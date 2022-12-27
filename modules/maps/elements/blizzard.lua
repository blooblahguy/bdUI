local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Maps")

function mod:minimap_blizzard_elements()
	local config = mod:get_save()
	-- mousewheel scroll
	if (bdUI.version < 100000) then
		Minimap:EnableMouseWheel(true)
		Minimap:SetScript('OnMouseWheel', function(self, delta)
			local action = delta > 0 and MinimapZoomIn:Click()
			local action = delta < 0 and MinimapZoomOut:Click()
		end)
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
	if (MiniMapMailBorder) then
		MiniMapMailBorder:Hide()	
	end

	--===========================
	-- Time Manager
	--===========================
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
	-- click tracking and calendar
	--===========================
	Minimap.ClickFunc = Minimap:GetScript("OnMouseUp")
	Minimap:SetScript('OnMouseUp', function (self, button)
		if button == 'RightButton' then
			local tracking = MinimapCluster.Tracking and MinimapCluster.Tracking.DropDown or MiniMapTrackingDropDown
			ToggleDropDownMenu(1, nil, tracking, Minimap, -config.size / 1.5, config.size * 0.93)
			GameTooltip:Hide()
		elseif (button == 'MiddleButton') then
			Calendar_Toggle = Calendar_Toggle or noop
			Calendar_Toggle()
		else
			Minimap.ClickFunc(self)
		end
	end)
end