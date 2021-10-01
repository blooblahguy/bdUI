local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Bags (beta)")


-- if bdUI:isClassicAny() then return end

mod.bank = mod:create_container("Bank")
mod.bank.cat_pool = CreateObjectPool(mod.category_pool_create, mod.category_pool_reset)
mod.bank.item_pool = CreateObjectPool(mod.item_pool_create, mod.item_pool_reset)

local function hide_blizzard_bank()
	for i = 1, 5 do				
		select(i, _G['BankFrame']:GetRegions()):Hide()
	end
	for i = 1, 5 do
		if (not select(i, _G['BankFrame']:GetChildren())) then break end	
		select(i, _G['BankFrame']:GetChildren()):Hide()
	end
	for i = 1, 5 do
		local child = select(i, _G['BankFrameMoneyFrameInset']:GetChildren())
		if (child) then
			child:Hide()
		end
	end
	-- _G['BankFrame'].NineSlice:Hide()
	if (_G["BackpackTokenFrame"]:GetRegions()) then
		_G["BackpackTokenFrame"]:GetRegions():SetAlpha(0)
	end

	BankFrameCloseButton:Hide()
	BankFrameMoneyFrame:Hide()
	bdUI:strip_textures(BankFrameMoneyFrameInset)
	bdUI:strip_textures(BankFrameMoneyFrameBorder)
	bdUI:strip_textures(BankFrameMoneyFrame)
	bdUI:strip_textures(BankFrame)
	bdUI:strip_textures(BankSlotsFrame, true)

	BankSlotsFrame:SetFrameStrata("HIGH")
	BankSlotsFrame:SetFrameLevel(8)
	BankSlotsFrame:SetParent(mod.bank)

	-- reagant frame
	ReagentBankFrame:SetFrameStrata("HIGH")
	ReagentBankFrame:SetFrameLevel(3)
	ReagentBankFrame:SetParent(mod.bank)
	bdUI:strip_textures(ReagentBankFrame)
	ReagentBankFrame:DisableDrawLayer("BACKGROUND")
	ReagentBankFrame:DisableDrawLayer("ARTWORK")
	BankPortraitTexture:Hide()
	BankFrame:EnableMouse(false)
	BankSlotsFrame:EnableMouse(false)
	-- mod:killShowable(BagHelpBox)
end

--===================================
-- Create bank frames
--===================================
function mod:create_bank()
	local config = mod.config
	mod.bank:SetPoint("TOPLEFT", bdParent, "TOPLEFT", 30, -30)
	mod.bank.container:SetWidth(config.bag_height)

	mod.bank:RegisterEvent('EQUIPMENT_SWAP_PENDING')
	mod.bank:RegisterEvent('EQUIPMENT_SWAP_FINISHED')
	mod.bank:RegisterEvent('AUCTION_MULTISELL_START')
	mod.bank:RegisterEvent('AUCTION_MULTISELL_UPDATE')
	mod.bank:RegisterEvent('AUCTION_MULTISELL_FAILURE')
	mod.bank:RegisterEvent('BAG_UPDATE_DELAYED')
	mod.bank:RegisterEvent('BANKFRAME_OPENED')
	mod.bank:RegisterEvent('BANKFRAME_CLOSED')

	mod.bank:SetScript("OnEvent", function(self, event, arg1)
		if (event == "EQUIPMENT_SWAP_PENDING" or event == "AUCTION_MULTISELL_START") then
			self.paused = true
		elseif (event == "EQUIPMENT_SWAP_FINISHED" or event == "AUCTION_MULTISELL_FAILURE") then
			self.paused = false
		elseif (event == "BANKFRAME_OPENED") then
			mod.bank:Show()
			hide_blizzard_bank()
			-- BankFrame:SetAlpha(0)
			-- BankFrame:EnableMouse(0)
			-- BankFrame:SetParent(bdUI.hidden)
		elseif (event == "BANKFRAME_CLOSED") then
			mod.bank:Hide()
			-- BankFrame:SetAlpha(0)
			-- BankFrame:EnableMouse(0)
			-- BankFrame:SetParent(bdUI.hidden)
		end

		if (not self.paused) then
			mod:update_bank()
		end
	end)
end


