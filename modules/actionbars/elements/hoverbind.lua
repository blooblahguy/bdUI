local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Actionbars")

--[[
	Lots of credit to ncNameHover - This implementation probably won't work as well as that addon does on it's own. Props
]]

-- variables
local localmacros = 0

-- Build button overlay for displaying binders
local binder = CreateFrame("frame", nil, UIParent)
binder:Hide()

binder.backlay = binder:CreateTexture(nil, "OVERLAY")
binder.backlay:SetAllPoints()
binder.backlay:SetTexture(0, 0, 0, .25)
binder.text = binder:CreateFontString(nil, "OVERLAY")
binder.text:SetFontObject(bdUI:get_font(11))
binder.text:SetTextColor(0.8, 0.8, 0)
binder.text:SetJustifyH("CENTER")
binder.text:SetJustifyV("MIDDLE")
binder.text:SetPoint("CENTER")

--=======================================================
-- Binder Listener
--=======================================================
function binder:Listener(key)
	if not v.ToggleBindings or InCombatLockdown() then return end

	if key == "ESCAPE" or key == "RightButton" then
		SetBinding(self.command, nil, self.secondary)

		print("Primary keybinding cleared for |cff00ff00"..self.button.name.."|r.")
		self:Update(self.button, self.spellmacro)
		return
	end
	
	-- don't count modifiers
	if key == "LSHIFT"
		or key == "RSHIFT"
		or key == "LCTRL"
		or key == "RCTRL"
		or key == "LALT"
		or key == "RALT"
		or key == "UNKNOWN"
		or key == "LeftButton"
		or key == "MiddleButton"
	then return end

	-- convert things to blizzard style
	if key == "Button4" then key = "BUTTON4" end
	if key == "Button5" then key = "BUTTON5" end
	local alt = IsAltKeyDown() and "ALT-" or ""
	local ctrl = IsControlKeyDown() and "CTRL-" or ""
	local shift = IsShiftKeyDown() and "SHIFT-" or ""
	local bind = alt..ctrl..shift..key
	
	if not self.spellmacro or self.spellmacro == "PET" or self.spellmacro == "STANCE" then
		SetBinding(bind, self.button.bindstring)
	else
		SetBinding(bind, self.spellmacro.." "..self.button.name)
	end
	print(bind.." |cff00ff00bound to |r"..self.button.name..".")
	self:Update(self.button, self.spellmacro)
end

--=======================================================
-- Initialize the binder & register buttons
--=======================================================
function binder:Update(button, spelltype)
	if not v.ToggleBindings or InCombatLockdown() then return end

	self.button = button
	self.spellmacro = spelltype
	
	self:ClearAllPoints()
	self:SetAllPoints(button)
	self.text:SetText("")
	self:Show()
	
	if spellmacro == "SPELL" then
		self.button.id = SpellBook_GetSpellBookSlot(self.button)
		self.button.name = GetSpellBookItemName(self.button.id, SpellBookFrame.bookType)

		-- can theoretically set 3rd and 4th bindings for everything, but we'll just display primary
		self.command, self.primary, self.secondary =GetBindingKey(spelltype.." "..self.button.name)
		if (self.primary) then
			self.text:SetText(self.primary)
		else
			self.text:SetText("")
		end
	elseif spellmacro == "MACRO" then
		self.button.id = self.button:GetID()
		if localmacros == 1 then self.button.id = self.button.id + 120 end
		self.button.name = GetMacroInfo(self.button.id)

		self.command, self.primary, self.secondary =GetBindingKey(spelltype.." "..self.button.name)
		if (self.primary) then
			self.text:SetText(self.primary)
		else
			self.text:SetText("")
		end
	elseif spellmacro == "STANCE" or spellmacro == "PET" then
		self.button.id = tonumber(button:GetID())
		self.button.name = button:GetName()
		if not self.button.name then return end
		
		-- build the binding string to query blizz api
		if not self.button.id or self.button.id < 1 or self.button.id > (spellmacro=="STANCE" and 10 or 12) then
			self.button.bindstring = "CLICK "..self.button.name..":LeftButton"
		else
			self.button.bindstring = (spellmacro=="STANCE" and "SHAPESHIFTBUTTON" or "BONUSACTIONBUTTON")..self.button.id
		end
		

		self.command, self.primary, self.secondary = GetBindingKey(bind.button.bindstring)
		if (self.primary) then
			self.text:SetText(self.primary)
		else
			self.text:SetText("")
		end
	else
		self.button.action = tonumber(button.action)
		self.button.name = button:GetName()
		if not self.button.name then return end
		
		-- build bind string to call blizz api
		if not self.button.action or self.button.action < 1 or self.button.action > 132 then
			self.button.bindstring = "CLICK "..self.button.name..":LeftButton"
		else
			local modact = 1+(self.button.action-1)%12
			if self.button.action < 25 or self.button.action > 72 then
				self.button.bindstring = "ACTIONBUTTON"..modact
			elseif self.button.action < 73 and self.button.action > 60 then
				self.button.bindstring = "MULTIACTIONBAR1BUTTON"..modact
			elseif self.button.action < 61 and self.button.action > 48 then
				self.button.bindstring = "MULTIACTIONBAR2BUTTON"..modact
			elseif self.button.action < 49 and self.button.action > 36 then
				self.button.bindstring = "MULTIACTIONBAR4BUTTON"..modact
			elseif self.button.action < 37 and self.button.action > 24 then
				self.button.bindstring = "MULTIACTIONBAR3BUTTON"..modact
			end
		end

		self.command, self.primary, self.secondary = GetBindingKey(self.button.bindstring)
		if (self.primary) then
			self.text:SetText(self.primary)
		else
			self.text:SetText("")
		end
	end
