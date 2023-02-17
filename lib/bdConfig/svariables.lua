local parent, ns = ...
local lib = ns.bdConfig

local player = UnitName("player")

--=================================================
-- Fetch Relevant Config
--=================================================
function lib:get_save(saved_variable, name, persistent)
	local sv = _G[saved_variable]

	-- sometimes this fires early?
	if (not sv) then
		lib:initialize_saved_variables(saved_variable)
	end

	sv = _G[saved_variable]

	if (persistent) then
		sv.persistent[name] = sv.persistent[name] or {}
		return sv.persistent[name]
	else
		local profile = sv.users[player].profile

		sv.profiles[profile] = sv.profiles[profile] or {}

		if (name) then
			sv.profiles[profile][name] = sv.profiles[profile][name] or {}
			return sv.profiles[profile][name]
		else
			return sv.profiles[profile]
		end
	end
end

--=================================================
-- Initialize SavedVariables
--=================================================
function lib:initialize_saved_variables(saved_variable)
	_G[saved_variable] = _G[saved_variable] or {}

	_G[saved_variable].users = _G[saved_variable].users or {}
	_G[saved_variable].users[player] = _G[saved_variable].users[player] or {}
	_G[saved_variable].users[player].profile = _G[saved_variable].users[player].profile or "default"

	_G[saved_variable].profiles = _G[saved_variable].profiles or {}
	_G[saved_variable].profiles.default = _G[saved_variable].profiles.default or {}

	-- Default configuration
	-- if (not _G[saved_variable]) then
	-- 	_G[saved_variable] = {
	-- 		users = {
	-- 			[player] = {
	-- 				profile = "default"
	-- 			}
	-- 		},
	-- 		profiles = {
	-- 			default = {}
	-- 		}
	-- 	}
	-- end

	-- -- Each player login
	-- if (not _G[saved_variable].users[player]) then
	-- 	_G[saved_variable].users[player] = {
	-- 		profile = "default"
	-- 	}
	-- end

	-- Persistent: Exists between profiles and characters
	_G[saved_variable].persistent = _G[saved_variable].persistent or {}
end

-- makes sure a value is set in the given save index
function lib:ensure_value(sv, option, value, persistent)
	if (not option) then return end
	if (sv[option] == nil) then
		if (value == nil) then
			value = {}
		end

		sv[option] = value
	end
end