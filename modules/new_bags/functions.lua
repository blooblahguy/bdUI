--===============================================
-- FUNCTIONS
--===============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Bags (beta)")

--===============================================
-- Events
--===============================================
function mod:register_events(frame, events)
	for event, fn in pairs(events) do
		frame:RegisterEvent(event)
	end
	frame:HookScript("OnEvent", function(self, event, ...)
		if (self[events[event]]) then
			self[events[event]](self, ...)
		end
	end)
end

--===============================================
-- Measurement
--===============================================
local measure = CreateFrame("frame", nil, UIParent)
function mod:measure(relativeA, A, relativeB, B)
	measure:ClearAllPoints()
	measure:SetPoint(relativeA, A)
	measure:SetPoint(relativeB, B)

	return measure:GetSize()
end

--===============================================
-- Positioning Helpers
--===============================================
function mod:position_objects(options)
	-- loop through items now
	local last, lastrow, first, lastcol
	local index = 1
	local rows, columns = 1, 1
	local spacing = mod.border

	if (options.table) then
		-- for k = 1, #options.table do
		-- 	v = options.table
		for k, v in pairs(options.table) do
			local frame = options.pool:Acquire()
			frame:Show()
			frame:SetParent(mod.current_parent)

			if (not first) then first = frame end
			if (not lastrow) then
				frame:SetPoint("TOPLEFT", options.parent, "TOPLEFT", 0, 0)
				lastrow = frame
			elseif (index > options.columns) then
				frame:SetPoint("TOPLEFT", lastrow, "BOTTOMLEFT", 0, -spacing)
				lastrow = frame
				lastcol = last
				index = 1
				rows = rows + 1
			else
				frame:SetPoint("TOPLEFT", last, "TOPRIGHT", spacing, 0)
				if (not lastcol) then
					columns = columns + 1
				end
			end
			last = frame
			index = index + 1

			-- print(frame, frame:GetPoint())

			if (options.loop) then 
				options.loop(frame, k, v) 
			end
		end
	else
		first = _G["bdBags_Item_1"]
	end

	if (options.callback and first) then
		local height = ((first:GetHeight()+spacing) * rows) - spacing
		local width = ((first:GetWidth()+spacing) * columns) - spacing
		options.callback(width, height)
	end
end
--===============================================
-- Custom functionality
-- place custom functionality here
--===============================================
function mod:create_button()

end

function mod:item_id(itemLink)
	if type(itemLink) == "string" and strmatch(itemLink, "battlepet:") then
		return 82800
	elseif type(itemLink) == "string" and strmatch(itemLink, "keystone:") then
		return 138019
	elseif itemLink then
		-- local itemString = string.match(itemLink, "item[%-?%d:]+")
		-- return tonumber(select(2, strsplit(":", itemString)))
		-- local link = select(2, GetItemInfo(str))
		return itemLink and tonumber(itemLink:match("item:(%d+)"))
	end
end

function mod:table_count(tab)
	local num = 0
	for k, v in pairs(tab) do
		num = num + 1
	end
	return num
end

function tMerge(...)
	local tbl = {}
	for i = 1, select("#", ...) do
		local added = select(i, ...)
		for k, v in pairs(added) do
			tinsert(tbl, v) 
		end
	end
	return tbl
end

function mod:remove_value(tab, val)
	if (not val) then return false end
	values = {}
	if (type(val) == "table") then
		for k, v in pairs(val) do
			values[v] = true
		end
	else
		values[val] = true
	end

	for i = 1, #tab do
		value = tab[i]
		if values[value] then
            tab[i] = nil
        end
	end
end

function mod:has_value(tab, val)
	if (not val) then return false end
	values = {}
	if (type(val) == "table") then
		for k, v in pairs(val) do
			values[v] = true
		end
	else
		values[val] = true
	end

	for i = 1, #tab do
		value = tab[i]
		if values[value] then
            return i
        end
	end

    return false
end