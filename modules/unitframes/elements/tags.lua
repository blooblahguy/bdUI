local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")
local oUF = bdUI.oUF

-- creates one tag by location
local function location_tag(self, unit, location)
	local name = unit.."_"..location

	self.tags[name] = self.TextHolder:CreateFontString(nil, "OVERLAY")
	self.tags[name]:SetFontObject(bdUI:get_font(10, "THINOUTLINE"))
	self.tags[name]:SetPoint("CENTER", self.TextHolder)

	oUF.Tags.Events['bdUI:'..name] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_NAME_UPDATE UNIT_POWER_UPDATE UNIT_MAXPOWER PLAYER_TARGET_CHANGED PLAYER_REGEN_DISABLED PLAYER_REGEN_ENABLED PLAYER_UPDATE_RESTING UNIT_HEALTH UNIT_CONNECTION UNIT_COMBAT UNIT_FLAGS"
	oUF.Tags.Methods["bdUI:"..name] = function(unit)
		return ""
	end

	local config = mod:get_save()
	self:Tag(self.tags[name], config[name])
end

-- creates and positions all tags
function mod:create_location_tags(self, unit)
	self.tags = {}

	local locs = {"outside_left", "inside_left", "inside_center", "inside_right", "outside_right", }
	for k, location in pairs(locs) do
		location_tag(self, unit, location)
	end

	self.tags[unit.."_outside_left"]:SetPoint("RIGHT", self.TextHolder, "LEFT", -8, 0)

	self.tags[unit.."_inside_left"]:SetPoint("LEFT", self.TextHolder, 5, 0)

	self.tags[unit.."_inside_center"]:SetPoint("CENTER", self.TextHolder)

	self.tags[unit.."_inside_right"]:SetPoint("RIGHT", self.TextHolder, -5, 0)

	self.tags[unit.."_outside_right"]:SetPoint("LEFT", self.TextHolder, "RIGHT", 8, 0)
	

	mod:update_tags(self, unit)
end

-- callback from config
function mod:update_tags(self, unit)
	local config = mod:get_save()
	local locs = {"outside_left", "inside_left", "inside_center", "inside_right", "outside_right", }
	for k, location in pairs(locs) do
		local name = unit.."_"..location
		self:Tag(self.tags[name], config[name])
	end

	if (unit == "player" or unit == "target") then
		local big_size = math.restrict(config.playertargetheight * 0.4, 10, config.playertargetheight)
		local normal_size = math.restrict(config.playertargetheight * 0.34, 10, config.playertargetheight)

		for k, location in pairs(locs) do
			local name = unit.."_"..location
			self.tags[name]:SetFontObject(bdUI:get_font(normal_size, "THINOUTLINE"))
		end

		self.tags[unit.."_outside_left"]:SetFontObject(bdUI:get_font(big_size, "THINOUTLINE"))
		self.tags[unit.."_outside_right"]:SetFontObject(bdUI:get_font(big_size, "THINOUTLINE"))
	end

	self:UpdateTags()
end

-- make all tags in one file now
function mod.create_all_tags(self, unit)
	-- classification
	oUF.Tags.Events["bd:rarity"] = "UNIT_NAME_UPDATE UNIT_THREAT_SITUATION_UPDATE PLAYER_TARGET_CHANGED"
	oUF.Tags.Methods["bd:rarity"] = function(unit, r)
		local c = UnitClassification(r or unit)
		
		if(c == 'rare') then
			c = 'R'
		elseif(c == 'rareelite') then
			c = 'R+'
		elseif(c == 'elite') then
			c = '+'
		elseif(c == 'worldboss') then
			c = 'B'
		elseif(c == 'minus') then
			c = '-'
		else
			c = false
		end

		if (c) then
			return "|cffbbbbbb"..c.."|r" 
		end
		return ""
	end
	-- name
	-- combat
	-- resting
	-- current hp
	oUF.Tags.Events['bd:curhp'] = 'UNIT_HEALTH UNIT_MAXHEALTH'
	oUF.Tags.Methods['bd:curhp'] = function(unit)
		local hp, hpMax = UnitHealth(unit), UnitHealthMax(unit)
		return bdUI:numberize(hp)
	end

	-- hp color hex
	-- start the hex string
	oUF.Tags.Events['hpcolor'] = 'UNIT_HEALTH UNIT_MAXHEALTH'
	oUF.Tags.Methods['hpcolor'] = function(unit)
		local hp, hpMax = UnitHealth(unit), UnitHealthMax(unit)

		if hpMax == 0 then return "|cffFFFFFF" end
		if (UnitIsDead(unit) or UnitIsGhost(unit)) then return "|cffFF00000|r" end

		local hpPercent = bdUI:round(hp / hpMax * 100)
		local r, g, b = bdUI:ColorGradient(hpPercent / 100, 1,0,0, 1,.5,0, 1, 1, 1)
		local hex = RGBPercToHex(r, g, b)

		return "|cff"..hex
	end
	-- end the hex string
	oUF.Tags.Events['/hpcolor'] = ''
	oUF.Tags.Methods['/hpcolor'] = function(unit)
		return "|r"
	end

	-- power
	oUF.Tags.Events['bd:curpp'] = 'UNIT_POWER_UPDATE UNIT_MAXPOWER PLAYER_TARGET_CHANGED'
	oUF.Tags.Methods['bdUI:curpp'] = function(unit)
		local pType, pToken = UnitPowerType(unit)
		local hex = RGBPercToHex(unpack(oUF.colors.power[pType]))
		local pp, ppMax = UnitPower(unit), UnitPowerMax(unit)
		if (ppMax == 0) then return "" end
		return "|cff"..hex..bdUI:round(pp / ppMax * 100).."|r"
	end

	-- power color hex
	-- start the hex string
	oUF.Tags.Events['ppcolor'] = 'UNIT_POWER_UPDATE UNIT_MAXPOWER PLAYER_TARGET_CHANGED'
	oUF.Tags.Methods['ppcolor'] = function(unit)
		local pType, pToken = UnitPowerType(unit)
		local hex = RGBPercToHex(unpack(oUF.colors.power[pType]))
		return "|cff"..hex
	end
	-- end the hex string
	oUF.Tags.Events['/ppcolor'] = ''
	oUF.Tags.Methods['/ppcolor'] = function(unit)
		return "|r"
	end

end