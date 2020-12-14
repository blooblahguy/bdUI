local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Buffs and Debuffs")
local config

local total = 0
local debuff_colors = {
	['Magic'] = { 0.20, 0.60, 1.00 },
	['Curse'] = { 0.60, 0.00, 1.00 },
	['Disease'] = { 0.60, 0.40, 0 },
	['Poison'] = { 0.00, 0.60, 0 },
	['None'] = { 0.6, 0.1, 0.2 }
}

local counterAnchor = {}
counterAnchor['BOTTOM'] = "TOP"
counterAnchor['LEFT'] = "RIGHT"
counterAnchor['TOP'] = "BOTTOM"
counterAnchor['RIGHT'] = "LEFT"
counterSpacing = {}
counterSpacing["TOP"] = {0, 4}
counterSpacing["LEFT"] = {-4, 0}
counterSpacing["RIGHT"] = {4, 0}
counterSpacing["BOTTOM"] = {0, -4}


-- parent frames
local bdBuffs = CreateFrame("frame", "Buffs", UIParent, "SecureAuraHeaderTemplate")
bdBuffs:SetPoint('TOPRIGHT', Minimap, "TOPLEFT", -10, -40)

local bdDebuffs = CreateFrame("frame", "Debuffs", UIParent, "SecureAuraHeaderTemplate")
bdDebuffs:SetPoint('LEFT', bdParent, "CENTER", -20, -110)

-- fonts
local bufffont = CreateFont("BD_BUFFS_FONT")
bufffont:SetShadowColor(0, 0, 0)
bufffont:SetShadowOffset(1, -1)

local debufffont = CreateFont("BD_DEBUFFS_FONT")
debufffont:SetShadowColor(0, 0, 0)
debufffont:SetShadowOffset(1, -1)

--===============================================
-- Time Function
--===============================================
local function set_time(button, duration)
	local seconds = Round(duration)
	local mins = Round(seconds/60);
	local hours = Round(mins/60, 1);

	if(duration <= 0) then
		button.duration:SetText('')
	else
		if (hours and hours > 1) then
			button.duration:SetText(hours.."h")
		elseif (mins and mins > 0) then
			button.duration:SetText(mins.."m")
		else			
			button.duration:SetText(seconds.."s")
		end
	end
end

local function update_time(self, elapsed)
	self.total = self.total + elapsed
	if (self.total > 0.1) then
		if(self.duration_seconds) then
			self.duration_seconds = math.max(self.duration_seconds - self.total, 0)

			set_time(self, self.duration_seconds)
		end
		self.total = 0
	end
end

--==============================================
-- Auras
--==============================================
local function update_enchant(button, index)
	local offset = (strmatch(button:GetName(), '2$') and 6) or 2
	local duration, remaining = 600, 0
	local duration = select(offset, GetWeaponEnchantInfo())

	if not duration then return end

	button.texture:SetTexture(GetInventoryItemTexture('player', index))
	local quality = GetInventoryItemQuality('player', index)
	button._border:SetVertexColor(.1, .2, 6, 1)

	duration = duration / 1000
	set_time(button, duration)
end

local function update_aura(button, index)
	local unit = button:GetParent():GetAttribute('unit')
	local filter = button:GetParent():GetAttribute('filter')
	local name, texture, count, debuffType, duration, expiration, caster, isStealable, nameplateShowSelf, spellID, canApply, isBossDebuff, casterIsPlayer, nameplateShowAll, timeMod, effect1, effect2, effect3 = UnitAura(unit, index, filter)

	if (not name) then
		button:SetScript('OnUpdate', nil)
		return
	end

	button.texture:SetTexture(texture)
	if (not count) then
		count = 0
	end
	button.total = 0
	button.name = name
	button.count:SetText(count > 1 and count or '')
	button.duration_seconds = expiration - GetTime()

	-- color debuffs
	if (filter == "HARMFUL") then
		local color = debuff_colors['None']

		if debuffType and debuff_colors[debuffType] then
			color = debuff_colors[debuffType]
		end

		local r, g, b = unpack(color)

		button._border:SetVertexColor(r, g, b)
	end

	button:SetScript('OnUpdate', update_time)
end

