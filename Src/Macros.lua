-- 调整宏界面字体
LoadAddOn('Blizzard_MacroUI')
MacroFrameText:SetFontObject('NumberFontNormal')

-- 一键宏(One-Button Macro)
OBM = {}
setmetatable(
    OBM,
    {
        __call = function(self)
            local _, player_class = UnitClass('player')
            local func = self[player_class]
            return func and func()
        end
    }
)
BananaAddSlashCommand(OBM, '/obm')

local function is_target_can_be_drained_life()
    -- 注意UnitCreatureType()函数在wowlua里面显示不出中文
    local target_type = UnitCreatureType('target')
    return target_type ~= L('Mechanical')
end
OBM['WARLOCK'] = function()
    -- 不能return，可能会法力不足，下同
    SelfCastAura('Demon Armor')
    if not TargetEnemy() then
        return
    end
    PetAttack() -- pet需要拉仇恨
    if IsPlayerCastingOrChanneling() then
        return
    end
    local in_combat = UnitAffectingCombat('player')
    local mana_percent = UnitManaPercent('player')
    if (not in_combat and mana_percent < 0.9) or (in_combat and mana_percent < 0.5) then
        Cast('Dark Pact')
    end
    CastAura('Corruption')
    CastAura('Curse of Agony')
    CastAura('Siphon Life')
    if UnitHasBuff('player', 'Shadow Trance') then
        Cast('Shadow Bolt')
    end
    local player_health_percent = UnitHealthPercent('player')
    local player_mana_percent = UnitManaPercent('player')
    local pet_health_percent = UnitHealthPercent('pet')
    local target_mana_percent = UnitManaPercent('target')
    if pet_health_percent < 0.7 and player_health_percent > pet_health_percent then
        Cast('Health Funnel')
    end
    if player_health_percent < 0.8 and is_target_can_be_drained_life() and player_mana_percent > 0.2 then
        Cast('Drain Life')
    end
    if target_mana_percent > 0.1 then
        Cast('Drain Mana')
    end
    -- 这里不要用else，不会卡宏，另外吸取生命的距离只有20码
    StartAttack()
end

OBM['HUNTER'] = function()
    TargetEnemy()
    StartAttack()
    PetAttack()
    if LFTlft then
        -- 乌龟服
        -- 乌龟服的孤狼守护魔耗太高，不自动施放
        if InMeleeDistance() or UnitHasBuff('player', 'Aspect of the Wolf') then
            if UnitIsPlayer('target') then
                CastAura('Wing Clip')
            end
            Cast('Raptor Strike')
            Cast('Mongoose Bite')
            Cast('Counterattack')
        else
            if not (UnitHasDebuff('target', 'Serpent Sting') or UnitHasDebuff('target', 'Scorpid Sting') or UnitHasDebuff('target', 'Viper Sting')) and UnitCreatureType('target') ~= 'Elemental' and UnitCreatureType('target') ~= 'Mechanical' then
                -- 毒蝎钉刺手动施放
                if UnitMana('target') > 8 and UnitPowerType('target') == 0 and UnitLevel('player') >= 36 then
                    Cast('Viper Sting')
                else
                    Cast('Serpent Sting')
                end
            end
            CastAura("Hunter's Mark")
            Cast('Arcane Shot')
        end
        if UnitIsUnit('targettarget', 'player') then
            Cast('Growl')
        end
        if UnitMana('pet') > 50 then
            Cast('Bite')
        end
        if UnitMana('pet') > 75 then
            Cast('Claw')
        end
        if UnitAffectingCombat('player') then
            Cast('Bestial Wrath')
        end
    else
        -- 经测试，CheckInteractDistance("target", 2)大概是7码，小于为1，大于为nil，第二个参数1或者3大概是5码
        if InMeleeDistance() then
            if UnitIsUnit('targettarget', 'player') then
                SelfCastAura('Aspect of the Monkey')
            end
            if UnitIsPlayer('target') then
                CastAura('Wing Clip')
            end
            Cast('Raptor Strike')
            Cast('Mongoose Bite')
            Cast('Counterattack')
        else
            if not (UnitHasDebuff('target', 'Serpent Sting') or UnitHasDebuff('target', 'Scorpid Sting') or UnitHasDebuff('target', 'Viper Sting')) and UnitCreatureType('target') ~= 'Elemental' and UnitCreatureType('target') ~= 'Mechanical' then
                -- 毒蝎钉刺手动施放
                if UnitMana('target') > 8 and UnitPowerType('target') == 0 and UnitLevel('player') >= 36 then
                    Cast('Viper Sting')
                else
                    Cast('Serpent Sting')
                end
            end
            CastAura("Hunter's Mark")
            Cast('Arcane Shot')
        end
        if UnitIsUnit('targettarget', 'player') then
            Cast('Growl')
        end
        if UnitMana('pet') > 50 then
            Cast('Bite')
        end
        if UnitMana('pet') > 75 then
            Cast('Claw')
        end
    end
