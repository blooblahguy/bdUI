local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Bags (beta)")

local events = {}
events["BAG_UPDATE_COOLDOWN"] = "update_cooldown"
events["ITEM_LOCK_CHANGED"] = "update_lock"
events["ITEM_UNLOCKED"] = "update_lock"
events["BAG_UPDATE_DELAYED"] = "update_lock"
-- events["QUEST_ACCEPTED"] = "update_border"
events["BAG_NEW_ITEMS_UPDATED"] = "update_new"
-- events["PLAYER_EQUIPMENT_CHANGED"] = "update"
events["INVENTORY_SEARCH_UPDATE"] = "update_search"
-- events["UNIT_QUEST_LOG_CHANGED"] = "update"

-- Actionbar Methods
local methods = {
	-- grey out if item is searched on
	["update_search"] = function(self)
		local _, _, _, _, _, _, _, isFiltered = GetContainerItemInfo(self.bag, self.slot)
		if isFiltered then
			self.searchOverlay:Show();
		else
			self.searchOverlay:Hide();
		end
	end,

	-- update border information
	["update_border"] = function(self)
		local count = _G[self:GetName().."Count"]
		-- local quest = _G[self:GetName().."IconQuestTexture"] or self.IconQuestTexture
		local isQuestItem, questId, isActive = GetContainerItemQuestInfo(self.bag, self.slot)

		if (not self.texture) then
			self.IconBorder:Hide()
			self.quality_border:Hide()
			return
		end

		self.IconBorder:SetTexture(bdUI.media.flat)
		self.IconBorder:ClearAllPoints()
		self.IconBorder:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
		self.IconBorder:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, mod.border*3)

		-- quest
		if (isQuestItem) then
			self.IconBorder:SetVertexColor(1, 1, 0.2, 1)
		end

		count:ClearAllPoints()
		local r, g, b = self.IconBorder:GetVertexColor()
		local color = bdUI:round(r, 1)..bdUI:round(g, 1)..bdUI:round(b, 1)
		if (color == "111" or color == "0.70.70.7" or color == "000") then
			self.IconBorder:Hide()
			self.quality_border:Hide()
			count:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -1, 1)
		else
			self.IconBorder:Show()
			self.quality_border:Show()
			count:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -1, mod.border*3)
		end
	end,

	-- lock item if its in transit
	["update_lock"] = function(self, bag, slot)
		-- self.locked = select(3, GetContainerItemInfo(self.bag, self.slot))
		if (not slot and self.locked) or (bag == self.bag and slot == self.slot) then
			self.locked = select(3, GetContainerItemInfo(self.bag, self.slot))
			self:Enable()
			SetItemButtonDesaturated(self, self.locked)
		end
	end,

	-- return cooldown information
	["update_cooldown"] = function(self)
		return ContainerFrame_UpdateCooldown(self.bag, self)
	end,

	["update_new"] = function(self)
		self.BattlepayItemTexture:SetShown(IsBattlePayItem(self.bag, self.slot))
	end,

	-- update basic button traits
	["update"] = function(self)
		local texture, count, locked, quality, readable, lootable, itemLink = GetContainerItemInfo(self.bag, self.slot);
		self.itemID = GetContainerItemID(self.bag, self.slot)
		self.itemLink = GetContainerItemLink(self.bag, self.slot)
		self.hasItem = not not self.itemID
		self.texture = texture
		self.itemCount = count
		self.quality = quality
		self.bagFamily = select(2, GetContainerNumFreeSlots(self.bag))

		-- if (self.bag == -1) then
		-- 	BankFrameBaseButton_OnLoad (self)
			
		-- end
	
		-- self.UpgradeIcon:SetShown(IsContainerItemAnUpgrade(self.bag, self.slot) or false)
		-- if self.itemCount > 1 then
		-- 	_G[self:GetName().."Count"]:SetText(self.itemCount)
		-- 	_G[self:GetName().."Count"]:Show()
		-- else
		-- 	_G[self:GetName().."Count"]:Hide()
		-- end

		SetItemButtonTexture(self, self.texture)
		SetItemButtonQuality(self, self.quality, self.itemLink)
		SetItemButtonCount(self, self.itemCount)

		self:skin()
		self:update_new()
		self:update_border()
		self:update_cooldown()
	end,

	-- return cooldown information
	["full_update"] = function(self)
		local bag, slot = self.bag, self.slot
		-- self.itemID = GetContainerItemID(bag, slot)
		-- self.itemLink = GetContainerItemLink(bag, slot)
		-- self.hasItem = not not self.itemID
		-- self.texture = GetContainerItemInfo(bag, slot)
		
		self:update()
	end,

	-- skin the button
	["skin"] = function(self)
		if (self.skinned) then return end
		bdUI:set_backdrop(self)

		local normal = _G[self:GetName().."NormalTexture"]
		local count = _G[self:GetName().."Count"]
		local icon = _G[self:GetName().."IconTexture"]
		local quest = _G[self:GetName().."IconQuestTexture"]

		-- border
		local quality_border = self:CreateTexture(self:GetName().."QualityBorder", "OVERLAY")
		quality_border:SetPoint("BOTTOMLEFT", self.IconBorder, "TOPLEFT", 0, 0)
		quality_border:SetPoint("TOPRIGHT", self.IconBorder, "TOPRIGHT", 0, 1)
		quality_border:SetTexture(bdUI.media.flat)
		quality_border:SetVertexColor(0, 0, 0, 1)
		quality_border:Hide()
		self.quality_border = quality_border

		-- icon
		self:SetNormalTexture("")
		self:SetPushedTexture("")
		icon:SetAllPoints(self)
		icon:SetTexCoord(.07, .93, .07, .93)
		self.flash:SetAllPoints()
		normal:SetAllPoints()
		quest:SetAllPoints()

		self.blank = self:CreateTexture(self:GetName().."Blank", "BACKGROUND")
		self.blank:SetAllPoints()
		self.blank:SetTexture([[Interface\BUTTONS\UI-EmptySlot]])
		self.blank:SetTexCoord(.3, .7, .3, .7)
		self.blank:Hide()

		-- hover
		local hover = self:CreateTexture()
		hover:SetTexture(bdUI.media.flat)
		hover:SetVertexColor(1, 1, 1, 0.1)
		hover:SetAllPoints(self)
		self:SetHighlightTexture(hover)

		-- count
		count:SetFont(bdUI.media.font, 13, "OUTLINE")
		count:SetJustifyH("RIGHT")
		count:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -1, 1)
		
		-- self.SplitStack = nil -- Remove the function set up by the template
		-- if self.NewItemTexture then
		-- 	self.NewItemTexture:Hide()
		-- end

		self.skinned = true
	end
}

