local addonName, ns = ...
local mod = ns.bdConfig

--=================================================
-- Config Builder Helper
--=================================================
function mod:parse_config()
	
end

--=================================================
-- Initialize SavedVariables
--=================================================
function mod:initialize_saved_variables(saved_variable)
	local player = UnitName("player")

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

	if (not _G[saved_variable].users[player]) then
		_G[saved_variable].users[player] = {
			profile = "default"
		}
	end
	
	local sv = _G[saved_variable]
	local profile = sv.users[player].profile
	sv.profiles[profile] = sv.profiles[profile] or {}

	return sv.profiles[profile]
end

-- makes sure a value is set in the given save index
function mod:ensure_value(sv, option, value)
	if (sv[option] == nil) then
		value = value and value or {}
		sv[option] = value
	end
end