function MerchantFrame_OnShow()
    OpenBackpack()
    -- Update repair all button status
    if (MerchantRepairAllIcon) then
        local repairAllCost, canRepair = GetRepairAllCost()
        if (canRepair) then
            SetDesaturation(MerchantRepairAllIcon, nil)
            MerchantRepairAllButton:Enable()
        else
            SetDesaturation(MerchantRepairAllIcon, 1)
            MerchantRepairAllButton:Disable()
        end
    end
    PanelTemplates_SetTab(MerchantFrame, 1)
    MerchantFrame_Update()
    -- PATCH 自动修理，自动售卖垃圾
    if MerchantRepairAllButton:IsEnabled() then
        MerchantRepairAllButton:Click()
    end
    -- END OF PATCH
end

local sell_trash_button = CreateFrame('Button', nil, MerchantFrame, 'UIPanelButtonTemplate')
sell_trash_button:SetWidth(85)
sell_trash_button:SetHeight(22)
sell_trash_button:SetText(GetLocale() == 'zhCN' and '卖垃圾' or 'Sell Trash')
sell_trash_button:SetPoint('TOPRIGHT', -43, -43)
sell_trash_button:SetScript(
    'OnClick',
    function()
        -- 一次全卖会掉线，这里使用延时任务
        local bag_id, slot_index, num_slots = 0, 1, GetContainerNumSlots(0)
        local function task()
            if not MerchantFrame:IsShown() then
                BananaPrint('Cancelled')
                return nil
            end
            -- BananaPrint(bag_id, slot_index, num_slots)
            local delay = 0
            if slot_index <= num_slots then
                local item_link = GetContainerItemLink(bag_id, slot_index)
                local item_id = BananaParseItemLink(item_link)
                if item_id then
                    local _, _, qty = GetItemInfo(item_id)
                    if qty == 0 then
                        BananaPrint('Sell', bag_id, slot_index, item_link)
                        UseContainerItem(bag_id, slot_index)
                        delay = 0.3
                    end
                end
                slot_index = slot_index + 1
            else
                bag_id = bag_id + 1
                if bag_id > 4 then
                    delay = nil
                    BananaPrint('Done')
                else
                    slot_index = 1
                    num_slots = GetContainerNumSlots(bag_id)
                end
            end
            -- BananaPrint(delay)
            return delay
        end
        BananaAddTask(task)
    end
)

local function sell_all()
    if not MerchantFrame:IsShown() then
        return
    end
    local bag = this:GetParent()
    local bag_id = bag:GetID()
    local slot_index = GetContainerNumSlots(bag_id)
    local function task()
        if not (MerchantFrame:IsShown() and bag:IsShown()) then
            BananaPrint('Cancelled')
            return nil
        end
        if slot_index < 1 then
            BananaPrint('Done')
            return nil
        end
        local delay
        local item_link = GetContainerItemLink(bag_id, slot_index)
        if item_link then
            BananaPrint('Sell', bag_id, slot_index, item_link)
            UseContainerItem(bag_id, slot_index)
            delay = 0.3
        else
            delay = 0
        end
        slot_index = slot_index - 1
        return delay
    end
    BananaAddTask(task)
end
for i = 1, 12 do
    getglobal('ContainerFrame' .. i .. 'PortraitButton'):Hide() -- 会遮挡我的按钮
    local container = getglobal('ContainerFrame' .. i)
    local sell_all_button = CreateFrame('Button', nil, container, 'UIPanelButtonTemplate')
    sell_all_button:SetText(GetLocale() == 'zhCN' and '全部出售' or 'Sell All')
    sell_all_button:SetPoint('TOPLEFT', 14, -26)
    sell_all_button:SetWidth(85)
    sell_all_button:SetHeight(22)
    sell_all_button:SetScript('OnClick', sell_all)
end

