local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Smart Bags (beta)")

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
	for categoryID, items in spairs(categories, function(a, b)
		return a < b
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

		-- now position items inside of frame
		for itemname, iteminfo in pairs(items) do
			local name, bag, slot, itemLink, itemID, texture, itemCount, itemSubClassID, bagID = unpack(iteminfo)
			local item = mod.current_parent.item_pool:Acquire()
			item:Show()
			item:SetSize(buttonsize, buttonsize)

			item.bag = bag
			item.bagID = bagID
			item.slot = slot
			item.itemLink = itemLink
			item.itemCount = itemCount
			item.texture = texture
			item.itemID = itemID

			item:update()

			if (not last_item) then
				item:SetPoint("TOPLEFT", cat, mod.spacing/3, -mod.spacing/3)
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
	-- figure out how wide the bag can be
	local max_width = ((buttonsize + mod.border) * buttonsperrow) - mod.border

	-- loop through categories first
	local row_width = 0
	local first_cat = nil
	local last_cat = nil
	local last_cat_row = nil
	local cat_rows = 0
	local max_cols = 0

	for categoryID, items in spairs(categories, function(a, b)
		return a < b
	end) do
		local cat = last_draw[categoryID]

		-- too see how wide we should make the total bag
		max_cols = math.max(max_cols, cat.columns)

		-- size this category based on item dimensions
		local category_width, category_height = mod:frame_size(buttonsize, cat.rows, cat.columns)
		cat:SetSize(category_width, category_height)

		-- store how wide this row is ending up
		row_width = row_width + category_width + buttonsize + (mod.border * 2)

		-- now position based on if we can stack
		if (not last_cat) then
			cat:SetPoint("TOPLEFT", mod.current_parent, mod.spacing/2, -mod.spacing * 1.5)
			last_cat_row = cat
			first_cat = cat
			cat_rows = cat_rows + 1
		elseif (row_width < max_width) then
			cat:SetPoint("LEFT", last_cat, "RIGHT", buttonsize + (mod.border * 2), 0)
		else
			cat:SetPoint("TOPLEFT", last_cat_row, "BOTTOMLEFT", 0, -24)
			last_cat_row = cat
			row_width = category_width + (mod.spacing / 2)
			cat_rows = cat_rows + 1
		end

		last_cat = cat
	end

	mod.current_parent:SetWidth(max_cols * (buttonsize + mod.border) + mod.spacing + (mod.spacing / 2) + mod.border)
	local bag_width, categories_height = mod:measure("TOPLEFT", first_cat, "BOTTOMRIGHT", last_cat)
	mod.current_parent:SetHeight(categories_height + mod.spacing + (mod.spacing / 2) + mod.border + (mod.spacing))
end