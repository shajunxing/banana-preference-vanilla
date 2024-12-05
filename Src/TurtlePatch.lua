--乌龟客户端补丁
if LFT then
    function ChatFrame_RegisterForMessages(...)
        local messageGroup
        local index = 1
        for i = 1, arg.n do
            messageGroup = ChatTypeGroup[arg[i]]
            if (messageGroup) then
                this.messageTypeList[index] = arg[i]
                for index, value in messageGroup do
                    this:RegisterEvent(value)
                end
                index = index + 1
            end
        end
    end

    ChatFrame1:UnregisterEvent("CHAT_MSG_HARDCORE")
    ChatFrame2:UnregisterEvent("CHAT_MSG_HARDCORE")
    ChatFrame_RemoveMessageGroup(ChatFrame1, "CHANNEL")

    TargetHPPercText:Hide()
    TargetHPPercText.Show = BananaDummy
    TargetHPText:Hide()
    TargetHPText.Show = BananaDummy

    UIPanelWindows["QuestLogFrame"] = {area = "left", pushable = 99, whileDead = 1}

    EBC_Minimap:Hide()
    local buttons = {LFTMinimapButton, TWMiniMapBattlefieldFrame, MinimapShopFrame}
    for index, button in buttons do
        button:SetMovable(false)
        button:ClearAllPoints()
        button:SetParent(UIParent)
        button:SetScript("OnEnter", BananaDummy)
        if index == 1 then
            button:SetPoint("BOTTOMLEFT", 0, 0)
        else
            button:SetPoint("LEFT", buttons[index - 1], "RIGHT", 0, 0)
        end
    end
end
