local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Tooltips")

local inspector = CreateFrame("frame", nil, UIParent)
inspector:RegisterEvent("INSPECT_READY")
local stored_units = {}

local function returnItemCount(unit)
	local numSlots = 0
	for slot = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
		if slot ~= INVSLOT_BODY and slot ~= INVSLOT_TABARD then
			local itemLink = GetInventoryItemLink(unit, slot)
			if itemLink then -- If we have an item in this slot,
				numSlots = numSlots + 1
			end
		end
	end

	return numSlots
end

local function returnUnitItemLevel(unit)
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

	if (ilvl > 0 and numSlots > 0) then
		return math.floor((ilvl / numSlots)+0.5)
	else
		return 0
	end
end

local function returnUnitSpecialization(unit)
	local currentSpec = GetInspectSpecialization(unit)
	local id, name, description, icon, background, role, class = GetSpecializationInfoByID(currentSpec)

	if (name) then
		return "|T"..icon..":12|t "..name
	end
	return ""
end

local function populateTooltip(tooltip, ilvl, spec)
	local numlines = tooltip:NumLines()

	if (tooltip.ilvl) then
		_G["GameTooltipTextLeft"..tooltip.ilvl]:SetText("iLvl")
		_G["GameTooltipTextLeft"..tooltip.ilvl]:Show()
		_G["GameTooltipTextRight"..tooltip.ilvl]:SetText(ilvl)
		_G["GameTooltipTextRight"..tooltip.ilvl]:Show()
		
		_G["GameTooltipTextLeft"..tooltip.spec]:SetText("Spec")
		_G["GameTooltipTextLeft"..tooltip.spec]:Show()
		_G["GameTooltipTextRight"..tooltip.spec]:SetText(spec)
		_G["GameTooltipTextRight"..tooltip.spec]:Show()
	else
		tooltip:AddDoubleLine("iLvl", ilvl, .7, .7, .7, unpack(tooltip.levelColor))
		tooltip:AddDoubleLine("Spec", spec, .7, .7, .7, unpack(tooltip.namecolor))
		tooltip.ilvl = numlines + 1
		tooltip.spec = numlines + 2
	end

	tooltip:Show()
end

local function inspectReady(self, event, guid)
	local inspectUnit = inspector.inspectUnit
	if inspectUnit and UnitGUID(inspectUnit) == guid then
		
		local delay = 0
		-- we gotta wait for items from the server
		local count = returnItemCount(inspectUnit)
		if (count < 15) then
			delay = 0.5
		end
		local tooltip = inspector.tooltip
		C_Timer.After(delay, function()
			local ilvl = returnUnitItemLevel(inspectUnit) -- Calculate the unit's average item level
			local spec = returnUnitSpecialization(inspectUnit) -- Get unit spec

			if (ilvl > 0) then
				stored_units[guid] = {GetTime(), ilvl, spec}
				populateTooltip(tooltip, ilvl, spec)
			end

			ClearInspectPlayer()
			inspector.tooltip = nil
			inspector.inspectUnit = nil
		end)
	end
		
end

-- Request the average item level of a unit to be calculated
function mod:getAverageItemLevel(tooltip, unit)
	if (not UnitIsPlayer(unit) or not UnitIsFriend("player", unit)) then return end
	if (InCombatLockdown()) then return end

	local guid = UnitGUID(unit)
	local stored = stored_units[guid]
	if (stored) then
		local duration, ilvl, spec = unpack(stored)

		if (GetTime() - duration < 60) then
			populateTooltip(tooltip, ilvl, spec)
			return
		else
			stored_units[guid] = nil
		end
	end

	inspector.inspectUnit = unit
	inspector.tooltip = tooltip
	NotifyInspect(unit)
end

inspector:SetScript("OnEvent", inspectReady)