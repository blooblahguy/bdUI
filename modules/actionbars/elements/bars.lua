local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Actionbars")
local v = mod.variables

local defaultPadding = 14

--===============================================================
-- Actionbar 1
--===============================================================
function mod:create_actionbar1()
	mod:HideMainMenuBar()
	cfg = {}
	cfg.blizzardBar = nil
	cfg.cfg = "bar1"
	cfg.frameName = "bdActionbars_1"
	cfg.moveName = "Actionbar 1"
	cfg.frameVisibility = "[petbattle] hide; show"
	cfg.actionPage = "[bar:6]6;[bar:5]5;[bar:4]4;[bar:3]3;[bar:2]2;[overridebar]14;[shapeshift]13;[vehicleui]12;[possessbar]12;[bonusbar:5]11;[bonusbar:4]10;[bonusbar:3]9;[bonusbar:2]8;[bonusbar:1]7;1"
	cfg.frameSpawn = {"BOTTOM", UIParent, "BOTTOM", 0, defaultPadding}

	local buttonName = "ActionButton"
	local numButtons = NUM_ACTIONBAR_BUTTONS
	local buttonList = mod:GetButtonList(buttonName, numButtons)
	local bar1 = mod:CreateBar(buttonList, cfg)

	-- fix the button grid for actionbar1
	local function ToggleButtonGrid()
		if InCombatLockdown() then return end
		local showgrid = tonumber(GetCVar("alwaysShowActionBars"))
		for i, button in next, buttonList do
			button:SetAttribute("showgrid", showgrid)
			ActionButton_ShowGrid(button, ACTION_BUTTON_SHOW_GRID_REASON_EVENT)
		end
	end
	hooksecurefunc("MultiActionBar_UpdateGridVisibility", ToggleButtonGrid)
		
	--_onstate-page state driver
	for i, button in next, buttonList do
		bar1:SetFrameRef(buttonName..i, button)
	end

	bar1:Execute(([[
		buttons = table.new()
		for i=1, %d do
			table.insert(buttons, self:GetFrameRef("%s"..i))
		end
	]]):format(numButtons, buttonName))
	bar1:SetAttribute("_onstate-page", [[
		--print("_onstate-page","index",newstate)
		for i, button in next, buttons do
			button:SetAttribute("actionpage", newstate)
		end
	]])
	RegisterStateDriver(bar1, "page", cfg.actionPage)
end

--===============================================================
-- Actionbar 2
--===============================================================
function mod:create_actionbar2()
	cfg = {}
	cfg.blizzardBar = MultiBarBottomLeft
	cfg.cfg = "bar2"
	cfg.frameName = "bdActionbars_2"
	cfg.moveName = "Actionbar 2"
	-- cfg.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar][shapeshift] hide; [combat][mod][@target,exists,nodead] show; hide"
	cfg.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar][shapeshift] hide; show"
	cfg.frameSpawn = {"BOTTOMRIGHT", bdParent, "BOTTOMRIGHT", -defaultPadding, defaultPadding}

	local buttonList = mod:GetButtonList("MultiBarBottomLeftButton", NUM_ACTIONBAR_BUTTONS)
	local bar2 = mod:CreateBar(buttonList, cfg)
end

--===============================================================
-- Actionbar 3
--===============================================================
function mod:create_actionbar3()
	cfg = {}
	cfg.blizzardBar = MultiBarBottomRight
	cfg.frameName = "bdActionbars_3"
	cfg.moveName = "Actionbar 3"
	cfg.cfg = "bar3"
	cfg.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar][shapeshift] hide; show"
	cfg.frameSpawn = {"BOTTOM", mod.bars['bar2'], "TOP", 0, 0}

	local buttonList = mod:GetButtonList("MultiBarBottomRightButton", NUM_ACTIONBAR_BUTTONS)
	local bar3 = mod:CreateBar(buttonList, cfg)
end

