local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Smart Bags (beta)")

local events = {}
events["BAG_UPDATE_COOLDOWN"] = "update_cooldown"
events["ITEM_LOCK_CHANGED"] = "update_lock"
events["ITEM_UNLOCKED"] = "update_lock"
events["BAG_UPDATE_DELAYED"] = "update"
events["BAG_NEW_ITEMS_UPDATED"] = "update_new"
events["INVENTORY_SEARCH_UPDATE"] = "update_search"
events["BAG_UPDATE"] = "update_lock"
events["PLAYERBANKSLOTS_CHANGED"] = "update"
events["PLAYER_ENTERING_WORLD"] = "update_cooldown"

local methods = {}
methods["update_quality"] = function(self)
	local isQuestItem, questId, isActive = GetContainerItemQuestInfo(self.bag, self.slot)

	self.quality_border:Hide()
	self.quality_border:set_border_color(unpack(bdUI.media.border))
	
	if (self.itemLink) then
		local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(self.itemLink)
		if (itemRarity and itemRarity > 1) then
			local r, g, b, hex = GetItemQualityColor(itemRarity)
			self.quality_border:set_border_color(r, g, b, 1)
			self.quality_border:Show()
		end
	end
	if (isQuestItem) then
		self.quality_border:set_border_color(1, 1, 0.2, 1)
		self.quality_border:Show()
	end
end

methods["update_lock"] = function(self, bag, slot)
	if (not slot and self.locked) or (bag == self.bag and slot == self.slot) then
		self.locked = select(3, GetContainerItemInfo(self.bag, self.slot))
		self:Enable()
		SetItemButtonDesaturated(self, self.locked)
	end
end

methods["update_cooldown"] = function(self)
	return ContainerFrame_UpdateCooldown(self.bag, self)
end

methods["update_new"] = function(self)
	self.BattlepayItemTexture:SetShown(C_NewItems.IsNewItem(self.bag, self.slot))
	-- self.new_item:SetShown(C_NewItems.IsNewItem(self.bag, self.slot))

	-- self:update()
end

methods["update"] = function(self)
	self.hasItem = not not self.itemID
	self:GetParent():SetID(self.bagID)
	self:SetID(self.slot)

	SetItemButtonTexture(self, self.texture)
	SetItemButtonQuality(self, self.quality, self.itemLink)
	SetItemButtonCount(self, self.itemCount)

	self.blank:SetShown(not self.hasItem)

	self:update_new()
	self:update_quality()
end

function mod:skin(self)
	bdUI:set_backdrop(self)

	local normal = _G[self:GetName().."NormalTexture"]
	local count = _G[self:GetName().."Count"]
	local icon = _G[self:GetName().."IconTexture"]
	local quest = _G[self:GetName().."IconQuestTexture"]

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
	self.blank:SetAlpha(0.8)
	self.blank:Hide()

	-- hover
	local hover = self:CreateTexture()
	hover:SetTexture(bdUI.media.flat)
	hover:SetVertexColor(1, 1, 1, 0.1)
	hover:SetAllPoints(self)
	self:SetHighlightTexture(hover)

	-- count
	count:SetFontObject(bdUI:get_font(13))
	count:SetJustifyH("RIGHT")
	count:ClearAllPoints()
	count:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -1, 1)

	-- battleplay
	self.BattlepayItemTexture:SetAllPoints()
	self.BattlepayItemTexture:SetTexCoord(.25, .75, .25, .75)
	
	-- New Item
	self.NewItemTexture:SetAllPoints()
	self.NewItemTexture:Hide()
	-- 902180
	-- local new_item = CreateFrame("frame", self:GetName().."NewBorder", self)
	-- new_item:SetPoint("TOPLEFT", self, "TOPLEFT")
	-- new_item:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")
	-- new_item:SetAlpha(0.4)
	-- new_item:Hide()
	-- bdUI:set_backdrop(new_item)
	-- new_item._background:SetVertexColor(0.4, 0.5, 1, 1)
	-- new_item:set_border_size(0)
	-- self.new_item = new_item

	-- quality
	local quality = CreateFrame("frame", self:GetName().."QualityBorder", self)
	quality:SetPoint("TOPLEFT", self, "TOPLEFT", mod.border, -mod.border)
	quality:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -mod.border, mod.border)
	bdUI:set_backdrop(quality)
	quality:set_border_color(1, 0, 0, 1)
	quality._background:Hide()
	self.quality_border = quality
end

local item_num = 0
mod.item_pool_create = function(self)
	item_num = item_num + 1
	local parent = CreateFrame("frame", nil, mod.current_parent)
	local button = CreateFrame(ItemButtonMixin and "ItemButton" or "Button", "bdBags_Item_"..item_num, parent, "ContainerFrameItemButtonTemplate")
	button:SetHeight(36)
	button:SetWidth(36)
	button:SetFrameStrata("HIGH")
	button:RegisterForDrag("LeftButton")
	button:RegisterForClicks("LeftButtonUp","RightButtonUp")

	-- really surprising that i have to do this, itembuttons dont come with tooltip functionality in the bank main bag
	button:HookScript("OnEnter", function(self, ...)
		if (self.bag == -1) then
			self.GetInventorySlot = ButtonInventorySlot;
			self.UpdateTooltip = BankFrameItemButton_OnEnter;
			BankFrameItemButton_OnEnter(self)
		elseif (self.bag == -3) then
			self.GetInventorySlot = ReagentButtonInventorySlot
			self.UpdateTooltip = BankFrameItemButton_OnEnter;
			BankFrameItemButton_OnEnter(self)
		else
			self.UpdateTooltip = ContainerFrameItemButton_OnUpdate;
		end
	end)

	mod:skin(button)
	Mixin(button, methods)
	mod:register_events(button, events)

	return button
end
mod.item_pool_reset = function(self, frame)
	frame:ClearAllPoints()
	frame:Hide()
end