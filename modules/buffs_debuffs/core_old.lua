--===============================================
-- FUNCTIONS
--===============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Buffs & Debuffs")
local config

local debuff_colors = {
	['Magic'] = { 0.20, 0.60, 1.00 },
	['Curse'] = { 0.60, 0.00, 1.00 },
	['Disease'] = { 0.60, 0.40, 0 },
	['Poison'] = { 0.00, 0.60, 0 },
	['None'] = { 0.6, 0.1, 0.2 }
}

local bdBuffs = CreateFrame("frame", "Buffs", UIParent, "SecureAuraHeaderTemplate")
bdBuffs:SetPoint('TOPRIGHT', Minimap, "TOPLEFT", -10, -40)
local bufffont = CreateFont("BD_BUFFS_FONT")
bufffont:SetShadowColor(0, 0, 0)
bufffont:SetShadowOffset(1, -1)

local bdDebuffs = CreateFrame("frame", "Debuffs", UIParent, "SecureAuraHeaderTemplate")
bdDebuffs:SetPoint('LEFT', bdParent, "CENTER", -20, -110)
local debufffont = CreateFont("BD_DEBUFFS_FONT")
debufffont:SetShadowColor(0, 0, 0)
debufffont:SetShadowOffset(1, -1)

--===============================================
-- Time Functions
--===============================================
local function UpdateTime(self, elapsed)
	self.total = self.total + elapsed
	if (self.total > 0.1) then
		if(self.expiration) then
			self.expiration = math.max(self.expiration - self.total, 0)
			-- local seconds = 

			if(self.expiration <= 0) then
				self.duration:SetText('')
			else
				-- if (seconds < 10 or not config.decimalprec) then
				-- 	seconds = bdUI:round(seconds, 1)
				-- else
				-- end
				local seconds = Round(self.expiration)
				local mins = Round(seconds/60);
				local hours = Round(mins/60, 1);

				if (hours and hours > 1) then
					self.duration:SetText(hours.."h")
				elseif (mins and mins > 0) then
					self.duration:SetText(mins.."m")
				else			
					self.duration:SetText(seconds.."s")
				end
			
			end
		end
		self.total = 0
	end
end

--===============================================
-- Update Borders
--===============================================
local function UpdateAura(self, index, filter)
	local unit = self:GetParent():GetAttribute('unit')
	local filter = self:GetParent():GetAttribute('filter')
	local name, texture, count, debuffType, duration, expiration, caster, isStealable, nameplateShowSelf, spellID, canApply, isBossDebuff, casterIsPlayer, nameplateShowAll, timeMod, effect1, effect2, effect3 = UnitAura(unit, index, filter)
	if(name) then
		self.texture:SetTexture(texture)
		if (not count) then
			count = 0
		end
		self.total = 0
		self.name = name
		self.count:SetText(count > 1 and count or '')
		self.expiration = expiration - GetTime()

		if (filter == "HARMFUL") then
			local color = debuff_colors['None']

			if debuffType and debuff_colors[debuffType] then
				color = debuff_colors[debuffType]
			end

			local r, g, b = unpack(color)

			self._border:SetVertexColor(r, g, b)
		end

	end
end

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

--===============================================
-- Skin Buttons
--===============================================
local function InitiateAura(self, name, button)
	if(not string.match(name, '^child')) then return end
	local filter = button:GetParent():GetAttribute("filter")
	
	button.filter = filter
	button:SetScript('OnUpdate', UpdateTime)
	button:SetScript('OnAttributeChanged', function(self, attribute, value)
		if (attribute == 'index') then
			UpdateAura(self, value)
		end
	end)
	
	bdUI:set_backdrop(button)
	
	if (filter == "HARMFUL") then
		button._border:SetVertexColor(.7,0,0,1)
	end
	
	if (not button.texture) then
		button.texture = button:CreateTexture(nil, 'BORDER')
		button.texture:SetAllPoints()
		button.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	end

	if (not button.count) then
		button.count = button:CreateFontString()
		button.count:SetPoint('BOTTOMRIGHT', -2, 2)
		button.count:SetFont(bdUI.media.font, 12, "OUTLINE")
		button.count:SetJustifyH("LEFT")
	end

	if (not button.duration) then
		button.duration = button:CreateFontString()
		button.duration:SetJustifyH("CENTER")
	end

	if (filter == "HARMFUL") then
		button.duration:SetFontObject("BD_DEBUFFS_FONT")
		button.count:SetFontObject("BD_DEBUFFS_FONT")
		button.duration:SetPoint(counterAnchor[config.debufftimer], button, config.debufftimer, unpack(counterSpacing[config.debufftimer]))
	else
		button.duration:SetFontObject("BD_BUFFS_FONT")
		button.count:SetFontObject("BD_BUFFS_FONT")
		button.duration:SetPoint(counterAnchor[config.bufftimer], button, config.bufftimer, unpack(counterSpacing[config.bufftimer]))
	end
	
	UpdateAura(button, button:GetID(), filter)
end

