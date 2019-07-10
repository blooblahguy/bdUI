local bdUI, c, l = unpack(select(2, ...))
--==============================================
-- Event & Action System
bdUI.actions = bdUI.actions or {}
bdUI.events = bdUI.events or {}
bdUI.eventer = CreateFrame("frame", nil, bdParent)
--================================================
	function bdUI:do_action(action, ...)
		if (bdUI.actions[action]) then
			for k, v in pairs(bdUI.actions[action]) do
				v(...)
			end
		end
	end

	function bdUI:add_action(action, callback)
		local action = {strsplit(",", action)} or {action}

		for k, e in pairs(action) do
			e = strtrim(e)
			if (not bdUI.actions[e]) then
				bdUI.actions[e] = {}
			end
			table.insert(bdUI.actions[e], callback)
		end
	end

	-- register events in a single frame
	function bdUI:RegisterEvent(event, callback)
		local event = {strsplit(",", event)} or {event}

		for k, e in pairs(event) do
			e = strtrim(e)
			if (not bdUI.events[e]) then
				bdUI.events[e] = {}
			end
			table.insert(bdUI.events[e], callback)
			bdUI.eventer:RegisterEvent(e)
		end
	end
	function bdUI:UnregisterEvent(event, callback)
		if (bdUI.events[event]) then
			for k, v in pairs(bdUI.events[event]) do
				if v == callback then
					table.remove(bdUI.events[event], k)
					return
				end
			end
		end
	end

	bdUI.eventer:SetScript("OnEvent", function(self, ...)
		if (bdUI.events[event]) then
			for k, v in pairs(bdUI.events[event]) do
				v(...)
			end
		end
	end)
	

--==============================================
-- Developer Functions
--==============================================
	function bdUI:debug(...)
		print(bdUI.colorString.."UI: "..tostring(...))
	end

	-- no operation function
	noop = function() end

	-- Dump table to chat
	function dump (tbl, indent)
		if not indent then indent = 0 end
		for k, v in pairs(tbl) do
			formatting = string.rep("     ", indent) .. k .. ": "
			if type(v) == "table" then
				print(formatting)
				-- dump(v, indent+1)
			elseif type(v) == 'boolean' then
				print(formatting .. tostring(v))      
			elseif type(v) == 'userdata' then
				print(formatting .. "userdata")
			elseif type(v) ~= 'function' then
				-- print(type(v))
				print(formatting .. v)
			end
		end
	end