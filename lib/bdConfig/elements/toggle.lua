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
		
		self.check:SetChecked(value)
	end,
	-- return value from profile[key]
	["get"] = function(self)
		self.save = self.module:get_save()

		return self.save[self.key]
	end,
	["onclick"] = function(self)
		self.save[self.key] = self.check:GetChecked()
		self:set()

		self.callback(self.check, nil, self.save[self.key])
	end
}

--========================================
-- Spawn Element
--========================================
local function create(options, parent)
	options.size = options.size or "half"
	local container = lib:create_container(options, parent, 16)

	local check = CreateFrame("CheckButton", options.name.."_"..options.key, container, "ChatConfigCheckButtonTemplate")
	local text = _G[check:GetName().."Text"]
	check:SetPoint("LEFT", container, "LEFT", -2, 0)
	text:SetText(options.label)
	text:SetFontObject("bdConfig_font")
	text:ClearAllPoints()
	text:SetPoint("LEFT", check, "RIGHT", 2, 1)

	container.callback = options.callback
	container.key = options.key
	container.module = options.module
	container.check = check
	Mixin(container, methods)
	container:set()
	check:SetScript("OnClick", function() container:onclick() end)

	return container
end

lib:register_element("toggle", create)