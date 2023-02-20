local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")

mod.custom_layout["targettarget"] = function(self, unit)
	local config = mod.save
	
	self:SetSize(config.targetoftargetwidth, config.targetoftargetheight)
end