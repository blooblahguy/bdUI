local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("New Bags")
mod.dropdowns = 1
mod.draggers = 1

local function dropdown_click(self, arg1, arg2, checked)
	print(self, arg1, arg2, checked)
end

local dragger_methods = {
	['click'] = function(self, ...)
		local type, id, info = GetCursorInfo()
		ClearCursor()
		local cat_name = self:GetParent().name

		local index = mod:has_value(mod.categories[cat_name].conditions.itemids, id)
		if (index) then
			mod.categories[cat_name].conditions.itemids[index] = nil
		else
			table.insert(mod.categories[cat_name].conditions.itemids, id)
		end


		mod.show_all = false
		mod:update_bags()
	end,
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
		dragger.BattlepayItemTexture:Hide()
		dragger.UpgradeIcon:Hide()
		dragger.IconBorder:Hide()
		dragger:SetNormalTexture("")
		dragger:SetPushedTexture("")
		dragger.flash:SetAllPoints()
		-- dragger:Show()

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
		overlay:Hide()
		dragger.overlay = overlay
		
		SetItemButtonTexture(dragger, [[Interface\BUTTONS\UI-EmptySlot]])

		dragger:RegisterEvent("ITEM_LOCK_CHANGED")
		dragger:SetScript("OnEvent", function(self, ...)
			local type, id, info = GetCursorInfo()
			
			if (type == "item") then
				dragger:RegisterEvent("CURSOR_UPDATE")
				dragger:UnregisterEvent("ITEM_LOCK_CHANGED")
				self:Show()
				overlay:Show()
				mod.show_all = true
				mod:draw_bags()

				local cat_name = self:GetParent().name
				local index = mod:has_value(mod.categories[cat_name].conditions.itemids, id)
				if (index) then
					self.overlay:SetVertexColor(1, 0, 0, 0.3)
				else
					self.overlay:SetVertexColor(0, 1, 0, 0.3)
				end
			else
				dragger:UnregisterEvent("CURSOR_UPDATE")
				dragger:RegisterEvent("ITEM_LOCK_CHANGED")
				self:Hide()
				overlay:Hide()
				mod.show_all = false
				mod:draw_bags()
			end
		end)

		bdUI:set_backdrop(dragger)
		Mixin(dragger, dragger_methods)

		self.dragger = dragger
	end,
	['create_text'] = function(self)
		local header = CreateFrame("button", nil, self)
		header:SetPoint("TOPLEFT", self, "TOPLEFT")
		header:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, -28)

		local text = header:CreateFontString(nil, "OVERLAY")
		text:SetFont(bdUI.media.font, 13, "OUTLINE")
		text:SetPoint("TOPLEFT", header, "TOPLEFT", 8, -10)
		text:SetAlpha(0.7)

		header:SetScript("OnEnter", function()
			text:SetAlpha(0.9)
		end)
		header:SetScript("OnLeave", function()
			text:SetAlpha(0.7)
		end)
		header:SetScript("OnMouseDown", function()
			text:SetPoint("TOPLEFT", header, "TOPLEFT", 8, -11)
		end)
		header:SetScript("OnMouseUp", function()
			text:SetPoint("TOPLEFT", header, "TOPLEFT", 8, -10)
		end)

		self.header = header
		self.text = text
	end,
	['create_container'] = function(self)
		local container = CreateFrame("frame", nil, self)
		container:SetPoint("TOPLEFT", self.header, "BOTTOMLEFT", 12, -4)

		self.container = container
	end,
	["create_dropdown"] = function(self)
		local name = "bdBagsCategoryDropdown"..mod.dropdowns
		mod.dropdowns = mod.dropdowns + 1

		-- local arrow = CreateFrame("button", nil, self)
		-- arrow:SetPoint("TOPRIGHT", self, "TOPRIGHT", -4, -10)
		-- arrow:SetSize(16, 16)
		-- arrow:SetBackdrop({bgFile = bdUI.media.flat})
		-- arrow:SetBackdropColor(0, 0, 0, 1)
		-- arrow.texture = arrow:CreateTexture()
		-- arrow.texture:SetPoint("CENTER", arrow, 0, -1)
		-- arrow.texture:SetSize(12, 7)
		-- arrow.texture:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up", 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
		-- arrow.texture:SetTexCoord(.25, 0.72, 0.45, 0.68)
		-- arrow.texture:SetDesaturated(true)
		-- arrow.texture:SetBlendMode("BLEND")
		-- arrow:SetScript("OnEnter", function(self) self.texture:SetDesaturated(false) end)
		-- arrow:SetScript("OnLeave", function(self) self.texture:SetDesaturated(true) end)
		-- self.arrow = arrow

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

				local entry = {
					text = name
					, notCheckable = false
					, keepShownOnClick = true
					, value = ids
					, checked = checked
					, arg1 = name
					, arg2 = ids
					, func = dropdown_click
				}

				table.insert(types_menu, entry)
			end

			local menu = {
				{ text = cat_name, isTitle = true, notCheckable = true }
				, { text = "Rename", notCheckable = true }
				, { text = "Item Types", notCheckable = true, keepShownOnClick = true, hasArrow = true, menuList = types_menu}
				-- , { text = "Item Quality", notCheckable = false, keepShownOnClick = true, hasArrow = true, menuList = types_menu}
			}

			return menu
		end

		-- hook to header click
		self.header:SetScript("OnClick", function()
			if (dropdown.is_shown) then
				dropdown.is_shown = false
				HideDropDownMenu(1, nil, dropdown, self.header, 0, 0);
			else
				dropdown.is_shown = true
				local menu = dropdown:get_options()
				EasyMenu(menu, dropdown, self.header, 0 , 0, "MENU");
			end
		end)
	end,
	['update_size'] = function(self, width, height)
		if (width < 124) then width = 124 end
		self.container:SetSize(width, height)
		self:SetSize(width + 20, height + self.dragger:GetHeight() + 20)
	end
}

--===============================================
-- CATEGORY POOL FUNCTIONS
--===============================================
mod.category_pool_create = function(self)
	local frame = CreateFrame("frame", nil, mod.current_parent)
	frame:SetSize(124, 30)
	Mixin(frame, category_methods)

	frame:create_text()
	frame:create_dropdown()
	frame:create_dragger()
	frame:create_container()

	return frame
end
mod.category_pool_reset = function(self, frame)
	frame:ClearAllPoints()
	frame:SetParent(mod.current_parent)
	frame.text:SetText("")
	frame:Hide()
end

--===============================================
-- CATEGORY FUNCTIONS
--===============================================
function mod:position_categories(options)

end
function mod:delete_category(name)

end
function mod:create_category(name, options)
	order = options.order or #mod.categories + 1
	if (mod.categories[name]) then return end

	mod.categories[name] = {}
	local category = mod.categories[name]

	-- default condition fillers
	local conditions = {}
	conditions['type'] = {}
	conditions['subtype'] = {}
	conditions['ilvl'] = 0
	conditions['expacID'] = 0
	conditions['rarity'] = 0
	conditions['minlevel'] = 0
	conditions['duplicate'] = false
	conditions['autohide'] = true
	conditions['itemids'] = {}
	for k, v in pairs(options) do conditions[k] = v end

	category.conditions = conditions
	category.name = name
	category.order = order
	category.locked = options.locked
	category.brand_new = not options.default
end
