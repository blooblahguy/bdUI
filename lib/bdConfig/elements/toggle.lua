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
		if (value) then
			self.check:GetCheckedTexture():Show()
			_G[self.check:GetName().."Text"]:SetAlpha(1)
		else
			self.check:GetCheckedTexture():Hide()
			_G[self.check:GetName().."Text"]:SetAlpha(lib.media.muted)
		end
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
		self:check_state_color()
	end,
	["check_state_color"] = function(self)
		if (self.text:GetText() == "Enabled" or self.text:GetText() == "Enable") then
			if (self.check:GetChecked()) then
				self.text:SetTextColor(0, 1, 0)
			else
				self.text:SetTextColor(1, 0, 0)
			end
		else
			self.text:SetTextColor(1, 1, 1)
		end
	end,
}

local skin = function(frame)
	local inside = frame:CreateMaskTexture()
	-- inside:SetTexture([[Interface\Minimap\UI-Minimap-Background]], 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
	inside:SetTexture(lib.media.flat)--, 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
	inside:SetSize(10, 10)
	inside:SetPoint('CENTER')

	frame.inside = inside

	local outside = frame:CreateMaskTexture()
	outside:SetTexture([[Interface\Minimap\UI-Minimap-Background]], 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
	outside:SetTexture(lib.media.flat) --, 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
	outside:SetSize(10, 10)
	outside:SetPoint('CENTER')

	frame.outside = outside

	frame:SetCheckedTexture(lib.media.flat)
	frame:SetNormalTexture(lib.media.flat)
	frame:SetHighlightTexture(lib.media.flat)
	frame:SetDisabledTexture(lib.media.flat)
	frame:SetPushedTexture("")

	local check = frame:GetCheckedTexture()
	check:SetVertexColor(unpack(lib.media.blue))
	-- -- check:SetTexCoord(0, 1, 0, 1)
	check:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -0)
	check:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -0, 0)
	check:AddMaskTexture(inside)

	local highlight = frame:GetHighlightTexture()
	highlight:SetTexCoord(0, 1, 0, 1)
	highlight:SetVertexColor(1, 1, 1)
	highlight:SetAlpha(0.3)
	highlight:AddMaskTexture(inside)

	local normal = frame:GetNormalTexture()
	normal:SetPoint("TOPLEFT", frame, "TOPLEFT", -lib.border, lib.border)
	normal:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", lib.border, -lib.border)
	normal:SetTexCoord(0, 1, 0, 1)
	normal:SetVertexColor(unpack(lib.media.border))
	normal:AddMaskTexture(outside)

	local disabled = frame:GetDisabledTexture()
	disabled:SetVertexColor(.3, .3, .3)
	disabled:AddMaskTexture(outside)

	-- hooksecurefunc(frame, "SetNormalTexture", function(f, t) if t ~= "" then f:SetNormalTexture("") end end)
	-- hooksecurefunc(frame, "SetPushedTexture", function(f, t) if t ~= "" then f:SetPushedTexture("") end end)
	-- hooksecurefunc(frame, "SetHighlightTexture", function(f, t) if t ~= "" then f:SetHighlightTexture("") end end)
	-- hooksecurefunc(frame, "SetDisabledTexture", function(f, t) if t ~= "" then f:SetDisabledTexture("") end end)
end

--========================================
-- Spawn Element
--========================================
local function create(options, parent)
	options.size = options.size or "half"
	local container = lib:create_container(options, parent, 16)

	local check = CreateFrame("CheckButton", options.name.."_"..options.key, container, "ChatConfigCheckButtonTemplate")
	local text = _G[check:GetName().."Text"]
	check:SetPoint("LEFT", container, "LEFT", -2, 0)
	check:SetSize(lib.border * 8, lib.border * 8)
	text:SetText(options.label)
	text:SetFontObject("bdConfig_font")
	text:ClearAllPoints()
	text:SetPoint("LEFT", check, "RIGHT", 5, -1)

	container.callback = options.callback
	container.key = options.key
	container.module = options.module
	container.check = check
	container.text = text
	Mixin(container, methods)
	check:SetScript("OnClick", function() container:onclick() end)
	skin(check)
	container:set()
	container:check_state_color()

	-- check:Click()
	-- check:Click()

	return container
end

lib:register_element("toggle", create)