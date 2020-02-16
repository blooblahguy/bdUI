local bdUI, c, l = unpack(select(2, ...))
local fpmod = mod
local mod = bdUI:get_module("Bags")
local config

local floor, abs = math.floor, math.abs

--======================================
-- SKIN BLIZZARD
--======================================
function mod:skin_blizzard()
	ContainerFrame1MoneyFrame:ClearAllPoints()
	ContainerFrame1MoneyFrame:Show()
	ContainerFrame1MoneyFrame:SetPoint("TOPLEFT", mod.bags, "TOPLEFT", 11, -8)
	ContainerFrame1MoneyFrame:SetParent(mod.bags)
	BackpackTokenFrameToken1:ClearAllPoints()
	BackpackTokenFrameToken1:SetPoint("BOTTOMLEFT", mod.bags, "BOTTOMLEFT", 0, 8)
end

--======================================
-- CREATE BAGS
--======================================
function mod:create_bags()
	config = mod:get_save()

	SetSortBagsRightToLeft(false)
	SetInsertItemsLeftToRight(false)

	-- Creation Functions
	mod:setup(mod.bags)
	mod:create_moneyframe()
	mod:bag_slots()
	mod:bag_search()

	-- Disable Aurora Bags
	local aurora = select(1, IsAddOnLoaded("Aurora"))
	if (aurora) then
		local F, C = unpack(Aurora or FreeUI)
		C.defaults['bags'] = false
	end
end

-- place bag slots in bag container
function mod:bag_slots()
	mod.bagslots = {
		CharacterBag0Slot,
		CharacterBag1Slot,
		CharacterBag2Slot,
		CharacterBag3Slot
	}

	if (BackpackTokenFrameToken1) then
		BackpackTokenFrameToken1:ClearAllPoints()
		BackpackTokenFrameToken1:SetPoint("BOTTOMLEFT", mod.bags, "BOTTOMLEFT", 0, 8)
		for i = 1, 3 do
			_G["BackpackTokenFrameToken"..i]:SetFrameStrata("TOOLTIP")
			_G["BackpackTokenFrameToken"..i]:SetFrameLevel(5)
			_G["BackpackTokenFrameToken"..i.."Icon"]:SetSize(12,12) 
			_G["BackpackTokenFrameToken"..i.."Icon"]:SetTexCoord(.1,.9,.1,.9) 
			_G["BackpackTokenFrameToken"..i.."Icon"]:SetPoint("LEFT", _G["BackpackTokenFrameToken"..i], "RIGHT", -8, 2) 
			_G["BackpackTokenFrameToken"..i.."Count"]:SetFont(bdUI.media.font, 14)
			if (i ~= 1) then
				_G["BackpackTokenFrameToken"..i]:SetPoint("LEFT", _G["BackpackTokenFrameToken"..(i-1)], "RIGHT", 10, 0)
			end
		end
	end

	for k, f in pairs(mod.bagslots) do
		local bordersize = bdUI:get_border(f)
		local count = _G[f:GetName().."Count"]
		local icon = _G[f:GetName().."IconTexture"]
		local norm = _G[f:GetName().."NormalTexture"]
		f:SetParent(mod.bags.bags)
		
		f:ClearAllPoints()
		f:SetWidth(24)
		f:SetHeight(24)
		
		norm:SetAllPoints(f)
		if lastbutton then
			f:SetPoint("LEFT", lastbutton, "RIGHT", bordersize, 0)
		else
			f:SetPoint("TOPLEFT", mod.bags.bags, "TOPLEFT", 8, -8)
		end
		count.Show = function() end
		count:Hide()
		
		bdUI:set_backdrop(f)
		bdUI:strip_textures(f)
		f:SetNormalTexture("")
		f:SetPushedTexture("")
		f:SetHighlightTexture("")
		f.IconBorder:SetTexture("")

		icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

		lastbutton = f
		mod.bags.bags:SetWidth((24+bordersize)*(getn(mod.bagslots))+16)
		mod.bags.bags:SetHeight(40)
	end
end

-- search boxes
local function position_search(self, id)
	if (not BagItemSearchBox) then return end
	BagItemSearchBox:ClearAllPoints()
	BagItemSearchBox:SetPoint("LEFT", ContainerFrame1MoneyFrame, "RIGHT", 8, 0)
	BagItemSearchBox.ClearAllPoints = noop
	BagItemSearchBox.SetPoint = noop
	BagItemSearchBox:SetWidth(200)
	BagItemAutoSortButton:Hide();
	
	mod:SkinEditBox(BagItemSearchBox)
