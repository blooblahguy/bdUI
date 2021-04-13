local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")

mod.custom_layout["pet"] = function(self, unit)
	local config = mod.save
	
	self:SetSize(config.targetoftargetwidth, config.targetoftargetheight)

	self.Name:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
	self.Name:SetFontObject(bdUI:get_font(math.clamp(config.targetoftargetheight * 0.75, 0, 13)))

	self.Health.colorClass = false
	self.Health.colorSmooth = false
	self.Health.colorReaction = true
end