local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Tooltips")
local config = {}

----------------------------------------------
-- Neat Colors to things
----------------------------------------------
local colors = {
	stamina = "00CCFF",
	strength = "ba6418",
	agility = "00CCFF",
	intellect = "00CCFF",
}

local global_patterns = {
	["COOLDOWN_REMAINING"] = "|CFF999999Cooldown remaining|r",
	["ENERGY_COST"] = "%s |CFFFFFF00Energy|r",
	["ITEM_COOLDOWN_TIME"] = "|CFF999999Cooldown remaining|r %s",
	["ITEM_COOLDOWN_TIME_DAYS"] = "|CFF999999Cooldown remaining|r %d |4day:days;",
	["ITEM_COOLDOWN_TIME_HOURS"] = "|CFF999999Cooldown remaining|r %d |4hour:hours;",
	["ITEM_COOLDOWN_TIME_MIN"] = "|CFF999999Cooldown remaining|r %d min.",
	["ITEM_COOLDOWN_TIME_SEC"] = "|CFF999999Cooldown remaining|r %d sec.",
	["ITEM_MOD_MANA"] = "%1$c%2$d |CFF3399FFMana|r",
	["SPELL_RECAST_TIME_MIN"] = "|CFF999999%.3g min cooldown|r",
	["SPELL_RECAST_TIME_SEC"] = "|CFF999999%.3g sec cooldown|r",
	["MELEE_RANGE"] = "|CFF00FF00Melee Range|r",
	["SPELL_RANGE"] = "%s |CFF00FF00yd range|r",
	["SPELL_ON_NEXT_SWING"] = "|CFFFF66CCNext melee|r",
	["ITEM_SOULBOUND"] = "|CFFFF6633Soulbound|r",
	["ITEM_ACCOUNTBOUND"] = "|CFFCC66FFAccount Bound|r",
	["ITEM_BIND_ON_EQUIP"] = "|CFFCC66FFBinds when|r |CFFFF66CCequipped|r",
	["ITEM_BIND_ON_PICKUP"] = "|CFFCC66FFBinds when|r |CFFFF66CCpicked up|r",
	["ITEM_BIND_ON_USE"] = "|CFFCC66FFBinds when|r |CFFFF66CCused|r",
	["ITEM_BIND_QUEST"] = "|CFFCC66FFQuest Item|r",
	["ITEM_STARTS_QUEST"] = "|CFFCC66FFThis Item Begins a Quest|r",
	["ITEM_BIND_TO_ACCOUNT"] = "|CFFCC66FFBinds to account|r",
	["DURABILITY_TEMPLATE"] = "|CFF00CCFFDurability|r %d / %d",
	["ITEM_UNIQUE"] = "|CFFFFFF66Unique|r",
	["ITEM_UNIQUE_EQUIPPABLE"] = "|CFFFFFF66Unique-Equipped|r",
	["HEALTH_COST"] = "%s |CFF00FF00Health|r",
	["HEALTH_COST_PER_TIME"] = "%s |CFF00FF00Health|r, plus %s per sec",
	["MANA_COST"] = "%s |CFF3399FFMana|r",
	["MANA_COST_PER_TIME"] = "%s |CFF3399FFMana|r, plus %s per sec",
	["RUNE_COST_BLOOD"] = "%s |CFFFF0000Blood|r",
	["RUNE_COST_FROST"] = "%s |CFF3399FFFrost|r",
	["RUNE_COST_UNHOLY"] = "%s |CFF00FF00Unholy|r",
	["RUNIC_POWER"] = "|CFF66F0FFRunic Power|r",
	["RUNIC_POWER_COST"] = "%s |CFF66F0FFRunic Power|r",
	["RUNIC_POWER_COST_PER_TIME"] = "%s |CFF66F0FFRunic Power|r, plus %s per sec.",
	["REQUIRES_RUNIC_POWER"] = "Requires |CFF66F0FFRunic Power|r",
	["SPELL_USE_ALL_ENERGY"] = "Consumed 100% |CFFFFFF00Energy|r.",
	["SPELL_USE_ALL_FOCUS"] = "Consumed 100% |CFFFFCC33Fokus|r.",
	["SPELL_USE_ALL_HEALTH"] = "Consumed 100% |CFF00FF00Health|r.",
	["SPELL_USE_ALL_MANA"] = "Consumed 100% |CFF3399FFMana|r.",
	
	["SPELL_USE_ALL_RAGE"] = "Consumed 100% |CFFCC3333Rage|r.",
	["RAGE_COST"] = "|CFFCC3333%s Rage|r",

	["SPELL_CAST_TIME_INSTANT"] = "|CFFCC66FFInstant cast|r",
	["SPELL_CAST_TIME_INSTANT_NO_MANA"] = "|CFFCC66FFInstant|r",

	-- ["SHIELD_BLOCK_TEMPLATE"] = "%s |cff808080Block|r",
	["ARMOR_TEMPLATE"] = "|cffA0A0A0%s Armor|r",

	["ITEM_SOCKETABLE"] = "",

	-- ["SPELL_STAT2_NAME"] = "|cffAAEE72Agility|r",
	-- ["ITEM_MOD_AGILITY"] = "|cffAAEE72%c%s Agility|r",
	-- ["ITEM_MOD_AGILITY_SHORT"] = "|cffAAEE72Agility|r",
	-- ["PRIMARY_STAT2_TOOLTIP_NAME"] = "|cffAAEE72Agility|r",
	-- ["SPEC_FRAME_PRIMARY_STAT_AGILITY"] = "|cffAAEE72Agility|r",

	-- ["SPELL_STAT4_NAME"] = "|cff4D85E6Intellect|r",
	-- ["PRIMARY_STAT4_TOOLTIP_NAME"] = "|cff4D85E6Intellect|r",
	-- ["SPEC_FRAME_PRIMARY_STAT_INTELLECT"] = "|cff4D85E6Intellect|r",
	-- ["ITEM_MOD_INTELLECT"] = "|cff4D85E6%c%s Intellect|r",
	-- ["ITEM_MOD_INTELLECT_SHORT"] = "|cff4D85E6Intellect|r",

	-- ["SPELL_STAT5_NAME"] = "|cff4D85E6Spirit|r",
	-- ["ITEM_MOD_SPIRIT"] = "|cff4D85E6%c%s Spirit|r",
	-- ["ITEM_MOD_SPIRIT_SHORT"] = "|cff4D85E6Spirit|r",

	-- ["RAID_BUFF_2"] = "|cff"..colors.stamina.."Stamina|r",
	-- ["SPELL_STAT3_NAME"] = "|cff"..colors.stamina.."Stamina|r",
	-- ["PRIMARY_STAT3_TOOLTIP_NAME"] = "|cff"..colors.stamina.."Stamina|r",
	-- ["ITEM_MOD_STAMINA"] = "|CFF00CCFF%c%s Sta"..colors.stamina.."",
	-- ["ITEM_MOD_STAMINA_SHORT"] = "|CFF"..colors.stamina.."Stamina|r",

	-- ["SPELL_STAT1_NAME"] = "|CFF"..colors.strength.."Strength|r",
	-- ["PRIMARY_STAT1_TOOLTIP_NAME"] = "|CFF"..colors.strength.."Strength|r",
	-- ["ITEM_MOD_STRENGTH"] = "|CFF"..colors.strength.."%c%s Strength|r",
	-- ["ITEM_MOD_STRENGTH_SHORT"] = "|CFF"..colors.strength.."Strength|r",
	-- ["SPEC_FRAME_PRIMARY_STAT_STRENGTH"] = "|CFF"..colors.strength.."%c%s Strength|r",

	-- ["ITEM_MOD_STRENGTH_OR_INTELLECT_SHORT"] = "|CFFba6418Strength|r or Intellect",
	-- ["ITEM_MOD_VERSATILITY"] = "|CFFf6ff00Versatility|r",
	-- ["ITEM_MOD_CRIT_RATING_SHORT"] = "|CFFf6ff00Critical Strike|r",
	["RESISTANCE1_NAME"] = "|cffFFE680Holy Resistance|r",
	["RESISTANCE2_NAME"] = "|cffFF8000Fire Resistance|r",
	["RESISTANCE3_NAME"] = "|cff4DFF4DNature Resistance|r",
	["RESISTANCE4_NAME"] = "|cff80FFFFFrost Resistance|r",
	["RESISTANCE5_NAME"] = "|cff8080FFShadow Resistance|r",
	["RESISTANCE6_NAME"] = "|cffFF80FFArcane Resistance|r",
}

