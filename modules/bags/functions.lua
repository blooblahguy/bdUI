local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Bags")

--===============================================
-- Item / Filter Helpers
--===============================================
function mod:get_item_table(bag, slot, bagID, itemCount, itemLink)
	local name, link, rarity, ilvl, minlevel, itemType, itemSubType, count, itemEquipLoc, icon, price, itemTypeID, itemSubTypeID, bindType, expacID, itemSetID, isCraftingReagent

	if (itemLink) then
		name, link, rarity, ilvl, minlevel, itemType, itemSubType, count, itemEquipLoc, icon, price, itemTypeID, itemSubTypeID, bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo(itemLink)
	end

	local itemID
	if (itemLink) then
		local itemString = string.match(itemLink, "item[%-?%d:]+")
		local keyString = string.match(itemLink, "item[%-?%d:]+")

		if (itemString ~= nil) then -- is item
			itemID = select(2, strsplit(":", itemString))
		elseif (keyString) then -- is keystone
			itemID = select(2, strsplit(":", keyString))
			icon = 525134
			itemCount = 1
			itemTypeID = 13
			itemSubTypeID = 0
			itemEquipLoc = ""
			rarity = 4
		else
			print("weird item found:", itemLink, " please report to developer")
		end
	end
	
	-- print(itemLink, icon, count)
	local t = {}
	t.name = name
	t.bag = bag
	t.bagID = bagID
	t.slot = slot

	t.itemLink = itemLink
	t.itemID = itemID
	t.texture = icon
	t.itemCount = itemCount
	t.itemTypeID = itemTypeID
	t.itemSubTypeID = itemSubTypeID
	t.itemEquipLoc = itemEquipLoc
	t.rarity = rarity or 0

	return t
end

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

	function button:ToggleActive()
		if (self.active) then
			self:SetInactive()
		else
			self:SetActive()
		end
	end

	function button:SetActive()
		if (not self._background) then return end
		self._background:SetVertexColor(unpack(bdUI.media.blue))
		self.text:SetTextColor(1, 1, 1)
		self.active = true
	end
	function button:SetInactive()
		if (not self._background) then return end
		self._background:SetVertexColor(unpack(bdUI.media.backdrop))
		self.text:SetTextColor(.4, .4, .4)
		self.active = false
	end

	button:SetScript("OnEnter", function(self)
		self.text:SetTextColor(1, 1, 1)
	end)
	button:SetScript("OnLeave", function(self)
		if (not self.active) then
			self.text:SetTextColor(.4, .4, .4)
		end
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

function mod:frame_size(btn_size, rows, columns)
	local width = ((btn_size + mod.border) * columns) - mod.border
	local height = ((btn_size + mod.border) * rows) - mod.border

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


function __genOrderedIndex( t )
    local orderedIndex = {}
    for key in pairs(t) do
        table.insert( orderedIndex, key )
    end
    table.sort( orderedIndex )
    return orderedIndex
end

function orderedNext(t, state)
    -- Equivalent of the next function, but returns the keys in the alphabetic
    -- order. We use a temporary ordered key table that is stored in the
    -- table being iterated.

    local key = nil
    --print("orderedNext: state = "..tostring(state) )
    if state == nil then
        -- the first time, generate the index
        t.__orderedIndex = __genOrderedIndex( t )
        key = t.__orderedIndex[1]
    else
        -- fetch the next value
        for i = 1,table.getn(t.__orderedIndex) do
            if t.__orderedIndex[i] == state then
                key = t.__orderedIndex[i+1]
            end
        end
    end

    if key then
        return key, t[key]
    end

    -- no more value to return, cleanup
    t.__orderedIndex = nil
    return
end

function orderedPairs(t)
    -- Equivalent of the pairs() function on tables. Allows to iterate
    -- in order
    return orderedNext, t, nil
end