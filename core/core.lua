local bdUI, c, l = unpack(select(2, ...))

-- idk, maybe?
function CreateCaseInsensitiveTable()
	local metatbl = {}

	function metatbl.__index(table, key)
		if(type(key) == "string") then
		key = key:lower()
		end

		return rawget(table, key)
	end

	function metatbl.__newindex(table, key, value)
		if(type(key) == "string") then
		key = key:lower()
		end

		rawset(table, key, value)
	end

	local ret = {}
	setmetatable(ret, metatbl)
	return ret
end

-- sort pairs
function bdUI:spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

-- swaps keys and values in table
function bdUI:swaptable(table)
	local newtable = {}
	for k, v in pairs(table) do
		newtable[v] = k
	end

	return swaptable
end

--==============================================
-- Useful Functions
--==============================================
local trunc_parent = CreateFrame("frame", nil)
local truncator = trunc_parent:CreateFontString(nil, "OVERLAY")
function bdUI:truncate_text(text, fontObject, targetWidth)
	-- BDUI_SAVE.truncates = BDUI_SAVE.truncates or {}
	truncator:SetFontObject(fontObject)
	truncator:SetText(text)
	local width = truncator:GetStringWidth()

	-- print(text, width, targetWidth)

	-- if (width <= targetWidth) then return end

	local auto = {"Elysian", "of", "the", "and"}

	local words = {strsplit(" ", text)}
	for k, word in pairs(words) do
		print(word)
	end
end

function bdUI:hide_protected(frame)
	frame:Hide()
	frame:EnableMouse(false)
	hooksecurefunc(frame, "Show", function(self) self:Hide() end)
end

function bdUI:set_outside(frame)
	if (not frame) then return end
	local border = bdUI:get_border(frame)
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", -border, border)
	frame:SetPoint("BOTTOMRIGHT", border, -border)
end

function bdUI:set_inside(frame)
	if (not frame) then return end
	local border = bdUI:get_border(frame)
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", border, -border)
	frame:SetPoint("BOTTOMRIGHT", -border, border)
end

function bdUI:kill(frame)
	if (not frame) then return end
	if frame.UnregisterAllEvents then
		frame:UnregisterAllEvents()
		frame:SetParent(bdUI.hidden)
	else
		hooksecurefunc(frame, "Show", function(self) self:Hide() end)
		-- frame.Show = frame.Hide
	end

	frame:Hide()
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

function dump_functions(tbl, indent)
	if not indent then indent = 4 end
	for k, v in pairs(tbl) do
		formatting = string.rep("  ", indent) .. k .. ": "
		if type(v) == "table" then
			print(formatting)
			dump(v, indent+1)
		else
			if string.find(tostring(v), "function") ~= nil then
				print(formatting .. tostring(v))
			end
		end
	end
end

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