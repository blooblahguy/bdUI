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

		self:populate()
	end,
	-- return value from profile[key]
	["get"] = function(self)
		self.save = self.module:get_save()

		return self.save[self.key]
	end,
	-- fadeout animation
	["start_fade"] = function(self)
		local total = 0
		self.input.alert:Show()
		self.input:SetScript("OnUpdate",function(self, elapsed)
			total = total + elapsed
			if (total > 2.5) then
				self.alert:SetAlpha(self.alert:GetAlpha()-0.02)
				
				if (self.alert:GetAlpha() <= 0.05) then
					self:SetScript("OnUpdate", function() return end)
					self.alert:Hide()
				end
			end
		end)
	end,
	-- take the save data and populate the list
	["populate"] = function(self)
		local string = "";
		local height = 0;
		local save = self:get()

		-- maintained list
		-- allows us to pass a list of variables that should be maintained inside of this listbox, but can be set to false and won't be added again
		-- if (options.autoadd or options.autoAdd or options.maintained) then
		-- 	local autoadd = options.autoadd or options.autoAdd or options.maintained -- alias
			-- for k, v in pairs(autoadd) do
			-- 	if (self.save[self.key][k] == nil) then
			-- 		self.save[self.key][k] = v
			-- 	end
			-- end
		-- end

		-- populated the saved options
		for k, v in pairs(save) do
			if (v ~= false) then
				string = string..k.."\n";
				height = height + 14
			end
		end

		local scrollheight = (height - 200) 
		scrollheight = scrollheight > 1 and scrollheight or 1

		self.list.content.scrollbar:SetMinMaxValues(1, scrollheight)
		if (scrollheight == 1) then 
			self.list.content.scrollbar:Hide()
		else
			self.list.content.scrollbar:Show()
		end

		self.list.content:SetHeight(height)
		self.list.text:SetHeight(height)
		self.list.text:SetText(string)
	end,
	-- add or remove an item from the list, depending on if it exists
	["add_remove"] = function(self, value)
		local save = self:get()
		if (save[value]) then
			self.input.alert:SetTextColor(1, 0.1, 0.1)
			self.input.alert:SetText(value.." removed")
			save[value] = false
		else
			self.input.alert:SetTextColor(0, 1, .2)
			self.input.alert:SetText(value.." added")
			save[value] = true
		end
		self:start_fade()
		self:populate()
		self:callback()
	end
}

--========================================
-- Spawn Element
--========================================
local function create(options, parent)
	options.size = options.size or "full"
	local container = lib:create_container(options, parent, 200)

	-- Title
	local title = container:CreateFontString(nil, "OVERLAY", "bdConfig_font")
	title:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
	title:SetText(options.label)

	-- button
	local button = lib.elements['button']({solo = true}, container)
	button:SetText("Add/Remove")
	button:SetHeight(26)

	local insertbox = CreateFrame("EditBox", nil, container, "BackdropTemplate")
	insertbox:SetFontObject("bdConfig_font")
	insertbox:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
	insertbox:SetTextInsets(6, 2, 2, 2)
	insertbox:SetMaxLetters(200)
	insertbox:SetHistoryLines(1000)
	insertbox:SetAutoFocus(false) 
	insertbox:SetScript("OnEnterPressed", function(self, key) button:Click() end)
	insertbox:SetScript("OnEscapePressed", function(self, key) self:ClearFocus() end)
	local border = lib:get_border(insertbox)
	insertbox:SetBackdrop({bgFile = lib.media.flat, edgeFile = lib.media.flat, edgeSize = border})
	insertbox:SetBackdropColor(0, 0, 0, 0.15)
	insertbox:SetBackdropBorderColor(0, 0, 0, 0.2)

	insertbox.alert = insertbox:CreateFontString(nil, "OVERLAY", "bdConfig_font")
	insertbox.alert:SetPoint("TOPRIGHT", container, "TOPRIGHT", -2, 0)

	button:SetPoint("TOPLEFT", insertbox, "TOPRIGHT", 0, -2)
	insertbox:SetSize(container:GetWidth() - button:GetWidth() + 2, 30)

	local list = CreateFrame("frame", nil, container, "BackdropTemplate")
	list:SetPoint("TOPLEFT", insertbox, "BOTTOMLEFT", 0, -2)
	list:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT")
	list.save = options.save
	list.key = options.key
	list.callback = options.callback
	local border = lib:get_border(list)
	list:SetBackdrop({bgFile = lib.media.flat, edgeFile = lib.media.flat, edgeSize = border})
	list:SetBackdropColor(0, 0, 0, 0.08)
	list:SetBackdropBorderColor(0, 0, 0, 0.15)

	local content = lib.elements['scrollframe']({}, list)
	list.content = content

	list.text = content:CreateFontString(nil, "OVERLAY", "bdConfig_font")
	list.text:SetPoint("TOPLEFT", content, "TOPLEFT", lib.dimensions.padding, -lib.dimensions.padding)
	list.text:SetHeight(600)
	list.text:SetWidth(list:GetWidth() - (lib.dimensions.padding * 2))
	list.text:SetJustifyH("LEFT")
	list.text:SetJustifyV("TOP")
	list.text:SetText("test")

	button.OnClick = function()
		local value = insertbox:GetText()

		if (strlen(value) > 0) then
			container:add_remove(insertbox:GetText())
		end

		insertbox:SetText("")
		insertbox:ClearFocus()
	end


	container.callback = options.callback
	container.key = options.key
	container.list = list
	container.input = insertbox
	container.module = options.module
	Mixin(container, methods)
	container:populate()

	return container
end

lib:register_element("list", create)