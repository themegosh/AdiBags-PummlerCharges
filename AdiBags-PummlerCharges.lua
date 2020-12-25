local _, ns = ...

local addon = LibStub('AceAddon-3.0'):GetAddon('AdiBags')
local L = setmetatable({}, {__index = addon.L})

local mod = addon:NewModule("AdiPummlerCharges", 'ABEvent-1.0')
mod.uiName = L['Pummler Charges Overlay']
mod.uiDesc = L['Adds a Charges Count overlay to Manual Crowd Pummlers']

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
    local text
    local text2

    if getglobal("MCPTooltipTextLeft11") then
        text = getglobal("MCPTooltipTextLeft11"):GetText()
    end

    if getglobal("MCPTooltipTextLeft12") then
        text2 = getglobal("MCPTooltipTextLeft12"):GetText()
    end

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

function mod:UpdateButton(event, button)
    local textOverlay = button.PummlerChargesOverlay
    if enabled then
        local link = button:GetItemLink()
        if link then
            local itemName = GetItemInfo(link)
            if itemName == 'Manual Crowd Pummeler' then
                local charges = GetCharges(button.bag, button.slot)
                if not textOverlay then
                    textOverlay = button:CreateFontString(f, "OVERLAY",
                                                          "GameTooltipText")
                    textOverlay:SetPoint("CENTER", 0, 0)
                    local fontName = textOverlay:GetFont()
                    textOverlay:SetFont(fontName, 18, "OUTLINE")
                end
                textOverlay:SetText(charges)
                return true
            end
        end
    end

    if textOverlay then texture:Hide() end
end

