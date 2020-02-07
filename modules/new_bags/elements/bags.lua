local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("New Bags")

function mod:create_bags()
	mod.bags = mod:create_container("Bags", 0, 4)
	mod.bags.cat_pool = CreateObjectPool(mod.category_create, mod.category_reset)
	mod.bags.item_pool = CreateObjectPool(mod.item_create, mod.item_reset)

	-- create shortcut category bar
end


--==================================
-- update item tables
--==================================
function mod:update_bags()
	local items = {}
	local open_slots = 0
	mod.bags.category_items = {}

	-- first gather all items up
	for bag_id = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag_id) do
			local texture, itemCount, locked, quality, readable, lootable, itemLink = GetContainerItemInfo(bag_id, slot);
			if (texture) then 
				-- print(itemLink, slot)
				table.insert(items, {itemLink, bag_id, slot})
			else
				open_slots = open_slots + 1
			end
		end
	end

	-- now loop through categories
	for category_name, category in pairs(mod.categories) do
		local conditions = category.conditions
		for i = 1, #items do
			if (items[i]) then
				local itemLink, bag_id, slot = unpack(items[i])
				local include = false
				local name, link, rarity, ilvl, minlevel, itemtype, subtype, count, itemEquipLoc, icon, price, itemTypeID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo(itemLink)
				local itemid = mod:item_id(itemLink)

				-- evaluate conditions
				if (mod:has_value(conditions['type'], itemTypeID)) then include = true end
				if (mod:has_value(conditions['subtype'], itemSubClassID)) then include = true end
				if (mod:has_value(conditions['itemids'], itemid)) then include = true end
				-- if (conditions['minlevel'], itemtype)) then include = true end

				-- elseif (conditions['items']) then

				-- end

				-- print(include)

				if (include) then
					items[i] = nil
					mod.bags.category_items[category.name] = mod.bags.category_items[category.name] or {}
					table.insert(mod.bags.category_items[category.name], {itemLink, bag_id, slot, itemID})
				end
			end
		end
	end

	mod:draw_bags()
end


--==================================
-- draw the bags and categories
--==================================
function mod:draw_bags()
	mod.bags.cat_pool:ReleaseAll() -- release frame pool
	mod.bags.item_pool:ReleaseAll() -- release frame pool
	mod.current_parent = mod.containers["bags"] -- set this to parent the category frames correctly

	-- row functionality
	local lastCategoryRow, lastCategory
	local categoryCols = math.floor(mod:table_count(mod.categories) / 2)
	local categoryIndex = 1

	-- loop through categories and position them
	mod:position_objects({
		["table"] = mod.categories,
		["pool"] = mod.bags.cat_pool,
		["columns"] = 2,
		["parent"] = mod.bags,
		["loop"] = function(frame, i, category)
			if (not mod.bags.category_items[category.name]) then return end
			frame.text:SetText(category.name)

			-- now loop through items
			mod:position_objects({
				["table"] = mod.bags.category_items[category.name],
				["pool"] = mod.bags.item_pool,
				["columns"] = 6,
				["parent"] = frame.container,
				["loop"] = function(button, i, itemInfo)
					local itemLink, bag_id, slot, itemID = unpack(itemInfo)
					local name, link, rarity, ilvl, minlevel, itemtype, subtype, count, itemEquipLoc, icon, price, itemTypeID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo(itemLink)

					button:SetParent(mod.bag_frames[bag_id])
					button:SetID(slot)
					button.bag = bag_id
					button.slot = slot
					button.count = count
					button.itemId = itemID
					button.itemLink = itemLink
					button.hasItem = not not self.itemId
					button.texture = icon
					button.bagFamily = select(2, GetContainerNumFreeSlots(bag_id))

					SetItemButtonTexture(button, icon)
					SetItemButtonQuality(button, rarity, itemLink)
					SetItemButtonCount(button, count)

					button:update()
				end,
				["callback"] = frame.update_size
			})
		end,
		["callback"] = mod.bags.update_size
	})
end