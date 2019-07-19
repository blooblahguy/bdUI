local addonName, ns = ...
local mod = ns.bdConfig

--========================================
-- Methods Here
--========================================
local methods = {
	["set"] = function(self, save, key, value)
		if (not value) then value = self:get(save, key) end
		save[key] = value

		self:SetChecked(value)
	end,
	["get"] = function(self, save, key)
		return save[key]
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
	local container = mod:create_container(options, parent, 16)

	local check = CreateFrame("CheckButton", options.module.."_"..options.key, container, "ChatConfigCheckButtonTemplate")
	local text = _G[check:GetName().."Text"]
	check:SetPoint("LEFT", container, "LEFT", -2, 0)
	text:SetText(options.label)
	text:SetFontObject("bdConfig_font")
	text:ClearAllPoints()
	text:SetPoint("LEFT", check, "RIGHT", 2, 1)

	check.callback = options.callback
	check.save = options.save
	check.key = options.key
	Mixin(check, methods)
	check:SetScript("OnClick", check.onclick)
	check:set(options.save, options.key)

	return container
end

mod:register_element("toggle", create)