function BananaHealthManaBar_Initialize(this, unit)
    local this_name = this:GetName()
    local health_bar = getglobal(this_name .. 'HealthBar')
    local mana_bar = getglobal(this_name .. 'ManaBar')
    BananaHealthBar_Initialize(health_bar, unit)
    BananaManaBar_Initialize(mana_bar, unit)
end

-- 此函数专用于如果没有能量值则隐藏能量条
function BananaHealthManaBar_Update(this)
    -- 如果mana=0那么隐藏mana bar
    local this_name = this:GetName()
    local health_bar = getglobal(this_name .. 'HealthBar')
    local mana_bar = getglobal(this_name .. 'ManaBar')
    if mana_bar:GetValue() <= 0 then
        if mana_bar:IsShown() then
            mana_bar:Hide()
            this:SetHeight(health_bar:GetHeight())
        end
    else
        if not mana_bar:IsShown() then
            mana_bar:Show()
            this:SetHeight(health_bar:GetHeight() + mana_bar:GetHeight() + 1)
        end
    end
end

function BananaHealthBar_Update(this)
    if not this.unit then -- PLAYER_ENTERING_WORLD且this.unit未设置
        return
    end
    this:SetMinMaxValues(0, UnitHealthMax(this.unit))
    local value = UnitHealth(this.unit)
    this:SetValue(value)
    getglobal(this:GetName() .. 'Text'):SetText(value)
    -- 血条颜色，参考TargetFrame.lua TargetFrame_CheckFaction()
    -- 为了与系统血条颜色保持一致，此处做了调整，如果是自己以及自己或友方的宠物，都是绿色，如果是友方玩家，都是蓝色，不区分pvp状态，敌方玩家和宠物，无论是否能攻击，都是红色
    local r, g, b = 0, 0.2, 1 -- 默认蓝色，加亮
    if UnitPlayerControlled(this.unit) then
        if this.unit == 'player' or this.unit == 'pet' or UnitIsUnit(this.unit, 'player') then -- 自己和宠物
            r, g, b = 0, 1, 0
        elseif UnitIsFriend('player', this.unit) and (not UnitIsPlayer(this.unit)) then -- 友方宠物
            r, g, b = 0, 1, 0
        elseif UnitIsEnemy('player', this.unit) then -- 敌方玩家和宠物
            r, g, b = 1, 0, 0
        end
    elseif (UnitIsTapped(this.unit) and not UnitIsTappedByPlayer(this.unit)) then
        r, g, b = 0.5, 0.5, 0.5
    else
        local reaction = UnitReaction(this.unit, 'player')
        if reaction then
            r = UnitReactionColor[reaction].r
            g = UnitReactionColor[reaction].g
            b = UnitReactionColor[reaction].b
        end
    end
    this:SetStatusBarColor(r, g, b)
end

function BananaHealthBar_Initialize(this, unit)
    this.unit = unit
    this:SetScript('OnEvent', BananaHealthBar_OnEvent)
    this:RegisterEvent('PLAYER_ENTERING_WORLD')
    this:RegisterEvent('UNIT_HEALTH')
    this:RegisterEvent('UNIT_MAXHEALTH')
    this:RegisterEvent('PLAYER_TARGET_CHANGED')
    this:RegisterEvent('UNIT_FACTION') -- 调整血条颜色，野怪被别的玩家触摸变成灰色也是该事件
    this:RegisterEvent('UNIT_PET')
    BananaHealthBar_Update(this)
end

function BananaHealthBar_OnEvent()
    if not this.unit then
        return
    end
    if arg1 == this.unit or (event == 'PLAYER_TARGET_CHANGED' and this.unit == 'target') or (event == 'UNIT_PET' and arg1 == 'player' and this.unit == 'pet') or event == 'PLAYER_ENTERING_WORLD' then
        BananaHealthBar_Update(this)
    end
end

function BananaManaBar_Update(this)
    if not this.unit then
        return
    end
    this:SetMinMaxValues(0, UnitManaMax(this.unit))
    local value = UnitMana(this.unit)
    this:SetValue(value)
    getglobal(this:GetName() .. 'Text'):SetText(value)
    local color = ManaBarColor[UnitPowerType(this.unit)]
    this:SetStatusBarColor(color.r, color.g, color.b)
end

function BananaManaBar_Initialize(this, unit)
    this.unit = unit
    this:SetScript('OnEvent', BananaManaBar_OnEvent)
    this:RegisterEvent('PLAYER_ENTERING_WORLD')
    this:RegisterEvent('UNIT_MANA')
    this:RegisterEvent('UNIT_RAGE')
    this:RegisterEvent('UNIT_FOCUS')
    this:RegisterEvent('UNIT_ENERGY')
    this:RegisterEvent('UNIT_HAPPINESS')
    this:RegisterEvent('UNIT_MAXMANA')
    this:RegisterEvent('UNIT_MAXRAGE')
    this:RegisterEvent('UNIT_MAXFOCUS')
    this:RegisterEvent('UNIT_MAXENERGY')
    this:RegisterEvent('UNIT_MAXHAPPINESS')
    this:RegisterEvent('UNIT_DISPLAYPOWER')
    this:RegisterEvent('PLAYER_TARGET_CHANGED')
    this:RegisterEvent('UNIT_PET')
    BananaManaBar_Update(this)
end

function BananaManaBar_OnEvent()
    if not this.unit then
        return
    end
    if arg1 == this.unit or (event == 'PLAYER_TARGET_CHANGED' and this.unit == 'target') or (event == 'UNIT_PET' and arg1 == 'player' and this.unit == 'pet') or event == 'PLAYER_ENTERING_WORLD' then
        BananaManaBar_Update(this)
    end
end
