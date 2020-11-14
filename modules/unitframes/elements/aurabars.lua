local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")

local font = CreateFont("BDUI_UF_AURAS")
font:SetFont(bdUI.media.font, 13, "THINOUTLINE")
font:SetShadowColor(0, 0, 0)
font:SetShadowOffset(0, 0)

mod.additional_elements.aurabars = function(self, unit)
	if (self.AuraBars) then return end
	local config = mod.config

	self.AuraBars = CreateFrame("Frame", "bdUF_AuraBars", self)
	self.AuraBars:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, bdUI.border * 3)
	self.AuraBars:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, bdUI.border * 3)
	self.AuraBars:SetHeight(60)
	self.AuraBars.width = config.playertargetwidth
	self.AuraBars.height = 16
	-- self.AuraBars.iconDisabled = true
	self.AuraBars.sparkDisabled = true
	self.AuraBars.spacing = bdUI.border * 3
	self.AuraBars.fontObject = "BDUI_UF_AURAS"
	self.AuraBars.texture = bdUI.media.smooth
	self.AuraBars.baseColor = bdUI.media.blue

	-- self.AuraBars.PostUpdateBar = function(self, unit, bar, index, position, duration, expiration, debuffType, isStealable)
	-- 	-- print("hey bar")
	-- -- 	local name, _, _, debuffType, duration, expiration, caster, IsStealable, _, spellID = UnitAura(unit, index, bar.filter)
	-- -- 	duration, expiration = bdUI:update_duration(bar.cd, unit, spellID, caster, name, duration, expiration)
	-- end

	self.AuraBars.PostCreateBar = function(buffs, bar)
		bdUI:set_backdrop(bar)
		bar.icon.bg = bar:CreateTexture(nil, "BACKGROUND")
		bar.icon.bg:SetTexture(bdUI.media.flat)
		bar.icon.bg:SetVertexColor(bdUI.media.backdrop)
		bar.icon.bg:SetPoint("TOPLEFT", bar.icon, "TOPLEFT", -bdUI.border, bdUI.border)
		bar.icon.bg:SetPoint("BOTTOMRIGHT", bar.icon, "BOTTOMRIGHT", bdUI.border, -bdUI.border)

		bar.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

		-- blacklist
		bar:SetScript("OnMouseDown", function(self, button)
			self:GetParent():ForceUpdate()
			if (not IsShiftKeyDown() or not button == "MiddleButton") then return end
			local name = self.spell
			BDUI_SAVE.persistent.Auras.blacklist[name] = true
			bdUI.caches.auras = false

			bdUI:debug("Blacklisted "..name)
		end)
	end

	-- set better colors
	self.AuraBars.PostUpdateBar = function(self, unit, statusBar, index, position, duration, expiration, debuffType, isStealable)
		-- dump(bdUI.classColor)
		statusBar:SetStatusBarColor(bdUI.classColor:GetRGB())
	end
end