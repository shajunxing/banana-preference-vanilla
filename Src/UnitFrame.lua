-- PlayerFrame.xml PetFrame.xml TargetFrame.xml PartyFrame.xml PartyFrameTemplates.xml 边框半透明
local alpha = 0.8
PlayerFrameTexture:SetAlpha(alpha)
PetFrameTexture:SetAlpha(alpha)
TargetFrameTexture:SetAlpha(alpha)
TargetofTargetTexture:SetAlpha(alpha)
PartyMemberFrame1Texture:SetAlpha(alpha)
PartyMemberFrame2Texture:SetAlpha(alpha)
PartyMemberFrame3Texture:SetAlpha(alpha)
PartyMemberFrame4Texture:SetAlpha(alpha)
PartyMemberFrame1PetFrameTexture:SetAlpha(alpha)
PartyMemberFrame2PetFrameTexture:SetAlpha(alpha)
PartyMemberFrame3PetFrameTexture:SetAlpha(alpha)
PartyMemberFrame4PetFrameTexture:SetAlpha(alpha)

-- 删掉状态条文本前缀，加亮蓝色
SetTextStatusBarTextPrefix(PlayerFrameHealthBar, nil)
SetTextStatusBarTextPrefix(PlayerFrameManaBar, nil)
SetTextStatusBarTextPrefix(MainMenuExpBar, nil)
ManaBarColor = {
    [0] = {r = 0.04, g = 0.44, b = 0.95, prefix = nil}, -- 10.0浅色风格
    [1] = {r = 1.00, g = 0.00, b = 0.00, prefix = nil},
    [2] = {r = 1.00, g = 0.50, b = 0.25, prefix = nil},
    [3] = {r = 1.00, g = 1.00, b = 0.00, prefix = nil},
    [4] = {r = 0.00, g = 1.00, b = 1.00, prefix = nil}
}

-- TargetFrame增宽
-- TargetFrameBackground:ClearAllPoints()
-- TargetFrameBackground:SetAllPoints()
local w, h = 232, 100
local dw = 59
local l, r, t, b = 0.09375, 1, 0, 0.78125
TargetFrame:SetWidth(w + dw)
TargetFrame:SetHitRectInsets(96 + dw, 6, 4, 9)
TargetFrameTexture:SetTexCoord(l + (r - l) * 0.5, r, t, b)
TargetFrameTexture:SetWidth(w * 0.5)
TargetFrameTexture:SetHeight(h)
TargetFrameTexture:ClearAllPoints()
TargetFrameTexture:SetPoint('RIGHT', 0, 0)
local tex_file = 'Interface\\TargetingFrame\\UI-TargetingFrame'
local left_tex = TargetFrameTextureFrame:CreateTexture(nil, 'BACKGROUND')
left_tex:SetTexture(tex_file)
left_tex:SetTexCoord(l, l + (r - l) * 0.25, t, b)
left_tex:SetAlpha(alpha)
left_tex:SetWidth(w * 0.25)
left_tex:SetHeight(h)
left_tex:SetPoint('LEFT', 0, 0)
local middle_tex = TargetFrameTextureFrame:CreateTexture(nil, 'BACKGROUND')
middle_tex:SetTexture(tex_file)
middle_tex:SetTexCoord(l + (r - l) * 0.25, l + (r - l) * 0.5, t, b)
middle_tex:SetAlpha(alpha)
middle_tex:SetHeight(100)
middle_tex:SetPoint('LEFT', w * 0.25, 0)
middle_tex:SetPoint('RIGHT', -w * 0.5, 0)
TargetLevelText:SetPoint('CENTER', 63 + dw * 0.5, -16)
TargetHighLevelTexture:SetPoint('CENTER', 63 + dw * 0.5, -16)
TargetFrameHealthBar:SetWidth(119 + dw)
TargetFrameManaBar:SetWidth(119 + dw)
TargetFrameBackground:SetWidth(119 + dw)
TargetFrameNameBackground:SetWidth(119 + dw)
TargetName:SetWidth(100 + dw)
-- 默认FrameLevel，TargetFrame 1，TargetFrameTextureFrame 2，TargetFrameHealthBar TargetFrameManaBar 1
-- TargetFrame的右侧会挡住HealthBar ManaBar的鼠标提示
TargetFrameTextureFrame:SetFrameLevel(3)
TargetFrameHealthBar:SetFrameLevel(2)
TargetFrameManaBar:SetFrameLevel(2)
-- TargetFrameBackground的目的是让目标姓名背景变暗，但是reload之后会失效（估计跑到TargetFrameNameBackground后面了）
TargetFrameBackground:SetDrawLayer('BORDER')

