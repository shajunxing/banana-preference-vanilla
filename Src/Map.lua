-- Minimap.xml
-- Minimap如果重设大小，里面的箭头不会缩放，另外，Minimap没有SetScale方法
MinimapCluster:EnableMouse(false) -- 隐藏地图后鼠标可以穿过
MinimapBorderTop:ClearAllPoints()
MinimapBorderTop:SetTexture(0, 0, 0, 0) -- 可以用来查看widget位置
MinimapBorderTop:SetAllPoints()
MinimapZoomIn:Hide()
MinimapZoomOut:Hide()
MinimapToggleButton:Hide()
MinimapZoneTextButton:Hide()
MinimapZoneText:SetParent(MinimapCluster)
MinimapZoneText:ClearAllPoints()
MinimapZoneText:SetPoint('TOP', 0, -2)
local cluster_width = 182 -- 默认192
MinimapCluster:SetWidth(cluster_width)
MinimapCluster:SetHeight(cluster_width)
MinimapZoneText:SetWidth(cluster_width)
MinimapZoneText:SetTextHeight(10) -- 中文版字体过大，修正为与英文版一致，且都变小
Minimap:ClearAllPoints()
Minimap:SetPoint('CENTER', 0, 0)
Minimap:SetMaskTexture('Interface\\AddOns\\BananaPreference\\Res\\MinimapMask')
MinimapBorder:ClearAllPoints()
MinimapBorder:SetTexCoord(0, 1, 0, 1)
MinimapBorder:SetTexture('Interface\\AddOns\\BananaPreference\\Res\\MinimapBorder')
MinimapBorder:SetPoint('CENTER', Minimap, 0, 0)
local border_size = 146
MinimapBorder:SetWidth(border_size)
MinimapBorder:SetHeight(border_size)
--[[
测试代码：
MiniMapTrackingFrame:Show()
MiniMapMeetingStoneFrame:Show()
MiniMapMailFrame:Show()
MiniMapBattlefieldFrame:Show()
]]
local tracking_border_tex = 'Interface\\AddOns\\BananaPreference\\Res\\MinimapTrackingBorder'
MiniMapTrackingBorder:SetTexture(tracking_border_tex)
MiniMapMeetingStoneBorder:SetTexture(tracking_border_tex)
MiniMapMailBorder:SetTexture(tracking_border_tex)
MiniMapBattlefieldBorder:SetTexture(tracking_border_tex)
MiniMapBattlefieldIcon:SetWidth(22)
MiniMapBattlefieldIcon:SetHeight(22)
-- 追踪图标修正为圆角
MiniMapTrackingFrame:SetScript(
    'OnEvent',
    function()
        if (event == 'PLAYER_AURAS_CHANGED') then
            local icon = GetTrackingTexture()
            if (icon) then
                SetPortraitToTexture(MiniMapTrackingIcon, icon)
                MiniMapTrackingFrame:Show()
            else
                MiniMapTrackingFrame:Hide()
            end
        end
    end
)

-- GameTime.xml
GameTimeFrame:Hide()
MinimapCluster:CreateFontString('GameTimeText', 'ARTWORK', 'NumberFontNormal')
-- FontString有缺陷，如果自动宽度，屏幕非等比缩放，末尾字符可能会被吃掉，比如1,s
-- GameTimeText:SetWidth(cluster_width)
-- GameTimeText:SetPoint("BOTTOM", 0, 0)
GameTimeText:SetTextHeight(10)
GameTimeText:SetPoint('TOPRIGHT', -2, -2)
BANANA_CLOCK_FORMAT = '%H:%M'
local function update_clock()
    GameTimeText:SetText(date(BANANA_CLOCK_FORMAT, time()))
    return 1
end
BananaAddTask(update_clock)

local minimap_scale = 1.4
local function scale_minimap()
    MinimapCluster:SetScale(minimap_scale)
    -- BuffFrame.xml
    local xoffset = cluster_width * (minimap_scale - 1)
    BuffFrame:SetPoint('TOPRIGHT', -205 - xoffset, -13)
    TemporaryEnchantFrame:SetPoint('TOPRIGHT', -175 - xoffset, -13)
    -- HelpFrame.lua里面也有
    function TicketStatusFrame_OnEvent()
        if (event == 'PLAYER_ENTERING_WORLD') then
            GetGMTicket()
        else
            if (arg1 ~= 0) then
                this:Show()
                TemporaryEnchantFrame:SetPoint('TOPRIGHT', this:GetParent(), 'TOPRIGHT', -205 - xoffset, (-this:GetHeight()))
                refreshTime = GMTICKET_CHECK_INTERVAL
            else
                this:Hide()
                TemporaryEnchantFrame:SetPoint('TOPRIGHT', 'UIParent', 'TOPRIGHT', -180 - xoffset, -13)
            end
        end
    end
end
scale_minimap()

Minimap:EnableMouseWheel(true)
Minimap:SetScript(
    'OnMouseWheel',
    function()
        if arg1 == 1 then
            MinimapZoomIn:Click()
        elseif arg1 == -1 then
            MinimapZoomOut:Click()
        end
    end
)

SpellBookFrame:EnableMouseWheel(true)
SpellBookFrame:SetScript(
    'OnMouseWheel',
    function()
        if arg1 == 1 then
            SpellBookPrevPageButton:Click()
        elseif arg1 == -1 then
            SpellBookNextPageButton:Click()
        end
    end
)

