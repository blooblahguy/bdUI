--===============================================
-- INIT
--===============================================
local bdUI, c, l = unpack(select(2, ...))
-- local config = {}

local config = {
	{
		key = "enablett",
		type = "toggle",
		value = true,
		label = "Enable Tooltips"
	},

	{
		key = "tooltips",
		type = "group",
		heading = "Main Tooltips",
		args = {
			{
				key = "text",
				type = "text",
				value = "Hint: Hold shift over a player to see their spec and ilvl",
			},
			{
				key = "showrealm",
				type = "toggle",
				value = true,
				label = "Show Realm Name"
			},
			{
				key = "anchor",
				type = "select",
				value = "Frame",
				options = {"Frame", "Mouse"},
				label = "Tooltip Anchor"
			},
			-- {
			-- 	key = "itemids",
			-- 	type = "toggle",
			-- 	value = false,
			-- 	label = "Enable itemIDs in tooltip"
			-- },
			-- {
			-- 	key = "spellids",
			-- 	type = "toggle",
			-- 	value = true,
			-- 	label = "Enable spellIDs in tooltip"
			-- },
			{
				key = "enablelinecolors",
				type = "toggle",
				value = true,
				label = "Enable line-coloring"
			},
		}
	},
	{
		key = "mouseovertooltips",
		type = "group",
		heading = "Lite Tooltips",
		args = {
			{
				key = "enablemott",
				type = "toggle",
				value = true,
				label = "Enable lite tooltips on unit mouseover"
			}
		}
	},
	{
		key = "titles",
		type = "group",
		heading = "Titles",
		args = {
			{
				key = "enabletitlesintt",
				type = "toggle",
				value = true,
				label = "Enable title display in unit mouseover"
			}
		}
	},
	
}

local mod = bdUI:register_module("Tooltips", config)

function mod:initialize()
	mod.config = mod:get_save()
	if (not mod.config.enablett) then return end

	mod:create_tooltips()
	mod:color_tooltips()
	mod:create_mouseover_tooltips()
end

function mod:config_callback()
	mod.config = mod:get_save()

end
