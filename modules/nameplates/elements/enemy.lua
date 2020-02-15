local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Nameplates")

function mod:enemy_style(self, event, unit)
	local config = mod.config

	-- names
	self.Name:Show()
	if (config.hideEnemyNames == "Always Hide") then
		self.Name:Hide()
	elseif (config.hideEnemyNames == "Only Target" and not self.isTarget) then
		self.Name:Hide()
	elseif (config.hideEnemyNames == "Hide in Arena") then
		local inInstance, instanceType = IsInInstance();
		if (inInstance and instanceType == "arena") then
			self.Name:Hide()
		end
	end
	
	if (self.currentStyle and self.currentStyle == "enemy") then return end
	self.currentStyle = "enemy"

	-- auras
	self.Auras:Show()
	self.Name:SetTextColor(1,1,1)

	-- castbars
	self:EnableElement("Castbar")
	self.Castbar:ClearAllPoints()
	self.Castbar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -bdUI:get_border(self.Castbar))
	self.Castbar:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 0, -config.castbarheight)

	-- healthbar
	self.Health:Show()
	self.disableFixate = false

	-- power
	-- self.Power:Hide()
end