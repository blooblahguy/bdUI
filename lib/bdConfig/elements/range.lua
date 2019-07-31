local parent, ns = ...
local lib = ns.bdConfig

--========================================
-- Methods Here
--========================================
local methods = {
	-- set value to profile[key]
	["set"] = function(self, value)
		self.save = self.module:get_save()

		if (not value) then value = self:get() end
		self.save[self.key] = value
		

		self.lastValue = value
		self.slider:SetValue(value)
		self.slider.value:SetText(value)
	end,
	-- return value from profile[key]
	["get"] = function(self)
		self.save = self.module:get_save()

		return self.save[self.key]
	end,
	["onchange"] = function(self)
		local newval
		if (self.step >= 1) then
			newval = lib:round(self.slider:GetValue())
		else
			newval = lib:round(self.slider:GetValue(), 1)
		end

		if (self.lastValue == newval) then return end
		if (self:get() == newval) then -- throttle it changing on the same pixel
			return false
		end

		self:set(newval)
		
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
	local container = lib:create_container(options, parent, 46)
	local name = options.name.."_"..options.key

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
	container.lastValue = 0
	container.callback = options.callback
	container.step = options.step
	container.key = options.key
	container.slider = slider
	container.module = options.module
	Mixin(container, methods)
	container:set()
	slider:SetScript("OnValueChanged", function() container:onchange() end)

	return container
end

lib:register_element("range", create)