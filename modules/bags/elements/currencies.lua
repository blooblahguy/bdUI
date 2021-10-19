local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Bags")

-- if bdUI:isClassicAny() then return end

--============================================
-- allow for tracking beyond 3
--============================================
MAX_WATCHED_TOKENS = 10

--============================================
-- Currency object
--============================================
local currencies = {}
currencies.watchers = {}

--============================================
-- Currency updates
--============================================
function mod:currencies_update()
	if (not C_CurrencyInfo) then 
		currencies:SetHeight(10)
		return
	end

	for i = 1, MAX_WATCHED_TOKENS do
		if (currencies.watchers[i]) then
			currencies.watchers[i]:Hide()
		end
	end

	local index = 1
	local last = nil
	local lastrow = nil
	local maxwidth = mod.bags:GetWidth() - 40
	local newheight = 10
	local rowwidth = 0
	currencies:SetSize(maxwidth, 30)

	for i = 1, C_CurrencyInfo.GetCurrencyListSize() do
		local currency = C_CurrencyInfo.GetCurrencyListInfo(i)

		if (currency.isShowInBackpack) then
			local frame = currencies.watchers[index]

			frame:Show()
			frame:ClearAllPoints()
			frame:SetText(AbbreviateLargeNumbers(currency.quantity))
			frame.icon:SetTexture(currency.iconFileID)
			frame.currencyID = i
			rowwidth = rowwidth + frame:GetWidth() + 10

			if (not last) then
				frame:SetPoint("TOPLEFT", currencies, "TOPLEFT", 5, 0)
				lastrow = frame
				newheight = newheight + frame:GetHeight()
			elseif (rowwidth > maxwidth) then
				rowwidth = 0
				frame:SetPoint("TOPLEFT", lastrow, "BOTTOMLEFT", 0, -0)
				lastrow = frame
				newheight = newheight + frame:GetHeight() + 0
			else
				frame:SetPoint("LEFT", last, "RIGHT", 10, 0)
			end

			last = frame
			index = index + 1
		end

		if (index == MAX_WATCHED_TOKENS) then break end
	end

	-- currencies:SetHeight(newheight)
	-- mod.bags.footer:SetPoint("TOPLEFT", mod.bags, "BOTTOMLEFT", 0, newheight - 5)
	-- mod.bags.footer:SetPoint("TOPRIGHT", mod.bags, "BOTTOMRIGHT", 0, newheight - 5)

	currencies:SetHeight(newheight)

	mod:update_bags()
end


--============================================
-- Create the appropriate # of currency trackers
--============================================
function mod:create_currencies()
	currencies = CreateFrame("frame", "bdBags_Currencies", mod.bags)
	currencies.watchers = {}
	
	if (not C_CurrencyInfo) then return currencies end

	for i = 3, MAX_WATCHED_TOKENS do
		local frame = CreateFrame("button", "BackpackTokenFrameToken"..i, BackpackTokenFrame, "BackpackTokenTemplate")
		BackpackTokenFrame.Tokens[i] = frame
	end
	currencies:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
	currencies:RegisterEvent("PLAYER_ENTERING_WORLD")
	currencies:SetScript("OnEvent", mod.currencies_update)
	currencies:SetSize(200, 30)
	currencies:SetPoint("BOTTOMLEFT", mod.bags, "BOTTOMLEFT", mod.spacing * .75, 0)

	local last = nil
	for i = 1, MAX_WATCHED_TOKENS do
		local currency = CreateFrame("button", nil, currencies)
		currency:SetHeight(20)

		currency.icon = currency:CreateTexture(nil, "OVERLAY")
		currency.icon:SetPoint("LEFT")
		currency.icon:SetSize(16, 16)
		currency.icon:SetTexCoord(.07, .93, .07, .93)
		currency.text = currency:CreateFontString(nil, "OVERLAY")
		currency.text:SetFontObject(bdUI:get_font(13))
		currency.text:SetPoint("LEFT", currency.icon, "RIGHT", 5, -1)

		local bg = currency:CreateTexture(nil, "BORDER")
		bg:SetPoint("TOPLEFT", currency.icon, "TOPLEFT", -mod.border, mod.border)
		bg:SetPoint("BOTTOMRIGHT", currency.icon, "BOTTOMRIGHT", mod.border, -mod.border)
		bg:SetTexture(bdUI.media.flat)
		bg:SetVertexColor(unpack(bdUI.media.border))

		function currency:SetText(text)
			currency.text:SetText(text)
			currency:SetWidth(currency.text:GetWidth() + 24)
		end

		currency:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetCurrencyToken(self.currencyID)
		end)
		currency:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)

		currencies.watchers[i] = currency
	end

	mod.bags.currencies = currencies

	mod:currencies_update()
	hooksecurefunc("BackpackTokenFrame_Update", mod.currencies_update)

	return currencies
end