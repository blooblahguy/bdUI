local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")

mod.custom_layout["pet"] = function(self, unit)
	local config = mod._config
	
	self:SetSize(config.targetoftargetwidth, config.targetoftargetheight)
end