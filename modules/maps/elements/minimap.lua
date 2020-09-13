local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Maps")
local config
--easier to change in the future if more minimap types want to be supported
local rectangleFileLocation = "Interface\\Addons\\bdUI\\media\\rectangle.tga"

function mod:config_callback()
	config = mod.config
	if (not config.enabled) then return false end

	-- show/hide time
	if not IsAddOnLoaded("Blizzard_TimeManager") then
		LoadAddOn('Blizzard_TimeManager')
	end
	if (config.showtime) then
		TimeManagerClockButton:SetAlpha(1)
		TimeManagerClockButton:Show()
	else
		TimeManagerClockButton:SetAlpha(0)
		TimeManagerClockButton:Hide()
	end

	-- Minimap Shape
	function GetMinimapShape() return "SQUARE" end
	if (config.shape == "Rectangle") then
		Minimap:SetMaskTexture(rectangleFileLocation)
		Minimap.background:SetSize(config.size, config.size*.75)

		local inset = ((config.size * .25) / 2)
		Minimap:SetHitRectInsets(0, 0, -inset, inset)
		Minimap:SetClampRectInsets(0, 0, -inset, inset)

		Minimap:SetSize(config.size, config.size)
	else
		Minimap:SetMaskTexture(bdUI.media.flat)
		Minimap.background:SetSize(config.size, config.size)
		Minimap:SetSize(config.size, config.size)
		Minimap:SetHitRectInsets(0, 0, 0, 0)
		Minimap:SetClampRectInsets(0, 0, 0, 0)
	end

	-- Button Frame positioning
	if (config.buttonpos == "Disable") then
		Minimap.buttonFrame:ClearAllPoints()
		Minimap.buttonFrame:Hide()
	else 
		Minimap.buttonFrame:ClearAllPoints()

		local space = bdUI.border * 2
		local size = config.buttonsize + space

		if (config.buttonpos == "Top") then
			Minimap.buttonFrame:SetPoint("BOTTOMLEFT", Minimap.background, "TOPLEFT", bdUI.border, space)
			Minimap.buttonFrame:SetPoint("TOPRIGHT", Minimap.background, "TOPRIGHT", -bdUI.border, size)
		elseif (config.buttonpos == "Right") then
			Minimap.buttonFrame:SetPoint("TOPLEFT", Minimap.background, "TOPRIGHT", space, -bdUI.border)
			Minimap.buttonFrame:SetPoint("BOTTOMRIGHT", Minimap.background, "BOTTOMRIGHT", size, bdUI.border)
		elseif (config.buttonpos == "Bottom") then
			Minimap.buttonFrame:SetPoint("TOPLEFT", Minimap.background, "BOTTOMLEFT", bdUI.border, -space)
			Minimap.buttonFrame:SetPoint("BOTTOMRIGHT", Minimap.background, "BOTTOMRIGHT", -bdUI.border, -size)
		elseif (config.buttonpos == "Left") then
			Minimap.buttonFrame:SetPoint("TOPRIGHT", Minimap.background, "TOPLEFT", -space, -bdUI.border)
			Minimap.buttonFrame:SetPoint("BOTTOMLEFT", Minimap.background, "BOTTOMLEFT", -size, bdUI.border)
		end
	end
end

