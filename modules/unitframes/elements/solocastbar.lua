local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")

mod.additional_elements.solocastbar = function(self, unit, align, icon)
	if (self.SoloCastbar) then return end
	local config = mod.config
	
end