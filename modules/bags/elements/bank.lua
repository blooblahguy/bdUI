local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Bags")
local config
local bordersize = 2

--==============================================
-- BANK CREATION
--==============================================
function mod:create_bank()
	config = mod:get_save()

	mod:setup(mod.bank)

	mod:create_bank_bags()
	mod:create_bank_tabs()
	mod:create_bank_search()
	mod:create_bank_money()

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
					mod.onreagents = true
					mod:quickbank(false)
					mod:quickreagent(true)
					mod.bank.tab2.text:SetTextColor(1,1,1)
					mod.bank.tab1.text:SetTextColor(.4,.4,.4)
				else
					-- Redraw bank in rank
					mod.onreagents = false
					mod:quickbank(true)
					mod.bank.tab1.text:SetTextColor(1,1,1)
					mod.bank.tab2.text:SetTextColor(.4,.4,.4)
				end
			else
				panel:Hide()
			end
		end
	end
end

--==============================================
-- BANK BAGS CONTAINER
--==============================================
function mod:create_bank_bags()
	local lastbutton = nil
	for i = 1, 7 do
		local bankbag = BankSlotsFrame["Bag"..i]
		if (not bankbag) then break end
		local icon = bankbag.icon
		
		bankbag:SetParent(mod.bank.bags)
		bankbag:GetChildren():Hide()
		bankbag:ClearAllPoints()
		bankbag:SetWidth(24)
		bankbag:SetHeight(24)
		
		if lastbutton then
			bankbag:SetPoint("LEFT", lastbutton, "RIGHT", bordersize, 0)
		else
			bankbag:SetPoint("TOPLEFT", mod.bank.bags, "TOPLEFT", 8, -8)
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
		
		mod.bank.bags:SetWidth((24+bordersize)*(7)+16)
		mod.bank.bags:SetHeight(40)
	end

	-- set purchase slot button
	local function checkpurchasable()
		local cost = GetBankSlotCost()
		if (cost < 999999999) then
			mod.bank.purchase:Show()
		else
			mod.bank.purchase:Hide()
		end
	end
	mod.bank.purchase = CreateFrame("Button",nil,mod.bank.bags)
	mod.bank.purchase:SetSize(24, 24)
	bdUI:set_backdrop(mod.bank.purchase)
	mod.bank.purchase:SetPoint("CENTER",lastbutton,"CENTER",0,0)
	mod.bank.purchase:SetFrameLevel(27)
	mod.bank.purchase:Hide()
	mod.bank.purchase.text = mod.bank.purchase:CreateFontString(nil)
	mod.bank.purchase.text:SetFont(bdUI.media.font,20)
	mod.bank.purchase.text:SetText("+")
	mod.bank.purchase.text:SetTextColor(.3,.3,.3)
	mod.bank.purchase.text:SetPoint("CENTER", mod.bank.purchase,"CENTER",0,0)
	mod.bank.purchase:SetScript("OnEnter",function(self) 
		mod.bank.purchase.text:SetTextColor(1,1,1)
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
		GameTooltip:SetText("Purchase a bag slot")
	end)
	mod.bank.purchase:SetScript("OnLeave",function() 
		mod.bank.purchase.text:SetTextColor(.3,.3,.3)
		GameTooltip:Hide()
	end)
	mod.bank.purchase:SetScript("OnClick",function() 
		BankFramePurchaseButton:Click()
		checkpurchasable()
	end)
	mod.bank:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED")
	mod.bank:RegisterEvent("PLAYER_ENTERING_WORLD")
	mod.bank:SetScript("OnEvent", checkpurchasable)
end

