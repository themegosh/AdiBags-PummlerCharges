local _, ns = ...

local addon = LibStub('AceAddon-3.0'):GetAddon('AdiBags')
local L = setmetatable({}, {__index = addon.L})

local mod = addon:NewModule("AdiPummlerCharges", 'ABEvent-1.0')
mod.uiName = L['Manual Crowd Pummler Overlay']
mod.uiDesc =
    L['Adds a # of Charges overlay to Manual Crowd Pummlers and a * to indicate if they\'re enchanted with an Iron Counterweight.']

local enabled = false

function mod:OnInitialize() end

function mod:OnEnable()
    enabled = true
    self:RegisterMessage('AdiBags_UpdateButton', 'UpdateButton')
    self:SendMessage('AdiBags_UpdateAllButtons')
end

function mod:OnDisable()
    enabled = false
    self:SendMessage('AdiBags_UpdateAllButtons')
end

function mod:GetOptions() end

local function GetCharges(bag, slot)

    local text, charges

    -- read lines 11 to 13 (can move because of enchants/attachments)
    for textLines = 11, 13 do

        local textLine = "MCPTooltipTextLeft" .. textLines

        if getglobal(textLine) then

            text = getglobal(textLine):GetText()

            if text then
                if text:find("耗尽") then
                    charges = 0
                elseif text:find("次") then
                    charges = text:gsub("次", "")
                elseif text:find("Charge") then
                    charges = strsplit(" ", text, 2)
                end

                if charges then
                    charges = tonumber(charges)
                    return charges
                end
            end

        end
    end

    return charges

end

local function HasAttachment()
    local text, attachment

    for textLines = 8, 9 do

        local textLine = "MCPTooltipTextLeft" .. textLines

        if getglobal(textLine) then

            text = getglobal(textLine):GetText()

            if text then if text:find("Undead") then return true end end
        end
    end

end

-- returns Red, Green, Blue
local function GetChargesColor(charges)

    if charges == 3 then
        return 0, 1, 0 -- green
    elseif charges == 2 then
        return 1, 0.6, 0 -- orange
    elseif charges == 1 then
        return 0.9, 0, 0 -- red
    else
        return 0.7, 0.7, 0.7 -- grey
    end

end

local function UpdateEnchantedOverlay(button, link)

    local textEnchantedOverlay = button.PummlerEnchantedOverlay
    local _, _, _, _, _, Enchant = link:find(
                                       "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")

    -- iron counterweight is id 34
    if not textEnchantedOverlay and Enchant == "34" then
        textEnchantedOverlay = button:CreateFontString(f, "OVERLAY",
                                                       "GameTooltipText")
        textEnchantedOverlay:SetPoint("TOPRIGHT", 1, -2)
        local fontName = textEnchantedOverlay:GetFont()
        textEnchantedOverlay:SetFont(fontName, 28, "OUTLINE")
        textEnchantedOverlay:SetText("*")
        textEnchantedOverlay:SetTextColor(1, 0, 1) -- purple
        button.PummlerEnchantedOverlay = textEnchantedOverlay
    elseif textEnchantedOverlay ~= nil and Enchant == "34" then
        textEnchantedOverlay:Show()
    elseif textEnchantedOverlay ~= nil and Enchant ~= "34" then
        textEnchantedOverlay:Hide()
    end

end

local function UpdateAttachedOverlay(button, link)

    local textAttachedOverlay = button.PummlerAttachedOverlay
    local attachment = HasAttachment()

    if not textAttachedOverlay and attachment then
        textAttachedOverlay = button:CreateFontString(f, "OVERLAY",
                                                      "GameTooltipText")
        textAttachedOverlay:SetPoint("TOPLEFT", 1, -2)
        local fontName = textAttachedOverlay:GetFont()
        textAttachedOverlay:SetFont(fontName, 28, "OUTLINE")
        textAttachedOverlay:SetText("*")
        textAttachedOverlay:SetTextColor(1, 1, 0)
        button.PummlerAttachedOverlay = textAttachedOverlay
    elseif textAttachedOverlay ~= nil and attachment then
        textAttachedOverlay:Show()
    elseif textAttachedOverlay ~= nil and attachment then
        textAttachedOverlay:Hide()
    end

end

local function UpdateChargesOverlay(button, link)

    local textOverlay = button.PummlerChargesOverlay
    local charges = GetCharges(button.bag, button.slot)

    if not textOverlay then
        textOverlay = button:CreateFontString(f, "OVERLAY", "GameTooltipText")
        textOverlay:SetPoint("CENTER", 0, 0)
        local fontName = textOverlay:GetFont()
        textOverlay:SetFont(fontName, 18, "OUTLINE")
        button.PummlerChargesOverlay = textOverlay
    end

    textOverlay:SetText(charges)
    local red, green, blue = GetChargesColor(charges)
    textOverlay:SetTextColor(red, green, blue)
    textOverlay:Show()

end

function mod:UpdateButton(event, button)

    if enabled then
        local link = button:GetItemLink()

        if link then

            local itemName = GetItemInfo(link)
            if itemName == 'Manual Crowd Pummeler' then

                -- prep tooltip for parsing
                if not MCPTooltip then
                    CreateFrame("GameTooltip", "MCPTooltip", nil,
                                "GameTooltipTemplate")
                    MCPTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
                end

                MCPTooltip:SetBagItem(button.bag, button.slot)

                UpdateChargesOverlay(button, link)
                UpdateEnchantedOverlay(button, link)
                UpdateAttachedOverlay(button, link)

                return
            end
        end
    end

    -- clean up non-pummler overlays (moving items around the bags)
    if button.PummlerChargesOverlay then button.PummlerChargesOverlay:Hide() end
    if button.PummlerEnchantedOverlay then
        button.PummlerEnchantedOverlay:Hide()
    end
    if button.PummlerAttachedOverlay then
        button.PummlerAttachedOverlay:Hide()
    end
end

