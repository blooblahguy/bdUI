local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("General")

local function delay(tick)
    local th = coroutine.running()
    C_Timer.After(tick, function() coroutine.resume(th) end)
    coroutine.yield()
end

-- auto fills delete the text for item
local delete_panel = StaticPopupDialogs["DELETE_GOOD_ITEM"]
local function prefill_text(box)
	box.editBox:SetText(DELETE_ITEM_CONFIRM_STRING)
end
hooksecurefunc(delete_panel, "OnShow", prefill_text)

-- auto sell
local cansell = false
local repair = 0
local trash = 0
 
local function sell_trash(bag)
    for slot = 1, GetContainerNumSlots(bag) do
		if not cansell then break end

		local texture, itemCount, locked, quality, readable, lootable, itemLink = GetContainerItemInfo(bag, slot)
		if (texture and quality == 0 and not locked) then
			UseContainerItem(bag, slot)
			delay(0.05)
		end
    end

	if (bag < 4) then
		bag = bag + 1
		coroutine.wrap(sell_trash)(bag)
	elseif (trash > 0) then
		print("Sold Trash for "..GetMoneyString(trash, true))
	end
end

local sell = CreateFrame("frame")
sell:RegisterEvent('MERCHANT_SHOW')
sell:RegisterEvent('MERCHANT_CLOSED')
sell:HookScript("OnEvent", function(self, event)
	if (event == "MERCHANT_SHOW") then
		trash = 0
		cansell = true
	else
		trash = 0
		cansell = false
	end

	-- auto repair
	if (mod.config.autorepair) then
		if CanMerchantRepair() then
			local repair = GetRepairAllCost()
			if GetGuildBankWithdrawMoney() >= repair then
				RepairAllItems(1)
			elseif GetMoney() >= repair then
				RepairAllItems()
			end

			if (repair > 0) then
				print("Repaired for "..GetMoneyString(repair, true))
			end
		end
	end

	-- coroutine autosell
	if (mod.config.autosell) then

		-- count our values first
		for bag = 0, 4 do
			for slot = 1, GetContainerNumSlots(bag) do
				local texture, itemCount, locked, quality, readable, lootable, itemLink = GetContainerItemInfo(bag, slot)
				-- print(itemLink)
				if (texture and quality == 0 and not locked) then
					local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(itemLink)

					trash = trash + itemSellPrice
				end
			end
		end

		coroutine.wrap(sell_trash)(0)
		
		-- local index = 0
		-- for bagID = 0, 4 do
		-- 	for slot = 0, GetContainerNumSlots(bagID) do
		-- 		local texture, itemCount, locked, quality, readable, lootable, itemLink = GetContainerItemInfo(bagID, slot);

		-- 		if (texture and quality == 0) then
		-- 			local price = select(11, GetItemInfo(itemLink))
		-- 			profit = profit + price

		-- 			if (not locked) then
		-- 				UseContainerItem(bagID, slot)
		-- 			else
		-- 				C_Timer.After(0.2, function()
		-- 					if (cansell) then
		-- 						UseContainerItem(bagID, slot)
		-- 					end
		-- 				end)
		-- 			end
		-- 		end
		-- 	end
		-- end
		-- C_Timer.After(2, function()
		-- 	if (profit > 0) then
		-- 		print(("Sold all trash for %d|cFFF0D440"..GOLD_AMOUNT_SYMBOL.."|r %d|cFFC0C0C0"..SILVER_AMOUNT_SYMBOL.."|r %d|cFF954F28"..COPPER_AMOUNT_SYMBOL.."|r"):format(profit / 100 / 100, (profit / 100) % 100, profit % 100));
		-- 	end
		-- end)
	end
end)


local fastloot = CreateFrame("frame",nil)
fastloot:RegisterEvent("LOOT_OPENED")
fastloot:SetScript("OnEvent",function()
	local autoLoot = tonumber(GetCVar("autoLootDefault")) == 1 and true or false

	if ((IsShiftKeyDown() ~= autoLoot)) then
		local numitems = GetNumLootItems()
		for i = 1, numitems do
			LootSlot(i)
		end
	end
end)