-- 增强物品显示
local overlayed_item_buttons = {}
local function item_button_prepare(button, more)
    if not overlayed_item_buttons[button] then
        local overlay = CreateFrame('Frame', nil, button)
        overlay:SetAllPoints()
        overlay:Show()
        local ilvlbg = overlay:CreateTexture(nil, 'BACKGROUND')
        ilvlbg:SetTexture(0, 0, 0)
        ilvlbg:SetPoint('TOPRIGHT', -2, -2)
        ilvlbg:Hide()
        local ilvl = overlay:CreateFontString(nil, 'OVERLAY', 'NumberFontNormal')
        ilvl:SetPoint('TOPRIGHT', -2, -2)
        ilvl:SetJustifyH('RIGHT')
        ilvl:Hide()
        overlayed_item_buttons[button] = {
            overlay = overlay,
            ilvlbg = ilvlbg,
            ilvl = ilvl
        }
        if more then
            more(overlayed_item_buttons[button])
        end
    end
    return overlayed_item_buttons[button]
end
local function item_button_hide_all(button)
    if overlayed_item_buttons[button] then
        overlayed_item_buttons[button].ilvlbg:Hide()
        overlayed_item_buttons[button].ilvl:Hide()
    end
end
local function item_button_show_ilvl(button, item_id) -- item_id可以是id或者item string
    local item_name, item_string, item_quality, item_min_level, item_type, item_sub_type, item_stack_count, item_equip_loc, item_texture = GetItemInfo(item_id)
    if item_equip_loc == '' or item_equip_loc == 'INVTYPE_BAG' or not item_min_level or not item_quality then
        -- BananaPrint(item_name, item_string, item_quality, item_min_level, item_equip_loc)
        return
    end
    local r, g, b
    if item_quality == 2 then -- 绿色，变暗
        r, g, b = 0, 0.9, 0
    elseif item_quality == 3 then -- 蓝色，加亮
        r, g, b = 0.1, 0.5, 1
    elseif item_quality == 4 then -- 紫色，加亮
        r, g, b = 0.9, 0.3, 1
    else
        r, g, b = GetItemQualityColor(item_quality)
    end
    local entry = item_button_prepare(button)
    entry.ilvl:SetText(item_min_level)
    if r then
        entry.ilvl:SetTextColor(r, g, b)
    end
    entry.ilvl:Show()
    local w, h = entry.ilvl:GetWidth(), entry.ilvl:GetHeight()
    entry.ilvlbg:SetWidth(w)
    entry.ilvlbg:SetHeight(h)
    entry.ilvlbg:Show()
end
-- 角色面板
do
    local function update(button)
        item_button_hide_all(button)
        local slot_id = button:GetID()
        local item_id = BananaParseItemLink(GetInventoryItemLink('player', slot_id))
        if item_id then
            item_button_show_ilvl(button, item_id)
        end
    end
    local old_PaperDollItemSlotButton_Update = PaperDollItemSlotButton_Update
    PaperDollItemSlotButton_Update = function(cooldownOnly)
        old_PaperDollItemSlotButton_Update(cooldownOnly)
        update(this)
    end
    -- FrameXML\PaperDollFrame.xml
    if PaperDollFrame:IsShown() then
        update(CharacterHeadSlot)
        update(CharacterNeckSlot)
        update(CharacterShoulderSlot)
        update(CharacterBackSlot)
        update(CharacterChestSlot)
        update(CharacterShirtSlot)
        update(CharacterTabardSlot)
        update(CharacterWristSlot)
        update(CharacterHandsSlot)
        update(CharacterWaistSlot)
        update(CharacterLegsSlot)
        update(CharacterFeetSlot)
        update(CharacterFinger0Slot)
        update(CharacterFinger1Slot)
        update(CharacterTrinket0Slot)
        update(CharacterTrinket1Slot)
        update(CharacterMainHandSlot)
        update(CharacterSecondaryHandSlot)
        update(CharacterRangedSlot)
        update(CharacterAmmoSlot)
    end
