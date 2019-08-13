local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")
local config
local class = select(2, UnitClass("player"))

mod.update_resources = function(self, unit)
	-- power
	self.Resources.power:SetSize(config.resources_width, config.resources_power_height)
	if (config.resources_power_height == 0) then
		self.Resources.power:Hide()
	end
	-- primary
	self.Resources.primary:SetSize(config.resources_width, config.resources_primary_height)
	if (config.resources_primary_height == 0) then
		self.Resources.primary:Hide()
	end
	-- secondary
	self.Resources.secondary:SetSize(config.resources_width, config.resources_secondary_height)
	if (config.resources_secondary_height == 0) then
		self.Resources.secondary:Hide()
	end

	-- now update stack positioning
	bdUI:frame_group(self.Resources, "downwards", self.Resources.power, self.Resources.primary, self.Resources.secondary)
end

-- Mega resource display
mod.create_resources = function(self, unit)
	if (unit ~= "player") then return end
	config = mod:get_save()

	-- if we've created this already, just update it
	if (self.Resources) then
		mod.update_resources(self, unit)
		return
	end

	-- displays class resources
	self.Resources = CreateFrame("frame", "bdResources", self)
	bdMove:set_moveable(self.Resources, "Player Resources")

	-- For Power Display
	self.Resources.power = CreateFrame("statusbar", nil, self.Resources)
	Mixin(self.Resources, self.Power)
	self.Resources.power:SetSize(config.resources_width, config.resources_power_height)
	self.Resources.power:SetStatusBarTexture(bdUI.media.flat)
	self.Resources.power:Hide()
	bdUI:set_backdrop(self.Resources.power)

	-- For primary resource
	self.Resources.primary = CreateFrame("frame", nil, self.Resources)
	self.Resources.primary:SetSize(config.resources_width, config.resources_primary_height)
	self.Resources.primary:Hide()
	bdUI:set_backdrop(self.Resources.primary)

	-- for secondary resource (like stagger, necrostrike)
	self.Resources.secondary = CreateFrame("frame", nil, self.Resources)
	self.Resources.secondary:SetSize(config.resources_width, config.resources_secondary_height)
	self.Resources.secondary:Hide()
	bdUI:set_backdrop(self.Resources.secondary)

	if (class == "SHAMAN") then
		-- Totem Statusbars
		for i = 1, 4 do
			local width = self.Resources:GetWidth() - (bdUI.border * 4) / 4
			local totem = CreateFrame("StatusBar", nil, self)
			totem:SetStatusBarTexture(bdUI.media.flat)
			totem:SetSize(width, config.resources_primary_height)
			totem:SetMinMaxValues(0, 1)

			if (index == 1) then
				rune:SetPoint('BOTTOMLEFT', self.Resources, 'BOTTOMLEFT', 0, 0)
			else
				rune:SetPoint('BOTTOMLEFT', self.TotemBar[index - 1], 'BOTTOMRIGHT', bdUI.border, 0)
			end

			totem.bg = totem:CreateTexture(nil, "BACKGROUND")
			totem.bg:SetAllPoints()
			totem.bg:SetTexture(bdUI.media.flat)
			totem.bg.multiplier = 0.2
			self.TotemBar[i] = totem
		end

	elseif (class == "DEATHKNIGHT") then
		-- Necrostrike Indicator
		if (self:IsElementEnabled("NecroStrike")) then
			self.Health.NecroticOverlay = self.Resources.secondary:CreateTexture(nil, "OVERLAY", self.Resources.secondary)
			self.Health.NecroticOverlay:SetAllPoints(self.Resources.secondary)
			self.Health.NecroticOverlay:SetTexture(bdUI.media.flat)
			self.Health.NecroticOverlay:SetBlendMode("BLEND")
			self.Health.NecroticOverlay:SetVertexColor(0, 0, 0, 0.4)
			self.Health.NecroticOverlay:Hide()
			self.Resources.secondary:Show()
			function self.Health.NecroticOverlay.PostUpdate(amount)
				if (amount > 0) then
					self.Resources.secondary:Show()
				else
					self.Resources.secondary:Hide()
				end
			end
		end

		-- Rune Indicator
		for index = 1, 6 do
			local rune = CreateFrame('StatusBar', nil, self.Resources)
			local width = self.Resources:GetWidth() - (bdUI.border * 6) / 6
			rune:SetStatusBarTexture(bdUI.media.flat)
			rune:SetSize(width, config.resources_primary_height)
			if (index == 1) then
				rune:SetPoint('BOTTOMLEFT', self.Resources, 'BOTTOMLEFT', 0, 0)
			else
				rune:SetPoint('BOTTOMLEFT', self.runes[index - 1], 'BOTTOMRIGHT', bdUI.border, 0)
			end

			self.runes[index] = rune
		end		
	else
		-- also add stagger bar
		if (class == "MONK" and self:IsElementEnabled("Stagger")) then
			self.Stagger = CreateFrame('StatusBar', nil, self.Resources.secondary)
			self.Stagger:SetAllPoints()
			self.Resources.secondary:Show()
		end

		-- power for all other classes
		for index = 1, 10 do
			local bar = CreateFrame('StatusBar', nil, self.Resources)
			local width = self.Resources:GetWidth() - (bdUI.border * 10) / 10
			bar:SetStatusBarTexture(bdUI.media.flat)
			bar:SetSize(width, config.resources_primary_height)

			if (index == 1) then
				bar:SetPoint('BOTTOMLEFT', self.Resources, 'BOTTOMLEFT', 0, 0)
			else
				bar:SetPoint('BOTTOMLEFT', self.ClassPower[index - 1], 'BOTTOMRIGHT', bdUI.border, 0)
			end

			self.ClassPower[index] = bar
		end

		-- resize available bars
		function self.ClassPower:PostUpdate(cur, max, changed, powerType)
			if (not self.isEnabled) then
				self.Resources:Hide()
			else
				self.Resources:Show()
				if (changed) then
					for index = 1, max do
						local width = self.Resources:GetWidth() - (bdUI.border * max) / max
						bar:SetSize(width, config.resources_primary_height)
					end
				end
			end
		end
	end
end