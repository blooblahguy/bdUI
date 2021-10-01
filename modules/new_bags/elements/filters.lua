local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Bags (beta)")

--===============================
-- filter groups
--===============================
local expansion = {}
expansion[0] = "Classic"
expansion[1] = "The Burning Crusade"
expansion[2] = "Wrath of the Lich King"
expansion[3] = "Cataclysm"
expansion[4] = "Mists of Pandaria"
expansion[5] = "Warlords of Draenor"
expansion[6] = "Legion"
expansion[7] = "Battle for Azeroth"
expansion[8] = "Shadowlands"
mod.expansion = {}

--==========================================
-- itemTypeIDs -> value
local itemTypeIDValues = {}
--==========================================
itemTypeIDValues[0] = "Consumable"
itemTypeIDValues[1] = "Container"
itemTypeIDValues[2] = "Weapon"
itemTypeIDValues[3] = "Gem"
itemTypeIDValues[4] = "Armor"
itemTypeIDValues[5] = "Reagent"
itemTypeIDValues[6] = "Projectile"
itemTypeIDValues[7] = "Tradegoods"
itemTypeIDValues[8] = "ItemEnhancement"
itemTypeIDValues[9] = "Recipe"
itemTypeIDValues[10] = "CurrencyTokenObsolete"
itemTypeIDValues[11] = "Quiver"
itemTypeIDValues[12] = "Questitem"
itemTypeIDValues[13] = "Key"
itemTypeIDValues[14] = "PermanentObsolete"
itemTypeIDValues[15] = "Miscellaneous"
itemTypeIDValues[16] = "Glyph"
itemTypeIDValues[17] = "Battlepet"
itemTypeIDValues[18] = "WoWToken"
mod.itemTypeIDValues = itemTypeIDValues

--==========================================
-- itemTypeValueIDs -> ids
mod.itemTypeValueIDs = bdUI:swaptable(itemTypeIDValues)
--==========================================

--==========================================
-- itemTypeIDs -> value
local itemSubTypeIDValues = {}
--==========================================

--=====================
-- Consumable
itemSubTypeIDValues[0] = {}
--=====================
itemSubTypeIDValues[0][0] = "Generic" -- Explosives and Devices
itemSubTypeIDValues[0][1] = "Potion" -- Potion
itemSubTypeIDValues[0][2] = "Elixir" -- Elixir
itemSubTypeIDValues[0][3] = "Scroll" -- Scroll (OBSOLETE)
itemSubTypeIDValues[0][4] = "Fooddrink" -- Food & Drink
itemSubTypeIDValues[0][5] = "Itemenhancement" -- Item Enhancement (OBSOLETE)
itemSubTypeIDValues[0][6] = "Bandage" -- Bandage
itemSubTypeIDValues[0][7] = "Other" -- Other

--=====================
 -- Container
 itemSubTypeIDValues[1] = {}
 --=====================
itemSubTypeIDValues[1][0] = "Bag"
itemSubTypeIDValues[1][1] = "Soul Bag" -- Classic
itemSubTypeIDValues[1][2] = "Herb Bag"
itemSubTypeIDValues[1][3] = "Enchanting Bag"
itemSubTypeIDValues[1][4] = "Engineering Bag"
itemSubTypeIDValues[1][5] = "Gem Bag"
itemSubTypeIDValues[1][6] = "Mining Bag"
itemSubTypeIDValues[1][7] = "Leatherworking Bag"
itemSubTypeIDValues[1][8] = "Inscription Bag"
itemSubTypeIDValues[1][9] = "Tackle Box"
itemSubTypeIDValues[1][10] = "Cooking Bag"

