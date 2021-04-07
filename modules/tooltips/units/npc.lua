local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Tooltips")

function mod:npc_tooltip(self, unit)
	local race = UnitRace(unit) or ""
	local factionGroup = select(1, UnitFactionGroup(unit))
	local creatureType = UnitCreatureType(unit)
	local classification = UnitClassification(unit)
	local classification_names = {
		["worldboss"] = "Boss",
		["rareelite"] = "Rare Elite",
		["elite"] = "Elite",
		["rare"] = "Rare",
		["normal"] = "",
		["trivial"] = "",
		["minus"] = ""
	}
	classification = classification_names[classification]

	-- do they have a faction?
	-- local faction = GameTooltip:NumLines() >= 2 and _G["GameTooltipTextLeft"..GameTooltip:NumLines()]
	local faction, faction_index = GameTooltip:LastLine()
	local standings = {
		{"Unknown", ""},
		{"Hated", "cc0000"},
		{"Hostile", "ff0000"},
		{"Unfriendly", "f26000"},
		{"Neutral", "e4e400"},
		{"Friendly", "33ff33"},
		{"Honored", "5fe65d"},
		{"Revered", "53e9bc"},
		{"Exalted", "2ee6e6"},
	}

	if (faction) then
		for factionIndex = 1, GetNumFactions() do
			local name, description, standingId, bottomValue, topValue, earnedValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild = GetFactionInfo(factionIndex)
				if (not isHeader and name == faction:GetText() and standingId > 0) then
					local info, color = unpack(standings[standingId + 1])
					faction:SetText(name.." (|cff"..color..info..")|r")
					-- DEFAULT_CHAT_FRAME:AddMessage("Faction: " .. name .. " - " .. standingId, bottomValue, topValue, earnedValue)
				end
		  end
	end

	-- color leveling
	local level_line, level_line_index = GameTooltip:FindLine("Level %d")
	if (level_line) then
		-- Color level by difficulty
		local level = UnitLevel(unit)
		local levelColor = GetQuestDifficultyColor(level)
		if level == -1 then
			level = '??'
			levelColor = {r = 1, g = 0, b = 0}
		end

		-- Friend / Enemy coloring
		local friendColor = factionGroup == "Horde" and {r = 1, g = 0.15, b = 0} or {r = 0, g = 0.55, b = 1}
		level_line:SetFormattedText('|cff%s%s|r |cff%s|r%s |cffFFFF00%s|r', RGBPercToHex(levelColor), level, RGBPercToHex(friendColor), creatureType, classification)
	end

	
end