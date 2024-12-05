function BananaComboFrame_Initialize(this)
    local this_name = this:GetName()
    local i = 1
    while true do
        local combo_point = getglobal(this_name .. "ComboPoint" .. i)
        if combo_point then
            combo_point:SetVertexColor(0.8, 0.8, 0.8)
        else
            break
        end
        i = i + 1
    end
    this:SetScript("OnEvent", BananaComboFrame_OnEvent)
    this:RegisterEvent("PLAYER_TARGET_CHANGED")
    this:RegisterEvent("PLAYER_COMBO_POINTS")
    BananaComboFrame_Update(this)
end

function BananaComboFrame_OnEvent()
    BananaComboFrame_Update(this)
end

function BananaComboFrame_Update(this)
    local this_name = this:GetName()
    local num_combo_points = GetComboPoints()
    local i = 1
    while i <= num_combo_points do -- 不能用for循环，循环变量的作用域只在循环体内
        local combo_point = getglobal(this_name .. "ComboPoint" .. i)
        if combo_point then
            combo_point:Show()
        else
            break
        end
        i = i + 1
    end
    this:SetWidth((i - 1) * 13 + 3)
    while true do
        local combo_point = getglobal(this_name .. "ComboPoint" .. i)
        if combo_point then
            combo_point:Hide()
        else
            break
        end
        i = i + 1
    end
end
