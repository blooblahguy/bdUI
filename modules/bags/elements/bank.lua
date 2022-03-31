local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Bags")

-- bank
function mod:create_bank()
	mod.bank = mod:create_container("Bank")
	
	mod.bank.item_pool = CreateObjectPool(mod.item_pool_create, mod.item_pool_reset)
	mod.bank.cat_pool = CreateObjectPool(mod.category_pool_create, mod.category_pool_reset)

	-- mod.bank:RegisterEvent('EQUIPMENT_SWAP_PENDING')
	-- mod.bank:RegisterEvent('EQUIPMENT_SWAP_FINISHED')
	-- mod.bank:RegisterEvent('AUCTION_MULTISELL_START')
	-- mod.bank:RegisterEvent('AUCTION_MULTISELL_UPDATE')
	mod.bank:RegisterEvent('BAG_UPDATE_DELAYED')
	mod.bank:RegisterEvent('BANKFRAME_OPENED')
	mod.bank:RegisterEvent('BANKFRAME_CLOSED')

	local run_bag_holder = 0
	mod.bank:SetScript("OnEvent", function(self, event, arg1)
		if (event == "BANKFRAME_OPENED") then
			mod.bank:Show()
			mod:update_bank()

			-- create bank slots
			if (run_bag_holder == 0) then
				run_bag_holder = 1

				mod:create_bagslots(mod.bank, {"-4.1", "-4.2", "-4.3", "-4.4", "-4.5", "-4.6", "-4.7"})
			end
		elseif (event == "BANKFRAME_CLOSED") then
			mod.bank:Hide()
		else
			mod:update_bank()
		end
	end)
end

local categories = {}
function mod:update_bank()
	if (not mod.bank:IsShown()) then return end
	
	local config = mod.config
	local freeslots = 0
	local freeslot = nil
	categories = {}

	local bank_bags = {BANK_CONTAINER, 5, 6, 7, 8, 9, 10, 11}

	for k, bag in pairs(bank_bags) do
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
	mod:draw_bank()
end


function mod:draw_bank()
	local config = mod.config

	mod.current_parent = mod.bank -- we want new frames to parent to bags
	
	mod:position_items(categories, config.bankbuttonsize, config.bankbuttonsperrow)
	mod:position_categories(categories, config.bankbuttonsize, config.bankbuttonsperrow)

	mod:hide_blizzard_bank()
end

function mod:hide_blizzard_bank()
	local children = {BankFrame:GetChildren()}
	for k, child in pairs(children) do
		child:Hide()
		child.Show = noop
		child:SetAlpha(0)
		child:EnableMouse(false)
	end

	bdUI:strip_textures(BankFrame, true)

	BankFrame:EnableMouse(false)
end