--=====================
-- Weapon
itemSubTypeIDValues[2] = {}
--=====================
itemSubTypeIDValues[2][0] = "Axe1H" -- One-Handed Axes
itemSubTypeIDValues[2][1] = "Axe2H" -- Two-Handed Axes
itemSubTypeIDValues[2][2] = "Bows" -- Bows
itemSubTypeIDValues[2][3] = "Guns" -- Guns
itemSubTypeIDValues[2][4] = "Mace1H" -- One-Handed Maces
itemSubTypeIDValues[2][5] = "Mace2H" -- Two-Handed Maces
itemSubTypeIDValues[2][6] = "Polearm" -- Polearms
itemSubTypeIDValues[2][7] = "Sword1H" -- One-Handed Swords
itemSubTypeIDValues[2][8] = "Sword2H" -- Two-Handed Swords
itemSubTypeIDValues[2][9] = "Warglaive" -- Warglaives
itemSubTypeIDValues[2][10] = "Staff" -- Staves
itemSubTypeIDValues[2][11] = "Bearclaw" -- Bear Claws
itemSubTypeIDValues[2][12] = "Catclaw" -- CatClaws
itemSubTypeIDValues[2][13] = "Unarmed" -- Fist Weapons
itemSubTypeIDValues[2][14] = "Generic" -- Miscellaneous
itemSubTypeIDValues[2][15] = "Dagger" -- Daggers
itemSubTypeIDValues[2][16] = "Thrown" -- Thrown	Classic
itemSubTypeIDValues[2][17] = "Obsolete3" -- Spears
itemSubTypeIDValues[2][18] = "Crossbow" -- Crossbows
itemSubTypeIDValues[2][19] = "Wand" -- Wands
itemSubTypeIDValues[2][20] = "Fishingpole" -- Fishing Poles

--=====================
-- Gem
itemSubTypeIDValues[3] = {} 
--=====================
itemSubTypeIDValues[3][0] = "Intellect" -- Intellect
itemSubTypeIDValues[3][1] = "Agility" -- Agility
itemSubTypeIDValues[3][2] = "Strength" -- Strength
itemSubTypeIDValues[3][3] = "Stamina" -- Stamina
itemSubTypeIDValues[3][4] = "Spirit" -- Spirit
itemSubTypeIDValues[3][5] = "Criticalstrike" -- Critical Strike
itemSubTypeIDValues[3][6] = "Mastery" -- Mastery
itemSubTypeIDValues[3][7] = "Haste" -- Haste
itemSubTypeIDValues[3][8] = "Versatility" -- Versatility
itemSubTypeIDValues[3][9] = "Other" -- Other
itemSubTypeIDValues[3][10] = "Multiplestats" -- Multiple Stats
itemSubTypeIDValues[3][11] = "Artifactrelic" -- Artifact Relic

--=====================
-- Armor
itemSubTypeIDValues[4] = {} 
--=====================
itemSubTypeIDValues[4][0] = "Generic" -- Miscellaneous	Includes Spellstones, Firestones, Trinkets, Rings and Necks
itemSubTypeIDValues[4][1] = "Cloth" -- Cloth
itemSubTypeIDValues[4][2] = "Leather" -- Leather
itemSubTypeIDValues[4][3] = "Mail" -- Mail
itemSubTypeIDValues[4][4] = "Plate" -- Plate
itemSubTypeIDValues[4][5] = "Cosmetic" -- Cosmetic
itemSubTypeIDValues[4][6] = "Shield" -- Shields
itemSubTypeIDValues[4][7] = "Libram" -- Librams	Classic
itemSubTypeIDValues[4][8] = "Idol" -- Idols	Classic
itemSubTypeIDValues[4][9] = "Totem" -- Totems	Classic
itemSubTypeIDValues[4][10] = "Sigil" -- Sigils	Classic
itemSubTypeIDValues[4][11] = "Relic" -- Relic

--=====================
-- Reagent
itemSubTypeIDValues[5] = {} 
--=====================
-- For crafting reagents see 7: Tradeskill. For spell reagents see 15: Miscellaneous.
itemSubTypeIDValues[5][0] = "Reagent" -- Reagent
itemSubTypeIDValues[5][1] = "Keystone" -- Keystone
itemSubTypeIDValues[5][2] = "ContextToken" -- Context Token

--=====================
-- Projectile
itemSubTypeIDValues[6] = {} 
--=====================
itemSubTypeIDValues[6][0] = "Wand" -- (OBSOLETE)
itemSubTypeIDValues[6][1] = "Bolt" -- (OBSOLETE)
itemSubTypeIDValues[6][2] = "Arrow"
itemSubTypeIDValues[6][3] = "Bullet"
itemSubTypeIDValues[6][4] = "Thrown" -- (OBSOLETE)

