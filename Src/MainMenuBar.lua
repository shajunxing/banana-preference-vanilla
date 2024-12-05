-- MainMenuBarMicroButtons.xml MainMenuBarMicroButtons.lua
-- 在LoadMicroButtonTextures()函数里已经RegisterEvent("UPDATE_BINDINGS")了
TalentMicroButton:UnregisterEvent('PLAYER_LEVEL_UP')
TalentMicroButton:UnregisterEvent('UNIT_LEVEL')
TalentMicroButton:UnregisterEvent('PLAYER_ENTERING_WORLD')
TalentMicroButton:SetScript(
    'OnEvent',
    function()
        this.tooltipText = MicroButtonTooltipText(TEXT(TALENTS_BUTTON), 'TOGGLETALENTS')
    end
)
TalentMicroButton_OnEvent = nil
UpdateTalentButton = nil
-- UIParent.lua:205
function ToggleTalentFrame()
    TalentFrame_LoadUI()
    if (TalentFrame_Toggle) then
        TalentFrame_Toggle()
    end
end
HelpMicroButton:SetParent(UIParent)
HelpMicroButton:ClearAllPoints()
HelpMicroButton:SetPoint('BOTTOMRIGHT', 0, 0)
HelpMicroButton:SetHitRectInsets(0, 0, 20, 0)
local prev_micro_button = HelpMicroButton
for _, micro_button in {MainMenuMicroButton, WorldMapMicroButton, SocialsMicroButton, QuestLogMicroButton, TalentMicroButton, SpellbookMicroButton, CharacterMicroButton} do
    micro_button:SetParent(HelpMicroButton)
    micro_button:ClearAllPoints()
    micro_button:SetPoint('BOTTOMRIGHT', prev_micro_button, 'BOTTOMLEFT', 3, 0)
    micro_button:SetHitRectInsets(0, 0, 20, 0)
    prev_micro_button = micro_button
end

-- MainMenuBarBagButtons.xml
local backpack_button_scale = 1
local micro_button_height = 58 - 20
MainMenuBarBackpackButton:SetParent(HelpMicroButton)
MainMenuBarBackpackButton:ClearAllPoints()
MainMenuBarBackpackButton:SetPoint('BOTTOMRIGHT', UIParent, 'BOTTOMRIGHT', 0, micro_button_height / backpack_button_scale)
MainMenuBarBackpackButton:SetScale(backpack_button_scale)
local prev_bag_button = MainMenuBarBackpackButton
for i, bag_button in {CharacterBag0Slot, CharacterBag1Slot, CharacterBag2Slot, CharacterBag3Slot, KeyRingButton} do
    bag_button:SetParent(HelpMicroButton)
    bag_button:ClearAllPoints()
    bag_button:SetPoint('BOTTOMRIGHT', prev_bag_button, 'BOTTOMLEFT', 0, 0)
    bag_button:SetScale(0.8)
    prev_bag_button = bag_button
end
MainMenuBarArtFrame:UnregisterAllEvents()
MainMenuBarArtFrame:SetScript('OnEvent', nil)
MainMenuBar_UpdateKeyRing = nil
SHOW_KEYRING = nil
KeyRingButton:SetPoint('BOTTOMRIGHT', CharacterBag3Slot, 'BOTTOMLEFT', 0, -1.55) -- 调整y坐标
KeyRingButton:Show()
MainMenuBarPerformanceBarFrame:SetParent(HelpMicroButton)
MainMenuBarPerformanceBarFrame:SetWidth(14)
MainMenuBarPerformanceBarFrame:SetHeight(14)
MainMenuBarPerformanceBarFrame:SetPoint('BOTTOMRIGHT', KeyRingButton, 'BOTTOMLEFT', 0, 0)
MainMenuBarPerformanceBarFrame:CreateTexture('MainMenuBarPerformanceBarBackground', 'BACKGROUND')
MainMenuBarPerformanceBarBackground:SetAllPoints()
MainMenuBarPerformanceBarBackground:SetTexture('Interface\\Buttons\\UI-CheckBox-Up')
MainMenuBarPerformanceBarBackground:SetTexCoord(4 / 32, 28 / 32, 5 / 32, 27 / 32)
MainMenuBarPerformanceBar:ClearAllPoints()
MainMenuBarPerformanceBar:SetAllPoints()
MainMenuBarPerformanceBar:SetDrawLayer('ARTWORK')
MainMenuBarPerformanceBar:SetTexture('Interface\\TargetingFrame\\UI-TargetingFrame-AttackBackground')
MainMenuBarPerformanceBar:SetTexCoord(1 / 32, 1, 1 / 32, 1)
MainMenuBarPerformanceBar:SetAlpha(0.8)

