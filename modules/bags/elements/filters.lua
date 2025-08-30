local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Bags")

local custom_categories = {}

function bdUI:get_filter_info(itemLink)
	local name,
	link,
	quality,
	ilvl,
	minlevel,
	itemType,
	itemSubType,
	count,
	itemEquipLoc,
	icon,
	sellPrice,
	itemTypeID,
	itemSubTypeID,
	bindType,
	expacID,
	itemSetID,
	isCraftingReagent = GetItemInfo(itemLink)

	itemSubTypeID = itemSubTypeID or -2

	local itemString = string.match(itemLink, "item[%-?%d:]+")
	local itemID = select(2, strsplit(":", itemString))

	print(itemLink)
	print("itemID", itemID)
	print("itemType", itemType, ":", itemTypeID)
	print("itemSubType", itemSubType, ":", itemSubTypeID)
	print("itemEquipLoc", itemEquipLoc)
	print("isCraftingReagent", isCraftingReagent)
	-- print("sellPrice", sellPrice)
	print("bindType", sellPrice)
	print("--")
end

-- /script print(bdUI:get_filter_info(""))

-- Name:Id
-- {itemTypes_filter, equipSlot_filter, subType_filter}

custom_categories["Consumable"] = { ["order"] = 0, ["itemTypeID"] = "7.2" }

custom_categories["Jewelry"] = {
	["itemTypeID"] = "4.0",
	["itemEquipLoc"] = "INVTYPE_FINGER,INVTYPE_NECK"
}

custom_categories["Trinkets"] = {
	["itemTypeID"] = "4.0",
	["itemEquipLoc"] = "FALSE,INVTYPE_TRINKET"
}

-- custom_categories["Professions"] = {
-- 	["itemTypeID"] = "7.1,7.2,7.3,7.17,7.7",
-- }

custom_categories["Miscellaneous"] = { ["order"] = 15, ["itemTypeID"] = "2.14" }

-- custom_categories["Potions:1.6"] = {
-- 	{"0.1", false, false},
-- 	{"5.6", false, false},
-- }

-- -- custom_categories["Food:5.7"] = {
-- -- 	{"0.5", false, false},
-- -- }

-- -- custom_categories["Consumables:0.4"] = {
-- -- 	{"0.5", false, false},
-- -- }

-- -- separate out professions a little bit
-- custom_categories["Mining:7.1"] = {
-- 	{"7.7", false, false},
-- }
-- custom_categories["Enchanting:7.2"] = {
-- 	{"7.12", false, false},
-- }
-- custom_categories["Tailoring:7.3"] = {
-- 	{"7.5", false, false},
-- }
-- custom_categories["Leatherworking:7.4"] = {
-- 	{"7.6", false, false},
-- }
-- custom_categories["Inscription:7.5"] = {
-- 	{"7.16", false, false},
-- }
-- custom_categories["Jewelcrafting:7.6"] = {
-- 	{"7.4", false, false},
-- }
-- custom_categories["Herbalism:7.7"] = {
-- 	{"7.9", false, false},
-- }

-- -- generic weapons should go here too
-- custom_categories["Miscellaneous:15"] = {
-- 	{"4.0", nil, false},
-- 	{"", "INVTYPE_TABARD", false},
-- 	{"", "INVTYPE_NON_EQUIP", false},
-- }

-- -- add things like blacksmithing hammers etc
-- custom_categories["Tools:20.5"] = {
-- 	{"0.0", false, false},
-- 	{"2.14", false, false},
-- 	{"2.20", false, false},
-- 	{"7.3", false, false},
-- }

-- -- reorder these for typically better stacking
-- custom_categories["Gem:6.1"] = {
-- 	{"3.", false, false},
-- }
-- custom_categories["Quest:6.2"] = {
-- 	{"12.", false, false},
-- }

