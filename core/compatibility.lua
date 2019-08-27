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
	UnitHasVehicleUI = UnitHasVehicleUI or noop
	UnitCastingInfo = UnitCastingInfo or CastingInfo
	UnitChannelInfo = UnitChannelInfo or ChannelInfo
	UnitAlternatePowerInfo = UnitAlternatePowerInfo or noop
	GetSpecialization = GetSpecialization or noop
	CanExitVehicle = CanExitVehicle or noop
	GetGuildBankWithdrawMoney = GetGuildBankWithdrawMoney or function() return 0 end

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
	ReagentBankFrame = ReagentBankFrame or noob

	-- library for spell durations
	-- bdUI.spell_durations = LibStub("LibClassicDurations")
    -- bdUI.spell_durations:Register("bdUI")

	function bdUI:update_duration(cd_frame, unit, spellID, caster, duration, expiration)
		if (bdUI.spell_durations) then
			local durationNew, expirationTimeNew = bdUI.spell_durations:GetAuraDurationByUnit(unit, spellID, caster)
			if duration == 0 and durationNew then
				duration = durationNew
				expirationTime = expirationTimeNew
			end

			local enabled = expirationTime and expirationTime ~= 0;
			if enabled then
				local startTime = expirationTime - duration;
				CooldownFrame_Set(cd_frame, startTime, duration, true);
			else
				CooldownFrame_Clear(cd_frame);
			end
		end

		return duration, expiration
	end
end

--====================================================
-- TBC
--====================================================