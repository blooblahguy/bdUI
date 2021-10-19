local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Bags")

local ace_hook = LibStub("AceHook-3.0")
ace_hook:Embed(mod)

mod.spacing = 20 --config.buttonsize

function mod:initialize()
	mod.config = mod:get_save()

	if (not mod.config.enabled) then return end
	mod.initialized = true
	mod.border = bdUI:get_border(UIParent)

	mod:create_bags() -- bags first
	mod:create_currencies()
	mod:create_bank() -- now bank
	-- mod:create_bagslot_frames() -- bagslot holders
	mod:create_reagents() -- lastly reagents

	mod:hook_blizzard_functions()

	-- debug tooltips
	-- GameTooltip:HookScript("OnTooltipSetItem", function(tooltip)
	-- 	local _, link = tooltip:GetItem()
	-- 	if not link then return end
		
	-- 	local itemString = string.match(link, "item[%-?%d:]+")
	-- 	local _, itemId = strsplit(":", itemString)

	-- 	local name, link, rarity, ilvl, minlevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, sellPrice, itemTypeID, itemSubTypeID, bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo(link)

	-- 	local lcolor = {0.6, 0.6, 0.6}
	-- 	local rcolor = {1, 1, 1}

	-- 	-- local itemType = 
	-- 	tooltip:AddDoubleLine("itemId", itemId, unpack(lcolor), unpack(rcolor))
	-- 	tooltip:AddDoubleLine("itemType", itemType, unpack(lcolor), unpack(rcolor))
	-- 	tooltip:AddDoubleLine("itemTypeID", itemTypeID, unpack(lcolor), unpack(rcolor))
	-- 	tooltip:AddDoubleLine("itemSubType", itemSubType, unpack(lcolor), unpack(rcolor))
	-- 	tooltip:AddDoubleLine("itemSubTypeID", itemSubTypeID, unpack(lcolor), unpack(rcolor))
	-- 	tooltip:AddDoubleLine("ilvl", ilvl, unpack(lcolor), unpack(rcolor))
	-- 	tooltip:AddDoubleLine("itemEquipLoc", itemEquipLoc, unpack(lcolor), unpack(rcolor))
	-- 	tooltip:AddDoubleLine("itemSetID", itemSetID, unpack(lcolor), unpack(rcolor))
	-- end)
end

function mod:config_callback()
	if (not mod.initialized and mod.config.enabled) then
		mod:initialize()
		mod:update_bags()
		-- mod:position_bag_categories()
	end
end

function mod:hook_blizzard_functions()
	-- bags
	
	-- local function open_all()
	-- 	mod.bags:Show()
	-- end

	local function close_bags()
		mod.bags:Hide()
	end

	local function open_bags()
		mod.bags:Show()
		mod:update_bags()
		mod:draw_bag()
		-- mod:draw_bag_categories()
	end

	local function toggle_bags()
		if (not mod.bags:IsShown()) then
			open_bags()
		else
			close_bags()
		end
	end

	local function close_all()
		close_bags()
		-- mod.bank:Hide()
	end

	mod:RawHook("ToggleBackpack", toggle_bags, true)
	mod:RawHook("ToggleAllBags", toggle_bags, true)
	mod:RawHook("ToggleBag", toggle_bags, true)
	mod:RawHook("OpenAllBags", open_bags, true)
	mod:RawHook("OpenBackpack", open_bags, true)
	mod:RawHook("OpenBag", open_bags, true)
	mod:RawHook("CloseBag", close_bags, true)
	mod:RawHook("CloseBackpack", close_bags, true)
	mod:RawHook("CloseAllBags", close_all, true)
	hooksecurefunc("CloseSpecialWindows", close_all)

	-- mod:RawHook(BankFrame, "Show", open_bank, true)
	-- mod:RawHook(BankFrame, "Hide", close_bank, true)
end
