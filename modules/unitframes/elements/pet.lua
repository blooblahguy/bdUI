local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")

mod.custom_layout["pet"] = function(self, unit)
	local config = mod:get_save()
	
	self:SetSize(config.targetoftargetwidth, config.targetoftargetheight)

	self.Name:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
	self.Name:SetFont(bdUI.media.font, math.clamp(config.targetoftargetheight * 0.75, 0, 13), "OUTLINE")
end