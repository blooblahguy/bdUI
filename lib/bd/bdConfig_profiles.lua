--===============================================
-- INIT
--===============================================
local bdUI, c, l = unpack(select(2, ...))

-- make new profile form
local name, realm = UnitName("player")
realm = GetRealmName()
local placeholder = name.."-"..realm
local profile_table = {}

-- Configuration Table
local config = bdConfig:helper_config()
config:add("intro", {
	type = "text",
	value = "You can use profiles to store configuration per character and spec automatically, or save templates to use when needed."
})

config:add("currentprofile", {
	type = "dropdown",
	value = c.profile,
	override = true,
	options = profile_table,
	update = function(dropdown) profileDropdown(dropdown) end,
	updateOn = "bd_update_profiles",
	tooltip = "Your currently selected profile.",
	callback = function(self, value) profileChange(value) end
})
config:add("createprofile", {
	type = "textbox",
	value = placeholder,
	button = "Create & Copy",
	description = "Create New Profile: ",
	tooltip = "Your currently selected profile.",
	callback = addProfile
})
config:add("deleteprofile", {
	type = "button",
	value = "Delete Current Profile",
	callback = function(self) deleteProfile() end
})

local mod = bdUI:register_module("Profiles", config)


function mod:initialize()

end

function mod:change_profile()

end