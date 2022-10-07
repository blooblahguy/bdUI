local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Nameplates")

mod.friendly_style = function(self, event, unit)
	local config = mod.config
	
	self.Name:SetTextColor(unpack(self.smartColors))
	self.Name:SetAlpha(config.friendnamealpha)

	if (self.currentStyle and self.currentStyle == "friendly") then return end
	self.currentStyle = "friendly"

	-- print(unit)

	-- auras
	self.Buffs:Show()
	self.Debuffs:Show()

	self.Name:Show()
	-- names
	if (config.hidefriendnames) then
		self.Name:Hide()
	else
		self.Name:Show()
		self.Name:SetAlpha(config.friendnamealpha)
	end

	-- castbars
	self:DisableElement("Castbar")
	self:DisableElement("FixateAlert")
	self:DisableElement("QuestProgress")

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