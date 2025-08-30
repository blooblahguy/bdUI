local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Player Bars")

local oUF = bdUI.oUF
local playerName = UnitName("player")
local media = bdUI.media
local _, class = UnitClass("player")
local classColor = RAID_CLASS_COLORS[class]
local config

local function get_width(maxWidth, number)
	return (maxWidth - (bdUI.border * (number - 1))) / number
end

function mod:create_class_power(self)
	local config = mod:get_save()
	local font_size = math.restrict(config.castbar_height * config.text_scale, 6, 16)
	local color = RAID_CLASS_COLORS[select(2, UnitClass("player"))]

	-- Mists of Pandaria warlock power types that might not be in PowerBarColor
	if not self.colors.power.BURNING_EMBERS then
		self.colors.power.BURNING_EMBERS = oUF:CreateColor(255, 128, 0) -- Orange color for burning embers
	end
	if not self.colors.power.DEMONIC_FURY then
		self.colors.power.DEMONIC_FURY = oUF:CreateColor(128, 0, 255) -- Purple color for demonic fury
	end

	-- Add fallback mappings for these power types
	self.colors.power[14] = self.colors.power.BURNING_EMBERS -- POWERTYPE_BURNING_EMBERS
	self.colors.power[15] = self.colors.power.DEMONIC_FURY -- POWERTYPE_DEMONIC_FURY

	-- since it shows and hides
	self.ClassPowerHolder = CreateFrame("frame", nil, self)
	self.ClassPowerHolder:SetSize(config.resources_width, config.power_height)
	-- self.ClassPowerHolder:SetTexture(bdUI.media.smooth)
	-- bdUI:set_backdrop(self.ClassPowerHolder)

	-- Create ClassPower element using oUF
	self.ClassPower = {}
	local last = nil
	for i = 1, 14 do
		local bar = CreateFrame("StatusBar", nil, self.ClassPowerHolder)
		bar:SetSize(get_width(self.ClassPowerHolder:GetWidth(), 14), self.ClassPowerHolder:GetHeight())
		bar.__owner = self
		bar:SetStatusBarTexture(media.flat)
		bar:SetMinMaxValues(0, 1)
		bar:EnableMouse(false)
		bar:SetStatusBarColor(1, 0, 0)
		bdUI:set_backdrop(bar)

		-- Text display
		-- bar.text = bar:CreateFontString(nil, "OVERLAY")
		-- bar.text:SetFontObject(bdUI:get_font(10, "THINOUTLINE"))
		-- bar.text:SetJustifyV("MIDDLE")
		-- bar.text:SetPoint("CENTER", bar)
		if (last == nil) then
			bar:SetPoint("LEFT", self.ClassPowerHolder, "LEFT", 0, 0)
		else
			bar:SetPoint("LEFT", last, "RIGHT", bdUI.border, 0)
		end

		last = bar

		self.ClassPower[i] = bar
	end

	-- Post update callback
	self.ClassPower.PostUpdate = function(element, cur, max, hasMaxChanged, powerType)
		if (not cur or not max) then return end
		if (hasMaxChanged) then
			for i = 1, 14 do
				local bar = element[i]
				if (i <= max) then
					bar:Show()
					bar:SetWidth(get_width(self.ClassPowerHolder:GetWidth(), max))
				else
					bar:Hide()
				end
			end
		end

		for i = 1, max do
			local bar = element[i]
			if (i <= cur) then
				bar:SetAlpha(1)
			else
				bar:SetAlpha(0.4)
			end
		end
		-- for i = 1, 14 do
		-- 	local bar = element[i]
		-- 	if (i <= max) then
		-- 		bar:Show()
		-- 		bar:SetWidth(config.resources_width / max)
		-- 	else
		-- 		bar:Hide()
		-- 	end
		-- end

		-- for i = 1, #element do
		-- 	local bar = element[i]
		-- 	if bar then
		-- 		if cur and max and max > 0 and i <= max then
		-- 			bar.text:SetText(bdUI:numberize(cur, 1))
		-- 		else
		-- 			bar.text:SetText("")
		-- 		end
		-- 	end
		-- end
	end
end

local function path()
	-- This will be handled by oUF ClassPower element
end

local function enable()
	-- if not mod.config.class_power_enable then return end

	-- Enable the oUF ClassPower element
	-- mod.ouf:EnableElement("ClassPower")

	-- Show the bar
	if (mod.ouf.ClassPowerHolder) then
		mod.ouf.ClassPowerHolder:Show()
	end

	return true
end

local function disable()
	-- mod.ouf:DisableElement("ClassPower")

	if (mod.ouf.ClassPowerHolder) then
		mod.ouf.ClassPowerHolder:Hide()
	end
end

mod:add_element('class_power', path, enable, disable)
