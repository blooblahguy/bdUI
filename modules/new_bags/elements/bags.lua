local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("New Bags")

function mod:create_bags()
	mod.bags = mod:create_container("Bags", 0, 4)
	mod.bags.cat_pool = CreateObjectPool(mod.category_pool_create, mod.category_pool_reset)
	mod.bags.item_pool = CreateObjectPool(mod.item_pool_create, mod.item_pool_reset)
	mod.bags.category_items = {}
	-- mod.bags:Hide()

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
	local items = {}
	local open_slots = 0
	mod.bags.category_items = {}

	-- first gather all items up
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			local texture, itemCount, locked, quality, readable, lootable, itemLink = GetContainerItemInfo(bag, slot);
			if (texture) then 
				-- print(itemLink, slot)
				table.insert(items, {itemLink, bag, slot})
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
				local itemLink, bag, slot = unpack(items[i])
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
					table.insert(mod.bags.category_items[category.name], {itemLink, bag, slot, itemID})
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

	local loop_cats = {}
	for k, category in pairs(mod.categories) do
		if (mod.bags.category_items[category.name]) then
			loop_cats[k] = category
		end
	end

	-- loop through categories and position them
	mod:position_objects({
		["table"] = loop_cats,
		["pool"] = mod.bags.cat_pool,
		["columns"] = 2,
		["parent"] = mod.bags,
		["loop"] = function(frame, i, category)
			if (not mod.bags.category_items[category.name]) then return false end
			frame.text:SetText(category.name:upper())

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
				["callback"] = frame.update_size
			})
		end,
		["callback"] = mod.bags.update_size
	})
end