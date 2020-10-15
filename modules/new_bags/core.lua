--===============================================
-- FUNCTIONS
--===============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Bags (beta)")
local config = {}

-- default variables
mod.containers = {}
mod.bag_frames = {}
mod.myilvl = select(1, GetAverageItemLevel())
local ace_hook = LibStub("AceHook-3.0")
ace_hook:Embed(mod)

--===============================================
-- Core functionality
-- place core functionality here
--===============================================
SetSortBagsRightToLeft(false)
	SetInsertItemsLeftToRight(false)
function mod:initialize()
	mod.config = mod:get_save()
	config = mod.config
	if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then return end
	if (not config.enabled) then return end

	-- store saved variable for messing with
	config.categories = config.categories or {}
	mod.categories = config.categories

	-- forced categories
	mod:create_category("Free", {
		["default"] = true,
		["locked"] = true,
		["order"] = -2,
	})

	mod:create_category("Bags", {
		["default"] = true,
		["duplicate"] = true,
		["locked"] = true,
		["order"] = -1,
	})

	-- default categories
	if (not config.first_run_complete) then
		mod:create_category("Armor", {
			["type"] = mod.types["Armor"],
			["default"] = true,
			["order"] = 1,
		})
		mod:create_category("Weapons", {
			["type"] = mod.types["Weapon"],
			["default"] = true,
			["order"] = 2,
		})
		mod:create_category("Quest & Keys", {
			["type"] = tMerge(mod.types["Quest"], mod.types["Keys"]),
			["default"] = true,
			["itemids"] = {138019}
		})
		mod:create_category("Hearths", {
			["itemids"] = {6948, 140192, 141605, 110560},
			["default"] = true,
		})
		mod:create_category("Enchants", {
			["type"] = tMerge(mod.types["Enchantment"]),
			["default"] = true,
		})
		mod:create_category("Tools", {
			["type"] = tMerge(mod.types["Consumable"], mod.types["Tokens"]),
			["default"] = true,
		})
		mod:create_category("Food & Potion", {
			["subtype"] = tMerge(mod.subtypes['Food'], mod.subtypes['Potions']),
			["default"] = true,
		})
		mod:create_category("Tradeskill", {
			["type"] = tMerge(mod.types["Tradeskill"], mod.types["Gems"], mod.types["Recipes"]),
			["subtype"] = tMerge(mod.subtypes["Generic Weapons"]),
			["default"] = true,
		})
		mod:create_category("Miscellaneous", {
			['type'] = tMerge(mod.types["Miscellaneous"]),
			["default"] = true,
		})

		config.first_run_complete = true
	end

	-- Create Frames
	mod:create_bags()
	mod:create_bank()
	mod:hook_blizzard_functions()

	mod:create_bag_slots()
end

function mod:config_callback()
	-- assert(false, "test")
	mod.config = mod:get_save()
	config = mod.config
	if (not config.enabled) then return end

	mod:update_bags()
	mod:update_bank()
end

--===============================================
-- Create Container
--===============================================
local function create_button(parent)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(20, 20)
	button.text = button:CreateFontString(nil, "OVERLAY")
	button.text:SetFont(bdUI.media.font, 11, "OUTLINE")
	button.text:SetAllPoints()
	button.text:SetJustifyH("CENTER")
	button.text:SetTextColor(.4, .4, .4)

	button:SetScript("OnEnter", function(self)
		self.text:SetTextColor(1, 1, 1)
	end)
	button:SetScript("OnLeave", function(self)
		self.text:SetTextColor(.4, .4, .4)
	end)

	button:SetScript("OnClick", function(self)
		button:callback()
	end)

	return button
end


