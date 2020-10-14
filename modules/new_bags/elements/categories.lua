local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Bags (beta)")
mod.dropdowns = 1
mod.draggers = 1

--===============================
-- Category Delete
--===============================
local function category_delete(self, arg1, arg2)
	-- mod.categories[arg1].frame:Hide()
	mod.bags.cat_pool:Release(frame)
	-- mod.bank.cat_pool:Release()
	mod.categories[arg1] = nil

	mod:update_bags()
end
--===============================
-- Category Rename Box
--===============================
StaticPopupDialogs["BDBAGS_POPUP"] = {
	button1 = "Change",
	button2 = "Cancel",
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
	onCancel = function() end
}

local function category_rename(self, arg1, arg2, checked)
	StaticPopupDialogs["BDBAGS_POPUP"]["text"] = "Rename "..arg1
	StaticPopupDialogs["BDBAGS_POPUP"]["hasEditBox"] = true

	StaticPopupDialogs["BDBAGS_POPUP"]["OnShow"] = function(self, data)
		self.editBox:SetText(arg1)
	end
	StaticPopupDialogs["BDBAGS_POPUP"]["OnAccept"] = function(self, data, data2)
		local new_name = self.editBox:GetText()

		mod.categories[new_name] = mod.categories[arg1]
		mod.categories[new_name].name = new_name
		mod.categories[new_name].frame.name = new_name
		mod.categories[arg1] = nil

		mod:draw_bags()
	end

	StaticPopup_Show("BDBAGS_POPUP")
end

--===============================
-- Category Ordering
--===============================
local function move_up(self, arg1, arg2, checked)
	-- sort categories
	local categories = mod:get_visible_categories()

	for i = 1, #categories do
		local category = categories[i]
		-- swap position with the previous element
		if (category.name == arg1) then
			if (not categories[i - 1]) then return end
			local prev_order = categories[i - 1].order
			local order = category.order

			category.order = prev_order
			categories[i - 1].order = order

			break
		end
	end

	mod:draw_bags()
end
local function move_down(self, arg1, arg2, checked)
	-- sort categories
	local categories = mod:get_visible_categories()

	for i = 1, #categories do
		local category = categories[i]
		-- swap position with the previous element
		if (category.name == arg1) then
			if (not categories[i + 1]) then return end
			local prev_order = categories[i + 1].order
			local order = category.order

			category.order = prev_order
			categories[i + 1].order = order

			break
		end
	end

	mod:draw_bags()
end

--===============================
-- Category Filter Changing
--===============================
local function dropdown_click(self, name, button, checked)
	-- print(self, name, arg2, checked)
	local filter_ids = mod.types[name]
	local category = mod.categories[self.arg2].conditions.type

	-- print(name)
	-- print(name)
	-- print(filter_ids)
	-- dump(category.conditions)
	for i = 1, #filter_ids do
		local id = filter_ids[i]

		if (checked) then
			tinsert(category, id)
		elseif (mod:has_value(category, id)) then
			mod:remove_value(category, id)
		end
			
	end

	-- dump(category)

	mod:update_bags()
end

local dragger_methods = {
	['click'] = function(self, ...)
		local type, id, info = GetCursorInfo()
		local itemID = mod:item_id(info)
		local cat_name = self:GetParent().name

		-- local has = mod.categories[cat_name].conditions.itemids[itemID]
		local index = tIndexOf(mod.categories[cat_name].conditions.itemids, itemID)

		for name, category in pairs(mod.categories) do
			tDeleteItem(category.conditions.itemids, itemID)
		end

		if (not index) then
			tinsert(mod.categories[cat_name].conditions.itemids, itemID)
		end

		ClearCursor()
		mod:update_bags()
	end,
	["update"] = function(self)
		local type, id, info = GetCursorInfo()
		local itemID = mod:item_id(info)
		
		if (type == "item") then
			self:RegisterEvent("CURSOR_UPDATE")
			self:Show()
			
			local cat_name = self:GetParent().name
			if (cat_name) then
				local index = tIndexOf(mod.categories[cat_name].conditions.itemids, itemID)

				if (index) then
					self.overlay:SetVertexColor(1, 0, 0, 0.3)
				else
					self.overlay:SetVertexColor(0, 1, 0, 0.3)
				end

				if (not mod.show_all) then
					mod.show_all = true
					mod:draw_bags()					
				end
			end
		else
			self:UnregisterEvent("CURSOR_UPDATE")
			self:Hide()

			if (mod.show_all) then
				mod.show_all = false
				mod:draw_bags()
			end
		end
	end
}

