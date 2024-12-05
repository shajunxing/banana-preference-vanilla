-- WorldMap.xml
UIPanelWindows["WorldMapFrame"].area = "left"
-- WorldMapFrame:SetParent(UIParent) -- 世界地图很多代码是有问题的，建议不改了
WorldMapFrame:ClearAllPoints()
WorldMapFrame:SetWidth(1024)
WorldMapFrame:SetHeight(768)
WorldMapFrame:SetScale(0.8)
WorldMapFrame:SetScript(
    "OnShow",
    function()
        -- xml里的OnShow会修改scale，这里去掉
        UpdateMicroButtons()
        SetMapToCurrentZone()
        PlaySound("igQuestLogOpen")
        CloseDropDownMenus()
        WorldMapFrame_PingPlayerPosition()
    end
)
BlackoutWorld:SetAlpha(0) -- WorldMap.lua里面会变更尺寸
WorldMapFrame:EnableKeyboard(false)

local vertical_offset = -128
local bar_width = 128
local health_bar_height = 8
local mana_bar_height = 4
local bar_margin = 2
local bar_spacing = 1
local bar_texture = "Interface\\TargetingFrame\\UI-StatusBar"

local status_frame = CreateFrame("Frame", nil, UIParent)
status_frame:EnableMouse(false)
status_frame:SetWidth(bar_width)
status_frame:SetHeight(health_bar_height + mana_bar_height + bar_spacing)
status_frame:SetPoint("TOP", UIParent, "CENTER", 0, vertical_offset)
-- local combat_bg = status_frame:CreateTexture()
-- combat_bg:SetPoint("BOTTOMLEFT", -6, -6)
-- combat_bg:SetPoint("TOPRIGHT", 6, 6)
-- combat_bg:SetTexture(1, 0, 0, 0.2)
local status_bg = status_frame:CreateTexture()
status_bg:SetPoint("BOTTOMLEFT", -2, -2)
status_bg:SetPoint("TOPRIGHT", 2, 2)
status_bg:SetTexture(0, 0, 0, 0.8)

-- 替换默认的血条文字
PlayerFrameHealthBarText:SetAlpha(0)
local player_health_text = PlayerFrame:GetChildren():GetChildren():CreateFontString(nil, "OVERLAY", "TextStatusBarText")
player_health_text:SetPoint("CENTER", 50, 4)

local target_health_text = TargetFrameTextureFrame:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
target_health_text:SetPoint("CENTER", -50, 4)

local health_bar = CreateFrame("StatusBar", nil, status_frame)
health_bar:EnableMouse(false)
health_bar:SetWidth(bar_width)
health_bar:SetHeight(health_bar_height)
health_bar:SetPoint("TOP", 0, 0)
health_bar:SetStatusBarTexture(bar_texture)
-- 血条颜色是用HealthBar_OnValueChanged()函数设置的，但是第二个smooth参数（低血量变色）貌似没有用的，所以都是绿色
health_bar:SetStatusBarColor(0, 1, 0)
health_bar:SetScript(
    "OnEvent",
    function()
        if event == "PLAYER_ENTERING_WORLD" or arg1 == "player" then
            local value = UnitHealth("player")
            local max_value = UnitHealthMax("player")
            this:SetMinMaxValues(0, max_value)
            this:SetValue(value)
            player_health_text:SetText(value)
        elseif event == "PLAYER_TARGET_CHANGED" or arg1 == "target" then
            target_health_text:SetText(UnitHealth("target"))
        end
    end
)
health_bar:RegisterEvent("PLAYER_ENTERING_WORLD")
health_bar:RegisterEvent("UNIT_HEALTH")
health_bar:RegisterEvent("UNIT_MAXHEALTH")
health_bar:RegisterEvent("PLAYER_TARGET_CHANGED")

PlayerFrameManaBarText:SetAlpha(0)
local player_mana_text = PlayerFrame:GetChildren():GetChildren():CreateFontString(nil, "OVERLAY", "TextStatusBarText")
player_mana_text:SetPoint("CENTER", 50, -8)

