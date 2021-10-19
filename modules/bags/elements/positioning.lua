local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Bags")

local last_item = nil
local last_row = nil
local first_item = nil
local row_items = 0
local last_draw = {}

function mod:position_items(categories, buttonsize, buttonsperrow)
	mod.current_parent.item_pool:ReleaseAll() -- release frame pool
	mod.current_parent.cat_pool:ReleaseAll() -- release frame pool

	-- positional vars
	last_draw = {}

	-- loop through categories first
	for categoryID, items in bdUI:spairs(categories, function(a, b)
		return tonumber(a) < tonumber(b)
	end) do
		local cat = mod.current_parent.cat_pool:Acquire()
		cat:Show()
		last_draw[categoryID] = cat

		-- set cat text and show or hide
		cat.text:SetText(mod.categoryIDtoNames[categoryID])
		if (categoryID == -1) then
			cat.text:SetTextColor(0.6, 0.6, 1)
		else
			cat.text:SetTextColor(1, 1, 1)
		end
		if (categoryID == -2) then
			cat.text:Hide()
		else
			cat.text:Show()
		end
		
		last_item = nil
		last_row = nil
		first_item = nil
		row_items = 0

		cat.rows = 1
		cat.columns = 0
		
		-- sort automatically, we don't need no stinking manual sort
		table.sort(items, function(a, b)
			if (a.itemLink == nil and b.itemLink == nil) then return end
			-- sort by rarity
			if (a.rarity ~= b.rarity) then return a.rarity > b.rarity end
			-- sort by equip
			if (a.itemEquipLoc ~= b.itemEquipLoc) then return a.itemEquipLoc < b.itemEquipLoc end
			-- sort by subTypeID
			if (a.itemSubTypeID ~= b.itemSubTypeID) then return a.itemSubTypeID < b.itemSubTypeID end
			-- sort by name
			if (a.name ~= b.name) then return a.name < b.name end
			-- sort by stacks
			if (a.itemCount ~= b.itemCount) then return a.itemCount > b.itemCount end

			return a.name < b.name
		end)

		-- now position items inside of frame
		for itemName, itemInfo in pairs(items) do
			local item = mod.current_parent.item_pool:Acquire()
			item:Show()
			item:SetSize(buttonsize, buttonsize)

			item.bag = itemInfo.bag
			item.bagID = itemInfo.bagID
			item.slot = itemInfo.slot
			item.itemLink = itemInfo.itemLink
			item.itemCount = itemInfo.itemCount
			item.texture = itemInfo.texture
			item.itemID = itemInfo.itemID

			-- now update the button appearance with new info
			item:update()

			if (not last_item) then
				item:SetPoint("TOPLEFT", cat)
				first_item = item
			elseif (row_items >= buttonsperrow) then
				item:SetPoint("TOPLEFT", last_row or first_item, "BOTTOMLEFT", 0, -mod.border)
				row_items = 0
				last_row = item
				cat.rows = cat.rows + 1
			else
				item:SetPoint("LEFT", last_item, "RIGHT", mod.border, 0)
			end

			if (cat.columns < buttonsperrow) then
				cat.columns = cat.columns + 1
			end

			last_item = item
			row_items = row_items + 1
		end
	end
end

function mod:position_categories(categories, buttonsize, buttonsperrow)
	local config = mod.config
	-- figure out how wide the bag can be
	local max_width = ((buttonsize + mod.border) * buttonsperrow) - mod.border
	local extraheight = mod.spacing

	-- loop through categories first
	local row_width = 0
	local first_cat = nil
	local last_cat = nil
	local last_cat_row = nil
	local longest_row = 0
	local current_row = 0

	for categoryID, items in bdUI:spairs(categories, function(a, b)
		return tonumber(a) < tonumber(b)
	end) do
		local cat = last_draw[categoryID]

		-- size this category based on item dimensions
		local category_width, category_height = mod:frame_size(buttonsize, cat.rows, cat.columns)
		cat:SetSize(category_width, category_height)

		-- store how wide this row is ending up
		row_width = row_width + category_width + buttonsize + (mod.spacing * 2)

		-- now position based on if we can stack
		if (not last_cat) then
			if config.showfreespaceasone then
				cat:SetPoint("TOPLEFT", mod.current_parent, mod.spacing, -mod.spacing * 3.5)
			else
				cat:SetPoint("TOPLEFT", mod.current_parent, mod.spacing, -mod.spacing * 2.5)
			end
			last_cat_row = cat
			first_cat = cat

			current_row = category_width
		elseif (row_width < max_width) then
			cat:SetPoint("LEFT", last_cat, "RIGHT", buttonsize + (mod.border * 2), 0)
			current_row = current_row + category_width + buttonsize
		else
			cat:SetPoint("TOPLEFT", last_cat_row, "BOTTOMLEFT", 0, -24)
			last_cat_row = cat
			row_width = category_width + (mod.spacing / 2)
			current_row = category_width
		end

		last_cat = cat

		-- too see how wide we should make the total bag
		longest_row = math.max(current_row, longest_row)
	end

	if (mod.current_parent.currencies) then
		extraheight = extraheight + mod.current_parent.currencies:GetHeight() + mod.spacing - mod.border
	end

	-- mod.current_parent:SetWidth(max_cols * (buttonsize + mod.border) + mod.spacing + (mod.spacing / 2) + mod.border)
	mod.current_parent:SetWidth(longest_row + (mod.spacing * 2))
	local bag_width, categories_height = mod:measure("TOPLEFT", mod.current_parent.header, "BOTTOMRIGHT", last_cat)
	mod.current_parent:SetHeight(categories_height + extraheight)
end