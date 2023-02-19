local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")


mod.custom_layout.arena = function(self, unit)
	local config = mod.save

	mod.additional_elements.power(self, unit)
	mod.additional_elements.castbar(self, unit)
	mod.additional_elements.auras(self, unit)
	
	self.Health:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, config.bosspower + bdUI.border)
	
	mod.align_text(self)

	-- config callback
	self.callback = function()
		self:SetSize(config.bosswidth, config.bossheight)
		self.Power:SetHeight(config.bosspower)

		self.Power:Show()
		if (config.bosspower == 0) then
			self.Power:Hide()
		end
	end
end