--===============================================================
-- Actionbar 4
--===============================================================
function mod:create_actionbar4()
	cfg = {}
	cfg.blizzardBar = MultiBarRight
	cfg.frameName = "bdActionbars_4"
	cfg.moveName = "Actionbar 4"
	cfg.cfg = "bar4"
	cfg.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar][shapeshift] hide; show"
	cfg.frameSpawn = {"TOP", bdParent, "CENTER", 0, -163}

	local buttonList = mod:GetButtonList("MultiBarRightButton", NUM_ACTIONBAR_BUTTONS)
	local bar4 = mod:CreateBar(buttonList, cfg)
end

--===============================================================
-- Actionbar 5
--===============================================================
function mod:create_actionbar5()
	cfg = {}
	cfg.blizzardBar = MultiBarLeft
	cfg.frameName = "bdActionbars_5"
	cfg.moveName = "Actionbar 5"
	cfg.cfg = "bar5"
	cfg.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar][shapeshift] hide; show"
	cfg.frameSpawn = {"RIGHT", bdParent, "RIGHT", -defaultPadding, 0}

	local buttonList = mod:GetButtonList("MultiBarLeftButton", NUM_ACTIONBAR_BUTTONS)
	local bar5 = mod:CreateBar(buttonList, cfg)
end

--===============================================================
-- Pet Bar
--===============================================================
function mod:create_petbar()
	cfg = {}
	cfg.cfg = "petbar"
	cfg.blizzardBar = PetActionBarFrame
	cfg.frameName = "bdActionbars_PetBar"
	cfg.moveName = "Pet Bar"
	cfg.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar][shapeshift] hide; [pet] show; hide"
	cfg.frameSpawn = {"BOTTOMRIGHT", mod.bars['bar1'], "TOPRIGHT", 0, defaultPadding}

	local buttonList = mod:GetButtonList("PetActionButton", NUM_PET_ACTION_SLOTS)
	local petbar = mod:CreateBar(buttonList, cfg)
	petbar:EnableMouse(false)
end

--===============================================================
-- StanceBar
--===============================================================
function mod:create_stancebar()
	cfg = {}
	cfg.cfg = "stancebar"
	cfg.blizzardBar = StanceBarFrame
	cfg.frameName = "bdActionbars_StanceBar"
	cfg.moveName = "Stance Bar"
	cfg.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar][shapeshift] hide; show"
	cfg.frameSpawn = {"BOTTOMLEFT", mod.bars['bar1'], "TOPLEFT", 0, defaultPadding}

	local stances = 0
	for i = 1, NUM_STANCE_SLOTS do
		local icon, name, active, castable, spellId = GetShapeshiftFormInfo(i);
		if (not icon) then break end
		stances = stances + 1
	end

	if (stances == 0) then return end

	local buttonList = mod:GetButtonList("StanceButton", stances)
	local stancebar = mod:CreateBar(buttonList, cfg)
	stancebar:EnableMouse(false)
end

--===============================================================
-- MicroMenu
--===============================================================
function mod:create_micromenu()
	c = mod:get_save()
	if (not c.showMicro) then return end
	cfg = {}
	cfg.cfg = "microbar"
	cfg.frameName = "bdActionbars_MicroMenuBar"
	cfg.moveName = "Micromenu"
	cfg.frameVisibility = "[petbattle] hide; show"
	cfg.frameSpawn = {"BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -defaultPadding, defaultPadding}
	cfg.widthScale = 0.777
	TalentMicroButtonAlert:Hide()
	TalentMicroButtonAlert.Show = noop
	cfg.buttonSkin = function(button)
		local regions = {button:GetRegions()}
		for k, v in pairs(regions) do
			if (v == button.background or v == button.border) then return end
			v:SetTexCoord(.17, .80, .22, .82)
			v:SetPoint("TOPLEFT", button, "TOPLEFT", 4, -6)
			v:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -4, 6)
		end
		bdUI:set_backdrop(button)
	end
	local buttonList = {}
	for idx, buttonName in next, MICRO_BUTTONS do
		local button = _G[buttonName]
		if button and button:IsShown() then
			table.insert(buttonList, button)
		end
	end
	local micromenu = mod:CreateBar(buttonList, cfg)
end
	