--===============================================
-- Set secure header attributes
--===============================================
local function setHeaderAttributes(header, template, isBuff)
	config = mod:get_save()

	local s = function(...) header:SetAttribute(...) end
	header.filter = isBuff and "HELPFUL" or "HARMFUL"
	
	local template = string.format('bdBuffsTemplate%d', config.buffsize)
	
	if (isBuff) then
		header:SetAttribute('includeWeapons', 1)
		header:SetAttribute('weaponTemplate', template)
		header:SetAttribute('consolidateDuration', -1)
	end

	-- header:SetSize()
	
	bdMove:set_moveable(header)
	header:SetAttribute('unit', 'player')
	header:SetAttribute("filter", header.filter)
	header:SetAttribute("separateOwn", 1)
	header:SetAttribute('sortMethod', 'TIME')
    header:HookScript("OnAttributeChanged", InitiateAura)

	header:Show()
end

--===============================================
-- Resize Children
--===============================================
local function loopChildren(header,size)
	local c = {header:GetChildren()}
	for i = 1, #c do
		local child = c[i]
		child:SetSize(size, size)
	end
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

	local buffrows = math.ceil(20/config.buffperrow)
	bdBuffs:SetSize((config.buffsize+config.buffspacing+2)*config.buffperrow, (config.buffsize+config.buffspacing+2)*buffrows)
	bdBuffs:SetAttribute("template", ("bdBuffsTemplate%d"):format(config.buffsize))
	bdBuffs:SetAttribute("style-width", config.buffsize)
	bdBuffs:SetAttribute("style-height", config.buffsize)
	bdBuffs:SetAttribute('wrapAfter', config.buffperrow)
	bdBuffs:SetAttribute("minWidth", (config.buffsize+config.buffspacing+2)*config.buffperrow)
	bdBuffs:SetAttribute("minHeight", (config.buffsize+config.buffspacing+2)*buffrows)
	-- bdBuffs:SetAttribute('weaponTemplate', ("bdBuffsTemplate%d"):format(config.buffsize))
	-- bdBuffs:SetAttribute('includeWeapons', 1)

	-- local tempEnchant1 = bdBuffs:GetAttribute("tempEnchant1");
	-- if tempEnchant1 then
	-- 	if not tempEnchant1.tex then
	-- 		-- create your style
	-- 	end
	-- 	local hasMainHandEnchant, mainHandExpiration, mainHandCharges = GetWeaponEnchantInfo();
	-- 	if hasMainHandEnchant then
	-- 		local slotid = GetInventorySlotInfo("MainHandSlot");
	-- 		local icon = GetInventoryItemTexture("player", slotid);
	-- 		tempEnchant1.tex:SetTexture(icon);
	-- 		if mainHandCharges > 1 then tempEnchant1.txt:SetText(mainHandCharges); else tempEnchant1.txt:SetText("");end
	-- 		tempEnchant1.tex:Show();
	-- 		tempEnchant1.txt:Show();
	-- 	else
	-- 		tempEnchant1.tex:Hide();
	-- 		tempEnchant1.txt:Hide();
	-- 	end
	-- end

	if (config.buffhgrowth == "Left") then
		bdBuffs:SetAttribute('xOffset', -(config.buffsize+config.buffspacing+2))
		bdBuffs:SetAttribute('sortDirection', "+")
		bdBuffs:SetAttribute('point', "TOPRIGHT")
	else
		bdBuffs:SetAttribute('xOffset', (config.buffsize+config.buffspacing+2))
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

	loopChildren(bdBuffs, config.buffsize)

	local debuffrows = math.ceil(10/config.debuffperrow)
	bdDebuffs:SetSize((config.debuffsize+config.debuffspacing+2)*config.debuffperrow, (config.debuffsize+config.debuffspacing+2)*debuffrows)
	bdDebuffs:SetAttribute("template", ("bdDebuffsTemplate%d"):format(config.debuffsize))
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
	loopChildren(bdDebuffs,config.debuffsize)

	setHeaderAttributes(bdBuffs, "bdBuffsTemplate", true)
	setHeaderAttributes(bdDebuffs, "bdDebuffsTemplate", false)
end

--===============================================
-- Initialize
--===============================================
function mod:initialize()
	config = mod:get_save()
	if (not config.enabled) then return end

	setHeaderAttributes(bdBuffs, "bdBuffsTemplate", true)
	setHeaderAttributes(bdDebuffs, "bdDebuffsTemplate", false)
	
	-- show who casts each buff
	hooksecurefunc(GameTooltip, "SetUnitAura", function(self, unit, index, filter)
		local caster = select(7, UnitAura(unit, index, filter))
		
		local name = caster and UnitName(caster)
		if name then
			self:AddDoubleLine("Cast by:", name, nil, nil, nil, 1, 1, 1)
			self:Show()
		end
	end)
	
	local addonDisabler = CreateFrame("Frame", nil)
	addonDisabler:RegisterEvent("ADDON_LOADED")
	addonDisabler:SetScript("OnEvent", function(self, event, addon)
		BuffFrame:UnregisterAllEvents("UNIT_AURA")
		BuffFrame:Hide()
	end)

	mod:config_callback()
end