-- 供参考：正式服MainMenuBar底高45，按钮尺寸45，宠物/姿态按钮尺寸30
local action_button_size = 36
local action_button_margin = 6
local action_bar_length = action_button_size * 12 + action_button_margin * 11 -- 12个动作按钮的宽度
local pet_action_button_size = 30
local progress_bar_height = 8
local progress_bar_margin = 2
local main_menu_bar_bottom = action_button_size

-- MainMenuBar.xml
MainMenuBar:ClearAllPoints()
MainMenuBar:SetPoint('BOTTOM', 0, main_menu_bar_bottom)
MainMenuBar:SetWidth(action_bar_length)
MainMenuBar:SetHeight(action_button_size)
ActionButton1:ClearAllPoints()
ActionButton1:SetPoint('TOPLEFT', 0, 0) -- 只有单个'TOPLEFT'参数会弹出错误，1.12不完善？
MainMenuBarTexture0:Hide()
MainMenuBarTexture1:Hide()
MainMenuBarTexture2:Hide()
MainMenuBarTexture3:Hide()
MainMenuBarLeftEndCap:Hide()
MainMenuBarRightEndCap:Hide()
ActionBarUpButton:SetParent(UIParent)
ActionBarUpButton:ClearAllPoints()
ActionBarUpButton:SetPoint('CENTER', MainMenuBarArtFrame, 'RIGHT', 14, 8) -- 注意按钮实际尺寸是32x32比图标大
ActionBarDownButton:SetParent(UIParent)
ActionBarDownButton:ClearAllPoints()
ActionBarDownButton:SetPoint('CENTER', MainMenuBarArtFrame, 'RIGHT', 14, -10)
MainMenuBarPageNumber:SetParent(UIParent)
MainMenuBarPageNumber:ClearAllPoints()
MainMenuBarPageNumber:SetPoint('LEFT', MainMenuBarArtFrame, 'RIGHT', 28, 0)
-- 主动作条始终显示按钮轮廓，参见ActionButton.lua:241 ActionButton_ShowGrid()和ActionButton_HideGrid() button.showgrid值的增减逻辑，以及MultiActionBars.lua:107 辅动作条如何“始终显示”的
for i = 1, NUM_ACTIONBAR_BUTTONS do
    ActionButton_ShowGrid(getglobal('ActionButton' .. i))
end

