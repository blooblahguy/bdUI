local bdUI, c, l = unpack(select(2, ...))
local fpmod = mod
local mod = bdUI:get_module("New Bags")

-- format money string
local function return_money(money)
	local gold = floor(abs(money / 10000))
	local silver = floor(abs(fpmod(money / 100, 100)))
	local copper = floor(abs(fpmod(money, 100)))

	local moneyString = "";
	if (gold > 0) then
		moneyString = BreakUpLargeNumbers(gold).."|cffF0D440g|r";
	end
	if (silver > 0) then
		moneyString = moneyString.." "..silver.."|cffC0C0C0s|r"
	end
	if (copper > 0) then
		moneyString = moneyString.." "..copper.."|cffFF8F32c|r"
	end
	
	return moneyString;
end

function mod:create_money(name, parent)
	local money = CreateFrame("button", "bd"..name.."Money", parent, "SmallMoneyFrameTemplate")
	
	for k, v in pairs({"Gold","Silver","Copper"}) do
		_G[money:GetName()..v.."ButtonText"]:SetFont(bdUI.media.font, 12)
		_G[money:GetName()..v.."Button"]:EnableMouse(false)
		_G[money:GetName()..v.."Button"]:SetFrameLevel(8)
	end

	-- update display & saved variable
	function money:update()
		local money = GetMoney()
		local name, r = UnitName("player")
		local class, classFileName = UnitClass("player")
		local color = RAID_CLASS_COLORS[classFileName]
		moneyString = GetMoneyString(money, true)
		
		BDUI_SAVE.persistent.goldtrack = BDUI_SAVE.persistent.goldtrack or {}
		BDUI_SAVE.persistent.goldtrack[name] = {money, color.colorStr}
	end
	money:RegisterEvent("PLAYER_ENTERING_WORLD")
	money:RegisterEvent("PLAYER_MONEY")
	money:HookScript("OnEvent", money.update)

	money:SetScript("OnEnter", function(self) 
		ShowUIPanel(GameTooltip)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -147, 10)
		
		local total = 0;
		for name, stored in pairs(BDUI_SAVE.persistent.goldtrack) do
			local money, cc = unpack(stored)
			total = total + money
		end
		total = GetMoneyString(total, true)
		GameTooltip:AddDoubleLine("Total Gold", total, 1,1,1, 1,1,1)
		GameTooltip:AddLine(" ")
		for name, stored in pairs(BDUI_SAVE.persistent.goldtrack) do
			local money, cc = unpack(stored)
			local moneystring = GetMoneyString(money, true)
			if (money == 0) then
				BDUI_SAVE.persistent.goldtrack[name] = nil
			else
				GameTooltip:AddDoubleLine("|c"..cc..name.."|r ",moneystring, 1,1,1, 1,1,1)
			end
		end	

		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(" ", "ctrl + shift + click to clear", 1, 1, 1, .3, .3, .3)
		GameTooltip:Show()
	end)
	money:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	money:SetScript("OnClick", function(self, ...)
		if (IsShiftKeyDown() and IsControlKeyDown()) then
			BDUI_SAVE.persistent.goldtrack = {}
			GameTooltip:Hide()
			self:update()
		end
	end)

	return money
end

