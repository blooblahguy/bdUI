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
	if (not tooltip.background) then
		bdUI:set_backdrop(tooltip)
	end
	
	mod:strip(tooltip)
	tooltip:SetScale(1)
end

function mod:strip(frame)
	local regions = {frame:GetRegions()}

	-- frame:DisableDrawLayer("BACKGROUND")
	frame:DisableDrawLayer("BORDER")

	for k, v in pairs(regions) do
		if (not v.protected) then
			-- print(v:GetObjectType())
			if v:GetObjectType() == "Texture" then
				v:SetTexture(nil)
				v:SetAlpha(0)
				v:Hide()
				v.Show = noop
			end
		end
	end
end

function mod:getcolor()
	local reaction = UnitReaction("mouseover", "player") or 5
	
	if UnitIsPlayer("mouseover") then
		local _, class = UnitClass("mouseover")
		local color = RAID_CLASS_COLORS[class]
		return color.r, color.g, color.b
	elseif UnitCanAttack("player", "mouseover") then
		if UnitIsDead("mouseover") then
			return 136/255, 136/255, 136/255
		else
			if reaction<4 then
				return 1, 68/255, 68/255
			elseif reaction==4 then
				return 1, 1, 68/255
			end
		end
	else
		if reaction<4 then
			return 48/255, 113/255, 191/255
		else
			return 1, 1, 1
		end
	end
end

------------------------------------
-- Enhanced Gametooltip - credit to RantTooltip
------------------------------------
local wrapText = function(text)
	if text:len() >= 45 then
		for str in text:gmatch("..%s..") do
			local last = text:gsub("(.*\n)(.*)", "%2")
			local startPos = last:find(str)
			if startPos and startPos >= 45 then
				local newText = last:sub(1, startPos+1).."\n"..last:sub(startPos+3, last:len())
				text = text:gsub(last, newText)
			end
		end
	end
	return text
end

GameTooltip["GetLine"] = function(self, num)
	if type(num) == "table" then
		num = num:GetName():gsub("GameTooltipTextLeft", "")
		num = tonumber(num)
		return num
	else
		return _G["GameTooltipTextLeft"..num]
	end
end

--Find a line
GameTooltip["FindLine"] = function(self, msg, exact, from) 
	if not msg then return end
	local lines = self:NumLines(true)
	for i = from or 1, lines do
		local line = _G["GameTooltipTextLeft"..i]
		local text = line and line:GetText()
		if text and ((exact and text == msg) or (not exact and text:find(msg))) then
			return line, i
		end
	end
end

--Num Lines
local _NumLines = GameTooltip.NumLines
GameTooltip["NumLines"] = function(self, ignoreDeleted)
	if ignoreDeleted then
		local line, realLines, i = true, 0, 0
		while line do
			i = i + 1
			line = _G[self:GetName().."TextLeft"..i]
			local text = line and line:GetText()
			if text and string.len(text) > 0 then
				realLines = realLines + 1
			else
				break
			end
		end
		return realLines
	end
	return _NumLines(self)
end

--Delete Line
GameTooltip["DeleteLine"] = function(self, line, exact)
	local numLines, originalNum, barNum = self:NumLines()
	if type(line) == "number" then
		line = _G["GameTooltipTextLeft"..line]
	elseif type(line) == "string" then
		line = self:FindLine(line, exact)
	end
	if line then
		originalNum = self:GetLine(line)
		if line ~= _G["GameTooltipTextLeft"..numLines] then
			local number = self:GetLine(line)
			local tbl = {}
			for i = number+1, numLines do
				tbl[i-1] = _G["GameTooltipTextLeft"..i]
			end
			for k, v in pairs(tbl) do
				local text = v:GetText()
				local newLine = _G["GameTooltipTextLeft"..k]
				if v:GetStringHeight() > select(2,v:GetFont()) then
					text = wrapText(text)
				end
				newLine.deleted = v.deleted
				newLine:SetText(text)
				newLine:SetTextColor(v:GetTextColor())
			end
			line = _G["GameTooltipTextLeft"..numLines]
			if not line then return end
		end
		line.deleted = true
		line:SetText("")
		line:Hide()
		self:Show()
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

------------------------------------
-- Helper funcs
------------------------------------
function RGBToHex(r, g, b)
	if (type(r) == "table") then
		g = r.g
		b = r.b
		r = r.r
	end
	if (not r and not g and not b) then
		r = 255
		g = 255
		b = 255
	end
	r = r <= 255 and r >= 0 and r or 0
	g = g <= 255 and g >= 0 and g or 0
	b = b <= 255 and b >= 0 and b or 0
	return string.format("%02x%02x%02x", r, g, b)
end

function RGBPercToHex(r, g, b)
	if (type(r) == "table") then
		g = r.g
		b = r.b
		r = r.r
	end
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return string.format("%02x%02x%02x", r*255, g*255, b*255)
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
