local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Tooltips")

local function summarize_stats(self, func)
	local itemName, itemLink = self:GetItem()

	if (not itemLink) then return end

	-- print(itemLink)
end

-- add equippables ilvl
local function add_ilvl(tooltip)
	if (not mod.config.show_ilvls or not mod.config.enablett) then return end
	if (not tooltip.GetItem) then return end -- dragonflight
	local item = tooltip:GetItem()
	local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType, expacID, setID, isCraftingReagent =
	GetItemInfo(item)
	if (not itemLevel or itemEquipLoc == "") then return end
	tooltip:AddDoubleLine("Item Level", itemLevel, nil, nil, nil, 1, 1, 1)
	-- tooltip:AddLine("Item Level: "..itemLevel)
end

function mod:create_ilvl()
	local tooltips = {
		'GameTooltip',
		'ItemRefTooltip',
		'ItemRefShoppingTooltip1',
		'ItemRefShoppingTooltip2',
		'ShoppingTooltip1',
		'ShoppingTooltip2',
	}

	local funcs = {
		"SetHyperlink",
		"SetBagItem",
		"SetHyperlinkCompareItem",
		"SetGuildBankItem",
		"SetBuybackItem",
		"SetMerchantItem",
		"SetMerchantCompareItem",
		"SetInventoryItem",
	}

	-- hook compare items
	-- hooksecurefunc("GameTooltip_ShowCompareItem", function(self, ...)
	-- -- 	local shoppingTooltip1, shoppingTooltip2 = unpack(self.shoppingTooltips)
	-- -- 	if ( shoppingTooltip1:IsShown() ) then
	-- -- 		summarize_stats(ShoppingTooltip1, "GameTooltip_ShowCompareItem", ...)
	-- -- 	end
	-- -- 	if ( shoppingTooltip2:IsShown() ) then
	-- -- 		summarize_stats(shoppingTooltip2, "GameTooltip_ShowCompareItem", ...)
	-- -- 	end
	-- -- end)

	-- -- hook main tooltips
	-- for k, tt in pairs(tooltips) do
	-- 	for k, func in pairs(funcs) do
	-- 		if (_G[tt] and _G[tt][func]) then
	-- 			hooksecurefunc(_G[tt], func, function(self, ...)
	-- 				summarize_stats(self, func, ...)
	-- 			end)
	-- 		end
	-- 	end
	-- end
end
