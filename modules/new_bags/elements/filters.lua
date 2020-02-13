local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("New Bags")

--===============================
-- filter groups
--===============================
local types = {}
types["Consumable"] = {0}
types["Bags"] = {1}
types["Weapon"] = {2, 6, 11}
types["Gems"] = {3}
types["Armor"] = {4}
types["Tradeskill"] = {5, 7, 9}
types["Recipes"] = {9}
types["Enchantment"] = {8, 16}
types["Quest"] = {12}
types["Keys"] = {13}
types["Tokens"] = {10, 14, 18}
types["Battle Pets"] = {17}
types["Miscellaneous"] = {15}
mod.types = types

local subtypes = {}
subtypes["Food"] = {0.5}
subtypes["Potions"] = {0.1, 0.2, 0.3}
subtypes["Explosives"] = {0.0, 7.2, 7.17} 
subtypes["Archaeology"] = {5.1}
subtypes["Mount"] = {15.5, 15.6}
subtypes["Holiday"] = {15.3}
mod.subtypes = subtypes

--===============================
-- FILTERS USAGE
-- mod:add_filter("name", value, function(conditions, itemLink, itemID, name, rarity, ilvl, minlevel, itemEquipLoc, price, itemTypeID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent)
-- 	RETURN weight
-- end
--===============================
mod.filters = {}
function mod:add_filter(name, value, func)
	mod.filters[#mod.filters + 1] = {name, value, func}
end
function mod:filter_item(conditions, ...)
	local weight = 0
	for i = 1, #mod.filters do
		local name, value, func = unpack(mod.filters[i])
		if (func(conditions, ...)) then
			weight = weight + value
		end
	end
	return weight
end

--===============================
-- Item Type
--===============================
mod:add_filter("itemType", 1, function(conditions, itemLink, itemID, name, rarity, ilvl, minlevel, itemEquipLoc, price, itemTypeID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent)
	if (#conditions['type'] == 0) then return false end

	if (tContains(conditions['type'], itemTypeID)) then 
		return true
	end
end)

--===============================
-- Item Subtype
--===============================
mod:add_filter("itemSubType", 2.5, function(conditions, itemLink, itemID, name, rarity, ilvl, minlevel, itemEquipLoc, price, itemTypeID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent)
	if (#conditions['subtype'] == 0) then return false end

	-- print(itemLink)
	for i = 1, #conditions['subtype'] do
		local val = conditions['subtype'][i]
		local typeid, subtypeid = strsplit(".", val)
		subtypeid = subtypeid or typeid

		-- print(typeid, itemTypeID, subtypeid, itemSubClassID)
		-- -- local typeid, subtypes = unpack()
		if (tonumber(typeid) == itemTypeID and tonumber(subtypeid) == itemSubClassID) then
			return true
		end
	end
end)

--===============================
-- Item ID
--===============================
mod:add_filter("itemID", 10, function(conditions, itemLink, itemID, name, rarity, ilvl, minlevel, itemEquipLoc, price, itemTypeID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent)
	if (#conditions["itemids"] == 0) then return false end

	if (tContains(conditions['itemids'], itemID)) then 
		return true
	end
end)

--===============================
-- Item Rarity
--===============================
mod:add_filter("itemRarity", 3, function(conditions, itemLink, itemID, name, rarity, ilvl, minlevel, itemEquipLoc, price, itemTypeID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent)
	if (conditions["rarity"] == 0 or not rarity) then return false end

	if (rarity >= conditions["rarity"]) then
		return true
	end
end)

--===============================
-- Item iLVL
--===============================
mod:add_filter("itemLvl", 3, function(conditions, itemLink, itemID, name, rarity, ilvl, minlevel, itemEquipLoc, price, itemTypeID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent)
	if (conditions["itemlvl"] == 0 or not ilvl) then return false end
	
	if (ilvl >= conditions["itemlvl"]) then
		return true
	end
end)