-- UIParent.lua
-- 重写UIParent_ManageFramePositions，注意这个函数要放在上面，下面的比如Reputation代码调用到它
-- 该函数一般都是在部件OnShow/OnHide里面调用，做全局清理，该清的清，该加的加
UIPARENT_MANAGED_FRAME_POSITIONS = nil
local container_offset_base_y = main_menu_bar_bottom + action_button_size + action_button_margin -- 在下面修改版函数GameTooltip_SetDefaultAnchor()里面也用到
function UIParent_ManageFramePositions()
    local relative_to = MainMenuBar
    CONTAINER_OFFSET_Y = container_offset_base_y
    local function stack_action_bar(action_bar)
        action_bar:ClearAllPoints()
        if action_bar:IsShown() then
            action_bar:SetPoint('BOTTOMLEFT', relative_to, 'TOPLEFT', 0, action_button_margin)
            relative_to = action_bar
            CONTAINER_OFFSET_Y = CONTAINER_OFFSET_Y + action_bar:GetHeight() + action_button_margin
        end
    end
    stack_action_bar(MultiBarBottomLeft)
    stack_action_bar(MultiBarBottomRight)
    stack_action_bar(PetActionBarFrame)
    stack_action_bar(ShapeshiftBarFrame)
    relative_to = nil
    local function stack_progress_bar(progress_bar)
        progress_bar:ClearAllPoints() -- 注意必须加上，否则ReputationWatchBar可能会有多个point
        if progress_bar:IsShown() then
            if not relative_to then
                progress_bar:SetPoint('BOTTOM', UIParent, 0, progress_bar_margin)
            else
                progress_bar:SetPoint('BOTTOMLEFT', relative_to, 'TOPLEFT', 0, progress_bar_margin)
            end
            relative_to = progress_bar
        end
    end
    stack_progress_bar(MainMenuExpBar)
    stack_progress_bar(ReputationWatchBar)
    if MultiBarRight:IsShown() then
        if MultiBarLeft:IsShown() then
            CONTAINER_OFFSET_X = MultiBarRight:GetWidth() * MultiBarRight:GetScale() + (MultiBarLeft:GetWidth() + action_button_margin) * MultiBarLeft:GetScale() + action_button_margin
        else
            CONTAINER_OFFSET_X = MultiBarRight:GetWidth() * MultiBarRight:GetScale() + action_button_margin
        end
    else
        CONTAINER_OFFSET_X = 0
    end
    -- 其它部件，拷贝自原始代码
    --[[测试代码
    QuestTimerFrame:EnableMouse(false)
    QuestTimerFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\ChatBubble-Background", edgeFile = "Interface\\Tooltips\\ChatBubble-Backdrop", tile = true, tileSize = 24, edgeSize = 24, insets = { left = 24, right = 24, top = 24, bottom = 24 } } );
    QuestTimerHeader:SetTexture('Interface\\Icons\\INV_Misc_PocketWatch_01')
    QuestTimerHeader:SetWidth(32)
    QuestTimerHeader:SetHeight(32)
    QuestTimerHeader:ClearAllPoints()
    QuestTimerHeader:SetPoint('TOPLEFT', 11, 11)
    local _, quest_timer_title = QuestTimerFrame:GetRegions()
    quest_timer_title:Hide()
    QuestTimerFrame:SetScript('OnUpdate', nil)
    QuestTimer1Text:SetText('QuestTimer1')
    QuestTimer1:Show()
    QuestTimer2Text:SetText('QuestTimer2')
    QuestTimer2:Show()
    QuestTimerFrame:Show()
    DurabilityHead:Show()
    DurabilityShoulders:Show()
    DurabilityChest:Show()
    DurabilityWrists:Show()
    DurabilityHands:Show()
    DurabilityWaist:Show()
    DurabilityLegs:Show()
    DurabilityFeet:Show()
    DurabilityWeapon:Show()
    DurabilityShield:Show()
    DurabilityOffWeapon:Show()
    DurabilityRanged:Show()
    DurabilityFrame:Show()
    ]]
    local anchorY = 0
    if (NUM_EXTENDED_UI_FRAMES) then
        local captureBar
        local numCaptureBars = 0
        for i = 1, NUM_EXTENDED_UI_FRAMES do
            captureBar = getglobal('WorldStateCaptureBar' .. i)
            if (captureBar and captureBar:IsShown()) then
                captureBar:SetPoint('TOPRIGHT', MinimapCluster, 'BOTTOMRIGHT', -CONTAINER_OFFSET_X, anchorY)
                anchorY = anchorY - captureBar:GetHeight()
            end
        end
    end
    QuestTimerFrame:SetPoint('TOPRIGHT', 'MinimapCluster', 'BOTTOMRIGHT', -CONTAINER_OFFSET_X, anchorY)
    if (QuestTimerFrame:IsShown()) then
        anchorY = anchorY - QuestTimerFrame:GetHeight()
    end
    if (DurabilityFrame) then
        local durabilityOffset = 0
        if (DurabilityShield:IsShown() or DurabilityOffWeapon:IsShown() or DurabilityRanged:IsShown()) then
            durabilityOffset = 20
        end
        DurabilityFrame:SetPoint('TOPRIGHT', 'MinimapCluster', 'BOTTOMRIGHT', -CONTAINER_OFFSET_X - durabilityOffset, anchorY)
        if (DurabilityFrame:IsShown()) then
            anchorY = anchorY - DurabilityFrame:GetHeight()
        end
    end
    QuestWatchFrame:SetPoint('TOPRIGHT', 'MinimapCluster', 'BOTTOMRIGHT', -CONTAINER_OFFSET_X, anchorY)
    FCF_DockUpdate()
    updateContainerFrameAnchors()
