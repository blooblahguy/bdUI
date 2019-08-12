local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Maps")
local config

function mod:create_objective_tracker()
	config = mod:get_save()

	local ignore_point

	local quest_anchor = CreateFrame("frame", "bdObjectiveFrame", bdParent)
	quest_anchor:SetSize(config.size, 50)
	quest_anchor:SetPoint("TOP", Minimap.background, "BOTTOM", 0, -50)
	bdMove:set_moveable(quest_anchor, "Objective Tracker")

	local function move_objective_tracker()
		local tracker = ObjectiveTrackerFrame
		tracker:ClearAllPoints()
		ignore_point = true
		tracker:SetPoint("TOP", quest_anchor, "TOP", 0, 0)
		ignore_point = false
	end

	local f = CreateFrame("Frame")
	f:SetScript("OnEvent",function(self, event, addon)
		if (event == "ENCOUNTER_START") then
			ObjectiveTrackerFrame:Hide()
		elseif (event == "ENCOUNTER_END") then
			ObjectiveTrackerFrame:Show()
		else
			if IsAddOnLoaded("Blizzard_ObjectiveTracker") then
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
	f:RegisterEvent("PLAYER_LOGIN")
	f:RegisterEvent("ENCOUNTER_START")
	f:RegisterEvent("ENCOUNTER_END")

end