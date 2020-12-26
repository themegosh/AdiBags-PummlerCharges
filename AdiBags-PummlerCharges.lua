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

-- code from https://wago.io/TMiK1zsb9
local function GetCharges(bag, slot)

    if not MCPTooltip then
        CreateFrame("GameTooltip", "MCPTooltip", nil, "GameTooltipTemplate")
        MCPTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
    end

    if bag == "player" and slot == 16 then
        MCPTooltip:SetInventoryItem(bag, slot)
    else
        MCPTooltip:SetBagItem(bag, slot)
    end

    local charges = nil
    local text, text2, text3

    if getglobal("MCPTooltipTextLeft11") then
        text = getglobal("MCPTooltipTextLeft11"):GetText()
    end

    if getglobal("MCPTooltipTextLeft12") then
        text2 = getglobal("MCPTooltipTextLeft12"):GetText()
    end

    -- print('text', text)
    -- print('text2', text2)

    if text then
        if string.find(text, "耗尽") then
            charges = 0
        elseif string.find(text, "次") then
            charges = text:gsub("次", "")
        elseif string.find(text, "Charge") then
            charges, _ = strsplit(" ", text, 2)
            -- print(charges)
        end
    end

    if text2 then
        if string.find(text2, "耗尽") then
            charges = 0
        elseif string.find(text2, "次") then
            charges = text2:gsub("次", "")
        elseif string.find(text2, "Charge") then
            charges, _ = strsplit(" ", text2, 2)
            -- print(charges)
        end
    end

    if not charges then charges = 0 end

    charges = tonumber(charges)
    return charges

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

local function UpdateChargesOverlay(button, link)

    local textOverlay = button.PummlerChargesOverlay
    local charges = GetCharges(button.bag, button.slot)

    if not textOverlay then
        textOverlay = button:CreateFontString(f, "OVERLAY", "GameTooltipText")
        textOverlay:SetPoint("CENTER", 0, 0)
        local fontName = textOverlay:GetFont()
        textOverlay:SetFont(fontName, 18, "OUTLINE")
        button.PummlerChargesOverlay = textOverlay
    else
        textOverlay:Show()
    end

    textOverlay:SetText(charges)
    local red, green, blue = GetChargesColor(charges)
    textOverlay:SetTextColor(red, green, blue)

end

function mod:UpdateButton(event, button)

    if enabled then
        local link = button:GetItemLink()
        if link then

            local itemName = GetItemInfo(link)
            if itemName == 'Manual Crowd Pummeler' then

                UpdateChargesOverlay(button, link)
                UpdateEnchantedOverlay(button, link)

                return
            end
        end
    end

    -- clean up non-pummler overlays (moving items around the bags)
    if button.PummlerChargesOverlay then button.PummlerChargesOverlay:Hide() end
    if button.PummlerEnchantedOverlay then
        button.PummlerEnchantedOverlay:Hide()
    end
end

