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

		self.lastValue = value
		self:SetValue(value)
		self.value:SetText(value)
	end,
	["get"] = function(self, save, key)
		if (not save) then save = self.save end
		if (not key) then key = self.key end

		return save[key]
	end,
	["onchange"] = function(self)
		local newval
		if (self.step >= 1) then
			newval = mod:round(self:GetValue())
		else
			newval = mod:round(self:GetValue(), 1)
		end

		if (self.lastValue == newval) then return end
		if (self:get(self.save, self.key) == newval) then -- throttle it changing on the same pixel
			return false
		end

		self:set(self.save, self.key, newval)
		
		self:callback()
	end,
	["onclick"] = function(self, options, save)
		
	end
}

--========================================
-- Spawn Element
--========================================
local function create(options, parent)
	options.size = options.size or "half"

	-- container/controller
	local container = mod:create_container(options, parent, 46)
	local name = options.module.."_"..options.key

	local slider = CreateFrame("Slider", name, container, "OptionsSliderTemplate")
	slider:SetWidth(container:GetWidth())
	slider:SetHeight(14)
	slider:SetPoint("LEFT", container ,"LEFT", 0, 0)
	slider:SetOrientation('HORIZONTAL')
	slider:SetMinMaxValues(options.min, options.max)
	slider.SetObeyStepOnDrag = slider.SetObeyStepOnDrag or noop
	slider:SetObeyStepOnDrag(true)
	slider:SetValueStep(options.step)

	_G[name..'Low']:SetText(options.min);
	_G[name..'Low']:SetFontObject("bdConfig_font")
	_G[name..'Low']:ClearAllPoints()
	_G[name..'Low']:SetPoint("TOPLEFT", slider,"BOTTOMLEFT",0,-1)
	_G[name..'High']:SetText(options.max);
	_G[name..'High']:SetFontObject("bdConfig_font")
	_G[name..'High']:ClearAllPoints()
	_G[name..'High']:SetPoint("TOPRIGHT", slider,"BOTTOMRIGHT",0,-1)
	_G[name..'Text']:SetText(options.label);
	_G[name..'Text']:SetFontObject("bdConfig_font")
	
	slider.value = slider:CreateFontString(nil, "OVERLAY", "bdConfig_font")
	slider.value:SetPoint("TOP", slider, "BOTTOM", 0, -2)

	-- Mixin methods, reference variables
	slider.lastValue = 0
	slider.callback = options.callback
	slider.step = options.step
	slider.save = options.save
	slider.key = options.key
	Mixin(slider, methods)
	slider:set(options.save, options.key)
	slider:SetScript("OnValueChanged", slider.onchange)

	return container, slider
end

mod:register_element("range", create)