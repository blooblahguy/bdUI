local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Smart Bags (beta)")

-- bank
function mod:create_bank()
	mod.bank = mod:create_container("Bank")
	mod.bank.item_pool = CreateObjectPool(mod.item_pool_create, mod.item_pool_reset)
	mod.bank.cat_pool = CreateObjectPool(mod.category_pool_create, mod.category_pool_reset)

	-- mod.bank:RegisterEvent('EQUIPMENT_SWAP_PENDING')
	-- mod.bank:RegisterEvent('EQUIPMENT_SWAP_FINISHED')
	-- mod.bank:RegisterEvent('AUCTION_MULTISELL_START')
	-- mod.bank:RegisterEvent('AUCTION_MULTISELL_UPDATE')
	-- mod.bank:RegisterEvent('AUCTION_MULTISELL_FAILURE')
	mod.bank:RegisterEvent('BAG_UPDATE')
	mod.bank:RegisterEvent('BANKFRAME_OPENED')
	mod.bank:RegisterEvent('BANKFRAME_CLOSED')

	mod.bank:SetScript("OnEvent", function(self, event, arg1)
		if (event == "BANKFRAME_OPENED") then
			mod.bank:Show()
			mod:update_bank()
		elseif (event == "BANKFRAME_CLOSED") then
			mod.bank:Hide()
		else
			mod:update_bank()
		end
		
	end)
end

local categories = {}
function mod:update_bank()
	categories = {}
	local bank_bags = {BANK_CONTAINER, 5, 6, 7, 8, 9, 10, 11}

	for k, bag in pairs(bank_bags) do
		local freeslots, bagtype = GetContainerNumFreeSlots(bag)
		local min, max, step = GetContainerNumSlots(bag), 1, -1

		for slot = min, max, step do
			local texture, itemCount, locked, quality, readable, lootable, itemLink = GetContainerItemInfo(bag, slot)

			if (not itemLink) then
				mod.categoryIDtoNames[-2] = "Bag"
				mod.categoryNamestoID["Bag"] = -2

				-- store it in a category
				categories[-2] = categories[-2] or {}

				-- then store by categoryID with lots of info
				table.insert(categories[-2], {"", bag, slot, itemLink, itemID, texture, itemCount, itemSubClassID, bag})
			elseif (itemLink and quality > 0) then
				local name, link, rarity, ilvl, minlevel, itemtype, subtype, count, itemEquipLoc, icon, price, itemTypeID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo(itemLink)
				local itemString = string.match(itemLink, "item[%-?%d:]+")
				local _, itemID = strsplit(":", itemString)

				-- store new items seperately
				if (C_NewItems.IsNewItem(bag, slot)) then
					itemTypeID = -1
					itemtype = "New"
				end

				-- store these for later
				mod.categoryIDtoNames[itemTypeID] = itemtype
				mod.categoryNamestoID[itemtype] = itemTypeID

				-- store it in a category
				categories[itemTypeID] = categories[itemTypeID] or {}

				-- then store by categoryID with lots of info
				table.insert(categories[itemTypeID], {name, bag, slot, itemLink, itemID, texture, itemCount, itemSubClassID, bag})
			end
		end
	end

	-- now loop through and display items
	mod:draw_bank()
end


function mod:draw_bank()
	local config = mod.config

	mod.current_parent = mod.bank -- we want new frames to parent to bags
	
	mod:position_items(categories, config.bankbuttonsize, config.bankbuttonsperrow)
	mod:position_categories(categories, config.bankbuttonsize, config.bankbuttonsperrow)
end