MerchantFrame:EnableMouseWheel(true)
MerchantFrame:SetScript(
    'OnMouseWheel',
    function()
        if arg1 == 1 then
            if MerchantPrevPageButton:IsShown() then
                MerchantPrevPageButton:Click()
            end
        elseif arg1 == -1 then
            if MerchantNextPageButton:IsShown() then
                MerchantNextPageButton:Click()
            end
        end
    end
)

ItemTextFrame:EnableMouseWheel(true)
ItemTextFrame:SetScript(
    'OnMouseWheel',
    function()
        if arg1 == 1 then
            if ItemTextPrevPageButton:IsShown() then
                ItemTextPrevPageButton:Click()
            end
        elseif arg1 == -1 then
            if ItemTextNextPageButton:IsShown() then
                ItemTextNextPageButton:Click()
            end
        end
    end
)

-- WorldMapFrame.xml
UIPanelWindows['WorldMapFrame'] = {area = 'center', pushable = 0, whileDead = 1}
WorldMapFrame:EnableKeyboard(false)
WorldMapFrame:EnableMouse(true)
-- 下两行代码使得WorldMapFrame:Show()之后，和别的toplevel比如任务列表能够正确地点击鼠标改变前后
-- 不能设置，否则pfQuest无法正常显示
-- WorldMapFrame:SetFrameStrata("MEDIUM")
-- WorldMapFrame:SetToplevel(true)
WorldMapFrame:ClearAllPoints()
WorldMapFrame:SetWidth(1024)
WorldMapFrame:SetHeight(768)
WorldMapFrame:SetPoint('CENTER', 0, 0)
WorldMapFrame:SetScript(
    'OnShow',
    function()
        -- 不能把WorldMapFrame的parent设置为UIParent，否则地图显示一片紊乱，这里随着UIParent缩放即可
        this:SetScale(UIParent:GetScale())
        UpdateMicroButtons()
        SetMapToCurrentZone()
        PlaySound('igQuestLogOpen')
        CloseDropDownMenus()
        WorldMapFrame_PingPlayerPosition()
    end
)
BlackoutWorld:SetAlpha(0)
-- 解决直接show()后esc无法关闭的问题，比如比如pfQuest任务界面的按钮打开
-- 响应esc按键的是ToggleGameMenu()函数
-- UIParent自己记录两个frame，UIParent.left和UIParent.center，left贴在左边，center居中或者贴left，CloseWindows()会关闭他们
table.insert(UISpecialFrames, 'WorldMapFrame')

-- UIOptionsFrame.xml
UIOptionsFrame:EnableKeyboard(false)
UIOptionsFrame:EnableMouse(false)
UIOptionsFrame:ClearAllPoints()
UIOptionsFrame:SetWidth(1024)
UIOptionsFrame:SetHeight(768)
UIOptionsFrame:SetPoint('CENTER', 0, 0)
UIOptionsFrame:SetScript(
    'OnShow',
    function()
        this:SetScale(UIParent:GetScale())
        UIOptionsFrame_Load()
        MultiActionBar_Update()
        MultiActionBar_ShowAllGrids()
        Disable_BagButtons()
        UpdateMicroButtons()
    end
)
UIOptionsBlackground:SetAlpha(0)
for k, v in {UIOptionsFrame:GetRegions()} do
    if v:GetObjectType() == 'Texture' then
        v:SetAlpha(0)
    end
end
UIOptionsFrame:SetBackdrop(
    {
        bgFile = 'Interface\\TutorialFrame\\TutorialFrameBackground',
        edgeFile = 'Interface\\TutorialFrame\\TUTORIALFRAMEBORDER',
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = {left = 8, right = 5, top = 4, bottom = 7}
    }
)
for k, v in {UIOptionsFrame:GetChildren()} do
    if v:GetWidth() == 32 and v:GetHeight() == 32 then
        -- 关闭按钮
        v:SetPoint('TOPRIGHT', 3, 4)
    end
end
UIOptionsFrameCancel:SetPoint('BOTTOMRIGHT', -6, 12)
UIOptionsFrameDefaults:SetPoint('BOTTOMLEFT', 12, 12)
-- 代码里面有设置为Interface\\OptionsFrame\\OptionsFrameTab-Active，是带颜色的
UIOptionsFrameTab1LeftDisabled:SetDesaturated(1)
UIOptionsFrameTab1MiddleDisabled:SetDesaturated(1)
UIOptionsFrameTab1RightDisabled:SetDesaturated(1)
UIOptionsFrameTab2LeftDisabled:SetDesaturated(1)
UIOptionsFrameTab2MiddleDisabled:SetDesaturated(1)
UIOptionsFrameTab2RightDisabled:SetDesaturated(1)

OptionsFrame:EnableMouse(false)
SoundOptionsFrame:EnableKeyboard(false)
SoundOptionsFrame:EnableMouse(false)
local _, _, _, _, _, _, _, _, _, _, _, nvidia_logo = OptionsFrame:GetRegions()
nvidia_logo:Hide()
OptionsFrameCancel:ClearAllPoints()
OptionsFrameCancel:SetPoint('BOTTOMRIGHT', -16, 16)
OptionsFrameDefaults:ClearAllPoints()
OptionsFrameDefaults:SetPoint('BOTTOMLEFT', 16, 16)