--===================================
-- Filter bank and update
--===================================
function mod:update_bank()
	if (not mod.bank:IsShown()) then return end

	local items = {}
	local free_slot = {}
	local remove = {}
	local new_items = {}
	local item_weights = {}
	local open_slots = 0
	local bank_bags = {BANK_CONTAINER, 5, 6, 7, 8, 9, 10, 11}

	for k, bag in pairs(bank_bags) do
		local freeslots, bagtype = GetContainerNumFreeSlots(bag)
		lastfull = freeslots == 0

		for slot = 1, GetContainerNumSlots(bag) do
			local texture, itemCount, locked, quality, readable, lootable, itemLink = GetContainerItemInfo(bag, slot);
			local itemID = mod:item_id(itemLink)

			if (texture) then 
				-- print(itemLink, bag, slot)
				items[#items + 1] = {itemLink, bag, slot, itemID}
			else
				free_slot = {false, bag, slot, itemID}
				open_slots = open_slots + 1
			end
		end
	end

	-- build item category weight table
	for category_name, category in pairs(mod.categories) do
		category.items = {}
		category.count = nil

		local conditions = category.conditions
		for k = 1, #items do
			v = items[k]

			-- item information
			local itemLink, bag, slot, itemID = unpack(v)
			if (itemLink) then
				local name, link, rarity, ilvl, minlevel, itemtype, subtype, count, itemEquipLoc, icon, price, itemTypeID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo(itemLink)

				if (rarity == nil or rarity > 0) then
					item_weights[k] = item_weights[k] or {0, nil}
					local current_weight, parent_category = unpack(item_weights[k])
					-- local new_weight = 0

					local new_weight = mod:filter_item(conditions, itemLink, itemID, name, rarity, ilvl, minlevel, itemEquipLoc, price, itemTypeID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent, category)

					if (current_weight < new_weight) then
						item_weights[k] = {new_weight, category_name}
					end
				else
					remove[#remove + 1] = k
				end
			end
		end
	end

	-- now loop through categories items that we've weighted out, assign them to their categories
	for k, v in pairs(item_weights) do
		local weight, parent_category = unpack(v)

		if (weight > 0) then
			local itemLink, bag, slot, itemID = unpack(items[k])
			-- local count = #mod.bags.category_items[parent_category]
			-- mod.bags.category_items[parent_category][count + 1] = {itemLink, bag, slot, itemID}
			local count = #mod.categories[parent_category].items
			mod.categories[parent_category].items[count + 1] = {itemLink, bag, slot, itemID}
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
	-- local bag_items = {}
	for k, v in pairs(items) do
		-- local itemLink, bag, slot, itemID = unpack(items[k])
		-- local name, link, rarity, ilvl, minlevel, itemtype, subtype, count, itemEquipLoc, icon, price, itemTypeID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo(itemLink)
		-- local count = #mod.bags.category_items["Bags"]
		-- mod.bags.category_items["Bags"][count + 1] = items[k]
		-- tinsert(bag_items, k)
		local count = #mod.categories["Bags"].items
		mod.categories["Bags"].items[count + 1] = items[k]
	end

	-- for k, v in pairs(free) do
	-- 	-- local itemLink, bag, slot, itemID = unpack(items[k])
	-- 	-- local name, link, rarity, ilvl, minlevel, itemtype, subtype, count, itemEquipLoc, icon, price, itemTypeID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo(itemLink)
	-- 	-- local count = #mod.bags.category_items["Bags"]
	-- 	-- mod.bags.category_items["Bags"][count + 1] = items[k]
	-- 	-- tinsert(bag_items, k)
	-- 	local count = #mod.categories["Free"].items
	-- 	mod.categories["Free"].items[count + 1] = items[k]
	-- end
	mod.categories["Free"].items[1] = free_slot
	mod.categories["Free"].count = open_slots
	
	--=====================
	-- Add New Items to New Category
	--=====================
	-- for k = 1, #new_items do
	-- 	local v = new_items[k]
	-- 	-- local itemLink, bag, slot, itemID = unpack(new_items[k])
	-- 	-- local name, link, rarity, ilvl, minlevel, itemtype, subtype, count, itemEquipLoc, icon, price, itemTypeID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo(itemLink)
	-- 	-- local count = #mod.bags.category_items["New Items"]
	-- 	-- mod.bags.category_items["New Items"][count + 1] = items[k]
	-- 	local count = #mod.categories["New Items"].items
	-- 	mod.categories["New Items"].items[count + 1] = items[k]
	-- end
-- 
	mod:draw_bank()
end

--==================================
-- draw the bags and categories
--==================================
function mod:draw_bank()
	mod.bank.cat_pool:ReleaseAll() -- release frame pool
	mod.bank.item_pool:ReleaseAll() -- release frame pool
	mod.current_parent = mod.containers["bank"] -- set this to parent the category frames correctly

	-- find out which categories we should display
	local loop_cats = mod:get_visible_categories()

	-- 
	for i = 1, #loop_cats do
		local category = loop_cats[i]
		category.frame = mod.bank.cat_pool:Acquire()
		category.frame.name = category.name
		category.frame:ClearAllPoints()
		category.frame:Show()
		category.frame:SetParent(mod.bank.container)
		category.frame.text:SetText(category.name:upper())
		category.frame.locked = category.locked
		category.frame.dragger:update()
		category.frame.dropdown:SetParent(category.frame)

		-- position items in categories
		local width, height = mod:position_items(category, mod.bank.container, mod.bank.item_pool)
		category.frame:update_size(width, height)
	end

	-- now position the categories since we have dimensions
	local width, height = mod:position_categories(mod.bank.container, loop_cats, mod.bank.cat_pool)
	mod.bank:update_size(width, height)
end