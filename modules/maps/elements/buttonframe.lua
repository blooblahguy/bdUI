local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Maps")
local config

-- Find and move buttons
local ignoreFrames = {}
local hideTextures = {}
local manualTarget = {}
local hideButtons = {}
local frames = {}
local last_number = 0

-- target these buttons no matter where they're parented
manualTarget['CodexBrowserIcon'] = true
manualTarget['MiniMapTracking'] = true
manualTarget['HelpOpenWebTicketButton'] = true
manualTarget['MiniMapMailFrame'] = true
manualTarget['COHCMinimapButton'] = true
manualTarget['ZygorGuidesViewerMapIcon'] = true
manualTarget['MiniMapBattlefieldFrame'] = true
manualTarget['PeggledMinimapIcon'] = true
manualTarget['QueueStatusMinimapButton'] = true

-- don't touch these
ignoreFrames['bdMinimap'] = true
ignoreFrames['bdButtonFrame'] = true
ignoreFrames['MinimapBackdrop'] = true
ignoreFrames['GameTimeFrame'] = true
ignoreFrames['MinimapVoiceChatFrame'] = true
ignoreFrames['TimeManagerClockButton'] = true

-- remove these textures
hideTextures['Interface\\Minimap\\MiniMap-TrackingBorder'] = true
hideTextures['Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight'] = true
hideTextures['Interface\\Minimap\\UI-Minimap-Background'] = true 
hideTextures[136430] = true 
hideTextures[136467] = true 

--===================================
-- Position button frames
--===================================
function mod:position_button_frame()
	if (config.buttonpos == "Disabled") then return end
	-- if (#frames == last_number) then return end
	last_number = #frames

	local minimap_width = Minimap:GetWidth()
	local row_width = 0

	-- start loop
	local last = nil
	local row = nil
	for k, f in pairs(frames) do
		f:ClearAllPoints()
		f:SetScale(1 / config.scale)
		f:SetSize(config.buttonsize, config.buttonsize)

		local width = (config.buttonsize * (1 / config.scale)) + ((bdUI.border * 3) * (1 / config.scale))

		if (config.buttonpos == "Top" or config.buttonpos == "Bottom") then
			row_width = row_width + width

			if (not last) then
				f:SetPoint("TOPLEFT", Minimap.buttonFrame, "TOPLEFT", 0, 0)
				row = f
			elseif (row_width > minimap_width) then
				if (config.buttonpos == "BOTTOM") then
					f:SetPoint("BOTTOMLEFT", row, "TOPLEFT", 0, (bdUI.border * 3))
				else
					f:SetPoint("TOPLEFT", row, "BOTTOMLEFT", 0, -(bdUI.border * 3))
				end
				
				row = f
				row_width = 0
			else
				f:SetPoint("LEFT", last, "RIGHT", bdUI.border*3, 0)		
			end

		end
		if (config.buttonpos == "Right" or config.buttonpos == "Left") then
			if (last) then
				f:SetPoint("TOP", last, "BOTTOM", 0, -bdUI.border*3)		
			else
				f:SetPoint("TOPLEFT", Minimap.buttonFrame, "TOPLEFT", 0, 0)
			end
		end


		last = f
	end
end

--===================================
-- Skin button
--===================================
local function skin(f)
	if (config.buttonpos == "Disabled") then return end
	if (f.skinned) then return end

	f:SetScale(1)
	f:SetFrameStrata("MEDIUM")

	-- Skin textures
	local r = {f:GetRegions()}
	for o = 1, #r do
		if (r[o].GetTexture and r[o]:GetTexture()) then
			local tex = r[o]:GetTexture()
			r[o]:SetAllPoints(f)
			r[o]:SetDrawLayer("ARTWORK")
			if (hideTextures[tex]) then
				r[o]:Hide()
			elseif (not strfind(tex,"WHITE8x8")) then
				local coord = table.concat({r[o]:GetTexCoord()})
				if (coord == "00011011" and not f:GetName() == "MinimMapTracking") then
					r[o]:SetTexCoord(0.3, 0.7, 0.3, 0.7)
					if (n == "DugisOnOffButton") then
						r[o]:SetTexCoord(0.25, 0.75, 0.2, 0.7)								
					end
				end
			end
		end
	end
	
	-- Create background
	-- local bg = CreateFrame("button", nil, Minimap.buttonFrame)
	-- bg:SetPoint("CENTER", f)
	-- bdUI:set_backdrop(bg)
	
	-- f.bg = bg
	-- -- , "OnShow", function(self) self.bg:Show() end)
	-- hooksecurefunc(f, "OnHide", function(self) self.bg:Hide() end)
	
	bdUI:set_backdrop(f)
	f.skinned = true
end

