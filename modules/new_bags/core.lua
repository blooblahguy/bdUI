--===============================================
-- FUNCTIONS
--===============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("New Bags")
local config = {}

-- default variables
local ace_hook = LibStub("AceHook-3.0")
ace_hook:Embed(mod)

mod.containers = {}
mod.bag_frames = {}


-- Backpack and bags
local BAGS = { [BACKPACK_CONTAINER] = BACKPACK_CONTAINER }
for i = 1, NUM_BAG_SLOTS do BAGS[i] = i end

-- Base nank bags
local BANK_ONLY = { [BANK_CONTAINER] = BANK_CONTAINER }
for i = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do BANK_ONLY[i] = i end

--- Reagent bank bags
local REAGENTBANK_ONLY = { [REAGENTBANK_CONTAINER] = REAGENTBANK_CONTAINER }

-- All bank bags
local BANK = {}
for _, bags in ipairs { BANK_ONLY, REAGENTBANK_ONLY } do
	for id in pairs(bags) do BANK[id] = id end
end

-- All bags
local ALL = {}
for _, bags in ipairs { BAGS, BANK } do
	for id in pairs(bags) do ALL[id] = id end
end

-- filter groups
local types = {}
types["Consumable"] = {0}
types["Bags"] = {1}
types["Weapon"] = {2, 6, 11}
types["Gems"] = {3}
types["Armor"] = {4}
types["Tradeskill"] = {5, 7, 9}
types["Enchantment"] = {8, 16}
types["Quest"] = {12}
types["Keys"] = {13}
types["Tokens"] = {10, 14, 17, 18}
types["Miscellaneous"] = {15}
mod.types = types

local subtypes = {}
subtypes[0] = {}
subtypes[0]["Food"] = {5}
subtypes[0]["Potions"] = {1, 2, 3}
mod.subtypes = subtypes

local filter_table = {}
filter_table[12] = "Quest"

--===============================================
-- Core functionality
-- place core functionality here
--===============================================
function mod:initialize()
	config = mod:get_save()
	if (not config.enabled or mod.initialized) then return end
	mod.initialized = true

	-- store saved variable for messing with
	config.categories = config.categories or {}
	-- config.categories = {}
	config.shortcuts = config.shortcuts or {}
	mod.categories = config.categories
	mod.shortcuts = config.shortcuts

	if (not mod.categories.first_run_complete) then
		mod:create_category("New Items", {
			["new_items"] = true,
			["default"] = true,
			["duplicate"] = true,
			["locked"] = true,
			["order"] = -1,
		})
		mod:create_category("Weapons", {
			["type"] = types["Weapon"],
			["default"] = true,
			["order"] = 1,
		})
		mod:create_category("Armor", {
			["type"] = types["Armor"],
			["default"] = true,
			["order"] = 2,
		})
		mod:create_category("Quest & Keys", {
			["type"] = tMerge(types["Quest"], types["Keys"]),
			["default"] = true,
			["itemids"] = {138019}
		})
		
		mod:create_category("Tools", {
			["type"] = tMerge(types["Consumable"], types["Enchantment"], types["Tokens"]),
			["default"] = true,
		})
		mod:create_category("Food & Potion", {
			["subtype"] = {{0, tMerge(subtypes[0].Food, subtypes[0].Potions)}},
			["default"] = true,
		})
		mod:create_category("Tradeskill", {
			["type"] = tMerge(types["Tradeskill"], types["Gems"]),
			["default"] = true,
		})
		mod:create_category("Miscellaneous", {
			['type'] = tMerge(types["Bags"], types["Miscellaneous"]),
			["default"] = true,
		})
		mod:create_category("Hearths", {
			["itemids"] = {6948, 140192, 141605, 110560},
			["default"] = true,
		})
		mod:create_category("Uncategorized", {
			["catch_all"] = true,
			["default"] = true,
			["locked"] = true,
			["order"] = 100
		})
	end

	-- Create Frames
	mod:create_bags()
	mod:update_bags()

	-- mod:create_bank()
end

function mod:config_callback()
	config = mod:get_save()
	if (not config.enabled) then return end
	mod:initialize()

	mod:update_bags()
end

--===============================================
-- Create Container
--===============================================
function create_button(parent)
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
function mod:create_container(name, start_id, end_id)
	local bags = CreateFrame("Frame", "bd"..name, UIParent)
	mod.border = bdUI:get_border(bags)
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
	bags.bd_background:SetVertexColor(.08, .09, .11, 1)

	-- header
	local header = CreateFrame("frame", nil, bags)
	header:SetPoint("TOPLEFT", bags, "TOPLEFT", 0, 0)
	header:SetPoint("BOTTOMRIGHT", bags, "TOPRIGHT", 0, -30)
	bags.header = header

	-- bag replacements
	local containers = mod:create_containers(bags, start_id, end_id)
	containers:SetPoint("BOTTOMRIGHT", bags, "TOPRIGHT", 0, mod.border)

	-- footer
	local footer = CreateFrame("frame", nil, bags)
	footer:SetPoint("TOPLEFT", bags, "BOTTOMLEFT", 0, 30)
	footer:SetPoint("BOTTOMRIGHT", bags, "BOTTOMRIGHT", 0, 0)
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
	bags.sorter = sort_bags

	-- bags
	local bags_button = create_button(header)
	bags_button.text:SetText("B")
	bags_button:SetPoint("RIGHT", sort_bags, "LEFT", -4, 0)
	bags_button.callback = function()
		containers:SetShown(not containers:IsShown())
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
	searchBox.bd_background:SetVertexColor(.06, .07, .09, 1)
	tinsert(_G.ITEM_SEARCHBAR_LIST, searchBox:GetName())

	-- callback for sizing
	function bags:update_size(width, height)
		-- print(height)
		bags:SetSize(width, height + header:GetHeight() + footer:GetHeight())
	end

	-- create parent bags for id searching
	for bagID = start_id, end_id do
		local f = CreateFrame("Frame", 'bdBagsItemContainer'..bagID, bags)
		f:SetID(bagID)
		mod.bag_frames[bagID] = f
	end

	mod.containers[name:lower()] = bags
	return bags
end



--===============================================
-- Stop Blizzard bags from rendering
--===============================================
function mod:hide_blizzard()

end