function mod:create_aura(button, ...)
	local filter = button:GetParent():GetAttribute("filter")
	local auraType = filter

	button.filter = filter
	button.auraType = auraType == 'HELPFUL' and 'buffs' or 'debuffs' -- used to update cooldown text
	button.total = 0

	bdUI:set_backdrop(button)

	-- debuff default coloring
	if (filter == "HARMFUL") then
		button._border:SetVertexColor(.7,0,0,1)
	end

	-- texture
	button.texture = button:CreateTexture(nil, 'BORDER')
	button.texture:SetAllPoints()
	button.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)

	button.count = button:CreateFontString()
	button.count:SetPoint('BOTTOMRIGHT', -2, 2)
	button.count:SetFont(bdUI.media.font, 12, "OUTLINE")
	button.count:SetJustifyH("LEFT")

	button.duration = button:CreateFontString()
	button.duration:SetJustifyH("CENTER")

	if (filter == "HARMFUL") then
		button.duration:SetFontObject("BD_DEBUFFS_FONT")
		button.count:SetFontObject("BD_DEBUFFS_FONT")
		button.duration:SetPoint(counterAnchor[config.debufftimer], button, config.debufftimer, unpack(counterSpacing[config.debufftimer]))
	else
		button.duration:SetFontObject("BD_BUFFS_FONT")
		button.count:SetFontObject("BD_BUFFS_FONT")
		button.duration:SetPoint(counterAnchor[config.bufftimer], button, config.bufftimer, unpack(counterSpacing[config.bufftimer]))
	end

	button:SetScript('OnAttributeChanged', function(self, attribute, value)
		if (attribute == 'index') then
			update_aura(self, value)
		elseif (attribute == "target-slot") then
			update_enchant(self, value)
		end
	end)
end

--==============================================
-- Size the frames
--==============================================
function mod:size_frames(frame, size)
	local c = {frame:GetChildren()}
	for i = 1, #c do
		local child = c[i]
		child:SetSize(size, size)
	end
end

--==============================================
-- All Auras
--==============================================
function mod:common_headers(header, filter)
	-- assign to player
	header:SetAttribute('unit', 'player')
	header:SetAttribute("separateOwn", 1)
	header:SetAttribute('sortMethod', 'TIME')
	header:SetAttribute("filter", filter)
	header.filter = filter

	header:Show()
end

--==============================================
-- Buffs
--==============================================
function mod:update_buffs()
	local buffrows = math.ceil(20/config.buffperrow)
	local template = string.format('bdAuraTemplate%d', config.buffsize)

	-- they share some stuff
	mod:common_headers(bdBuffs, "HELPFUL")

	-- sizing
	bdBuffs:SetSize((config.buffsize + config.buffspacing + 2) * config.buffperrow, (config.buffsize + config.buffspacing + 2) * buffrows)
	bdBuffs:SetAttribute("template", template)
	bdBuffs:SetAttribute("style-width", config.buffsize)
	bdBuffs:SetAttribute("style-height", config.buffsize)
	bdBuffs:SetAttribute('wrapAfter', config.buffperrow)
	bdBuffs:SetAttribute("minWidth", (config.buffsize + config.buffspacing + 2) * config.buffperrow)
	bdBuffs:SetAttribute("minHeight", (config.buffsize + config.buffspacing + 2) * buffrows)
	
	-- Weapons
	bdBuffs:SetAttribute('consolidateDuration', -1)
	bdBuffs:SetAttribute('includeWeapons', 1)
	bdBuffs:SetAttribute('weaponTemplate', template)
	bdBuffs:SetAttribute('consolidateTo', 0)

	-- positioning
	if (config.buffhgrowth == "Left") then
		bdBuffs:SetAttribute('xOffset', -(config.buffsize + config.buffspacing + 2))
		bdBuffs:SetAttribute('sortDirection', "+")
		bdBuffs:SetAttribute('point', "TOPRIGHT")
	else
		bdBuffs:SetAttribute('xOffset', (config.buffsize + config.buffspacing + 2))
		bdBuffs:SetAttribute('sortDirection', "-")
		bdBuffs:SetAttribute('point', "TOPLEFT")
	end

	local yspacing = 2
	if (config.bufftimer == "LEFT" or config.bufftimer == "RIGHT") then
		yspacing = yspacing + config.buffsize + config.buffspacing
	else
		yspacing = yspacing + config.buffsize + config.buffspacing + config.bufffontsize + 6
	end
	
	if (config.buffvgrowth == "Upwards") then
		bdBuffs:SetAttribute('wrapYOffset', yspacing)

		if (config.buffhgrowth == "Left") then
			bdBuffs:SetAttribute('point', "BOTTOMRIGHT")
		else
			bdBuffs:SetAttribute('point', "BOTTOMLEFT")
		end
	else
		bdBuffs:SetAttribute('wrapYOffset', -yspacing)
	end

	-- size children
	mod:size_frames(bdBuffs, config.buffsize)
