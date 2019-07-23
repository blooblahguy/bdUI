local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Actionbars")
local v = mod.variables

--===================================================
-- Range & Mana Display
-- A good bit borrowed from TullaCC, who makes this cpu-efficient
--===================================================

local total = 0
local throttle = 0.15
local buttons = {}
local buttonColors = {}
local colors = {}
colors['normal'] = {1, 1, 1}
colors['outmana'] = {0.3, 0.3, 0.8}
colors['outrange'] = {0.8, 0.1, 0.1}
colors['unusable'] = {0.3, 0.3, 0.3}
local updater = CreateFrame("frame")
updater:Hide()

--=========================================
-- BUTTON FUNCTIONS
--=========================================
-- This actually colors the button, main function
local function UpdateButtonUsable(self, force)
	if force then
		buttonColors[self] = nil
	end

	local action = self.action
	local isUsable, notEnoughMana = IsUsableAction(action)
	local colorkey = "normal"
	if (isUsable) then
		if (ActionHasRange(action) and IsActionInRange(action) == false) then
			colorkey = "outrange"
		elseif (notEnoughMana) then
			colorkey = "outmana"
		end
	else
		colorkey = "unusable"
	end

	-- cache results, because SetVertexColor is expensive, we don't want to recall it if unecessary
	if buttonColors[self] == colorkey then return end
	buttonColors[self] = colorkey

	local r, g, b = unpack(colors[colorkey])
	self.icon:SetVertexColor(r, g, b)
end

-- since we stripped the OnUpdate from the button, we gotta reimplement this blizzard code
local function UpdateButtonFlash(self, elapsed)
	if self.flashing ~= 1 then return end

	self.flashtime = self.flashtime + elapsed
	if (flashtime >= ATTACK_BUTTON_FLASH_TIME) then
		local flashTexture = self.Flash;
		if ( flashTexture:IsShown() ) then
			flashTexture:Hide();
		else
			flashTexture:Show();
		end

		self.flashtime = 0;
	end
end

--=========================================
-- UPDATER FUNCTIONS
-- Loop through / enable OnUpdater as necessary
--=========================================
local function UpdateButtons(elapsed)
	if next(buttons) then
		for button in pairs(buttons) do
			UpdateButtonUsable(button)
			UpdateButtonFlash(button, elapsed)
		end

		return true
	end

	return false
end
local function RequestUpdate()
	if next(buttons) then
		updater:Show()
	end
end

-- add button to the queue if it's visible and actionable
-- then run the onupdate if we're passed the throttle time
local function UpdateButtonStatus(self)
	local action = self.action

	if action and self:IsVisible() and HasAction(action) then
		buttons[self] = true
	else
		buttons[self] = nil
	end

	RequestUpdate()
end

-- Throttled Updater
-- Automatically hides when not in use, reducing onupdate calls
updater:SetScript("OnUpdate", function(self, elapsed)
	total = total + elapsed
	if (total >= throttle) then
		total = 0
		if not UpdateButtons(elapsed) then
			self:Hide()
		end
	end
end)

--===================================================
-- Hotkey Improvements
--===================================================
function mod:UpdateHotkeys(frame)
	if (not self and frame) then self = frame end

	local hotkey = _G[self:GetName() .. "HotKey"]
	local text = hotkey:GetText()
	if (not text) then return end
	
	text = string.gsub(text, "(s%-)", "S-")
	text = string.gsub(text, "(a%-)", "A-")
	text = string.gsub(text, "(c%-)", "C-")
	text = string.gsub(text, KEY_MOUSEWHEELDOWN , "MDn")
    text = string.gsub(text, KEY_MOUSEWHEELUP , "MUp")
	text = string.gsub(text, KEY_BUTTON3, "M3")
	text = string.gsub(text, KEY_BUTTON4, "M4")
	text = string.gsub(text, KEY_BUTTON5, "M5")
	text = string.gsub(text, KEY_MOUSEWHEELUP, "MU")
	text = string.gsub(text, KEY_MOUSEWHEELDOWN, "MD")
	text = string.gsub(text, KEY_NUMPAD0, "N0")
    text = string.gsub(text, KEY_NUMPAD1, "N1")
    text = string.gsub(text, KEY_NUMPAD2, "N2")
    text = string.gsub(text, KEY_NUMPAD3, "N3")
    text = string.gsub(text, KEY_NUMPAD4, "N4")
    text = string.gsub(text, KEY_NUMPAD5, "N5")
    text = string.gsub(text, KEY_NUMPAD6, "N6")
    text = string.gsub(text, KEY_NUMPAD7, "N7")
    text = string.gsub(text, KEY_NUMPAD8, "N8")
    text = string.gsub(text, KEY_NUMPAD9, "N9")
    text = string.gsub(text, KEY_NUMPADDECIMAL, "N.")
    text = string.gsub(text, KEY_NUMPADDIVIDE, "N/")
    text = string.gsub(text, KEY_NUMPADMINUS, "N-")
    text = string.gsub(text, KEY_NUMPADMULTIPLY, "N*")
    text = string.gsub(text, KEY_NUMPADPLUS, "N+")
	text = string.gsub(text, KEY_PAGEUP, "PU")
	text = string.gsub(text, KEY_PAGEDOWN, "PD")
	text = string.gsub(text, KEY_SPACE, "Spc")
	text = string.gsub(text, KEY_INSERT, "Ins")
	text = string.gsub(text, KEY_HOME, "Hm")
	text = string.gsub(text, KEY_DELETE, "Del")
	text = string.gsub(text, KEY_INSERT_MAC, "Hlp") -- mac

	hotkey:SetText(text)
end

--=====================================================
-- Main Hooks
-- Dequeue this button's updater, and use our own queue
--=====================================================
hooksecurefunc('ActionButton_OnUpdate', function(button)
	button:HookScript('OnShow', UpdateButtonStatus)
	button:HookScript('OnHide', UpdateButtonStatus)
	button:SetScript('OnUpdate', nil)
	UpdateButtonStatus(button)
end)
hooksecurefunc('ActionButton_Update', UpdateButtonStatus)
hooksecurefunc('ActionButton_UpdateUsable', function(button) UpdateButtonUsable(button, true) end)
hooksecurefunc("ActionButton_UpdateHotkeys", mod.UpdateHotkeys)
hooksecurefunc("PetActionButton_SetHotkeys", mod.UpdateHotkeys)