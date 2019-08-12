local bdUI, c, l = unpack(select(2, ...))

local noop = function() return end
local noob = CreateFrame("frame", nil, UIParent)

--====================================================
-- VANILLA
--====================================================
--globals
ATTACK_BUTTON_FLASH_TIME = 0.1

-- functions
CanExitVehicle = CanExitVehicle or noop
SetSortBagsRightToLeft = SetSortBagsRightToLeft or noop
UnitGroupRolesAssigned = UnitGroupRolesAssigned or noop
UnitThreatSituation = UnitThreatSituation or noop
UnitCastingInfo = UnitCastingInfo or noop
UnitChannelInfo = UnitChannelInfo or noop

-- frames
ChatFrameMenuButton = ChatFrameMenuButton or noob
QuickJoinToastButton = QuickJoinToastButton or noob
ChatFrameChannelButton = ChatFrameChannelButton or noob
BNToastFrame = BNToastFrame or noob
ObjectiveTrackerFrame = QuestWatchFrame or noob
MiniMapInstanceDifficulty = MiniMapInstanceDifficulty or noob
GarrisonLandingPageMinimapButton = GarrisonLandingPageMinimapButton or noob
QueueStatusMinimapButton = QueueStatusMinimapButton or noob
MiniMapTracking = MiniMapTracking or noob
SpellFlyout = SpellFlyout or noob
BagItemSearchBox = BagItemSearchBox or noob
BagItemAutoSortButton = BagItemAutoSortButton or noob
BankItemAutoSortButton = BankItemAutoSortButton or noob
BankItemSearchBox = BankItemSearchBox or noob