end

-- MultiActionBars.xml
-- 在UIOptionsFrame.xml:666,700,717,738处已经调用了UIParent_ManageFramePositions()，这里就不再在OnShow/OnHide里面加了
MultiBarBottomLeft:SetParent(UIParent)
MultiBarBottomLeft:SetWidth(action_bar_length)
MultiBarBottomLeft:SetHeight(action_button_size)
MultiBarBottomLeft:ClearAllPoints()
MultiBarBottomRight:SetParent(UIParent)
MultiBarBottomRight:SetWidth(action_bar_length)
MultiBarBottomRight:SetHeight(action_button_size)
MultiBarBottomRight:ClearAllPoints()
MultiBarRight:SetParent(UIParent)
MultiBarRight:SetWidth(action_button_size)
MultiBarRight:SetHeight(action_bar_length)
MultiBarRight:ClearAllPoints()
MultiBarRight:SetPoint('RIGHT', UIParent, 'RIGHT', 0, -57)
MultiBarLeft:SetParent(UIParent)
MultiBarLeft:SetWidth(action_button_size)
MultiBarLeft:SetHeight(action_bar_length)
MultiBarLeft:ClearAllPoints()
MultiBarLeft:SetPoint('TOPRIGHT', MultiBarRight, 'TOPLEFT', -action_button_margin, 0)
MultiBarRight:SetScale(pet_action_button_size / action_button_size)
MultiBarLeft:SetScale(pet_action_button_size / action_button_size)

-- PetActionBarFrame.xml
PetActionBarFrame:SetParent(UIParent)
PetActionBarFrame:ClearAllPoints()
PetActionBarFrame:SetWidth(pet_action_button_size * 10 + action_button_margin * 9)
PetActionBarFrame:SetHeight(pet_action_button_size)
local prev_pet_action_button
for i = 1, 10 do
    local pet_action_button = getglobal('PetActionButton' .. i)
    pet_action_button:ClearAllPoints()
    if i == 1 then
        pet_action_button:SetPoint('TOPLEFT', 0, 0)
    else
        pet_action_button:SetPoint('LEFT', prev_pet_action_button, 'RIGHT', action_button_margin, 0)
    end
    prev_pet_action_button = pet_action_button
end
SlidingActionBarTexture0:Hide()
SlidingActionBarTexture1:Hide()
PetActionBarFrame:SetScript('OnUpdate', nil) -- 去掉动画
PetActionBarFrame_OnUpdate = nil
function ShowPetActionBar()
    PetActionBarFrame:Show()
end
function HidePetActionBar()
    PetActionBarFrame:Hide()
end

-- BonusActionBarFrame.xml
ShapeshiftBarFrame:SetParent(UIParent)
ShapeshiftBarFrame:ClearAllPoints()
ShapeshiftBarFrame:SetWidth(pet_action_button_size * 10 + action_button_margin * 9)
ShapeshiftBarFrame:SetHeight(pet_action_button_size)
local prev_shapeshift_button
for i = 1, 10 do
    local shapeshift_button = getglobal('ShapeshiftButton' .. i)
    shapeshift_button:ClearAllPoints()
    if i == 1 then
        shapeshift_button:SetPoint('TOPLEFT', 0, 0)
    else
        shapeshift_button:SetPoint('LEFT', prev_shapeshift_button, 'RIGHT', action_button_margin, 0)
    end
    prev_shapeshift_button = shapeshift_button
