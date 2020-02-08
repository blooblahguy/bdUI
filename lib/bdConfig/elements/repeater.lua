local parent, ns = ...
local lib = ns.bdConfig
-- local repeater_frames = CreateFramePool()

--========================================
-- Methods Here
--========================================
local methods = {
	-- frame pool functions
	['release_frames'] = function(self)
		self.children = {}
		for k, frame in pairs(self.pool) do
			frame.active = false
			frame:Hide()
		end
	end,
	['get_frame'] = function(self, type)
		for k, frame in pairs(self.pool) do
			if (not frame.active) then
				frame.active = true
				frame:Show()
				return frame
			end
		end

		-- create a new one
		local frame = lib:create_container({}, self, 30)
		frame.active = true
		return frame
	end,

	['remove_row'] = function(self, index)
		table.remove(self.save[self.key], index)

		self:populate()
	end,
	['add_row'] = function(self)
		self = self.parent
		local row = {}
		local index = #self.save[self.key]

		for k, arg in pairs(self.args) do
			arg.save = self.save
			table.insert(row, arg)
		end

		table.insert(self.save[self.key], row)

		self:populate()
	end,

	
	['populate'] = function(self)
		self:release_frames()
		for k, entry in pairs(self.save[self.key]) do
			-- print(k, entry)
		end

		-- for k, entry in pairs(self.save[self.key]) do
		-- 	local row = self:get_frame()
		-- 	print(row, entry)

		-- 	for i, arg in pairs(entry) do
		-- 		-- dump(arg)
		-- 		if (not row[arg.key]) then
		-- 			row[arg.key] = lib.elements[arg.type](arg, row)
		-- 		end
		-- 	end

		-- 	-- append to parent for sizing
		-- 	table.insert(self.children, row)
		-- end
	end
}

