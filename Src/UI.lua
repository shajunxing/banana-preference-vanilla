
local function toggle_hud_frame()
    BananaSetShown(BananaHUDFrame, UIParent:IsShown())
end

function BananaHUDFrame_OnLoad()
    BananaOnUIParentToggle(toggle_hud_frame)
    toggle_hud_frame()
    local this_name = this:GetName()
    local crosshair_lines = {
        [getglobal(this_name .. "CrosshairTop")] = "V",
        [getglobal(this_name .. "CrosshairBottom")] = "V",
        [getglobal(this_name .. "CrosshairLeft")] = "H",
        [getglobal(this_name .. "CrosshairRight")] = "H"
    }
    BananaOnCombatStateChanged(
        function(combat)
            local t, r, g, b
            if combat then
                t, r, g, b = 2, 1, 0, 0
            else
                t, r, g, b = 1, 0, 0, 0
            end
            for line, orientation in crosshair_lines do
                if orientation == "V" then
                    line:SetWidth(t)
                else
                    line:SetHeight(t)
                end
                line:SetTexture(r, g, b)
            end
        end
    )
end

-- 全屏按钮
BANANA_TOGGLE_FULLSCREEN = GetLocale() == 'zhCN' and '切换全屏' or 'Toggle Fullscreen'
function BananaFullscreenToggleButton_UpdateTextures()
    if GetCVar('gxMaximize') == '1' then
        this:SetNormalTexture('Interface\\PaperDollInfoFrame\\UI-Character-SkillsPageDown-Up')
        this:SetPushedTexture('Interface\\PaperDollInfoFrame\\UI-Character-SkillsPageDown-Down')
    else
        this:SetNormalTexture('Interface\\PaperDollInfoFrame\\UI-Character-SkillsPageUp-Up')
        this:SetPushedTexture('Interface\\PaperDollInfoFrame\\UI-Character-SkillsPageUp-Down')
    end
end

-- 弹出对话框贴顶并移除边框
-- 测试代码：/run StaticPopup_Show("TAKE_GM_SURVEY");StaticPopup_Show("CONFIRM_RESET_INSTANCES");message("foo")
StaticPopup1:SetPoint('TOP', 0, 0)
local backdrop = {
    bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
    insets = {left = 11, right = 12, top = 12, bottom = 11}
}
StaticPopup1:SetBackdrop(backdrop)
StaticPopup2:SetBackdrop(backdrop)
StaticPopup3:SetBackdrop(backdrop)
StaticPopup4:SetBackdrop(backdrop)
ScriptErrors:SetBackdrop(backdrop)
ScriptErrors:ClearAllPoints()
ScriptErrors:SetPoint('TOP', 0, 0)

-- 提示信息置顶
-- 测试代码：/run UIErrorsFrame:AddMessage("UIErrorTest", 1.0, 0.1, 0.1);RaidWarningFrame:AddMessage("Raid Warning Test");RaidBossEmoteFrame:AddMessage("Boss Emote Test")
UIErrorsFrame:SetPoint('TOP', 0, 0)
RaidWarningFrame:SetPoint('TOP', UIErrorsFrame, 'BOTTOM', 0, 0)
RaidBossEmoteFrame:SetPoint('TOP', RaidWarningFrame, 'BOTTOM', 0, 0)
ZoneTextFrame:ClearAllPoints() -- 默认是BOTTOM
ZoneTextFrame:SetPoint('TOP', 0, 0)
SubZoneTextFrame:ClearAllPoints() -- 默认是BOTTOM
SubZoneTextFrame:SetPoint('TOP', 0, 0)

