--===============================================
-- FUNCTIONS
--===============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Tooltips")

--===============================================
-- Custom functionality
-- place custom functionality here
--===============================================
-----------------------------------
-- Skinning default tooltips
-----------------------------------
function mod:skin(tooltip)
	bdUI:set_backdrop(tooltip)
	
	mod:strip(tooltip)
	tooltip:SetScale(1)
end

function mod:strip(frame)
	local regions = {frame:GetRegions()}

	for k, v in pairs(regions) do
		if (not v.protected) then
			if v:GetObjectType() == "Texture" then
				v:SetTexture(nil)
				v:SetAlpha(0)
				v:Hide()
				v.Show = noop
			end
		end
	end
end

function mod:getUnitColor(unit)
	unit = unit or "mouseover"
	local reaction = UnitReaction(unit, "player") or 5
	
	if UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		local color = RAID_CLASS_COLORS[class]
		return color.r, color.g, color.b
	elseif UnitCanAttack("player", unit) then
		if UnitIsDead(unit) then
			return 136/255, 136/255, 136/255
		else
			if reaction<4 then
				return 1, 68/255, 68/255
			elseif reaction==4 then
				return 1, 1, 68/255
			end
		end
	else
		if (reaction < 4) then
			return 48/255, 113/255, 191/255
		-- elseif (UnitClass(unit)) then
		-- 	local _, class = UnitClass(unit)
		-- 	local color = RAID_CLASS_COLORS[class]
		-- 	return color.r, color.g, color.b 
		else
			return 1, 1, 1
		end
	end
end

------------------------------------
-- Colors
------------------------------------
local colors = {}
colors.tapped = {.6,.6,.6}
colors.offline = {.6,.6,.6}
colors.reaction = {}
colors.class = {}

-- class colors
for eclass, color in next, RAID_CLASS_COLORS do
	if not colors.class[eclass] then
		colors.class[eclass] = {color.r, color.g, color.b}
	end
end

-- faction colors
for eclass, color in next, FACTION_BAR_COLORS do
	if not colors.reaction[eclass] then
		colors.reaction[eclass] = {color.r, color.g, color.b}
	end
end

-- returns a 1-6 of how this unit reacts to you
function mod:getUnitReactionIndex(unit)
	if UnitIsDeadOrGhost(unit) then
		return 7
	elseif UnitIsPlayer(unit) or UnitPlayerControlled(unit) then
		if UnitCanAttack(unit, "player") then
			return UnitCanAttack("player", unit) and 2 or 3
		elseif UnitCanAttack("player", unit) then
			return 4
		elseif UnitIsPVP(unit) and not UnitIsPVPSanctuary(unit) and not UnitIsPVPSanctuary("player") then
			return 5
		else
			return 6
		end
	elseif UnitIsTapDenied(unit) then
		return 1
	else
		local reaction = UnitReaction(unit, "player") or 3
		return (reaction > 5 and 5) or (reaction < 2 and 2) or reaction
	end
end

function mod:getReactionColor(unit)
	if (not UnitExists(unit)) then
		return unpack(colors.tapped)
	end
	if UnitIsPlayer(unit) then
		return unpack(colors.class[select(2, UnitClass(unit))])
	elseif UnitIsTapDenied(unit) then
		return unpack(colors.tapped)
	elseif (colors.reaction[UnitReaction(unit, 'player')]) then
		return unpack(colors.reaction[UnitReaction(unit, 'player')])
	end
end
