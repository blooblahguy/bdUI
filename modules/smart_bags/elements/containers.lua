local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Smart Bags (beta)")

function mod:create_container(name, nomove)
	local frame = CreateFrame("frame", "bdBags_"..name, UIParent, BackdropTemplateMixin and "BackdropTemplate")
	bdUI:set_backdrop(frame)

	frame:SetSize(500, 400)
	frame:EnableMouse(true)
	if (not nomove) then
		frame:SetMovable(true)
		frame:SetUserPlaced(true)
		frame:SetFrameStrata("HIGH")
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
	local header = CreateFrame("frame", nil, frame)
	header:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
	header:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -mod.spacing / 2, -mod.spacing * 1.75)
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

	-- sort
	local sort_bags
	if (SortBags) then
		sort_bags = mod:create_button(header)
		sort_bags.text:SetText("S")
		sort_bags:SetPoint("RIGHT", close_button, "LEFT", -4, 0)
		if(name == "Bags") then
			sort_bags.callback = function() if (SortBags) then SortBags() else noop() end end
		elseif (name == "Bank") then
			sort_bags.callback = function() if (SortBankBags) then SortBankBags() else noop() end end
		elseif (name == "Reagents") then
			sort_bags.callback = function() if (SortReagentBankBags) then SortReagentBankBags() else noop() end end
		end
		frame.sorter = sort_bags
	end

	-- bags
	local bags_button = mod:create_button(header)
	bags_button.text:SetText("B")
	bags_button:SetPoint("RIGHT", sort_bags or close_button, "LEFT", -4, 0)
	bags_button.callback = function()
		frame.bagslot_holder:SetShown(not frame.bagslot_holder:IsShown())
	end

	-- money
	local money = mod:create_money(name, frame)
	money:SetPoint("LEFT", header, "LEFT", mod.spacing, -1)

	-- search
	local searchBox = CreateFrame("EditBox", "bd"..name.."SearchBox", frame, "BagSearchBoxTemplate")
	searchBox:SetHeight(20)
	searchBox:SetPoint("LEFT", money, "RIGHT", 4, 1)
	searchBox:SetWidth(250)
	searchBox:SetFrameLevel(27)
	searchBox.Left:Hide()
	searchBox.Right:Hide()
	searchBox.Middle:Hide()
	local icon = _G[searchBox:GetName().."SearchIcon"]
	icon:ClearAllPoints()
	icon:SetPoint("LEFT", searchBox,"LEFT", 4, -1)
	bdUI:set_backdrop(searchBox)
	searchBox._background:SetVertexColor(.06, .07, .09, 1)
	tinsert(_G.ITEM_SEARCHBAR_LIST, searchBox:GetName())

	-- callback for sizing
	-- function frame:update_size(width, height)
	-- 	if (frame.currencies) then
	-- 		frame:SetSize(width, height + header:GetHeight() + footer:GetHeight())
	-- 	else
	-- 		frame:SetSize(width, height + header:GetHeight() + 10)
	-- 	end
	-- end

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
	
		self.blank:SetShown(not self.hasItem)
	
		self:update_quality()
	end

	mod:skin(button)

	return button
end

-- create bank container frames
function mod:create_bank_bagslots()
	local config = mod.config
	local size = config.bankbuttonsize
	local last_bag = nil
	local num_bags = 0

	if (not mod.bank.bagslot_holder) then
		local holder = CreateFrame("frame", nil, mod.bank)
		holder:SetPoint("BOTTOMRIGHT", mod.bank, "TOPRIGHT", 0, mod.border)
		bdUI:set_backdrop(holder)
		holder:SetSize(200, size + size * .5)
		mod.bank.bagslot_holder = holder
	end

	for i = 1, 7 do
		local bankbag = BankSlotsFrame["Bag"..i]
		if (not bankbag) then break end
		local icon = bankbag.icon
		
		bankbag:SetParent(mod.bank.bagslot_holder)
		bankbag:ClearAllPoints()
		bankbag:GetChildren():Hide()
		bankbag:SetWidth(size)
		bankbag:SetHeight(size)

		local bankbagchildren = {bankbag:GetChildren()}
		for k, v in pairs(bankbagchildren) do
			v:Hide()
			v:SetParent(bankbag)
			v.Show = noop
			bdUI:strip_textures(v)
		end
		mod:skin(bankbag)

		bankbag:SetNormalTexture("")
		bankbag:SetPushedTexture("")
		bankbag:SetHighlightTexture("")
		bankbag.IconBorder:SetTexture("")
		
		-- for i = 1, bankbag:GetNumRegions() do
		-- 	local region = select(i, bankbag:GetRegions())

		-- 	if (not region.protected) then
		-- 		if region:GetObjectType() == "Texture" then
		-- 			region:SetTexture(nil)
		-- 			region:Hide()
		-- 			region:SetAlpha(0)
		-- 			region:SetAllPoints()
		-- 			region.Show = noop
		-- 		end
		-- 	end
		-- end	
		
		icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

		if (not last_bag) then
			bankbag:SetPoint("RIGHT", mod.bank.bagslot_holder, "RIGHT", -size/4, 0)
		else
			bankbag:SetPoint("RIGHT", last_bag, "LEFT", -mod.border, 0)
		end

		last_bag = bankbag
		num_bags = num_bags + 1
	end

	-- local bagslots = {"-1.1", "-1.-29", "-1.-30", "-1.-31", "-1.-32", "-1.-33", "-1.-34"}
	-- local last_bag = nil
	-- local num_bags = 0

	-- for k, ids in pairs(bagslots) do
	-- 	local bagID, slot = strsplit(".", ids)
	-- 	local bag = create_bagslot_item(mod.bank.bagslot_holder, "BankItemButtonGenericTemplate")

	-- 	bag.bag = tonumber(bagID)
	-- 	bag.bagID = tonumber(bagID)
	-- 	bag.slot = tonumber(slot)
	-- 	bag:GetParent():SetID(tonumber(bagID))
	-- 	bag:SetID(tonumber(slot))
	-- 	bag:SetSize(size, size)
	-- 	bag:Show()
	-- 	bag:update()

	-- 	local itemLink = select(7, GetContainerItemInfo(tonumber(bagID), tonumber(slot)))

	-- 	local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(itemLink)

	-- 	local itemString = string.match(itemLink, "item[%-?%d:]+")
	-- 	local _, itemID = strsplit(":", itemString)
		
	-- 	bag.itemLink = itemLink
	-- 	bag.itemCount = 0
	-- 	bag.texture = itemTexture
	-- 	bag.itemID = itemID
	-- 	bag:update()
			
	-- 	if (not last_bag) then
	-- 		bag:SetPoint("RIGHT", mod.bank.bagslot_holder, "RIGHT", -size/4, 0)
	-- 	else
	-- 		bag:SetPoint("RIGHT", last_bag, "LEFT", -mod.border, 0)
	-- 	end

	-- 	last_bag = bag
	-- 	num_bags = num_bags + 1
	-- end
