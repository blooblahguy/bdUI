local parent, ns = ...
local lib = ns.bdConfig

--========================================
-- Methods Here
--========================================
local methods = {
	["set"] = function(self, options, save)

	end,
	["get"] = function(self, options, save)

	end,
	["onchange"] = function(self, options, save)

	end,
	["onclick"] = function(self, options, save)
		
	end
}

--========================================
-- Spawn Element
--========================================
local function create(options, parent)
	options.size = options.size or "half"
	local media = lib.media
	local border = media.border_size
	local button
	local container

	if (options.solo) then
		button = CreateFrame("Button", nil, parent)
	else
		container = lib:create_container(options, parent, 28)
		button = CreateFrame("Button", nil, container)
		button:SetPoint("LEFT", container, "LEFT")
	end

	button.inactiveColor = media.blue
	button.activeColor = media.blue
	button.callback = options.callback or lib.noop
	button.save = options.save
	button.key = options.key
	button.activeAlpha = 1
	button.hoverAlpha = 0.8
	button.inactiveAlpha = 0.5
	button:SetBackdrop({bgFile = media.flat})
	
	function button:BackdropColor(r, g, b, a)
		button.inactiveColor = button.inactiveColor or media.blue
		button.activeColor = button.activeColor or media.blue

		if (r and b and g) then
			button:SetBackdropColorOld(r, g, b, a)
		end
	end

	button.SetBackdropColorOld = button.SetBackdropColor
	button.SetBackdropColor = button.BackdropColor
	button.SetVertexColor = button.BackdropColor

	button:SetBackdropColor(unpack(media.blue))
	button:SetAlpha(button.inactiveAlpha)
	button:SetHeight(30)
	button:EnableMouse(true)

	button.text = button:CreateFontString(nil, "OVERLAY", "bdConfig_font")
	button.text:SetPoint("CENTER")
	button.text:SetJustifyH("CENTER")
	button.text:SetJustifyV("MIDDLE")

	function button:Select()
		button.SetVertexColor(unpack(button.activeColor))
		button:SetAlpha(button.activeAlpha)
	end
	function button:Deselect()
		button.SetVertexColor(unpack(button.inactiveColor))
		button:SetAlpha(button.inactiveAlpha)
	end
	function button:OnEnter()
		if (button.active) then
			button:SetBackdropColor(unpack(button.activeColor))
			button:SetAlpha(button.activeAlpha)
		else
			if (button.hoverColor) then
				button:SetBackdropColor(unpack(button.hoverColor))
			else
				button:SetBackdropColor(unpack(button.inactiveColor))
			end
			button:SetAlpha(button.hoverAlpha)
		end
	end

	function button:OnLeave()
		if (button.active) then
			button:SetBackdropColor(unpack(button.activeColor))
			button:SetAlpha(button.activeAlpha)
		else
			button:SetBackdropColor(unpack(button.inactiveColor))
			button:SetAlpha(button.inactiveAlpha)
		end
	end
	function button:OnClickDefault()
		if (button.OnClick) then button.OnClick(button) end
		if (button.autoToggle) then
			if (button.active) then
				button.active = false
			else
				button.active = true
			end
		end

		button:OnLeave()

		button:callback(button, options)
	end
	function button:GetText()
		return button.text:GetText()
	end
	function button:SetText(text)
		button.text:SetText(text)
		button:SetWidth(button.text:GetStringWidth() + 30)
	end

	button:SetScript("OnEnter", button.OnEnter)
	button:SetScript("OnLeave", button.OnLeave)
	button:SetScript("OnClick", button.OnClickDefault)

	button:OnLeave()
	button:SetText(options.value or options.label)

	if (options.solo) then
		return button
	else
		container.button = button
		return container
	end
end

lib:register_element("button", create)