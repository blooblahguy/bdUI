local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Nameplates")

local world_quests = {}
local quests = {}
local quest_tt = CreateFrame('GameTooltip', nil, nil, 'GameTooltipTemplate')

mod.create_quest_tracker = function(self, event, unit)
	self.QuestProgress = CreateFrame("Frame", nil, self.Health)
	-- print(self, event, unit)
end