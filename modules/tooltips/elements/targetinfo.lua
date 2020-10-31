local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Tooltips")

function returnUnitItemLevel(unit)
	local ilvl = 0
	local mainHandEquipLoc, offHandEquipLoc
	local numSlots = 0
	
	for slot = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
		if slot ~= INVSLOT_BODY and slot ~= INVSLOT_TABARD then
			local itemLink = GetInventoryItemLink(unit, slot)
			if itemLink then -- If we have an item in this slot,
				local itemLevel = GetDetailedItemLevelInfo(itemLink)
				ilvl = ilvl + itemLevel -- Add it to the total

				numSlots = numSlots + 1
			end
		end
	end

	if (ilvl and numSlots) then
		return math.floor((ilvl / numSlots)+0.5)
	else
		return "err"
	end
end

local function returnUnitSpecialization(unit)
	local currentSpec = GetInspectSpecialization(unit)
	local id, name, description, icon, background, role, class = GetSpecializationInfoByID(currentSpec)

	return "|T"..icon..":12|t "..name
end

local inspector = CreateFrame("frame", nil, UIParent)
inspector:RegisterEvent("INSPECT_READY")
inspector:SetScript("OnEvent", function(self, event, guid)
	local inspectUnit = self.inspectUnit
	if inspectUnit and UnitGUID(inspectUnit) == guid then
		
		local ilvl = returnUnitItemLevel(inspectUnit) -- Calculate the unit's average item level
		local spec = returnUnitSpecialization(inspectUnit) -- Get unit spec
		local numlines = self.tooltip:NumLines()
		ClearInspectPlayer()

		
		if (self.tooltip.ilvl) then
			_G["GameTooltipTextLeft"..self.tooltip.ilvl]:SetText("iLvl")
			_G["GameTooltipTextLeft"..self.tooltip.ilvl]:Show()
			_G["GameTooltipTextRight"..self.tooltip.ilvl]:SetText(ilvl)
			_G["GameTooltipTextRight"..self.tooltip.ilvl]:Show()

			_G["GameTooltipTextLeft"..self.tooltip.spec]:SetText("Spec")
			_G["GameTooltipTextLeft"..self.tooltip.spec]:Show()
			_G["GameTooltipTextRight"..self.tooltip.spec]:SetText(spec)
			_G["GameTooltipTextRight"..self.tooltip.spec]:Show()
		else
			self.tooltip.ilvl = numlines + 1
			self.tooltip.spec = numlines + 2
			self.tooltip:AddDoubleLine("iLvl", ilvl, .7, .7, .7, unpack(self.tooltip.levelColor))
			self.tooltip:AddDoubleLine("Spec", spec, .7, .7, .7, unpack(self.tooltip.namecolor))
		end
		
		self.tooltip:Show()

		self.inspectUnit = nil
		self.tooltip = nil
	end

end)

-- Request the average item level of a unit to be calculated
function mod:getAverageItemLevel(tooltip, unit)
	if (not UnitIsPlayer(unit) or not UnitIsFriend("player", unit)) then return end

	inspector.inspectUnit = unit
	inspector.tooltip = tooltip
	NotifyInspect(unit)
end