--===============================================
-- FUNCTIONS
--===============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Actionbars")
mod.frame = CreateFrame("frame", nil, bdParent)
mod.bars = {}
local v = mod.variables
local c = {}

--===============================================
-- Core functionality
-- place core functionality here
--===============================================
function mod:initialize()
	c = mod:get_save()
	if (not c.enabled) then mod.disabled = true; return end
	
	mod:remove_blizzard()

	-- Main bars
	mod:create_actionbar1()
	mod:create_actionbar2()
	mod:create_actionbar3()
	mod:create_actionbar4()
	mod:create_actionbar5()

	-- -- Extra bars
	mod:create_petbar()
	mod:create_stancebar()
	mod:create_micromenu()
	mod:create_bagbar()
	mod:create_vehicle()
	mod:create_possess()
	mod:create_extra()

	-- Flyout
	mod:hook_flyout()

	-- Callback events for leaving combat
	mod.frame:SetScript("OnEvent", mod.callback)
end

--=======================================
-- Primary Configuration callback
--=======================================
function mod:config_callback()
	c = mod:get_save()
	if (InCombatLockdown()) then
		mod:RegisterEvent("PLAYER_REGEN_DISABLED")
		return
	end
	
	mod:UnregisterEvent("PLAYER_REGEN_DISABLED")
	mod.variables.font:SetFont(bdUI.media.font, c.font_size, "OUTLINE")

	-- loop through bar callbacks
	for k, callback in pairs(mod.variables.callbacks) do
		callback()
	end
end

local function HideKeybinds(frame)
	local hide = frame.hidehotkeys and not IsMouseOverFrame(frame)

	for i, button in pairs(frame.buttonList) do
		local hotkey = _G[button:GetName().."HotKey"]
		if (hotkey) then
			local text = hotkey:GetText()
			if (hide or not text or not text:match("[%a%d]")) then
				hotkey:Hide()
			else
				hotkey:Show()
			end
		end
	end
end

--=======================================
-- Create Bars main function
--=======================================
function mod:CreateBar(buttonList, cfg)
	local frame = CreateFrame("Frame", cfg.frameName, UIParent, "SecureHandlerStateTemplate")
	frame:SetPoint(unpack(cfg.frameSpawn))
	frame.__blizzardBar = cfg.blizzardBar
	frame.buttonList = buttonList

	-- hide hotkeys based on mousing over full bar
	frame:HookScript("OnEnter", HideKeybinds)
	frame:HookScript("OnLeave", HideKeybinds)

	-- hook into configuration changes
	table.insert(mod.variables.callbacks, function() 
		mod:LayoutBar(frame, buttonList, cfg) 
	end)
	if (cfg.callback) then
		table.insert(mod.variables.callbacks, cfg.callback)
	end

	-- Layout the buttons using the config options
	mod:LayoutBar(frame, buttonList, cfg)
	if (cfg.callback) then
		cfg:callback(frame)
	end

	-- Moveable
	bdMove:set_moveable(frame, cfg.moveName)

	--reparent the Blizzard bar
	if cfg.blizzardBar then
		cfg.blizzardBar:SetParent(frame)
		cfg.blizzardBar:EnableMouse(false)
	end

	mod.bars[cfg.cfg] = frame

	return frame
end