end

--==============================================
-- Debuffs
--==============================================
function mod:update_debuffs()
	local debuffrows = math.ceil(10/config.debuffperrow)
	local template = string.format('bdAuraTemplate%d', config.debuffsize)

	-- they share some stuff
	mod:common_headers(bdDebuffs, "HARMFUL")

	bdDebuffs:SetSize((config.debuffsize+config.debuffspacing+2)*config.debuffperrow, (config.debuffsize+config.debuffspacing+2)*debuffrows)
	bdDebuffs:SetAttribute("template", template)
	bdDebuffs:SetAttribute("style-width", config.debuffsize)
	bdDebuffs:SetAttribute("style-height", config.debuffsize)
	bdDebuffs:SetAttribute('wrapAfter', config.debuffperrow)
	bdDebuffs:SetAttribute("minWidth", (config.debuffsize+config.debuffspacing+2)*config.debuffperrow)
	bdDebuffs:SetAttribute("minHeight", (config.debuffsize+config.debuffspacing+2)*debuffrows)
	if (config.debuffhgrowth == "Left") then
		bdDebuffs:SetAttribute('xOffset', -(config.debuffsize+config.debuffspacing+2))
		bdDebuffs:SetAttribute('sortDirection', "+")
		bdDebuffs:SetAttribute('point', "TOPRIGHT")
	else
		bdDebuffs:SetAttribute('xOffset', (config.debuffsize+config.debuffspacing+2))
		bdDebuffs:SetAttribute('sortDirection', "-")
		bdDebuffs:SetAttribute('point', "TOPLEFT")
	end

	local yspacing = 2
	if (config.debufftimer == "LEFT" or config.debufftimer == "RIGHT") then
		yspacing = yspacing + config.debuffsize + config.debuffspacing
	else
		yspacing = yspacing + config.debuffsize + config.debuffspacing + config.debufffontsize + 6
	end
	

	if (config.debuffvgrowth == "Upwards") then
		bdDebuffs:SetAttribute('wrapYOffset', yspacing)

		if (config.debuffhgrowth == "Left") then
			bdDebuffs:SetAttribute('point', "BOTTOMRIGHT")
		else
			bdDebuffs:SetAttribute('point', "BOTTOMLEFT")
		end
	else
		bdDebuffs:SetAttribute('wrapYOffset', -yspacing)
	end

	-- size children
	mod:size_frames(bdDebuffs, config.debuffsize)
end

--===============================================
-- Config Callback
--===============================================
function mod:config_callback()
	config = mod:get_save()
	if (not config.enabled) then return end
	if (InCombatLockdown()) then return end

	-- font sizes
	bufffont:SetFont(bdUI.media.font, config.bufffontsize)
	debufffont:SetFont(bdUI.media.font, config.debufffontsize)

	-- buffs
	mod:update_buffs()
	
	-- debuffs
	mod:update_debuffs()

	-- drivers
	-- RegisterStateDriver(header, 'visibility', '[petbattle] hide; show')
	RegisterAttributeDriver(bdBuffs, 'unit', '[vehicleui] vehicle; player')
	RegisterAttributeDriver(bdDebuffs, 'unit', '[vehicleui] vehicle; player')
end

--===============================================
-- Initialize
--===============================================
function mod:initialize()
	config = mod:get_save()

	if (not config.enabled) then return end

	bdMove:set_moveable(bdBuffs)
	bdMove:set_moveable(bdDebuffs)

	local addonDisabler = CreateFrame("Frame", nil)
	addonDisabler:RegisterEvent("ADDON_LOADED")
	addonDisabler:SetScript("OnEvent", function(self, event, addon)
		BuffFrame:UnregisterAllEvents("UNIT_AURA")
		BuffFrame:Hide()
		TemporaryEnchantFrame:UnregisterAllEvents("UNIT_AURA")
		TemporaryEnchantFrame:Hide()
	end)

	mod:config_callback()
end