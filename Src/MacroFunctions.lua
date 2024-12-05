local function is_target_attackable()
    return UnitExists('target') and (not UnitIsDead('target')) and UnitCanAttack('player', 'target')
end
-- 返回有无可攻击目标
function TargetEnemy()
    if is_target_attackable() then
        return true
    end
    TargetNearestEnemy()
    return is_target_attackable()
end
BananaAddSlashCommand(TargetEnemy, '/targetenemy')

-- 参考 https://legacy-wow.com/vanilla-addons/autoattack/
local is_attacking = false
BananaRegisterEvent(
    'PLAYER_ENTER_COMBAT',
    function()
        is_attacking = true
    end
)
BananaRegisterEvent(
    'PLAYER_LEAVE_COMBAT',
    function()
        is_attacking = false
    end
)
local function start_melee_attack()
    if not is_attacking then
        AttackTarget()
    end
end

function Cast(name)
    name = L(name)
    CastSpellByName(name)
end

local is_auto_repeating = false
BananaRegisterEvent(
    'START_AUTOREPEAT_SPELL',
    function()
        is_auto_repeating = true
    end
)
BananaRegisterEvent(
    'STOP_AUTOREPEAT_SPELL',
    function()
        is_auto_repeating = false
    end
)
local function cast_auto_repeating(name)
    if not is_auto_repeating then
        Cast(name)
    end
end
local function get_melee_dps()
    local lo, hi, off_lo, off_hi = UnitDamage('player')
    local spd, off_spd = UnitAttackSpeed('player')
    local dps = ((lo + hi) / 2) / spd
    local off_dps = off_spd and (((off_lo + off_hi) / 2) / off_spd) or 0
    return dps + off_dps
end
local function is_ranged_equipped()
    return GetInventoryItemTexture('player', 18) ~= nil
end
local function get_ranged_dps()
    -- https://wowpedia.fandom.com/wiki/API_UnitRangedDamage?oldid=219168 有误，speed并不会为0
    -- 从FrameXML\PaperDollFrame.lua:435,482可知，需要用GetInventoryItemXXX判断有无装备远程武器
    local spd, lo, hi = UnitRangedDamage('player')
    return ((lo + hi) / 2) / spd
end
local function get_ranged_type()
    local item_id = BananaParseItemLink(GetInventoryItemLink('player', 18))
    if item_id then
        local _, _, _, _, _, sub_type = GetItemInfo(item_id)
        return sub_type
    end
end
function InMeleeDistance()
    -- https://wowpedia.fandom.com/wiki/API_CheckInteractDistance?oldid=265528 10码，近似8码
    return CheckInteractDistance('target', 3)
end
function StartAttack()
    local _, player_class = UnitClass('player')
    -- 会出现被减速、被缴械、换武器等情况，所以每次都要判断，不要缓存结果
    if player_class == 'WARRIOR' or player_class == 'ROGUE' then
        if (not is_ranged_equipped()) or InMeleeDistance() then
            start_melee_attack()
        else
            -- https://wowpedia.fandom.com/wiki/ItemType?oldid=204286 ，注意是localized的
            local ranged_type = get_ranged_type()
            -- BananaPrint(ranged_type)
            if ranged_type == L('Bows') then
                Cast('Shoot Bow')
            elseif ranged_type == L('Crossbows') then
                Cast('Shoot Crossbow')
            elseif ranged_type == L('Guns') then
                Cast('Shoot Gun')
            elseif ranged_type == L('Thrown') then
                Cast('Throw')
            end
        end
    elseif player_class == 'HUNTER' then
        if (not is_ranged_equipped()) or InMeleeDistance() then
            start_melee_attack()
        else
            cast_auto_repeating('Auto Shot')
        end
    elseif player_class == 'MAGE' or player_class == 'PRIEST' or player_class == 'WARLOCK' then
        -- 魔杖没有最短距离限制
        if (not is_ranged_equipped()) or (InMeleeDistance() and get_melee_dps() > get_ranged_dps()) then
            start_melee_attack()
        else
            cast_auto_repeating('Shoot')
        end
    else
        start_melee_attack()
    end
