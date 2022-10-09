local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Bags")

local last_item = nil
local last_row = nil
local first_item = nil
local row_items = 0
local last_draw = {}

function mod:position_items(categories, buttonsize, buttonsperrow)
	local config = mod.config

	mod.current_parent.item_pool:ReleaseAll() -- release frame pool
	mod.current_parent.cat_pool:ReleaseAll() -- release frame pool

	-- positional vars
	last_draw = {}

	local cat = {}
	cat.last_item = nil

	local row = {}
	row.first_item = nil
	row.num_items = 0
	row.num_rows = 1

	mod.current_parent.all_items = {}

	local last_item = nil
	local last_cat = nil

	local row_spacing = config.showlabels and mod.spacing * 2 or mod.spacing

	-- loop through categories first
	for categoryID, items in bdUI:spairs(categories, function(a, b)
		return tonumber(a) < tonumber(b)
	end) do
		local cat = mod.current_parent.cat_pool:Acquire()
		-- print(mod.current_parent:GetName(), "acquire")
		cat:Show()
		cat.positioned = false
		cat:SetSize(buttonsize * 2, buttonsize)
		last_draw[categoryID] = cat

		-- set cat text and show or hide
		-- cat.text:SetText(mod.categoryIDtoNames[categoryID])
		-- if (categoryID == -1) then
		-- 	cat.text:SetTextColor(0.6, 0.6, 1)
		-- else
		-- 	cat.text:SetTextColor(1, 1, 1)
		-- end
		-- cat.text:Show()
		-- if (categoryID == -2) then
		-- 	cat.text:Hide()
		-- else
		-- end

		local new_cat = true
		if (row.num_items > 0) then
			row.num_items = row.num_items + 1
		end
		
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

			-- item = Mixin(item, itemInfo) -- why doesn't this work for the blank items?
			item.name = itemInfo.name
			item.bag = itemInfo.bag
			item.bagID = itemInfo.bagID
			item.slot = itemInfo.slot
			item.itemLink = itemInfo.itemLink
			item.itemLevel = itemInfo.itemLevel
			item.bindType = itemInfo.bindType
			item.itemType = itemInfo.itemType
			item.itemCount = itemInfo.itemCount
			item.texture = itemInfo.texture
			item.itemID = itemInfo.itemID
			item.rarity = itemInfo.rarity
			item.tradeable = mod:is_item_tradeable(itemInfo.itemLink) and "tradeable" or ""

			table.insert(mod.current_parent.all_items, item)

			-- now update the button appearance with new info
			item:update()

			-- start positioning
			if (not last_item) then
				local top_spacing = config.showlabels and mod.spacing * 1.5 or mod.spacing * 0.5
				item:SetPoint("TOPLEFT", mod.current_parent.header, "BOTTOMLEFT", mod.spacing, -top_spacing)
				if (not cat.positioned) then
					cat:SetPoint("TOPLEFT", item)
					cat.positioned = true
				end
				if (config.showlabels) then
					item.text:Show()
					item.text:SetText(mod.categoryIDtoNames[categoryID])
				end

				new_cat = false
				row.num_items = 0 -- reset row count
				row.first_item = item -- this is the first item of this row
			elseif (row.num_items > buttonsperrow) then -- new row
				item:SetPoint("TOPLEFT", row.first_item, "BOTTOMLEFT", 0, -row_spacing)
				if (not cat.positioned) then
					cat:SetPoint("TOPLEFT", item)
					cat.positioned = true
				end
				if (config.showlabels) then
					item.text:Show()
					item.text:SetText(mod.categoryIDtoNames[categoryID])
				end

				new_cat = false
				row.num_items = 0 -- reset row count
				row.first_item = item -- this is the first item of this row
				row.num_rows = row.num_rows + 1
			elseif (new_cat) then -- new category
				item:SetPoint("TOPLEFT", last_item, "TOPRIGHT", buttonsize + mod.border * 2, 0)
				if (not cat.positioned) then
					cat:SetPoint("TOPLEFT", item)
					cat.positioned = true
				end
				if (config.showlabels) then
					item.text:Show()
					item.text:SetText(mod.categoryIDtoNames[categoryID])
				end

				new_cat = false
			else
				item:SetPoint("TOPLEFT", last_item, "TOPRIGHT", mod.border, 0)
			end

			-- store this so we know where to jump from
			last_cat = cat
			last_item = item
			cat.last_item = item
			row.num_items = row.num_items + 1

			-- if (not last) then
			-- 	item:SetPoint("TOPLEFT", mod.current_parent, 0, -30)
			-- 	row_btn = item
			-- elseif (num_row > buttonsperrow) then
			-- 	item:SetPoint("TOPLEFT", row_btn, "BOTTOMLEFT", 0, -20)
			-- 	row_btn = item
			-- 	num_row = 0
			-- else
			-- 	item:SetPoint("TOPLEFT", last, "TOPRIGHT", 2, 0)
			-- end

			-- last = item
			-- num_row = num_row + 1

			-- if (not last_item) then
			-- 	item:SetPoint("TOPLEFT", cat)
			-- 	first_item = item
			-- elseif (row_items >= buttonsperrow) then
			-- 	item:SetPoint("TOPLEFT", last_row or first_item, "BOTTOMLEFT", 0, -mod.border)
			-- 	row_items = 0
			-- 	last_row = item
			-- 	cat.rows = cat.rows + 1
			-- else
			-- 	item:SetPoint("LEFT", last_item, "RIGHT", mod.border, 0)
			-- end

			-- if (cat.columns < buttonsperrow) then
			-- 	cat.columns = cat.columns + 1
			-- end

			-- last_item = item
			-- row_items = row_items + 1
		end
	end

	mod.current_parent:SetWidth(mod.spacing * 2 + (buttonsperrow + 1) * (buttonsize + mod.border))
	-- local bag_width, categories_height = mod:measure("TOPLEFT", mod.current_parent.header, "BOTTOMRIGHT", last_cat)
	mod.current_parent:SetHeight(mod.spacing * 2 + row.num_rows * (buttonsize + mod.border + row_spacing))
