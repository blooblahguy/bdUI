local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Player Bars")

local playerName = UnitName("player")
local media = bdUI.media
local _, class = UnitClass("player")
local classColor = RAID_CLASS_COLORS[class]
local mainSpeed, offSpeed = UnitAttackSpeed("player")
local mainLastHit, offLastHit = 0, 0
local mainNextHit, offNextHit = 0, 0
local total = 0
local mainhand, offhand
local holder

-- spells we need to watch or reset on
local queue = {}
local resetSpells = {}
local spells = {
	["Heroic Strike"] = 0,
	["Cleave"] = 0,
	["Maul"] = 0,
	["Slam"] = 0,
	["Raptor Strike"] = 0,
}
local spellTypes = {
	["Heroic Strike"] = 1,
	["Cleave"] = 2,
	["Maul"] = 1,
	["Raptor Strike"] = 1,
}

-- set bar color back to class
local function reset_color(bar)
	bar:SetStatusBarColor(classColor.r, classColor.g, classColor.b)
end

-- color based on queued spell type
local function special_color(bar, colorType)
	if (colorType == 1) then
		bar:SetStatusBarColor(unpack(config.special_1_color))
	elseif (colorType == 2) then
		bar:SetStatusBarColor(unpack(config.special_2_color))
	end
end

-- bar holder
local function create_bar(name)
	local bar = CreateFrame("StatusBar", name, holder)
	bar:SetStatusBarTexture(media.smooth)
	bar:SetMinMaxValues(0, 1)
	bar:SetWidth(config.resources_width)
	bar:SetValue(1)
	reset_color(bar)
	bdUI:set_backdrop(bar)

	return bar
end

-- we need to refresh this when gear changes
local function store_spell_info()
	-- loop through tracked spells
	for name, v in pairs(spells) do
		-- check if we have their id
		local id = select(7, GetSpellInfo(name))
		if (id) then

			-- if so, store the id, let it know to track them
			spells[name] = id
			resetSpells[id] = true
			if (spellTypes[name]) then
				-- if we should be coloring based on this, locate the spell on the actionbar
				queue[name] = C_ActionBar.FindSpellActionButtons(id) or 0
			end
		end
	end
end

-- comes from combat log
local function combat_log(...)
	-- print(sourceName)
	local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...
	if (sourceName ~= playerName) then return end -- only interested in player

	-- swing times
	if (subevent == "SWING_DAMAGE" or subevent == "SWING_MISSED") then
		local amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(12, ...)
		-- if (isOffHand == nil) then return end -- this was some other swing event that wasn't actually a weapon

		-- now update bar last-hits
		local hand = isOffHand and "offhand" or "mainhand"
		if (hand == "mainhand") then
			mainLastHit = GetTime()
			-- mainNextHit = mainLastHit + mainSpeed
		else
			offLastHit = GetTime()
			-- offNextHit = offLastHit + offSpeed
		end
	-- specific spell cast
	elseif (subevent == "SPELL_CAST_SUCCESS" or subevent == "SPELL_MISSED") then
		spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical = select(12, ...)
		if (not resetSpells[spellId]) then return end

		-- reset the mainhand
		mainLastHit = GetTime()
	end
end

local function mainhand_update(self, elapsed)
	self.text:SetText(bdUI:round(mainSpeed, 1))
	local progress = math.min(math.abs((mainLastHit + mainSpeed) - mainSpeed - GetTime()), mainSpeed)
	self:SetValue(progress)

	if (total > 1) then
		local speed = UnitAttackSpeed("player")
		local down, up, lagHome, lagWorld = GetNetStats()
		
		local lagpct = lagHome / (speed * 1000)
		self.latency:SetWidth(self:GetWidth() * lagpct)
	end
end

local function offhand_update(self, elapsed)
	if (not offSpeed) then return end
	local progress = math.min(math.abs((offLastHit + offSpeed) - offSpeed - GetTime()), offSpeed)
	self:SetValue(progress)
end

local function path()
	mod.config = mod:get_save()
	config = mod.config
end

