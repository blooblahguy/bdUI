local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Bags")

function mod:create_reagents()
	if (not IsReagentBankUnlocked or not IsReagentBankUnlocked()) then return end -- make sure we have this

	mod.reagent = mod:create_container("Reagents", true)
	mod.reagent:SetMovable(true)
	mod.reagent:SetUserPlaced(false)
	mod.reagent:SetFrameLevel(20)
	mod.reagent:RegisterForDrag("LeftButton","RightButton")
	mod.reagent:RegisterForDrag("LeftButton","RightButton")
	mod.reagent:SetScript("OnDragStart", function(self) mod.bank:StartMoving() end)
	mod.reagent:SetScript("OnDragStop", function(self) mod.bank:StopMovingOrSizing() end)
	mod.reagent:ClearAllPoints()
	mod.reagent:SetPoint("TOP", mod.bank)
	mod.reagent.item_pool = CreateObjectPool(mod.item_pool_create, mod.item_pool_reset)
	mod.reagent.cat_pool = CreateObjectPool(mod.category_pool_create, mod.category_pool_reset)

	ReagentBankFrame_OnShow(ReagentBankFrame) -- populate the frames for blizzard

	local deposit_all = mod:create_button(mod.reagent)
	deposit_all.text:SetText("Deposit All Reagents")
	deposit_all:SetWidth(100)
	deposit_all:SetPoint("TOP", mod.reagent, "BOTTOM", 0, -mod.border)
	bdUI:set_backdrop(deposit_all)
	deposit_all:SetActive()
	deposit_all.callback = function(self)
		DepositReagentBank()
	end

	mod.bank_reagent_tabs = CreateFrame("frame", "bdBank_tabs", mod.bank)
	local btab = mod:create_button(mod.bank_reagent_tabs)
	btab.text:SetText("Bank")
	btab:SetWidth(50)
	btab:SetPoint("LEFT", mod.bank_reagent_tabs)
	bdUI:set_backdrop(btab)
	btab:SetActive()
	btab.callback = function(self)
		mod.bank_reagent_tabs.rtab:SetInactive()
		mod.bank_reagent_tabs.btab:SetActive()
		mod.reagent:Hide()
		mod.bank:Show()
		mod.bank_reagent_tabs:SetParent(mod.bank)
		mod.bank_reagent_tabs:SetPoint("BOTTOM", mod.bank, "TOP")
	end
	mod.bank_reagent_tabs.btab = btab

	local rtab = mod:create_button(mod.bank_reagent_tabs)
	rtab.text:SetText("Reagents")
	rtab:SetWidth(60)
	rtab:SetPoint("RIGHT", mod.bank_reagent_tabs)
	bdUI:set_backdrop(rtab)
	rtab.callback = function(self)
		mod.bank_reagent_tabs.btab:SetInactive()
		mod.bank_reagent_tabs.rtab:SetActive()
		mod.bank:Hide()
		mod.reagent:Show()
		mod.bank_reagent_tabs:SetParent(mod.reagent)
		mod.bank_reagent_tabs:SetPoint("BOTTOM", mod.reagent, "TOP")
	end
	mod.bank_reagent_tabs.rtab = rtab

	mod.bank_reagent_tabs:SetSize(rtab:GetWidth() + btab:GetWidth() + mod.border, btab:GetHeight())
	mod.bank_reagent_tabs:SetPoint("BOTTOM", mod.bank, "TOP", 0, mod.border)

	mod.bags:RegisterEvent('BAG_UPDATE_DELAYED')
	mod.bags:RegisterEvent('PLAYERREAGENTBANKSLOTS_CHANGED')
	mod.bags:RegisterEvent('BANKFRAME_OPENED')
	mod.bags:RegisterEvent('BANKFRAME_CLOSED')

	local run_bag_holder = 0
	mod.bags:HookScript("OnEvent", function(self, event, arg1)
		if (event == "BANKFRAME_CLOSED") then
			mod.reagent:Hide()
			return
		end

		mod:update_reagents()
	end)
end

local categories = {}
function mod:update_reagents()
	if (not mod.bank:IsShown()) then return end

	categories = {}
	local bag = REAGENTBANK_CONTAINER
	local min, max, step = GetContainerNumSlots(bag), 1, -1
	
	for slot = min, max, step do
		local texture, itemCount, locked, quality, readable, lootable, itemLink = GetContainerItemInfo(bag, slot)

		-- make this table consistent from one place
		local itemInfo = mod:get_item_table(bag, slot, bag, itemCount, itemLink)

		mod.categoryIDtoNames[-2] = "Bag"
		mod.categoryNamestoID["Bag"] = -2

		-- store it in a category
		categories[-2] = categories[-2] or {}

		table.insert(categories[-2], itemInfo)
	end

	mod:draw_reagents()
end

function mod:draw_reagents()
	local config = mod.config

	mod.current_parent = mod.reagent -- we want new frames to parent to bags
	
	mod:position_items(categories, config.buttonsize, config.buttonsperrow)
	mod:position_categories(categories, config.buttonsize, config.buttonsperrow)
end