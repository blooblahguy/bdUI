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

		self.input:SetText(value)
	end,
	-- return value from profile[key]
	["get"] = function(self)
		self.save = self.module:get_save()

		return self.save[self.key]
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
	local container = lib:create_container(options, parent, 36)
	
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
	input:SetScript("OnTextChanged", function(self, key) container:set(self:GetText()) end)
	input:SetScript("OnEnterPressed", function(self, key) container:set(self:GetText()); self:ClearFocus(); end)
	input:SetScript("OnEscapePressed", function(self, key) container:set(self:GetText()); self:ClearFocus(); end)
	input:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -2)
	lib:create_backdrop(input)

	container.key = options.key
	container.input = input
	container.label = label
	container.module = options.module
	Mixin(container, methods)
	container:set()

	return container
end

lib:register_element("input", create)