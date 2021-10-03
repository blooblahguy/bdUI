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

function mod:create_container(name)
	local frame = CreateFrame("frame", "bdBags_"..name, UIParent, BackdropTemplateMixin and "BackdropTemplate")
	bdUI:set_backdrop(frame)

	frame:SetSize(500, 400)
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:SetUserPlaced(true)
	frame:SetFrameStrata("HIGH")
	frame:RegisterForDrag("LeftButton","RightButton")
	frame:RegisterForDrag("LeftButton","RightButton")
	frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
	frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
	if (name == "Bags") then
		frame:SetPoint("BOTTOMRIGHT", -20, 20)
	else
		frame:SetPoint("TOPLEFT", 20, -20)
	end
	frame:Hide()

	-- header
	local header = CreateFrame("frame", nil, frame)
	header:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
	header:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -mod.spacing / 2, -mod.spacing * 1.75)
	frame.header = header

	-- footer
	local footer = CreateFrame("frame", nil, frame)
	footer:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, 0)
	footer:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 0, 0)
	frame.footer = footer

	-- close
	local close_button = mod:create_button(header)
	close_button.text:SetText("X")
	close_button:SetPoint("RIGHT", header, "RIGHT", -4, 0)
	close_button.callback = function(self)
		frame:Hide()
	end

	-- sort
	local sort_bags = mod:create_button(header)
	sort_bags.text:SetText("S")
	sort_bags:SetPoint("RIGHT", close_button, "LEFT", -4, 0)
	if(name == "Bags") then
		sort_bags.callback = function() if (SortBags) then SortBags() else noop() end end
	elseif (name == "Bank") then
		sort_bags.callback = function() if (SortBankBags) then SortBankBags() else noop() end end
	end
	frame.sorter = sort_bags

	-- bags
	local bags_button = mod:create_button(header)
	bags_button.text:SetText("B")
	bags_button:SetPoint("RIGHT", sort_bags, "LEFT", -4, 0)
	bags_button.callback = function()
		self.bag_slots:SetShown(not self.bag_slots:IsShown())
	end

	-- money
	local money = mod:create_money(name, frame)
	money:SetPoint("LEFT", header, "LEFT", mod.spacing, -1)

	-- search
	local searchBox = CreateFrame("EditBox", "bd"..name.."SearchBox", frame, "BagSearchBoxTemplate")
	searchBox:SetHeight(20)
	searchBox:SetPoint("LEFT", money, "RIGHT", 4, 1)
	searchBox:SetWidth(250)
	searchBox:SetFrameLevel(27)
	searchBox.Left:Hide()
	searchBox.Right:Hide()
	searchBox.Middle:Hide()
	local icon = _G[searchBox:GetName().."SearchIcon"]
	icon:ClearAllPoints()
	icon:SetPoint("LEFT", searchBox,"LEFT", 4, -1)
	bdUI:set_backdrop(searchBox)
	searchBox._background:SetVertexColor(.06, .07, .09, 1)
	tinsert(_G.ITEM_SEARCHBAR_LIST, searchBox:GetName())

	-- callback for sizing
	-- function frame:update_size(width, height)
	-- 	if (frame.currencies) then
	-- 		frame:SetSize(width, height + header:GetHeight() + footer:GetHeight())
	-- 	else
	-- 		frame:SetSize(width, height + header:GetHeight() + 10)
	-- 	end
	-- end

	return frame
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