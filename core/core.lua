local bdUI, c, l = unpack(select(2, ...))

--==============================================
-- Aura Funcitonality
-- library for spell durations
--==============================================
if (bdUI:get_game_version() == "vanilla") then
	bdUI.spell_durations = LibStub("LibClassicDurations")
	bdUI.spell_durations:Register("bdUI")
end

function bdUI:update_duration(cd_frame, unit, spellID, caster, name, duration, expiration)
	if (bdUI.spell_durations) then

		local durationNew, expirationTimeNew = bdUI.spell_durations:GetAuraDurationByUnit(unit, spellID, caster, name)
		if duration == 0 and durationNew then
			duration = durationNew
			expirationTime = expirationTimeNew
		end

		local enabled = expirationTime and expirationTime ~= 0;
		if enabled then
			cd_frame:SetCooldown(expirationTime - duration, duration)
			cd_frame:Show()
		else
			cd_frame:Hide()
		end
	end

	return duration, expiration
end

--==============================================
-- Event, Filter, & Action System
bdUI.events = bdUI.events or {}
bdUI.eventer = CreateFrame("frame", nil, bdParent)
--================================================
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
			formatting = string.rep("  ", indent) .. k .. ": "
			if type(v) == "table" then
				print(formatting)
				dump(v, indent+1)
			elseif type(v) == 'boolean' then
				print(formatting .. tostring(v))      
			else
				print(formatting .. tostring(v))
			end
		end
	end