local tooltips = {
	'GameTooltip',
	'ItemRefTooltip',
	'ItemRefShoppingTooltip1',
	'ItemRefShoppingTooltip2',
	'ShoppingTooltip1',
	'ShoppingTooltip2',
	'DropDownList1MenuBackdrop',
	'DropDownList2MenuBackdrop',
}

local function skin_item_icons(self)
	local texture
	for i = 1, 10 do
		texture = _G[self:GetName().."Texture"..i]

		if texture and texture:GetTexture() then
			if (not texture.border) then
				-- texture.border = self:CreateTexture(nil, "BACKGROUND")
				
			end

			-- print(texture:GetTexture(), texture:IsShown())
			texture:SetTexCoord(.07, .93, .07, .93)
			-- texture.border:SetTexture(bdUI.media.flat)
			-- texture.border:SetVertexColor(bdUI.media.backdrop)
			-- texture.border:SetPoint("TOPLEFT", texture, -bdUI.pixel, bdUI.pixel)
			-- texture.border:SetPoint("BOTTOMRIGHT", texture, bdUI.pixel, -bdUI.pixel)
			-- texture.border:SetShown(texture:IsShown())
		end
-- 		local text = line and line:GetText()
	end
end

-- local patterns = {
-- 	{"%+%d+ Stamina", colors["stamina"]},
-- 	{"Stamina", colors["stamina"]},
-- }

