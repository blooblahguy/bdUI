local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Maps")
local config

function mod:create_objective_tracker()
	config = mod.config

	local ignore_point

	local quest_anchor = CreateFrame("frame", "bdObjectiveFrame", bdParent)
	quest_anchor:SetSize(config.size, 50)
	quest_anchor:SetPoint("TOP", Minimap.background, "BOTTOM", 0, -50)
	bdMove:set_moveable(quest_anchor, "Objective Tracker")

	local function move_objective_tracker()
		local tracker = ObjectiveTrackerFrame
		tracker:ClearAllPoints()
		ignore_point = true
		tracker:SetPoint("TOPLEFT", quest_anchor, "TOPLEFT", 0, 0)
		local bottom = quest_anchor:GetBottom() * bdUI.scale
		tracker:SetHeight(bottom - 100)
		ignore_point = false

		DurabilityFrame:ClearAllPoints()
		DurabilityFrame:SetPoint("BOTTOMRIGHT", Minimap.background, "BOTTOMLEFT", -20, 0)
	end

	local f = CreateFrame("Frame")
	f:SetScript("OnEvent",function(self, event, addon)
		if (event == "ENCOUNTER_START") then
			ObjectiveTracker_Collapse()
		elseif (event == "ENCOUNTER_END") then
			ObjectiveTracker_Expand()
		else
			if (IsAddOnLoaded("Blizzard_ObjectiveTracker") or bdUI:get_game_version() == "vanilla") then
				-- bdUI:set_backdrop(ObjectiveTrackerFrame)
				-- ObjectiveTrackerFrame:ClearAllPoints()
				-- print(ObjectiveTrackerFrame:GetPoint())
				move_objective_tracker()
				hooksecurefunc(ObjectiveTrackerFrame, "SetPoint", function(self, anchorPoint, relativeTo, x, y)
					if (not ignore_point) then
						move_objective_tracker()
					end
				end)
				self:UnregisterEvent("ADDON_LOADED")
			else
				self:RegisterEvent("ADDON_LOADED")
			end
		end
	end)
	f:RegisterEvent("PLAYER_ENTERING_WORLD")
	f:RegisterEvent("PLAYER_LOGIN")
	f:RegisterEvent("ENCOUNTER_START")
	f:RegisterEvent("ENCOUNTER_END")

end