--=====================
-- Tradeskill
itemSubTypeIDValues[7] = {} 
--=====================
itemSubTypeIDValues[7][0] = "Trade Goods" -- (OBSOLETE)
itemSubTypeIDValues[7][1] = "Parts"
itemSubTypeIDValues[7][2] = "Explosives" -- (OBSOLETE)
itemSubTypeIDValues[7][3] = "Devices" -- (OBSOLETE)
itemSubTypeIDValues[7][4] = "Jewelcrafting"
itemSubTypeIDValues[7][5] = "Cloth"
itemSubTypeIDValues[7][6] = "Leather"
itemSubTypeIDValues[7][7] = "Metal & Stone"
itemSubTypeIDValues[7][8] = "Cooking"
itemSubTypeIDValues[7][9] = "Herb"
itemSubTypeIDValues[7][10] = "Elemental"
itemSubTypeIDValues[7][11] = "Other"
itemSubTypeIDValues[7][12] = "Enchanting"
itemSubTypeIDValues[7][13] = "Materials" -- (OBSOLETE)
itemSubTypeIDValues[7][14] = "Item Enchantment" -- (OBSOLETE)
itemSubTypeIDValues[7][15] = "Weapon Enchantment" -- (OBSOLETE)
itemSubTypeIDValues[7][16] = "Inscription"
itemSubTypeIDValues[7][17] = "Explosives and Devices" -- (OBSOLETE)

--=====================
-- Item Enhancement
itemSubTypeIDValues[8] = {} 
--=====================
itemSubTypeIDValues[8][0] = "Head"
itemSubTypeIDValues[8][1] = "Neck"
itemSubTypeIDValues[8][2] = "Shoulder"
itemSubTypeIDValues[8][3] = "Cloak"
itemSubTypeIDValues[8][4] = "Chest"
itemSubTypeIDValues[8][5] = "Wrist"
itemSubTypeIDValues[8][6] = "Hands"
itemSubTypeIDValues[8][7] = "Waist"
itemSubTypeIDValues[8][8] = "Legs"
itemSubTypeIDValues[8][9] = "Feet"
itemSubTypeIDValues[8][10] = "Finger"
itemSubTypeIDValues[8][11] = "Weapon" -- One-handed weapons
itemSubTypeIDValues[8][12] = "Two-Handed Weapon"
itemSubTypeIDValues[8][13] = "Shield/Off-hand"
itemSubTypeIDValues[8][14] = "Misc"

--=====================
-- Recipe
itemSubTypeIDValues[9] = {} 
--=====================
itemSubTypeIDValues[9][0] = "Book" -- Book
itemSubTypeIDValues[9][1] = "Leatherworking" -- Leatherworking
itemSubTypeIDValues[9][2] = "Tailoring" -- Tailoring
itemSubTypeIDValues[9][3] = "Engineering" -- Engineering
itemSubTypeIDValues[9][4] = "Blacksmithing" -- Blacksmithing
itemSubTypeIDValues[9][5] = "Cooking" -- Cooking
itemSubTypeIDValues[9][6] = "Alchemy" -- Alchemy
itemSubTypeIDValues[9][7] = "FirstAid" -- First Aid
itemSubTypeIDValues[9][8] = "Enchanting" -- Enchanting
itemSubTypeIDValues[9][9] = "Fishing" -- Fishing
itemSubTypeIDValues[9][10] = "Jewelcrafting" -- Jewelcrafting
itemSubTypeIDValues[9][11] = "Inscription" -- Inscription

--=====================
-- Money (Obsolete)
itemSubTypeIDValues[10] = {} 
--=====================
itemSubTypeIDValues[10][0] = "Money" -- (OBSOLETE)

--=====================
-- Quiver
itemSubTypeIDValues[11] = {} 
--=====================
itemSubTypeIDValues[11][0] = "Quiver" -- (OBSOLETE)
itemSubTypeIDValues[11][1] = "Bolt" -- (OBSOLETE)
itemSubTypeIDValues[11][2] = "Quiver"
itemSubTypeIDValues[11][3] = "Ammo Pouch"

--=====================
-- Quest
itemSubTypeIDValues[12] = {} 
--=====================
itemSubTypeIDValues[12][0] = "Quest"

--=====================
-- Key
itemSubTypeIDValues[13] = {} 
--=====================
itemSubTypeIDValues[13][0] = "Key"
itemSubTypeIDValues[13][1] = "Lockpick"

--=====================
-- Permanent (Obsolete)
itemSubTypeIDValues[14] = {} 
--=====================
itemSubTypeIDValues[14][0] = "Permanent"

