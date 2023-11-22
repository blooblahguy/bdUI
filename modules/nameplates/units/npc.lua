local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Nameplates")

mod.npc_style = function(self, event, unit)
	local config = mod.config

	if (self.smartColors) then
		self.Name:SetTextColor(unpack(self.smartColors))
	end

	if (self.currentStyle and self.currentStyle == "npc") then return end
	self.currentStyle = "npc"

	-- castbar
	self:DisableElement("Castbar")
	self:DisableElement("Buffs")
	self:DisableElement("Debuffs")
	self:DisableElement("FixateAlert")
	self:DisableElement("QuestProgress")

	-- healthbar
	self.Health:Hide()
	self.disableFixate = true

	-- powerbar
	-- self.Power:Hide()

	-- name
	self.Name:Show()
end