local target_mana_text = TargetFrameTextureFrame:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
target_mana_text:SetPoint("CENTER", -50, -8)

local mana_bar = CreateFrame("StatusBar", nil, status_frame)
mana_bar:EnableMouse(false)
mana_bar:SetWidth(bar_width)
mana_bar:SetHeight(mana_bar_height)
mana_bar:SetPoint("TOP", health_bar, "BOTTOM", 0, -bar_spacing)
mana_bar:SetStatusBarTexture(bar_texture)
-- 调整颜色
ManaBarColor[0].g = 0.2
mana_bar:SetScript(
    "OnEvent",
    function()
        if event == "PLAYER_ENTERING_WORLD" or arg1 == "player" then
            local value = UnitMana("player")
            local max_value = UnitManaMax("player")
            mana_bar:SetMinMaxValues(0, max_value)
            mana_bar:SetValue(value)
            local color = ManaBarColor[UnitPowerType("player")]
            mana_bar:SetStatusBarColor(color.r, color.g, color.b)
            player_mana_text:SetText(value)
        elseif event == "PLAYER_TARGET_CHANGED" or arg1 == "target" then
            target_mana_text:SetText(UnitMana("target"))
        end
    end
)
mana_bar:RegisterEvent("PLAYER_ENTERING_WORLD")
mana_bar:RegisterEvent("UNIT_MANA")
mana_bar:RegisterEvent("UNIT_RAGE")
mana_bar:RegisterEvent("UNIT_FOCUS")
mana_bar:RegisterEvent("UNIT_ENERGY")
mana_bar:RegisterEvent("UNIT_HAPPINESS")
mana_bar:RegisterEvent("UNIT_MAXMANA")
mana_bar:RegisterEvent("UNIT_MAXRAGE")
mana_bar:RegisterEvent("UNIT_MAXFOCUS")
mana_bar:RegisterEvent("UNIT_MAXENERGY")
mana_bar:RegisterEvent("UNIT_MAXHAPPINESS")
mana_bar:RegisterEvent("UNIT_DISPLAYPOWER")
mana_bar:RegisterEvent("PLAYER_TARGET_CHANGED")

-- wowlua测试代码
LoadAddOn("Blizzard_BattlefieldMinimap");BattlefieldMinimap:Show()
KeyRingButton:Show()
MainMenuBar:SetScale(1)

TargetHighLevelTexture:Show()
TargetLeaderIcon:Show()
TargetPVPIcon:Show()
TargetRaidTargetIcon:Show()

if not Foo then
   CreateFrame("Frame", "Foo", UIParent, "BananaFrameTemplate1")
end
Foo:ClearAllPoints()
Foo:SetPoint("TOP", 0, 0)
Foo:SetWidth(300)
Foo:SetHeight(200)
FooTitle:SetText("Foo")
Foo:Show()

if not Bar then
   CreateFrame("Frame", "Bar", UIParent, "BananaFrameTemplate2")
end
Bar:ClearAllPoints()
Bar:SetPoint("TOP", 30, -30)
Bar:SetWidth(300)
Bar:SetHeight(200)
BarTitle:SetText("Bar")
Bar:Show()
Bar:Raise()

if not Baz then
   CreateFrame("Frame", "Baz", UIParent, "BananaFrameTemplate3")
   CreateFrame("ScrollFrame", "Qux", Baz, "BananaScrollingEditTemplate")
   Qux:SetPoint("TOPLEFT", 32, -32)
   Qux:SetPoint("BOTTOMRIGHT", -32, 32)
   QuxBackground:SetTexture(0, 0, 0)
end
Baz:ClearAllPoints()
Baz:SetPoint("TOP", 60, -60)
Baz:SetWidth(300)
Baz:SetHeight(200)
BazTitle:SetText("Baz")
Baz:Show()
Baz:Raise()

BananaInspect(WorldFrame)

for  _, child in {WorldFrame:GetChildren()} do
   if child:GetObjectType() == "Button" then
      for k, v in child do
         print(k, v)
      end
   end
end









