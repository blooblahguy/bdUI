local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Bags (beta)")
local config = {}

local inprogress = {}
local bag_slot_methods = {
	["skin"] = function(self)
		local normal = _G[self:GetName().."NormalTexture"]
		local icon = _G[self:GetName().."IconTexture"]

		-- icon
		self:SetNormalTexture("")
		self:SetPushedTexture("")
		icon:SetAllPoints(self)
		icon:SetTexCoord(.07, .93, .07, .93)
		normal:SetAllPoints()

		-- hover
		local hover = self:CreateTexture()
		hover:SetTexture(bdUI.media.flat)
		hover:SetVertexColor(1, 1, 1, 0.1)
		hover:SetAllPoints(self)
		self:SetHighlightTexture(hover)

		bdUI:set_backdrop(self)
	end,
	["update"] = function(self)
		local icon = GetInventoryItemTexture("player", self.invSlot)
		self.hasItem = not not icon
		if not icon then
			icon = [[Interface\PaperDoll\UI-PaperDoll-Slot-Bag]]
		end
		self:Enable()
		SetItemButtonTexture(self, icon)
		SetItemButtonDesaturated(self, IsInventoryItemLocked(self.invSlot))
	end,
	["onshow"] = function(self)
		self:RegisterEvent("BAG_UPDATE")
		self:RegisterEvent("ITEM_LOCK_CHANGED")
		self:update()
	end,
	["onhide"] = function(self)
		self:UnregisterAllEvents()
	end,

	["onleave"] = function(self)
		if GameTooltip:GetOwner() == self then
			GameTooltip:Hide()
		end
	end,
	["onenter"] = function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		if not GameTooltip:SetInventoryItem("player", self.invSlot) then
			if self.tooltipText then
				GameTooltip:SetText(self.tooltipText)
			end
		end
	end,
	["dragstart"] = function(self)
		if self.hasItem then
			PickupBagFromSlot(self.invSlot)
		end
	end,
	["onclick"] = function(self)
		if not PutItemInBag(self.invSlot) and self.hasItem then
			PickupBagFromSlot(self.invSlot)
			self:update()
		end
	end,
	["onevent"] = function(self, event, arg1, arg2)
		if (event == "BAG_UPDATE" and arg1 == self.bag) then
			self:update()
		elseif (event == "ITEM_LOCK_CHANGED" and not (arg2 and arg1 == self.invSlot) or inprogress[self.invSlot] ) then
			self:update()
		end
	end,
	["updatelock"] = function(self)
		if not PutItemInBag(self.invSlot) and self.hasItem then
			PickupBagFromSlot(self.invSlot)
		end
	end,
}