end
function mod:bag_search()
	hooksecurefunc("ContainerFrame_Update", position_search)
	position_search()
end
	
function mod:create_moneyframe()

	ContainerFrame1MoneyFrame:SetScript("OnEnter", function(self) 
		ShowUIPanel(GameTooltip)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -147, 10)
		
		local total = 0;
		for name, stored in pairs(bdUI.persistent.goldtrack) do
			local money, cc = unpack(stored)
			total = total + money
		end
		total = ContainerFrame1MoneyFrame:returnMoney(total)
		GameTooltip:AddDoubleLine("Total Gold",total,1,1,1, 1,1,1)
		GameTooltip:AddLine(" ")
		for name, stored in pairs(bdUI.persistent.goldtrack) do
			local money, cc = unpack(stored)
			local moneystring = ContainerFrame1MoneyFrame:returnMoney(money)
			GameTooltip:AddDoubleLine("|c"..cc..name.."|r ",moneystring,1,1,1, 1,1,1)
		end	

		GameTooltip:Show()
	end)
	ContainerFrame1MoneyFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	function ContainerFrame1MoneyFrame:returnMoney(money)
		local gold = floor(abs(money / 10000))
		local silver = floor(abs(fpmod(money / 100, 100)))
		local copper = floor(abs(fpmod(money, 100)))
		

		local moneyString = "";
		if (gold > 0) then
			moneyString = mod:comma_value(gold).."|cffF0D440g|r";
		end
		if (silver > 0) then
			moneyString = moneyString.." "..silver.."|cffC0C0C0s|r"
		end
		if (copper > 0) then
			moneyString = moneyString.." "..copper.."|cffFF8F32c|r"
		end
		
		return moneyString;
	end

	function ContainerFrame1MoneyFrame:Update()
		local money = GetMoney()
		local name, r = UnitName("player")
		local class, classFileName = UnitClass("player")
		local color = RAID_CLASS_COLORS[classFileName]
		moneyString = ContainerFrame1MoneyFrame:returnMoney(money)
		
		bdUI.persistent.goldtrack = bdUI.persistent.goldtrack or {}
		bdUI.persistent.goldtrack[name] = {money, color.colorStr}
	end

	

	local money = {"Gold","Silver","Copper"}
	for k, v in pairs(money) do
		_G["ContainerFrame1MoneyFrame"..v.."ButtonText"]:SetFont(bdUI.media.font, 14)
		_G["ContainerFrame1MoneyFrame"..v.."Button"]:EnableMouse(false)
		_G["ContainerFrame1MoneyFrame"..v.."Button"]:SetFrameLevel(8)
	end

	ContainerFrame1MoneyFrame:ClearAllPoints()
	ContainerFrame1MoneyFrame:Show()
	ContainerFrame1MoneyFrame:SetPoint("TOPLEFT", mod.bags, "TOPLEFT", 11, -8)
	ContainerFrame1MoneyFrame:SetParent(mod.bags)
	ContainerFrame1MoneyFrame:SetFrameLevel(10)
	ContainerFrame1MoneyFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	ContainerFrame1MoneyFrame:RegisterEvent("PLAYER_MONEY")
	ContainerFrame1MoneyFrame:HookScript("OnEvent", ContainerFrame1MoneyFrame.Update)
end

function mod:bag_generation(...)
	if (mod.disabled) then return end
	local bordersize = bdUI.border

	local numrows, lastrowitem, numitems, lastitem = 0, nil, 0, nil
	for bagID = 0, 4 do
		local numSlots = GetContainerNumSlots(bagID)

		local start, finish, step = 1, numSlots, 1
		if (bagID == 0) then
			start, finish, step = numSlots, 1, -1
		end
		for slot = start, finish, step do
			local texture, itemCount, locked, quality, readable, lootable, itemLink = GetContainerItemInfo(bagID, slot);

			local item = _G["ContainerFrame"..(bagID+1).."Item"..slot]

			if (item) then
				item:ClearAllPoints()

				item:SetWidth(config.buttonsize)
				item:SetHeight(config.buttonsize)
				mod:skin(item)
				
				if (not lastitem) then
					item:SetPoint("TOPLEFT", mod.bags, "TOPLEFT", 10, -30)
					lastrowitem = item
				else
					item:SetPoint("LEFT", lastitem, "RIGHT", -bordersize,0)
					if (numitems == config.buttonsperrow) then
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
	end
	
	-- set bag and bank height
	mod.bags:SetHeight(64+(config.buttonsize-bordersize)*(numrows+1))
	mod.bags:SetWidth(20+(config.buttonsize-bordersize)*(config.buttonsperrow))
end

