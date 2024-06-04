local bdUI, c, l = unpack(select(2, ...))

-- idk, maybe?
function CreateCaseInsensitiveTable()
	local metatbl = {}

	function metatbl.__index(table, key)
		if (type(key) == "string") then
			key = key:lower()
		end

		return rawget(table, key)
	end

	function metatbl.__newindex(table, key, value)
		if (type(key) == "string") then
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
	for k in pairs(t) do keys[#keys + 1] = k end

	-- if order function given, sort by it by passing the table and keys a, b,
	-- otherwise just sort the keys
	if order then
		table.sort(keys, function(a, b) return order(a, b) end)
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
	truncator:SetFontObject(fontObject, "THINOUTLINE")
	truncator:SetText(text)
	local width = truncator:GetStringWidth()

	-- print(text, width, targetWidth)

	-- if (width <= targetWidth) then return end

	local auto = { "Elysian", "of", "the", "and" }

	local words = { strsplit(" ", text) }
	for k, word in pairs(words) do
		print(word)
	end
end

local function on_cvar_event()
	if (bdUI.cvars_ignore) then return end -- don't trigger this while we update our own cvars

	bdUI:apply_cvars()
end

bdUI.cvars = {
	["cameraDistanceMaxZoomFactor"] = 4,
}
bdUI:RegisterEvent("CVAR_UPDATE", on_cvar_event)
bdUI:RegisterEvent("VARIABLES_LOADED", on_cvar_event)
bdUI:RegisterEvent("PLAYER_REGEN_ENABLED", on_cvar_event)

function bdUI:SetCVar(name, value)
	bdUI.cvars[name] = value

	bdUI:apply_cvars()
end

function bdUI:apply_cvars()
	if (InCombatLockdown()) then return end
	bdUI.cvars_ignore = true

	-- loop through and set our own
	for name, value in pairs(bdUI.cvars) do
		if (value == "default") then
			SetCVar(name, GetCVarDefault(name))
		else
			SetCVar(name, value)
		end
	end

	bdUI.cvars_ignore = false
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
	if frame.GetTexture then
		frame:SetTexture(nil)
		frame:Hide()
		frame:SetAlpha(0)
	end
	if frame.UnregisterAllEvents then
		frame:UnregisterAllEvents()
		frame:SetParent(bdUI.hidden)
	else
	end

	frame:Hide()
	hooksecurefunc(frame, "Show", function(self) self:Hide() end)
end

local lockedFrames = {}
local function LockParent(frame, parent)
	if lockedFrames[frame] and parent ~= bdUI.hidden then
		frame:SetParent(bdUI.hidden)
	end
end

function bdUI:HideFrame(frame, doNotReparent)
	if not frame then return end

	-- local lockParent = doNotReparent == 1
	-- print("hide frame")
	local originalParent = frame:GetParent()
	frame:SetParent(bdUI.hidden)

	if not doNotReparent and not lockedFrames[frame] then
		hooksecurefunc(frame, 'SetParent', LockParent)
		lockedFrames[frame] = originalParent
	end
end

function bdUI:UnHideFrame(frame)
	if not frame or not lockedFrames[frame] then return end

	local originalParent = lockedFrames[frame]
	frame:SetParent(originalParent)
	lockedFrames[frame] = nil
end

function bdUI:KillEditMode(object)
	object.HighlightSystem = noop
	object.ClearHighlight = noop
end

function bdUI:Kill(object)
	if object.UnregisterAllEvents then
		object:UnregisterAllEvents()
		object:SetParent(bdUI.hidden)
	else
		object.Show = object.Hide
	end

	object:Hide()
end

function bdUI:GetQuadrant(frame)
	local x, y = frame:GetCenter()
	x = x * UIParent:GetScale()
	y = y * UIParent:GetScale()
	local hhalf = (x > UIParent:GetWidth() / 2) and "RIGHT" or "LEFT"
	local vhalf = (y > UIParent:GetHeight() / 2) and "TOP" or "BOTTOM"
	return vhalf .. hhalf, vhalf, hhalf
end

--==============================================
-- Event, Filter, & Action System
bdUI.events = bdUI.events or {}
bdUI.eventer = CreateFrame("frame", nil, bdParent)
--================================================
-- register events in a single frame
function bdUI:RegisterEvent(event, callback)
	local event = { strsplit(",", event) } or { event }

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
	print(bdUI.colorString .. "UI: " .. tostring(table.concat({ ... }, " ")))
end

-- no operation function
noop = function() end
noof = CreateFrame("frame")
noof:Hide();

function dump_functions(tbl, indent)
	if not indent then indent = 4 end
	for k, v in pairs(tbl) do
		formatting = string.rep("  ", indent) .. k .. ": "
		if type(v) == "table" then
			print(formatting)
			dump(v, indent + 1)
		else
			if string.find(tostring(v), "function") ~= nil then
				print(formatting .. tostring(v))
			end
		end
	end
end

-- Dump table to chat
function dump(tbl, indent)
	if not indent then indent = 0 end
	for k, v in pairs(tbl) do
		formatting = string.rep("  ", indent) .. k .. ": "
		if type(v) == "table" then
			print(formatting)
			dump(v, indent + 1)
		elseif type(v) == 'boolean' then
			print(formatting .. tostring(v))
		else
			print(formatting .. tostring(v))
		end
	end
end

function bdUI:sanitize(str)
	str = str:lower()
	str = strtrim(str)
	str = gsub(str, "[^a-zA-Z0-9%s]+", "")

	return str
end

function bdUI:lowercase_table(t)
	local new = {}

	for k, v in pairs(t) do
		k = type(k) == "string" and bdUI:sanitize(k) or k
		v = type(v) == "string" and bdUI:sanitize(v) or v
		new[k] = v
	end

	return new
end

-- thanks to elvui for saving me a lot of time here
function bdUI:abbreviate_string(name)
	local letters, lastWord = '', strmatch(name, '.+%s(.+)$')
	if lastWord then
		for word in gmatch(name, '.-%s') do
			local firstLetter = string.utf8sub(gsub(word, '^[%s%p]*', ''), 1, 1)
			if firstLetter ~= string.utf8lower(firstLetter) then
				letters = format('%s%s. ', letters, firstLetter)
			end
		end
		name = format('%s%s', letters, lastWord)
	end
	return name
end

function bdUI:avg_ilvl()
	local total = 0
	for slot = 1, 18 do
		if (slot ~= 4) then
			local itemLink = GetInventoryItemLink("player", slot)
			local ilvl = select(4, GetItemInfo(itemLink))

			total = total + ilvl
		end
	end

	print(bdUI:round(total / 17, 1))
end