-- tries to match an item to a custom category, rather than default
function mod:filter_category(itemLink, itemTypeID)
	local name,
	link,
	quality,
	ilvl,
	minlevel,
	itemType,
	itemSubType,
	count,
	itemEquipLoc,
	icon,
	price,
	_,
	itemSubTypeID,
	bindType,
	expacID,
	itemSetID,
	isCraftingReagent = C_Item.GetItemInfo(itemLink)

	itemSubTypeID = itemSubTypeID or -2
	itemTypeID = itemTypeID or -2
	-- default returns
	-- local returnType, returnID = itemType, itemTypeID -- item name / itemID

	-- we want to loop in here til we find the filter that matches the most conditions, then store it there
	local bestMatch = { itemType, itemTypeID } -- when we find a best match, return it. this is a table of name / id
	local bestMatchCount = 0                -- we want to check our best-match so far
	local currentEntry = 0                  -- this is used to add a sub-id to the item categorizations
	for filter_name, filters in pairs(custom_categories) do
		currentEntry = currentEntry + 1
		local order = filters["order"] or itemTypeID .. "." .. currentEntry
		local filterMatchCount = 0

		-- match any itemtype ids and subtype ids
		local typeMatched = false
		if (filters["itemTypeID"]) then
			local types = { strsplit(",", filters["itemTypeID"]) }
			for k, v in pairs(types) do
				local type1, type2 = strsplit(".", v)
				type1 = type1
				type2 = type2

				-- decide if we're looking for just the type or the type and subtype
				local find = tostring(itemTypeID or -1)
				if (type1 and type2 and itemSubTypeID ~= nil) then
					find = tostring(itemTypeID or -1) .. "." .. tostring(itemSubTypeID)
				end

				-- now match on whats stored in the filter
				-- print(filter_name, find, v)
				if (tonumber(find) == tonumber(v)) then
					filterMatchCount = filterMatchCount + 1
					typeMatched = true
				end
			end
		end

		-- check if this equips at this location
		if (filters["itemEquipLoc"]) then
			local types = { strsplit(",", filters["itemEquipLoc"]) }
			for k, v in pairs(types) do
				if (itemEquipLoc == v) then
					filterMatchCount = filterMatchCount + 1
				end
				if (itemEquipLoc == "") then
					-- print(itemLink, filter_name, typeMatched)
				end
				if v == "FALSE" and itemEquipLoc == "" and typeMatched then
					filterMatchCount = filterMatchCount + 1
				end
			end
		end

		-- check if this is our latest best match
		if (filterMatchCount > bestMatchCount) then
			-- print(itemLink, order)
			bestMatchCount = filterMatchCount
			bestMatch = { filter_name, order }
		end
	end

	return unpack(bestMatch)

	-- 	-- local name, id = strsplit(":", filter_name)
	-- 	for criteria, value in pairs(filters) do

	-- 		-- local itemTypes_filter, equipSlot_filter, subType_filter = unpack(criteria)
	-- 		-- local itemType_filter, itemSubIDType_filter = strsplit(".", itemTypes_filter)

	-- 		if (itemTypes_filter ~= "" and tonumber(itemTypeID) == tonumber(itemType_filter)) then
	-- 			-- print(itemLink, "matches", name, "itemids", itemSubTypeID, itemSubIDType_filter)
	-- 			-- if (equipSlot == "INVTYPE_TABARD") then
	-- 			-- 	print(itemLink, itemTypes_filter, equipSlot_filter, subType_filter, equipSlot)
	-- 			-- end
	-- 			pass = true
	-- 			if (itemSubIDType_filter ~= "") then -- compare
	-- 				if (tonumber(itemSubTypeID) == tonumber(itemSubIDType_filter)) then
	-- 					-- print(itemLink, "matches", name, "itemsubtype")
	-- 					pass = true
	-- 				else
	-- 					pass = false
	-- 				end
	-- 			end
	-- 		elseif (itemTypes_filter == "") then
	-- 			-- print(name, unpack(criteria))
	-- 			-- if (equipSlot == "INVTYPE_TABARD") then
	-- 			-- 	print(itemLink, itemTypes_filter, equipSlot_filter, subType_filter, equipSlot)
	-- 			-- end
	-- 			if (equipSlot_filter ~= false) then
	-- 				if (equipSlot_filter == equipSlot) then
	-- 					pass = true
	-- 				else
	-- 					pass = false
	-- 				end
	-- 			end

	-- 			if (subType_filter ~= false) then
	-- 				if (subType_filter == itemSubType) then
	-- 					pass = true
	-- 				else
	-- 					pass = false
	-- 				end
	-- 			end
	-- 		end

	-- 		if (pass) then
	-- 			itemType_return, itemTypeID_return = name, id
	-- 			break
	-- 		end
	-- 	end
	-- 	if (pass) then
	-- 		break
	-- 	end
	-- end

	-- return itemType_return, tonumber(itemTypeID_return)
end

function mod:categorize_items(bag, slot, config)
	return categories, freeslot
end

-- mod.filter_category = memoize(filter_category, mod.cache)