end
BananaAddSlashCommand(StartAttack, '/startattack')

-- 如果存在，则返回index，否则返回nil
-- 1.12的UnitBuff/UnitDebuff很简陋，并没有名字信息，参见：
-- https://wowpedia.fandom.com/wiki/API_UnitBuff?oldid=204496
-- https://wowpedia.fandom.com/wiki/API_UnitDebuff?oldid=353435
function UnitHasBuff(unit, name)
    name = L(name)
    local result = false
    local index = 1
    while true do
        BananaScanningTooltip:ClearLines()
        BananaScanningTooltip:SetUnitBuff(unit, index)
        local text = BananaScanningTooltipTextLeft1:GetText()
        -- BananaPrint(index, text)
        if not text then
            break
        elseif text == name then
            result = true
            break
        else
            index = index + 1
        end
    end
    return result
end

function UnitHasDebuff(unit, name)
    name = L(name)
    local result = false
    local index = 1
    while true do
        BananaScanningTooltip:ClearLines()
        BananaScanningTooltip:SetUnitDebuff(unit, index)
        local text = BananaScanningTooltipTextLeft1:GetText()
        -- BananaPrint(index, text)
        if not text then
            break
        elseif text == name then
            result = true
            break
        else
            index = index + 1
        end
    end
    return result
end

function CastAura(name)
    if not (UnitHasBuff('target', name) or UnitHasDebuff('target', name)) then
        Cast(name)
        return true
    end
end

-- 如果已有aura则返回false，如此可自我施法后不执行别的比如PetAttack()动作避免进入战斗
function SelfCastAura(name)
    if not UnitHasBuff('player', name) then
        Cast(name, true)
        return true
    end
end

-- GetPlayerBuff()、GameTooltip:SetPlayerBuff()、CancelPlayerBuff()...这套函数和UnitXXX不太一样，说是Buff但是混合Debuff的，index起始位置也不一样，文档上说UnitXXX是3.0新增的，但是？
-- 参考BuffFrame.xml BuffFrame.lua，GetPlayerBuff一套函数纯粹是配合那些BuffButton用的
-- 返回的index专用于CancelPlayerBuff()函数
-- name可以是string或table，分别供CancelAura()和Dismount()用，func是匹配函数，Dismount()需要模糊匹配
-- 另外，CancelPlayerBuff()执行后，现存buff的index会移位，所以一次只能处理一个
local function player_buff_iterator(_s, id)
    id = id + 1
    if id < 0 or id > 15 then
        return nil
    end
    local index = GetPlayerBuff(id, 'HELPFUL')
    if index < 0 then
        return nil
    end
    -- 以下行必须加，如果之前返回nil，那么貌似SetPlayerBuff会修改owner
    BananaScanningTooltip:SetOwner(BananaScanningTooltip, 'ANCHOR_NONE')
    BananaScanningTooltip:ClearLines()
    BananaScanningTooltip:SetPlayerBuff(index)
    local text = BananaScanningTooltipTextLeft1:GetText()
    if not text then
        return nil
    end
    return id, index, text
end
local function player_buffs()
    return player_buff_iterator, nil, -1
end

function CancelAura(name)
    name = L(name)
    for id, index, text in player_buffs() do
        if text == name then
            CancelPlayerBuff(index)
            break
        end
    end
end

-- 注意，根据https://wowpedia.fandom.com/wiki/API_GetItemInfo?oldid=204429，只有本地缓存的才有，但并不影响Dismount()的工作
mount_names = {}
for _, mount_id in MountIDs do
    local mount_name = GetItemInfo(mount_id)
    if mount_name then
        mount_names[mount_name] = true
    end
end
local function match_mount_name(text)
    for name, _ in mount_names do
        if string.find(name, text) then
            return true
        end
    end
end
function Dismount()
    for id, index, text in player_buffs() do
        if match_mount_name(text) then
            CancelPlayerBuff(index)
            break
        end
    end
end

