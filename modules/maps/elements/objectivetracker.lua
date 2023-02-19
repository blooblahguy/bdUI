local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Maps")
local config

local collapsed = false

local function collapse()
	if (ObjectiveTracker_Collapse) then 
		ObjectiveTracker_Collapse() 
	elseif (WatchFrameCollapseExpandButton and not collapsed) then
		collapsed = true
		WatchFrameCollapseExpandButton:Click()
	end
end

local function expand()
	if (ObjectiveTracker_Expand) then 
		ObjectiveTracker_Expand()
	elseif (WatchFrameCollapseExpandButton and collapsed) then
		collapsed = false
		WatchFrameCollapseExpandButton:Click()
	end
end

function mod:create_objective_tracker()
	config = mod.config
	-- if (MinimapCluster.SetHeaderUnderneath) then return end -- not messing with this in DF

	local frame = ObjectiveTracker or ObjectiveTrackerFrame or WatchFrame
	if (not frame) then return end

	frame:SetClampedToScreen(false)

	local quest_anchor = CreateFrame("frame", "bdObjectiveFrame", bdParent)
	quest_anchor:SetSize(200 * config.scale, 50)
	quest_anchor:SetPoint("TOP", Minimap, "BOTTOM", 0, -40)
	bdMove:set_moveable(quest_anchor, "Objective Tracker")
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", quest_anchor, "TOPLEFT", -30, 0)

	Minimap.qa = quest_anchor

	local function move_objective_tracker(self, rel, anchor, rel2)
		if (anchor == quest_anchor) then return end
		frame:ClearAllPoints()
		if (frame == ObjectiveTrackerFrame) then
			frame:SetPoint("TOPLEFT", quest_anchor, 0, 0)
			frame:SetPoint("TOPRIGHT", quest_anchor, 0, 0)
		else
			frame:SetPoint("TOPLEFT", quest_anchor, -34, 0)
			frame:SetPoint("TOPRIGHT", quest_anchor, 42, 0)
		end
		local bottom = quest_anchor:GetBottom() * bdUI.scale
		frame:SetHeight(bottom - 100)
	end

	hooksecurefunc(frame, "SetPoint", move_objective_tracker)
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", quest_anchor, "TOPLEFT", -30, 0)

	-- auto collapse in combat
	local f = CreateFrame("Frame")
	f:SetScript("OnEvent",function(self, event, addon)
		if (event == "ENCOUNTER_START" or (event == "PLAYER_ENTERING_WORLD" and IsInRaid())) then
			collapse()
		elseif (event == "ENCOUNTER_END" and not IsInRaid()) then
			expand()
		end
	end)
	f:RegisterEvent("PLAYER_ENTERING_WORLD")
	f:RegisterEvent("ENCOUNTER_START")
	f:RegisterEvent("ENCOUNTER_END")
end