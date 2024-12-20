local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Bags")

local last_call = 0

mod.categoryIDtoNames = {}
mod.categoryNamestoID = {}

local GetContainerNumSlots = GetContainerNumSlots or C_Container.GetContainerNumSlots
local GetContainerItemInfo = GetContainerItemInfo or C_Container.GetContainerItemInfo
local GetContainerNumFreeSlots = GetContainerNumFreeSlots or C_Container.GetContainerNumFreeSlots
-- local GetContainerItemInfo
-- if (C_Container and C_Container.GetContainerNumSlots) then
-- 	local GetContainerNumSlots = C_Container.GetContainerNumSlots
-- 	local GetContainerItemInfo = C_Container.GetContainerItemInfo
-- end

-- bags
function mod:create_bags()
	mod.bags = mod:create_container("Bags")
	mod.bags.item_pool = CreateObjectPool(mod.item_pool_create, mod.item_pool_reset)
	mod.bags.cat_pool = CreateObjectPool(mod.category_pool_create, mod.category_pool_reset)

	-- pre-make these so we don't try to do it in combat
	mod.current_parent = mod.bags
	for i = 1, 20 do
		mod.bags.cat_pool:Acquire()
	end
	for i = 1, 200 do
		mod.bags.item_pool:Acquire()
	end
	mod.bags.cat_pool:ReleaseAll()
	mod.bags.item_pool:ReleaseAll()

	mod.bags:RegisterEvent('BAG_UPDATE')
	mod.bags:RegisterEvent('PLAYER_LOGIN')
	mod.bags:RegisterEvent('PLAYER_ENTERING_WORLD')

	local run_bag_holder = 0
	mod.bags:SetScript("OnEvent", function(self, event, arg1)
		-- cache items
		if (event == "PLAYER_LOGIN") then
			C_Timer.After(1, function()
				mod:update_bags()
			end)
			-- create container items for bigger and better bags
			-- for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
			-- local min, max, step = GetContainerNumSlots(bag), 1, -1

			-- print(min, max, bag, step)
			-- print(event)

			-- for slot = min, max, step do
			-- print(slot)
			-- print("ContainerFrame"..bag.."Item"..slot)
			-- local blizzbut = _G["ContainerFrame"..bag.."Item"..slot]
			-- local texture, itemCount, locked, quality, readable, lootable, itemLink = GetContainerItemInfo(bag, slot)
			-- if (type(texture) == "table") then
			-- 	itemLink = texture.hyperlink
			-- end
			-- GetItemInfo(itemLink)
			-- print(itemLink)
			-- if (blizzbut) then
			-- print(blizzbut:GetID(), blizzbut:GetParent():GetID())
			-- end
			-- end

			-- query for itemlink
			-- local bagslots = {"0.0", "0.-1", "2.-2", "3.-3"}
			-- for k, ids in pairs(bagslots) do
			-- 	local bagID, slot = strsplit(".", ids)
			-- 	local itemLink = select(7, GetContainerItemInfo(tonumber(bagID), tonumber(slot)))
			-- end
			-- end

			-- if (run_bag_holder == 0) then
			-- 	run_bag_holder = 1

			-- 	-- then try to create
			-- C_Timer.After(1, function()
			-- mod:create_bagslots(mod.bags, {"0.0", "0.1", "0.2", "0.3"})
			-- end)
			-- end
		else
			if (GetTime() - .01 >= last_call or event == "PLAYER_ENTERING_WORLD") then -- throttle just crazy amounts of calls
				last_call = GetTime()
				mod:update_bags()
			end
		end
	end)
end

function mod:update_bags()
	local config = mod.config
	local freeslots = 0
	local freeslot = nil
	mod.bags.categories = {}
	-- mod.categoryIDtoNames[13] = GetItemClassInfo(13)
	-- local keyName = GetItemClassInfo(13)
	-- mod.categoryNamestoID[keyName] = 13


	bdUI:profile_start("bag update loop", 1)
	-- first gather all items up
	for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
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

			if (not itemLink) then
				-- make this table consistent from one place
				local itemInfo = mod:get_item_table(bag, slot, bag, itemCount, itemLink)

				-- combine free space into one "item"
				if (not config.showfreespaceasone) then
					mod.categoryIDtoNames[-2] = "Bag"
					mod.categoryNamestoID["Bag"] = -2

					-- store it in a category
					mod.bags.categories[-2] = mod.bags.categories[-2] or {}

					-- then store by categoryID with lots of info
					table.insert(mod.bags.categories[-2], itemInfo)
				elseif (not freeslot) then
					freeslot = itemInfo
				end
			elseif (itemLink and not mod:is_item_trash(itemLink)) then --quality ~= nil and quality > 0) then
				-- make this table consistent from one place
				local itemInfo = mod:get_item_table(bag, slot, bag, itemCount, itemLink)

				-- detailed info
				local name, link, rarity, ilvl, minlevel, itemType, itemSubType, count, itemEquipLoc, icon, price, itemTypeID, itemSubTypeID, bindType, expacID, itemSetID, isCraftingReagent =
					GetItemInfo(itemLink)

				-- run through filters to see where i truly belong
				itemType, itemTypeID = mod:filter_category(itemLink, itemTypeID)

				if (not itemType) then itemType = GetItemClassInfo(13) end;
				if (not itemTypeID) then itemTypeID = 13 end;

				-- store these for later
				mod.categoryIDtoNames[itemTypeID] = itemType
				mod.categoryNamestoID[itemType] = itemTypeID

				-- store it in a category
				mod.bags.categories[itemTypeID] = mod.bags.categories[itemTypeID] or {}

				-- then store by categoryID with lots of info
				table.insert(mod.bags.categories[itemTypeID], itemInfo)
			end
		end
	end
	bdUI:profile_stop("bag update loop", 1)

	if (config.showfreespaceasone and freeslot) then
		mod.categoryIDtoNames[200] = "Bag"
		mod.categoryNamestoID["Bag"] = -2

		-- store it in a category
		mod.bags.categories[200] = mod.bags.categories[200] or {}

		-- then store by categoryID with lots of info
		freeslot.itemCount = freeslots -- change item count of this one slot
		table.insert(mod.bags.categories[200], freeslot)
	end

	-- now loop through and display items
	bdUI:profile_start("bag draw", 1)
	mod:draw_bag()
	bdUI:profile_stop("bag draw", 1)
end

-- don't mess with categories or releasing frames, just show or hide items that have been used but leave category positions
-- this should be used only when we reduce items in the bag, so that when selling things frames aren't jumping around
function mod:bag_only_update_item_positions()

end

function mod:draw_bag()
	local config = mod.config

	mod.current_parent = mod.bags -- we want new frames to parent to bags

	bdUI:profile_start("bag draw items", 3)
	mod:position_items(mod.bags.categories, config.buttonsize, config.buttonsperrow)
	bdUI:profile_stop("bag draw items", 3)
	bdUI:profile_start("bag draw categopries", 3)
	mod:position_categories(mod.bags.categories, config.buttonsize, config.buttonsperrow)
	bdUI:profile_stop("bag draw categopries", 3)

	if (mod.bags.currencies) then
		local height = mod.bags.currencies:GetHeight()
		mod.bags:SetHeight(mod.bags:GetHeight() + height)
	end

	bdUI:profile_start("bag search update", 3)
	mod.bags.searchBox:update()
	bdUI:profile_stop("bag search update", 3)
end
