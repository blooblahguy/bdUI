local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("New Bags")

if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then return end

MAX_WATCHED_TOKENS = 10
for i = 3, MAX_WATCHED_TOKENS do
	local frame = CreateFrame("button", "BackpackTokenFrameToken"..i, BackpackTokenFrame, "BackpackTokenTemplate")
	BackpackTokenFrame.Tokens[i] = frame
end

function mod:create_currencies(name, parent)
	-- local name, isHeader, isExpanded, isUnused, isWatched, count, extraCurrencyType, icon, itemID = GetCurrencyListInfo(i)

	local currencies = CreateFrame("frame", nil, parent)
	currencies:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
	currencies:RegisterEvent("PLAYER_ENTERING_WORLD")
	currencies:SetScript("OnEvent", currencies.update)
	currencies:SetSize(200, 30)
	currencies.watchers = {}
	
	local texture = currencies:CreateTexture(nil, "OVERLAY")

	local last = nil
	for i = 1, MAX_WATCHED_TOKENS do
		local currency = CreateFrame("button", nil, currencies)
		currency:SetHeight(20)
		currency.text = currency:CreateFontString(nil, "OVERLAY")
		currency.text:SetFont(bdUI.media.font, 12, "OUTLINE")
		currency.text:SetPoint("LEFT")

		currency.icon = currency:CreateTexture(nil, "OVERLAY")
		currency.icon:SetPoint("LEFT", currency.text, "RIGHT", 5, 1)
		currency.icon:SetSize(16, 16)
		currency.icon:SetTexCoord(.07, .93, .07, .93)

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

		if (not last) then
			currency:SetPoint("LEFT", currencies, "LEFT", 0, 0)
		else
			currency:SetPoint("LEFT", last, "RIGHT", 10, 0)
		end

		last = currency
		currencies.watchers[i] = currency
	end

	function currencies:update()
		for i = 1, MAX_WATCHED_TOKENS do
			currencies.watchers[i]:Hide()
		end

		local index = 1
		for i = 1, GetCurrencyListSize() do
			local name, isHeader, isExpanded, isUnused, isWatched, count, icon, itemID = GetCurrencyListInfo(i)

			if (isWatched) then
				local frame = currencies.watchers[index]

				frame:Show()
				frame:SetText(AbbreviateLargeNumbers(count))
				frame.icon:SetTexture(icon)
				frame.currencyID = i

				index = index + 1
			end
			if (index == MAX_WATCHED_TOKENS) then break end
		end
	end

	hooksecurefunc("BackpackTokenFrame_Update", currencies.update)

	currencies:update()

	return currencies
end