local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("General")

local delete_panel = StaticPopupDialogs["DELETE_GOOD_ITEM"]

local function prefill_text(box)
	box.editBox:SetText(DELETE_ITEM_CONFIRM_STRING)
end

hooksecurefunc(delete_panel, "OnShow", prefill_text)

-- auto sell
local sell = CreateFrame("frame")
sell:RegisterEvent('MERCHANT_SHOW')
sell:HookScript("OnEvent", function()
	if (mod.config.autosell) then
		
		local profit = 0
		local index = 0
		for bagID = 0, 4 do
			for slot = 0, GetContainerNumSlots(bagID) do
				local texture, itemCount, locked, quality, readable, lootable, itemLink = GetContainerItemInfo(bagID, slot);

				if (texture and quality == 0) then
					local price = select(11, GetItemInfo(itemLink))
					profit = profit + price

					-- C_Timer.After(0.005 * index, function()
					-- 	if (not locked) then
					-- 		UseContainerItem(bagID, slot)
					-- 	end
					-- end)
					if (not locked) then
						UseContainerItem(bagID, slot)
					else
						C_Timer.After(0.3, function()
							UseContainerItem(bagID, slot)
						end)
					end
				end
			end
		end
		if (profit > 0) then
			print(("Sold all trash for %d|cFFF0D440"..GOLD_AMOUNT_SYMBOL.."|r %d|cFFC0C0C0"..SILVER_AMOUNT_SYMBOL.."|r %d|cFF954F28"..COPPER_AMOUNT_SYMBOL.."|r"):format(profit / 100 / 100, (profit / 100) % 100, profit % 100));
		end
	end
end)

-- auto repair
local repair = CreateFrame("frame")
repair:RegisterEvent('MERCHANT_SHOW')
repair:SetScript("OnEvent", function()
	if (mod.config.autorepair) then
		if CanMerchantRepair() then
			local cost = GetRepairAllCost()
			if GetGuildBankWithdrawMoney() >= cost then
				RepairAllItems(1)
			elseif GetMoney() >= cost then
				RepairAllItems()
			end
		end
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