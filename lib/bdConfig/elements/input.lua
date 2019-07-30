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

		self:SetText(value)
	end,
	["get"] = function(self, save, key)
		if (not save) then save = self.save end
		if (not key) then key = self.key end

		return save[key]
	end,
	-- ["onclick"] = function(self)
		-- self.save[self.key] = self:GetChecked()
		-- self:set(self.save, self.key)

		-- self:callback()
	-- end
}

--========================================
-- Spawn Element
--========================================
local function create(options, parent)
	options.size = options.size or "half"
	local container = mod:create_container(options, parent, 36)
	
	local label = container:CreateFontString(nil, "OVERLAY", "bdConfig_font")
	label:SetText(options.label)
	label:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)

	local input = CreateFrame("EditBox", nil, container)
	input:SetSize(200,24)
	input:SetFontObject("bdConfig_font")
	input:SetText(options.value or "")
	input:SetTextInsets(6, 2, 2, 2)
	input:SetMaxLetters(200)
	input:SetHistoryLines(1000)
	input:SetAutoFocus(false) 
	input:SetScript("OnTextChanged", function(self, key) self:set(self.save, self.key, self:GetText()) end)
	input:SetScript("OnEnterPressed", function(self, key) self:set(self.save, self.key, self:GetText()); self:ClearFocus(); end)
	input:SetScript("OnEscapePressed", function(self, key) self:set(self.save, self.key, self:GetText()); self:ClearFocus(); end)
	input:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -2)
	input.save = options.save
	input.key = options.key
	Mixin(input, methods)
	input:set()

	mod:create_backdrop(input)

	return container, input
end

mod:register_element("input", create)