-- find minimap frames
local function find_frames()
	if (config.buttonpos == "Disabled") then return end
	if (InCombatLockdown()) then return end

	if (not config.showconfig) then
		hideButtons['LibDBIcon10_bdUI'] = true
		if (bdUI_configButton) then
			bdUI_configButton:Hide("bdUI")
		end
		BDUI_SAVE.MinimapIcon.hide = true
	else
		hideButtons['LibDBIcon10_bdUI'] = false
		if (bdUI_configButton) then
			bdUI_configButton:Show("bdUI")
		end
		BDUI_SAVE.MinimapIcon.hide = false
	end

	if (config.hideclasshall) then
		hideButtons['GarrisonLandingPageMinimapButton'] = true
	else
		hideButtons['GarrisonLandingPageMinimapButton'] = false
	end

	if (GarrisonLandingPageMinimapButton) then
		GarrisonLandingPageMinimapButton.overlay = CreateFrame('button', nil, GarrisonLandingPageMinimapButton)
		GarrisonLandingPageMinimapButton.overlay:SetAllPoints()
		GarrisonLandingPageMinimapButton.overlay:SetFrameLevel(0)
		GarrisonLandingPageMinimapButton.overlay:SetScript("OnClick", function(self)
			GarrisonLandingPageMinimapButton:Click()			
		end)
	end

	-- start loop
	frames = {}
	local children = {Minimap:GetChildren()}
	for k, v in pairs(manualTarget) do table.insert(children, k) end

	for i = 1, #children do
		local frame = _G[children[i]] or children[i]
		local name = (frame.GetName and frame:GetName()) or _G[frame];

		if (name and not ignoreFrames[name]) then -- don't touch these
			local isLibBtn = name and (strfind(name, "LibDB") or strfind(name, "Button") or strfind(name, "Btn")) -- lib buttons should be handled
			if (hideButtons[name]) then -- move on from these
				frame:Hide()
			elseif (frame:IsShown() and (manualTarget[name] or isLibBtn)) then -- needs to be handled
				skin(frame)
				if (not tIndexOf(frames, frame)) then
					table.insert(frames, frame)
				end
			end
		end
	end

	mod:position_button_frame()
end


function mod:create_button_frame()
	config = mod.config

	-- Button frame
	Minimap.buttonFrame = CreateFrame("frame", "bdButtonFrame", UIParent)
	Minimap.buttonFrame:SetSize(1, 1)
	Minimap.buttonFrame:SetPoint("TOP", Minimap.background, "BOTTOM", bdUI.border, -bdUI.border)
	bdUI:create_fader(Minimap.buttonFrame, {}, 1, 0, .1, 0)
	
	Minimap.buttonFrame:RegisterEvent("UPDATE_FACTION")
	Minimap.buttonFrame:RegisterEvent("UPDATE_PENDING_MAIL")
	Minimap.buttonFrame:RegisterEvent("MAIL_INBOX_UPDATE")
	Minimap.buttonFrame:RegisterEvent("MAIL_CLOSED")
	if _G["GarrisonMission"] then
		Minimap.buttonFrame:RegisterEvent("GARRISON_SHOW_LANDING_PAGE");
		Minimap.buttonFrame:RegisterEvent("GARRISON_HIDE_LANDING_PAGE");
		Minimap.buttonFrame:RegisterEvent("GARRISON_BUILDING_ACTIVATABLE");
		Minimap.buttonFrame:RegisterEvent("GARRISON_BUILDING_ACTIVATED");
		Minimap.buttonFrame:RegisterEvent("GARRISON_ARCHITECT_OPENED");
		Minimap.buttonFrame:RegisterEvent("GARRISON_MISSION_FINISHED");
		Minimap.buttonFrame:RegisterEvent("GARRISON_MISSION_NPC_OPENED");
		Minimap.buttonFrame:RegisterEvent("GARRISON_SHIPYARD_NPC_OPENED");
		Minimap.buttonFrame:RegisterEvent("GARRISON_INVASION_AVAILABLE");
		Minimap.buttonFrame:RegisterEvent("GARRISON_INVASION_UNAVAILABLE");
		Minimap.buttonFrame:RegisterEvent("GARRISON_MISSION_LIST_UPDATE")
		Minimap.buttonFrame:RegisterEvent("SHIPMENT_UPDATE");
	end
	Minimap.buttonFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	Minimap.buttonFrame:RegisterEvent("ZONE_CHANGED");
	Minimap.buttonFrame:RegisterEvent("ZONE_CHANGED_INDOORS");
	Minimap.buttonFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
	Minimap.buttonFrame:RegisterEvent("LOADING_SCREEN_DISABLED")

	if (bdUI.version >= 60000) then
		Minimap.buttonFrame:RegisterEvent("GARRISON_UPDATE")
	end
	if (_G["CovenantCallingQuestMixin"]) then
		Minimap.buttonFrame:RegisterEvent("COVENANT_CALLINGS_UPDATED")
	end

	-- Updater script
	local total = 0
	Minimap.buttonFrame:SetScript("OnEvent", find_frames)
	Minimap.buttonFrame:SetScript("OnUpdate", function(self, elapsed)
		total = total + elapsed
		if (total > 5) then
			total = 0
			find_frames()
		end
	end)
end