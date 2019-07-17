local addonName, ns = ...
local mod = ns.bdConfig

--=================================================
-- Initialize SavedVariables
--=================================================
function mod:initialize_saved_variables(saved_variable)
	local sv = _G[saved_variable]
	local player = UnitName("player")

	-- Default configuration
	if (not sv) then
		sv = {
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