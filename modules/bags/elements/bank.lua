local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Bags")

local last_call = 0

local GetContainerNumSlots = GetContainerNumSlots or C_Container.GetContainerNumSlots
local GetContainerItemInfo = GetContainerItemInfo or C_Container.GetContainerItemInfo
local GetContainerNumFreeSlots = GetContainerNumFreeSlots or C_Container.GetContainerNumFreeSlots
local GetContainerItemLink = GetContainerItemLink or C_Container.GetContainerItemLink
local GetContainerItemID = GetContainerItemID or C_Container.GetContainerItemID

-- bank
function mod:create_bank()
	mod.bank = mod:create_container("Bank")

	mod.bank.item_pool = CreateObjectPool(mod.item_pool_create, mod.item_pool_reset)
	mod.bank.cat_pool = CreateObjectPool(mod.category_pool_create, mod.category_pool_reset)

	-- pre-make these so we don't try to do it in combat
	mod.current_parent = mod.bank
	for i = 1, 20 do
		mod.bank.cat_pool:Acquire()
	end
	for i = 1, 200 do
		mod.bank.item_pool:Acquire()
	end
	mod.bank.cat_pool:ReleaseAll()
	mod.bank.item_pool:ReleaseAll()

	-- mod.bank:RegisterEvent('EQUIPMENT_SWAP_PENDING')
	-- mod.bank:RegisterEvent('EQUIPMENT_SWAP_FINISHED')
	-- mod.bank:RegisterEvent('AUCTION_MULTISELL_START')
	-- mod.bank:RegisterEvent('AUCTION_MULTISELL_UPDATE')
	mod.bank:RegisterEvent('BAG_UPDATE')
	mod.bank:RegisterEvent('BANKFRAME_OPENED')
	mod.bank:RegisterEvent('BANKFRAME_CLOSED')

	local run_bag_holder = 0
	mod.bank:SetScript("OnEvent", function(self, event, arg1)
		if (event == "BANKFRAME_OPENED") then
			mod.bank:Show()
			mod:update_bank()

			-- create bank slots
			-- if (run_bag_holder == 0) then
			-- 	run_bag_holder = 1

			-- 	mod:create_bagslots(mod.bank, {"-4.1", "-4.2", "-4.3", "-4.4", "-4.5", "-4.6", "-4.7"})
			-- end
		elseif (event == "BANKFRAME_CLOSED") then
			mod.bank:Hide()
		else
			if (GetTime() - .01 >= last_call) then -- throttle just crazy amounts of calls
				-- print("bank call", event, GetTime())
				last_call = GetTime()
				mod:update_bank()
			end
		end
	end)
end

function bdUI:update_bank()
	mod:update_bank()
end
function mod:update_bank()
	if (not mod.bank:IsShown()) then
		return
	end

	local config = mod.config
	local freeslots = 0
	local freeslot = nil
	mod.bank.categories = {}

	local bank_bags = { BANK_CONTAINER, 5, 6, 7, 8, 9, 10, 11 }

	for k, bag in pairs(bank_bags) do
		local min, max, step = GetContainerNumSlots(bag), 1, -1
		local free, bagtype = GetContainerNumFreeSlots(bag)
		freeslots = freeslots + free

		for slot = min, max, step do
			local texture, itemCount, locked, quality, readable, lootable, itemLink = GetContainerItemInfo(bag, slot)
			if (type(texture) == "table") then
				itemLink = texture.hyperlink
				quality = texture.quality
				itemCount = texture.stackCount
			end
			-- print(bag, slot, itemLink, GetContainerItemInfo(bag, slot))

			-- if (texture and texture > 0 and quality == -1) then
			-- 	print(bag, slot, GetContainerItemInfo(bag, slot))
			-- 	print('bank bugged i think')
			-- 	C_Timer.After(0.2, mod.update_bank)
			-- 	return
			-- end

			if (not itemLink) then
				-- print(GetContainerItemInfo(bag, slot))
				-- make this table consistent from one place
				local itemInfo = mod:get_item_table(bag, slot, bag, itemCount, itemLink)

				-- combine free space into one "item"
				if (not config.showfreespaceasone) then
					mod.categoryIDtoNames[-2] = "Bag"
					mod.categoryNamestoID["Bag"] = -2

					-- store it in a category
					mod.bank.categories[-2] = mod.bank.categories[-2] or {}

					-- then store by categoryID with lots of info
					table.insert(mod.bank.categories[-2], itemInfo)
				elseif (not freeslot) then
					freeslot = itemInfo
				end
			elseif (itemLink and not mod:is_item_trash(itemLink)) then
				-- make this table consistent from one place
				local itemInfo = mod:get_item_table(bag, slot, bag, itemCount, itemLink)

				local name, link, rarity, ilvl, minlevel, itemType, itemSubType, count, itemEquipLoc, icon, price, itemTypeID, itemSubTypeID, bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo(itemLink)

				-- run through filters to see where i truly belong
				itemType, itemTypeID = mod:filter_category(itemLink, itemTypeID)

				-- store these for later
				mod.categoryIDtoNames[itemTypeID] = itemType
				mod.categoryNamestoID[itemType] = itemTypeID

				-- store it in a category
				mod.bank.categories[itemTypeID] = mod.bank.categories[itemTypeID] or {}

				-- then store by categoryID with lots of info
				table.insert(mod.bank.categories[itemTypeID], itemInfo)
			end
		end
	end

	if (config.showfreespaceasone and freeslot) then
		mod.categoryIDtoNames[200] = "Bag"
		mod.categoryNamestoID["Bag"] = -2

		-- store it in a category
		mod.bank.categories[200] = mod.bank.categories[200] or {}

		-- then store by categoryID with lots of info
		freeslot.itemCount = freeslots -- change item count of this one slot
		table.insert(mod.bank.categories[200], freeslot)
	end

	-- now loop through and display items
	mod:draw_bank()
end

function mod:draw_bank()
	local config = mod.config

	mod.current_parent = mod.bank -- we want new frames to parent to bags

	mod:position_items(mod.bank.categories, config.bankbuttonsize, config.bankbuttonsperrow)
	mod:position_categories(mod.bank.categories, config.bankbuttonsize, config.bankbuttonsperrow)

	mod:hide_blizzard_bank()

	mod.bank.searchBox:update()
end

function mod:hide_blizzard_bank()
	if (BankFrame.hidden) then
		return
	end
	BankFrame.hidden = true
	local children = { BankFrame:GetChildren() }
	for k, child in pairs(children) do
		child:Hide()
		child.Show = noop
		child:SetAlpha(0)
		child:EnableMouse(false)
		child:SetParent(bdUI.hidden)
	end

	bdUI:strip_textures(BankFrame, true)

	BankFrame:EnableMouse(false)
end
