local parent, ns = ...
local lib = ns.bdConfig

--========================================
-- Methods Here
--========================================
local methods = {
	-- set value to profile[key]
	["set"] = function(self, value)
		self.save = self.module:get_save()

		if (not value) then value = self:get(self.save, self.key) end
		self.save[self.key] = value

		self.picker:SetBackdropColor(unpack(value))
	end,
	-- return value from profile[key]
	["get"] = function(self)
		self.save = self.module:get_save()

		return self.save[self.key]
	end,
	["change"] = function(self, r, g, b, a)
		self:set({r, g, b, a})

		self:callback()

		return r, g, b, a
	end,
	["onclick"] = function(self)
		self.save[self.key] = self:GetChecked()
		self:set()

		self:callback()
	end
}

--========================================
-- Spawn Element
--========================================
local function create(options, parent)
	options.size = options.size or "half"
	local container = lib:create_container(options, parent, 30)

	local picker = CreateFrame("button", nil, container, "BackdropTemplate")
	picker:SetSize(20, 20)
	picker:SetBackdrop({bgFile = lib.media.flat, edgeFile = lib.media.flat, edgeSize = 2, insets = {top = 2, right = 2, bottom = 2, left = 2}})
	picker:SetBackdropBorderColor(0,0,0,1)
	picker:SetPoint("LEFT", container, "LEFT", 0, 0)
	
	picker:SetScript("OnClick", function(self)		
		HideUIPanel(ColorPickerFrame)
		local r, g, b, a = unpack(container:get())

		ColorPickerFrame:SetFrameStrata("FULLSCREEN_DIALOG")
		ColorPickerFrame:SetClampedToScreen(true)
		ColorPickerFrame.hasOpacity = true
		ColorPickerFrame.opacity = 1 - a
		ColorPickerFrame.old = {r, g, b, a}
		
		local function colorChanged()
			local r, g, b = ColorPickerFrame:GetColorRGB()
			local a = 1 - OpacitySliderFrame:GetValue()

			container:change(r, g, b, a)
		end

		ColorPickerFrame.func = colorChanged
		ColorPickerFrame.opacityFunc = colorChanged
		ColorPickerFrame.cancelFunc = function()
			local r, g, b, a = unpack(ColorPickerFrame.old) 
			container:change(r, g, b, a)
		end

		ColorPickerFrame:SetColorRGB(r, g, b)
		ColorPickerFrame:EnableKeyboard(false)
		ShowUIPanel(ColorPickerFrame)
	end)
	
	picker.text = picker:CreateFontString(nil, "OVERLAY", "bdConfig_font")
	picker.text:SetText(options.label)
	picker.text:SetPoint("LEFT", picker, "RIGHT", 8, 0)
	picker.text:SetAlpha(lib.media.muted)

	container.key = options.key
	container.callback = options.callback
	container.module = options.module
	container.picker = picker
	Mixin(container, methods)
	container:set()

	return container
end

lib:register_element("color", create)