local result = {}
local inspect

local function inspect_property(blank, obj)
    if obj.GetTexture then
        table.insert(result, blank .. '    GetTexture()= ' .. tostring(obj:GetTexture()))
    end
    if obj.GetText then
        table.insert(result, blank .. '    GetText()= ' .. tostring(obj:GetText()))
    end
    if obj.GetFont then
        local fname, fheight, fflags = obj:GetFont()
        if fname then
            table.insert(result, blank .. '    GetFont()= ' .. fname .. ' ' .. fheight .. ' ' .. fflags)
        end
    end
    if obj.GetNumPoints then
        for i = 1, obj:GetNumPoints() do
            local p, r, rp, x, y = obj:GetPoint(i)
            table.insert(result, blank .. '    GetPoint(' .. i .. ')= ' .. p .. ' ' .. tostring(r) .. ' ' .. rp .. ' ' .. x .. ' ' .. y)
        end
    end
    if obj.GetWidth then
        table.insert(result, blank .. '    GetWidth()= ' .. tostring(obj:GetWidth()))
    end
    if obj.GetHeight then
        table.insert(result, blank .. '    GetHeight()= ' .. tostring(obj:GetHeight()))
    end
    if obj.GetDrawLayer then
        table.insert(result, blank .. '    GetDrawLayer()= ' .. tostring(obj:GetDrawLayer()))
    end
    if obj.GetFrameStrata then
        table.insert(result, blank .. '    GetFrameStrata()= ' .. tostring(obj:GetFrameStrata()))
    end
    if obj.GetFrameLevel then
        table.insert(result, blank .. '    GetFrameLevel()= ' .. tostring(obj:GetFrameLevel()))
    end
    if obj.GetScript then
        table.insert(result, blank .. '    OnLoad= ' .. tostring(obj:GetScript('OnLoad')))
        table.insert(result, blank .. '    OnShow= ' .. tostring(obj:GetScript('OnShow')))
        table.insert(result, blank .. '    OnUpdate= ' .. tostring(obj:GetScript('OnUpdate')))
    end
end

local function inspect_regions(level, ...)
    local blank = string.rep(' ', level * 4)
    for i = 1, arg.n do
        local region = arg[i]
        local type = region:GetObjectType()
        local line = blank .. '<' .. tostring(type) .. '> ' .. tostring(region:GetName()) .. ' ' .. tostring(region)
        table.insert(result, line)
        inspect_property(blank, region)
    end
end

local function inspect_children(level, ...)
    for i = 1, arg.n do
        inspect(level, arg[i])
    end
end

inspect = function(level, widget)
    local blank = string.rep(' ', level * 4)
    table.insert(result, blank .. '<' .. tostring(widget:GetObjectType()) .. '> ' .. tostring(widget:GetName()) .. ' ' .. tostring(widget))
    inspect_property(blank, widget)
    if widget.GetRegions then
        inspect_regions(level + 1, widget:GetRegions())
    end
    if widget.GetChildren then
        inspect_children(level + 1, widget:GetChildren())
    end
end

function BananaInspect(name)
    local frame = getglobal(name)
    if frame then
        inspect(0, frame)
        BananaOutputFrameEditorScrollFrameEditBox:SetText(table.concat(result, '|n'))
    else
        BananaOutputFrameEditorScrollFrameEditBox:SetText('"' .. name .. '" Not Found')
    end
    BananaOutputFrame:Show()
    result = {}
end

BananaAddSlashCommand(BananaInspect, '/tinspect')

-- 删掉场景动画，比如人物创建第一次进入的介绍动画
-- CinematicFrame.xml CinematicFrame.lua
-- 注意场景动画是在WorldFrame上播放的，而CinematicFrame只是接收按键用
-- CinematicFrame:SetScript('OnShow', nil)
-- CinematicFrame:SetScript('OnEvent', StopCinematic)
-- CinematicFrame:SetScript('OnKeyDown', nil)
-- CinematicFrame_OnLoad = nil
-- CinematicFrame_OnEvent = nil
-- StopCinematic()
-- 貌似依旧无法取消

-- 可阅读物品字体颜色太浅问题，没用
-- ItemTextPageText:SetTextColor(0, 0, 0)
-- ItemTextPageText.SetTextColor = function()
-- end

-- 美化任务计时面板
QuestTimerFrame:EnableMouse(false)
QuestTimerFrame:SetBackdrop({bgFile = 'Interface\\Tooltips\\ChatBubble-Background', edgeFile = 'Interface\\Tooltips\\ChatBubble-Backdrop', tile = true, tileSize = 24, edgeSize = 24, insets = {left = 24, right = 24, top = 24, bottom = 24}})
QuestTimerHeader:SetTexture('Interface\\Icons\\INV_Misc_PocketWatch_01')
QuestTimerHeader:SetWidth(32)
QuestTimerHeader:SetHeight(32)
QuestTimerHeader:ClearAllPoints()
QuestTimerHeader:SetPoint('TOPLEFT', 11, 11)
local _, quest_timer_title = QuestTimerFrame:GetRegions()
quest_timer_title:Hide()


