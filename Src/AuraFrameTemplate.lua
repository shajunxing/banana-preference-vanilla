function BananaAuraFrame_Initialize(this, unit, anchor, aurafunc, filtered, icon_size, icon_margin)
    this.anchor = anchor
    this.hmul = string.find(anchor, "LEFT$") and 1 or -1
    this.vmul = string.find(anchor, "^BOTTOM") and 1 or -1
    this.unit = unit
    this.aurafunc = aurafunc
    this.filtered = filtered
    this.icons = this.icons or {}
    this.icon_size = icon_size or 21
    this.icon_margin = icon_margin or 3
    this:SetScript("OnEvent", BananaAuraFrame_OnEvent)
    this:RegisterEvent("PLAYER_ENTERING_WORLD")
    this:RegisterEvent("UNIT_AURA")
    this:RegisterEvent("PLAYER_TARGET_CHANGED")
    this:RegisterEvent("UNIT_PET")
    BananaAuraFrame_Update(this)
end

function BananaAuraFrame_OnEvent()
    if arg1 == this.unit or (event == "PLAYER_TARGET_CHANGED" and this.unit == "target") or (event == "UNIT_PET" and arg1 == "player" and this.unit == "pet") or event == "PLAYER_ENTERING_WORLD" then
        BananaAuraFrame_Update(this)
    end
end

function BananaAuraFrame_Update(this)
    if not this.unit then
        return
    end
    local i = 1
    while this.icons[i] do
        this.icons[i]:Hide()
        i = i + 1
    end
    i = 1
    local x, y = nil, nil
    local frame_width = this:GetWidth()
    local icon_size = this.icon_size
    local icon_margin = this.icon_margin
    while true do
        local tex = this.aurafunc(this.unit, i, this.filtered)
        if not tex then
            break
        end
        local icon = this.icons[i]
        if not icon then
            icon = this:CreateTexture(nil, "ARTWORK")
            icon:SetWidth(icon_size)
            icon:SetHeight(icon_size)
            this.icons[i] = icon
        end
        icon:SetTexture(tex)
        if not x then
            x, y = 0, 0
        elseif (x + icon_size * 2 + icon_margin) <= frame_width then
            x = x + icon_size + icon_margin
        else
            x = 0
            y = y + icon_size + icon_margin
        end
        icon:SetPoint(this.anchor, x * this.hmul, y * this.vmul)
        icon:Show()
        i = i + 1
    end
    if not y then
        this:SetHeight(1)
    else
        this:SetHeight(y + icon_size)
    end
end
