local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Nameplates")

function mod:friendly_style(self, event, unit)
	local config = mod._config
	
	self.Name:SetTextColor(unpack(self.smartColors))
	self.Name:SetAlpha(config.friendnamealpha)

	if (self.currentStyle and self.currentStyle == "friendly") then return end
	self.currentStyle = "friendly"

	-- healthbar
	if (config.friendlyplates) then
		self.Health:Show()
	else
		self.Health:Hide()
	end
	
end