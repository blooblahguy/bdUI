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

	local rows, columns = 1, 1

	for k, v in pairs(options.table) do
		local frame = options.pool:Acquire()
		local border = bdUI:get_border(frame)
		frame:Show()

		if (not first) then first = frame end
		if (not lastrow) then
			frame:SetPoint("TOPLEFT", options.parent, "TOPLEFT", 0, 0)
			lastrow = frame
		elseif (index > options.columns) then
			frame:SetPoint("TOPLEFT", lastrow, "BOTTOMLEFT", 0, -border)
			lastrow = frame
			lastcol = last
			index = 1
			rows = rows + 1
		else
			frame:SetPoint("TOPLEFT", last, "TOPRIGHT", border, 0)
			if (not lastcol) then
				columns = columns + 1
			end
		end
		last = frame
		index = index + 1

		if (options.loop) then 
			options.loop(frame, k, v) 
		end
	end

	if (options.callback and first) then
		local height = first:GetHeight() * rows
		local width = first:GetWidth() * columns
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