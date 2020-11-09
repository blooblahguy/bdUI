local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")
local config
local class = select(2, UnitClass("player"))

local function getDisplayPower(unit)
	local _, min, _, _, _, _, showOnRaid = UnitAlternatePowerInfo(unit)
	if(showOnRaid) then
		return ALTERNATE_POWER_INDEX, min
	end
end

mod.update_resources = function(self, unit)
	-- power
	self.Resources.power:SetSize(config.resources_width, config.resources_power_height)
	if (config.resources_power_height == 0 or not config.resources_enable) then
		self.Resources.power:Hide()
	elseif (config.resources_power_height ~= 0) then
		self.Resources.power:Show()
	end
	-- primary
	self.Resources.primary:SetSize(config.resources_width, config.resources_primary_height)
	if (config.resources_primary_height == 0 or not config.resources_enable or not self.Resources.__isEnabled) then
		self.Resources.primary:Hide()
	elseif (config.resources_primary_height ~= 0) then
		self.Resources.primary:Show()
	end
	-- secondary
	self.Resources.secondary:SetSize(config.resources_width, config.resources_secondary_height)
	if (config.resources_secondary_height == 0 or not config.resources_enable or not self.Resources.secondary.__isEnabled) then
		self.Resources.secondary:Hide()
	elseif (config.resources_secondary_height ~= 0) then
		self.Resources.secondary:Show()
	end

	-- now update stack positioning
	bdUI:frame_group(self.Resources, "downwards", self.Resources.power, self.Resources.primary, self.Resources.secondary)
end

