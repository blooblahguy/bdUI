--===============================================
-- FUNCTIONS
--===============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")

--===============================================
-- Custom functionality
-- place custom functionality here
--===============================================
function mod:display_text(self, unit, align)
	local config = mod:get_save()

	self.Name:ClearAllPoints()
	self.Curhp:ClearAllPoints()
	self.Status:ClearAllPoints()

	local LEFT = "LEFT"
	local RIGHT = "RIGHT"
	local offset = 4
	self.Name:Show()
	if (align == "right") then
		offset = -4
		LEFT = "RIGHT"
		RIGHT = "LEFT"
	end

	
	if (config.textlocation == "Inside") then
		self.Name:SetFontObject(bdUI:get_font(11))
		self.Curhp:SetFontObject(bdUI:get_font(10))

		self.Name:SetPoint(LEFT, self.TextHolder, offset, 0)
		self.Curhp:SetPoint(RIGHT, self.TextHolder, RIGHT, -offset, 0)

		self.Status:SetPoint("CENTER")
	elseif (config.textlocation == "Outside") then
		self.Name:SetFontObject(bdUI:get_font(13))
		self.Curhp:SetFontObject(bdUI:get_font(10))
		
		self.Name:SetPoint("TOP"..RIGHT, self.TextHolder, "TOP"..LEFT, -offset, 0)
		self.Curhp:SetPoint("TOP"..RIGHT, self.Name, "BOTTOM"..RIGHT, 0, -mod.padding)

		self.Status:SetPoint(RIGHT, -offset, 0)
	elseif (config.textlocation == "Minimal") then
		if (unit == "player") then
			self.Name:Hide()
		end

	end

end

mod.align_text = function(self, align)
	local config = mod:get_save()
	local icons = self.Auras or self.Debuffs or self.Buffs

	self.Name:ClearAllPoints()
	self.Curhp:ClearAllPoints()

	if (config.textlocation == "Inside") then
		if (align == "right") then
			self.Name:SetPoint("RIGHT", self.Health, "RIGHT", -4, 0)
			self.Curhp:SetPoint("LEFT", self.Health, "LEFT", 4, 0)
		else
			self.Name:SetPoint("LEFT", self.Health, "LEFT", 4, 0)
			self.Curhp:SetPoint("RIGHT", self.Health, "RIGHT", -4, 0)
		end
	elseif (config.textlocation == "Outside") then
		if (align == "right") then
			self.Name:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", 4, -mod.padding)
			self.Curhp:SetPoint("TOPLEFT", self.Name, "BOTTOMLEFT", 0, -mod.padding)
		else
			self.Name:SetPoint("TOPRIGHT", self.Health, "TOPLEFT", -4, -mod.padding)
			self.Curhp:SetPoint("TOPRIGHT", self.Name, "BOTTOMRIGHT", 0, -mod.padding)
		end
	end
end