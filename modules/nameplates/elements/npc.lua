local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Nameplates")

function mod:npc_style(self, event, unit)
	local config = mod:get_save()

	if (self.smartColors) then
		self.Name:SetTextColor(unpack(self.smartColors))
	end
	
	if (self.currentStyle and self.currentStyle == "npc") then return end
	self.currentStyle = "npc"

	-- castbar
	self:DisableElement("Castbar")

	-- healthbar
	self.Health:Hide()
	self.disableFixate = true

	-- powerbar
	-- self.Power:Hide()

	-- name
	self.Name:Show()

	-- auras
	self.Auras:Hide()
end