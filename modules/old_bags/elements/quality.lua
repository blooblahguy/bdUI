local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Bags")

local quality = CreateFrame("frame", nil, UIParent)

-- add quality border to frame
local function create_border(frame)
	if (frame.quality_border) then return end

	local borderSize = bdUI:get_border(frame)

	local quality_border = CreateFrame("frame", frame:GetName().."QualityBorder", frame)
	quality_border:SetPoint("TOPLEFT", frame, "TOPLEFT", borderSize, -borderSize)
	quality_border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -borderSize, borderSize)
	bdUI:set_backdrop(quality_border)
	quality_border:set_border_color(1, 0, 0, 1)
	quality_border._background:Hide()

	frame.quality_border = quality_border
end

-- changes frame quality
local function update_quality(bag, slot, frameName)
	local item = _G[frameName]
	if (not item) then return end
	create_border(item)

	local ItemLink = GetContainerItemLink(bag, slot)
	local isQuestItem, questId, isActive = GetContainerItemQuestInfo(bag, slot)

	item.quality_border:Hide()
	item.quality_border:set_border_color(unpack(bdUI.media.border))
	
	if (ItemLink) then
		local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(ItemLink)
		if (itemRarity and itemRarity > 1) then
			local r, g, b, hex = GetItemQualityColor(itemRarity)
			item.quality_border:set_border_color(r, g, b, 1)
			item.quality_border:Show()
		end
	end
	if (isQuestItem) then
		item.quality_border:set_border_color(1, 1, 0.2, 1)
		item.quality_border:Show()
	end
end

-- update bag from event
function quality:BAG_UPDATE(bag)
	quality:updateBag(bag)
end

-- update single bag
function quality:updateBag(bag)
	local maxSlots = GetContainerNumSlots(bag)
	for slot = 1, maxSlots do
		local slotId = maxSlots + 1 - slot -- blizzard reverses the slot # in the frame name
		update_quality(bag, slot, "ContainerFrame"..(bag+1).."Item"..slotId)
	end
end

-- update all bags
function quality:updateBags()
	for bag = 0, NUM_BAG_SLOTS do
		quality:updateBag(bag)
	end
end

-- update banks from event
function quality:PLAYERBANKSLOTS_CHANGED()
	quality:updateBank(bag)
end

-- update all bank bags
function quality:updateBank()
	for slot = 1, GetContainerNumSlots(BANK_CONTAINER) do
		update_quality(BANK_CONTAINER, slot, "BankFrameItem"..slot);
	end
	for bag = 5, 11 do
		local maxSlots = GetContainerNumSlots(bag)
		for slot = 1, maxSlots do
			local slotId = maxSlots + 1 - slot -- blizzard reverses the slot # in the frame name
			update_quality(bag, slot, "ContainerFrame"..(bag+1).."Item"..slotId)
		end
	end
end

function mod:create_quality()
	hooksecurefunc(mod.bags, "Show", quality.updateBags)
	hooksecurefunc(mod.bank, "Show", quality.updateBank)
	quality:RegisterEvent("BAG_UPDATE")
	quality:RegisterEvent("PLAYERBANKSLOTS_CHANGED")

	quality:SetScript('OnEvent', function(self, event, ...) self[event](self, ...) end)
end