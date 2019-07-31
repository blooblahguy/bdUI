local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Nameplates")

function mod:friendly_style(self, event, unit)
	local config = mod:get_save()
	
	self.Name:SetTextColor(unpack(self.smartColors))
	self.Name:SetAlpha(config.friendnamealpha)

	if (self.currentStyle and self.currentStyle == "friendly") then return end
	self.currentStyle = "friendly"

	-- auras
	self.Auras:Show()

	-- names
	if (config.hidefriendnames) then
		self.Name:Hide()
	else
		self.Name:Show()
		self.Name:SetAlpha(config.friendnamealpha)
	end

	-- castbars
	self:DisableElement("Castbar")

	-- healthbar
	if (config.friendlyplates) then
		self.Health:Show()
	else
		self.Health:Hide()
	end
	self.disableFixate = true

	-- power
	-- self.Power:Hide()
	
end