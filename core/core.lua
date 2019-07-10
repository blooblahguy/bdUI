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
		print(bdUI.colorString.."UI: "..tostring(table.concat({...}, " ")))
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

	-- slash commands
	function bdUI:set_slash_command(name, func, ...)
		SlashCmdList[name] = func
		for i = 1, select('#', ...) do
			_G['SLASH_'..name..i] = '/'..select(i, ...)
		end
	end

	-- reload
	bdUI:set_slash_command('ReloadUI', ReloadUI, 'rl', 'reset')
	-- readycheck
	bdUI:set_slash_command('DoReadyCheck', DoReadyCheck, 'rc', 'ready')
	-- lock/unlock
	bdUI:set_slash_command('ToggleLock', bdMove.toggle_lock, 'bdlock')
	bdUI:set_slash_command('ResetPositions', function()
		BDUI_SAVE = nil
		bdMove:reset_positions()
	end, 'bdreset')
	-- framename
	bdUI:set_slash_command('Frame', function()
		print(GetMouseFocus():GetName())
	end, 'frame')
	-- texture
	bdUI:set_slash_command('Texture', function()
		local type, id, book = GetCursorInfo();
		print((type=="item") and GetItemIcon(id) or (type=="spell") and GetSpellTexture(id,book) or (type=="macro") and select(2,GetMacroInfo(id)))
	end, 'texture')
	-- itemid
	bdUI:set_slash_command('ItemID', function()
		local infoType, info1, info2 = GetCursorInfo(); 
		if infoType == "item" then 
			print( info1 );
		end
	end, 'item')
	-- tt functionality, thanks phanx for simple script
	bdUI:set_slash_command('TellTarget', function()
		if UnitIsPlayer("target") and (UnitIsUnit("player", "target") or UnitCanCooperate("player", "target")) then
			SendChatMessage(message, "WHISPER", nil, GetUnitName("target", true))
		end
	end, 'tt', 'wt')