local category_methods = {
	['create_dragger'] = function(self)
		local name = "bdBagsCategoryDragger"..mod.draggers
		mod.draggers = mod.draggers + 1

		local dragger = CreateFrame("ItemButton", name, self, "ContainerFrameItemButtonTemplate")
		dragger:ClearAllPoints()
		dragger:SetPoint("LEFT", self.text, "RIGHT", 4, 0)
		dragger:SetSize(22, 22)
		dragger:SetFrameLevel(27)
		dragger:SetScript('OnReceiveDrag', function(self) self:click() end)
		dragger:SetScript('OnClick', function(self) self:click() end)
		dragger:Hide()
		dragger.BattlepayItemTexture:Hide()
		dragger.UpgradeIcon:Hide()
		dragger.IconBorder:Hide()
		dragger:SetNormalTexture("")
		dragger:SetPushedTexture("")
		dragger.flash:SetAllPoints()
		bdUI:set_backdrop(dragger)
		Mixin(dragger, dragger_methods)

		local icon = _G[dragger:GetName().."IconTexture"]
		icon:SetAllPoints(dragger)
		icon:SetTexCoord(.3, .7, .3, .7)

		local hover = dragger:CreateTexture()
		hover:SetTexture(bdUI.media.flat)
		hover:SetVertexColor(1, 1, 1, 0.1)
		hover:SetAllPoints(dragger)
		dragger:SetHighlightTexture(hover)

		local overlay = dragger:CreateTexture()
		overlay:SetTexture(bdUI.media.flat)
		overlay:SetAllPoints(dragger)
		dragger.overlay = overlay
		
		SetItemButtonTexture(dragger, [[Interface\BUTTONS\UI-EmptySlot]])

		dragger:RegisterEvent("ITEM_LOCK_CHANGED")
		dragger:SetScript("OnEvent", dragger.update)
		-- self:SetScript("OnShow", dragger.update)

		return dragger
	end,
	['create_header'] = function(self)
		local header = CreateFrame("button", nil, self)
		header:SetPoint("TOPLEFT", self, "TOPLEFT")
		header:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, -26)

		return header
	end,
	['create_text'] = function(self)
		local text = self.header:CreateFontString(nil, "OVERLAY")
		text:SetFont(bdUI.media.font, 13, "OUTLINE")
		text:SetPoint("LEFT", self.header, "LEFT", self.spacing, 0)
		text:SetAlpha(0.7)

		self.header:SetScript("OnEnter", function()
			text:SetAlpha(0.9)
		end)
		self.header:SetScript("OnLeave", function()
			text:SetAlpha(0.7)
		end)
		self.header:SetScript("OnMouseDown", function()
			text:SetPoint("LEFT", self.header, "LEFT", self.spacing, -1)
		end)
		self.header:SetScript("OnMouseUp", function()
			text:SetPoint("LEFT", self.header, "LEFT", self.spacing, 0)
		end)

		return text
	end,
	['create_container'] = function(self)
		local container = CreateFrame("frame", nil, self)
		container:SetPoint("TOPLEFT", self.header, "BOTTOMLEFT", self.spacing+4, 0)

		return container
	end,
	["create_dropdown"] = function(self)
		local name = "bdBagsCategoryDropdown"..mod.dropdowns
		mod.dropdowns = mod.dropdowns + 1

		local dropdown = CreateFrame("Button", name, self, "UIDropDownMenuTemplate")
		dropdown:SetPoint("TOPRIGHT", arrow, "TOPRIGHT")
		dropdown:Hide()
		UIDropDownMenu_SetWidth(dropdown, self:GetWidth() - 20)
		UIDropDownMenu_JustifyText(dropdown, "LEFT")
		function dropdown:get_options(self)
			local cat_name = dropdown:GetParent().name
			local conditions = mod.categories[cat_name].conditions

			local types_menu = {}
			for name, ids in pairs(mod.types) do
				local checked = false
				if (mod:has_value(conditions.type, ids)) then
					checked = true
				end

				dropdown.test = "Hello"

				local entry = {
					text = name
					, notCheckable = false
					, keepShownOnClick = true
					, value = ids
					, checked = checked
					, arg1 = name
					, arg2 = cat_name
					, func = dropdown_click
				}

				table.insert(types_menu, entry)
			end

			local subtypes = {}

			local menu = {
				{ text = cat_name, isTitle = true, notCheckable = true }
				, { text = "Rename", notCheckable = true, func = category_rename, arg1 = cat_name }
				, { text = "Move Up", notCheckable = true, func = move_up, arg1 = cat_name, keepShownOnClick = false }
				, { text = "Move Down", notCheckable = true, func = move_down, arg1 = cat_name, keepShownOnClick = false }
				, { text = " ", notCheckable = true, notClickable = true }
				, { text = "Filters", isTitle = true, notCheckable = true }
				, { text = "Types", notCheckable = true, keepShownOnClick = true, hasArrow = true, menuList = types_menu}
				-- , { text = "Sub Types", notCheckable = true, keepShownOnClick = true, hasArrow = true, menuList = {}}
				, { text = " ", notCheckable = true, notClickable = true }
				, { text = "|cffff5555Delete|r", notCheckable = true, func = function(self, name) mod.categories[name] = nil mod:update_bags() end, arg1 = cat_name }
			}

			return menu
		end

		-- hook to header click
		self.header:SetScript("OnClick", function(...)
			-- print(...)
			if (dropdown.is_shown) then
				dropdown.is_shown = false
				HideDropDownMenu(1, nil, dropdown, self.header, 0, 0);
			else
				dropdown.is_shown = true
				local menu = dropdown:get_options()
				EasyMenu(menu, dropdown, self.header, 0 , 0, "MENU");
			end
		end)

		return dropdown
	end,
	['update_size'] = function(self, width, height)
		local config = mod.config
		if (width < config.bag_size) then width = config.bag_size end
		self.container:SetSize(width, height)
		self:SetSize(width + (self.spacing * 3), height + self.dragger:GetHeight() + self.spacing)
	end
}

