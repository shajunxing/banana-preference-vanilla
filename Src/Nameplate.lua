-- TODO：是否可以把SetPoint等函数改为Dummy防止系统变更？
local name_font_size, name_y_offset = 14, 4
local border_width, bar_width, bar_height, bar_y_offset = 2, 128, 8, -22 -- 猎人印记需要一些下偏移
local glow_width = 2
local level_font_size, level_x_offset = 14, 22
local left_inset = -(bar_width / 2 + border_width)
local right_inset = left_inset
local top_inset = -(border_width + name_y_offset + name_font_size + bar_y_offset)
local bottom_inset = -(bar_height + border_width - bar_y_offset)

local function nameplate_on_load(frame, info)
    -- BananaPrint("nameplate_on_load", frame)
    frame:SetHitRectInsets(left_inset, right_inset, top_inset, bottom_inset) -- 重载界面后本就有的依旧处于未设置状态，应该是bug
    -- info.name:SetFont("Fonts\\FRIZQT__.TTF", name_font_size) -- 不要改文字，中文版会消失，经检查字体是FZLBJW.TTF
    info.name:ClearAllPoints()
    info.name:SetPoint('BOTTOM', info.bar, 'TOP', -level_x_offset / 2, name_y_offset)
    info.bar:SetFrameLevel(2) -- 默认frame挡在statusbar前面，frame的level不能设置为0，否则无法鼠标点选
    info.bar:SetStatusBarTexture('Interface\\TargetingFrame\\UI-StatusBar')
    info.border:SetTexture(0, 0, 0, 1)
    info.border:ClearAllPoints()
    info.border:SetPoint('BOTTOMLEFT', info.bar, 'BOTTOMLEFT', -border_width, -border_width)
    info.border:SetPoint('TOPRIGHT', info.bar, 'TOPRIGHT', border_width, border_width)
    info.glow:SetTexture(0.8, 0.8, 0.8, 1)
    info.marker:ClearAllPoints()
    info.marker:SetPoint('BOTTOMRIGHT', info.border, 'TOPLEFT', 0, 0)
    -- info.marker:SetTexCoord(0, 0.25, 0, 0.25)
end

local function nameplate_on_show(frame, info)
    -- BananaPrint("nameplate_on_show", frame)
    frame:SetWidth(0.0001)
    frame:SetHeight(0.0001)
    info.bar:SetWidth(bar_width)
    info.bar:SetHeight(bar_height)
    info.bar:ClearAllPoints()
    info.bar:SetPoint('TOP', 0, bar_y_offset)
    -- BananaPrint(frame:GetWidth(), frame:GetHeight())
    info.level:ClearAllPoints()
    info.level:SetPoint('RIGHT', info.name, level_x_offset, 0)
    -- info.marker:Show()
end

local function nameplate_on_update(frame, info)
    info.glow:ClearAllPoints()
    info.glow:SetPoint('BOTTOMLEFT', info.bar, 'BOTTOMLEFT', -glow_width, -glow_width)
    info.glow:SetPoint('TOPRIGHT', info.bar, 'TOPRIGHT', glow_width, glow_width)
end

local children_info = {}
local target_nameplate = nil
local prev_target_nameplate = nil

-- target changed和target nameplate changed如果混在一个函数里会有逻辑错误，比如在没有nameplate之时点选不同目标，那么这个on_change函数并不会被触发
local function on_target_nameplate_or_target_changed()
    -- BananaPrint("on_target_nameplate_or_target_changed", target_exists, target_nameplate)
    if UnitExists('target') and (not UnitIsDead('target')) and UnitCanAttack('player', 'target') and UIParent:IsShown() then -- 不要在nameplate的扫描里设置target_exists全局变量，否则PLAYER_TARGET_CHANGED事件之时target_exists全局变量可能会与事实相反
        local is_boss = (UnitClassification('target') == 'worldboss')
        BananaTargetNameplate:SetWidth(is_boss and 256 or 128)
        BananaTargetNameplate:ClearAllPoints()
        if target_nameplate then
            -- 不能把BananaTargetNameplate的parent设置为nameplate，否则alpha值会是半透明状态，估计是系统设置nameplate的children的时候改变的
            -- BananaPrint(target_nameplate:GetAlpha(), BananaTargetNameplate:GetAlpha())
            -- BananaPrint(target_nameplate:GetPoint(1))
            local info = children_info[target_nameplate]
            BananaTargetNameplate:SetPoint('TOP', info.bar, 0, 0)
            BananaTargetNameplate:Show()
        else
            BananaTargetNameplate:SetPoint('BOTTOM', WorldFrame, 'CENTER', 0, is_boss and 224 or 192)
            BananaTargetNameplate:Show()
        end
    else
        BananaTargetNameplate:Hide()
    end
end

