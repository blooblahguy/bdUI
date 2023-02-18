local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")

local font = bdUI:get_font(13)

mod.additional_elements.aurabars = function(self, unit)
	if (self.AuraBars) then return end
	local config = mod.config

	self.AuraBars = CreateFrame("Frame", "bdUF_AuraBars", self)
	if (self.ResourceHolder:IsShown()) then
		self.AuraBars:SetPoint("BOTTOMLEFT", self.ResourceHolder, "TOPLEFT", bdUI.border * 2, bdUI.border)
	else
		self.AuraBars:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", bdUI.border * 2, bdUI.border)
	end

	-- self.AuraBars:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, bdUI.border)
	self.AuraBars:SetHeight(60)
	self.AuraBars:SetWidth(config.playertargetwidth - (bdUI.border * 2))
	self.AuraBars.width = config.playertargetwidth - (bdUI.border * 2)
	self.AuraBars.height = 16
	self.AuraBars.sparkDisabled = true
	self.AuraBars.spacing = bdUI.border
	self.AuraBars.fontObject = bdUI:get_font(10)
	self.AuraBars.texture = bdUI.media.smooth
	self.AuraBars.baseColor = bdUI.media.blue

	self.AuraBars.PostCreateBar = function(buffs, bar)
		bdUI:set_backdrop(bar)
		bar.icon.bg = bar:CreateTexture(nil, "BACKGROUND")
		bar.icon.bg:SetTexture(bdUI.media.flat)
		-- print(bdUI.media.backdrop)
		bar.icon.bg:SetVertexColor(unpack(bdUI.media.backdrop))
		bar.icon.bg:SetPoint("TOPLEFT", bar.icon, "TOPLEFT", -bdUI.border, bdUI.border)
		bar.icon.bg:SetPoint("BOTTOMRIGHT", bar.icon, "BOTTOMRIGHT", bdUI.border, -bdUI.border)

		bar.icon:SetTexCoord(.07, .93, .07, .93)

		-- blacklist
		bar:SetScript("OnMouseDown", function(self, button)
			if (not IsShiftKeyDown() or not IsAltKeyDown() or not IsAltKeyDown() or not button == "MiddleButton") then return end
			local name = self.spell:lower()
			local auras = bdUI:get_module("Auras")
			
			auras:get_save().blacklist[name] = true
			auras:store_lowercase_auras()
			bdUI.caches.auras = {}

			bdUI:debug("Blacklisted "..name)

			self:GetParent():ForceUpdate()
		end)
	end

	-- set better colors
	self.AuraBars.PostUpdateBar = function(self, unit, statusBar, index, position, duration, expiration, debuffType, isStealable)
		-- dump(bdUI.classColor)
		statusBar:SetStatusBarColor(bdUI.classColor:GetRGB())
	end
end