-- TargetFrame增加状态条文字
-- 参考UnitFrame.lua、TextStatusBar.xml、TextStatusBar.lua
-- 血条前缀“Health”是在CharacterFrame_OnLoad()里面设置的，真乱
-- CharacterFrame_OnHide()会调用HideTextStatusBarText()隐藏玩家和宠物的数字
-- TextStatusBar_UpdateTextString会在UnitFrame_UpdateManaType（GetCVar("statusBarText") == "1"之时）、TextStatusBar.OnEnter、TextStatusBar_OnValueChanged三处调用，重置我设置的文字格式
-- 甚至有在StatusBar之外调用UnitFrameHealthBar_Update、UnitFrameManaBar_Update等更改的
-- TargetFrame.OnLoad里面的UnitFrame_Initialize，是有TargetFrameHealthBarText和TargetFrameManaBarText的，但是当然都是nil
TargetFrameTextureFrame:CreateFontString('TargetFrameHealthBarText', 'OVERLAY', 'TextStatusBarText')
TargetFrameHealthBarText:SetPoint('CENTER', -50, 4)
TargetFrameHealthBar:RegisterEvent('CVAR_UPDATE') -- 参考PlayerFrameHealthBar.OnLoad
TargetFrameHealthBar.lockShow = 0
TargetFrameHealthBar.textLockable = 1
SetTextStatusBarText(TargetFrameHealthBar, TargetFrameHealthBarText)
TargetFrameTextureFrame:CreateFontString('TargetFrameManaBarText', 'OVERLAY', 'TextStatusBarText')
TargetFrameManaBarText:SetPoint('CENTER', -50, -8)
TargetFrameManaBar:RegisterEvent('CVAR_UPDATE') -- 参考PlayerFrameHealthBar.OnLoad
TargetFrameManaBar.lockShow = 0
TargetFrameManaBar.textLockable = 1
SetTextStatusBarText(TargetFrameManaBar, TargetFrameManaBarText)

-- PATCH：默认如果valueMax=0，那么TargetFrameManaBar会Hide，但是TargetFrameManaBarText并不是TargetFrameManaBar的儿子所以不会Hide，此时TargetFrameManaBarText文本是上一次的，并不正确
function TextStatusBar_UpdateTextString(textStatusBar)
    if (not textStatusBar) then
        textStatusBar = this
    end
    local string = textStatusBar.TextString
    if (string) then
        local value = textStatusBar:GetValue()
        local valueMin, valueMax = textStatusBar:GetMinMaxValues()
        if (valueMax > 0) then
            textStatusBar:Show()
            if (value == 0 and textStatusBar.zeroText) then
                string:SetText(textStatusBar.zeroText)
                textStatusBar.isZero = 1
                string:Show()
            else
                textStatusBar.isZero = nil
                if (textStatusBar.prefix) then
                    string:SetText(textStatusBar.prefix .. ' ' .. value .. ' / ' .. valueMax)
                else
                    string:SetText(value .. ' / ' .. valueMax)
                end
                if (GetCVar('statusBarText') == '1' and textStatusBar.textLockable) then
                    string:Show()
                elseif (textStatusBar.lockShow > 0) then
                    string:Show()
                else
                    string:Hide()
                end
            end
        else
            textStatusBar:Hide()
            string:Hide() -- PATCH
        end
    end
end

local fake_player_name = nil
local fake_pet_name = nil
local fake_guild_name = nil

local function set_fake_name_if_needed()
    if fake_player_name and (this.unit == 'player' or (this.unit == 'target' and UnitIsUnit('target', 'player'))) then
        this.name:SetText(fake_player_name)
    elseif fake_pet_name and (this.unit == 'pet' or (this.unit == 'target' and UnitIsUnit('target', 'pet'))) then
        this.name:SetText(fake_pet_name)
    else
        this.name:SetText(GetUnitName(this.unit))
    end
