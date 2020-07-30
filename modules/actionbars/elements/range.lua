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
local text_colors = {}
text_colors[3] = {0.8, 0.1, 0.1}
text_colors[60] = {0.8, 0.7, 0.1}
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
		end
	else
		colorkey = "unusable"
		if (notEnoughMana) then
			colorkey = "outmana"
		end
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
	if (self.flashtime >= ATTACK_BUTTON_FLASH_TIME) then
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

--=====================================================
-- Main Hooks
-- Dequeue this button's updater, and use our own queue
--=====================================================
hooksecurefunc("ActionButton_UpdateRangeIndicator", function(button, checksRange, inRange)
	if (not checksRange) then 
		return 
	end
	local action = button.action
	local isUsable, notEnoughMana = IsUsableAction(action)
	local colorkey = "normal"
	if (isUsable) then
		if (not inRange) then
			colorkey = "outrange"
		end
	else
		colorkey = "unusable"
		if (notEnoughMana) then
			colorkey = "outmana"
		end
	end

	-- cache results, because SetVertexColor is expensive, we don't want to recall it if unecessary
	if buttonColors[action] == colorkey then return end
	buttonColors[action] = colorkey

	local r, g, b = unpack(colors[colorkey])
	button.icon:SetVertexColor(r, g, b)
end)
-- hooksecurefunc('ActionButton_Update', UpdateButtonStatus)
-- hooksecurefunc('ActionButton_UpdateUsable', function(button) UpdateButtonUsable(button, true) end)