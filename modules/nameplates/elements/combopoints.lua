local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Nameplates")
local oUF = bdUI.oUF

mod.elements.combopoints = function(self, unit)
	local border = bdUI:get_border(self)
	config = mod.config

	self.ClassicComboPointsHolder = CreateFrame("frame", nil, self)
	self.ClassicComboPointsHolder:SetAllPoints()
	self.ClassicComboPoints = {}

	for index = 1, 5 do
		local bar = CreateFrame('StatusBar', "bdNameplateComboPoint" .. index, self.ClassicComboPointsHolder)
		bar:SetStatusBarTexture(bdUI.media.flat)
		self.ClassicComboPoints[index] = bar
	end

	local colors = {}
	colors[1] = { 0.34, 0.57, 0.17 }
	colors[2] = { 0.34, 0.57, 0.17 }
	colors[3] = { 0.58, 0.52, 0 }
	colors[4] = { 0.64, 0.50, 0 }
	colors[5] = { 0.6, 0.23, 0 }

	self.ClassicComboPoints.UpdateColor = function(self, powerType)
		for i = 1, #self do
			local bar = self[i]
			bar:SetStatusBarColor(unpack(colors[i]))
		end
	end

	mod:show_class_resources(self)
end