end

function UnitFrame_Update()
    set_fake_name_if_needed() -- PATCH: 设置假名
    SetPortraitTexture(this.portrait, this.unit)
    UnitFrameHealthBar_Update(this.healthbar, this.unit)
    UnitFrameManaBar_Update(this.manabar, this.unit)
end

function UnitFrame_OnEvent(event)
    if (event == 'UNIT_NAME_UPDATE') then
        if (arg1 == this.unit) then
            set_fake_name_if_needed() -- PATCH: 设置假名
        end
    elseif (event == 'UNIT_PORTRAIT_UPDATE') then
        if (arg1 == this.unit) then
            SetPortraitTexture(this.portrait, this.unit)
        end
    elseif (event == 'UNIT_DISPLAYPOWER') then
        if (arg1 == this.unit) then
            UnitFrame_UpdateManaType()
        end
    end
end

function TargetofTarget_OnUpdate(elapsed)
    if (CURRENT_TARGETTARGET ~= UnitName('targettarget')) then
        CURRENT_TARGETTARGET = UnitName('targettarget')
        SetPortraitTexture(this.portrait, this.unit)
        -- PATCH: 设置假名
        if fake_player_name and UnitIsUnit('targettarget', 'player') then
            this.name:SetText(fake_player_name)
        elseif fake_pet_name and UnitIsUnit('targettarget', 'pet') then
            this.name:SetText(fake_pet_name)
        else
            this.name:SetText(GetUnitName(this.unit))
        end
    -- END OF PATCH
    end
    TargetofTarget_Update()
end

function PaperDollFrame_SetGuild()
    -- PATCH: 设置假名
    if fake_guild_name then
        CharacterGuildText:Show()
        CharacterGuildText:SetText(fake_guild_name)
        HonorGuildText:Show()
        HonorGuildText:SetText(fake_guild_name)
    else
        -- END OF PATCH
        local guildName, title, rank = GetGuildInfo('player') -- PATCH: title也应该是local的
        if (guildName) then
            CharacterGuildText:Show()
            CharacterGuildText:SetText(format(TEXT(GUILD_TITLE_TEMPLATE), title, guildName))
            -- Set it for the honor frame while we're at it
            HonorGuildText:Show()
            HonorGuildText:SetText(format(TEXT(GUILD_TITLE_TEMPLATE), title, guildName))
        else
            CharacterGuildText:Hide()
            HonorGuildText:Hide()
        end
    end
end

-- 把newbie tooltip放在下面
function UnitFrame_OnEnter()
    if (SpellIsTargeting()) then
        if (SpellCanTargetUnit(this.unit)) then
            SetCursor('CAST_CURSOR')
        else
            SetCursor('CAST_ERROR_CURSOR')
        end
    end
    GameTooltip_SetDefaultAnchor(GameTooltip, this)
    GameTooltip:SetUnit(this.unit)
    this.r, this.g, this.b = GameTooltip_UnitColor(this.unit)
    GameTooltipTextLeft1:SetTextColor(this.r, this.g, this.b)
    if (SHOW_NEWBIE_TIPS == '1' and this:GetName() ~= 'PartyMemberFrame1' and this:GetName() ~= 'PartyMemberFrame2' and this:GetName() ~= 'PartyMemberFrame3' and this:GetName() ~= 'PartyMemberFrame4') then
        if (this:GetName() == 'PlayerFrame') then
            GameTooltip:AddLine(NEWBIE_TOOLTIP_PARTYOPTIONS, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
        elseif (UnitPlayerControlled('target') and not UnitIsUnit('target', 'player') and not UnitIsUnit('target', 'pet')) then
            GameTooltip:AddLine(NEWBIE_TOOLTIP_PLAYEROPTIONS, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
        end
    end
    GameTooltip:Show() -- 必须加上才能重新调整AddLine之后的尺寸
end

function UnitFrame_OnLeave()
    GameTooltip:FadeOut()
end

UnitFrame_OnUpdate = function()
end
