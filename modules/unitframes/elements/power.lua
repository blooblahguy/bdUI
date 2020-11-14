local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")

mod.additional_elements.power = function(self, unit)
	if (self.Power) then return end
	local config = mod.config

	-- Power
	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetStatusBarTexture(bdUI.media.flat)
	self.Power:ClearAllPoints()
	
	self.Power:SetHeight(config.playertargetpowerheight)
	self.Power.frequentUpdates = true
	self.Power.colorPower = true
	self.Power.Smooth = true
	bdUI:set_backdrop(self.Power)
	self.Power.PostUpdateColor = function(self, unit, r, g, b)
		self._background:SetVertexColor(r * 0.15, g * 0.15, b * 0.15)
	end

	bdUI:add_action("bdUI/border_size, post_loaded", function()
		local border = bdUI:get_border(self)
		self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -border)
		self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -border)
		self.Border:SetPoint("BOTTOMRIGHT", self.Power, "BOTTOMRIGHT", border, -border)
	end)
end