local item_num = 0
mod.item_pool_create = function(self)
	item_num = item_num + 1
	local button = CreateFrame("ItemButton", "bdBags_Item_"..item_num, mod.current_parent, "ContainerFrameItemButtonTemplate")
	button:SetHeight(30)
	button:SetWidth(30)
	button:RegisterForDrag("LeftButton")
	button:RegisterForClicks("LeftButtonUp","RightButtonUp")

	-- really surprising that i have to do this, itembuttons dont come with tooltip functionality in the bank main bag
	button:HookScript("OnEnter", function(self, ...)
		if (self.bag == -1) then
			self.GetInventorySlot = ButtonInventorySlot;
			self.UpdateTooltip = BankFrameItemButton_OnEnter;
			BankFrameItemButton_OnEnter(self)
		else
			self.UpdateTooltip = ContainerFrameItemButton_OnUpdate;
		end
	end)

	bdUI:set_backdrop(button)
	Mixin(button, methods)
	mod:register_events(button, events)
	
	return button
end
mod.item_pool_reset = function(self, frame)
	frame:ClearAllPoints()
	frame:SetParent(mod.current_parent)
	frame:Hide()
end

--========================================
-- POSITION ITEMS
--========================================
function mod:position_items(category, parent, pool)
	-- loop through items now
	local last, lastrow, index = nil, nil, 1

	local spacing = mod.border
	local cat_spacing = 20
	local config = mod.config
	local num = #category.items
	if (num == 0) then num = 1 end

	local columns = math.min(num, config.bag_max_column)
	local rows = math.ceil(num / columns)

	local height = ((config.bag_size + spacing) * rows) - spacing
	local width = ((config.bag_size + spacing) * columns) - spacing
	width = math.max(width, category.frame.dragger:GetWidth() + category.frame.text:GetWidth())

	for i = 1, #category.items do
		local itemLink, bag, slot, itemID = unpack(category.items[i])
		local button = pool:Acquire()

		button:Show()
		button:SetParent(mod.bag_frames[bag])
		button:SetID(slot)
		button:SetSize(config.bag_size, config.bag_size)
		button.bag = bag
		button.slot = slot

		button:update()

		if (category.count ~= nil) then
			button.blank:Show()
			SetItemButtonCount(button, category.count)
		end

		if (not lastrow) then
			button:SetPoint("TOPLEFT", category.frame.container, "TOPLEFT", 0, 0)
			lastrow = button
		elseif (index > columns) then
			button:SetPoint("TOPLEFT", lastrow, "BOTTOMLEFT", 0, -spacing)
			lastrow = button
			index = 1
		else
			button:SetPoint("TOPLEFT", last, "TOPRIGHT", spacing, 0)
		end

		last = button
		index = index + 1
	end

	return width, height
end