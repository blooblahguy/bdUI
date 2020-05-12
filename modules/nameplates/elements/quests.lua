local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Nameplates")

local world_quests = {}
local quests = {}
local quest_tt = CreateFrame('GameTooltip', nil, nil, 'GameTooltipTemplate')

function mod:update_quest_marker(self, event, unit)
	-- print(self, event, unit)
end