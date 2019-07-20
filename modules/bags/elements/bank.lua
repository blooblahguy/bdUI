local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Bags")
local config

function mod:create_bank_tabs()
	-- reagent tabs
	for i = 1, 2 do
		local tab = _G["BankFrameTab"..i]
		bdUI:strip_textures(tab)
		tab:ClearAllPoints()
		tab:Hide()
	end
end
function mod:create_bank()
	config = mod._config
end

-- place bank slots in bank bag container
local lastbutton = nil
for i = 1, 7 do
	local bankbag = BankSlotsFrame["Bag"..i]
	local icon = bankbag.icon
	
	bankbag:SetParent(core.bank.bags)
	bankbag:GetChildren():Hide()
	bankbag:ClearAllPoints()
	bankbag:SetWidth(24)
	bankbag:SetHeight(24)
	
	if lastbutton then
		bankbag:SetPoint("LEFT", lastbutton, "RIGHT", bordersize, 0)
	else
		bankbag:SetPoint("TOPLEFT", core.bank.bags, "TOPLEFT", 8, -8)
	end
	lastbutton = bankbag
	bdUI:set_backdrop(bankbag)
	
	bankbag:SetNormalTexture("")
	bankbag:SetPushedTexture("")
	bankbag:SetHighlightTexture("")
	bankbag.IconBorder:SetTexture("")
	
	bdUI:strip_textures(bankbag)
	
	icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	
	if highlight and not highlight.skinned then
		highlight:SetTexture(1, 1, 1, 0.3)
		highlight:SetTexture("")
		highlight:ClearAllPoints()
		highlight:SetPoint("TOPLEFT", 2, -2)
		highlight:SetPoint("BOTTOMRIGHT", -2, 2)
		highlight.skinned = true
	end
	
	core.bank.bags:SetWidth((24+bordersize)*(7)+16)
	core.bank.bags:SetHeight(40)
end
-- set purchase slot button
local function checkpurchasable()
	local cost = GetBankSlotCost()
	if (cost < 999999999) then
		core.bank.purchase:Show()
	else
		core.bank.purchase:Hide()
	end
end
core.bank.purchase = CreateFrame("Button",nil,core.bank.bags)
core.bank.purchase:SetSize(24, 24)
bdUI:set_backdrop(core.bank.purchase)
core.bank.purchase:SetPoint("CENTER",lastbutton,"CENTER",0,0)
core.bank.purchase:SetFrameLevel(27)
core.bank.purchase:Hide()
core.bank.purchase.text = core.bank.purchase:CreateFontString(nil)
core.bank.purchase.text:SetFont(bdUI.media.font,20)
core.bank.purchase.text:SetText("+")
core.bank.purchase.text:SetTextColor(.3,.3,.3)
core.bank.purchase.text:SetPoint("CENTER", core.bank.purchase,"CENTER",0,0)
core.bank.purchase:SetScript("OnEnter",function(self) 
	core.bank.purchase.text:SetTextColor(1,1,1)
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
	GameTooltip:SetText("Purchase a bag slot")
end)
core.bank.purchase:SetScript("OnLeave",function() 
	core.bank.purchase.text:SetTextColor(.3,.3,.3)
	GameTooltip:Hide()
end)
core.bank.purchase:SetScript("OnClick",function() 
	BankFramePurchaseButton:Click()
	checkpurchasable()
end)
core.addon:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED")
core.addon:RegisterEvent("PLAYER_ENTERING_WORLD")
core.addon:SetScript("OnEvent",function() checkpurchasable() end)

------------------------------------
-- tab/reagent tab		
------------------------------------
local unlock = CreateFrame("frame",nil,core.bank)
unlock:SetAllPoints(core.bank)
--unlock:SetFrameStrata("TOOLTIP")
unlock:SetSize(300,300)
unlock:SetFrameLevel(20)
unlock:SetBackdrop({bgFile = bdUI.media.flat})
unlock:SetBackdropColor(0,0,0,.6)
unlock.button = CreateFrame("Button",nil,unlock)
unlock.button:SetSize(120,30)
unlock.button:SetPoint("CENTER", unlock, "CENTER")
unlock.button:SetText("Unlock Reagent Bank")
bdUI:skinButton(unlock.button, false, "blue")

unlock.button:SetScript("OnClick",function()
	ReagentBankFrameUnlockInfoPurchaseButton:Click()
end)

