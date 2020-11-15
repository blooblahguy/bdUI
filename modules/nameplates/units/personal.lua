local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Nameplates")

mod.personal_style = function(self, event, unit)
	local config = mod.config
	
	if (self.currentStyle and self.currentStyle == "personal") then return end
	self.currentStyle = "personal"

	-- name
	self.Name:Hide()

	-- -- castbar
	self:DisableElement("Castbar")
	self:DisableElement("Auras")
	self:DisableElement("FixateAlert")
	self:DisableElement("QuestProgress")
	-- self.Castbar:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -2)
	-- self.Castbar:SetPoint("BOTTOMRIGHT", self.Power, "BOTTOMRIGHT", 0, -config.castbarheight)

	-- healthbar
	self.Health:Show()
	self.Curhp:Hide()
	self.Curpower:Hide()
	-- if (config.hptext == "None" or config.showhptexttargetonly) then
	-- else
		-- self.Curhp:Show()
	-- end

	-- self:SetHeight()

	self.disableFixate = true

	-- on target callback
	self.OnTarget = function()
		self.Curhp:Hide()
		self.Curpower:Hide()
	end
end