end

--===================================================
-- Load, register, and hook
--===================================================
function binder:Initialize()
	if (self.initialized) then return end
	
	-- REGISTERING BUTTONS
	local stance = StanceButton1:GetScript("OnClick")
	local pet = PetActionButton1:GetScript("OnClick")
	local button = ActionButton1:GetScript("OnClick")

	local function register(val)
		if val.IsProtected and val.GetObjectType and val.GetScript and val:GetObjectType()=="CheckButton" and val:IsProtected() then
			local script = val:GetScript("OnClick")
			val.GetEnter = val:GetScript("OnEnter")
			if script == button then
				val:HookScript("OnEnter", function(self) binder:Update(self) end)
			elseif script==stance then
				val:HookScript("OnEnter", function(self) binder:Update(self, "STANCE") end)
			elseif script==pet then
				val:HookScript("OnEnter", function(self) binder:Update(self, "PET") end)
			end
		end
	end
	-- loop through all frames, register only buttons
	local val = EnumerateFrames()
	while val do
		register(val)
		val = EnumerateFrames(val)
	end
	for i = 1, 12 do
		local sb = _G["SpellButton"..i]
		sb.GetEnter = sb:GetScript("OnEnter")
		sb:HookScript("OnEnter", function(self) binder:Update(self, "SPELL") end)
	end

	-- REGISTERING MACROS
	local function registermacro()
		for i = 1, 120 do
			local mb = _G["MacroButton"..i]
			mb.GetEnter = mb:GetScript("OnEnter")
			mb:HookScript("OnEnter", function(self) binder:Update(self, "MACRO") end)
		end
		-- tracl whether we're modifying character or global macros
		MacroFrameTab1:HookScript("OnMouseUp", function() localmacros = 0 end)
		MacroFrameTab2:HookScript("OnMouseUp", function() localmacros = 1 end)
	end
	if not IsAddOnLoaded("Blizzard_MacroUI") then
		hooksecurefunc("LoadAddOn", function(addon)
			if addon == "Blizzard_MacroUI" then
				registermacro()
			end
		end)
	else
		registermacro()
	end

	-- Register the dialog popup for when we're in binding mode
	StaticPopupDialogs["KEYBIND_MODE"] = {
		text = "Hover your mouse over any actionbutton to bind it. Press the escape key or right click to clear the current actionbutton's keybinding.",
		button1 = "Save bindings",
		button2 = "Discard bindings",
		OnAccept = function() binder:Deactivate(true) end,
		OnCancel = function() binder:Deactivate(false) end,
		timeout = 0,
		whileDead = 1,
		hideOnEscape = false
	}


	-- Hook Events / Trigger
	self:SetScript("OnEvent", function(self) self:Deactivate(false) end)
	self:SetScript("OnLeave", function(self) self:Hide() end)
	self:SetScript("OnKeyUp", function(self, key) self:Listener(key) end)
	self:SetScript("OnMouseUp", function(self, key) self:Listener(key) end)
	self:SetScript("OnMouseWheel", function(self, delta) if delta > 0 then self:Listener("MOUSEWHEELUP") else self:Listener("MOUSEWHEELDOWN") end end)

	self.initialized = true
end

--=======================================================
-- Activate
--=======================================================
function binder:Activate()
	if (InCombatLockdown()) then print("You can't bind keys in combat.") return end
	self:Initialize()
	self:ClearAllPoints()
	self:RegisterEvent("PLAYER_REGEN_DISABLED")

	StaticPopup_Show("KEYBIND_MODE")
end

--=======================================================
-- Deactivate & save or discard
--=======================================================
function binder:Deactivate(save)
	local acc_or_char = c.bindaccount and 2 or 1
	v.ToggleBindings = false

	if save then
		SaveBindings(acc_or_char)
		print("All keybindings have been saved.")
	else
		LoadBindings(acc_or_char)
		print("All newly set keybindings have been discarded.")
	end

	self:Hide()
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
	StaticPopup_Hide("KEYBIND_MODE")
end


--=======================================================
-- bdNameplates Hook
--=======================================================
function mod:ToggleBindings()
	if (not v.ToggleBindings) then
		binder:Activate()
		v.ToggleBindings = true
	else
		binder:Deactivate(true)
		v.ToggleBindings = false
	end
end
