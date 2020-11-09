local bdUI, c, l = unpack(select(2, ...))

local noop = function() return end
local noob = CreateFrame("frame", nil, UIParent)

--====================================================
-- VANILLA
--====================================================
if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
	-- globals
	ATTACK_BUTTON_FLASH_TIME = ATTACK_BUTTON_FLASH_TIME or 0.4

	-- functions
	CanExitVehicle = CanExitVehicle or noop
	SetSortBagsRightToLeft = SetSortBagsRightToLeft or noop
	UnitGroupRolesAssigned = UnitGroupRolesAssigned or noop
	UnitThreatSituation = UnitThreatSituation or noop
	UnitHasVehicleUI = UnitHasVehicleUI or noop
	UnitCastingInfo = UnitCastingInfo or CastingInfo
	UnitChannelInfo = UnitChannelInfo or ChannelInfo
	UnitAlternatePowerInfo = UnitAlternatePowerInfo or noop
	GetSpecialization = GetSpecialization or noop
	CanExitVehicle = CanExitVehicle or noop
	SortBags = SortBags or noop
	GetGuildBankWithdrawMoney = GetGuildBankWithdrawMoney or function() return 0 end

	-- frames
	TalentMicroButtonAlert = TalentMicroButtonAlert or noob
	ChatFrameMenuButton = ChatFrameMenuButton or noob
	QuickJoinToastButton = QuickJoinToastButton or noob
	ChatFrameChannelButton = ChatFrameChannelButton or noob
	BNToastFrame = BNToastFrame or noob
	ObjectiveTrackerFrame = ObjectiveTrackerFrame or QuestWatchFrame or noob
	MiniMapInstanceDifficulty = MiniMapInstanceDifficulty or noob
	GarrisonLandingPageMinimapButton = GarrisonLandingPageMinimapButton or noob
	QueueStatusMinimapButton = QueueStatusMinimapButton or noob
	MiniMapTracking = MiniMapTracking or MiniMapTrackingFrame or noob
	BagItemSearchBox = BagItemSearchBox or noob
	BagItemAutoSortButton = BagItemAutoSortButton or noob
	BankItemAutoSortButton = BankItemAutoSortButton or noob
	BankItemSearchBox = BankItemSearchBox or noob
	ReagentBankFrame = ReagentBankFrame or noob
	BankFrameMoneyFrameInset = BankFrameMoneyFrameInset or noob
	BackpackTokenFrame = BackpackTokenFrame or noob
	BankFrameCloseButton = BankFrameCloseButton or noob
	CharacterMicroButtonAlert = CharacterMicroButtonAlert or noob
	TalentMicroButtonAlert = TalentMicroButtonAlert or noob
	MiniMapTrackingButtonBorder = MiniMapTrackingButtonBorder or noob
	MiniMapTrackingButtonShine = MiniMapTrackingButtonShine or noob
	QueueStatusMinimapButton = QueueStatusMinimapButton or noob
	QueueStatusMinimapButtonIcon = QueueStatusMinimapButtonIcon or noob

	-- threat functions
	local threatcolors = {
		[0] = {0.69, 0.69, 0.69},
		[1] = {1, 1, 0.47},
		[2] = {1, 0.6, 0},
		[3] = {1, 0, 0},
	}
	function GetThreatStatusColor(level)
		return unpack(threatcolors[level])
	end

	Enum.PvPUnitClassification = Enum.PvPUnitClassification or {}
	Enum.SummonStatus = Enum.SummonStatus or {}
end

--====================================================
-- TBC
--====================================================