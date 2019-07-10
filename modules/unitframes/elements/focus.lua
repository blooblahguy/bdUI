local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")

mod.custom_layout["focus"] = function(self, unit)
	local config = mod._config
	
	mod.additional_elements.castbar(self, unit)
	mod.additional_elements.power(self, unit)

	self:SetSize(config.playertargetwidth, config.playertargetheight)
end