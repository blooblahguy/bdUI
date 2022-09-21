local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Actionbars")
local v = mod.variables



--===================================================
-- Hotkey Improvements
--===================================================
local function UpdateHotkeys(actionButtonType)
	local id;
    if ( not actionButtonType ) then
        actionButtonType = "ACTIONBUTTON";
		id = self:GetID();
	else
		if ( actionButtonType == "MULTICASTACTIONBUTTON" ) then
			id = self.buttonIndex;
		else
			id = self:GetID();
		end
    end

    local hotkey = self.HotKey;
    local key = GetBindingKey(actionButtonType..id) or
                GetBindingKey("CLICK "..self:GetName()..":LeftButton");

	local text = GetBindingText(key, 1);

	-- print(text)
	-- print(self, frame)
	-- return
	-- if (not self and frame) then self = frame end

	-- local hotkey = _G[self:GetName() .. "HotKey"]
	-- local text = hotkey:GetText()
	-- if (not text) then return end
	
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
-- if (bdUI:get_game_version() == "shadowlands") then
-- hooksecurefunc(ActionButton1, "UpdateHotkeys", mod.UpdateHotkeys)
-- end
-- hooksecurefunc("ActionButton_UpdateHotkeys", UpdateHotkeys)