end

function mod:position_categories(categories, buttonsize, buttonsperrow)
	-- local config = mod.config
	-- -- figure out how wide the bag can be
	-- local max_width = ((buttonsize + mod.border) * buttonsperrow) - mod.border
	-- local extraheight = mod.spacing

	-- -- loop through categories first
	-- local row_width = 0
	-- local first_cat = nil
	-- local last_cat = nil
	-- local last_cat_row = nil
	-- local longest_row = 0
	-- local current_row = 0

	-- for categoryID, items in bdUI:spairs(categories, function(a, b)
	-- 	return tonumber(a) < tonumber(b)
	-- end) do
	-- 	local cat = last_draw[categoryID]
	-- 	-- print(items, #items)

	-- 	-- size this category based on item dimensions
	-- 	local category_width, category_height = mod:frame_size(buttonsize, cat.rows, cat.columns)
	-- 	cat:SetSize(category_width + 6, category_height + 6)

	-- 	-- store how wide this row is ending up
	-- 	row_width = row_width + category_width + buttonsize + (mod.spacing * 2)

	-- 	-- now position based on if we can stack
	-- 	if (not last_cat) then
	-- 		if config.showfreespaceasone then
	-- 			cat:SetPoint("TOPLEFT", mod.current_parent, mod.spacing, -mod.spacing * 3.5)
	-- 		else
	-- 			cat:SetPoint("TOPLEFT", mod.current_parent, mod.spacing, -mod.spacing * 2.5)
	-- 		end
	-- 		last_cat_row = cat
	-- 		first_cat = cat

	-- 		current_row = category_width
	-- 	elseif (row_width < max_width) then
	-- 		cat:SetPoint("LEFT", last_cat, "RIGHT", buttonsize + (mod.border * 2), 0)
	-- 		current_row = current_row + category_width + buttonsize
	-- 	else
	-- 		cat:SetPoint("TOPLEFT", last_cat_row, "BOTTOMLEFT", 0, -24)
	-- 		last_cat_row = cat
	-- 		row_width = category_width + (mod.spacing / 2)
	-- 		current_row = category_width
	-- 	end

	-- 	last_cat = cat

	-- 	-- too see how wide we should make the total bag
	-- 	longest_row = math.max(current_row, longest_row)
	-- end

	-- if (mod.current_parent.currencies) then
	-- 	extraheight = extraheight + mod.current_parent.currencies:GetHeight() + mod.spacing - mod.border
	-- end

	-- -- mod.current_parent:SetWidth(max_cols * (buttonsize + mod.border) + mod.spacing + (mod.spacing / 2) + mod.border)
	-- mod.current_parent:SetWidth(longest_row + (mod.spacing * 2))
	-- local bag_width, categories_height = mod:measure("TOPLEFT", mod.current_parent.header, "BOTTOMRIGHT", last_cat)
	-- mod.current_parent:SetHeight(categories_height + extraheight)
end