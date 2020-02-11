--===============================================
-- FUNCTIONS
--===============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("New Bags")
local config = {}

-- default variables
mod.containers = {}
mod.bag_frames = {}

-- filter groups
local types = {}
types["Consumable"] = {0}
types["Bags"] = {1}
types["Weapon"] = {2, 6, 11}
types["Gem"] = {3}
types["Armor"] = {4}
types["Tradeskill"] = {5, 7, 9}
types["Enchantment"] = {8, 16}
types["Quest"] = {12}
types["Keys"] = {13}
types["Tokens"] = {10, 14, 17, 18}
types["Miscellaneous"] = {15}
mod.types = types

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
	-- config.categories = config.categories or {}
	config.categories = {}
	config.shortcuts = config.shortcuts or {}
	mod.categories = config.categories
	mod.shortcuts = config.shortcuts

	if (not mod.categories.first_run_complete) then
		mod:create_category("New Items", {
			["new_items"] = true,
			["default"] = true,
			["duplicate"] = true,
			["locked"] = true,
		})
		mod:create_category("Quest & Keys", {
			["type"] = mod:merge(mod.types["Quest"], mod.types["Keys"]),
			["default"] = true,
			["itemids"] = {138019}
		})
		mod:create_category("Armor & Weapons", {
			["type"] = mod:merge(mod.types["Armor"], mod.types["Weapon"]),
			["default"] = true,
		})
		mod:create_category("Consumables", {
			["type"] = mod:merge(mod.types["Consumable"], mod.types["Enchantment"], mod.types["Tokens"]),
			["default"] = true,
		})
		mod:create_category("Tradeskill", {
			["type"] = mod:merge(mod.types["Tradeskill"], mod.types["Gem"]),
			["default"] = true,
		})
		mod:create_category("Miscellaneous", {
			['type'] = mod:merge(mod.types["Bags"], mod.types["Miscellaneous"]),
			["default"] = true,
		})
		mod:create_category("Uncategorized", {
			["catch_all"] = true,
			["default"] = true,
			["locked"] = true,
		})
	end

	-- Create Frames
	mod:create_bags()
	mod:update_bags()

	-- mod:create_bank()
end

function mod:config_callback()
	if (not config.enabled) then return end
	mod:initialize()


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
	bags:SetSize(500, 300)
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

	-- header
	local header = CreateFrame("frame", nil, bags)
	header:SetPoint("TOPLEFT", bags, "TOPLEFT", 0, 0)
	header:SetPoint("BOTTOMRIGHT", bags, "TOPRIGHT", 0, -30)

	-- footer
	local footer = CreateFrame("frame", nil, bags)
	footer:SetPoint("TOPLEFT", bags, "BOTTOMLEFT", 0, 30)
	footer:SetPoint("BOTTOMRIGHT", bags, "BOTTOMRIGHT", 0, 0)

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

	-- bags
	local bags_button = create_button(header)
	bags_button.text:SetText("B")
	bags_button:SetPoint("RIGHT", sort_bags, "LEFT", -4, 0)

	-- money
	local money = CreateFrame("frame", "bd"..name.."Money", bags, "SmallMoneyFrameTemplate")
	money:SetPoint("LEFT", header, "LEFT", 6, -1)
	for k, v in pairs({"Gold","Silver","Copper"}) do
		_G[money:GetName()..v.."ButtonText"]:SetFont(bdUI.media.font, 12)
		_G[money:GetName()..v.."Button"]:EnableMouse(false)
		_G[money:GetName()..v.."Button"]:SetFrameLevel(8)
	end
	-- money:RegisterEvent("PLAYER_ENTERING_WORLD")
	-- money:RegisterEvent("PLAYER_MONEY")
	-- money:HookScript("OnEvent", ContainerFrame1MoneyFrame.Update)

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
	tinsert(_G.ITEM_SEARCHBAR_LIST, searchBox:GetName())

	-- callback for sizing
	function bags:update_size(width, height)
		bags:SetSize(width + 20, height + 40)
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