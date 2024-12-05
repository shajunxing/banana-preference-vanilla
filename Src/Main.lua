function BananaPrint(...)
    local s = ""
    for i = 1, arg.n do
        s = s .. tostring(arg[i]) .. " "
    end
    DEFAULT_CHAT_FRAME:AddMessage(s)
end

local function subscribe(queue, topic, callback)
    assert(type(callback) == "function")
    local is_topic_added = false
    if not queue[topic] then
        queue[topic] = {count = 0}
        is_topic_added = true
    end
    if not queue[topic][callback] then
        queue[topic][callback] = true
        queue[topic].count = queue[topic].count + 1
    end
    return is_topic_added
end

local function unsubscribe(queue, topic, callback)
    assert(type(callback) == "function")
    local is_topic_removed = false
    if queue[topic] then
        if queue[topic][callback] then
            queue[topic][callback] = nil
            queue[topic].count = queue[topic].count - 1
        end
        if queue[topic].count < 1 then
            queue[topic] = nil
            is_topic_removed = true
        end
    end
    return is_topic_removed
end

local function publish(queue, topic, ...)
    if queue[topic] then
        for callback, _ in queue[topic] do
            if callback ~= "count" then
                assert(pcall(callback, unpack(arg)))
            end
        end
    end
end

local event_queue = {}
local frame = CreateFrame("Frame")
frame:SetScript(
    "OnEvent",
    function()
        -- https://wowpedia.fandom.com/wiki/Events?oldid=372741，最多9个参数
        publish(event_queue, event, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
    end
)

function BananaRegisterEvent(event, callback)
    if subscribe(event_queue, event, callback) then
        frame:RegisterEvent(event)
    end
end

function BananaRegisterEventOnce(event, callback)
    local run_once
    run_once = function(...)
        BananaUnregisterEvent(event, run_once)
        callback(unpack(arg))
    end
    BananaRegisterEvent(event, run_once)
end

function BananaUnregisterEvent(event, callback)
    if unsubscribe(event_queue, event, callback) then
        frame:UnregisterEvent(event)
    end
end

local tasks = {}

-- task是函数，返回值为下一次执行间隔时间，nil则停止执行
function BananaAddTask(callback, after)
    if not after then
        after = 0
    end
    tasks[callback] = after
end

frame:SetScript(
    "OnUpdate",
    function()
        for k, v in tasks do
            if v > 0 then
                tasks[k] = v - arg1
            else
                tasks[k] = k()
            end
        end
    end
)

function BananaAddSlashCommand(callback, ...)
    assert(arg.n > 0)
    assert(string.len(arg[1]) > 1)
    assert(string.sub(arg[1], 1, 1) == "/")
    local name = string.upper(string.sub(arg[1], 2))
    SlashCmdList[name] = callback
    for i = 1, arg.n do
        setglobal("SLASH_" .. name .. i, arg[i])
    end
end

BananaAddSlashCommand(ReloadUI, "/reload", "/rl")

-- 参见https://wowpedia.fandom.com/wiki/UIOBJECT_GameTooltip?oldid=213552
local tooltip = CreateFrame("GameTooltip", "BananaScanningTooltip", nil, "GameTooltipTemplate")
tooltip:SetOwner(tooltip, "ANCHOR_NONE")

function BananaDummy()
end

function BananaSetShown(region, show)
    if show then
        region:Show()
    else
        region:Hide()
    end
end

function BananaToggleShown(region)
    BananaSetShown(region, not region:IsShown())
end

local uiparent_toggle_callbacks = {}
local uiparent_toggle_bindings = {}

local function notify_uiparent_toggle()
    local shown = UIParent:IsShown()
    for callback, _ in uiparent_toggle_callbacks do
        callback(shown)
    end
    for region, _ in uiparent_toggle_bindings do
        BananaSetShown(region, shown)
    end
end

local uiparent_onshow = UIParent:GetScript("OnShow")
UIParent:SetScript(
    "OnShow",
    function()
        if uiparent_onshow then
            uiparent_onshow()
        end
        notify_uiparent_toggle()
    end
)

local uiparent_onhide = UIParent:GetScript("OnHide")
UIParent:SetScript(
    "OnHide",
    function()
        if uiparent_onhide then
            uiparent_onhide()
        end
        notify_uiparent_toggle()
    end
)

function BananaOnUIParentToggle(callback)
    uiparent_toggle_callbacks[callback] = true
end

function BananaBindUIParentToggle(region)
    uiparent_toggle_bindings[region] = true
end

local combat_state_callbacks = {}

local function notify_combat_state(combat)
    for callback, _ in combat_state_callbacks do
        callback(combat)
    end
end

BananaRegisterEvent(
    "PLAYER_REGEN_DISABLED",
    function()
        -- BananaPrint("PLAYER_REGEN_DISABLED")
        notify_combat_state(true)
    end
)
BananaRegisterEvent(
    "PLAYER_REGEN_ENABLED",
    function()
        -- BananaPrint("PLAYER_REGEN_ENABLED")
        notify_combat_state(false)
    end
)
BananaRegisterEvent(
    "PLAYER_ENTERING_WORLD",
    function()
        -- 战斗中炉石回去，战斗状态不会变，加这个看看
        -- BananaPrint("PLAYER_ENTERING_WORLD")
        notify_combat_state(UnitAffectingCombat("player"))
    end
)

function BananaOnCombatStateChanged(callback)
    combat_state_callbacks[callback] = true
    callback(UnitAffectingCombat("player"))
end

-- 注意itemString和itemLink在该版本里是不一样的
-- https://wowpedia.fandom.com/wiki/API_GetContainerItemLink?oldid=239468
-- https://wowpedia.fandom.com/wiki/API_GetItemInfo?direction=prev&oldid=355373
function BananaParseItemLink(item_link)
    if item_link then
        local _, _, item_string, item_id = string.find(item_link, '(item:(%d+):%d+:%d+:%d+)')
        item_id = tonumber(item_id)
        return item_id, item_string
    end
end

