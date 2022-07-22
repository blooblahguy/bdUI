local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Nameplates")
local oUF = bdUI.oUF

mod.elements.combopoints = function(self, unit)
	local border = bdUI:get_border(self)
	config = mod.config

	local border = bdUI:get_border(self)
	self.ClassicComboPointsHolder = CreateFrame("frame", nil, self)
	-- self.ClassicComboPointsHolder:SetPoint("BOTTOMLEFT", self.Health)
	self.ClassicComboPointsHolder:SetPoint("TOPLEFT", self.Health)
	self.ClassicComboPointsHolder:SetPoint("BOTTOMRIGHT", self.Health)
	self.ClassicComboPoints = {}

	local last
	local gap = border * 4
	width = 16
	for index = 1, 5 do
		local bar = CreateFrame('StatusBar', "bdNameplateComboPoint"..index, self.ClassicComboPointsHolder)
		bar:SetStatusBarTexture(bdUI.media.flat)
		bdUI:set_backdrop_basic(bar)

		bar:SetSize(width, 5)
		if (not last) then
			bar:SetPoint("BOTTOMLEFT", self.ClassicComboPointsHolder)
		else
			bar:SetPoint('LEFT', last, "RIGHT", gap, 0)
		end

		last = bar
		self.ClassicComboPoints[index] = bar
	end

	-- color gradiants
	local colors = {}
	colors[1] = {0.34, 0.57, 0.17}
	colors[2] = {0.34, 0.57, 0.17}
	colors[3] = {0.58, 0.52, 0}
	colors[4] = {0.64, 0.50, 0}
	colors[5] = {0.6, 0.23, 0}

	self.ClassicComboPoints.UpdateColor = function(self, powerType)
		local width = (config.width - (gap * 4)) / 5
		for i = 1, #self do
			local bar = self[i]
			bar:SetWidth(width)
			bar:SetStatusBarColor(unpack(colors[i]))
		end
	end

	mod:show_class_resources(self)

	-- pixel perfect
	self:HookScript("OnSizeChanged", function(self, elapsed)
		local border = bdUI:get_border(self)

		for index = 1, 5 do
			bdUI:set_backdrop(self.ClassicComboPoints[index], true)
		end
	end)
end