end
-- 目标角色面板
do
    local function update(button)
        item_button_hide_all(button)
        local slot_id = button:GetID()
        if InspectFrame.unit then
            local item_id = BananaParseItemLink(GetInventoryItemLink(InspectFrame.unit, slot_id))
            if item_id then
                item_button_show_ilvl(button, item_id)
            end
        end
    end
    local old_InspectPaperDollItemSlotButton_Update = InspectPaperDollItemSlotButton_Update
    InspectPaperDollItemSlotButton_Update = function(button)
        old_InspectPaperDollItemSlotButton_Update(button)
        update(button)
    end
    if InspectPaperDollFrame and InspectPaperDollFrame:IsShown() then -- InspectPaperDollFrame可能为nil，原因未知
        update(InspectHeadSlot)
        update(InspectNeckSlot)
        update(InspectShoulderSlot)
        update(InspectBackSlot)
        update(InspectChestSlot)
        update(InspectShirtSlot)
        update(InspectTabardSlot)
        update(InspectWristSlot)
        update(InspectHandsSlot)
        update(InspectWaistSlot)
        update(InspectLegsSlot)
        update(InspectFeetSlot)
        update(InspectFinger0Slot)
        update(InspectFinger1Slot)
        update(InspectTrinket0Slot)
        update(InspectTrinket1Slot)
        update(InspectMainHandSlot)
        update(InspectSecondaryHandSlot)
        update(InspectRangedSlot)
    end
end
-- 背包
do
    local function update(bag)
        local bag_id = bag:GetID()
        local bag_name = bag:GetName()
        for i = 1, bag.size do
            local button = getglobal(bag_name .. 'Item' .. i)
            item_button_hide_all(button)
            local slot_id = button:GetID()
            local item_id = BananaParseItemLink(GetContainerItemLink(bag_id, slot_id))
            if item_id then
                item_button_show_ilvl(button, item_id)
            end
        end
    end
    local old_ContainerFrame_Update = ContainerFrame_Update
    ContainerFrame_Update = function(bag)
        old_ContainerFrame_Update(bag)
        update(bag)
    end
    local old_ContainerFrame_OnShow = ContainerFrame_OnShow
    ContainerFrame_OnShow = function()
        old_ContainerFrame_OnShow()
        update(this)
    end
    -- FrameXML\ContainerFrame.xml
    for i = 1, NUM_CONTAINER_FRAMES do
        local bag_name = 'ContainerFrame' .. i
        local bag = getglobal(bag_name)
        bag:SetScript('OnShow', ContainerFrame_OnShow)
    end
end
-- 银行界面，非银行背包
do
    local function update(button)
        item_button_hide_all(button)
        if button.isBag then
            return
        end
        local item_id = BananaParseItemLink(GetContainerItemLink(BANK_CONTAINER, button:GetID()))
        if item_id then
            item_button_show_ilvl(button, item_id)
        end
    end
    local old_BankFrameItemButton_OnUpdate = BankFrameItemButton_OnUpdate
    BankFrameItemButton_OnUpdate = function()
        old_BankFrameItemButton_OnUpdate()
        update(this)
    end
    -- FrameXML\BankFrame.xml
    if BankFrame:IsShown() then
        for i = 1, 24 do
            local button = _G['BankFrameItem' .. i]
            update(button)
        end
    end
end
-- 商人
do
    local function update()
        local offset = (MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE
        for i = 1, 12 do
            local item = getglobal('MerchantItem' .. i)
            local button = getglobal('MerchantItem' .. i .. 'ItemButton')
            item_button_hide_all(button)
            if item:IsShown() and button:IsShown() then
                if MerchantFrame.selectedTab == 1 then
                    -- 补上物品ID
                    button.link = GetMerchantItemLink(offset + i)
                else
                    -- 1.12没有GetBuybackItemLink函数
                    button.link = nil
                end
                if button.link then
                    local item_id = BananaParseItemLink(button.link)
                    item_button_show_ilvl(button, item_id)
                end
            end
        end
    end
    local old_MerchantFrame_Update = MerchantFrame_Update
    MerchantFrame_Update = function()
        old_MerchantFrame_Update()
        update()
    end
    if MerchantFrame:IsShown() then
        update()
    end
end