--===============================================
-- CATEGORY POOL FUNCTIONS
--===============================================
mod.category_pool_create = function(self)
	local frame = CreateFrame("frame", nil, mod.current_parent)
	frame:SetSize(124, 30)
	frame.spacing = 8
	-- bdUI:set_backdrop(frame)
	Mixin(frame, category_methods)

	frame.header = frame:create_header()
	frame.text = frame:create_text()
	frame.dropdown = frame:create_dropdown()
	frame.dragger = frame:create_dragger()
	frame.container = frame:create_container()

	return frame
end
mod.category_pool_reset = function(self, frame)
	frame:ClearAllPoints()
	frame:SetParent(mod.current_parent)
	frame.text:SetText("")
	frame.name = false
	frame:Hide()
end

--===============================================
-- CATEGORY FUNCTIONS
--===============================================
function mod:delete_category(name)
	-- print(name)
end

local ordermax = 0
function mod:create_category(name, options)
	ordermax = math.max(options.order or 0, ordermax) + 1
	order = options.order or ordermax

	if (mod.categories[name]) then return end

	mod.categories[name] = {}
	local category = mod.categories[name]

	-- default condition fillers
	local conditions = {}
	conditions['type'] = {}
	conditions['subtype'] = {}
	conditions['ilvl'] = 0
	-- conditions['expacID'] = 0
	conditions['rarity'] = 0
	conditions['itemlvl'] = 0
	conditions['minlevel'] = 0
	-- conditions['duplicate'] = false
	-- conditions['autohide'] = true
	conditions['bindType'] = true
	conditions['itemids'] = {}
	for k, v in pairs(options) do conditions[k] = v end

	category.conditions = conditions
	category.name = name
	category.order = order
	category.locked = options.locked
	category.brand_new = not options.default
end

function mod:get_visible_categories()
	local loop_cats = {}
	
	-- find visible only
	for k, category in pairs(mod.categories) do
		if ((mod.show_all and not category.locked) or category.brand_new or #category.items > 0) then
			loop_cats[#loop_cats + 1] = category
			category.brand_new = false
		end
	end

	-- sort and reset index
	table.sort(loop_cats, function(a, b)
		return a.order < b.order
	end)

	for i = 1, #loop_cats do
		local category = loop_cats[i]
		category.order = i
	end

	return loop_cats
end

--===============================================
-- POSITION CATEGORIES
--===============================================
function mod:position_categories(parent, categories, pool)
	local config = mod.config

	local spacing = mod.border
	local max_width = ((config.bag_size + spacing) * config.bag_max_column) + 20
	for i = 1, #categories do
		max_width = math.max(categories[i].frame:GetWidth(), max_width)
	end

	local columns = {}
	local column = {}
	local last
	-- loop and position
	for i = 1, #categories do	
		local category = categories[i]
		local frame = category.frame

		if (not last) then
			frame:SetPoint("TOPLEFT", parent)

			column.header = frame
			column.left = frame
			column.row_width = frame:GetWidth()
			column.width = frame:GetWidth()
			column.height = frame:GetHeight()
		elseif (frame:GetWidth() + column.row_width < max_width) then
			frame:SetPoint("TOPLEFT", last, "TOPRIGHT")

			column.row_width = column.row_width + frame:GetWidth()
		elseif (column.height + frame:GetHeight() > config.bag_height) then
			frame:SetPoint("TOPLEFT", column.header, column.width + mod.border, 0)

			tinsert(columns, column)

			column = {}
			column.header = frame
			column.left = frame
			column.width = frame:GetWidth()
			column.row_width = frame:GetWidth()
			column.height = frame:GetHeight()
		else
			frame:SetPoint("TOPLEFT", column.left, "BOTTOMLEFT")

			column.left = frame
			column.row_width = frame:GetWidth()
			column.height = column.height + frame:GetHeight()
		end

		column.width = math.max(column.width, column.row_width)
		last = frame
	end

	-- now calculate bag dimensions
	local width, height = 0, 0
	tinsert(columns, column)
	for i = 1, #columns do
		local column = columns[i]
		width = width + (column.width or 0)
		height = math.max(height, column.height)
	end

	return width, height
end