local function enable()
	mod.config = mod:get_save()
	config = mod.config

	if (not mod.config.swingbar_enable) then return end

	holder = holder or CreateFrame("frame", nil, mod.Resources)

	-- create bars
	if (not mainhand) then
		-- mainhand
		mainhand = create_bar("bdSTMainhand")
		mainhand:SetHeight(config.mainhand_height)
		mainhand.text = mainhand:CreateFontString(nil, "OVERLAY")
		mainhand.text:SetFontObject(bdUI:get_font(12, "OUTLINE"))
		mainhand.text:SetPoint("LEFT", 4, 0)
		mainhand.latency = mainhand:CreateTexture(nil, "OVERLAY")
		mainhand.latency:SetTexture(media.flat)
		mainhand.latency:SetVertexColor(1, 0, 0, 0.5)
		mainhand.latency:SetHeight(mainhand:GetHeight())
		mainhand.latency:SetPoint("RIGHT")

		-- offhand
		offhand = create_bar("bdSTOffhand")
		offhand:SetHeight(config.offhand_height)
	end

	-- holder position
	bdUI:frame_group(holder, "downwards", mainhand, offhand)

	-- update gear changes
	store_spell_info()

	holder:RegisterEvent("PLAYER_REGEN_ENABLED")
	holder:RegisterEvent("PLAYER_REGEN_DISABLED")
	holder:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	holder:RegisterEvent("ACTIONBAR_UPDATE_STATE")
	holder:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
	holder:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
	holder:RegisterEvent("PLAYER_ENTERING_WORLD")
	holder:SetScript("OnEvent", function(self, event, ...)
		if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
			path(CombatLogGetCurrentEventInfo())
		elseif (event == "ACTIONBAR_UPDATE_STATE") then
			-- color the bar based on action queued
			reset_color(mainhand)
			for name, slot in pairs(queue) do
				if (name and queue[name] and queue[name][1] and IsCurrentAction(queue[name][1])) then
					special_color(mainhand, spellTypes[name])
				end
			end
		elseif (event == "ACTIONBAR_SLOT_CHANGED" or event == "ACTIONBAR_PAGE_CHANGED") then
			store_spell_info()
		elseif (event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_ENTERING_WORLD") then
			for k, frame in pairs({holder:GetChildren()}) do
				if (UnitAffectingCombat("player")) then
					frame:SetAlpha(config.swing_ic_alpha)
					if (config.swing_ooc_alpha == 0) then
						frame:Show()
					end
				else
					frame:SetAlpha(config.swing_ooc_alpha)
					if (config.swing_ooc_alpha == 0) then
						frame:Hide()
					end
				end
			end
		end
	end)

	-- onupdates
	mainhand:SetScript("OnUpdate", mainhand_update)
	offhand:SetScript("OnUpdate", offhand_update)

	-- lets check haste changes
	holder:SetScript("OnUpdate", function(self, elapsed)
		total = total + elapsed
		if (total > 0.1) then
			total = 0
			mainSpeed, offSpeed = UnitAttackSpeed("player")

			mainhand:SetMinMaxValues(0, mainSpeed)
			if (offSpeed) then
				offhand:Show()
				offhand:SetMinMaxValues(0, offSpeed)
			else
				offhand:Hide()
			end
		end
	end)

	holder.mainhand = mainhand
	holder.offhand = offhand
	mod.swing_timer = holder

	return true
end
local function disable()
	holder:UnregisterEvent("PLAYER_REGEN_ENABLED")
	holder:UnregisterEvent("PLAYER_REGEN_DISABLED")
	holder:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	holder:UnregisterEvent("ACTIONBAR_UPDATE_STATE")
	holder:UnregisterEvent("ACTIONBAR_SLOT_CHANGED")
	holder:UnregisterEvent("ACTIONBAR_PAGE_CHANGED")
	holder:UnregisterEvent("PLAYER_ENTERING_WORLD")
	holder:SetScript("OnUpdate", function() return end)
	if (mainhand) then
		mainhand:SetScript("OnUpdate", function() return end)
		offhand:SetScript("OnUpdate", function() return end)
	end

	holder:Hide()
end

mod:add_element('filters', path, enable, disable)