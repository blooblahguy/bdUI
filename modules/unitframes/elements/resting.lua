local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")

mod.additional_elements.resting = function(self, unit)
	if (self.RestingIndicator) then return end
	local config = mod.config
	local height = config.playertargetheight

	local size = math.restrict(height * 0.75, 8, height)

	-- Resting indicator
	self.RestingIndicator = self.TextHolder:CreateTexture(nil, "OVERLAY")
	self.RestingIndicator:SetSize(size, size)
	self.RestingIndicator:SetTexture([[Interface\CharacterFrame\UI-StateIcon]])
	self.RestingIndicator:SetTexCoord(0, 0.5, 0, 0.421875)

	if (config.textlocation == "Outside") then
		self.RestingIndicator:SetPoint("LEFT", self.TextHolder, mod.padding, 1)
	elseif (config.textlocation == "Inside") then
		self.RestingIndicator:SetPoint("LEFT", self.TextHolder, "CENTER", mod.padding, 1)
	end
end