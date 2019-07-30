local addonName, ns = ...
local mod = ns.bdConfig
mod.profiles = {}
local profiles = mod.profiles

local class = select(2, UnitClass("player"))
local player, realm = UnitName("player")
realm = GetRealmName()
local placeholder = player.."-"..realm

--============================================
-- Profile Functions
--============================================
local profile_table = {}

-- change profile
local function change_profile(select, options, value)
	_G[profiles.sv_string].users[player].profile = value
	_G[profiles.sv_string].persistent.Profiles.currentprofile = value

	mod:do_action("profile_change", value)
end

-- return fresh copy of available profiles
local function get_profiles()
	table.wipe(profile_table)

	for k, v in pairs(_G[profiles.sv_string].profiles) do
		table.insert(profile_table, k)
	end

	return profile_table
end

-- create new profile
local function create_profile(button, options)
	local sv = _G[profiles.sv_string]
	local value = options.save['createprofile']
	local old = sv.users[player].profile

	if (sv.profiles[value]) then
		print(value, "Already exists.", "Profile must have unique names")
		return
	end

	-- Create profile and copy settings over
	sv.profiles[value] = {}
	Mixin(sv.profiles[value], sv.profiles[old])

	change_profile(nil, nil, value)
end

-- delete current profile
local function delete_profile(button, options)
	local sv = _G[profiles.sv_string]
	local value = sv.users[player].profile

	if (value == "default") then
		print("You cannot delete the \"default\" profile")
		return
	end

	sv.profiles[value] = nil

	change_profile(nil, nil, "default")
end

--============================================
-- Spec Profiles
--============================================
local function spec_changed(self, event, index, prev)
	print(event, index, prev)
end
local function build_spec_profiles()
	local specs = 3
	if (class == "DEMONHUNTER") then
		specs = 2
	elseif (class == "DRUID") then
		specs = 4
	end

	local spec_config = {}
	for i = 1, specs do
		local id, name, description, icon, background, role = GetSpecializationInfo(i)
		if (name) then
			name = name.." profile"
		else
			name = "Spec "..i
		end
		local c = {
			key = "spec_profile_"..i,
			type = "select",
			value = "default",
			size = "third",
			label = name,
			action = "profile_change,talent_available",
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
		key = "group",
		type = "group",
		heading = "Current Profile",
		args = {
			{
				key = "currentprofile",
				type = "select",
				value = "default",
				options = profile_table,
				action = "profile_change",
				lookup = get_profiles,
				callback = change_profile,
				label = "Current Profile"
			},
			{
				key = "deleteprofile",
				type = "button",
				label = "Delete Profile",
				callback = delete_profile
			}
		}
	},

	{
		key = "group",
		type = "group",
		heading = "Spec Profiles",
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


-- Main initialization
function mod:create_profiles(instance, saved_variables_string, disable_spec_profiles)
	profiles.sv_string = saved_variables_string

	-- populate spec table
	for k, v in pairs(_G[profiles.sv_string].profiles) do
		table.insert(profile_table, k)
		config[2].options = profile_table
	end

	-- remove spec profile options
	if (disable_spec_profiles) then
		table.remove(config[3])
	else
		config[3].args = build_spec_profiles()
	end

	-- Register inside of config window
	instance:register_module("Profiles", config, {
		persistent = true
	})

	-- update bdMove
	if (bdMove) then
		bdMove:set_save(mod:get_save("BDUI_SAVE"))
	end
end


-- let the UI know when talents are available
local talent = CreateFrame("frame")
talent:RegisterEvent("PLAYER_TALENT_UPDATE")
talent:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
talent:SetScript("OnEvent", function(self, event)
	if (event == "PLAYER_TALENT_UPDATE") then
		mod:do_action("talents_available")
	elseif (event == "ACTIVE_TALENT_GROUP_CHANGED") then
		mod:do_action("talents_changed")
	end
end)

function ns:unpack()
	return self[1], self[2], self[3]
end