local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Buffs and Debuffs")
local config
local aura_array = {}
aura_array["buffs"] = {}
aura_array["debuffs"] = {}

local buffs = CreateFrame("frame", "bdBuffs", UIParent)
buffs:RegisterUnitEvent("UNIT_AURA", "player", "vehicle")
buffs:RegisterEvent("GROUP_ROSTER_UPDATE")
buffs:RegisterEvent("PLAYER_ENTERING_WORLD")
buffs:SetPoint("CENTER")
buffs:SetSize(20, 20)
bdUI:set_backdrop(buffs)
-- buffs:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")

local debuffs = CreateFrame("frame", "bdDebuffs", UIParent)
local enchants = CreateFrame("frame", "bdEnchants", UIParent)

local function create_aura_button(filter, index, parent)
	local helpful = (filter == "HELPFUL")

	template = helpful and "bdUI_BuffButtonTemplate" or "DebuffButtonTemplate"
	local name = helpful and "bdBuff"..index or "bdDebuff"..index

	local button = CreateFrame("Button", name, parent, template)
	print(button:GetScript("OnEnter"))
	button:SetID(index)
	button:SetSize(30, 30)
	button:EnableMouse(true)
	button.parent = parent
	button.unit = "player"
	button.filter = filter
	button.exitTime = nil
	button:Show()
	bdUI:set_backdrop(button)

	button.Icon = button:CreateTexture(nil, "BACKGROUND")
	button.Icon:SetAllPoints()

	-- for k, v in pairs(button) do
	-- 	print(k)
	-- end

	if (helpful) then
		aura_array['buffs'][index] = button
	else
		aura_array['debuffs'][index] = button
	end

	return button
end

local function update_aura(name, unit, index, filter, texture, count, debuffType, duration, expirationTime)
	local button
	if (filter == "HELPFUL") then
		button = aura_array['buffs'][index] or create_aura_button(filter, index, buffs)
	else
		button = aura_array['debuffs'][index] or create_aura_button(filter, index, debuffs)
	end

	button.Icon:SetTexture(texture)
	button.auraName = name

	print(index, filter, texture, count, debuffType)

	-- if ( count > 1 ) then
	-- 	button.count:SetText(count)
	-- 	button.count:Show()
	-- else
	-- 	button.count:Hide()
	-- end
end

local function position_frames(parent, frame_table)
	local last
	for i = 1, #frame_table do
		local button = frame_table[i]
		button:ClearAllPoints()
		if (i == 1) then
			button:SetPoint("RIGHT", parent, "RIGHT")
		else
			button:SetPoint("RIGHT", last, "LEFT", -10)
		end

		last = button
	end
end

local function update_buffs(unit)
	unit = unit or "player"
	-- print(...)
	for index = 1, BUFF_MAX_DISPLAY do
		local name, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitBuff(unit, index)
		if (not name) then break end

		print(name)
		-- print(icon)
		-- print(count, debuffType)
		update_aura(name, unit, index, "HELPFUL", icon, count, debuffType, duration, expirationTime)
	end

	position_frames(buffs, aura_array['buffs'])
end


function bdUIBuffButton_OnClick(self)
				
end

function mod:config_callback()
	config = mod:get_save()
	if (not config.enabled) then return end
	if (InCombatLockdown()) then return end

end

function mod:initialize()
	config = mod:get_save()
	if (not config.enabled) then return end

	buffs:SetScript("OnEvent", function(self, event, ...)
		update_buffs(...)
	end)

	for i = 1, 20 do

	end
end