local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")

local function castbar_kickable(self, unit)
	-- set cast duration
	self.Duration:SetText(bdUI:round(self.max, 1))

	-- find out if its kickable
	local name, text, texture, startTimeMS, endTimeMS, isTradeSkill, castID, notInterruptible, spellId = UnitCastingInfo(
		unit)
	if (not name) then
		name, text, texture, startTimeMS, endTimeMS, isTradeSkill, notInterruptible, spellId = UnitChannelInfo(unit)
	end
	self:SetAlpha(1)
	if (notInterruptible) then
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
	self.Castbar:SetFrameStrata("MEDIUM")
	self.Castbar:SetStatusBarTexture(bdUI.media.smooth)
	self.Castbar:SetStatusBarColor(.1, .4, .7, 1)
	self.Castbar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -bdUI.get_border())
	self.Castbar:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 0, -(4 + config.castbarheight))
	self.Castbar.timeToHold = 1.2
	if (self.Power) then
		self.Castbar:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -bdUI.get_border())
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
		self.Castbar.Icon.bg:SetPoint("TOPLEFT", self.Castbar.Icon, "TOPLEFT", -bdUI.get_border(), bdUI.get_border())
		self.Castbar.Icon.bg:SetPoint("BOTTOMRIGHT", self.Castbar.Icon, "BOTTOMRIGHT", bdUI.get_border(), -bdUI.get_border())
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
		self.Castbar.Icon:SetPoint("TOPRIGHT", self.Castbar, "TOPLEFT", -mod.padding * 2, 0)
		self.Castbar.Icon:SetSize(config.castbarheight * 1.5, config.castbarheight * 1.5)
	end

	bdUI:set_backdrop(self.Castbar)

	-- attribute who interrupted this cast
	function self.Castbar:CastbarAttribute()
		local timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, extraSpellID, extraSpellName, extraSchool =
			CombatLogGetCurrentEventInfo()

		if (event == "SPELL_INTERRUPT" and UnitExists(sourceName)) then
			local unit_kicked = destGUID
			local this_nameplate = UnitGUID(self.unit)

			if (unit_kicked == this_nameplate) then
				self.Castbar:SetAlpha(0.8)
				self.Castbar:SetStatusBarColor(unpack(bdUI.media.red))
				self.Castbar.Text:SetText("|cff" ..
					mod:autoUnitColorHex(sourceName) .. UnitName(sourceName) .. "|r Interrupted")
			end
		end
	end

	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self.Castbar.CastbarAttribute, true)

	-- check if kickable








	self.Castbar.PostCastStart = castbar_kickable
	self.Castbar.PostChannelStart = castbar_kickable
	self.Castbar.PostCastNotInterruptible = castbar_kickable
	self.Castbar.PostCastInterruptible = castbar_kickable
end
