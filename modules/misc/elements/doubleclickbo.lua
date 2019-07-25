local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Misc")


function mod:create_dcbo(event, addon)
	local config = mod._config
	local dcbo = CreateFrame('frame')
	dcbo:SetScript("OnEvent", function(self, event, ...) self[event](self, event, ...) end)
	dcbo:RegisterEvent("ADDON_LOADED")

	function dcbo:ADDON_LOADED(event, addon)
		if addon ~= "Blizzard_AuctionUI" then return end
		self:UnregisterEvent(event)

		local lastClickTime = nil
		local lastBrowseClicked = nil

		for i = 1, NUM_BROWSE_TO_DISPLAY do
			local browseButton = _G["BrowseButton"..i]
			local browseButtonOnClick = browseButton:GetScript("OnClick")

			browseButton:SetScript("PostClick", function(self)
				if (not config.doubleclickbo) then 
					browseButtonOnClick(self)

					lastBrowseClicked = browseClicked
					lastClickTime = currentTime
					
					return
				end
				
				--browseButtonOnClick(self)
				--[[if (IsShiftKeyDown()) then
					PlaceAuctionBid(AuctionFrame.type, GetSelectedAuctionItem(AuctionFrame.type), AuctionFrame.buyoutPrice)
				end--]]
				
				local currentTime, browseClicked = GetTime(), self:GetID()
				if lastClickTime and (currentTime - lastClickTime) < 0.5 and lastBrowseClicked and lastBrowseClicked == browseClicked then
					PlaceAuctionBid(AuctionFrame.type, GetSelectedAuctionItem(AuctionFrame.type), AuctionFrame.buyoutPrice)

					lastBrowseClicked = nil
					lastClick = nil
				else
					browseButtonOnClick(self)

					lastBrowseClicked = browseClicked
					lastClickTime = currentTime
				end
			end)
		end

	end)
end