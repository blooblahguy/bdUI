local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Tooltips")

local function unit_name(self, unit)
	-- name info
	local name, realm = UnitName(unit)
	if (mod.config.enabletitlesintt) then
		name = UnitPVPName(unit)
	end

	-- color by class
	local namecolor = {mod:getUnitColor(unit)}
	local namehex = RGBPercToHex(unpack(namecolor))

	-- color the strings
	name = mod.config.showrealm and realm and "|CFF"..namehex..name.."-"..realm.."|r" or "|CFF"..namehex..name.."|r"
	
	return name
end

--=========================
-- Make the player tooltip
--=========================
function mod:player_tooltip(self, unit)
	local name = unit_name(self, unit)
	local guild, rank = GetGuildInfo(unit)
	local race = UnitRace(unit) or ""
	local factionGroup = select(1, UnitFactionGroup(unit))
	local dnd = UnitIsAFK(unit) and " |cffBBBBBB<AFK>|r " or UnitIsDND(unit) and " |cffBBBBBB<DND>|r " or ""

	GameTooltipTextLeft1:SetFormattedText('%s%s', name, dnd)

	if (IsShiftKeyDown() and WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC) then
		mod:getAverageItemLevel(self, self.unit)
	end

	-- Color level by difficulty
	local level = UnitLevel(unit)
	local levelColor = GetQuestDifficultyColor(level)
	if level == -1 then
		level = '??'
		levelColor = {r = 1, g = 0, b = 0}
	end

	-- Friend / Enemy coloring
	local friendColor = factionGroup == "Horde" and {r = 1, g = 0.15, b = 0} or {r = 0, g = 0.55, b = 1}

	-- add guild rank
	if (guild) then
		local guild_line, guild_line_index = GameTooltip:FindLine(guild)
		guild_line:SetFormattedText('<|cff00FF00%s|r> |cffBBBBBB%s|r', guild, rank)
	end

	-- add realm
	local name, realm = UnitName(unit)
	realm = realm and mod.config.showrealm and realm or ""

	-- color leveling, color faction, add realm
	local level_line, level_line_index = GameTooltip:FindLine("Level %d")
	level_line:SetFormattedText('|cff%s%s|r |cff%s%s|r %s', RGBPercToHex(levelColor), level, RGBPercToHex(friendColor), race, realm)
end