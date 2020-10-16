local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Bags (beta)")


--===================================
-- Create bank frames
--===================================
function mod:create_reagents()
	local config = mod.config
	mod.reagents:SetPoint("TOPLEFT", bdParent, "TOPLEFT", 30, -30)
	mod.reagents.container:SetWidth(config.bag_width)

	mod.reagents:RegisterEvent('EQUIPMENT_SWAP_PENDING')
	mod.reagents:RegisterEvent('EQUIPMENT_SWAP_FINISHED')
	mod.reagents:RegisterEvent('AUCTION_MULTISELL_START')
	mod.reagents:RegisterEvent('AUCTION_MULTISELL_UPDATE')
	mod.reagents:RegisterEvent('AUCTION_MULTISELL_FAILURE')
	mod.reagents:RegisterEvent('BAG_UPDATE_DELAYED')
	mod.reagents:RegisterEvent('BANKFRAME_OPENED')
	mod.reagents:RegisterEvent('BANKFRAME_CLOSED')

	mod.reagents:SetScript("OnEvent", function(self, event, arg1)
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
end


function mod:update_reagents()

end

function mod:draw_regeants()

end