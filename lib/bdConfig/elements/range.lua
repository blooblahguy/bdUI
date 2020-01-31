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

local function skin(frame)
	assert(frame, "doesn't exist!")

	local orientation = frame:GetOrientation()
	local thumb_height = 12
	local slider_height = 7

	for k, v in pairs ({frame:GetRegions()}) do
		if (v:GetObjectType() == "TEXTURE") then
			v:Hide()
		end
	end
	frame:SetBackdrop({bgFile = lib.media.flat, edgeFile = lib.media.flat, edgeSize = lib.border})
	frame:SetBackdropColor(unpack(lib.media.background))
	frame:SetBackdropBorderColor(unpack(lib.media.border))

	local thumb = frame:GetThumbTexture()
	frame:SetThumbTexture(lib.media.flat)
	thumb:SetVertexColor(unpack(lib.media.blue))
	thumb:SetSize(slider_height, thumb_height)

	if orientation == 'VERTICAL' then
		frame:SetWidth(slider_height)
	else
		frame:SetHeight(slider_height)

		for i=1, frame:GetNumRegions() do
			local region = select(i, frame:GetRegions())
			if region and region:IsObjectType('FontString') then
				local point, anchor, anchorPoint, x, y = region:GetPoint()
				if strfind(anchorPoint, 'BOTTOM') then
					region:SetPoint(point, anchor, anchorPoint, x, y - 4)
				end
			end
		end
	end
end

--========================================
-- Spawn Element
--========================================
local function create(options, parent)
	options.size = options.size or "half"

	-- container/controller
	local container = lib:create_container(options, parent, 36)
	local name = options.name.."_"..options.key

	local slider = CreateFrame("Slider", name, container, "OptionsSliderTemplate")
	slider:SetWidth(container:GetWidth())
	slider:SetHeight(8)
	slider:SetPoint("LEFT", container ,"LEFT", 0, -8)
	slider:SetOrientation('HORIZONTAL')
	slider:SetMinMaxValues(options.min, options.max)
	slider.SetObeyStepOnDrag = slider.SetObeyStepOnDrag or noop
	slider:SetObeyStepOnDrag(true)
	slider:SetValueStep(options.step)

	_G[name..'Low']:Hide();
	_G[name..'High']:Hide();
	_G[name..'Text']:ClearAllPoints()
	_G[name..'Text']:SetPoint("BOTTOMLEFT", slider, "TOPLEFT", 4, 2)
	_G[name..'Text']:SetText(options.label);
	_G[name..'Text']:SetFontObject("bdConfig_font")
	_G[name..'Text']:SetAlpha(lib.media.muted)
	
	slider.value = slider:CreateFontString(nil, "OVERLAY", "bdConfig_font")
	slider.value:SetPoint("BOTTOMRIGHT", slider, "TOPRIGHT", -4, 2)
	slider.value:SetAlpha(lib.media.muted)

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

	skin(slider)

	return container
end

lib:register_element("range", create)