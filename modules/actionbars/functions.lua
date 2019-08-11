--===============================================
-- FUNCTIONS
--===============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Actionbars")
local v = mod.variables

--===============================================
-- Custom functionality
-- place custom functionality here
--===============================================

--=======================================
-- Hiding Helpers
--=======================================
function mod:noop() return end

function mod:ForceHide(frame)
	if (not frame) then return end
	frame:Hide()
	frame.Show = mod.noop
end

--=======================================
-- Get buttons from global
--=======================================
function mod:GetButtonList(buttonName,numButtons)
	local buttonList = {}
	for i=1, numButtons do
		local button = _G[buttonName..i]
		if not button then break end
		table.insert(buttonList, button)
	end
	return buttonList
end

--=======================================
-- Hide & Fix Blizzard
-- again, mega credit to Zork
--=======================================
local scripts = { "OnShow", "OnHide", "OnEvent", "OnEnter", "OnLeave", "OnUpdate", "OnValueChanged", "OnClick", "OnMouseDown", "OnMouseUp"}
local framesToHide = { MainMenuBar, OverrideActionBar }
local framesToDisable = { MainMenuBar, MicroButtonAndBagsBar, MainMenuBarArtFrame, StatusTrackingBarManager, ActionBarDownButton, ActionBarUpButton, MainMenuBarVehicleLeaveButton, OverrideActionBar,
  OverrideActionBarExpBar, OverrideActionBarHealthBar, OverrideActionBarPowerBar, OverrideActionBarPitchFrame }

-- loops through and kills hooked scripts
local function StripScripts(frame)
	for i, script in next, scripts do
		if frame:HasScript(script) then
			frame:SetScript(script,nil)
		end
	end
end

-- hide mainmenu bar
function mod:HideMainMenuBar()
	--bring back the currency
	local function OnEvent(self,event)
		TokenFrame_LoadUI()
		TokenFrame_Update()
		BackpackTokenFrame_Update()
	end
	v.hidden:SetScript("OnEvent", OnEvent)
	-- v.hidden:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
	for i, frame in next, framesToHide do
		frame:SetParent(v.hidden)
	end
	for i, frame in next, framesToDisable do
		frame:UnregisterAllEvents()
		StripScripts(frame)
	end
end

--fix blizzard cooldown flash
local function FixCooldownFlash(self)
	if not self then return end
	if InCombatLockdown() then return end
	if self:GetEffectiveAlpha() > 0 then
		self:Show()
	else
		self:Hide()
	end
end

function mod:remove_blizzard()
	hooksecurefunc(getmetatable(ActionButton1Cooldown).__index, "SetCooldown", FixCooldownFlash)

	-- Hide extra textures
	StanceBarLeft:SetTexture(nil)
	StanceBarMiddle:SetTexture(nil)
	StanceBarRight:SetTexture(nil)

	SlidingActionBarTexture0:SetTexture(nil)
	SlidingActionBarTexture1:SetTexture(nil)

	if (PossessBackground1) then
		PossessBackground1:SetTexture(nil)
		PossessBackground2:SetTexture(nil)
	end

	if (ExtraActionBarFrame) then
		ExtraActionBarFrame.ignoreFramePositionManager = true
	end
	if (ZoneAbilityFrame) then
		ZoneAbilityFrame.ignoreFramePositionManager = true
	end
	if (ZoneAbilityFrame) then
		PetBattleFrame.BottomFrame.MicroButtonFrame:SetScript("OnShow", nil)
	end
	if (OverrideActionBar) then
		OverrideActionBar:SetScript("OnShow", nil)
	end
	MainMenuBar:SetScript("OnShow", nil)
end