--=====================
-- Miscellaneous
itemSubTypeIDValues[15] = {} 
--=====================
itemSubTypeIDValues[15][0] = "Junk" -- Junk
itemSubTypeIDValues[15][1] = "Reagent" -- Reagent	Mainly spell reagents. For crafting reagents see 7: Tradeskill.
itemSubTypeIDValues[15][2] = "CompanionPet" -- Companion Pets
itemSubTypeIDValues[15][3] = "Holiday" -- Holiday
itemSubTypeIDValues[15][4] = "Other" -- Other
itemSubTypeIDValues[15][5] = "Mount" -- Mount
itemSubTypeIDValues[15][6] = "MountEquipment" -- Mount Equipment

--=====================
-- Glyph
itemSubTypeIDValues[16] = {} 
--=====================
itemSubTypeIDValues[16][1] = "Warrior"
itemSubTypeIDValues[16][2] = "Paladin"
itemSubTypeIDValues[16][3] = "Hunter"
itemSubTypeIDValues[16][4] = "Rogue"
itemSubTypeIDValues[16][5] = "Priest"
itemSubTypeIDValues[16][6] = "Death Knight"
itemSubTypeIDValues[16][7] = "Shaman"
itemSubTypeIDValues[16][8] = "Mage"
itemSubTypeIDValues[16][9] = "Warlock"
itemSubTypeIDValues[16][1] = "Monk"
itemSubTypeIDValues[16][1] = "Druid"
itemSubTypeIDValues[16][1] = "Demon Hunter"

--=====================
 -- Battle Pets
itemSubTypeIDValues[17] = {}
--=====================
itemSubTypeIDValues[17][0] = "Humanoid" -- Humanoid
itemSubTypeIDValues[17][1] = "Dragonkin" -- Dragonkin
itemSubTypeIDValues[17][2] = "Flying" -- Flying
itemSubTypeIDValues[17][3] = "Undead" -- Undead
itemSubTypeIDValues[17][4] = "Critter" -- Critter
itemSubTypeIDValues[17][5] = "Magic" -- Magic
itemSubTypeIDValues[17][6] = "Elemental" -- Elemental
itemSubTypeIDValues[17][7] = "Beast" -- Beast
itemSubTypeIDValues[17][8] = "Aquatic" -- Aquatic
itemSubTypeIDValues[17][9] = "Mechanical" -- Mechanical

--=====================
 -- WoW Token
itemSubTypeIDValues[18] = {}
--=====================
itemSubTypeIDValues[18][0] = "WoW Token"

--==========================================
-- itemTypeValueIDs -> ids
mod.itemSubTypeIDValues = itemSubTypeIDValues

mod.itemSubTypeValueIDs = {}
mod.itemSubTypeValueIDs["Consumable"] = bdUI:swaptable(itemSubTypeIDValues[0])
mod.itemSubTypeValueIDs["Container"] = bdUI:swaptable(itemSubTypeIDValues[1])
mod.itemSubTypeValueIDs["Weapon"] = bdUI:swaptable(itemSubTypeIDValues[2])
mod.itemSubTypeValueIDs["Gem"] = bdUI:swaptable(itemSubTypeIDValues[3])
mod.itemSubTypeValueIDs["Armor"] = bdUI:swaptable(itemSubTypeIDValues[4])
mod.itemSubTypeValueIDs["Reagent"] = bdUI:swaptable(itemSubTypeIDValues[5])
mod.itemSubTypeValueIDs["Projectile"] = bdUI:swaptable(itemSubTypeIDValues[6])
mod.itemSubTypeValueIDs["Tradegoods"] = bdUI:swaptable(itemSubTypeIDValues[7])
mod.itemSubTypeValueIDs["ItemEnhancement"] = bdUI:swaptable(itemSubTypeIDValues[8])
mod.itemSubTypeValueIDs["Recipe"] = bdUI:swaptable(itemSubTypeIDValues[9])
mod.itemSubTypeValueIDs["CurrencyTokenObsolete"] = bdUI:swaptable(itemSubTypeIDValues[10])
mod.itemSubTypeValueIDs["Quiver"] = bdUI:swaptable(itemSubTypeIDValues[11])
mod.itemSubTypeValueIDs["Questitem"] = bdUI:swaptable(itemSubTypeIDValues[12])
mod.itemSubTypeValueIDs["Key"] = bdUI:swaptable(itemSubTypeIDValues[13])
mod.itemSubTypeValueIDs["PermanentObsolete"] = bdUI:swaptable(itemSubTypeIDValues[14])
mod.itemSubTypeValueIDs["Miscellaneous"] = bdUI:swaptable(itemSubTypeIDValues[15])
mod.itemSubTypeValueIDs["Glyph"] = bdUI:swaptable(itemSubTypeIDValues[16])
mod.itemSubTypeValueIDs["Battlepet"] = bdUI:swaptable(itemSubTypeIDValues[17])
mod.itemSubTypeValueIDs["WoW Token"] = bdUI:swaptable(itemSubTypeIDValues[18])
--==========================================

