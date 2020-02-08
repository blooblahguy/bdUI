local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("New Bags")
mod.bank = mod:create_container("Bank", 6, 12)

function mod:create_bank()
	mod.bank:Show()
	mod.bank:SetPoint("BOTTOMRIGHT", bdParent, "BOTTOMRIGHT", -30, 30)

	mod.bank.cat_pool = CreateObjectPool(mod.category_pool_create, mod.category_pool_reset)
	mod.bank.item_pool = CreateObjectPool(mod.item_pool_create, mod.item_pool_reset)
	mod.bank.category_items = {}

	mod.bank:RegisterEvent('EQUIPMENT_SWAP_PENDING')
	mod.bank:RegisterEvent('EQUIPMENT_SWAP_FINISHED')
	mod.bank:RegisterEvent('AUCTION_MULTISELL_START')
	mod.bank:RegisterEvent('AUCTION_MULTISELL_UPDATE')
	mod.bank:RegisterEvent('AUCTION_MULTISELL_FAILURE')
	mod.bank:RegisterEvent('BAG_UPDATE_DELAYED')

	mod.bank.open = function(self)
		mod.bank:Show()
	end
	mod.bank.close = function(self)
		mod.bank:Hide()
	end
	mod.bank.toggle = function(self)
		mod.bank:SetShown(not mod.bank:IsShown())
	end

	-- hooksecurefunc("OpenAllBags", mod.bags.open)
	-- hooksecurefunc("OpenBag", mod.bags.open)
	-- hooksecurefunc("OpenBackpack", mod.bags.open)

	-- hooksecurefunc("ToggleBackpack", mod.bags.toggle)
	-- hooksecurefunc("ToggleAllBags", mod.bags.toggle)
	-- hooksecurefunc("ToggleBag", mod.bags.toggle)

	-- hooksecurefunc("CloseAllBags", mod.bags.close)
	-- hooksecurefunc('CloseSpecialWindows', mod.bags.close)
	-- hooksecurefunc("CloseBag", mod.bags.close)
	-- hooksecurefunc("CloseBackpack", mod.bags.close)


	mod.bank:SetScript("OnEvent", function(self, event, arg1)
		if (event == "EQUIPMENT_SWAP_PENDING" or event == "AUCTION_MULTISELL_START") then
			self.paused = true
		elseif (event == "EQUIPMENT_SWAP_FINISHED" or event == "AUCTION_MULTISELL_FAILURE") then
			self.paused = false
			-- mod:update_bags()
		else
			if (self.paused) then return end
			-- mod:update_bags()
		end
	end)

	-- create shortcut category bar
end