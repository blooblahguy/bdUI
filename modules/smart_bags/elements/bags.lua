local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Smart Bags (beta)")

mod.categoryIDtoNames = {}
mod.categoryNamestoID = {}

-- bags
function mod:create_bags()
	mod.bags = mod:create_container("Bags")
	mod.bags.item_pool = CreateObjectPool(mod.item_pool_create, mod.item_pool_reset)
	mod.bags.cat_pool = CreateObjectPool(mod.category_pool_create, mod.category_pool_reset)

	

	-- mod.bags:RegisterEvent('EQUIPMENT_SWAP_PENDING')
	-- mod.bags:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
	-- mod.bags:RegisterEvent('AUCTION_MULTISELL_START')
	-- mod.bags:RegisterEvent('AUCTION_MULTISELL_UPDATE')
	-- mod.bags:RegisterEvent('AUCTION_MULTISELL_FAILURE')
	mod.bags:RegisterEvent('BAG_UPDATE_DELAYED')
	mod.bags:RegisterEvent('PLAYER_ENTERING_WORLD')

	mod.bags:SetScript("OnEvent", function(self, event, arg1)
		if (event == "PLAYER_ENTERING_WORLD") then
			-- create container items for bigger and better bags
			mod:create_bag_bagslots()
		else
			mod:update_bags()
		end
	end)
end

local categories = {}
function mod:update_bags()
	categories = {}

	-- first gather all items up
	for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		local min, max, step = GetContainerNumSlots(bag), 1, -1
		local freeslots, bagtype = GetContainerNumFreeSlots(bag)
		
		for slot = min, max, step do
			local texture, itemCount, locked, quality, readable, lootable, itemLink = GetContainerItemInfo(bag, slot)

			if (not itemLink) then
				mod.categoryIDtoNames[-2] = "Bag"
				mod.categoryNamestoID["Bag"] = -2

				-- store it in a category
				categories[-2] = categories[-2] or {}

				-- then store by categoryID with lots of info
				table.insert(categories[-2], {"", bag, slot, itemLink, itemID, texture, itemCount, itemSubTypeID, bag})
			elseif (itemLink and quality > 0) then
				local name, link, rarity, ilvl, minlevel, itemType, itemSubType, count, itemEquipLoc, icon, price, itemTypeID, itemSubTypeID, bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo(itemLink)
				local itemString = string.match(itemLink, "item[%-?%d:]+")
				local _, itemID = strsplit(":", itemString)

				-- run through filters to see where i truly belong
				itemType, itemTypeID = mod:filter_category(itemLink, itemType, itemTypeID, itemSubType, itemSubTypeID, itemEquipLoc)

				-- store new items seperately
				if (C_NewItems.IsNewItem(bag, slot)) then
					itemTypeID = -1
					itemType = "New"
				end

				-- print(itemLink, itemTypeID, itemType)

				-- store these for later
				mod.categoryIDtoNames[itemTypeID] = itemType
				mod.categoryNamestoID[itemType] = itemTypeID

				-- store it in a category
				categories[itemTypeID] = categories[itemTypeID] or {}

				-- then store by categoryID with lots of info
				table.insert(categories[itemTypeID], {name, bag, slot, itemLink, itemID, texture, itemCount, itemSubTypeID, bag})
			end		
		end
	end

	-- now loop through and display items
	mod:draw_bag()
end

local last_draw = {}
local last_free = 0

function mod:draw_bag()
	local config = mod.config

	mod.current_parent = mod.bags -- we want new frames to parent to bags
	
	mod:position_items(categories, config.buttonsize, config.buttonsperrow)
	mod:position_categories(categories, config.buttonsize, config.buttonsperrow)
end