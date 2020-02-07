--===============================================
-- FUNCTIONS
--===============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("New Bags")

--===============================================
-- Events
--===============================================
function mod:register_events(frame, events)
	for event, fn in pairs(events) do
		frame:RegisterEvent(event)
	end

	frame:SetScript("OnEvent", function(self, event, ...)
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

	for k, v in pairs(options.table) do
		local frame = options.pool:Acquire()
		frame:Show()

		if (not first) then first = frame end
		if (not lastrow) then
			frame:SetPoint("TOPLEFT", options.parent, "TOPLEFT", 0, 0)
			lastrow = frame
		elseif (index > options.columns) then
			frame:SetPoint("TOPLEFT", lastrow, "BOTTOMLEFT", 0, -mod.border)
			lastrow = frame
			lastcol = last
			index = 1
		else
			frame:SetPoint("TOPLEFT", last, "TOPRIGHT", mod.border, 0)
		end
		last = frame
		index = index + 1

		if (options.loop) then 
			options.loop(frame, k, v) 
		end
	end

	if (options.callback and first and last and lastcol) then
		local width = select(1, mod:measure("TOPLEFT", first, "BOTTOMRIGHT", lastcol))
		local height = select(2, mod:measure("TOPLEFT", first, "BOTTOMRIGHT", last))
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
	local itemString = string.match(itemLink, "item[%-?%d:]+")
	-- local itemType, itemID, enchant, gem1, gem2, gem3, gem4, suffixID, uniqueID, level, specializationID, upgradeId, instanceDifficultyID, numBonusIDs, bonusID1, bonusID2, upgradeValue = strsplit(":", itemString)
	return select(2, strsplit(":", itemString))
end

function mod:table_count(tab)
	local num = 0
	for k, v in pairs(tab) do
		num = num + 1
	end
	return num
end
function mod:has_value(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end