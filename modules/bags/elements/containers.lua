local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Bags")

local function sanitize(str)
	str = str:lower()
	str = strtrim(str)

	return str
end

function mod:create_container(name, nomove)
	local frame = CreateFrame("frame", "bdBags_"..name, UIParent, BackdropTemplateMixin and "BackdropTemplate")
	bdUI:set_backdrop(frame)

	frame:SetSize(500, 400)
	frame:EnableMouse(true)
	frame:SetFrameStrata("HIGH")
	if (not nomove) then
		frame:SetMovable(true)
		frame:SetUserPlaced(true)
		frame:RegisterForDrag("LeftButton","RightButton")
		frame:RegisterForDrag("LeftButton","RightButton")
		frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
		frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
	end
	if (name == "Bags") then
		frame:SetPoint("BOTTOMRIGHT", -20, 20)
	else
		frame:SetPoint("TOPLEFT", 20, -20)
	end
	frame:Hide()

	-- header
	local header = CreateFrame("frame", nil, frame, BackdropTemplateMixin and "BackdropTemplate")
	-- bdUI:set_backdrop(header)
	header:SetPoint("TOPLEFT", frame)
	header:SetPoint("TOPRIGHT", frame)
	header:SetHeight(mod.spacing * 2)
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

	-- bags
	local bags_button = mod:create_button(header)
	bags_button.text:SetText("B")
	bags_button:SetPoint("RIGHT", sort_bags or close_button, "LEFT", -4, 0)
	bags_button.callback = function()
		if (frame.bagslot_holder) then
			frame.bagslot_holder:SetShown(not frame.bagslot_holder:IsShown())
		end
	end

	-- money
	local money = mod:create_money(name, frame)
	money:SetPoint("LEFT", header, "LEFT", mod.spacing - 4, -1)
 
	-- search box
	local searchBox = CreateFrame("EditBox", "bd"..name.."SearchBox", frame, "BagSearchBoxTemplate")
	searchBox:SetHeight(20)
	searchBox:SetPoint("LEFT", money, "RIGHT", 4, 1)
	searchBox:SetWidth(250)
	searchBox:SetFrameLevel(27)
	searchBox.Left:Hide()
	searchBox.Right:Hide()
	searchBox.Middle:Hide()

	searchBox.hide = CreateFrame("button", nil, searchBox)
	searchBox.hide:SetSize(20, 20)
	searchBox.hide:EnableMouse(true)
	searchBox.hide:SetScript("OnClick", function() searchBox:SetText(""); searchBox:ClearFocus(false) end)
	searchBox.hide:SetPoint("RIGHT", searchBox, -2, 0)
	searchBox.hide:SetAlpha(0.5)
	searchBox.hide.text = searchBox.hide:CreateFontString(nil, "OVERLAY")
	searchBox.hide.text:SetFontObject(bdUI:get_font(12))
	searchBox.hide.text:SetText("x")
	searchBox.hide.text:SetTextColor(.7, .2, .2)
	searchBox.hide.text:SetAllPoints()
	searchBox.hide.text:SetJustifyH("CENTER")
	searchBox.hide.text:SetJustifyV("MIDDLE")

	searchBox:SetScript("OnEditFocusGained", function(self, ...)
		self.Instructions:Hide()
	end)
	searchBox:SetScript("OnEditFocusLost", function(self, ...)
		if (strlen(self:GetText()) == 0) then
			self.Instructions:Show()
		else
			self.Instructions:Hide()
		end
	end)

	searchBox:SetScript("OnTextChanged", function(self, ...)
		if (not frame.all_items) then return end
		local find = sanitize(self:GetText())
		if (strlen(self:GetText()) == 0) then
			self.Instructions:Show()
		else
			self.Instructions:Hide()
		end

		for k, item in pairs(frame.all_items) do
			if (item.name) then
				local text = sanitize(item.name..item.itemType)

				if (string.find(text, find)) then
					item:SetAlpha(1)
				else
					item:SetAlpha(.1)
				end
			end
		end
	end)

	local icon = _G[searchBox:GetName().."SearchIcon"]
	icon:ClearAllPoints()
	icon:SetPoint("LEFT", searchBox,"LEFT", 4, -1)
	bdUI:set_backdrop(searchBox)
	searchBox._background:SetVertexColor(.06, .07, .09, 1)
	tinsert(_G.ITEM_SEARCHBAR_LIST, searchBox:GetName())

	-- callback for sizing
	function frame:update_size(width, height)
		if (frame.currencies) then
			frame:SetSize(width, height + header:GetHeight() + footer:GetHeight())
		else
			frame:SetSize(width, height + header:GetHeight() + 10)
		end
	end

	return frame
end

