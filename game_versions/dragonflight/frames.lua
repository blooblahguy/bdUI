local bdUI, c, l = unpack(select(2, ...))


MiniMapTrackingDropDown = MiniMapTrackingDropDown or MinimapCluster.Tracking.Button

-- hooksecurefunc(EditModeManagerFrame, "EnterEditMode", function(systemFrame)
-- 	bdMove:unlock()
-- end)
-- hooksecurefunc(EditModeManagerFrame, "ExitEditMode", function(systemFrame)
-- 	bdMove:lock()
-- end)
-- hooksecurefunc(EditModeManagerFrame, "RegisterSystemFrame", function(systemFrame)
-- 	for i = 1, #EditModeManagerFrame.registeredSystemFrames do
-- 		local frame = EditModeManagerFrame.registeredSystemFrames[i]
-- 		-- print(frame:GetName())
-- 		if (frame == ObjectiveTrackerFrame) then
-- 			table.remove(EditModeManagerFrame.registeredSystemFrames, i)
-- 			print("found it!")
-- 		end
-- 	end
-- end)