function mod:create_container(name, ids, bagids)
	local bags = CreateFrame("Frame", "bd"..name, UIParent)
	mod.border = bdUI.border
	bags:SetSize(500, 400)
	bags:SetFrameStrata("HIGH")
	bags:EnableMouse(true)
	bags:SetMovable(true)
	bags:SetUserPlaced(true)
	bags:SetFrameStrata("HIGH")
	bags:RegisterForDrag("LeftButton","RightButton")
	bags:RegisterForDrag("LeftButton","RightButton")
	bags:SetScript("OnDragStart", function(self) self:StartMoving() end)
	bags:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
	bags:Hide()
	bdUI:set_backdrop(bags)
	bags._background:SetVertexColor(.08, .09, .11, 1)

	-- header
	local header = CreateFrame("frame", nil, bags)
	header:SetPoint("TOPLEFT", bags, "TOPLEFT", 0, 0)
	header:SetPoint("BOTTOMRIGHT", bags, "TOPRIGHT", 0, -30)
	bags.header = header

	-- footer
	local footer = CreateFrame("frame", nil, bags)
	footer:SetPoint("TOPLEFT", bags, "BOTTOMLEFT", 0, 0)
	footer:SetPoint("TOPRIGHT", bags, "BOTTOMRIGHT", 0, 0)
	bags.footer = footer

	-- add category
	local add_category = create_button(footer)
	add_category.text:SetText("+")
	add_category:SetPoint("RIGHT", footer, "RIGHT", -4, 0)
	add_category.text:SetFont(bdUI.media.font, 14, "OUTLINE")
	add_category.callback = function(self)
		mod:create_category("New Category", {
			["brand_new"] = true
		})
		mod:update_bags()
	end

	-- category container
	local container = CreateFrame("frame", nil, bags)
	container:SetPoint("TOPLEFT", bags, "TOPLEFT", 0, -30)
	container:SetPoint("BOTTOMRIGHT", bags, "BOTTOMRIGHT", 0, 30)
	bags.container = container

	-- close
	local close_button = create_button(header)
	close_button.text:SetText("X")
	close_button:SetPoint("RIGHT", header, "RIGHT", -4, 0)
	close_button.callback = function(self)
		bags:Hide()
	end

	-- sort
	local sort_bags = create_button(header)
	sort_bags.text:SetText("S")
	sort_bags:SetPoint("RIGHT", close_button, "LEFT", -4, 0)
	sort_bags.callback = SortBags
	bags.sorter = sort_bags

	-- bags
	local bags_button = create_button(header)
	bags_button.text:SetText("B")
	bags_button:SetPoint("RIGHT", sort_bags, "LEFT", -4, 0)
	bags_button.callback = function()
		self.bag_slots:SetShown(not self.bag_slots:IsShown())
	end

	-- money
	local money = mod:create_money(name, bags)
	money:SetPoint("LEFT", header, "LEFT", 6, -1)

	-- search
	local searchBox = CreateFrame("EditBox", "bd"..name.."SearchBox", bags, "BagSearchBoxTemplate")
	searchBox:SetHeight(20)
	searchBox:SetPoint("RIGHT", bags_button, "LEFT", -8, 2)
	searchBox:SetPoint("LEFT", money, "RIGHT", 4, 2)
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
	function bags:update_size(width, height)
		-- print(height)
		bags:SetSize(width, height + header:GetHeight() + footer:GetHeight())
	end

	-- create parent bags for id searching
	-- for k, bagID in pairs(ids) do
	-- 	local f = CreateFrame("Frame", 'bdBagsItemContainer'..bagID, bags)
	-- 	mod.bag_frames[bagID] = f
	-- 	f:SetID(bagID)
	-- end
	-- for k, bagID in pairs(bagids) do
	-- end

	

	mod.containers[name:lower()] = bags
	return bags
end

