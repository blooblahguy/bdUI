local bdUI, c, l = unpack(select(2, ...))

local noop = function() return end
local noob = CreateFrame("frame", nil, UIParent)

--====================================================
-- VANILLA
--====================================================
if (bdUI:get_game_version() == "vanilla") then
	-- globals
	ATTACK_BUTTON_FLASH_TIME = ATTACK_BUTTON_FLASH_TIME or 0.4

	-- functions
	CanExitVehicle = CanExitVehicle or noop
	SetSortBagsRightToLeft = SetSortBagsRightToLeft or noop
	UnitGroupRolesAssigned = UnitGroupRolesAssigned or noop
	UnitThreatSituation = UnitThreatSituation or noop
	UnitCastingInfo = UnitCastingInfo or noop
	UnitChannelInfo = UnitChannelInfo or noop
	UnitAlternatePowerInfo = UnitAlternatePowerInfo or noop

	-- frames
	ChatFrameMenuButton = ChatFrameMenuButton or noob
	QuickJoinToastButton = QuickJoinToastButton or noob
	ChatFrameChannelButton = ChatFrameChannelButton or noob
	BNToastFrame = BNToastFrame or noob
	ObjectiveTrackerFrame = ObjectiveTrackerFrame or QuestWatchFrame or noob
	MiniMapInstanceDifficulty = MiniMapInstanceDifficulty or noob
	GarrisonLandingPageMinimapButton = GarrisonLandingPageMinimapButton or noob
	QueueStatusMinimapButton = QueueStatusMinimapButton or noob
	MiniMapTracking = MiniMapTracking or noob
	BagItemSearchBox = BagItemSearchBox or noob
	BagItemAutoSortButton = BagItemAutoSortButton or noob
	BankItemAutoSortButton = BankItemAutoSortButton or noob
	BankItemSearchBox = BankItemSearchBox or noob
end

--====================================================
-- TBC
--====================================================