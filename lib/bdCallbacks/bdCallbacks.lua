local MAJOR, MINOR = "bdCallback-1.0", 1
local lib, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end -- No upgrade needed

-- These are global tables for addons that use bdCallback
lib.actions = {}
lib.filters = {}

function lib:new(object)
	--====================================================
	-- FILTERS
	--====================================================
	object["do_filter"] = function(self, action, ...)
		local result = {...}
		if (lib.filters[action]) then
			for priority, events in pairs(lib.filters[action]) do
				for k, callback in pairs(events) do
					result = {callback(unpack(result))}
				end
			end

			return unpack(result)
		end
	end

	-- hook a callback on an action, optionally returning a value for filtering
	object["add_filter"] = function(self, action, callback, priority)
		priority = priority or 10
		local action = {strsplit(",", action)} or {action}

		for k, e in pairs(action) do
			e = strtrim(e)

			lib.filters[e] = lib.filters[e] or {}
			lib.filters[e][priority] = lib.filters[e][priority] or {}
			table.insert(lib.filters[e][priority], callback)
		end
	end

	-- unhook a given action callback
	object["remove_action"] = function(self, action, callback, priority)
		for k, fn in pairs(lib.actions[action][priority]) do
			if (fn == callback) then 
				lib.actions[action][priority][k] = nil
			end
		end
	end

	--====================================================
	-- ACTIONS
	--====================================================
	object["do_action"] = function(self, action, ...)
		if (lib.actions[action]) then
			for priority, events in pairs(lib.actions[action]) do
				for k, callback in pairs(events) do
					callback(...)
				end
			end
		end
	end

	-- hook a callback on an action, optionally returning a value for filtering
	object["add_action"] = function(self, action, callback, priority)
		priority = priority or 10
		local action = {strsplit(",", action)} or {action}

		for k, e in pairs(action) do
			e = strtrim(e)

			lib.actions[e] = lib.actions[e] or {}
			lib.actions[e][priority] = lib.actions[e][priority] or {}
			table.insert(lib.actions[e][priority], callback)
		end
	end

	-- unhook a given action callback
	object["remove_action"] = function(self, action, callback, priority)
		for k, fn in pairs(lib.actions[action][priority]) do
			if (fn == callback) then 
				lib.actions[action][priority][k] = nil
			end
		end
	end
end