end

function BananaHunterSlow()
    if InMeleeDistance() then
        CastAura('Wing Clip')
    else
        CastAura('Concussive Shot')
    end
end

function BananaShadowmeld()
    Dismount()
    SelfCastAura('Shadowmeld')
    if not UnitHasBuff('pet', 'Prowl') then
        Cast('Prowl')
    end
end

BananaTarget = {
    ['Broken Tooth'] = '断牙',
    ['Marsh Flesheater'] = '沼泽食腐鱼人',
    ["Bhag'thera"] = '巴尔瑟拉',
    ['Tethis'] = '泰希斯',
    ['Andre Firebeard'] = '安德雷·费尔比德',
    ['Caliph Scorpidsting'] = '卡利夫·斯科比斯汀'
}
setmetatable(
    BananaTarget,
    {
        __call = function(self)
            local locale = GetLocale()
            for en, zh in self do
                local name = locale == 'zhCN' and zh or en
                TargetExact(name)
            end
        end
    }
)

-- 治疗宠物
function BananaHunterHeal()
    if not UnitExists('pet') then
        Cast('Call Pet')
    elseif UnitIsDead('pet') then
        Cast('Revive Pet')
    else
        Cast('Mend Pet')
    end
end

function BananaDruidAttack()
    if UnitHealth('player') < (UnitHealthMax('player') * 0.8) then
        SelfCastAura('Rejuvenation')
    end
    SelfCastAura('Mark of the Wild')
    SelfCastAura('Thorns')
    TargetEnemy()
    StartAttack()
    CastAura('Moonfire')
end

function BananaWarriorAttack()
    TargetEnemy()
    StartAttack()
    SelfCastAura('Battle Shout')
    Cast('Overpower')
    CastAura('Rend')
    Cast('Heroic Strike')
end

function BananaPaladinAttack()
    TargetEnemy()
    StartAttack()
    SelfCastAura('Blessing of Might')
    SelfCastAura('Seal of Righteousness')
    Cast('Judgement')
end

function BananaRogueAttack()
    if (GetComboPoints() > 0) and (not UnitHasBuff('player', 'Slice and Dice')) then
        Cast('Slice and Dice')
    end
    Cast('Sinister Strike')
end

OBM['PALADIN'] = function()
    SelfCastAura('Blessing of Wisdom')
    TargetEnemy()
    StartAttack()
    if not UnitHasDebuff('target', 'Judgement of Wisdom') then
        SelfCastAura('Seal of Wisdom')
        Cast('Judgement')
    else
        SelfCastAura('Seal of Command')
    end
    if UnitManaPercent('player') > 0.5 then
        Cast('Judgement')
    end
end

OBM['WARRIOR'] = function()
    TargetEnemy()
    StartAttack()
    -- SelfCastAura('Shield Block')
    Cast('Bloodrage')
    CastAura('Rend')
    Cast('Shield Slam')
    Cast('Revenge')
    if UnitMana('player') > 32 then
        Cast('Heroic Strike')
    end
end