--==============================================
-- REAGENT/TABS
--==============================================
function mod:create_bank_tabs()
	if (bdUI:get_game_version() == "vanilla") then return end
	mod.bank.tab1 = CreateFrame("frame", nil, mod.bank)
	mod.bank.tab2 = CreateFrame("frame", nil, mod.bank)

	local tab1, tab2 = mod.bank.tab1, mod.bank.tab2

	tab1:SetPoint("BOTTOM", mod.bank, "TOP", -21, -2)
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

	tab2:SetPoint("BOTTOM", mod.bank, "TOP", 31, -2)
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
		if not tab then break end
		bdUI:strip_textures(tab)
		tab:ClearAllPoints()
		tab:Hide()
	end

	local unlock = CreateFrame("frame",nil,mod.bank)
	unlock:SetAllPoints(mod.bank)
	unlock:SetSize(300,300)
	unlock:SetFrameLevel(20)
	unlock:SetBackdrop({bgFile = bdUI.media.flat})
	unlock:SetBackdropColor(0,0,0,.6)
	unlock.button = CreateFrame("Button",nil,unlock)
	unlock.button:SetSize(120,30)
	unlock.button:SetPoint("CENTER", unlock, "CENTER")
	unlock.button:SetText("Unlock Reagent Bank")
	bdUI:skin_button(unlock.button, false, "blue")

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

	mod.bank.unlock = unlock
end


function mod:quickreagent(show)
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
		mod:skin(item)
		
		if (not lastitem) then
			item:SetPoint("TOPLEFT", mod.bank, "TOPLEFT", 10, -30)
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
	
	mod.bank:SetHeight(40+(config.bankbuttonsize-bordersize)*(numrows+1))
	mod.bank:SetWidth(20+(config.bankbuttonsize-bordersize)*(config.bankbuttonsperrow))

	local children = {ReagentBankFrame:GetChildren()}
	children[1]:ClearAllPoints()
	children[1]:SetPoint("BOTTOM", mod.bank, "BOTTOM", 0, 10)
	children[1]:SetFrameStrata("HIGH")
	children[1]:SetFrameLevel(3)
	
	if (not IsReagentBankUnlocked()) then
		mod.bank.unlock:Show()
	else
		mod.bank.unlock:Hide()
		mod.bank.unlock.Show = function() return end
	end
	
	if (show) then
		ReagentBankFrame:SetFrameLevel(2)
		mod.bank:SetFrameLevel(1)
	else
		ReagentBankFrame:SetFrameLevel(1)
		mod.bank:SetFrameLevel(2)
	end
end

function mod:quickbank(show)
	if (show) then
		mod:bank_generation()
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
		mod.bank:SetFrameLevel(2)
	else
		ReagentBankFrame:SetFrameLevel(2)
		mod.bank:SetFrameLevel(1)
	end
	
	mod.bank.unlock:Hide()
end

function mod:create_bank_money()
	ContainerFrame2MoneyFrame:Show()
	ContainerFrame2MoneyFrame:ClearAllPoints()
	ContainerFrame2MoneyFrame:SetPoint("TOPLEFT", mod.bank, "TOPLEFT", 11, -8)
	ContainerFrame2MoneyFrame:SetFrameStrata("HIGH")
	ContainerFrame2MoneyFrame:SetFrameLevel(2)
	ContainerFrame2MoneyFrame:SetParent(mod.bank)
	local money = {"Gold","Silver","Copper"}
	for k, v in pairs(money) do
		_G["ContainerFrame2MoneyFrame"..v.."ButtonText"]:SetFont(bdUI.media.font,14)
	end
end

function mod:create_bank_search()
	hooksecurefunc("ContainerFrame_Update", function(frame, id)
		BankItemSearchBox:ClearAllPoints()
		BankItemSearchBox:SetParent(mod.bank)
		BankItemSearchBox:SetPoint("TOPRIGHT", mod.bank, "TOPRIGHT", -48, -6)
		BankItemAutoSortButton:Hide();
		
		mod:SkinEditBox(BankItemSearchBox)
	end)
end


function mod:bank_generation(...)
	local numrows, lastrowitem, numitems, lastitem = 0, nil, 0, nil
	
	-- bank frames
	for index = 1, 28 do
		local item = _G["BankFrameItem"..index]
		if (item) then
			item:ClearAllPoints()
			item:SetWidth(config.bankbuttonsize)
			item:SetHeight(config.bankbuttonsize)
			item:Show()
			mod:skin(item)
			
			if index == 1 then
				item:SetPoint("TOPLEFT", mod.bank, "TOPLEFT", 10, -30)
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
			mod:skin(item)
			
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
	mod.bank:SetHeight(40+(config.bankbuttonsize-bordersize)*(numrows+1))
	mod.bank:SetWidth(20+(config.bankbuttonsize-bordersize)*(config.bankbuttonsperrow))
end