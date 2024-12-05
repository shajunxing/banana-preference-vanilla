-- UIParent.lua
-- PATCH
UIPanelWindows["LootFrame"] = nil
-- END OF PATCH

-- LootFrame.lua
function LootFrame_OnEvent(event)
    if (event == "LOOT_OPENED") then
        this.page = 1
        -- PATCH: 这里不用ShowUIPanel，也不要patchLootFrame_OnShow，因为ShowUIPanel里面在Show之后还会有动作
        this:ClearAllPoints()
        local x, y = GetCursorPosition()
        local s = UIParent:GetScale()
        x = x / s - 24 - 16
        y = y / s - (256 - 80 - 16)
        this:SetClampedToScreen(true)
        this:SetPoint("BOTTOMLEFT", x, y)
        this:Show()
        -- END OF PATCH
        if (not this:IsVisible()) then
            CloseLoot(1) -- The parameter tells code that we were unable to open the UI
        end
        return
    end
    if (event == "LOOT_SLOT_CLEARED") then
        if (not this:IsVisible()) then
            return
        end

        local numLootToShow = LOOTFRAME_NUMBUTTONS
        if (this.numLootItems > LOOTFRAME_NUMBUTTONS) then
            numLootToShow = numLootToShow - 1
        end
        local slot = arg1 - ((this.page - 1) * numLootToShow)
        if ((slot > 0) and (slot < (numLootToShow + 1))) then
            local button = getglobal("LootButton" .. slot)
            if (button) then
                button:Hide()
            end
        end
        -- try to move second page of loot items to the first page
        local button
        local allButtonsHidden = 1

        for index = 1, LOOTFRAME_NUMBUTTONS do
            button = getglobal("LootButton" .. index)
            if (button:IsVisible()) then
                allButtonsHidden = nil
            end
        end
        if (allButtonsHidden and LootFrameDownButton:IsVisible()) then
            LootFrame_PageDown()
        end
        return
    end
    if (event == "LOOT_CLOSED") then
        StaticPopup_Hide("LOOT_BIND")
        HideUIPanel(this)
        return
    end
    if (event == "OPEN_MASTER_LOOT_LIST") then
        ToggleDropDownMenu(1, nil, GroupLootDropDown, LootFrame.selectedLootButton, 0, 0)
        return
    end
    if (event == "UPDATE_MASTER_LOOT_LIST") then
        UIDropDownMenu_Refresh(GroupLootDropDown)
    end
end

local right_extend = 102
LootButton1:SetHitRectInsets(0, -right_extend, 0, 0)
LootButton2:SetHitRectInsets(0, -right_extend, 0, 0)
LootButton3:SetHitRectInsets(0, -right_extend, 0, 0)
LootButton4:SetHitRectInsets(0, -right_extend, 0, 0)

