local addonName, ns = ...
local mod = ns.bdConfig
mod.profiles = {}
local profiles = mod.profiles

local player, realm = UnitName("player")
realm = GetRealmName()
local placeholder = player.."-"..realm

--============================================
-- Profile Functions
--============================================
local profile_table = {}

-- return fresh copy of available profiles
local function get_profiles()
	table.wipe(profile_table}

	for k, v in pairs(_G[profiles.sv_string].profiles) do
		table.insert(profile_table, k)
	end

	return profile_table
end

-- create new profile
local function create_profile(button, options)
	local value = options.save['createprofile']
	print("create", value)

	change_profile(nil, nil, value)
end

-- delete current profile
local function delete_profile(button, options)
	local value = _G[profiles.sv_string].users[player].profile
	print("delete", value)

	if (value == "default") then
		print("You cannot delete the \"default\" profile")
		return
	end

	change_profile("default")
end

-- change profile
local function change_profile(select, options, value)
	--_G[profiles.sv_string].users[player].profile = value
	print("change", value)

	mod:do_action("profile_changed")
end

--============================================
-- Spec Profiles
--============================================
local function build_spec_profiles()
	local specs = GetNumSpecializations()

	local spec_config = {}
	for i = 1, specs do
		local id, name, description, icon, background, role = GetSpecializationInfo(i)
		local c = {
			key = "spec_profile_"..i,
			type = "select",
			value = "default",
			label = name.." profile",
			action = "profile_change",
			lookup = get_profiles,
			options = profile_table
		}
		table.insert(spec_config, c)
	end

	return spec_config
end

--============================================
-- Main configuration
--============================================
local config = {
	{
		key = "text",
		type = "text",
		value = "Profiles can be used to store different positioning and configuration settings for different characters and specs",
	},
	{
		key = "currentprofile",
		type = "select",
		value = "default",
		options = profile_table,
		action = "profile_change",
		lookup = get_profiles,
		callback = change_profile
	},
	{
		key = "group",
		type = "group",
		heading = "Spec Profiles",
		args = {
			build_spec_profiles()
		}
	},
	{
		key = "group",
		type = "group",
		heading = "Manage Profiles",
		args = {
			{
				key = "createprofile",
				type = "input",
				label = "Create Profile",
				value = placeholder
			},
			{
				key = "createprofilesubmit",
				type = "button",
				label = "Create Profile",
				callback = create_profile
			}
		}
	}
}

function mod:create_profiles(saved_variables_string, disable_spec_profiles)
	profiles.sv_string = saved_variables_string

	-- populate spec table
	for k, v in pairs(_G[profiles.sv_string].profiles) do
		table.insert(profile_table, k)
	end

	-- remove spec profile options
	if (disable_spec_profiles) then
		table.remove(config[3])
	end

	-- Register inside of config window
	local mod = bdUI:register_module("Profiles", config, {
		persistent = true
	})
end