local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Maps")
local config

function mod:create_objective_tracker()
	config = mod.config
	if (MinimapCluster.SetHeaderUnderneath) then return end -- not messing with this in DF

	local frame = ObjectiveTracker and ObjectiveTracker or ObjectiveTrackerFrame and ObjectiveTrackerFrame or WatchFrame and WatchFrame
	frame:SetClampedToScreen(false)

	local quest_anchor = CreateFrame("frame", "bdObjectiveFrame", bdParent)
	quest_anchor:SetSize(160 * config.scale, 50)
	quest_anchor:SetPoint("TOP", Minimap, "BOTTOM", 0, -50)
	bdMove:set_moveable(quest_anchor, "Objective Tracker")
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", quest_anchor, "TOPLEFT", -30, 0)

	Minimap.qa = quest_anchor

	local function move_objective_tracker()
		frame:ClearAllPoints()
		ignore_point = true
		frame:SetPoint("TOPLEFT", quest_anchor, "TOPLEFT", -30, 0)
		local bottom = quest_anchor:GetBottom() * bdUI.scale
		frame:SetHeight(bottom - 100)
		ignore_point = false
	end

	if (frame) then
		move_objective_tracker()
		hooksecurefunc(frame, "SetPoint", function(self, anchorPoint, relativeTo, x, y)
			if (not ignore_point) then
				move_objective_tracker()
			end
		end)
	end

	local f = CreateFrame("Frame")
	f:SetScript("OnEvent",function(self, event, addon)
		if (event == "ENCOUNTER_START" or (event == "PLAYER_ENTERING_WORLD" and IsInRaid())) then
			if (ObjectiveTracker_Collapse) then ObjectiveTracker_Collapse() end
		elseif (event == "ENCOUNTER_END" and not IsInRaid()) then
			if (ObjectiveTracker_Expand) then ObjectiveTracker_Expand() end
		end
	end)
	f:RegisterEvent("PLAYER_ENTERING_WORLD")
	f:RegisterEvent("ENCOUNTER_START")
	f:RegisterEvent("ENCOUNTER_END")
end