local hooked = false
local function try_global_overwrite_secure() -- testing overwriting the global variables inside of a secure hook once
	if hooked then return end
	for global, pattern in pairs(global_patterns) do
		_G[global] = pattern
	end
	hooked = true
end

-- this isn't efficient, but it seems to avoid taints at least
-- local function color_lines(self)

-- 	local line, i = true, 0
-- 	while line do
-- 		i = i + 1
-- 		line = _G[self:GetName().."TextLeft"..i]
-- 		local text = line and line:GetText()
-- 		if text and string.len(text) > 0 then
-- 			for pi = 1, #patterns do
-- 				local find, color = unpack(patterns[pi])
-- 				-- print(text, find, replace)
-- 				-- if (_G[global]) then
-- 				local string_found = string.match(text, find)
-- 				if (string_found) then
-- 					-- print(find_pattern)
-- 					string_found = "|cff"..color..string_found.."|r"
-- 					print(text, string.match(text, find), string_found)
-- 					-- local formated = string.format()
-- 					-- local new_string = string.gsub(text, find, )
-- 					-- print("replace it!", "|cff"..color..text.."|r")
-- 					line:SetText(string.gsub(text, find, string_found)) -- replace these global strings with our own

-- 					break
-- 				end
-- 			end
-- 		end
-- 	end
-- end


function mod:color_tooltips()
	for i = 1, #tooltips do
		bdUI:SecureHookScript(_G[tooltips[i]], "OnShow", function(self)
			skin_item_icons(self)
			if (_G[tooltips[i]] == GameTooltip) then
				try_global_overwrite_secure(self)
			end
		end)
		
	end

	-- bdUI:SecureHookScript(GameTooltip, "OnShow", try_global_overwrite_secure) -- testing this to see if it doesn't trigger taints
end