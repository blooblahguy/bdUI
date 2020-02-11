local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("New Bags")

mod.bags = mod:create_container("Bags", 0, 4)
mod.bags.cat_pool = CreateObjectPool(mod.category_pool_create, mod.category_pool_reset)
mod.bags.item_pool = CreateObjectPool(mod.item_pool_create, mod.item_pool_reset)

function mod:create_bags()
	mod.bags:Show()
	mod.bags:SetPoint("BOTTOMRIGHT", bdParent, "BOTTOMRIGHT", -30, 30)

	mod.bags.category_items = {}

	mod.bags:RegisterEvent('EQUIPMENT_SWAP_PENDING')
	mod.bags:RegisterEvent('EQUIPMENT_SWAP_FINISHED')
	mod.bags:RegisterEvent('AUCTION_MULTISELL_START')
	mod.bags:RegisterEvent('AUCTION_MULTISELL_UPDATE')
	mod.bags:RegisterEvent('AUCTION_MULTISELL_FAILURE')
	mod.bags:RegisterEvent('BAG_UPDATE_DELAYED')

	mod.bags.open = function(self)
		mod.bags:Show()
	end
	mod.bags.close = function(self)
		mod.bags:Hide()
	end
	mod.bags.toggle = function(self)
		mod.bags:SetShown(not mod.bags:IsShown())
	end

	-- hooksecurefunc("OpenAllBags", mod.bags.open)
	-- hooksecurefunc("OpenBag", mod.bags.open)
	-- hooksecurefunc("OpenBackpack", mod.bags.open)

	-- hooksecurefunc("ToggleBackpack", mod.bags.toggle)
	-- hooksecurefunc("ToggleAllBags", mod.bags.toggle)
	-- hooksecurefunc("ToggleBag", mod.bags.toggle)

	-- hooksecurefunc("CloseAllBags", mod.bags.close)
	-- hooksecurefunc('CloseSpecialWindows', mod.bags.close)
	-- hooksecurefunc("CloseBag", mod.bags.close)
	-- hooksecurefunc("CloseBackpack", mod.bags.close)


	mod.bags:SetScript("OnEvent", function(self, event, arg1)
		if (event == "EQUIPMENT_SWAP_PENDING" or event == "AUCTION_MULTISELL_START") then
			self.paused = true
		elseif (event == "EQUIPMENT_SWAP_FINISHED" or event == "AUCTION_MULTISELL_FAILURE") then
			self.paused = false
			mod:update_bags()
		else
			if (self.paused) then return end
			mod:update_bags()
		end
	end)

	-- create shortcut category bar
end


