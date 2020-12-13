local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Tooltips")
local config = {}


function mod:color_tooltips()
	----------------------------------------------
	-- Neat Colors to things
	----------------------------------------------
	-- COOLDOWN_REMAINING = "|CFF999999Cooldown remaining|r"
	-- ENERGY_COST = "%s |CFFFFFF00Energy|r"
	-- ITEM_COOLDOWN_TIME = "|CFF999999Cooldown remaining|r %s";
	-- ITEM_COOLDOWN_TIME_DAYS = "|CFF999999Cooldown remaining|r %d |4day:days;"
	-- ITEM_COOLDOWN_TIME_HOURS = "|CFF999999Cooldown remaining|r %d |4hour:hours;"
	-- ITEM_COOLDOWN_TIME_MIN = "|CFF999999Cooldown remaining|r %d min."
	-- ITEM_COOLDOWN_TIME_SEC = "|CFF999999Cooldown remaining|r %d sec."
	-- ITEM_MOD_MANA = "%1$c%2$d |CFF3399FFMana|r"
	-- SPELL_RECAST_TIME_MIN = "|CFF999999%.3g min cooldown|r"
	-- SPELL_RECAST_TIME_SEC = "|CFF999999%.3g sec cooldown|r"
	-- MELEE_RANGE = "|CFF00FF00Melee Range|r"
	-- SPELL_RANGE = "%s |CFF00FF00yd range|r"
	-- SPELL_ON_NEXT_SWING = "|CFFFF66CCNext melee|r"
	-- -- ITEM_SOULBOUND = "|CFFFF6633Soulbound|r"
	-- ITEM_ACCOUNTBOUND = "|CFFCC66FFAccount Bound|r";
	-- ITEM_BIND_ON_EQUIP = "|CFFCC66FFBinds when|r |CFFFF66CCequipped|r"
	-- ITEM_BIND_ON_PICKUP = "|CFFCC66FFBinds when|r |CFFFF66CCpicked up|r"
	-- ITEM_BIND_ON_USE = "|CFFCC66FFBinds when|r |CFFFF66CCused|r"
	-- ITEM_BIND_QUEST = "|CFFCC66FFQuest Item|r"
	-- ITEM_BIND_TO_ACCOUNT = "|CFFCC66FFBinds to account|r"
	-- DURABILITY_TEMPLATE = "|CFF00CCFFDurability|r %d / %d"
	-- ITEM_UNIQUE = "|CFFFFFF66Unique|r"
	-- ITEM_UNIQUE_EQUIPPABLE = "|CFFFFFF66Unique-Equipped|r"
	-- HEALTH_COST = "%s |CFF00FF00Health|r"
	-- HEALTH_COST_PER_TIME = "%s |CFF00FF00Health|r, plus %s per sec"
	-- MANA_COST = "%s |CFF3399FFMana|r"
	-- MANA_COST_PER_TIME = "%s |CFF3399FFMana|r, plus %s per sec"
	-- RUNE_COST_BLOOD = "%s |CFFFF0000Blood|r"
	-- RUNE_COST_FROST = "%s |CFF3399FFFrost|r"
	-- RUNE_COST_UNHOLY = "%s |CFF00FF00Unholy|r"
	-- RUNIC_POWER = "|CFF66F0FFRunic Power|r"
	-- RUNIC_POWER_COST = "%s |CFF66F0FFRunic Power|r"
	-- RUNIC_POWER_COST_PER_TIME = "%s |CFF66F0FFRunic Power|r, plus %s per sec."
	-- REQUIRES_RUNIC_POWER = "Requires |CFF66F0FFRunic Power|r"
	-- SPELL_USE_ALL_ENERGY = "Consumed 100% |CFFFFFF00Energy|r."
	-- SPELL_USE_ALL_FOCUS = "Consumed 100% |CFFFFCC33Fokus|r."
	-- SPELL_USE_ALL_HEALTH = "Consumed 100% |CFF00FF00Health|r."
	-- SPELL_USE_ALL_MANA = "Consumed 100% |CFF3399FFMana|r."
	-- SPELL_USE_ALL_RAGE = "Consumed 100% |CFFCC3333Rage|r."
	-- SPELL_CAST_TIME_INSTANT = "|CFFCC66FFInstant cast|r"
	-- SPELL_CAST_TIME_INSTANT_NO_MANA = "|CFFCC66FFInstant|r"

	-- ITEM_MOD_SPIRIT = "%c%s Spirit";
	-- ITEM_MOD_SPIRIT_SHORT = "Spirit";
	-- ITEM_MOD_STAMINA = "%c%s |CFF00FF00Stamina|r";
	-- ITEM_MOD_STAMINA_SHORT = "|CFF00FF00Stamina|r";
	-- ITEM_MOD_STRENGTH = "%c%s |CFFba6418Strength|r";
	-- ITEM_MOD_STRENGTH_OR_INTELLECT_SHORT = "|CFFba6418Strength|r or Intellect";
	-- ITEM_MOD_VERSATILITY = "|CFFf6ff00Versatility|r";
	-- ITEM_MOD_CRIT_RATING_SHORT = "|CFFf6ff00Critical Strike|r";
	-- ITEM_MOD_STRENGTH_SHORT = "Strength";
end