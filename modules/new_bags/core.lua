--===============================================
-- FUNCTIONS
--===============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("New Bags")
local config = {}

-- default variables
mod.containers = {}
mod.bag_frames = {}

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
	-- bdUI.persistent.categories = bdUI.persistent.categories or {}
	bdUI.persistent.categories = {}
	bdUI.persistent.shortcuts = bdUI.persistent.shortcuts or {}
	mod.categories = bdUI.persistent.categories
	mod.shortcuts = bdUI.persistent.shortcuts

	if (not mod.categories.first_run_complete) then
		mod:create_category("Quest", {
			["type"] = {12}
		})
		mod:create_category("Armor & Weapons", {
			["type"] = {2, 4}
		})
		mod:create_category("Consumables", {
			["type"] = {0, 8, 9, 16, 18}
		})
		mod:create_category("Tradeskill", {
			["type"] = {3, 7, 5},
		})
		mod:create_category("Miscellaneous", {
			['type'] = {15, 13}
		})
	end

	-- Create Frames
	mod:create_bags()
	mod:update_bags()
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

	button:SetScript("OnClick", button.callback)

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
	header:SetPoint("BOTTOMLEFT", bags, "TOPLEFT", 0, mod.border)
	header:SetPoint("TOPRIGHT", bags, "TOPRIGHT", 0, 30)
	header:EnableMouse(true)
	header:RegisterForDrag("LeftButton","RightButton")
	header:RegisterForDrag("LeftButton","RightButton")
	header:SetScript("OnDragStart", function(self) self:GetParent():StartMoving() end)
	header:SetScript("OnDragStop", function(self) self:GetParent():StopMovingOrSizing() end)
	bdUI:set_backdrop(header)

	-- close
	local close_button = create_button(header)
	close_button.text:SetText("X")
	close_button:SetPoint("RIGHT", header, "RIGHT", -4, 0)

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
	money:SetPoint("LEFT", header, "LEFT", 4, 0)
	for k, v in pairs({"Gold","Silver","Copper"}) do
		_G[money:GetName()..v.."ButtonText"]:SetFont(bdUI.media.font, 12)
		_G[money:GetName()..v.."Button"]:EnableMouse(false)
		_G[money:GetName()..v.."Button"]:SetFrameLevel(8)
	end
	-- money:Show()
	-- money:SetParent(mod.bags)
	-- money:SetFrameLevel(10)
	-- money:RegisterEvent("PLAYER_ENTERING_WORLD")
	-- money:RegisterEvent("PLAYER_MONEY")
	-- money:HookScript("OnEvent", ContainerFrame1MoneyFrame.Update)

	-- search
	local searchBox = CreateFrame("EditBox", "bd"..name.."SearchBox", bags, "BagSearchBoxTemplate")
	searchBox:SetHeight(20)
	searchBox:SetPoint("RIGHT", bags_button, "LEFT", -4, 0)
	searchBox:SetFrameLevel(27)
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