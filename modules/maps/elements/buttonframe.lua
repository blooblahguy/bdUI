local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Minimap")


function mod:create_button_frame()
	local config = mod._config

	-- Button frame
	Minimap.buttonFrame = CreateFrame("frame", "bdButtonFrame", Minimap)
	Minimap.buttonFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	Minimap.buttonFrame:RegisterEvent("GARRISON_UPDATE")
	Minimap.buttonFrame:RegisterEvent("PLAYER_XP_UPDATE")
	Minimap.buttonFrame:RegisterEvent("PLAYER_LEVEL_UP")
	Minimap.buttonFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	Minimap.buttonFrame:RegisterEvent("UPDATE_FACTION")
	Minimap.buttonFrame:SetSize(Minimap.background:GetWidth() - (bdUI.border * 2), config.buttonsize)
	Minimap.buttonFrame:SetPoint("TOP", Minimap.background, "BOTTOM", bdUI.border, -bdUI.border)

	local bdConfigButton = CreateFrame("button","bdUI_configButton", Minimap)
	bdConfigButton.text = bdConfigButton:CreateFontString(nil,"OVERLAY")
	bdConfigButton.text:SetFontObject("BDUI_SMALL")
	bdConfigButton.text:SetTextColor(.4,.6,1)
	bdConfigButton.text:SetText("bd")
	bdConfigButton.text:SetJustifyH("CENTER")
	bdConfigButton.text:SetPoint("CENTER", bdConfigButton, "CENTER", -1, -1)
	bdConfigButton:SetScript("OnEnter", function(self) 
		self.text:SetTextColor(.6,.8,1) 
		ShowUIPanel(GameTooltip)
		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 6)
		GameTooltip:AddLine("Big Dumb Config")
		GameTooltip:Show()
	end)
	bdConfigButton:SetScript("OnLeave", function(self) 
		self.text:SetTextColor(.4,.6,1) 
		GameTooltip:Hide()
	end)
	bdConfigButton:SetScript("OnClick", function() bdUI.config_instance:toggle() end)

	-- Find and move buttons
	local ignoreFrames = {}
	local hideTextures = {}
	local manualTarget = {}
	local frames = {}
	local numChildren = 0

	MiniMapTracking:SetParent(Minimap)
	manualTarget['MiniMapTracking'] = true
	manualTarget['MiniMapMailFrame'] = true
	manualTarget['COHCMinimapButton'] = true
	manualTarget['ZygorGuidesViewerMapIcon'] = true
	manualTarget['MiniMapBattlefieldFrame'] = true

	ignoreFrames['bdButtonFrame'] = true
	ignoreFrames['MinimapBackdrop'] = true
	ignoreFrames['GameTimeFrame'] = true
	ignoreFrames['MinimapVoiceChatFrame'] = true
	ignoreFrames['TimeManagerClockButton'] = true

	hideTextures['Interface\\Minimap\\MiniMap-TrackingBorder'] = true
	hideTextures['Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight'] = true
	hideTextures['Interface\\Minimap\\UI-Minimap-Background'] = true

	--===================================
	-- Position buttons
	--===================================
	local function size_move()
		local last = nil
		
		for k, f in pairs(frames) do
			f:SetWidth(config.buttonsize)
			f:SetHeight(config.buttonsize)
			f:ClearAllPoints()

			f:ClearAllPoints()
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
	--===================================
	local function skin(f)
		if (f.skinned) then return end

		f:SetScale(1)
		f.SetSize = bdUI.noop
		f.SetWidth = bdUI.noop
		f.SetHeight = bdUI.noop
		f:SetParent(Minimap.buttonFrame)
		f:SetFrameStrata("MEDIUM")
		f:Show()

		-- Skin textures
		local r = {f:GetRegions()}
		for o = 1, #r do
			if (r[o].GetTexture and r[o]:GetTexture()) then
				local tex = r[o]:GetTexture()
				r[o]:SetAllPoints(f)
				if (hideTextures[tex]) then
					r[o]:Hide()
				elseif (not strfind(tex,"WHITE8x8")) then
					local coord = table.concat({r[o]:GetTexCoord()})
					if (coord == "00011011") then
						r[o]:SetTexCoord(0.3, 0.7, 0.3, 0.7)
						if (n == "DugisOnOffButton") then
							r[o]:SetTexCoord(0.25, 0.75, 0.2, 0.7)								
						end
					end
				end
			end
		end
		
		-- Create background
		f.bdbackground = f.bdbackground or CreateFrame("frame",nil,f)
		f.bdbackground:SetAllPoints(f)
		f.bdbackground:SetFrameStrata("BACKGROUND")
		bdUI:set_backdrop(f.bdbackground)
		f:SetHitRectInsets(0, 0, 0, 0)
		f:HookScript("OnEnter",function(self)
			local newlines = {}
			for l = 1, 10 do
				local line = _G["GameTooltipTextLeft"..l]
				if (line and line:GetText()) then
					newlines[line:GetText()] = true
				end
			end
			
			GameTooltip:Hide()
			GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 6)
			for k, v in pairs(newlines) do
				GameTooltip:AddLine(k)
			end
			GameTooltip:Show()
		end)

		f.skinned = true
	end

	
	local function move_buttons()
		if (InCombatLockdown()) then return end
		
		local c = {Minimap.buttonFrame:GetChildren()}
		local d = {Minimap:GetChildren()}

		if (#d ~= numChildren) then
			numChildren = #d
			frames = {}

			for k, v in pairs(d) do table.insert(c,v) end
			local last = nil
			for i = 1, #c do
				local f = c[i]
				local n = f:GetName() or "";
				if ((manualTarget[n] and f:IsShown() ) or (
					f:GetName() and 
					f:IsShown() and 
					(strfind(n, "LibDB") or strfind(n, "Button") or strfind(n, "Btn")) and 
					not ignoreFrames[n]
				)) then
					skin(f)
					frames[i] = f
				end
			end
		end

		size_move()
	end

	-- Updater script
	local total = 0
	Minimap.buttonFrame:SetScript("OnEvent",moveMinimapButtons)
	Minimap.buttonFrame:SetScript("OnUpdate", function(self, elapsed)
		total = total + elapsed
		if (total > .5) then
			total = 0
			if (not InCombatLockdown()) then
				move_buttons()
			end
		end
	end)
end