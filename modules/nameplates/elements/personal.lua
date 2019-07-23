local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Nameplates")

function mod:personal_style(self, event, unit)
	local config = mod._config
	
	if (self.currentStyle and self.currentStyle == "personal") then return end
	self.currentStyle = "personal"

	ClassNameplateManaBarFrame:Hide()
	ClassNameplateManaBarFrame.Show = noop

	-- castbar
	self:EnableElement("Castbar")
	self.Castbar:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -2)
	self.Castbar:SetPoint("BOTTOMRIGHT", self.Power, "BOTTOMRIGHT", 0, -config.castbarheight)

	-- healthbar
	self.Health:Show()
	if (config.hptext == "None" or config.showhptexttargetonly) then
		self.Curhp:Hide()
	else
		self.Curhp:Show()
	end

	self.disableFixate = true
	mod:set_border(self)

	-- powerbar
	self.Power:Show()

	-- name
	self.Name:Hide()

	-- auras
	self.Auras:Show()
end