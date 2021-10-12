local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Bags")

local custom_categories = {}
-- {itemTypes_filter, equipSlot_filter, subType_filter}

custom_categories["Jewelry:5.5"] = {
	{"4.", "INVTYPE_FINGER", false},
	{"4.", "INVTYPE_NECK", false},
}

custom_categories["Trinkets:5.4"] = {
	{"4.", "INVTYPE_TRINKET", false},
}

custom_categories["Potions:5.6"] = {
	{"0.1", false, false},
}

custom_categories["Food:5.7"] = {
	{"0.5", false, false},
}

-- separate out professions a little bit
custom_categories["Mining:7.1"] = {
	{"7.7", false, false},
}
custom_categories["Enchanting:7.2"] = {
	{"7.12", false, false},
}
custom_categories["Tailoring:7.3"] = {
	{"7.5", false, false},
}
custom_categories["Leatherworking:7.4"] = {
	{"7.6", false, false},
}
custom_categories["Inscription:7.5"] = {
	{"7.16", false, false},
}
custom_categories["Jewelcrafting:7.6"] = {
	{"7.4", false, false},
}
custom_categories["Herbalism:7.7"] = {
	{"7.9", false, false},
}

-- generic weapons should go here too
custom_categories["Miscellaneous:15"] = {
	{"4.0", nil, false},
}

-- add things like blacksmithing hammers etc
custom_categories["Tools:20.5"] = {
	{"0.0", false, false},
	{"2.14", false, false},
	{"2.20", false, false},
	{"7.3", false, false},
}

-- reorder these for typically better stacking
custom_categories["Gem:6.1"] = {
	{"3.", false, false},
}
custom_categories["Quest:6.2"] = {
	{"12.", false, false},
}

-- tries to match an item to a custom category, rather than default
function mod:filter_category(itemLink, itemType, itemTypeID, itemSubType, itemSubTypeID, equipSlot)
	local itemType_return, itemTypeID_return = itemType, itemTypeID
	local pass = false

	for filter_name, filters in pairs(custom_categories) do
		local name, id = strsplit(":", filter_name)
		for k, criteria in pairs(filters) do
			local itemTypes_filter, equipSlot_filter, subType_filter = unpack(criteria)
			local itemType_filter, itemSubIDType_filter = strsplit(".", itemTypes_filter)

			if (tonumber(itemTypeID) == tonumber(itemType_filter)) then
				-- print(itemLink, "matches", name, "itemids", itemSubTypeID, itemSubIDType_filter)
				pass = true
				if (itemSubIDType_filter ~= "") then -- compare
					if (tonumber(itemSubTypeID) == tonumber(itemSubIDType_filter)) then
						-- print(itemLink, "matches", name, "itemsubtype")
						pass = true
					else
						pass = false
					end
				end

				if (equipSlot_filter ~= false) then
					if (equipSlot_filter == equipSlot) then
						pass = true
					else
						pass = false
					end
				end

				if (subType_filter ~= false) then
					if (subType_filter == itemSubType) then
						pass = true
					else
						pass = false
					end
				end
			end

			if (pass) then
				itemType_return, itemTypeID_return = name, id
				break
			end
		end
		if (pass) then
			break
		end
	end

	return itemType_return, tonumber(itemTypeID_return)
end

function mod:categorize_items(bag, slot, config)

	return categories, freeslot
end