--========================================
-- Spawn Element
--========================================
local function create(options, parent)
	options.size = options.size or "full"

	-- Title
	table.insert(parent.children, lib.elements['heading']({value = options.label}, parent))

	local repeater = lib:create_container(options, parent, 30)
	local border = lib:get_border(repeater)
	repeater:SetBackdrop({bgFile = lib.media.flat, edgeFile = lib.media.flat, edgeSize = border})
	repeater:SetBackdropColor(0, 0, 0, 0.08)
	repeater:SetBackdropBorderColor(0, 0, 0, 0.15)
	repeater.pool = {}
	repeater.children = {}
	repeater.save = options.save
	repeater.key = options.key
	repeater.callback = options.callback
	repeater.args = options.args
	Mixin(repeater, methods)

	-- Placeholder
	local placeholder = repeater:CreateFontString(nil, "OVERLAY", "bdConfig_font")
	placeholder:SetText("Click the + to add a row")
	placeholder:SetPoint('CENTER')
	placeholder:SetAlpha(0.4)
	placeholder:SetScale(0.8)
	placeholder:SetJustifyH("CENTER")
	placeholder:SetJustifyV("MIDDLE")
	placeholder:SetWidth(repeater:GetWidth(2) / 2)

	-- Buttons
	local button = lib.elements['button']({solo = true}, repeater)
	button:SetText("+")
	button:SetHeight(20)
	button:SetPoint("BOTTOMRIGHT", repeater, "BOTTOMRIGHT", -2, -8)
	button.parent = repeater
	button.OnClick = repeater.add_row

	repeater:populate()

	return repeater

	-- local title = container:CreateFontString(nil, "OVERLAY", "bdConfig_font")
	-- title:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
	-- title:SetText(options.label)

	-- local button = bdConfig:create_button(container)
	-- button:SetText("Add")

	-- local insertbox = CreateFrame("EditBox", nil, container)
	-- insertbox:SetFontObject("bdConfig_font")
	-- insertbox:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
	-- insertbox:SetSize(container:GetWidth() - 66, 24)
	-- insertbox:SetTextInsets(6, 2, 2, 2)
	-- insertbox:SetMaxLetters(200)
	-- insertbox:SetHistoryLines(1000)
	-- insertbox:SetAutoFocus(false) 
	-- insertbox:SetScript("OnEnterPressed", function(self, key) button:Click() end)
	-- insertbox:SetScript("OnEscapePressed", function(self, key) self:ClearFocus() end)
	-- bdConfig:create_backdrop(insertbox)

	-- insertbox.alert = insertbox:CreateFontString(nil, "OVERLAY", "bdConfig_font")
	-- insertbox.alert:SetPoint("TOPRIGHT",container,"TOPRIGHT", -2, 0)
	-- function insertbox:startFade()
	-- 	local total = 0
	-- 	self.alert:Show()
	-- 	self:SetScript("OnUpdate",function(self, elapsed)
	-- 		total = total + elapsed
	-- 		if (total > 2.5) then
	-- 			self.alert:SetAlpha(self.alert:GetAlpha()-0.02)
				
	-- 			if (self.alert:GetAlpha() <= 0.05) then
	-- 				self:SetScript("OnUpdate", function() return end)
	-- 				self.alert:Hide()
	-- 			end
	-- 		end
	-- 	end)
	-- end

	-- button:SetPoint("TOPLEFT", insertbox, "TOPRIGHT", 0, 2)
	-- insertbox:SetSize(container:GetWidth() - button:GetWidth() + 2, 24)

	-- local list = CreateFrame("frame", nil, container)
	-- list:SetPoint("TOPLEFT", insertbox, "BOTTOMLEFT", 0, -2)
	-- list:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT")
	-- bdConfig:create_backdrop(list)

	-- local content = bdConfig:create_scrollframe(list)

	-- list.text = content:CreateFontString(nil, "OVERLAY", "bdConfig_font")
	-- list.text:SetPoint("TOPLEFT", content, "TOPLEFT", 5, 0)
	-- list.text:SetHeight(600)
	-- list.text:SetWidth(list:GetWidth() - 10)
	-- list.text:SetJustifyH("LEFT")
	-- list.text:SetJustifyV("TOP")
	-- list.text:SetText("test")
	

	-- -- show all config entries in this list
	-- function list:populate()
	-- 	local string = "";
	-- 	local height = 0;

	-- 	-- maintained list
	-- 	-- allows us to pass a list of variables that should be maintained inside of this listbox, but can be set to false and won't be added again
	-- 	if (info.autoadd or info.autoAdd or info.maintained) then
	-- 		local autoadd = info.autoadd or info.autoAdd or info.maintained -- alias
	-- 		for k, v in pairs(autoadd) do
	-- 			if (module.save[option][k] == nil) then
	-- 				module.save[option][k] = v
	-- 			end
	-- 		end
	-- 	end

	-- 	-- populated the saved options
	-- 	for k, v in pairs(module.save[option]) do
	-- 		if (v ~= false) then
	-- 			string = string..k.."\n";
	-- 			height = height + 14
	-- 		end
	-- 	end

	-- 	local scrollheight = (height - 200) 
	-- 	scrollheight = scrollheight > 1 and scrollheight or 1

	-- 	list.scrollbar:SetMinMaxValues(1, scrollheight)
	-- 	if (scrollheight == 1) then 
	-- 		list.scrollbar:Hide()
	-- 	else
	-- 		list.scrollbar:Show()
	-- 	end

	-- 	list.text:SetHeight(height)
	-- 	list.text:SetText(string)
	-- end

	-- -- remove or add something, then redraw the text
	-- function list:addRemove(value)
	-- 	if (module.save[option][value]) then
	-- 		insertbox.alert:SetText(value.." removed")
	-- 		module.save[option][value] = false
	-- 	else
	-- 		insertbox.alert:SetText(value.." added")
	-- 		-- @todo pass in table or integer values here to alter display
	-- 		module.save[option][value] = true
	-- 	end
	-- 	insertbox:startFade()
		
	-- 	self:populate()
	-- 	info:callback()

	-- 	-- clear aura cache
	-- 	bdCore.caches.auras = {}
	-- end

	-- button.OnClick = function()
	-- 	local value = insertbox:GetText()

	-- 	if (strlen(value) > 0) then
	-- 		list:addRemove(insertbox:GetText())
	-- 	end

	-- 	insertbox:SetText("")
	-- 	insertbox:ClearFocus()
	-- end

	-- list:populate()

	-- return container
end

lib:register_container("repeater", create)