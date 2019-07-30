local addonName, ns = ...
local mod = ns.bdConfig



	--========================================
-- Methods Here
--========================================
local methods = {
	["set"] = function(self, save, key, value)
		if (not save) then save = self.save end
		if (not key) then key = self.key end
		if (not value) then value = self:get(save, key) end
		save[key] = value

		self:SetBackdropColor(unpack(value))
	end,
	["get"] = function(self, save, key)
		if (not save) then save = self.save end
		if (not key) then key = self.key end

		return save[key]
	end,
	["change"] = function(self, r, g, b, a)
		self:set(self.save, self.key, {r, g, b, a})

		self:callback()

		return r, g, b, a
	end,
	["onclick"] = function(self)
		self.save[self.key] = self:GetChecked()
		self:set(self.save, self.key)

		self:callback()
	end
}

--========================================
-- Spawn Element
--========================================
local function create(options, parent)
	options.size = options.size or "half"
	local container = mod:create_container(options, parent, 30)

	local picker = CreateFrame("button", nil, container)
	picker:SetSize(20, 20)
	picker:SetBackdrop({bgFile = mod.media.flat, edgeFile = mod.media.flat, edgeSize = 2, insets = {top = 2, right = 2, bottom = 2, left = 2}})
	picker:SetBackdropBorderColor(0,0,0,1)
	picker:SetPoint("LEFT", container, "LEFT", 0, 0)

	picker.save = options.save
	picker.key = options.key
	picker.callback = options.callback
	Mixin(picker, methods)
	picker:set()
	
	picker:SetScript("OnClick", function(self)		
		HideUIPanel(ColorPickerFrame)
		local r, g, b, a = unpack(self:get())

		ColorPickerFrame:SetFrameStrata("FULLSCREEN_DIALOG")
		ColorPickerFrame:SetClampedToScreen(true)
		ColorPickerFrame.hasOpacity = true
		ColorPickerFrame.opacity = 1 - a
		ColorPickerFrame.old = {r, g, b, a}
		
		local function colorChanged()
			local r, g, b = ColorPickerFrame:GetColorRGB()
			local a = 1 - OpacitySliderFrame:GetValue()

			self:change(r, g, b, a)
		end

		ColorPickerFrame.func = colorChanged
		ColorPickerFrame.opacityFunc = colorChanged
		ColorPickerFrame.cancelFunc = function()
			local r, g, b, a = unpack(ColorPickerFrame.old) 
			self:change(r, g, b, a)
		end

		ColorPickerFrame:SetColorRGB(r, g, b)
		ColorPickerFrame:EnableKeyboard(false)
		ShowUIPanel(ColorPickerFrame)
	end)
	
	picker.text = picker:CreateFontString(nil, "OVERLAY", "bdConfig_font")
	picker.text:SetText(options.label)
	picker.text:SetPoint("LEFT", picker, "RIGHT", 8, 0)

	return container, picker
end

mod:register_element("color", create)