local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Maps")
local config

function mod:position_minimap()
	config = mod:get_save()

	-- scale things
	Minimap:SetScale(config.scale)
	Minimap:SetSize(config.size, config.size)
	mod.Minimap:SetSize(config.size * config.scale, config.size * config.scale)

	-- snap back to our parent
	Minimap:ClearAllPoints()
	Minimap:SetPoint("BOTTOMLEFT", mod.Minimap)
	Minimap:SetPoint("TOPRIGHT", mod.Minimap)

	-- move the cluster, too
	MinimapCluster:ClearAllPoints()
	MinimapCluster:SetPoint("BOTTOMLEFT", mod.Minimap)
	MinimapCluster:SetPoint("TOPRIGHT", mod.Minimap)
end

function mod:create_minimap()
	config = mod:get_save()

	local inset = ((config.size * .25) / 2)
	GetMinimapShape = function() return "SQUARE" end

	--==========================
	-- Minimap
	--==========================
	local bdMinimap = CreateFrame("frame", "bdMinimap", UIParent, BackdropTemplateMixin and "BackdropTemplate")
	bdMinimap:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -inset, -inset)
	bdMinimap:SetSize(config.size, config.size)
	bdMinimap:SetBackdrop({bgFile = bdUI.media.flat, edgeFile = bdUI.media.flat, edgeSize = bdUI.border})
	bdMinimap:SetBackdropColor(0,0,0,0)
	bdMinimap:SetBackdropBorderColor(unpack(bdUI.media.border))
	bdMove:set_moveable(bdMinimap)
	mod.Minimap = bdMinimap

	if (MinimapCluster.SetHeaderUnderneath) then
		hooksecurefunc(MinimapCluster, "SetHeaderUnderneath", mod.position_minimap)
		hooksecurefunc(EditModeManagerFrame, "EnterEditMode", mod.position_minimap)
		hooksecurefunc(EditModeManagerFrame, "ExitEditMode", mod.position_minimap)
	end
	mod:position_minimap()

	-- mousewheel scroll
	Minimap:EnableMouseWheel(true)
	Minimap:SetScript('OnMouseWheel', function(self, delta)
		local action = delta > 0 and MinimapZoomIn:Click()
		local action = delta < 0 and MinimapZoomOut:Click()
	end)

	-- click tracking and calendar
	Minimap.ClickFunc = Minimap:GetScript("OnMouseUp")
	Minimap:SetScript('OnMouseUp', function (self, button)
		if button == 'RightButton' then
			local tracking = MinimapCluster.Tracking and MinimapCluster.Tracking.DropDown or MiniMapTrackingDropDown
			ToggleDropDownMenu(1, nil, tracking, Minimap, -config.size / 1.5, config.size * 0.93)
			GameTooltip:Hide()
		elseif (button == 'MiddleButton') then
			if not IsAddOnLoaded("Blizzard_Calendar") then
				LoadAddOn('Blizzard_Calendar')
			end
			Calendar_Toggle = Calendar_Toggle or noop
			Calendar_Toggle()
		else
			Minimap.ClickFunc(self)
		end
	end)
	
	-- fixes texture issue with non round minimaps
	Minimap:EnableMouse(true)
	if (Minimap.SetQuestBlobRingAlpha) then	
		Minimap:SetQuestBlobRingAlpha(0)
	end
	if (Minimap.SetArchBlobRingAlpha) then	
		Minimap:SetArchBlobRingAlpha(0)
	end
	if (Minimap.SetArchBlobRingScalar) then	
		Minimap:SetArchBlobRingScalar(0)
	end
	if (Minimap.SetQuestBlobRingScalar) then	
		Minimap:SetQuestBlobRingScalar(0)
	end
	MinimapCluster:EnableMouse(false)
	if (MiniMapInstanceDifficulty) then
		MiniMapInstanceDifficulty:ClearAllPoints()
		MiniMapInstanceDifficulty:SetPoint("TOPRIGHT", bdMinimap, "TOPRIGHT", -2, -2)
	end

	--========================
	-- Skin
	--========================
	local frames = {
		"MiniMapVoiceChatFrame", -- out in BFA
		"MiniMapWorldMapButton",
		"MinimapZoneTextButton",
		"MiniMapMailBorder",
		"MiniMapInstanceDifficulty",
		"MinimapNorthTag",
		"MinimapZoomOut",
		"MinimapZoomIn",
		"MinimapBackdrop",
		"GameTimeFrame",
		"GuildInstanceDifficulty",
		"MiniMapChallengeMode",
		"MinimapBorderTop",
		"MinimapBorder",
		"MinimapToggleButton",
	}
	for i = 1, #frames do
		if (_G[frames[i]]) then
			_G[frames[i]]:Hide()
			_G[frames[i]].Show = noop
		end
	end

	-- ButtonFrame stuff
	if (GarrisonLandingPageMinimapButton) then
		GarrisonLandingPageMinimapButton:SetParent(Minimap)
	end
	if (QueueStatusMinimapButton) then
		QueueStatusMinimapButton:SetParent(Minimap)
		QueueStatusMinimapButtonIcon:SetFrameLevel(50)
	end
	if (MiniMapTracking) then
		MiniMapTracking:SetParent(Minimap)
	end
	if (MiniMapTrackingButtonBorder) then
		MiniMapTrackingButtonBorder:Hide()
		MiniMapTrackingButtonShine:Hide()
		MiniMapTrackingButtonShine.Show = noop
	end

	--===========================
	-- Mail
	--===========================
	MiniMapMailIcon:SetTexture(nil)
	local frame = MiniMapMailFrame or MailFrame
	frame.mail = frame:CreateFontString(nil,"OVERLAY")
	frame.mail:SetFontObject(bdUI:get_font(13))
	frame.mail:SetText("M")
	frame.mail:SetJustifyH("CENTER")
	frame.mail:SetPoint("CENTER", frame, "CENTER", 1, -1)
	frame:RegisterEvent("UPDATE_PENDING_MAIL")
	frame:RegisterEvent("MAIL_INBOX_UPDATE")
	frame:RegisterEvent("MAIL_CLOSED")
	-- MiniMapMailBorder:Hide()


	--===========================
	-- Zone
	--===========================
	MinimapZoneText:Hide()
	MinimapZoneText:EnableMouse(false)
	MinimapCluster.BorderTop:Hide()
	MinimapCluster.BorderTop:EnableMouse(false)
	MinimapCluster.Tracking:Hide()
	MinimapCluster.Tracking:EnableMouse(false)
	MinimapCluster.ZoneTextButton:Hide()
	MinimapCluster.ZoneTextButton:EnableMouse(false)
	Minimap.zone = CreateFrame("frame", nil, Minimap)
	Minimap.zone:Hide()
	Minimap.zone.text = Minimap.zone:CreateFontString(nil)
	Minimap.zone.text:SetFontObject(bdUI:get_font(13))
	Minimap.zone.text:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 8, -8)
	Minimap.zone.text:SetJustifyH("LEFT")
	Minimap.zone.subtext = Minimap.zone:CreateFontString(nil)
	Minimap.zone.subtext:SetFontObject(bdUI:get_font(13))
	Minimap.zone.subtext:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", -8, -8)
	Minimap.zone.subtext:SetJustifyH("RIGHT")
	Minimap.zone:RegisterEvent("ZONE_CHANGED")
	Minimap.zone:RegisterEvent("ZONE_CHANGED_INDOORS")
	Minimap.zone:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	Minimap.zone:RegisterEvent("PLAYER_ENTERING_WORLD")
	Minimap.zone:SetScript("OnEvent", function(self, event)
		Minimap.zone.text:SetText(GetZoneText())
		Minimap.zone.subtext:SetText(GetSubZoneText())
	end)
	Minimap:SetScript("OnEnter", function()
		Minimap.zone:Show()
	end)
	Minimap:SetScript("OnLeave", function()
		Minimap.zone:Hide()
	end)

	--===========================
	-- Time Manager
	--===========================
	if not IsAddOnLoaded("Blizzard_TimeManager") then
		LoadAddOn('Blizzard_TimeManager')
	end
	select(1, TimeManagerClockButton:GetRegions()):Hide()
	TimeManagerClockButton:ClearAllPoints()
	TimeManagerClockButton:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT",5,-2)
	TimeManagerClockTicker:SetFontObject(bdUI:get_font(13))
	TimeManagerClockTicker:SetAllPoints(TimeManagerClockButton)
	TimeManagerClockTicker:SetJustifyH('LEFT')
	TimeManagerClockTicker:SetShadowColor(0,0,0,0)

	TicketStatusFrame:ClearAllPoints()
	TicketStatusFrame:SetPoint("TOP", UIParent, "TOP", 0, -20)

	--===========================
	-- Difficulty
	--===========================
	local difftext = {}
	local rd = CreateFrame("Frame", nil, Minimap)
	rd:SetSize(24, 8)
	rd:EnableMouse(false)
	rd:RegisterEvent("PLAYER_ENTERING_WORLD")
	if (bdUI.version >= 50000) then
		rd:RegisterEvent("CHALLENGE_MODE_START")
		rd:RegisterEvent("CHALLENGE_MODE_COMPLETED")
		rd:RegisterEvent("CHALLENGE_MODE_RESET")
		rd:RegisterEvent("PLAYER_DIFFICULTY_CHANGED")
	end
	rd:RegisterEvent("GUILD_PARTY_STATE_UPDATED")
	rd:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	local rdt = rd:CreateFontString(nil, "OVERLAY")
	rdt:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", -4, 6)
	rdt:SetFontObject(bdUI:get_font(13))
	rdt:SetJustifyH("RIGHT")
	rdt:SetTextColor(.7,.7,.7)
	rd:SetScript("OnEvent", function()
		local difficulty = select(3, GetInstanceInfo())
		local numplayers = select(9, GetInstanceInfo())
		local mplusdiff = C_ChallengeMode and select(1, C_ChallengeMode.GetActiveKeystoneInfo()) or "";

		if (difficulty == 1) then
			rdt:SetText("5")
		elseif difficulty == 2 then
			rdt:SetText("5H")
		elseif difficulty == 3 then
			rdt:SetText("10")
		elseif difficulty == 4 then
			rdt:SetText("25")
		elseif difficulty == 5 then
			rdt:SetText("10H")
		elseif difficulty == 6 then
			rdt:SetText("25H")
		elseif difficulty == 7 then
			rdt:SetText("LFR")
		elseif difficulty == 8 then
			rdt:SetText("M+"..mplusdiff)
		elseif difficulty == 9 then
			rdt:SetText("40")
		elseif difficulty == 11 then
			rdt:SetText("HScen")
		elseif difficulty == 12 then
			rdt:SetText("Scen")
		elseif difficulty == 14 then
			rdt:SetText("N:"..numplayers)
		elseif difficulty == 15 then
			rdt:SetText("H:"..numplayers)
		elseif difficulty == 16 then
			rdt:SetText("M")
		elseif difficulty == 17 then
			rdt:SetText("LFR:"..numplayers)
		elseif difficulty == 23 then
			rdt:SetText("M+")
		elseif difficulty == 24 then
			rdt:SetText("TW")
		else
			rdt:SetText("")
		end
	end)

	Minimap.rd = rd
end