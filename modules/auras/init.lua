--===============================================
-- INIT
--===============================================
local bdUI, c, l = unpack(select(2, ...))

local friendlyclass, class = UnitClass("player")

-- Config Table
local config = {
	{
		key = "text",
		type = "text",
		value = "Auras are used throughout bdUI to determine what buffs and debuffs should be shown on each frame (player, target, bosses, nameplates, grid)."
	},
	{
		key = "tab",
		type = "tab",
		label = "Whitelist",
		args = {
			{
				key = "text",
				type = "text",
				value = "Add an aura to this list to force it show up. Useful for personal cooldowns, raid encounter debuffs, or other player auras."
			},
			{
				key = "whitelist",
				type = "list",
				value = bdUI.aura_lists.whitelist,
				label = "Whitelisted Auras",
			}
		}
	},
	{
		key = "tab",
		type = "tab",
		label = "My Casts",
		args = {
			{
				key = "text",
				type = "text",
				value = "Show these auras when they are cast by you"
			},
			{
				key = "mine",
				type = "list",
				value = bdUI.aura_lists.mine,
				label = "My Auras",
			}
		}
	},
	{
		key = "tab1",
		type = "tab",
		label = friendlyclass.." Auras",
		args = {
			{
				key = "text",
				type = "text",
				value = "Shows spells only while playing a "..friendlyclass..". ie only show paladin beacons while you are playing a paladin."
			},
			{
				key = class,
				type = "list",
				value = bdUI.aura_lists.class[class],
				label = friendlyclass.." Auras",
			}
		}
	},
	{
		key = "tab2",
		type = "tab",
		label = "Blacklist",
		args = {
			{
				key = "text",
				type = "text",
				value = "The blacklist overrides all previous aura configurations and hides an aura if its in this list."
			},
			{
				key = "blacklist",
				type = "list",
				value = bdUI.aura_lists.blacklist,
				label = "Blacklisted Auras",
			}
		}
	},
}

local mod = bdUI:register_module("Auras", config, {
	persistent = true
})