function mod:create_bag_slots()
	local bags = {}
	bags['bags'] = {0, 1, 2, 3, 4}
	bags['bank'] = {-1, 5, 6, 7, 8, 9, 10, 11}

	local slots = {}
	slots['bags'] = {1, 2, 3, 4, 5}
	slots['bank'] = {6, 7, 8, 9, 10, 11, 12}

	for bag, group in pairs(bags) do
		local bag = mod.containers[bag]

		for k, bagID in pairs(group) do
			local slot = CreateFrame("frame", 'bdBagsItemContainer'..bagID, bag)
			slot:SetID(bagID)
			mod.bag_frames[bagID] = slot
		end
	end

	-- 	local containers = CreateFrame("frame", nil, parent)
	-- 	containers:SetSize(((30 + mod.border) * #bagids) + (mod.border*4) - mod.border, 30 + (mod.border*4))
	-- 	containers:Hide()
	-- 	bdUI:set_backdrop(containers)

	-- 	-- local someids 

	-- 	local last = nil
	-- 	for k, i in pairs(bagids) do
	-- 		local bag_slot = CreateFrame("ItemButton", "bdBagsBackpack"..i, containers)
	-- 		bag_slot:SetSize(30, 30)
	-- 		bag_slot.invSlot = ContainerIDToInventoryID(i)
	-- 		Mixin(bag_slot, bag_slot_methods)

	-- 		bag_slot:skin()
	-- 		bag_slot:update()

	-- 		bag_slot:EnableMouse(true)
	-- 		bag_slot:RegisterForDrag("LeftButton")
	-- 		bag_slot:RegisterForClicks("LeftButtonUp", "RightButtonUp")

	-- 		bag_slot:SetScript('OnShow', bag_slot.onshow)
	-- 		bag_slot:SetScript('OnHide', bag_slot.onhide)
	-- 		bag_slot:SetScript('OnEvent', bag_slot.onevent)
	-- 		bag_slot:SetScript('OnEnter', bag_slot.onenter)
	-- 		bag_slot:SetScript('OnLeave', bag_slot.onleave)
	-- 		bag_slot:SetScript('OnDragStart', bag_slot.dragstart)
	-- 		bag_slot:SetScript('OnReceiveDrag', bag_slot.onclick)
	-- 		bag_slot:SetScript('OnClick', bag_slot.onclick)

	-- 		if (not last) then
	-- 			bag_slot:SetPoint("LEFT", containers, "LEFT", mod.border*2, 0)
	-- 		else
	-- 			bag_slot:SetPoint("LEFT", last, "RIGHT", mod.border, 0)
	-- 		end

	-- 		last = bag_slot
	-- 	end

	-- 	return containers

	-- 	-- bag replacements
	-- 	local bag_slots = mod:create_containers(bags, bagids)
	-- 	bag_slots:SetPoint("BOTTOMRIGHT", bags, "TOPRIGHT", 0, mod.border)

	-- 	for i = 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
	-- 		local invID = ContainerIDToInventoryID(i)
	-- 		print(i, invID, GetInventoryItemLink("player", invID))
	-- 	end

	-- 	self.bag_slots = bag_slots
	-- end
	
end

--===============================================
-- Replace blizzard functions to open our bags
--===============================================
function mod:hook_blizzard_functions()
	local function close_all()
		mod.bags:Hide()
	end
	local function open_all()
		mod.bags:Show()
	end

	local function close_bag()
		mod.bags:Hide()
	end

	local function open_bag()
		mod.bags:Show()
	end

	local function toggle_bag()
		mod.bags:SetShown(not mod.bags:IsShown())
	end

	mod:RawHook("ToggleBackpack", toggle_bag, true)
	mod:RawHook("ToggleAllBags", toggle_bag, true)
	mod:RawHook("ToggleBag", toggle_bag, true)
	mod:RawHook("OpenAllBags", open_all, true)
	mod:RawHook("OpenBackpack", open_bag, true)
	mod:RawHook("OpenBag", open_bag, true)
	mod:RawHook("CloseBag", close_bag, true)
	mod:RawHook("CloseBackpack", close_bag, true)
	mod:RawHook("CloseAllBags", close_all, true)
	hooksecurefunc("CloseSpecialWindows", close_all)

end



function ContainerFrame_GenerateFrame(frame, size, id)
	print(size, id)
end