end

-- create bag container frames
function mod:create_bag_bagslots()
	local config = mod.config
	local size = config.buttonsize

	if (not mod.bags.bagslot_holder) then
		local holder = CreateFrame("frame", nil, mod.bags)
		holder:SetPoint("BOTTOMRIGHT", mod.bags, "TOPRIGHT", 0, mod.border)
		bdUI:set_backdrop(holder)
		holder:SetSize(200, size + size * .5)
		holder:Hide()
		mod.bags.bagslot_holder = holder
		mod.bags.bagslot_holder.items = {}
	end


	local bagslots = {"0.0", "0.-1", "0.-2", "0.-3"}

	local last_bag = nil
	local num_bags = 0

	for k, ids in pairs(bagslots) do
		local bagID, slot = strsplit(".", ids)
		local bag = mod.bags.bagslot_holder.items[k] or create_bagslot_item(mod.bags.bagslot_holder, "ContainerFrameItemButtonTemplate")
		mod.bags.bagslot_holder.items[k] = bag

		bag.bag = tonumber(bagID)
		bag.bagID = tonumber(bagID)
		bag.slot = tonumber(slot)
		bag:GetParent():SetID(tonumber(bagID))
		bag:SetID(tonumber(slot))
		bag:SetSize(size, size)
		bag:Show()

		local itemLink = select(7, GetContainerItemInfo(tonumber(bagID), tonumber(slot)))
		-- print(bagID, slot, itemLink)b

		local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(itemLink)

		if (itemLink) then

			local itemString = string.match(itemLink, "item[%-?%d:]+")
			local _, itemID = strsplit(":", itemString)
			
			bag.itemLink = itemLink
			bag.itemCount = 0
			bag.texture = itemTexture
			bag.itemID = itemID
			bag:update()
				
			if (not last_bag) then
				bag:SetPoint("RIGHT", mod.bags.bagslot_holder, "RIGHT", -size/4, 0)
			else
				bag:SetPoint("RIGHT", last_bag, "LEFT", -mod.border, 0)
			end

			last_bag = bag
			num_bags = num_bags + 1
		else
			C_Timer.After(2, function()
				mod:create_bag_bagslots()
			end)
		end
	end

	mod.bags.bagslot_holder:SetWidth(((num_bags * (size + mod.border))) + (size / 2))
end

-- update the frames depending on which frame is shown
function mod:update_bagslot_frames(name, parent)
	local config = mod.config

	local containers = {}
	containers[name] = parent

	parent.bag_holder_item_pool:ReleaseAll()

	for name, parent in pairs(containers) do
		local size = 30
		if (name == "Bags") then
			size = config.buttonsize
		else
			size = config.bankbuttonsize
		end

		local num_bags = 0
		local last_bag = false
		for ids, v in pairs(bagslots[name]) do
			local pid, id = strsplit(".", ids)
			mod.current_parent = parent.bagslot_holder
			local bag = parent.bag_holder_item_pool:Acquire()
			bag.bag = tonumber(pid)
			bag.bagID = tonumber(pid)
			bag.slot = tonumber(id)
			bag:SetID(tonumber(id))
			bag:GetParent():SetID(tonumber(pid))
			if (name == "Bags") then
				bag:SetSize(size, size)
			else
				bag:SetSize(size, size)
			end
			bag:Show()

			local itemLink
			if (pid == "player") then
				itemLink = GetInventoryItemLink("player", id)
			else
				itemLink = select(7, GetContainerItemInfo(tonumber(pid), tonumber(id)))
			end

			local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(itemLink)

			-- print(tonumber(pid), tonumber(id), itemLink)
			local itemString = string.match(itemLink, "item[%-?%d:]+")
			local _, itemID = strsplit(":", itemString)
			
			bag.bag = tonumber(pid)
			bag.bagID = tonumber(pid)
			bag.slot = tonumber(id)
			bag.itemLink = itemLink
			bag.itemCount = 0
			bag.texture = itemTexture
			bag.itemID = itemID
				
			if (not last_bag) then
				bag:SetPoint("RIGHT", parent.bagslot_holder, "RIGHT", -size/4, 0)
			else
				bag:SetPoint("RIGHT", last_bag, "LEFT", -mod.border, 0)
			end

			last_bag = bag
			num_bags = num_bags + 1
		end

		parent.bagslot_holder:SetWidth(((num_bags * (size + mod.border))) + (size / 2))
	end
end