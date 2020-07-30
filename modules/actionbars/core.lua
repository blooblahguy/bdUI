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
	mod.config = c
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
	-- mod:create_extra()

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
	mod.config = c
	if (not c.enabled) then mod.disabled = true; return end
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

local function update_cooldown(button, progress, force)
	if (progress > 1.5) then
		local color = {1, 1, 1}
		local threshhold = 0
		if (progress < 3) then
			threshhold = 3
			color = {0.8, 0.1, 0.1}
		elseif (progress < 60) then
			threshhold = 60
			color = {0.9, 0.9, 0.1}
		end
		-- don't call blizzard functions more often than neccesary
		if (button.threshhold ~= threshhold or force) then
			button.threshhold = threshhold
			_G[button:GetName().."Cooldown"]:GetRegions():SetTextColor(unpack(color))
			_G[button:GetName().."Icon"]:SetDesaturated(true)
		end
	else
		-- default
		_G[button:GetName().."Cooldown"].end_time = false
		_G[button:GetName().."Cooldown"]:GetRegions():SetTextColor(0.9, 0.9, 0.1)
		_G[button:GetName().."Icon"]:SetDesaturated(false)
	end
end

local function hook_cooldown(self)
	local button = self
	local cooldown = _G[self:GetName().."Cooldown"]

	-- update cooldown remaining when its set
	hooksecurefunc(cooldown, "SetCooldown", function(self, start, duration)
		local progress = start + duration - GetTime()
		if (start and duration and duration > 1.5) then
			self.end_time = start + duration
			self.duration = duration
			update_cooldown(button, progress, true)
		end
	end)

	-- check math every frame
	cooldown:SetScript("OnUpdate", function(self)
		if (not cooldown.end_time) then return end
		update_cooldown(button, cooldown.end_time - GetTime())
	end)
end

--=======================================
-- Skinning
--=======================================
function mod:SkinButton(button)
	if button.skinned then return end

	bdUI:set_backdrop(button)

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

	if (button.SetNormalTexture) then
		button:SetNormalTexture("")
	end

	-- FLASH
	if (flash) then
		flash:SetColorTexture(1.0, 0.2, 0.2, 0.45)
		bdUI:set_outside(flash)
		flash:SetDrawLayer("BACKGROUND", -1)
	end

	-- ICON
	if (icon) then
		icon:SetTexCoord(.1, .9, .1, .9)
		icon:SetDrawLayer("ARTWORK")
	end

	-- HOTKEY
	if (hotkey) then
		hotkey:SetFontObject(v.font)
		hotkey:SetJustifyH("Right")
		hotkey:SetTextColor(1, 1, 1)
		hotkey:ClearAllPoints()
		hotkey:SetPoint("TOPRIGHT", button, "TOPRIGHT", 0,-3)
	end

	-- COUNT
	if (count) then
		count:SetFontObject(v.font)
		count:SetTextColor(0.7,0.7,0.7)
		count:SetJustifyH("Center")
		count:SetTextColor(1,1,1)
		count:ClearAllPoints()
		count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0,0)
	end
	
	-- MACRO
	if (macro) then
		macro:SetFontObject(v.font)
		macro:SetTextColor(0.7,0.7,0.7)
		macro:SetJustifyH("RIGHT")
		macro:SetTextColor(1,1,1)
		macro:ClearAllPoints()
		macro:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0,1)
	end

	-- COOLDOWN
	if (cooldown) then
		local cooldowntext = cooldown:GetRegions()
		cooldowntext = cooldown:GetRegions()
		cooldowntext:SetFont(bdUI.media.font, 16, "OUTLINE")
		cooldowntext:SetJustifyH("Center")
		cooldowntext:SetAllPoints(cooldown)
		cooldown:SetParent(button)
		cooldown:SetAllPoints(button)
		hook_cooldown(button)
	end

	-- HOVER
	if (button.SetHighlightTexture) then
		local hover = button:CreateTexture()
		hover:SetTexture(bdUI.media.flat)
		hover:SetVertexColor(1, 1, 1, 0.1)
		hover:SetAllPoints(button)
		button:SetHighlightTexture(hover)
	end

	-- PUSHED
	if (button.SetPushedTexture) then
		local pushed = button:CreateTexture()
		pushed:SetTexture(bdUI.media.flat)
		pushed:SetVertexColor(1, 1, 1, 0.2)
		pushed:SetAllPoints(button)
		button:SetPushedTexture(pushed)
	end

	-- CHECKED
	if (button.SetCheckedTexture) then
		local new_checked = button:CreateTexture()
		new_checked:SetAllPoints()
		new_checked:SetColorTexture(1, 1, 1, 0.2)
		button:SetCheckedTexture(new_checked)
	end

	-- SHINE
	if (shine) then
		shine:SetParent(button)
		bdUI:set_inside(shine)
	end

	-- HIDE
	bdUI:kill(autocastable)
	bdUI:kill(normal2)
	bdUI:kill(border)
	bdUI:kill(btnBG)

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