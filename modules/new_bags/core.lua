--===============================================
-- FUNCTIONS
--===============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("New Bags")
local config = {}

-- default variables
mod.containers = {}
mod.bag_frames = {}
mod.font = CreateFont("BDN_FONT")
mod.font:SetFont(bdUI.media.font, 14)
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
function mod:create_container(name, start_id, end_id)
	local bags = CreateFrame("Frame", "bd"..name, UIParent)
	bags:SetSize(500, 300)
	bags:EnableMouse(true)
	bags:SetMovable(true)
	bags:SetUserPlaced(true)
	bags:SetClampedToScreen(true)
	bags:SetFrameStrata("HIGH")
	bags:SetPoint("BOTTOMRIGHT", bdParent, "BOTTOMRIGHT", -30, 30)
	bdUI:set_backdrop(bags)

	bags:RegisterForDrag("LeftButton","RightButton")
	bags:RegisterForDrag("LeftButton","RightButton")
	bags:SetScript("OnDragStart", function(self) self:StartMoving() end)
	bags:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

	-- callback for sizing
	function bags.update_size(width, height)
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
-- CATEGORY FUNCTIONS
--===============================================
mod.category_create = function(self)
	local frame = CreateFrame("frame", nil, mod.current_parent)
	frame:SetHeight(100)
	frame:SetWidth(200)
	-- bdUI:set_backdrop(frame)

	frame.dragger = CreateFrame("Button", nil, frame, "ContainerFrameItemButtonTemplate")
	frame.dragger:SetPoint("TOPLEFT", frame, "TOPLEFT")
	frame.dragger:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, -30)
	frame.dragger:SetHeight(30)
	frame.dragger:SetWidth(30)
	bdUI:set_backdrop(frame.dragger)

	frame.container = CreateFrame("frame", nil, frame)
	frame.container:SetPoint("TOPLEFT", frame.dragger, "BOTTOMLEFT")
	frame.container:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")

	frame.text = frame:CreateFontString(nil, "OVERLAY")
	frame.text:SetFontObject(mod.font)
	frame.text:SetPoint("LEFT", frame.dragger, "LEFT", 6, 0)

	function frame.update_size(width, height)
		frame:SetSize(width + 20, height + 40)
	end

	return frame
end
mod.category_reset = function(self, frame)
	frame:ClearAllPoints()
	frame:SetParent(mod.current_parent)
	frame.text:SetText("")
	frame:Hide()
end

--===============================================
-- CATEGORY FUNCTIONS
--===============================================
local item_num = 0
mod.item_create = function(self)
	local button = CreateFrame("ItemButton", "bdBags_Item_"..item_num, mod.current_parent, "ContainerFrameItemButtonTemplate")
	button:SetHeight(30)
	button:SetWidth(30)
	bdUI:set_backdrop(button)
	Mixin(button, ItemButtonMixin )
	button:RegisterForDrag("LeftButton")
	button:RegisterForClicks("LeftButtonUp","RightButtonUp")
	button:SetScript('OnShow', button.OnShow)
	button:SetScript('OnHide', button.OnHide)
	if button.NewItemTexture then
		button.NewItemTexture:Hide()
	end
	button.SplitStack = nil -- Remove the function set up by the template

	-- functions
	function button:update()
		self.BattlepayItemTexture:SetShown(IsBattlePayItem(self.bag, self.slot))
		self.UpgradeIcon:SetShown(IsContainerItemAnUpgrade(self.bag, self.slot) or false)
		if self.count > 1 then
			self.Count:SetText(self.count)
			self.Count:Show()
		else
			self.Count:Hide()
		end
	end

	function button:update_cooldown()
		return ContainerFrame_UpdateCooldown(self.bag, self)
	end

	item_num = item_num + 1
	return button
end
mod.item_reset = function(self, frame)
	frame:ClearAllPoints()
	frame:SetParent(mod.current_parent)
	frame:Hide()
end

function mod:delete_category(name)

end
function mod:create_category(name, custom_conditions, order)
	-- if (mod.categories[name]) then return end
	order = order or #mod.categories + 1
	mod.categories[name] = mod.categories[name] or {}
	local category = mod.categories[name]

	-- default condition fillers
	local conditions = {}
	conditions['type'] = {}
	conditions['subtype'] = {}
	conditions['ilvl'] = 0
	conditions['expacID'] = 0
	conditions['rarity'] = 0
	conditions['minlevel'] = 0
	conditions['itemids'] = {}
	for k, v in pairs(custom_conditions) do conditions[k] = v end

	category.conditions = conditions
	category.name = name
	category.order = order
end

function mod:category_add_filter()

end

--===============================================
-- Stop Blizzard bags from rendering
--===============================================
function mod:hide_blizzard()

end