end
ShapeshiftBarLeft:Hide()
ShapeshiftBarMiddle:Hide()
ShapeshiftBarRight:Hide()
for i = 1, 10 do
    -- UIParent.lua UIParent_ManageFramePositions() 里面会随MultiBarBottomLeft的显隐改变大小
    local tex = getglobal('ShapeshiftButton' .. i .. 'NormalTexture')
    tex:SetWidth(50)
    tex:SetHeight(50)
    tex.SetWidth = BananaDummy
    tex.SetHeight = BananaDummy
end
BonusActionBarFrame:SetParent(UIParent)
BonusActionBarFrame:ClearAllPoints()
BonusActionBarFrame:SetPoint('TOPLEFT', MainMenuBar)
BonusActionBarFrame:SetWidth(action_bar_length)
BonusActionBarFrame:SetHeight(action_button_size)
BonusActionButton1:ClearAllPoints()
BonusActionButton1:SetPoint('TOPLEFT', 0, 0)
BonusActionBarTexture0:Hide()
BonusActionBarTexture1:Hide()
-- 始终显示网格，参见上面MainMenuBar代码
for i = 1, NUM_BONUS_ACTION_SLOTS do
    ActionButton_ShowGrid(getglobal('BonusActionButton' .. i))
end
BonusActionBarFrame:SetScript('OnUpdate', nil)
BonusActionBar_OnUpdate = nil
function ShowBonusActionBar()
    BonusActionBarFrame:Show()
    MainMenuBar:Hide()
end
function HideBonusActionBar()
    BonusActionBarFrame:Hide()
    MainMenuBar:Show()
end

-- MainMenuBar.xml里面的经验条
MainMenuExpBar:SetParent(UIParent)
MainMenuExpBar:ClearAllPoints()
MainMenuExpBar:SetWidth(action_bar_length)
MainMenuExpBar:SetHeight(progress_bar_height)
ExhaustionLevelFillBar:SetHeight(progress_bar_height)
MainMenuXPBarTexture0:Hide()
MainMenuXPBarTexture1:Hide()
MainMenuXPBarTexture2:Hide()
MainMenuXPBarTexture3:Hide()
-- 默认是鼠标放在MainMenuExpBar 1秒后，ExhaustionTick的tooltip附加到tooltip之后，而ExhaustionTick却没有tooltip，没必要的复杂，这里简化
MainMenuExpBar:SetScript(
    'OnEnter',
    function()
        TextStatusBar_UpdateTextString()
        ShowTextStatusBarText(this)
        GameTooltip_AddNewbieTip(XPBAR_LABEL, 1.0, 1.0, 1.0, NEWBIE_TOOLTIP_XPBAR, 1)
    end
)
MainMenuExpBar:SetScript('OnUpdate', nil)
MainMenuExpBar:SetScript('OnShow', UIParent_ManageFramePositions) -- 原本是在MainMenuBarMaxLevelBar的show/hide里面的
MainMenuExpBar:SetScript('OnHide', UIParent_ManageFramePositions)
ExhaustionTick:SetParent(MainMenuExpBar)
ExhaustionTick_OnUpdate = nil -- 这个名字取的他妈的和ExhaustionTick_Update混淆了吧，牛头不对马嘴
function ExhaustionToolTipText() -- ExhaustionTick的tooltip，代码非常混乱，不知道脑子里想啥
    local exhaustionStateID, exhaustionStateName, exhaustionStateMultiplier = GetRestState()
    local tooltipText = format(EXHAUST_TOOLTIP1, exhaustionStateName, exhaustionStateMultiplier * 100)
    local exhaustionThreshold = GetXPExhaustion()
    local exhaustionCountdown = GetTimeToWellRested()
    local append
    if IsResting() then
        if exhaustionThreshold and exhaustionCountdown then
            append = format(EXHAUST_TOOLTIP4, exhaustionCountdown / 60)
        end
    elseif (exhaustionStateID == 4) or (exhaustionStateID == 5) then
        append = EXHAUST_TOOLTIP2
    end
    if append then
        tooltipText = tooltipText .. append
    end
    GameTooltip_AddNewbieTip(EXHAUSTION_LABEL, 1, 1, 1, tooltipText)
