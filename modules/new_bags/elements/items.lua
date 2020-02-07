local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("New Bags")

local events = {}
events["BAG_UPDATE_COOLDOWN"] = "update_cooldown"
events["ITEM_LOCK_CHANGED"] = "update_lock"
events["ITEM_UNLOCKED"] = "update_lock"
events["QUEST_ACCEPTED"] = "update_border"
events["BAG_NEW_ITEMS_UPDATED"] = "update"
events["PLAYER_EQUIPMENT_CHANGED"] = "update"
events["INVENTORY_SEARCH_UPDATE"] = "update_search"
events["UNIT_QUEST_LOG_CHANGED"] = "update"

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

		self.IconBorder:SetTexture(bdUI.media.flat)
		self.IconBorder:ClearAllPoints()
		self.IconBorder:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
		self.IconBorder:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, mod.border*3)

		count:ClearAllPoints()
		local r, g, b = self.IconBorder:GetVertexColor()
		-- print(r, g, b)
		local color = bdUI:round(r, 1)..bdUI:round(g, 1)..bdUI:round(b, 1)
		-- print(color)
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
		if (not slot) or (bag == self.bag and slot == self.slot) then
			local locked = select(3, GetContainerItemInfo(self.bag, self.slot))
			self:Enable()
			SetItemButtonDesaturated(self, locked)
		end
	end,

	-- return cooldown information
	["update_cooldown"] = function(self)
		return ContainerFrame_UpdateCooldown(self.bag, self)
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
	
		self.BattlepayItemTexture:SetShown(IsBattlePayItem(self.bag, self.slot))
		self.UpgradeIcon:SetShown(IsContainerItemAnUpgrade(self.bag, self.slot) or false)
		if self.itemCount > 1 then
			_G[self:GetName().."Count"]:SetText(self.itemCount)
			_G[self:GetName().."Count"]:Show()
		else
			_G[self:GetName().."Count"]:Hide()
		end

		SetItemButtonTexture(self, self.texture)
		SetItemButtonQuality(self, self.quality, self.itemLink)
		SetItemButtonCount(self, self.itemCount)

		self:skin()
		self:update_border()
	end,

	-- return cooldown information
	["full_update"] = function(self)
		local bag, slot = self.bag, self.slot
		self.itemID = GetContainerItemID(bag, slot)
		self.itemLink = GetContainerItemLink(bag, slot)
		self.hasItem = not not self.itemID
		self.texture = GetContainerItemInfo(bag, slot)
		self.bagFamily = select(2, GetContainerNumFreeSlots(bag))
		self:update()
	end,

	-- skin the button
	["skin"] = function(self)
		if (self.skinned) then return end
		bdUI:set_backdrop(self)

		local normal = _G[self:GetName().."NormalTexture"]
		local count = _G[self:GetName().."Count"]
		local icon = _G[self:GetName().."IconTexture"]

		-- icon
		self:SetNormalTexture("")
		self:SetPushedTexture("")
		icon:SetAllPoints(self)
		icon:SetTexCoord(.07, .93, .07, .93)

		-- hover
		local hover = self:CreateTexture()
		hover:SetTexture(bdUI.media.flat)
		hover:SetVertexColor(1, 1, 1, 0.3)
		hover:SetAllPoints(self)
		self:SetHighlightTexture(hover)

		-- count
		count:SetFont(bdUI.media.font, 13, "OUTLINE")
		count:SetJustifyH("RIGHT")
		count:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -1, 1)
		
		self.SplitStack = nil -- Remove the function set up by the template
		if self.NewItemTexture then
			self.NewItemTexture:Hide()
		end
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
	button:SetScript('OnShow', button.OnShow)
	button:SetScript('OnHide', button.OnHide)

	button.quality_border = button:CreateTexture(nil, "OVERLAY")
	button.quality_border:SetPoint("BOTTOMLEFT", button.IconBorder, "TOPLEFT", 0, 0)
	button.quality_border:SetPoint("TOPRIGHT", button.IconBorder, "TOPRIGHT", 0, 1)
	button.quality_border:SetTexture(bdUI.media.flat)
	button.quality_border:SetVertexColor(0, 0, 0, 1)

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
