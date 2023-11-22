local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")

mod.custom_layout["pet"] = function(self, unit)
	local config = mod.save

	self:SetSize(config.targetoftargetwidth, config.targetoftargetheight)

	self.Health.colorClass = false
	self.Health.colorSmooth = false
	self.Health.colorReaction = true
end
