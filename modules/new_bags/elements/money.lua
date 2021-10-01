local bdUI, c, l = unpack(select(2, ...))
local fpmod = mod
local mod = bdUI:get_module("Bags (beta)")

-- format money string
local function break_money(money)
	local gold = floor(abs(money / 10000))
	local silver = floor(abs(fpmod(money / 100, 100)))
	local copper = floor(abs(fpmod(money, 100)))

	return gold, silver, copper
end
local function return_money(money)
	local gold, silver, copper = break_money(money)

	local moneyString = "";
	if (gold > 0) then
		moneyString = BreakUpLargeNumbers(gold).."|cffF0D440g|r";
	end
	-- if (silver > 0) then
	-- 	moneyString = moneyString.." "..silver.."|cffC0C0C0s|r"
	-- end
	-- if (copper > 0) then
	-- 	moneyString = moneyString.." "..copper.."|cffFF8F32c|r"
	-- end
	
	return moneyString;
end

local methods = {
	["onenter"] = function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -147, 10)
		mod.gold = BDUI_SAVE.persistent.goldtrack

		if (#mod.gold == 0) then return end

		local total = 0;
		for name, stored in pairs(mod.gold) do
			local money, cc, name = unpack(stored)
			total = total + money
		end
		total = return_money(total, true)
		GameTooltip:AddDoubleLine("Total Gold", total, 1,1,1, 1,1,1)
		GameTooltip:AddLine(" ")

		table.sort(mod.gold, function(a, b)
			return a[1] < b[1]
		end)

		for name, stored in pairs(mod.gold) do
			-- local stored = mod.gold[i]
			local money, cc, name = unpack(stored)
			local moneystring = return_money(money, true)
			
			GameTooltip:AddDoubleLine("|c"..cc..name.."|r ",moneystring, 1,1,1, 1,1,1)
		end	

		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(" ", "ctrl + shift + click to clear", 1, 1, 1, .3, .3, .3)
		GameTooltip:Show()
	end,
	["onleave"] = function(self)
		GameTooltip:Hide()
	end,
	["update"] = function(self)
		BDUI_SAVE.persistent.goldtrack = BDUI_SAVE.persistent.goldtrack or {}
		mod.gold = BDUI_SAVE.persistent.goldtrack

		local money = GetMoney()

		local gold, silver, copper = break_money(money)
		

		local moneyString = ""
		-- if (gold > 100) then
			-- moneyString = "|cffF0D440"..BreakUpLargeNumbers(gold).."|r"
		-- else
			-- moneyString = "|"...."|r"
			moneyString = BreakUpLargeNumbers(gold).."|cffF0D440g|r"
			moneyString = moneyString.." "..silver.."|cffC0C0C0s|r"
			moneyString = moneyString.." "..copper.."|cffFF8F32c|r"
		-- end

		self.text:SetText(moneyString)
		self:SetWidth(self.text:GetStringWidth() + 8)

		local name, r = UnitName("player")
		local class, classFileName = UnitClass("player")
		local color = RAID_CLASS_COLORS[classFileName]

		mod.gold[name] = {money, color.colorStr, name}
	end,
	["click"] = function(self)
		if (IsShiftKeyDown() and IsControlKeyDown()) then
			BDUI_SAVE.persistent.goldtrack = {}
			GameTooltip:Hide()
			self:update()
		end
	end,
}

function mod:create_money(name, parent)
	local money = CreateFrame("button", "bd"..name.."Money", parent)
	money:SetSize(200, 10)
	Mixin(money, methods)

	money.text = money:CreateFontString(nil, "OVERLAY")
	money.text:SetFontObject(bdUI:get_font(13))
	money.text:SetPoint("LEFT", money)

	money:RegisterEvent("PLAYER_ENTERING_WORLD")
	money:RegisterEvent("PLAYER_MONEY")
	money:HookScript("OnEvent", money.update)
	money:HookScript("OnEnter", money.onenter)
	money:HookScript("OnLeave", money.onleave)
	money:HookScript("OnClick", money.click)

	return money
end

