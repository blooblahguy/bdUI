local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Bags (beta)")

--===================================
-- Create bank frames
--===================================
function mod:create_reagents()
	local config = mod.config
	local reagents = CreateFrame("Frame", nil, mod.bank)
	reagents.cat_pool = CreateObjectPool(mod.category_pool_create, mod.category_pool_reset)
	reagents.item_pool = CreateObjectPool(mod.item_pool_create, mod.item_pool_reset)
	reagents:SetPoint("TOPLEFT", mod.bank, "TOPRIGHT", -2)
	reagents:SetPoint("BOTTOMLEFT", mod.bank, "BOTTOMRIGHT", -2)
	reagents:SetWidth(500)
	reagents:SetHeight(500)
	reagents:SetFrameStrata("HIGH")
	bdUI:set_backdrop(reagents)

	-- header
	local header = CreateFrame("frame", nil, reagents)
	header:SetPoint("TOPLEFT", reagents, "TOPLEFT", 0, 0)
	header:SetPoint("BOTTOMRIGHT", reagents, "TOPRIGHT", 0, -30)
	reagents.header = header

	local sort_bags = mod:create_button(header)
	sort_bags.text:SetText("S")
	sort_bags:SetPoint("RIGHT", header, "RIGHT", -4, 0)
	sort_bags.callback = function() BankItemAutoSortButton:Click() end
	reagents.sorter = sort_bags

	local button = CreateFrame("Button", nil, header, BackdropTemplateMixin and "BackdropTemplate, UIPanelButtonTemplate" or "UIPanelButtonTemplate")
	button:SetText("Deposit All Reagents")
	button:SetPoint("CENTER", header, "CENTER", 0)
	bdUI:skin_button(button)

	local container = CreateFrame("frame", nil, reagents)
	container:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 10, -10)
	container:SetPoint("BOTTOMRIGHT", reagents, "BOTTOMRIGHT", -10, 10)
	reagents.container = container

	reagents:RegisterEvent('EQUIPMENT_SWAP_PENDING')
	reagents:RegisterEvent('EQUIPMENT_SWAP_FINISHED')
	reagents:RegisterEvent('AUCTION_MULTISELL_START')
	reagents:RegisterEvent('AUCTION_MULTISELL_UPDATE')
	reagents:RegisterEvent('AUCTION_MULTISELL_FAILURE')
	reagents:RegisterEvent('BAG_UPDATE_DELAYED')
	reagents:RegisterEvent('BANKFRAME_OPENED')
	reagents:RegisterEvent('BANKFRAME_CLOSED')

	reagents:SetScript("OnEvent", function(self, event, arg1)
		if (event == "EQUIPMENT_SWAP_PENDING" or event == "AUCTION_MULTISELL_START") then
			self.paused = true
		elseif (event == "EQUIPMENT_SWAP_FINISHED" or event == "AUCTION_MULTISELL_FAILURE") then
			self.paused = false
		elseif (event == "BANKFRAME_OPENED") then
			mod.reagents:Show()
		elseif (event == "BANKFRAME_CLOSED") then
			mod.reagents:Hide()
		end

		if (not self.paused) then
			mod:update_reagents()
		end
	end)


	mod.reagents = reagents
end


function mod:update_reagents()
	local items = {}
end

function mod:draw_regeants()

end