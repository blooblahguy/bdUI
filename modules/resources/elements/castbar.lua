local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Player Bars")
local config
local class = select(2, UnitClass("player"))
local padding = 4

-- local function castbar_kickable(self)
-- 	if (self.notInterruptible) then
-- 		if (self.Icon) then
-- 			self.Icon:SetDesaturated(1)
-- 		end
-- 		self:SetStatusBarColor(0.7, 0.7, 0.7, 1)
-- 	else
-- 		if (self.Icon) then
-- 			self.Icon:SetDesaturated(false)
-- 		end
-- 		self:SetStatusBarColor(.1, .4, .7, 1)
-- 	end
-- end

function mod:create_castbar(self)
	local config = mod:get_save()
	local font_size = math.restrict(config.castbar_height * config.text_scale, 6, 16)
	local color = RAID_CLASS_COLORS[select(2, UnitClass("player"))]

	-- since it shows and hides
	self.CastbarHolder = CreateFrame("frame", nil, self)

	self.Castbar = CreateFrame("StatusBar", nil, self.CastbarHolder)
	self.Castbar:SetFrameLevel(3)
	self.Castbar:SetStatusBarTexture(bdUI.media.flat)
	self.Castbar:SetStatusBarColor(color.r, color.g, color.b)
	self.Castbar:SetPoint("TOPRIGHT", self.CastbarHolder)
	self.Castbar:SetPoint("BOTTOMRIGHT", self.CastbarHolder)
	self.Castbar:SetWidth(config.resources_width - config.castbar_height - bdUI.border)
	
	self.Castbar.Text = self.Castbar:CreateFontString(nil, "OVERLAY")
	self.Castbar.Text:SetFontObject(bdUI:get_font(font_size))
	self.Castbar.Text:SetJustifyV("MIDDLE")

	self.Castbar.Icon = self.Castbar:CreateTexture(nil, "OVERLAY")
	self.Castbar.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	self.Castbar.Icon:SetDrawLayer('ARTWORK')
	self.Castbar.Icon.bg = self.Castbar:CreateTexture(nil, "BORDER")
	self.Castbar.Icon.bg:SetTexture(bdUI.media.flat)
	self.Castbar.Icon.bg:SetVertexColor(unpack(bdUI.media.border))
	self.Castbar.Icon.bg:SetPoint("TOPLEFT", self.Castbar.Icon, "TOPLEFT", -bdUI.border, bdUI.border)
	self.Castbar.Icon.bg:SetPoint("BOTTOMRIGHT", self.Castbar.Icon, "BOTTOMRIGHT", bdUI.border, -bdUI.border)

	self.Castbar.SafeZone = self.Castbar:CreateTexture(nil, "OVERLAY")
	self.Castbar.SafeZone:SetVertexColor(0.85, 0.10, 0.10, 0.20)
	self.Castbar.SafeZone:SetTexture(bdUI.media.flat)

	self.Castbar.Time = self.Castbar:CreateFontString(nil, "OVERLAY")
	self.Castbar.Time:SetFontObject(bdUI:get_font(font_size))

	self.Castbar.MaxTime = self.Castbar:CreateFontString(nil, "OVERLAY")
	self.Castbar.MaxTime:SetFontObject(bdUI:get_font(font_size))

	-- Positioning
	self.Castbar.Time:SetPoint("LEFT", self.Castbar, "LEFT", padding, 0)
	self.Castbar.Time:SetJustifyH("LEFT")
	self.Castbar.MaxTime:SetPoint("RIGHT", self.Castbar, "RIGHT", -padding, 0)
	self.Castbar.MaxTime:SetJustifyH("RIGHT")
	self.Castbar.Text:SetPoint("CENTER", self.Castbar, "CENTER", -padding, 0)
	self.Castbar.Icon:SetPoint("TOPRIGHT", self.Castbar,"TOPLEFT", -bdUI.border, 0)
	self.Castbar.Icon:SetSize(config.castbar_height, config.castbar_height)

	-- self.Castbar.PostChannelStart = castbar_kickable
	-- self.Castbar.PostChannelUpdate = castbar_kickable
	-- self.Castbar.PostCastStart = castbar_kickable
	-- self.Castbar.PostCastDelayed = castbar_kickable
	-- self.Castbar.PostCastNotInterruptible = castbar_kickable
	-- self.Castbar.PostCastInterruptible = castbar_kickable

	-- bdMove:set_moveable(self.Castbar, unit.." Castbar")
	bdUI:set_backdrop(self.Castbar)

	self.Castbar.PostCastStart = function(castbar, unit)
		castbar.MaxTime:SetText(bdUI:round(castbar.max, 1))
	end
end

-- don't really need this
local function path() end

local function enable(config)
	if (not config.castbar_enable) then return false end

	-- mod.player:EnableElement("Castbar")
	mod.player.CastbarHolder:Show()

	return true
end

local function disable(config)
	-- mod.player:DisableElement("Castbar")
	mod.player.CastbarHolder:Hide()
end

mod:add_element('castbars', path, enable, disable)