--=======================================
-- Button Layout
--=======================================
function mod:LayoutBar(frame, buttonList, cfg)
	local border = bdUI:get_border(frame)
	c = mod:get_save()

	-- config
	frame.limit = c[cfg.cfg.."_buttons"] or 12
	frame.scale = c[cfg.cfg.."_scale"] or 1
	frame.spacing = (c[cfg.cfg.."_spacing"] or cfg.spacing or 0) + border
	frame.width = (c[cfg.cfg.."_size"] * frame.scale) * (cfg.widthScale or 1)
	frame.height = c[cfg.cfg.."_size"] * frame.scale
	frame.rows = c[cfg.cfg.."_rows"] or 1
	frame.alpha = c[cfg.cfg.."_alpha"] or 1
	frame.enableFader = c[cfg.cfg.."_mouseover"] or false
	frame.hidehotkeys = c[cfg.cfg.."_hidehotkeys"] or false
	
	frame.num = #buttonList
	frame.cols = math.floor(math.min(frame.limit, frame.num) / frame.rows)

	-- register visibility driver, on init and on callback
	if cfg.frameVisibility then
		frame.frameVisibility = cfg.frameVisibility
		frame.frameVisibilityFunc = cfg.frameVisibilityFunc
		RegisterStateDriver(frame, cfg.frameVisibilityFunc or "visibility", cfg.frameVisibility)
	end

	-- sizing
	local frameWidth = frame.cols * frame.width + (frame.cols-1) * frame.spacing
	local frameHeight = frame.rows * frame.height + (frame.rows-1) * frame.spacing
	frame:SetSize(frameWidth, frameHeight)
	frame:SetAlpha(frame.alpha)

	-- hotkeys
	HideKeybinds(frame)
	
	-- Fader
	if (frame.enableFader) then
		bdMove:CreateFader(frame, buttonList, alpha, nil, nil, c.fade_duration)
		frame:SetAlpha(0)
	end

	-- button positioning
	local lastRow = nil
	local index = 1
	local showgrid = tonumber(GetCVar("alwaysShowActionBars"))	
	for i, button in pairs(buttonList) do
		if not frame.__blizzardBar then
			button:SetParent(frame)
		else
			frame.__blizzardBar.size = frame.size
			frame.__blizzardBar.alpha = frame.alpha
			frame.__blizzardBar.spacing = frame.spacing
		end
		button:SetSize(frame.width, frame.height)

		-- custom skinning callback
		if (cfg.buttonSkin) then
			cfg.buttonSkin(button)
		else
			mod:SkinButton(button)
		end

		button:ClearAllPoints()
		if (i > frame.limit) then
			button:SetPoint("CENTER", v.hidden, "CENTER", 0, 0)
			button:Hide()
			button:SetAlpha(0)
		else
			button:SetAlpha(1)
			button:Show()
			button:SetAttribute("showgrid", showgrid)
			if (i == 1) then
				button:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
				lastRow = button
			elseif (index > frame.cols) then
				button:SetPoint("TOPLEFT", lastRow, "BOTTOMLEFT", 0, -frame.spacing)
				lastRow = button
				index = 1
			else
				button:SetPoint("TOPLEFT", buttonList[i - 1], "TOPRIGHT", frame.spacing, 0)
			end
		end
		index = index + 1
	end
end

local function update_cooldown(self)
	if (not self.action) then return end
	local start, duration, enable = GetActionCooldown(self.action)

	-- print(start, duration, enable)

	local color = {1, 1, 1}
	if (start > 0 and enable and duration > 2) then
		local remaining = start + duration - GetTime()
		if (remaining < 3) then
			color = {0.8, 0.1, 0.1}
		elseif (remaining < 60) then
			color = {0.9, 0.9, 0.1}
		end
		-- print(remaining)
		self.cooldowntext:SetTextColor(unpack(color))
		self.icon:SetDesaturated(true)
	else
		self.cooldowntext:SetTextColor(0.9, 0.9, 0.1)
		self.icon:SetDesaturated(false)
	end
end

local function hook_cooldown(self)
	self.cooldown:SetScript("OnShow", function() update_cooldown(self) end)
	self.total = 0
	self:SetScript("OnUpdate", function(self, elapsed)
		self.total = self.total + elapsed
		if (self.total > 0.25) then
			self.total = 0
			update_cooldown(self)
		end
	end)
end

