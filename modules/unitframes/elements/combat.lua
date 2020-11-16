local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")

mod.additional_elements.combat = function(self, unit)
	if (self.CombatIndicator) then return end
	
	local config = mod.config
	local height = config.playertargetheight

	local size = math.restrict(height * 0.75, 8, height)

	-- Resting indicator
	self.CombatIndicator = self.TextHolder:CreateTexture(nil, "OVERLAY")
	self.CombatIndicator:SetSize(size, size)
	self.CombatIndicator:SetTexture([[Interface\CharacterFrame\UI-StateIcon]])
	self.CombatIndicator:SetTexCoord(.5, 1, 0, .49)

	if (config.textlocation == "Outside") then
		self.CombatIndicator:SetPoint("RIGHT", self.TextHolder, -mod.padding, 1)
	elseif (config.textlocation == "Inside") then
		self.CombatIndicator:SetPoint("RIGHT", self.TextHolder, "CENTER", -mod.padding, 1)
	end
end