-- Mega resource display
mod.create_resources = function(self, unit)
	if (unit ~= "player") then return end
	config = mod.save

	-- if we've created this already, just update it
	if (self.Resources) then
		mod.update_resources(self, unit)
		return
	end

	-- displays class resources
	self.Resources = CreateFrame("frame", "bdResources", UIParent)
	self.Resources:SetPoint("CENTER", bdParent, "CENTER", 0, -180)
	self.Resources:EnableMouse(false)
	bdMove:set_moveable(self.Resources, "Player Resources")

	-- For Power Display
	
	self.Resources.power = CreateFrame("statusbar", "bdPowerResource", self.Resources)
	self.Resources.power:SetSize(config.resources_width, config.resources_power_height)
	self.Resources.power:SetStatusBarTexture(bdUI.media.flat)
	self.Resources.power:RegisterEvent('UNIT_POWER_FREQUENT')
	if (WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC) then
		self.Resources.power:RegisterEvent('UNIT_POWER_POINT_CHARGE')
	end
	self.Resources.power:RegisterEvent('UNIT_DISPLAYPOWER')
	self.Resources.power:RegisterEvent('UNIT_MAXPOWER')
	-- self.Resources.power:RegisterEvent('UNIT_POWER_BAR_SHOW')
	-- self.Resources.power:RegisterEvent('UNIT_POWER_BAR_HIDE')
	self.Resources.power:EnableMouse(false)
	self.Resources.power:RegisterEvent('UNIT_FLAGS') -- For selection

	function self.Resources.power:Update(event)
		-- local displayType, min = getDisplayPower("player")

		local cur, max = UnitPower("player"), UnitPowerMax("player")
		self:SetMinMaxValues(0, max)
		self:SetValue(cur)
		self.text:SetText(bdUI:numberize(cur))

		-- color the bar
		local r, g, b
		if (not event) then
			local ptype, ptoken, altR, altG, altB = UnitPowerType(unit)
			r, g, b = unpack(self.__owner.colors.power[ptoken or ptype])
		else
			r, g, b = self.__owner.Power:GetStatusBarColor()
		end
		self:SetStatusBarColor(r * 0.8, g * 0.8, b * 0.8)
	end
	self.Resources.power.__owner = self
	self.Resources.power.text = self.Resources.power:CreateFontString(nil, "OVERLAY")
	self.Resources.power.text:SetFont(bdUI.media.font, 11, "OUTLINE")
	self.Resources.power.text:SetJustifyV("MIDDLE")
	self.Resources.power.text:SetPoint("CENTER", self.Resources.power)
	self.Resources.power:SetScript("OnEvent", self.Resources.power.Update)
	bdUI:set_backdrop(self.Resources.power)
	self.Resources.power:Update()

	-- For primary resource
	self.Resources.primary = CreateFrame("frame", "bdPrimaryResource", self.Resources)
	self.Resources.primary:SetSize(config.resources_width, config.resources_primary_height)
	self.Resources.primary:EnableMouse(false)
	self.Resources.primary:Hide()
	bdUI:set_backdrop(self.Resources.primary)

	-- for secondary resource (like stagger, necrostrike)
	self.Resources.secondary = CreateFrame("frame", "bdSecondaryResource", self.Resources)
	self.Resources.secondary:SetSize(config.resources_width, config.resources_secondary_height)
	self.Resources.secondary:EnableMouse(false)
	self.Resources.secondary:Hide()
	bdUI:set_backdrop(self.Resources.secondary)

	if (class == "SHAMAN") then
		self.Resources.secondary.__isEnabled = true
		-- Totem Statusbars
		self.Resources.primary:Show()
		self.TotemBar = {}
		for index = 1, 4 do
			local totem = CreateFrame("StatusBar", nil, self.Resources.primary)
			local width = (self.Resources.primary:GetWidth() - (bdUI.border * 3)) / 4
			totem:SetStatusBarTexture(bdUI.media.flat)
			totem:SetSize(width, config.resources_primary_height)
			totem:SetMinMaxValues(0, 1)

			if (index == 1) then
				totem:SetPoint('BOTTOMLEFT', self.Resources.primary, 'BOTTOMLEFT', 0, 0)
			else
				totem:SetPoint('BOTTOMLEFT', self.TotemBar[index - 1], 'BOTTOMRIGHT', bdUI.border, 0)
			end

			totem.bg = totem:CreateTexture(nil, "BACKGROUND")
			totem.bg:SetAllPoints()
			totem.bg:SetTexture(bdUI.media.flat)
			totem.bg.multiplier = 0.4
			self.TotemBar[index] = totem
		end

	elseif (class == "DEATHKNIGHT") then
		self.Resources.secondary.__isEnabled = true
		-- Necrostrike Indicator
		-- self.Health.NecroticOverlay = self.Resources.secondary:CreateTexture(nil, "OVERLAY", self.Resources.secondary)
		-- self.Health.NecroticOverlay:SetAllPoints(self.Resources.secondary)
		-- self.Health.NecroticOverlay:SetTexture(bdUI.media.flat)
		-- self.Health.NecroticOverlay:SetBlendMode("BLEND")
		-- self.Health.NecroticOverlay:SetVertexColor(0, 0, 0, 0.4)
		-- self.Health.NecroticOverlay:Hide()
		-- self.Resources.secondary:Show()
		-- function self.Health.NecroticOverlay:PostUpdate(amount)
		-- 	if (amount > 0) then
		-- 		self.__owner.Resources.secondary:Show()
		-- 	else
		-- 		self.__owner.Resources.secondary:Hide()
		-- 	end
		-- end


		-- Rune Indicator
		self.Resources.primary:Show()
		self.Runes = {}
		self.Runes.colorSpec = true
		for index = 1, 6 do
			local rune = CreateFrame('StatusBar', nil, self.Resources.primary)
			local width = (self.Resources.primary:GetWidth() - (bdUI.border * (5))) / 6
			rune:SetStatusBarTexture(bdUI.media.flat)
			rune:SetSize(width, config.resources_primary_height)
			if (index == 1) then
				rune:SetPoint('BOTTOMLEFT', self.Resources.primary, 'BOTTOMLEFT', 0, 0)
			else
				rune:SetPoint('BOTTOMLEFT', self.Runes[index - 1], 'BOTTOMRIGHT', bdUI.border, 0)
			end

			self.Runes[index] = rune
		end		
	else
		-- also add stagger bar
		if (class == "MONK") then
			self.Resources.secondary.__isEnabled = true
			print(SPEC_MONK_BREWMASTER ~= GetSpecialization())
			self.Stagger = CreateFrame('StatusBar', nil, self.Resources.secondary)
			self.Stagger:SetAllPoints()
			self.Stagger:SetStatusBarTexture(bdUI.media.flat)
			hooksecurefunc(self.Stagger, "Show", function(self)
				self:GetParent():Show()
			end)
			hooksecurefunc(self.Stagger, "Hide", function(self)
				self:GetParent():Hide()
			end)
		end

		-- power for all other classes
		self.ClassPower = {}
		for index = 1, 10 do
			local bar = CreateFrame('StatusBar', nil, self.Resources.primary)
			local width = (self.Resources:GetWidth() - (bdUI.border * (10 - 1))) / 10
			bar:SetStatusBarTexture(bdUI.media.flat)
			bar:SetSize(width, config.resources_primary_height)

			if (index == 1) then
				bar:SetPoint('BOTTOMLEFT', self.Resources.primary, 'BOTTOMLEFT', 0, 0)
			else
				bar:SetPoint('BOTTOMLEFT', self.ClassPower[index - 1], 'BOTTOMRIGHT', bdUI.border, 0)
			end

			self.ClassPower[index] = bar
		end

		-- resize available bars
		function self.ClassPower:PostUpdate(cur, max, changed, powerType)
			self._height = self._height or config.resources_primary_height
			if (self._height ~= config.resources_primary_height) then changed = true end

			self.__owner.Resources.__isEnabled = self.__isEnabled
			if (not self.__isEnabled or max == 0) then
				self.__owner.Resources.primary:Hide()
				self.__owner.Resources.__isEnabled = false
				return
			elseif (changed) then
				for index = 1, max do
					local bar = self[index]
					local width = (self.__owner.Resources:GetWidth() - (bdUI.border * (max - 1))) / max
					bar:SetSize(width, config.resources_primary_height)
				end
			end

			mod.update_resources(self.__owner, self.__owner.unit)
		end
	end

	mod.update_resources(self, unit)
end