unlock:RegisterEvent("REAGENTBANK_PURCHASED")
unlock:RegisterEvent("PLAYER_ENTERING_WORLD")
unlock:SetScript("OnEvent",function(self,event,arg1) 
	if (event == "PLAYER_ENTERING_WORLD" and not IsReagentBankUnlocked()) then
		unlock:Show()
	else
		unlock:Hide()
		unlock.Show = function() return end
	end
end)
local tab1 = CreateFrame("frame", nil, core.bank)
local tab2 = CreateFrame("frame", nil, core.bank)

tab1:SetPoint("BOTTOM", core.bank, "TOP", -21, -2)
tab1:SetSize(40, 24)
tab1:SetFrameLevel(25)
bdUI:set_backdrop(tab1)
tab1.text = tab1:CreateFontString("button")
tab1.text:SetPoint("CENTER", tab1, "CENTER", 2, 0)
tab1.text:SetJustifyH("CENTER")
tab1.text:SetFont(bdUI.media.font, 12, "OUTLINE")
tab1.text:SetText("Bank")
tab1.text:SetTextColor(1, 1, 1)
tab1:SetScript("OnMouseUp", function(self) 
	BankFrameTab1:Click()
	tab1.text:SetTextColor(1, 1, 1)
	tab2.text:SetTextColor(.4,.4,.4)
end)

tab2:SetPoint("BOTTOM", core.bank, "TOP", 31, -2)
tab2:SetSize(60, 24)
tab2:SetFrameLevel(25)
bdUI:set_backdrop(tab2)
tab2.text = tab2:CreateFontString("button")
tab2.text:SetPoint("CENTER", tab2, "CENTER", 2, 0)
tab2.text:SetJustifyH("CENTER")
tab2.text:SetFont(bdUI.media.font, 12, "OUTLINE")
tab2.text:SetText("Reagents")
tab2.text:SetTextColor(.4,.4,.4)
tab2:SetScript("OnMouseUp", function(self) 
	BankFrameTab2:Click()
	tab2.text:SetTextColor(1, 1, 1)
	tab1.text:SetTextColor(.4,.4,.4)
end)

for i = 1, 2 do
	local tab = _G["BankFrameTab"..i]
	bdUI:strip_textures(tab)
	tab:ClearAllPoints()
	tab:Hide()
end

-- I have to keep stealing blizzard functions, because they are doing so far from what I want they are actually making bag coding near impossible. 
function BankFrame_ShowPanel(sidePanelName, selection)
	local self = BankFrame;
	-- find side panel
	local tabIndex;
	
	ShowUIPanel(self);
	for index, data in pairs(BANK_PANELS) do
		local panel = _G[data.name];

		if ( data.name == sidePanelName ) then
			panel:Show()
			tabIndex = index;
			self.activeTabIndex = tabIndex;
			
			if (data.name == "ReagentBankFrame") then
				-- Redraw reagent in bank
				core.onreagents = true
				core:quickbank(false)
				core:quickreagent(true)
				tab2.text:SetTextColor(1,1,1)
				tab1.text:SetTextColor(.4,.4,.4)
			else
				-- Redraw bank in rank
				core.onreagents = false
				core:quickbank(true)
				tab1.text:SetTextColor(1,1,1)
				tab2.text:SetTextColor(.4,.4,.4)
			end
		else
			panel:Hide()
		end
	end
end
function core:quickreagent(show)
	local numrows, lastrowitem, numitems, lastitem = 0, nil, 1, nil
	for i = 1, 98 do
		--print(i)
		local item = _G["ReagentBankFrameItem"..i]
		if (not item) then return end
		item:ClearAllPoints()
		item:SetWidth(config.bankbuttonsize)
		item:SetHeight(config.bankbuttonsize)
		item:SetFrameStrata("HIGH")
		item:SetFrameLevel(2)
		core:Skin(item)
		
		if (not lastitem) then
			item:SetPoint("TOPLEFT", core.bank, "TOPLEFT", 10, -30)
			lastrowitem = item
		else
			item:SetPoint("LEFT", lastitem, "RIGHT", -bordersize,0)
			if (numitems > config.bankbuttonsperrow) then
				item:ClearAllPoints()
				item:SetPoint("TOP", lastrowitem, "BOTTOM", 0, bordersize)
				lastrowitem = item
				numrows = numrows + 1
				numitems = 1
			end
		end
		numitems = numitems + 1
		lastitem = item
		
	end

	ReagentBankFrameUnlockInfo:Hide()
	
	core.bank:SetHeight(40+(config.bankbuttonsize-bordersize)*(numrows+1))
	core.bank:SetWidth(20+(config.bankbuttonsize-bordersize)*(config.bankbuttonsperrow))

	local children = {ReagentBankFrame:GetChildren()}
	children[1]:ClearAllPoints()
	children[1]:SetPoint("BOTTOM", core.bank, "BOTTOM", 0, 10)
	children[1]:SetFrameStrata("HIGH")
	children[1]:SetFrameLevel(3)
	
	if (not IsReagentBankUnlocked()) then
		unlock:Show()
	else
		unlock:Hide()
		unlock.Show = function() return end
	end
	
	if (show) then
		ReagentBankFrame:SetFrameLevel(2)
		core.bank:SetFrameLevel(1)
	else
		ReagentBankFrame:SetFrameLevel(1)
		core.bank:SetFrameLevel(2)
	end