--==================================
-- update item tables
--==================================
function mod:update_bags()
	bdUI:profile_start("bags", "update bags", 2)
	local items = {}
	local remove = {}
	local new_items = {}
	local item_weights = {}
	local open_slots = 0
	mod.bags.category_items = {}

	-- first gather all items up
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			local texture, itemCount, locked, quality, readable, lootable, itemLink = GetContainerItemInfo(bag, slot);
			local itemID = mod:item_id(itemLink)
			if (texture) then 
				items[#items + 1] = {itemLink, bag, slot, itemID}

				-- add to new items category
				if (C_NewItems.IsNewItem(bag, slot)) then
					if (quality > 0) then
						new_items[#new_items + 1] = {itemLink, bag, slot, itemID}
					end
				end
			else
				open_slots = open_slots + 1
			end
		end
	end

	-- build item category weight table
	for category_name, category in pairs(mod.categories) do
		mod.bags.category_items[category_name] = {}
		local conditions = category.conditions
		for k = 1, #items do
			v = items[k]

			-- item information
			local itemLink, bag, slot, itemID = unpack(v)
			local name, link, rarity, ilvl, minlevel, itemtype, subtype, count, itemEquipLoc, icon, price, itemTypeID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo(itemLink)

			if (rarity == nil or rarity > 0) then
				item_weights[k] = item_weights[k] or {0, nil}
				local current_weight, parent_category = unpack(item_weights[k])
				local new_weight = 0

				-- evaluate conditions
				if (mod:has_value(conditions['type'], itemTypeID)) then new_weight = new_weight + 1 end -- weight: 1
				if (mod:has_value(conditions['subtype'], itemSubClassID)) then new_weight = new_weight + 1 end -- weight: 1
				if (mod:has_value(conditions['itemids'], itemID)) then new_weight = new_weight + 10 end -- weight: 10

				if (current_weight < new_weight) then
					item_weights[k] = {new_weight, category_name}
				end
			else
				remove[#remove + 1] = k
			end
		end
	end

	-- now loop through categories items that we've weighted out, assign them to their categories
	for k, v in pairs(item_weights) do
		local weight, parent_category = unpack(v)

		if (weight > 0) then
			local itemLink, bag, slot, itemID = unpack(items[k])
			local count = #mod.bags.category_items[parent_category]
			mod.bags.category_items[parent_category][count + 1] = {itemLink, bag, slot, itemID}
			remove[#remove + 1] = k
		end
	end

	--=====================
	-- remove what we've used
	--=====================
	for k = 1, #remove do
		items[remove[k]] = nil
	end

	--=====================
	-- didn't find these items
	--=====================
	for k, v in pairs(items) do
		-- local itemLink, bag, slot, itemID = unpack(items[k])
		-- local name, link, rarity, ilvl, minlevel, itemtype, subtype, count, itemEquipLoc, icon, price, itemTypeID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo(itemLink)
		local count = #mod.bags.category_items["Uncategorized"]
		mod.bags.category_items["Uncategorized"][count + 1] = items[k]
	end

	--=====================
	-- Add New Items to New Category
	--=====================
	for k, v in ipairs(new_items) do
		-- local itemLink, bag, slot, itemID = unpack(new_items[k])
		-- local name, link, rarity, ilvl, minlevel, itemtype, subtype, count, itemEquipLoc, icon, price, itemTypeID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo(itemLink)
		local count = #mod.bags.category_items["New Items"]
		mod.bags.category_items["New Items"][count + 1] = items[k]
	end

	bdUI:profile_stop("bags", "update bags", 2)

	mod:draw_bags()
end


--==================================
-- draw the bags and categories
--==================================
function mod:draw_bags()
	bdUI:profile_start("bags", "draw bags", 2)

	mod.bags.cat_pool:ReleaseAll() -- release frame pool
	mod.bags.item_pool:ReleaseAll() -- release frame pool
	mod.current_parent = mod.containers["bags"] -- set this to parent the category frames correctly

	-- row functionality
	local lastCategoryRow, lastCategory
	local categoryCols = math.floor(mod:table_count(mod.categories) / 2)
	local categoryIndex = 1

	local loop_cats = {}
	for k, category in pairs(mod.categories) do
		if ((mod.show_all and not category.locked) or category.brand_new or #mod.bags.category_items[category.name] > 0) then
			loop_cats[k] = category
		end
	end

	-- loop through categories and position them
	mod:position_objects({
		["table"] = loop_cats,
		["pool"] = mod.bags.cat_pool,
		["columns"] = 2,
		["parent"] = mod.bags.container,
		["loop"] = function(frame, i, category)
			if (#mod.bags.category_items[category.name] > 0) then mod.categories[category.name].brand_new = false end
			frame.text:SetText(category.name:upper())
			category.frame = frame
			frame.category = category
			frame.name = category.name

			-- now loop through items
			mod:position_objects({
				["table"] = mod.bags.category_items[category.name],
				["pool"] = mod.bags.item_pool,
				["columns"] = 6,
				["parent"] = frame.container,
				["loop"] = function(button, i, itemInfo)
					local itemLink, bag, slot, itemID = unpack(itemInfo)

					button:SetParent(mod.bag_frames[bag])
					button:SetID(slot)
					button.bag = bag
					button.slot = slot
					button.itemLink = itemLink
					button.itemID = itemID

					button:full_update()
				end,
				["callback"] = function(width, height)
					frame:update_size(width, height)
				end
			})
		end,
		["callback"] = function(width, height)
			mod.bags:update_size(width, height)
		end
	})

	bdUI:profile_stop("bags", "draw bags", 2)
end