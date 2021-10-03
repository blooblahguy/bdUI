local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Smart Bags (beta)")

--===============================================
-- Bag Frames
--===============================================
function mod:create_button(parent)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(20, 20)
	button.text = button:CreateFontString(nil, "OVERLAY")
	button.text:SetFontObject(bdUI:get_font(11))
	button.text:SetAllPoints()
	button.text:SetJustifyH("CENTER")
	button.text:SetTextColor(.4, .4, .4)

	button:SetScript("OnEnter", function(self)
		self.text:SetTextColor(1, 1, 1)
	end)
	button:SetScript("OnLeave", function(self)
		self.text:SetTextColor(.4, .4, .4)
	end)

	button:SetScript("OnClick", function(self)
		button:callback()
	end)

	return button
end

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

function mod:frame_size(size, rows, columns)
	local width = ((size + mod.border) * columns) - mod.border
	local height = ((size + mod.border) * rows) - mod.border

	return width, height
end

--===============================================
-- Table Functions
--===============================================
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