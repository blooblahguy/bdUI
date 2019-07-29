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

		self:SetChecked(value)
	end,
	["get"] = function(self, save, key)
		if (not save) then save = self.save end
		if (not key) then key = self.key end

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
	options.size = options.size or "full"
	local container = mod:create_container(options, parent, 200)

	-- Title
	local title = container:CreateFontString(nil, "OVERLAY", "bdConfig_font")
	title:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
	title:SetText(options.label)

	-- button
	local button = mod.elements['button']({solo = true}, container)
	button:SetText("Add/Remove")
	button:SetHeight(26)

	local insertbox = CreateFrame("EditBox", nil, container)
	insertbox:SetFontObject("bdConfig_font")
	insertbox:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
	insertbox:SetTextInsets(6, 2, 2, 2)
	insertbox:SetMaxLetters(200)
	insertbox:SetHistoryLines(1000)
	insertbox:SetAutoFocus(false) 
	insertbox:SetScript("OnEnterPressed", function(self, key) button:Click() end)
	insertbox:SetScript("OnEscapePressed", function(self, key) self:ClearFocus() end)
	local border = mod:get_border(insertbox)
	insertbox:SetBackdrop({bgFile = mod.media.flat, edgeFile = mod.media.flat, edgeSize = border})
	insertbox:SetBackdropColor(0, 0, 0, 0.15)
	insertbox:SetBackdropBorderColor(0, 0, 0, 0.2)

	insertbox.alert = insertbox:CreateFontString(nil, "OVERLAY", "bdConfig_font")
	insertbox.alert:SetPoint("TOPRIGHT", container, "TOPRIGHT", -2, 0)
	function insertbox:startFade()
		local total = 0
		self.alert:Show()
		self:SetScript("OnUpdate",function(self, elapsed)
			total = total + elapsed
			if (total > 2.5) then
				self.alert:SetAlpha(self.alert:GetAlpha()-0.02)
				
				if (self.alert:GetAlpha() <= 0.05) then
					self:SetScript("OnUpdate", function() return end)
					self.alert:Hide()
				end
			end
		end)
	end

	button:SetPoint("TOPLEFT", insertbox, "TOPRIGHT", 0, -2)
	insertbox:SetSize(container:GetWidth() - button:GetWidth() + 2, 30)

	local list = CreateFrame("frame", nil, container)
	list:SetPoint("TOPLEFT", insertbox, "BOTTOMLEFT", 0, -2)
	list:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT")
	list.save = options.save
	list.key = options.key
	list.callback = options.callback
	local border = mod:get_border(list)
	list:SetBackdrop({bgFile = mod.media.flat, edgeFile = mod.media.flat, edgeSize = border})
	list:SetBackdropColor(0, 0, 0, 0.08)
	list:SetBackdropBorderColor(0, 0, 0, 0.15)

	local content = mod.elements['scrollframe']({}, list)
	list.content = content

	list.text = content:CreateFontString(nil, "OVERLAY", "bdConfig_font")
	list.text:SetPoint("TOPLEFT", content, "TOPLEFT", mod.dimensions.padding, -mod.dimensions.padding)
	list.text:SetHeight(600)
	list.text:SetWidth(list:GetWidth() - (mod.dimensions.padding * 2))
	list.text:SetJustifyH("LEFT")
	list.text:SetJustifyV("TOP")
	list.text:SetText("test")

	-- show all config entries in this list
	function list:populate()
		local string = "";
		local height = 0;

		-- maintained list
		-- allows us to pass a list of variables that should be maintained inside of this listbox, but can be set to false and won't be added again
		if (options.autoadd or options.autoAdd or options.maintained) then
			local autoadd = options.autoadd or options.autoAdd or options.maintained -- alias
			for k, v in pairs(autoadd) do
				if (self.save[self.key][k] == nil) then
					self.save[self.key][k] = v
				end
			end
		end

		-- populated the saved options
		for k, v in pairs(self.save[self.key]) do
			if (v ~= false) then
				string = string..k.."\n";
				height = height + 14
			end
		end

		local scrollheight = (height - 200) 
		scrollheight = scrollheight > 1 and scrollheight or 1

		list.content.scrollbar:SetMinMaxValues(1, scrollheight)
		if (scrollheight == 1) then 
			list.content.scrollbar:Hide()
		else
			list.content.scrollbar:Show()
		end

		list.content:SetHeight(height)
		list.text:SetHeight(height)
		list.text:SetText(string)
	end

	-- remove or add something, then redraw the text
	function list:addRemove(value)
		if (self.save[self.key][value]) then
			insertbox.alert:SetTextColor(1, 0.1, 0.1)
			insertbox.alert:SetText(value.." removed")
			self.save[self.key][value] = false
		else
			insertbox.alert:SetTextColor(0, 1, .2)
			insertbox.alert:SetText(value.." added")
			-- @todo pass in table or integer values here to alter display
			self.save[self.key][value] = true
		end
		insertbox:startFade()
		
		self:populate()
		self:callback()
	end

	button.OnClick = function()
		local value = insertbox:GetText()

		if (strlen(value) > 0) then
			list:addRemove(insertbox:GetText())
		end

		insertbox:SetText("")
		insertbox:ClearFocus()
	end

	list:populate()

	return container
end

mod:register_element("list", create)