function CancelForm()
    for i = 1, GetNumShapeshiftForms() do
        local icon, name, active, castable = GetShapeshiftFormInfo(i)
        if active then
            Cast(name)
            break
        end
    end
end

-- 参考AutoDismount插件，错误信息在GlobalStrings.lua里面找
local ui_error_message_handlers = {
    [SPELL_FAILED_NOT_STANDING] = function()
        DoEmote('STAND')
    end,
    [SPELL_FAILED_NOT_MOUNTED] = Dismount,
    [ERR_ATTACK_MOUNTED] = Dismount,
    [ERR_TAXIPLAYERALREADYMOUNTED] = Dismount,
    [ERR_CANT_INTERACT_SHAPESHIFTED] = CancelForm,
    [ERR_MOUNT_SHAPESHIFTED] = CancelForm,
    [ERR_NOT_WHILE_SHAPESHIFTED] = CancelForm,
    [ERR_NO_ITEMS_WHILE_SHAPESHIFTED] = CancelForm,
    [ERR_TAXIPLAYERSHAPESHIFTED] = CancelForm,
    [SPELL_FAILED_NOT_SHAPESHIFT] = CancelForm,
    [SPELL_FAILED_NO_ITEMS_WHILE_SHAPESHIFTED] = CancelForm,
    [SPELL_NOT_SHAPESHIFTED] = CancelForm,
    [SPELL_NOT_SHAPESHIFTED_NOSPACE] = CancelForm
}
BananaRegisterEvent(
    'UI_ERROR_MESSAGE',
    function(ev, msg)
        local handler = ui_error_message_handlers[msg]
        if handler then
            handler()
        end
    end
)
TaxiFrame:SetScript(
    'OnShow',
    function()
        Dismount() -- PATCH
        PlaySound('igMainMenuOpen')
        DrawOneHopLines()
    end
)

function UseContainerItemByName(name)
    name = L(name)
    for bag_id = 0, 4 do
        for slot_index = 1, GetContainerNumSlots(bag_id) do
            local item_link = GetContainerItemLink(bag_id, slot_index)
            if item_link then
                -- BananaPrint(bag_id, slot_index, string.gsub(item_link, "|", "||"))
                local _, _, item_name = string.find(item_link, '%[(.+)%]')
                if name == item_name then
                    -- BananaPrint(bag_id, slot_index, item_name)
                    UseContainerItem(bag_id, slot_index)
                    return true
                end
            end
        end
    end
end

function UseInventoryItemByName(name)
    name = L(name)
    for slot_id = 0, 19 do
        local item_link = GetInventoryItemLink('player', slot_id)
        if item_link then
            local _, _, item_name = string.find(item_link, '%[(.+)%]')
            if name == item_name then
                BananaPrint(slot_id, item_name)
                UseInventoryItem(slot_id)
                return true
            end
        end
    end
end

function UnitHealthPercent(unit)
    return UnitHealth(unit) / UnitHealthMax(unit)
end

function UnitManaPercent(unit)
    local mana_max = UnitManaMax(unit)
    return mana_max == 0 and 0 or UnitMana(unit) / mana_max
end

-- CastingBarText:GetText()未必就是法术名，也可能是“正在引导”，很恶心
--[[ 测试代码：
BananaRegisterEvent('SPELLCAST_START', BananaPrint)
BananaRegisterEvent('SPELLCAST_STOP', BananaPrint)
BananaRegisterEvent('SPELLCAST_FAILED', BananaPrint)
BananaRegisterEvent('SPELLCAST_INTERRUPTED', BananaPrint)
BananaRegisterEvent('SPELLCAST_DELAYED', BananaPrint)
BananaRegisterEvent('SPELLCAST_CHANNEL_START', BananaPrint)
BananaRegisterEvent('SPELLCAST_CHANNEL_UPDATE', BananaPrint)
BananaRegisterEvent('SPELLCAST_CHANNEL_STOP', BananaPrint)
]]
function IsPlayerCastingOrChanneling()
    return CastingBarFrame.casting or CastingBarFrame.channeling
end