end
function ExhaustionTick_Update() -- 删掉部分show/hide的逻辑
    if (event == 'PLAYER_ENTERING_WORLD') or (event == 'PLAYER_XP_UPDATE') or (event == 'UPDATE_EXHAUSTION') or (event == 'PLAYER_LEVEL_UP') then
        local playerCurrXP = UnitXP('player')
        local playerMaxXP = UnitXPMax('player')
        local exhaustionThreshold = GetXPExhaustion()
        local exhaustionStateID, exhaustionStateName, exhaustionStateMultiplier = GetRestState()
        if exhaustionStateID >= 3 then
            ExhaustionTick:SetPoint('CENTER', 'MainMenuExpBar', 'RIGHT', 0, 0)
        end
        if not exhaustionThreshold then
            ExhaustionTick:Hide()
            ExhaustionLevelFillBar:Hide()
        else
            local exhaustionTickSet = max(((playerCurrXP + exhaustionThreshold) / playerMaxXP) * MainMenuExpBar:GetWidth(), 0)
            ExhaustionTick:ClearAllPoints()
            if exhaustionTickSet > MainMenuExpBar:GetWidth() then
                ExhaustionTick:Hide()
                ExhaustionLevelFillBar:Hide()
            else
                ExhaustionTick:Show()
                ExhaustionTick:SetPoint('CENTER', 'MainMenuExpBar', 'LEFT', exhaustionTickSet, 0)
                ExhaustionLevelFillBar:Show()
                ExhaustionLevelFillBar:SetPoint('TOPRIGHT', 'MainMenuExpBar', 'TOPLEFT', exhaustionTickSet, 0)
            end
        end
    end
    if (event == 'PLAYER_ENTERING_WORLD') or (event == 'UPDATE_EXHAUSTION') then
        local exhaustionStateID = GetRestState()
        if exhaustionStateID == 1 then
            MainMenuExpBar:SetStatusBarColor(0.0, 0.39, 0.88, 1.0)
            ExhaustionLevelFillBar:SetVertexColor(0.0, 0.39, 0.88, 0.15)
            ExhaustionTickHighlight:SetVertexColor(0.0, 0.39, 0.88)
        elseif exhaustionStateID == 2 then
            MainMenuExpBar:SetStatusBarColor(0.58, 0.0, 0.55, 1.0)
            ExhaustionLevelFillBar:SetVertexColor(0.58, 0.0, 0.55, 0.15)
            ExhaustionTickHighlight:SetVertexColor(0.58, 0.0, 0.55)
        end
    end
end

-- ReputationFrame.xml
ReputationWatchBar:SetParent(UIParent)
ReputationWatchBar:ClearAllPoints()
ReputationWatchBar:SetWidth(action_bar_length)
ReputationWatchBar:SetHeight(progress_bar_height)
ReputationWatchStatusBar:ClearAllPoints()
ReputationWatchStatusBar:SetAllPoints()
ReputationWatchBarTexture0:Hide()
ReputationWatchBarTexture1:Hide()
ReputationWatchBarTexture2:Hide()
ReputationWatchBarTexture3:Hide()
ReputationXPBarTexture0:Hide()
ReputationXPBarTexture1:Hide()
ReputationXPBarTexture2:Hide()
ReputationXPBarTexture3:Hide()
-- MainMenuExpBar满级的隐藏放在了ReputationFrame.xml:999 ReputationFrame.lua:226,240，有够乱的
function ReputationWatchBar_Update(newLevel) -- 删掉与MainMeuBar和MainMenuExpBar状态关联的的代码
    local name, reaction, min, max, value = GetWatchedFactionInfo()
    if not newLevel then
        newLevel = UnitLevel('player')
    end
    if name then
        -- Normalize values
        max = max - min
        value = value - min
        min = 0
        ReputationWatchStatusBar:SetMinMaxValues(min, max)
        ReputationWatchStatusBar:SetValue(value)
        SetTextStatusBarTextPrefix(ReputationWatchStatusBar, name) -- 参考MainMenuExpBar，使用TextStatusBar.lua的标准函数
        TextStatusBar_UpdateTextString(ReputationWatchStatusBar) -- TextStatusBar_OnValueChanged()会自动调用TextStatusBar_UpdateTextString()，但SetTextStatusBarTextPrefix不会()，这里如果切换监视声望就需要更新
        local color = FACTION_BAR_COLORS[reaction]
        ReputationWatchStatusBar:SetStatusBarColor(color.r, color.g, color.b)
        ReputationWatchBar:Show()
    else
        ReputationWatchBar:Hide()
    end
    if newLevel < MAX_PLAYER_LEVEL then
        MainMenuExpBar:Show()
    else
        MainMenuExpBar:Hide()
    end
