local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")

mod.additional_elements.perhp = function(self, unit)
	if (self.Perhp) then return end
	local config = mod.config

	self.Perhp = self.Health:CreateFontString(nil, "OVERLAY")
	self.Perhp:SetFontObject(bdUI:get_font(11))
	self.Perhp:SetPoint("LEFT", self.Health, "LEFT", 4, 0)

	self.Perpp = self.Health:CreateFontString(nil, "OVERLAY")
	self.Perpp:SetFontObject(bdUI:get_font(11))
	self.Perpp:SetPoint("RIGHT", self.Health, "RIGHT", -4, 0)
	self.Perpp:SetTextColor(self.Power:GetStatusBarColor())

	self:RegisterEvent("UNIT_POWER_UPDATE", function(self)
		self.Perpp:SetTextColor(self.Power:GetStatusBarColor())
	end, true)

	self:Tag(self.Perhp, '[perhp]')
	self:Tag(self.Perpp, '[perpp]')
end