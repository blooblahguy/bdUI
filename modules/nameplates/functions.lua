--===============================================
-- FUNCTIONS
--===============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Nameplates")

--===============================================
-- Custom functionality
-- place custom functionality here
--===============================================
local colors = {}
colors.tapped = { .6, .6, .6 }
colors.offline = { .6, .6, .6 }
colors.reaction = {}
colors.class = {}

-- class colors
for eclass, color in next, RAID_CLASS_COLORS do
	if not colors.class[eclass] then
		colors.class[eclass] = { color.r, color.g, color.b }
	end
end

-- faction colors
for eclass, color in next, FACTION_BAR_COLORS do
	if not colors.reaction[eclass] then
		colors.reaction[eclass] = { color.r, color.g, color.b }
	end
end

mod.guid_plates = {}
local plateMapper = CreateFrame("frame")
plateMapper:RegisterEvent("NAME_PLATE_UNIT_ADDED")
plateMapper:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
plateMapper:SetScript("OnEvent", function(self, event, unit)
	if (event == "NAME_PLATE_UNIT_ADDED") then
		mod.guid_plates[UnitGUID(unit)] = unit
	elseif (event == "NAME_PLATE_UNIT_REMOVED") then
		mod.guid_plates[UnitGUID(unit)] = nil
	end
end)

-- basic class coloring
function mod:autoUnitColor(unit)
	if (not UnitExists(unit)) then
		return unpack(colors.tapped)
	end
	if UnitIsPlayer(unit) then
		return unpack(colors.class[select(2, UnitClass(unit))])
	elseif UnitIsTapDenied(unit) then
		return unpack(colors.tapped)
	else
		return unpack(colors.reaction[UnitReaction(unit, 'player')])
	end
end

function mod:autoUnitColorHex(unit)
	return RGBPercToHex(mod:autoUnitColor(unit))
end

local function unitColor(self, tapDenied, isPlayer, reaction, status)
	config = mod:get_save()

	if (tapDenied) then
		return colors.tapped
	end

	if (isPlayer or status == false) then
		if isPlayer then
			return colors.class[isPlayer]
		else
			return colors.reaction[reaction]
		end
	else
		if (status == 3) then -- securely tanking
			return config.threatcolor
			-- elseif (targetRole == "TANK") then -- another tank has threat threat
			-- 	return config.othertankcolor
		elseif (status == 2 or status == 1) then -- near or over tank threat
			return config.threatdangercolor
		else                               -- on threat table, but not near tank threat
			return config.nothreatcolor
		end
	end
end

mod.unitColor = unitColor --memoize(unitColor, mod.cache)

function mod:numberize(v)
	if v <= 9999 then return v end
	if v >= 1000000000 then
		local value = format("%.1fb", v / 1000000000)
		return value
	elseif v >= 1000000 then
		local value = format("%.1fm", v / 1000000)
		return value
	elseif v >= 10000 then
		local value = format("%.1fk", v / 1000)
		return value
	end
end

function mod:round(num, numDecimalPlaces)
	local mult = 10 ^ (numDecimalPlaces or 0)
	return floor(num * mult + 0.5) / mult
end
