local addonName, ns = ...
local mod = ns.bdConfig
local player = UnitName("player")

--=================================================
-- Fetch Relevant Config
--=================================================
function mod:get_save(saved_variable, name, persistent)
	local sv = _G[saved_variable]
	local profile = sv.users[player].profile
	sv.profiles[profile] = sv.profiles[profile] or {}

	if (name) then
		sv.profiles[profile][name] = sv.profiles[profile][name] or {}
		return sv.profiles[profile][name]
	else
		return sv.profiles[profile]
	end
end

--=================================================
-- Initialize SavedVariables
--=================================================
function mod:initialize_saved_variables(saved_variable)
	-- Default configuration
	if (not _G[saved_variable]) then
		_G[saved_variable] = {
			users = {
				[player] = {
					profile = "default"
				}
			},
			profiles = {
				default = {}
			}
		}
	end

	-- Each player login
	if (not _G[saved_variable].users[player]) then
		_G[saved_variable].users[player] = {
			profile = "default"
		}
	end

	-- Persistent: Exists between profiles and characters
	_G[saved_variable].persistent = _G[saved_variable].persistent or {}
end

-- makes sure a value is set in the given save index
function mod:ensure_value(sv, option, value, persistent)
	if (sv[option] == nil) then
		if (value == nil) then
			value = {}
		end

		sv[option] = value
	end
end