local types = {}
types["Consumable"] = {0}
types["Weapon"] = {2, 6, 11}
types["Gems"] = {3}
types["Armor"] = {4}
types["Tradeskill"] = {1, 5, 7, 9}
types["Recipes"] = {9}
types["Enchantment"] = {8, 16}
types["Quest"] = {12}
types["Keys"] = {13}
types["Tokens"] = {10, 14, 18}
types["Battle Pets"] = {17}
types["Misc"] = {15}

mod.types = types

local subtypes = {}
subtypes["Food"] = {0.5}
subtypes["Potions"] = {0.1, 0.2, 0.3}
subtypes["Explosives"] = {0.0, 7.2, 7.17} 
subtypes["Archaeology"] = {5.1}
subtypes["Mount"] = {15.5, 15.6}
subtypes["Holiday"] = {15.3}
subtypes["Generic Weapons"] = {2.14}

mod.subtypes = subtypes

-- ===============================
-- ItemLevel Compat
-- ===============================
GetAverageItemLevel = GetAverageItemLevel or function()
	-- local total = 0
	-- local slots = 0
	-- for i = 1, 18 do
	-- 	if (i ~= 4) then
	-- 		local ItemLink = GetInventoryItemLink("player", i)
	-- 		if (ItemLink) then
	-- 			local ItemName, ItemLink, ItemRarity, ItemLevel, ItemMinLevel, ItemType, ItemSubType, ItemStackCount, ItemEquipLoc, ItemTexture = GetItemInfo(ItemLink)
	-- 			if (ItemLevel) then
	-- 				slots = slots + 1
	-- 				total = total + ItemLevel 
	-- 			end
	-- 		end
	-- 	end
	-- end

	return 100

	-- return total / slots
end


-- ===============================
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
	mod.myilvl = select(1, GetAverageItemLevel())

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
mod:add_filter("itemType", 1, function(conditions, itemLink, itemID, name, rarity, ilvl, minlevel, itemEquipLoc, price, itemTypeID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent, category)
	if (category.locked) then 
		return false 
	end
	if (#conditions['type'] == 0 and #conditions['subtype'] == 0) then
		return false
	end

	if (itemTypeID == nil or itemSubClassID == nil) then
		return false
	end

	local found_type = tContains(conditions['type'], itemTypeID)
	local found_subtype = tContains(conditions['subtype'], tonumber(itemTypeID.."."..itemSubClassID))

	-- print(name, itemSubClassID)

	-- if (tContains(conditions['subtype'], itemSubClassID)) then
	-- 	return true
	-- else
	-- end
	if (found_subtype) then 
		return 3
	elseif (found_type) then
		return 1
	end
end)

--===============================
-- Item Subtype
--===============================
-- mod:add_filter("itemSubType", 2.5, function(conditions, itemLink, itemID, name, rarity, ilvl, minlevel, itemEquipLoc, price, itemTypeID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent)
-- 	if (#conditions['subtype'] == 0) then return false end

-- 	-- print(itemLink)
-- 	for i = 1, #conditions['subtype'] do
-- 		local val = conditions['subtype'][i]
-- 		local typeid, subtypeid = strsplit(".", val)
-- 		subtypeid = subtypeid or typeid

-- 		-- print(typeid, itemTypeID, subtypeid, itemSubClassID)
-- 		-- -- local typeid, subtypes = unpack()
-- 		if (tonumber(typeid) == itemTypeID and tonumber(subtypeid) == itemSubClassID) then
-- 			return true
-- 		end
-- 	end
-- end)

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
	-- dump(conditions)
	if (conditions["ilvl"] == 0 or not ilvl) then return false end
	if (itemEquipLoc ~= "" and minlevel > 1) then


		if (ilvl <= mod.myilvl * 0.8) then
			return 2
		end
	end
end)