--=======================================
-- Skinning
--=======================================
function mod:SkinButton(button)
	bdUI:set_backdrop(button)
	if button.skinned then return end
	
	if (not button.SetNormalTexture) then return end

	local name = button:GetName()
	local icon = _G[name.."Icon"]
	local count = _G[name.."Count"]
	local macro = _G[name.."Name"]
	local cooldown = _G[name.."Cooldown"]
	local flash = _G[name.."Flash"]
	local checked = _G[name.."Checked"]
	local shine = _G[name.."Shine"]
	local hotkey = _G[name.."HotKey"]
	local border = _G[name.."Border"]
	local normal = _G[name.."NormalTexture"]
	local normal2 = _G[name.."NormalTexture2"]
	local btnBG = _G[name.."FloatingBG"]
	local autocastable = _G[name.."AutoCastable"]

	button:SetNormalTexture("")

	if ( not flash ) then return end

	flash:SetTexture("")
	icon:SetTexCoord(.1, .9, .1, .9)
	icon:SetDrawLayer("ARTWORK")

	-- Text Overrides
	hotkey:SetFontObject(v.font)
	hotkey:SetJustifyH("Right")
	hotkey:SetVertexColor(1, 1, 1)
	hotkey:SetTextColor(1, 1, 1)
	hotkey.SetTextColor = mod.noop
	hotkey.SetVertexColor = mod.noop
	hotkey:ClearAllPoints()
	hotkey:SetPoint("TOPRIGHT", button, "TOPRIGHT", 0,-3)

	count:SetFontObject(v.font)
	count:SetTextColor(0.7,0.7,0.7)
	count:SetJustifyH("Center")
	count:SetTextColor(1,1,1)
	count:ClearAllPoints()
	count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0,0)
	
	if (not macro) then return end
	macro:SetFontObject(v.font)
	macro:SetTextColor(0.7,0.7,0.7)
	macro:SetJustifyH("RIGHT")
	macro:SetTextColor(1,1,1)
	macro:ClearAllPoints()
	macro:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0,1)

	-- Fix cooldown Spiral Positioning
	button.cooldowntext = cooldown:GetRegions()
	button.cooldowntext:SetFont(bdUI.media.font, 16, "OUTLINE")
	button.cooldowntext:SetJustifyH("Center")
	button.cooldowntext:ClearAllPoints()
	button.cooldowntext:SetAllPoints(cooldown)
	cooldown:SetParent(button)
	cooldown:ClearAllPoints()
	cooldown:SetAllPoints(button)
	button.icon = icon
	hook_cooldown(button)

	-- Button Overwrite Textures
	button.hover = button:CreateTexture()
	button.hover:SetTexture(bdUI.media.flat)
	button.hover:SetVertexColor(1, 1, 1, 0.1)
	button.hover:SetAllPoints(button)
	button:SetHighlightTexture(button.hover)

	button.pushed = button:CreateTexture()
	button.pushed:SetTexture(bdUI.media.flat)
	button.pushed:SetVertexColor(1, 1, 1, 0.2)
	button.pushed:SetAllPoints(button)
	button:SetPushedTexture(button.pushed)

	button.checked = button:CreateTexture()
	button.checked:SetTexture(bdUI.media.flat)
	button.checked:SetVertexColor(0.2,1,0.2)
	button.checked:SetAlpha(0.3)
	button.checked.SetAlpha = mod.noop
	button.checked:SetAllPoints(button)
	button:SetCheckedTexture(button.checked)	

	-- Position these things onto the button
	if (shine) then
		shine:SetAlpha(0)
		shine:Hide()
		shine:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 0, 0)
		shine:SetPoint("TOPRIGHT", button, "TOPRIGHT", 0, 0)
	end
	if (checked) then
		checked:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 0, 0)
		checked:SetPoint("TOPRIGHT", button, "TOPRIGHT", 0, 0)
	end

	-- Force hide elements we don't want
	mod:ForceHide(autocastable)
	mod:ForceHide(normal2)
	mod:ForceHide(border)
	mod:ForceHide(btnBG)

	button.skinned = true
end


-- Flyout skinning
local function StyleFlyout(self)
	if (not self.FlyoutArrow or InCombatLockdown()) then return end

	local parent = self:GetParent():GetParent():GetParent()
	local size = parent and parent.width or c.bar1_size
	local alpha = parent and parent.alpha or 1
	local spacing = parent and parent.spacing or 2
	spacing = bdUI.pixel * spacing

	for i = 1, NUM_ACTIONBAR_BUTTONS do
		local button = _G["SpellFlyoutButton"..i]
		if not button then break end

		mod:SkinButton(button)
		-- button:ClearAllPoints()
		-- button:SetSize(size, size)
		-- if (i == 1) then
		-- 	button:SetPoint("BOTTOM", SpellFlyout, "BOTTOM", 0, spacing)
		-- else
		-- 	button:SetPoint("BOTTOM", _G["SpellFlyoutButton"..i-1], "TOP", 0, spacing)
		-- end
	end
end

function mod:hook_flyout()
	hooksecurefunc("ActionButton_UpdateFlyout", StyleFlyout)
	hooksecurefunc("SpellButton_OnClick", StyleFlyout)
end