local function scan_children(...)
    local num_visible, num_opaque, first_opaque = 0, 0, nil
    for i = 1, arg.n do
        local frame = arg[i]
        local info = children_info[frame]
        if not info then
            info = {}
            children_info[frame] = info
            info.border, info.glow, info.name, info.level, info.skull, info.marker = frame:GetRegions()
            info.bar = frame:GetChildren()
            local is_valid_border = info.border and info.border:GetObjectType() == 'Texture' and info.border:GetTexture() == 'Interface\\Tooltips\\Nameplate-Border'
            local is_valid_name = info.name and info.name:GetObjectType() == 'FontString'
            local is_valid_level = info.level and info.level:GetObjectType() == 'FontString'
            local is_valid_bar = info.bar and info.bar:GetObjectType() == 'StatusBar'
            if is_valid_border and is_valid_name and is_valid_level and is_valid_bar then
                info.is_nameplate = true
                info.tweaking_required = true
                nameplate_on_load(frame, info)
            end
        end
        if info.is_nameplate then
            if frame:IsShown() then
                num_visible = num_visible + 1
                if frame:GetAlpha() == 1 then
                    num_opaque = num_opaque + 1
                    if not first_opaque then
                        first_opaque = frame
                    end
                end
                if info.tweaking_required then
                    nameplate_on_show(frame, info)
                    info.tweaking_required = false
                end
                frame:EnableMouse(true) -- 设置为false可以禁用姓名板点击
                nameplate_on_update(frame, info)
            else
                info.tweaking_required = true
            end
        end
    end
    target_nameplate = UnitExists('target') and first_opaque
    if target_nameplate then
        target_nameplate:EnableMouse(false)
    end
    -- 去重
    if target_nameplate ~= prev_target_nameplate then
        on_target_nameplate_or_target_changed()
        prev_target_nameplate = target_nameplate
    end
end

BananaAddTask(
    function()
        scan_children(WorldFrame:GetChildren())
        return 0
    end,
    0
)

BananaRegisterEvent('PLAYER_TARGET_CHANGED', on_target_nameplate_or_target_changed)
BananaOnUIParentToggle(on_target_nameplate_or_target_changed)

function BananaTargetNameplate_UpdateHealthPercent(this)
    -- 注意不要改全局变量this，会导致之后的代码出错
    local min, max = this:GetMinMaxValues()
    local val = this:GetValue()
    local percent = (max == 0) and 0 or (val - min) / (max - min)
    local percent_label = getglobal(this:GetParent():GetName() .. 'HealthPercent')
    percent_label:SetText(format('%d%%', percent * 100))
    -- 参考HealthBar_OnValueChanged()渐变颜色（虽然客户端里没用到）
    local r, g, b
    if percent > 0.5 then
        r = (1.0 - percent) * 2
        g = 1.0
    else
        r = 1.0
        g = percent * 2
    end
    b = 0.0
    percent_label:SetTextColor(r, g, b)
end

-- 参考GlueXML\CharacterCreate.lua
local class_icon_tcoords = {
    ['WARRIOR'] = {0, 0.25, 0, 0.25},
    ['MAGE'] = {0.25, 0.49609375, 0, 0.25},
    ['ROGUE'] = {0.49609375, 0.7421875, 0, 0.25},
    ['DRUID'] = {0.7421875, 0.98828125, 0, 0.25},
    ['HUNTER'] = {0, 0.25, 0.25, 0.5},
    ['SHAMAN'] = {0.25, 0.49609375, 0.25, 0.5},
    ['PRIEST'] = {0.49609375, 0.7421875, 0.25, 0.5},
    ['WARLOCK'] = {0.7421875, 0.98828125, 0.25, 0.5},
    ['PALADIN'] = {0, 0.25, 0.5, 0.75}
}

function BananaTargetNameplate_UpdatePortrait(this)
    local portrait = getglobal(this:GetName() .. 'Portrait')
    local class, coords = nil, nil
    if UnitExists('target') and UnitIsPlayer('target') then
        _, class = UnitClass('target')
        coords = class_icon_tcoords[class]
    end
    -- BananaPrint(class)
    if coords then
        portrait:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
        portrait:Show()
    else
        portrait:Hide()
    end
end

function BananaPetNameplate_UpdateHappiness()
    local happiness_tex = getglobal(this:GetName() .. 'Happiness')
    local happiness, _, _ = GetPetHappiness()
    local _, is_hunter_pet = HasPetUI()
    if happiness and is_hunter_pet then
        if happiness == 1 then
            happiness_tex:SetTexCoord(51 / 128, (51 + 18) / 128, 3 / 64, 20 / 64)
        elseif happiness == 2 then
            happiness_tex:SetTexCoord(27 / 128, (27 + 18) / 128, 3 / 64, 20 / 64)
        elseif happiness == 3 then
            happiness_tex:SetTexCoord(3 / 128, (3 + 18) / 128, 3 / 64, 20 / 64)
        end
        happiness_tex:Show()
    else
        happiness_tex:Hide()
    end
end
