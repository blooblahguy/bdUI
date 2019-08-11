local bdUI, c, l = unpack(select(2, ...))

local noop = function() return end
local noob = CreateFrame("frame", nil, UIParent)

--====================================================
-- VANILLA
--====================================================
-- functions
CanExitVehicle = CanExitVehicle or noop
SetSortBagsRightToLeft = SetSortBagsRightToLeft or noop

-- frames
ChatFrameMenuButton = ChatFrameMenuButton or noob
QuickJoinToastButton = QuickJoinToastButton or noob
ChatFrameChannelButton = ChatFrameChannelButton or noob
BNToastFrame = BNToastFrame or noob
ObjectiveTrackerFrame = ObjectiveTrackerFrame or noob
MiniMapInstanceDifficulty = MiniMapInstanceDifficulty or noob
GarrisonLandingPageMinimapButton = GarrisonLandingPageMinimapButton or noob
QueueStatusMinimapButton = QueueStatusMinimapButton or noob
MiniMapTracking = MiniMapTracking or noob