local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")

local function castbar_kickable(self)
	if (self.notInterruptible) then
		if (self.Icon) then
			self.Icon:SetDesaturated(1)
		end
		self:SetStatusBarColor(0.7, 0.7, 0.7, 1)
	else
		if (self.Icon) then
			self.Icon:SetDesaturated(false)
		end
		self:SetStatusBarColor(.1, .4, .7, 1)
	end
end

mod.additional_elements.castbar = function(self, unit, align, icon)
	local config = mod.config
	if (not config.enablecastbars) then 
		self:DisableElement("Castbar")
		return
	end

	if (self.Castbar) then return end

	local font_size = math.restrict(config.castbarheight * 0.6, 8, 14)


	self.Castbar = CreateFrame("StatusBar", nil, self)
	self.Castbar:SetFrameLevel(3)
	self.Castbar:SetStatusBarTexture(bdUI.media.smooth)
	self.Castbar:SetStatusBarColor(.1, .4, .7, 1)
	self.Castbar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -bdUI.border)
	self.Castbar:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 0, -(4 + config.castbarheight))
	if (self.Power) then
		self.Castbar:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -bdUI.border)
		self.Castbar:SetPoint("BOTTOMRIGHT", self.Power, "BOTTOMRIGHT", 0, -(4 + config.castbarheight))
	end
	
	self.Castbar.Text = self.Castbar:CreateFontString(nil, "OVERLAY")
	self.Castbar.Text:SetFontObject(bdUI:get_font(font_size, "THINOUTLINE"))
	self.Castbar.Text:SetJustifyV("MIDDLE")
	self.Castbar.Text:SetJustifyH("CENTER")

	if (icon) then
		self.Castbar.Icon = self.Castbar:CreateTexture(nil, "OVERLAY")
		self.Castbar.Icon:SetTexCoord(.07, .93, .07, .93)
		self.Castbar.Icon:SetDrawLayer('ARTWORK')
		self.Castbar.Icon.bg = self.Castbar:CreateTexture(nil, "BORDER")
		self.Castbar.Icon.bg:SetTexture(bdUI.media.flat)
		self.Castbar.Icon.bg:SetVertexColor(unpack(bdUI.media.border))
		self.Castbar.Icon.bg:SetPoint("TOPLEFT", self.Castbar.Icon, "TOPLEFT", -bdUI.border, bdUI.border)
		self.Castbar.Icon.bg:SetPoint("BOTTOMRIGHT", self.Castbar.Icon, "BOTTOMRIGHT", bdUI.border, -bdUI.border)
	end

	self.Castbar.SafeZone = self.Castbar:CreateTexture(nil, "OVERLAY")
	self.Castbar.SafeZone:SetVertexColor(0.85, 0.10, 0.10, 0.20)
	self.Castbar.SafeZone:SetTexture(bdUI.media.flat)

	self.Castbar.Time = self.Castbar:CreateFontString(nil, "OVERLAY")
	self.Castbar.Time:SetFontObject(bdUI:get_font(font_size, "THINOUTLINE"))
	self.Castbar.Time:SetJustifyH("LEFT")

	self.Castbar.Duration = self.Castbar:CreateFontString(nil, "OVERLAY")
	self.Castbar.Duration:SetFontObject(bdUI:get_font(font_size, "THINOUTLINE"))
	self.Castbar.Duration:SetJustifyH("RIGHT")
	

	-- simplifing positioning
	self.Castbar.Time:SetPoint("LEFT", 6, 0)
	self.Castbar.Duration:SetPoint("RIGHT", -6, 0)
	self.Castbar.Text:SetPoint("CENTER")
	if (icon) then
		self.Castbar.Icon:SetPoint("TOPRIGHT", self.Castbar,"TOPLEFT", -mod.padding*2, 0)
		self.Castbar.Icon:SetSize(config.castbarheight * 1.5, config.castbarheight * 1.5)
	end		

	-- Positioning
	-- if (align == "right") then
	-- 	self.Castbar.Time:SetPoint("RIGHT", self.Castbar, "RIGHT", -mod.padding, 0)
	-- 	self.Castbar.Time:SetJustifyH("RIGHT")
	-- 	self.Castbar.Text:SetPoint("LEFT", self.Castbar, "LEFT", mod.padding, 0)
	-- 	if (icon) then
	-- 		self.Castbar.Icon:SetPoint("TOPLEFT", self.Castbar,"TOPRIGHT", mod.padding*2, 0)
	-- 		self.Castbar.Icon:SetSize(config.castbarheight * 1.5, config.castbarheight * 1.5)
	-- 	end
	-- else
	-- 	self.Castbar.Time:SetPoint("LEFT", self.Castbar, "LEFT", mod.padding, 0)
	-- 	self.Castbar.Time:SetJustifyH("LEFT")
	-- 	self.Castbar.Text:SetPoint("RIGHT", self.Castbar, "RIGHT", -mod.padding, 0)
	-- 	if (icon) then
	-- 		self.Castbar.Icon:SetPoint("TOPRIGHT", self.Castbar,"TOPLEFT", -mod.padding*2, 0)
	-- 		self.Castbar.Icon:SetSize(config.castbarheight * 1.5, config.castbarheight * 1.5)
	-- 	end			
	-- end

	self.Castbar.PostChannelStart = castbar_kickable
	self.Castbar.PostChannelUpdate = castbar_kickable
	self.Castbar.PostCastStart = castbar_kickable
	self.Castbar.PostCastDelayed = castbar_kickable
	self.Castbar.PostCastNotInterruptible = castbar_kickable
	self.Castbar.PostCastInterruptible = castbar_kickable

	-- bdMove:set_moveable(self.Castbar, unit.." Castbar")
	bdUI:set_backdrop(self.Castbar)

	self.Castbar.PostCastStart = function(self, unit)
		self.Duration:SetText(bdUI:round(self.max, 1))
	end
end