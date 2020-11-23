local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Maps")

local function has_value(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function mod:create_button_frame()
	local config = mod.config

	-- Button frame
	Minimap.buttonFrame = CreateFrame("frame", "bdButtonFrame", Minimap)
	if (bdUI.version >= 60000) then
		Minimap.buttonFrame:RegisterEvent("GARRISON_UPDATE")
	end
	-- Minimap.buttonFrame:RegisterEvent("PLAYER_XP_UPDATE")
	-- Minimap.buttonFrame:RegisterEvent("PLAYER_LEVEL_UP")
	Minimap.buttonFrame:RegisterEvent("UPDATE_FACTION")
	Minimap.buttonFrame:RegisterEvent("UPDATE_PENDING_MAIL")
	Minimap.buttonFrame:RegisterEvent("MAIL_INBOX_UPDATE")
	Minimap.buttonFrame:RegisterEvent("MAIL_CLOSED")
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
	Minimap.buttonFrame:RegisterEvent("SHIPMENT_UPDATE");
	Minimap.buttonFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	Minimap.buttonFrame:RegisterEvent("ZONE_CHANGED");
	Minimap.buttonFrame:RegisterEvent("ZONE_CHANGED_INDOORS");
	Minimap.buttonFrame:RegisterEvent("PLAYER_ENTERING_WORLD");

	if (bdUI:get_game_version() == "shadowlands") then
		Minimap.buttonFrame:RegisterEvent("COVENANT_CALLINGS_UPDATED")
	end
	if (WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC) then
		Minimap.buttonFrame:RegisterEvent("GARRISON_MISSION_LIST_UPDATE")
	end
	Minimap.buttonFrame:RegisterEvent("LOADING_SCREEN_DISABLED")

	Minimap.buttonFrame:SetSize(Minimap.background:GetWidth() - (bdUI.border * 2), config.buttonsize)
	Minimap.buttonFrame:SetPoint("TOP", Minimap.background, "BOTTOM", bdUI.border, -bdUI.border)

	bdUI:create_fader(Minimap.buttonFrame, {}, 1, 0, .1, 0)

	-- local bdConfigButton = CreateFrame("button","bdUI_configButton", Minimap)
	-- bdConfigButton.text = bdConfigButton:CreateFontString(nil,"OVERLAY")
	-- bdConfigButton.text:SetFontObject("BDUI_SMALL")
	-- bdConfigButton.text:SetTextColor(.4,.6,1)
	-- bdConfigButton.text:SetText("bd")
	-- bdConfigButton.text:SetJustifyH("CENTER")
	-- bdConfigButton.text:SetPoint("CENTER", bdConfigButton, "CENTER", -1, -1)
	-- bdConfigButton:RegisterForClicks("AnyUp")
	-- bdConfigButton:SetScript("OnEnter", function(self) 
	-- 	self.text:SetTextColor(.6,.8,1) 
	-- 	-- ShowUIPanel(GameTooltip)
	-- 	GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 6)
	-- 	GameTooltip:AddLine(bdUI.colorString.."Config\n|cffFFAA33Left Click:|r |cff00FF00Open bdUI Config|r\n|cffFFAA33Right Click:|r |cff00FF00Toggle lock/unlock|r\n|cffFFAA33Ctrl+Click:|r |cff00FF00Reload UI|r")
	-- 	GameTooltip:Show()
	-- end)
	-- bdConfigButton:SetScript("OnLeave", function(self) 
	-- 	self.text:SetTextColor(.4,.6,1)
	-- 	GameTooltip:Hide()
	-- end)
	-- bdConfigButton:SetScript("OnClick", function(self, button)
	-- 	if (IsControlKeyDown()) then
	-- 		ReloadUI()
	-- 	end
		
	-- 	if (button == "LeftButton") then
	-- 		bdUI.bdConfig:toggle()
	-- 	elseif (button == "RightButton") then
	-- 		bdUI.bdConfig.header.lock:Click()
	-- 	end		
	-- end)

	-- Find and move buttons
	local ignoreFrames = {}
	local hideTextures = {}
	local manualTarget = {}
	local hideButtons = {}
	local frames = {}
	local last_number = 0

	MiniMapTracking:SetParent(Minimap)
	MiniMapTrackingButtonBorder:Hide()
	MiniMapTrackingButtonShine:Hide()
	MiniMapTrackingButtonShine.Show = noop
	QueueStatusMinimapButtonIcon:SetFrameLevel(50)

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
	-- reposition frames, whenever there are more or less
	local function position()
		if (config.buttonpos == "Disabled") then return end
		-- if (#frames == last_number) then return end
		last_number = #frames

		-- start loop
		local last = nil
		for k, f in pairs(frames) do
			f:ClearAllPoints()
			f:SetSize(config.buttonsize, config.buttonsize)

			if (config.buttonpos == "Top" or config.buttonpos == "Bottom") then
				if (last) then
					f:SetPoint("LEFT", last, "RIGHT", bdUI.border*3, 0)		
				else
					f:SetPoint("TOPLEFT", Minimap.buttonFrame, "TOPLEFT", 0, 0)
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
	-- skin unskinned buttons
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
					if (not has_value(frames, frame)) then
						table.insert(frames, frame)
					end
				end
			end
		end

		position()
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