end
-- 鼠标放上/离开的文本显隐逻辑，参考MainMenuExpBar的写法，注意，MainMenuExpBar的部分初始化代码在MainMenuBarOverlayFrame的OnLoad里面，简直就是一坨屎
ReputationWatchBar:SetScript('OnLoad', nil)
ReputationWatchBar:UnregisterAllEvents()
ReputationWatchBar:SetScript('OnEvent', nil)
ReputationWatchBar:SetScript('OnShow', nil)
ReputationWatchBar:SetScript('OnHide', nil)
ReputationWatchBar:SetScript('OnEnter', nil)
ReputationWatchBar:SetScript('OnLeave', nil)
ReputationWatchBar:EnableMouse(false)
ReputationWatchStatusBar:EnableMouse(true)
ReputationWatchStatusBar:RegisterEvent('UPDATE_FACTION')
ReputationWatchStatusBar:RegisterEvent('PLAYER_LEVEL_UP')
SetTextStatusBarText(ReputationWatchStatusBar, ReputationWatchStatusBarText)
ReputationWatchStatusBar:RegisterEvent('CVAR_UPDATE')
ReputationWatchStatusBar.lockShow = 0
ReputationWatchStatusBar.textLockable = 1
ReputationWatchStatusBar:SetScript(
    'OnEvent',
    function()
        if event == 'UPDATE_FACTION' and this:IsVisible() then
            ReputationFrame_Update()
            ReputationWatchBar_Update()
        elseif event == 'PLAYER_LEVEL_UP' then
            ReputationWatchBar_Update(arg1)
        elseif event == 'CVAR_UPDATE' then -- 原代码"statusBarText"也写错了，应该是"STATUS_BAR_TEXT"
            TextStatusBar_OnEvent(arg1, arg2)
        else
            ReputationWatchBar_Update()
        end
    end
)
ReputationWatchStatusBar:SetScript('OnShow', UIParent_ManageFramePositions)
ReputationWatchStatusBar:SetScript('OnHide', UIParent_ManageFramePositions)
-- local faction_description
ReputationWatchStatusBar:SetScript(
    'OnEnter',
    function()
        TextStatusBar_UpdateTextString()
        ShowTextStatusBarText(this)
        -- 查找并显示声望信息
        -- if not faction_description then
        --     faction_description = {}
        --     for index = 1, GetNumFactions() do
        --         local name, description = GetFactionInfo(index)
        --         faction_description[name] = description
        --     end
        -- end
        -- local name = GetWatchedFactionInfo()
        -- local description = faction_description[name]
        -- GameTooltip_AddNewbieTip(name, 1.0, 1.0, 1.0, description, 1)
        GameTooltip_AddNewbieTip(REPUTATION, 1.0, 1.0, 1.0, REPUTATION_STANDING_DESCRIPTION, 1)
    end
)
ReputationWatchStatusBar:SetScript(
    'OnLeave',
    function()
        HideTextStatusBarText(this)
    end
)
ReputationWatchStatusBar:SetScript(
    'OnValueChanged',
    function()
        TextStatusBar_OnValueChanged()
    end
)
ShowWatchedReputationBarText = nil
HideWatchedReputationBarText = nil
-- 删掉ShowWatchedReputationBarText HideWatchedReputationBarText的几处调用
function CharacterFrame_OnShow()
    PlaySound('igCharacterInfoOpen')
    SetPortraitTexture(CharacterFramePortrait, 'player')
    CharacterNameText:SetText(UnitPVPName('player'))
    UpdateMicroButtons()
    ShowTextStatusBarText(PlayerFrameHealthBar)
    ShowTextStatusBarText(PlayerFrameManaBar)
    ShowTextStatusBarText(MainMenuExpBar)
    ShowTextStatusBarText(PetFrameHealthBar)
    ShowTextStatusBarText(PetFrameManaBar)
    -- 已删掉
    ShowTextStatusBarText(ReputationWatchStatusBar)
