local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Nameplates")

--==============================================
-- Show Kickable Casts
--==============================================
local function kickable_cast(self, unit)
	local name, text, texture, startTimeMS, endTimeMS, isTradeSkill, castID, notInterruptible, spellId = UnitCastingInfo(unit)
	if (not name) then
		name, text, texture, startTimeMS, endTimeMS, isTradeSkill, notInterruptible, spellId = UnitChannelInfo(unit)
	end
	self:SetAlpha(1)
	if (notInterruptible) then
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
	self.Castbar.timeToHold = 1.2
	
	-- text
	self.Castbar.Text = self.Castbar:CreateFontString(nil, "OVERLAY")
	self.Castbar.Text:SetJustifyH("LEFT")
	self.Castbar.Text:SetPoint("LEFT", self.Castbar, "LEFT", 10, 0)
	
	-- icon
	self.Castbar.Icon = self.Castbar:CreateTexture(nil, "OVERLAY")
	self.Castbar.Icon:SetTexCoord(.07, .93, .07, .93)
	self.Castbar.Icon:SetDrawLayer('ARTWORK')
	self.Castbar.Icon:SetSize( config.height+config.castbarheight, config.height+config.castbarheight )
	self.Castbar.Icon:SetPoint("BOTTOMRIGHT", self.Castbar, "BOTTOMLEFT", -border, 0)
	
	-- icon bg
	self.Castbar.Icon.bg = self.Castbar:CreateTexture(nil, "BORDER")
	self.Castbar.Icon.bg:SetTexture(bdUI.media.flat)
	self.Castbar.Icon.bg:SetVertexColor(unpack(bdUI.media.border))
	self.Castbar.Icon.bg:SetPoint("TOPLEFT", self.Castbar.Icon, "TOPLEFT", -border, border)
	self.Castbar.Icon.bg:SetPoint("BOTTOMRIGHT", self.Castbar.Icon, "BOTTOMRIGHT", border, -border)

	-- attribute who interrupted this cast
	function self.Castbar:CastbarAttribute() 
		local timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, extraSpellID, extraSpellName, extraSchool = CombatLogGetCurrentEventInfo()

		if (event == "SPELL_INTERRUPT" and UnitExists(sourceName)) then
			local unit_kicked = destGUID
			local this_nameplate = UnitGUID(self.unit)

			if (unit_kicked == this_nameplate) then
				self.Castbar:SetAlpha(0.8)
				self.Castbar:SetStatusBarColor(unpack(bdUI.media.red))
				self.Castbar.Text:SetText("|cff"..mod:autoUnitColorHex(sourceName)..UnitName(sourceName).."|r Interrupted")
			end
		end
	end
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self.Castbar.CastbarAttribute, true)

	-- Change color if cast is kickable or not
	self.Castbar.PostCastStart = kickable_cast
	self.Castbar.PostChannelStart = kickable_cast
	self.Castbar.PostCastNotInterruptible = kickable_cast
	self.Castbar.PostCastInterruptible = kickable_cast
end