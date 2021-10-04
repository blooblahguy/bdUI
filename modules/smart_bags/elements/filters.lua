local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Smart Bags (beta)")

local custom_categories = {}
-- {itemTypes_filter, equipSlot_filter, subType_filter}
custom_categories["Trinkets:5.5"] = {
	{"4.", "INVTYPE_TRINKET", false},
}
custom_categories["Rings:5.6"] = {
	{"4.", "INVTYPE_FINGER", false},
}
custom_categories["Miscellaneous:15"] = {
	{"4.0", nil, false},
}
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