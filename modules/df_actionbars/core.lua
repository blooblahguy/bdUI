local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Actionbars")
local config

function mod:kill_blizzard()
	bdUI:kill(MainMenuBar.EndCaps)
	bdUI:kill(MainMenuBar.ActionBarPageNumber)
	bdUI:kill(MainMenuBar.BorderArt)
end

function mod:get_button_list(buttonName, numButtons)
	local buttonList = {}
	for i=1, numButtons do
		local button = _G[buttonName..i]
		if not button then break end
		table.insert(buttonList, button)
	end
	return buttonList
end

function mod:initialize()
	config = mod:get_save()
	if (not config.enabled) then return end

	SetCVar("countdownForCooldowns", 1)

	local bars = {
		["ab1"] = mod:get_button_list("ActionButton", NUM_ACTIONBAR_BUTTONS),
		["ab2"] = mod:get_button_list("MultiBarBottomLeftButton", NUM_ACTIONBAR_BUTTONS),
		["ab3"] = mod:get_button_list("MultiBarBottomRightButton", NUM_ACTIONBAR_BUTTONS),
		["ab4"] = mod:get_button_list("MultiBarRightButton", NUM_ACTIONBAR_BUTTONS),
		["ab5"] = mod:get_button_list("MultiBarLeftButton", NUM_ACTIONBAR_BUTTONS),
		["ab6"] = mod:get_button_list("MultiBar5Button", NUM_ACTIONBAR_BUTTONS),
		["ab7"] = mod:get_button_list("MultiBar6Button", NUM_ACTIONBAR_BUTTONS),
		["ab8"] = mod:get_button_list("MultiBar7Button", NUM_ACTIONBAR_BUTTONS),
		["stance"] = mod:get_button_list("StanceButton", 10),
	}

	for k, list in pairs(bars) do
		for i = 1, #list do
			local button = list[i]
			mod:skin_button(button)
		end
	end

	mod:kill_blizzard()
end

function mod:skin_button(button)
	if button.skinned then return end

	-- button:KillEditMode()

	-- bdUI:set_backdrop(button)
	if (not button.SetBackdrop) then
		Mixin(button, BackdropTemplateMixin)
	end

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
	local r_divider = button.RightDivider

	if (button.SetNormalTexture) then
		button:SetNormalTexture("")
	end

	-- if (button.IconMask) then
	-- 	button.IconMask:SetAllPoints()
	-- end

	-- FLASH
	if (flash) then
		flash:SetColorTexture(1.0, 0.2, 0.2, 0.45)
		bdUI:set_outside(flash)
		flash:SetDrawLayer("BACKGROUND", -1)
	end

	-- ICON
	if (icon) then
		icon:SetTexCoord(.07, .93, .07, .93)
		-- icon:SetDrawLayer("ARTWORK")
	end

	-- HOTKEY
	if (hotkey) then
		hotkey:SetFontObject(bdUI:get_font(12, "THINOUTLINE"))
		hotkey:SetJustifyH("Right")
		hotkey:SetTextColor(1, 1, 1)
		hotkey:ClearAllPoints()
		hotkey:SetPoint("TOPRIGHT", button, "TOPRIGHT", 0,-3)
	end

	-- COUNT
	if (count) then
		count:SetFontObject(bdUI:get_font(12, "THINOUTLINE"))
		count:SetTextColor(0.7,0.7,0.7)
		count:SetJustifyH("Center")
		count:SetTextColor(1,1,1)
		count:ClearAllPoints()
		count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0,0)
	end
	
	-- MACRO
	if (macro) then
		macro:SetFontObject(bdUI:get_font(12, "THINOUTLINE"))
		macro:SetTextColor(0.7,0.7,0.7)
		macro:SetJustifyH("RIGHT")
		macro:SetTextColor(1,1,1)
		macro:ClearAllPoints()
		macro:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0,1)
	end

	-- COOLDOWN
	if (cooldown) then
		local cooldowntext = cooldown:GetRegions()
		cooldowntext:SetFontObject(bdUI:get_font(12, "THINOUTLINE"))
		cooldowntext:SetJustifyH("CENTER")
		cooldowntext:SetPoint("LEFT", cooldown, -20, 0)
		cooldowntext:SetPoint("RIGHT", cooldown, 20, 0)
		cooldown:SetParent(button)
		cooldown:SetPoint("TOPLEFT")
		cooldown:SetPoint("BOTTOMRIGHT")
		--cooldown:SetSize(button:GetWidth() + 46, button:GetHeight() + 6)

		-- hook into cooldown styling
		hooksecurefunc(cooldown, "SetCooldown", mod.hook_cooldown)
		cooldown:SetScript("OnUpdate", function(self, elapsed) mod:cooldown_on_update(self, elapsed) end)
	end

	-- HOVER
	if (button.SetHighlightTexture) then
		local hover = button:CreateTexture()
		hover:SetTexture(bdUI.media.flat)
		hover:SetVertexColor(1, 1, 1, 0.2)
		hover:SetPoint("BOTTOMLEFT", button, bdUI:get_border(button), bdUI:get_border(button))
		hover:SetPoint("TOPRIGHT", button, -bdUI:get_border(button), -bdUI:get_border(button))
		button:SetHighlightTexture(hover)
	end

	-- PUSHED
	if (button.SetPushedTexture) then
		local pushed = button:CreateTexture()
		pushed:SetTexture(bdUI.media.flat)
		pushed:SetVertexColor(1, 1, 1, 0.2)
		pushed:SetPoint("BOTTOMLEFT", button, bdUI:get_border(button), bdUI:get_border(button))
		pushed:SetPoint("TOPRIGHT", button, -bdUI:get_border(button), -bdUI:get_border(button))
		button:SetPushedTexture(pushed)
	end

	-- CHECKED
	if (button.SetCheckedTexture) then
		local new_checked = button:CreateTexture()
		new_checked:SetPoint("BOTTOMLEFT", button, bdUI:get_border(button), bdUI:get_border(button))
		new_checked:SetPoint("TOPRIGHT", button, -bdUI:get_border(button), -bdUI:get_border(button))
		new_checked:SetColorTexture(0.8, 0.8, 1, 0.5)
		button:SetCheckedTexture(new_checked)
	end

	-- SHINE
	if (shine) then
		shine:SetParent(button)
		bdUI:set_inside(shine)
	end

	hooksecurefunc(button, "SetScale", function()
		-- bdUI:set_backdrop(button)
		button:SetBackdrop({bgFile = bdUI.media.flat, edgeFile = bdUI.media.flat, edgeSize = bdUI:get_border(button)})
		button:SetBackdropColor(unpack(bdUI.media.backdrop))
		button:SetBackdropBorderColor(unpack(bdUI.media.border))
	end)

	-- HIDE
	bdUI:kill(autocastable)
	bdUI:kill(normal)
	bdUI:kill(normal2)
	bdUI:kill(border)
	bdUI:kill(btnBG)
	bdUI:kill(button.BottomDivider)
	bdUI:kill(button.RightDivider)
	bdUI:kill(button.SlotBackground)

	button.skinned = true
end