local bagslots = {}
bagslots["Bags"] = {}
bagslots["Bags"]["0.0"] = true
bagslots["Bags"]["0.-1"] = true
bagslots["Bags"]["0.-2"] = true
bagslots["Bags"]["0.-3"] = true

bagslots["Bank"] = {}
bagslots["Bank"]["player.76"] = true
bagslots["Bank"]["player.77"] = true
bagslots["Bank"]["player.78"] = true
bagslots["Bank"]["player.79"] = true
bagslots["Bank"]["player.80"] = true
bagslots["Bank"]["player.82"] = true
bagslots["Bank"]["player.83"] = true

local item_num = 1
local function create_bagslot_item(parent, template)
	item_num = item_num + 1
	local parent = CreateFrame("frame", nil, parent)
	local button = CreateFrame(ItemButtonMixin and "ItemButton" or "Button", "bdBags_ContainerItem_"..item_num, parent, template)
	button:SetHeight(36)
	button:SetWidth(36)
	button:SetFrameStrata("HIGH")
	button:RegisterForDrag("LeftButton")
	button:RegisterForClicks("LeftButtonUp","RightButtonUp")
	button:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED")
	button:SetScript("OnEvent", function(self)
		self:update()
	end)

	button:HookScript("OnClick", function(self)
		if (not _G['BankSlotsFrame'] or not _G['BankSlotsFrame']["Bag"..self.slot]) then return end 
		
		local isBought = _G['BankSlotsFrame']["Bag"..self.slot].tooltipText ~= BANK_BAG_PURCHASE
		if (not self.itemID and self.bagID == -4 and not isBought) then
			StaticPopup_Show("CONFIRM_BUY_BANK_SLOT");
		end
	end)

	function button:update_quality()
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
	end
	function button:update()
		self.hasItem = not not self.itemID
		self:GetParent():SetID(self.bagID)
		self:SetID(self.slot)
	
		SetItemButtonTexture(self, self.texture)
		SetItemButtonQuality(self, self.quality, self.itemLink)
		SetItemButtonCount(self, self.itemCount)

		local numSlots, full = GetNumBankSlots()
		self.BattlepayItemTexture:Hide()
		if (not full and not self.itemID and self.bagID == -4) then
			if (_G['BankSlotsFrame']["Bag"..self.slot].tooltipText == BANK_BAG_PURCHASE) then
				SetItemButtonTexture(self, 135769)
				self.BattlepayItemTexture:Show()
				self.icon:SetVertexColor(0, 1, 0)
				self.icon:SetAlpha(.4)
			else
				self.icon:SetVertexColor(1, 1, 1)
				self.icon:SetAlpha(1)
			end
		end
	
		self.blank:SetShown(not self.hasItem)
	
		self:update_quality()
	end

	mod:skin(button)

	return button
end

-- bagslot frames
function mod:create_bagslots(frame, bagslots)
	local config = mod.config
	local size = config.buttonsize

	-- create holder frame
	if (not frame.bagslot_holder) then
		local holder = CreateFrame("frame", nil, frame)
		holder:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, mod.border)
		bdUI:set_backdrop(holder)
		holder:SetSize(200, size + size * .5)
		holder:Hide()

		frame.bagslot_holder = holder
		frame.bagslot_holder.items = {}
	end

	local last_bag = nil
	local num_bags = 0

	-- loop through bags by table of strings
	for k, ids in pairs(bagslots) do
		local bagID, slot = strsplit(".", ids)
		local bag = frame.bagslot_holder.items[k] or create_bagslot_item(frame.bagslot_holder, "ContainerFrameItemButtonTemplate")
		frame.bagslot_holder.items[k] = bag

		local itemTexture, itemCount, locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID, isBound = GetContainerItemInfo(bagID, slot)

		bag.bag = tonumber(bagID)
		bag.bagID = tonumber(bagID)
		bag.slot = tonumber(slot)
		bag.isBag = true
		bag:GetParent():SetID(tonumber(bagID))
		bag:GetParent():GetParent():SetID(tonumber(bagID))
		bag:SetID(tonumber(slot))
		bag:SetSize(size, size)
		bag:Show()

		bag.itemLink = itemLink
		bag.itemCount = 0
		bag.quality = quality
		bag.texture = itemTexture
		bag.itemID = itemID or false
		bag:update()
			
		-- position things
		if (not last_bag) then
			bag:SetPoint("RIGHT", frame.bagslot_holder, "RIGHT", -size/4, 0)
		else
			bag:SetPoint("RIGHT", last_bag, "LEFT", -mod.border, 0)
		end

		last_bag = bag
		num_bags = num_bags + 1
	end

	-- resize the holder frame
	frame.bagslot_holder:SetWidth(((num_bags * (size + mod.border))) + (size / 2))
end