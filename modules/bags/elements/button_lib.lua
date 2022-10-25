local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Bags")

local events = {}
events["BAG_UPDATE_COOLDOWN"] = "UpdateCooldown"
events["ITEM_LOCK_CHANGED"] = "update_lock"
events["ITEM_UNLOCKED"] = "update_lock"
-- events["BAG_UPDATE_DELAYED"] = "update"
events["BAG_NEW_ITEMS_UPDATED"] = "update_new"
events["INVENTORY_SEARCH_UPDATE"] = "update_search"
events["BAG_UPDATE"] = "update_lock"
events["PLAYERBANKSLOTS_CHANGED"] = "update"
events["PLAYER_ENTERING_WORLD"] = "UpdateCooldown"

local function range_lerp(value, sourceMin, sourceMax, newMin, newMax)
	return newMin + (newMax - newMin) * ((value - sourceMin) / (sourceMax - sourceMin))
end

local function increase_brightness(r, percent)
    r = range_lerp(r, 0, 1, 0, 255)
    r = r + math.floor( percent / 100 * 255 )
	r = range_lerp(r, 0, 255, 0, 1)
    return r
end

local function brighten_color(r, g, b, percent)
	r = increase_brightness(r, percent)
	g = increase_brightness(g, percent)
	b = increase_brightness(b, percent)

	return r, g, b
end

local methods = {}
methods["update_quality"] = function(self)

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
	if (GetContainerItemQuestInfo and select(1, GetContainerItemQuestInfo(self.bag, self.slot))) then
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
	if (ContainerFrame_UpdateCooldown) then
		return ContainerFrame_UpdateCooldown(self.bag, self)
	else
		return _G["ContainerFrame1"]:UpdateCooldown(self.bag, self)
	end
end

methods["update_new"] = function(self)
	self.BattlepayItemTexture:SetShown(not self.isBag and C_NewItems.IsNewItem(self.bag, self.slot))
	-- self.new_item:SetShown(C_NewItems.IsNewItem(self.bag, self.slot))

	-- self:update()
end

methods["compare"] = function(self, key, down)
	if (not MouseIsOver(self)) then self:UnregisterEvent("MODIFIER_STATE_CHANGED") return end
	if (not self.itemID) then return end

	if IsModifiedClick("COMPAREITEMS") or (GetCVarBool("alwaysCompareItems") and not IsEquippedItem(self.itemID)) then
		GameTooltip_ShowCompareItem()
	end

	if (not IsModifiedClick("COMPAREITEMS") and not GetCVarBool("alwaysCompareItems")) then
		GameTooltip_HideShoppingTooltips(GameTooltip)
	end
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

	if (mod.config.show_ilvl and self.itemLevel > 0 and tonumber(self.itemCount) == 1) then
		local r, g, b, hex = GetItemQualityColor(self.rarity)
		r, g, b = brighten_color(r, g, b, 50)
		self.ilvl:SetText(self.itemLevel)
		self.ilvl:SetTextColor(r, g, b, 1)
	else
		self.ilvl:SetText("")
	end
end

function mod:skin(self)
	if (self.skinned) then return end
	self.skinned = true
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
	normal:Hide()
	normal.Show = noop
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
	-- button:SetFrameStrata("HIGH")
	button:EnableMouse(true)
	button:RegisterForDrag("LeftButton")
	button:RegisterForClicks("LeftButtonUp","RightButtonUp")
	-- button:Hide()

	button.text = button:CreateFontString(nil, "OVERLAY")
	button.text:SetFontObject(bdUI:get_font(13, "THINOUTLINE"))
	button.text:SetPoint("BOTTOMLEFT", button, "TOPLEFT", -2, 2)
	button.text:SetAlpha(1)
	button.text:SetTextColor(1, 1, 1)
	button.text:Hide()

	button.ilvl = button:CreateFontString(nil, "OVERLAY")
	button.ilvl:SetFontObject(bdUI:get_font(13, "OUTLINE"))
	button.ilvl:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
	button.ilvl:SetAlpha(1)
	button.ilvl:SetTextColor(1, 1, 1)

	-- get various methods on this
	Mixin(button, methods)

	button:HookScript("OnEnter", function(key, down)
		button:RegisterEvent("MODIFIER_STATE_CHANGED")
	end)
	button:HookScript("OnLeave", function(key, down)
		button:UnregisterEvent("MODIFIER_STATE_CHANGED")
	end)
	button:SetScript("OnEvent", function(self, event, arg1)
		if (event == "MODIFIER_STATE_CHANGED") then
			button:compare(button, key, down)
		end
	end)

	-- really surprising that i have to do this, itembuttons dont come with tooltip functionality in the bank main bag
	mod:SecureHookScript(button, "OnEnter", function(self, ...)
		self:update_new() -- mouseover update new
		if (self.bag == -1 or self.bag == -4) then
			self.GetInventorySlot = ButtonInventorySlot
			self.UpdateTooltip = BankFrameItemButton_OnEnter

			BankFrameItemButton_OnEnter(self)
		elseif (self.bag == -3) then
			self.GetInventorySlot = ReagentButtonInventorySlot
			self.UpdateTooltip = BankFrameItemButton_OnEnter
			BankFrameItemButton_OnEnter(self)
		else
			self.UpdateTooltip = ContainerFrameItemButton_OnUpdate;
		end
	end)

	securecall(function()
		mod:skin(button)
	end)

	-- easy delete item
	mod:SecureHookScript(button, "OnClick", function(self, button)
		if (mod.config.easy_delete) then
			if (IsAltKeyDown() and IsShiftKeyDown() and IsControlKeyDown() and button == "LeftButton") then
				PickupContainerItem(self.bagID, self.slot)
				DeleteCursorItem()
			end
		end
	end)
	
	mod:register_events(button, events)

	return button
end
mod.item_pool_reset = function(self, frame)
	frame:ClearAllPoints()
	frame:Hide()
	frame.text:Hide()
end