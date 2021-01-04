local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Nameplates")

--==============================================
-- Show Kickable Casts
--==============================================
local function kickable_cast(self)
	self:SetAlpha(1)
	if (self.notInterruptible) then
		self.Icon:SetDesaturated(1)
		self:SetStatusBarColor(unpack(config.nonkickable))
	else
		self.Icon:SetDesaturated(false)
		self:SetStatusBarColor(unpack(config.kickable))
	end

	local border = bdUI:get_border(self)
	self.Icon:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", -border, 0)
	self.Icon.bg:SetPoint("TOPLEFT", self.Icon, "TOPLEFT", -border, border)
	self.Icon.bg:SetPoint("BOTTOMRIGHT", self.Icon, "BOTTOMRIGHT", border, -border)
end

-- castbar element
mod.elements.castbar = function(self, unit)
	local border = bdUI:get_border(self)
	config = mod.config

	self.Castbar = CreateFrame("StatusBar", nil, self)
	self.Castbar:SetFrameLevel(3)
	self.Castbar:SetStatusBarTexture(bdUI.media.flat)
	self.Castbar:SetStatusBarColor(unpack(config.kickable))
	self.Castbar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -border)
	self.Castbar:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 0, -config.castbarheight)
	
	-- text
	self.Castbar.Text = self.Castbar:CreateFontString(nil, "OVERLAY")
	self.Castbar.Text:SetFontObject(mod.font_castbar)
	self.Castbar.Text:SetJustifyH("LEFT")
	self.Castbar.Text:SetPoint("LEFT", self.Castbar, "LEFT", 10, 0)

	self.Castbar.AttributeText = self.Castbar:CreateFontString(nil, "OVERLAY")
	self.Castbar.AttributeText:SetFontObject(mod.font_castbar)
	self.Castbar.AttributeText:SetJustifyH("RIGHT")
	self.Castbar.AttributeText:SetPoint("RIGHT", self.Castbar, "RIGHT", -10, 0)
	
	-- icon
	self.Castbar.Icon = self.Castbar:CreateTexture(nil, "OVERLAY")
	self.Castbar.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	self.Castbar.Icon:SetDrawLayer('ARTWORK')
	self.Castbar.Icon:SetSize( config.height+config.castbarheight, config.height+config.castbarheight )
	self.Castbar.Icon:SetPoint("BOTTOMRIGHT", self.Castbar, "BOTTOMLEFT", -border, 0)
	
	-- icon bg
	self.Castbar.Icon.bg = self.Castbar:CreateTexture(nil, "BORDER")
	self.Castbar.Icon.bg:SetTexture(bdUI.media.flat)
	self.Castbar.Icon.bg:SetVertexColor(unpack(bdUI.media.border))
	self.Castbar.Icon.bg:SetPoint("TOPLEFT", self.Castbar.Icon, "TOPLEFT", -border, border)
	self.Castbar.Icon.bg:SetPoint("BOTTOMRIGHT", self.Castbar.Icon, "BOTTOMRIGHT", border, -border)

	-- Combat log based extra information
	function self.Castbar:CastbarAttribute() 
		local timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, extraSpellID, extraSpellName, extraSchool = CombatLogGetCurrentEventInfo();

		if (event == 'SPELL_CAST_START') then
			if (self.unit ~= mod.guid_plates[sourceGUID]) then return end

			destName = mod.guid_plates[sourceGUID].."target"

			self.Castbar.AttributeText:SetText("")
			-- attribute who this cast is targeting
			if (UnitExists(destName) and config.showcasttarget) then
				self.Castbar.AttributeText:SetText(UnitName(destName))
				self.Castbar.AttributeText:SetTextColor(mod:autoUnitColor(destName))
			end
		elseif (event == "SPELL_INTERRUPT" and config.showcastinterrupt) then
			-- attribute who interrupted this cast
			if (UnitExists(sourceName)) then
				self.Castbar.AttributeText:SetText(UnitName(sourceName))
				self.Castbar.AttributeText:SetTextColor(mod:autoUnitColor(sourceName))
			end
		end
	end
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self.Castbar.CastbarAttribute, true)

	-- interrupted delay
	self.Castbar.PostCastInterrupted = function(self, unit)
		self.holdTime = 0.7
		self:SetAlpha(0.7)
		self:SetStatusBarColor(unpack(bdUI.media.red))
	end

	-- Change color if cast is kickable or not
	self.Castbar.PostChannelStart = kickable_cast
	self.Castbar.PostCastNotInterruptible = kickable_cast
	self.Castbar.PostCastInterruptible = kickable_cast
	self.Castbar.PostCastStart = kickable_cast

	-- Pixel Perfect
	self:SetScript("OnSizeChanged", function(self, elapsed)
		bdUI:set_backdrop(self.Health, true)
		bdUI:set_backdrop(self.Castbar, true)

		local border = bdUI:get_border(self)

		self.Castbar.Icon.bg:SetPoint("TOPLEFT", self.Castbar.Icon, "TOPLEFT", -border, border)
		self.Castbar.Icon.bg:SetPoint("BOTTOMRIGHT", self.Castbar.Icon, "BOTTOMRIGHT", border, -border)
		self.Castbar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -border)
		self.Castbar.Icon:SetPoint("BOTTOMRIGHT", self.Castbar, "BOTTOMLEFT", -border, 0)
	end)
end