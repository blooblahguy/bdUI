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
				value = false,
				label = "Enable title display in unit mouseover"
			}
		}
	},
	
}

local mod = bdUI:register_module("Tooltips", config)

function mod:initialize()
	mod.config = mod:get_save()
	if (not mod.config.enablett) then return end

	--============================
	-- elements
	--============================
	mod:create_castby()
	mod:create_mouseover_tooltips()
	-- mod:color_tooltips()
	mod:fix_healthbars()
	mod:create_unit_info()
	mod:create_targettarget()

	-- now do the rest
	mod:create_tooltips()

	-- disable quest tracking in combat
	local f = CreateFrame("Frame")
	f:RegisterEvent("GROUP_ROSTER_UPDATE")
	f:RegisterEvent("PLAYER_ENTERING_WORLD")
	f:SetScript("OnEvent", function(self, event)
		SetCVar("showQuestTrackingTooltips", IsInRaid() and 0 or 1)
	end)

end

function mod:config_callback()
	mod.config = mod:get_save()

end