end
function CharacterFrame_OnHide()
    PlaySound('igCharacterInfoClose')
    UpdateMicroButtons()
    HideTextStatusBarText(PlayerFrameHealthBar)
    HideTextStatusBarText(PlayerFrameManaBar)
    HideTextStatusBarText(MainMenuExpBar)
    HideTextStatusBarText(PetFrameHealthBar)
    HideTextStatusBarText(PetFrameManaBar)
    -- 已删掉
    HideTextStatusBarText(ReputationWatchStatusBar)
end

-- 默认LOW却总是挡在前面，估计是bug，改成和MainMenuBar一样的就没问题了
-- MainMenuBar.xml
ExhaustionTick:SetParent(MainMenuExpBar)
ExhaustionTick:SetFrameStrata('MEDIUM')
MainMenuBarOverlayFrame:SetFrameStrata('MEDIUM') -- 经验文本
-- PetActionBarFrame.xml
PetActionBarFrame:SetFrameStrata('MEDIUM')
-- MultiActionBars.xml
MultiBarBottomLeft:SetFrameStrata('MEDIUM')
MultiBarBottomRight:SetFrameStrata('MEDIUM')
MultiBarRight:SetFrameStrata('MEDIUM')
MultiBarLeft:SetFrameStrata('MEDIUM')
-- BonusActionBarFramexml
BonusActionBarFrame:SetFrameStrata('MEDIUM')
-- ReputationFrame.xml
ReputationWatchBarOverlayFrame:SetFrameStrata('MEDIUM') -- 声望文本

-- FloatingChatFrame.xml
ChatFrameEditBox:SetAltArrowKeyMode(false)
-- ChatFrame1:SetPoint('BOTTOMLEFT', 32, 32)
-- ChatFrame1:SetWidth(380)

local framerate_bottom = main_menu_bar_bottom + action_button_size * 3 + pet_action_button_size + action_button_margin * 4
FramerateLabel:SetParent(UIParent)
FramerateLabel:ClearAllPoints()
FramerateLabel:SetPoint('BOTTOMRIGHT', UIParent, 'BOTTOM', 0, framerate_bottom)
FramerateText:SetParent(UIParent)
FramerateLabel:SetFontObject('GameFontNormal')
FramerateText:SetFontObject('GameFontNormal')
ScreenshotStatusText:SetFontObject('WorldMapTextFont')
TutorialFrameParent:ClearAllPoints()
TutorialFrameParent:SetPoint('BOTTOM', 0, framerate_bottom)
CastingBarFrame:ClearAllPoints()
CastingBarFrame:SetPoint('BOTTOM', 0, framerate_bottom + FramerateLabel:GetHeight() + action_button_margin)

-- GameTooltip.lua 高度随CONTAINER_OFFSET_Y变高太丑，这里修正
function GameTooltip_SetDefaultAnchor(tooltip, parent)
    tooltip:SetOwner(parent, 'ANCHOR_NONE')
    tooltip:SetPoint('BOTTOMRIGHT', 'UIParent', 'BOTTOMRIGHT', -CONTAINER_OFFSET_X, container_offset_base_y)
    tooltip.default = 1
end