--===============================================================
-- BagBar
--===============================================================
function mod:create_bagbar()
	cfg = {}
	cfg.cfg = "bagbar"
	cfg.frameName = "bdActionbars_BagBar"
	cfg.moveName = "Bagbar"
	-- cfg.frameVisibility = "[petbattle] hide; show"
	cfg.frameSpawn = { "BOTTOMRIGHT", mod.bars['microbar'] or bdParent, "TOPRIGHT", 0, defaultPadding }
	function cfg:callback(frame)
		if (c.showBags) then
			_G['bdActionbars_BagBar']:Show()
		else
			_G['bdActionbars_BagBar']:Hide()
		end
	end
	local buttonList = { MainMenuBarBackpackButton, CharacterBag0Slot, CharacterBag1Slot, CharacterBag2Slot, CharacterBag3Slot }
	local bagbar = mod:CreateBar(buttonList, cfg)
end

--===============================================================
-- Vehicle Exit
--===============================================================
function mod:create_vehicle()
	cfg = {}
	cfg.cfg = "vehiclebar"
	cfg.frameName = "bdActionbars_VehicleExitBar"
	cfg.moveName = "Vehicle Exit"
	cfg.frameVisibility = "[canexitvehicle]c;[mounted]m;n"
	cfg.frameVisibilityFunc = "exit"
	cfg.frameSpawn = { "BOTTOMRIGHT", mod.bars['bar1'], "TOPLEFT", -defaultPadding, defaultPadding }
	--create vehicle exit button
	local button = CreateFrame("CHECKBUTTON", "bdActionbars_VehicleExitButton", nil, "ActionButtonTemplate, SecureHandlerClickTemplate")
	button.icon:SetTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up")
	button:SetScript("OnEnter", function() 
		ShowUIPanel(GameTooltip)
		GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
		
		if (UnitOnTaxi("player")) then
			GameTooltip:AddLine("Request Stop")
		else
			GameTooltip:AddLine("Leave Vehicle")
		end
		
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", function() 
		GameTooltip:Hide()
	end)
	button:RegisterForClicks("AnyUp")
	local function OnClick(self)
		if UnitOnTaxi("player") then TaxiRequestEarlyLanding() else VehicleExit() end self:SetChecked(false)
	end
	button:SetScript("OnClick", OnClick)
	
	local buttonList = { button }
	local vehicle = mod:CreateBar(buttonList, cfg)

	--[canexitvehicle] is not triggered on taxi, exit workaround
	vehicle:SetAttribute("_onstate-exit", [[ if CanExitVehicle() then self:Show() else self:Hide() end ]])
	if not CanExitVehicle() then vehicle:Hide() end
end

--===============================================================
-- Possess Exit
--===============================================================
function mod:create_possess()
	if (bdUI:get_game_version() == "vanilla") then return end
	cfg = {}
	cfg.cfg = "possessbar"
	cfg.blizzardBar = PossessBarFrame
	cfg.frameName = "bdActionbars_PossessExitBar"
	cfg.moveName = "Possess Exit"
	cfg.frameVisibility = "[possessbar] show; hide"
	cfg.frameSpawn = { "BOTTOM", mod.bars['vehiclebar'], "TOP", 0, defaultPadding }

	local buttonList = mod:GetButtonList("PossessButton", NUM_POSSESS_SLOTS)
	local possess = mod:CreateBar(buttonList, cfg)
end

--===============================================================
-- Extra Action Button
--===============================================================
function mod:create_extra()
	cfg = {}
	cfg.cfg = "extrabar"
	cfg.blizzardBar = ExtraActionBarFrame
	cfg.frameName = "bdActionbars_ExtraBar"
	cfg.moveName = "Extra Button"
	cfg.frameVisibility = "[extrabar] show; hide"
	cfg.frameSpawn = { "LEFT", UIParent, "LEFT", 300, 0 }

	local buttonList = mod:GetButtonList("ExtraActionButton", NUM_ACTIONBAR_BUTTONS)
	table.insert(buttonList, ZoneAbilityFrame)
	local extra = mod:CreateBar(buttonList, cfg)
end