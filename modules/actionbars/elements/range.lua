local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Actionbars")
local v = mod.variables

--===================================================
-- Range & Mana Display
--===================================================
local colors = {}
colors['normal'] = {1, 1, 1}
colors['outmana'] = {0.3, 0.3, 0.6}
colors['outrange'] = {0.8, 0.1, 0.1}
colors['unusable'] = {0.4, 0.4, 0.4}

local hotkey_colors = {}
hotkey_colors['normal'] = {1, 1, 1}
hotkey_colors['unusable'] = {0.8, 0.8, 0.8}
hotkey_colors['outmana'] = {0.7, 0.5, 1}
hotkey_colors['outrange'] = {1, 0.5, 0.5}

local function update_useable(self, checksRange, inRange)
	-- throw back to blizzard if we're not enabled
	if (not mod.config.enabled) then
		bdUI.hooks.ActionButton_UpdateRangeIndicator(self, checksRange, inRange)
	end

	local action = self.action
	if (not action) then return end
	local isUsable, notEnoughMana = IsUsableAction(action)
	local colorkey = "normal"

	-- if this ability is valid for range check, checking range, and in not in range
	if (checksRange and not inRange) then
		colorkey = "outrange"
		if (not isUsable) then
			colorkey = "unusable"

		end
	elseif (not isUsable) then
		-- just plain can't be used
		colorkey = "unusable"

		-- color blue if class doesn't have enough mana
		if (notEnoughMana) then
			-- local powerType, powerTypeString = UnitPowerType("player")
			-- if (powerTypeString == "MANA") then
				-- print("out of mana")
			colorkey = "outmana"
			-- end
		end
	end

	self.icon:SetVertexColor(unpack(colors[colorkey]))
	_G[self:GetName().."HotKey"]:SetTextColor(unpack(hotkey_colors[colorkey]))
end

-- take over blizzard function for this, securely
bdUI:RawHook("ActionButton_UpdateRangeIndicator", update_useable, true)