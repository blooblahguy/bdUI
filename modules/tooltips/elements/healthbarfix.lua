local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Tooltips")

local function update_healthbars(self, unit)
	if (self._healthbars) then return end

	local function update_color(self)
		self:SetStatusBarColor( mod:getUnitColor() )
	end

	GameTooltipStatusBar:ClearAllPoints()
	GameTooltipStatusBar:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, bdUI.border)
	GameTooltipStatusBar:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 6)
	GameTooltipStatusBar:SetStatusBarTexture(bdUI.media.smooth)
	hooksecurefunc(GameTooltipStatusBar, "SetValue", update_color)
	GameTooltipStatusBar:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	GameTooltipStatusBar:RegisterEvent("UNIT_HEALTH")
	GameTooltipStatusBar:SetScript("OnEvent", function(self, event, unit)
		if (not UnitExists("mouseover")) then return end
		if (event == "UNIT_HEALTH" and not UnitIsUnit("mouseover", unit)) then return end
		
		local hp, hpmax = UnitHealth("mouseover"), UnitHealthMax("mouseover")
		self:SetMinMaxValues(0, hpmax)
		self:SetValue(hp)

		local perc = 0
		if (hp > 0 and hpmax > 0) then
			perc = math.floor((hp / hpmax) * 100)
		end
		if (not hpmax) then
			perc = ''
		end
		self.text:SetText(perc)
		
		update_color(self)
	end)

	GameTooltipStatusBar.text = GameTooltipStatusBar:CreateFontString(nil)
	GameTooltipStatusBar.text:SetFontObject(bdUI:get_font(11))
	GameTooltipStatusBar.text:SetAllPoints()
	GameTooltipStatusBar.text:SetJustifyH("CENTER")
	GameTooltipStatusBar.text:SetJustifyV("MIDDLE")
	bdUI:set_backdrop(GameTooltipStatusBar)

	self._healthbars = true
end
function mod:fix_healthbars()
	if (TooltipDataProcessor) then
		TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, update_healthbars);
	else
		GameTooltip:HookScript('OnTooltipSetUnit', update_healthbars)
	end
end