function mod:create_minimap()
	config = mod:get_save()

	Minimap.background = CreateFrame("frame", "bdMinimap", Minimap, BackdropTemplateMixin and "BackdropTemplate")
	local inset = ((config.size * .25) / 2)
	Minimap.background:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -inset, -inset)
	Minimap.background:SetBackdrop({bgFile = bdUI.media.flat, edgeFile = bdUI.media.flat, edgeSize = bdUI.border})
	Minimap.background:SetBackdropColor(0,0,0,0)
	Minimap.background:SetBackdropBorderColor(unpack(bdUI.media.border))
	Minimap:EnableMouse(true)
	Minimap:SetMaskTexture(rectangleFileLocation)
	Minimap.SetArchBlobRingScalar = Minimap.SetArchBlobRingScalar or noop
	Minimap.SetQuestBlobRingScalar = Minimap.SetQuestBlobRingScalar or noop
	Minimap:SetArchBlobRingScalar(0);
	Minimap:SetQuestBlobRingScalar(0);
	Minimap:ClearAllPoints()
	Minimap:SetPoint("CENTER", Minimap.background, "CENTER", 0, 0)
	Minimap:RegisterEvent("ADDON_LOADED")
	Minimap:RegisterEvent("PLAYER_ENTERING_WORLD")
	Minimap:RegisterEvent("LOADING_SCREEN_DISABLED")
	Minimap:EnableMouseWheel(true)
	Minimap:SetScript('OnMouseWheel', function(self, delta)
		local action = delta > 0 and MinimapZoomIn:Click()
		local action = delta < 0 and MinimapZoomOut:Click()
	end)

	Minimap:SetScript('OnMouseUp', function (self, button)
		if button == 'RightButton' and bdUI:get_game_version() == "vanilla" then
			ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, Minimap.background, (Minimap:GetWidth()), (Minimap.background:GetHeight()-2))
			GameTooltip:Hide()
		elseif (button == 'MiddleButton') then
			if not IsAddOnLoaded("Blizzard_Calendar") then
				LoadAddOn('Blizzard_Calendar')
			end
			Calendar_Toggle = Calendar_Toggle or noop
			Calendar_Toggle()
		else
			Minimap_OnClick(self)
		end
	end)

	bdMove:set_moveable(Minimap.background)

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

	MinimapCluster:EnableMouse(false)
	MiniMapInstanceDifficulty:ClearAllPoints()
	MiniMapInstanceDifficulty:SetPoint("TOPRIGHT", Minimap.background, "TOPRIGHT", -2, -2)
	GarrisonLandingPageMinimapButton:SetParent(Minimap)
	QueueStatusMinimapButton:SetParent(Minimap)

	function dropdownOnClick(self)
		GameTooltip:Hide()
		DropDownList1:ClearAllPoints()
		DropDownList1:SetPoint('TOPLEFT', Minimap.background, 'TOPRIGHT', 2, 0)
	end

	MiniMapMailIcon:SetTexture(nil)
	MiniMapMailFrame.mail = MiniMapMailFrame:CreateFontString(nil,"OVERLAY")
	MiniMapMailFrame.mail:SetFontObject("BDUI_MEDIUM")
	MiniMapMailFrame.mail:SetText("M")
	MiniMapMailFrame.mail:SetJustifyH("CENTER")
	MiniMapMailFrame.mail:SetPoint("CENTER", MiniMapMailFrame, "CENTER", 1, -1)
	MiniMapMailFrame:RegisterEvent("UPDATE_PENDING_MAIL")
	MiniMapMailFrame:RegisterEvent("MAIL_INBOX_UPDATE")
	MiniMapMailFrame:RegisterEvent("MAIL_CLOSED")
	MiniMapMailBorder:Hide()

	if not IsAddOnLoaded("Blizzard_TimeManager") then
		LoadAddOn('Blizzard_TimeManager')
	end
	select(1, TimeManagerClockButton:GetRegions()):Hide()
	TimeManagerClockButton:ClearAllPoints()
	TimeManagerClockButton:SetPoint("BOTTOMLEFT", Minimap.background, "BOTTOMLEFT",5,-2)
	TimeManagerClockTicker:SetFontObject("BDUI_MEDIUM")
	TimeManagerClockTicker:SetAllPoints(TimeManagerClockButton)
	TimeManagerClockTicker:SetJustifyH('LEFT')
	TimeManagerClockTicker:SetShadowColor(0,0,0,0)

	TicketStatusFrame:ClearAllPoints()
	TicketStatusFrame:SetPoint("TOP", UIParent, "TOP", 0, -20)

	-- zone
	mod:zone()
	-- difficulty
	mod:difficulty()
end
--================================================
-- Zone
--================================================
function mod:zone()
	-- Zone
	Minimap.zone = CreateFrame("frame", nil, Minimap)
	Minimap.zone:Hide()
	Minimap.zone.text = Minimap.zone:CreateFontString(nil)
	Minimap.zone.text:SetFontObject("BDUI_MEDIUM")
	Minimap.zone.text:SetPoint("TOPLEFT", Minimap.background, "TOPLEFT", 8, -8)
	Minimap.zone.text:SetJustifyH("LEFT")
	Minimap.zone.subtext = Minimap.zone:CreateFontString(nil)
	Minimap.zone.subtext:SetFontObject("BDUI_MEDIUM")
	Minimap.zone.subtext:SetPoint("TOPRIGHT", Minimap.background, "TOPRIGHT", -8, -8)
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
end

--================================================
-- Difficulty
--================================================
function mod:difficulty()
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
	rdt:SetPoint("BOTTOMRIGHT", Minimap.background, "BOTTOMRIGHT", -4, 6)
	rdt:SetFontObject("BDUI_MEDIUM")
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
end
