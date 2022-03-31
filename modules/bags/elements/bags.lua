local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Bags")

mod.categoryIDtoNames = {}
mod.categoryNamestoID = {}

-- bags
function mod:create_bags()
	mod.bags = mod:create_container("Bags")
	mod.bags.item_pool = CreateObjectPool(mod.item_pool_create, mod.item_pool_reset)
	mod.bags.cat_pool = CreateObjectPool(mod.category_pool_create, mod.category_pool_reset)	

	mod.bags:RegisterEvent('BAG_UPDATE_DELAYED')
	mod.bags:RegisterEvent('PLAYER_ENTERING_WORLD')

	local run_bag_holder = 0
	mod.bags:SetScript("OnEvent", function(self, event, arg1)
		if (event == "PLAYER_ENTERING_WORLD") then
			-- create container items for bigger and better bags
			for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
				local min, max, step = GetContainerNumSlots(bag), 1, -1
				
				for slot = min, max, step do
					local texture, itemCount, locked, quality, readable, lootable, itemLink = GetContainerItemInfo(bag, slot)
				end

				-- query for itemlink
				local bagslots = {"0.0", "0.-1", "0.-2", "0.-3"}
				for k, ids in pairs(bagslots) do
					local bagID, slot = strsplit(".", ids)
					local itemLink = select(7, GetContainerItemInfo(tonumber(bagID), tonumber(slot)))
				end
			end

			if (run_bag_holder == 0) then
				run_bag_holder = 1

				-- then try to create
				C_Timer.After(2, function()
					mod:create_bagslots(mod.bags, {"0.0", "0.-1", "0.-2", "0.-3"})
				end)
			end
		else
			mod:update_bags()
		end
	end)
end

local categories = {}
function mod:update_bags()
	local config = mod.config
	local freeslots = 0
	local freeslot = nil
	categories = {}
	
	-- first gather all items up
	for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		local min, max, step = GetContainerNumSlots(bag), 1, -1
		local free, bagtype = GetContainerNumFreeSlots(bag)
		freeslots = freeslots + free
		
		for slot = min, max, step do
			local texture, itemCount, locked, quality, readable, lootable, itemLink = GetContainerItemInfo(bag, slot)

			if (not itemLink) then
				-- make this table consistent from one place
				local itemInfo = mod:get_item_table(bag, slot, bag, itemCount, itemLink)

				-- combine free space into one "item"
				if (not config.showfreespaceasone) then
					mod.categoryIDtoNames[-2] = "Bag"
					mod.categoryNamestoID["Bag"] = -2
					
					-- store it in a category
					categories[-2] = categories[-2] or {}
					
					-- then store by categoryID with lots of info
					table.insert(categories[-2], itemInfo)
				elseif (not freeslot) then
					freeslot = itemInfo
				end
			elseif (itemLink and quality > 0) then
				-- make this table consistent from one place
				local itemInfo = mod:get_item_table(bag, slot, bag, itemCount, itemLink)

				-- detailed info
				local name, link, rarity, ilvl, minlevel, itemType, itemSubType, count, itemEquipLoc, icon, price, itemTypeID, itemSubTypeID, bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo(itemLink)

				-- run through filters to see where i truly belong
				itemType, itemTypeID = mod:filter_category(itemLink, itemType, itemTypeID, itemSubType, itemSubTypeID, itemEquipLoc)

				-- store these for later
				mod.categoryIDtoNames[itemTypeID] = itemType
				mod.categoryNamestoID[itemType] = itemTypeID

				-- store it in a category
				categories[itemTypeID] = categories[itemTypeID] or {}

				-- then store by categoryID with lots of info
				table.insert(categories[itemTypeID], itemInfo)
			end
		end
	end

	if (config.showfreespaceasone and freeslot) then
		mod.categoryIDtoNames[200] = "Bag"
		mod.categoryNamestoID["Bag"] = -2

		-- store it in a category
		categories[200] = categories[200] or {}

		-- then store by categoryID with lots of info
		freeslot.itemCount = freeslots -- change item count of this one slot
		table.insert(categories[200], freeslot)
	end

	-- now loop through and display items
	mod:draw_bag()
end

-- don't mess with categories or releasing frames, just show or hide items that have been used but leave category positions
-- this should be used only when we reduce items in the bag, so that when selling things frames aren't jumping around
function mod:bag_only_update_item_positions()

end

function mod:draw_bag()
	local config = mod.config

	mod.current_parent = mod.bags -- we want new frames to parent to bags
	
	mod:position_items(categories, config.buttonsize, config.buttonsperrow)
	mod:position_categories(categories, config.buttonsize, config.buttonsperrow)

	if (mod.bags.currencies) then
		local height = mod.bags.currencies:GetHeight()
		mod.bags:SetHeight(mod.bags:GetHeight() + height)
	end
end