end

function core:quickbank(show)
	if (show) then
		core:bankGenerate()
	else
		for i = 1, 28 do
			_G["BankFrameItem"..i]:Hide()
		end
		for b = 6, 12 do
			local slots = GetContainerNumSlots(b-1)
			if (slots < 40) then slots = 40 end
			for t = 1, slots do
				if (_G["ContainerFrame"..b.."Item"..t]) then
					_G["ContainerFrame"..b.."Item"..t]:Hide()
				end
			end
		end
	end
	
	if (show) then
		ReagentBankFrame:SetFrameLevel(1)
		core.bank:SetFrameLevel(2)
	else
		ReagentBankFrame:SetFrameLevel(2)
		core.bank:SetFrameLevel(1)
	end
	
	unlock:Hide()
end



hooksecurefunc("ContainerFrame_Update", function(frame, id)
	BankItemSearchBox:ClearAllPoints()
	BankItemSearchBox:SetParent(core.bank)
	BankItemSearchBox:SetPoint("TOPRIGHT", core.bank, "TOPRIGHT", -48, -6)
	BankItemAutoSortButton:Hide();
	
	core:SkinEditBox(BankItemSearchBox)
end)

ContainerFrame2MoneyFrame:Show()
ContainerFrame2MoneyFrame:ClearAllPoints()
ContainerFrame2MoneyFrame:SetPoint("TOPLEFT", core.bank, "TOPLEFT", 11, -8)
ContainerFrame2MoneyFrame:SetFrameStrata("HIGH")
ContainerFrame2MoneyFrame:SetFrameLevel(2)
ContainerFrame2MoneyFrame:SetParent(core.bank)
local money = {"Gold","Silver","Copper"}
for k, v in pairs(money) do
	_G["ContainerFrame2MoneyFrame"..v.."ButtonText"]:SetFont(bdUI.media.font,14)
end

function core:bankGenerate(...)
	local numrows, lastrowitem, numitems, lastitem = 0, nil, 0, nil
	
	-- bank frames
	for index = 1, 28 do
		local item = _G["BankFrameItem"..index]
		item:ClearAllPoints()
		item:SetWidth(config.bankbuttonsize)
		item:SetHeight(config.bankbuttonsize)
		item:Show()
		core:Skin(item)
		
		if index == 1 then
			item:SetPoint("TOPLEFT", core.bank, "TOPLEFT", 10, -30)
			lastrowitem = item
		else
			item:SetPoint("LEFT", lastitem, "RIGHT", -bordersize,0)
			if (numitems == config.bankbuttonsperrow) then
				item:ClearAllPoints()
				item:SetPoint("TOP", lastrowitem, "BOTTOM", 0, bordersize)
				lastrowitem = item
				numrows = numrows + 1
				numitems = 0
			end
		end
		numitems = numitems + 1
		lastitem = item
	end
	
	-- bank bags
	for id = 6, 12 do
		local slots = GetContainerNumSlots(id-1)
		for index = 1, slots do
			local item = _G["ContainerFrame"..id.."Item"..index]
			item:ClearAllPoints()
			item:SetWidth(config.bankbuttonsize)
			item:SetHeight(config.bankbuttonsize)
			item:Show()
			core:Skin(item)
			
			item:SetPoint("LEFT", lastitem, "RIGHT", -bordersize,0)
			if (numitems == config.bankbuttonsperrow) then
				item:ClearAllPoints()
				item:SetPoint("TOP", lastrowitem, "BOTTOM", 0, bordersize)
				lastrowitem = item
				numrows = numrows + 1
				numitems = 0
			end
			numitems = numitems + 1
			lastitem = item
		end
	end
	core.bank:SetHeight(40+(config.bankbuttonsize-bordersize)*(numrows+1))
	core.bank:SetWidth(20+(config.bankbuttonsize-bordersize)*(config.bankbuttonsperrow))
end