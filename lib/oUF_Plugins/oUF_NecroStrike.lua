local _, ns = ...
local oUF = ns.oUF
local NecroticStrikeTooltip

--Enabling only for DKs
if select(2, UnitClass("player")) ~= "DEATHKNIGHT" then return end

local function GetNecroticAbsorb(unit)
	local i = 1
	while true do
		local _, _, texture, _, _, _, _, _, _, _, spellId = UnitAura(unit, i, "HARMFUL")
		if not texture then break end
		if spellId == 73975 then
			if not NecroticStrikeTooltip then
				NecroticStrikeTooltip = CreateFrame("GameTooltip", "NecroticStrikeTooltip", nil, "GameTooltipTemplate")
				NecroticStrikeTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
			end
			NecroticStrikeTooltip:ClearLines()
			NecroticStrikeTooltip:SetUnitDebuff(unit, i)
			if (GetLocale() == "ruRU") then
				return tonumber(string.match(_G[NecroticStrikeTooltip:GetName() .. "TextLeft2"]:GetText(), "(%d+%s?) .*"))
			else
				return tonumber(string.match(_G[NecroticStrikeTooltip:GetName() .. "TextLeft2"]:GetText(), ".* (%d+%s?) .*"))
			end
		end
		i = i + 1
	end
	return 0
end

local function UpdateOverlay(object)
	local healthFrame = object.Health
	local element = healthFrame.NecroticOverlay
	local amount = 0
	if healthFrame.NecroAbsorb then
		amount = healthFrame.NecroAbsorb
	end
	if amount > 0 then
		local currHealth = UnitHealth(object.unit)
		local maxHealth = UnitHealthMax(object.unit)
		
		--Calculatore overlay posistion based on current health
		local lOfs = (healthFrame:GetWidth() * (currHealth / maxHealth)) - (healthFrame:GetWidth() * (amount / maxHealth))
		local rOfs = (healthFrame:GetWidth() * (currHealth / maxHealth)) - healthFrame:GetWidth()
		
		--Compensate for smooth health bars
		local rOfs2 = (healthFrame:GetWidth() * (healthFrame:GetValue() / maxHealth)) - healthFrame:GetWidth()
		if rOfs2 > rOfs then rOfs = rOfs2 end
		
		--Clamp to health bar
		if lOfs < 0 then lOfs = 0 end
		if rOfs > 0 then rOfs = 0 end
		
		--Redraw overlay
		element:ClearAllPoints()
		element:SetPoint("LEFT", lOfs, 0)
		element:SetPoint("RIGHT", rOfs, 0)
		element:SetPoint("TOP", 0, 0)
		element:SetPoint("BOTTOM", 0, 0)
		
		--Select overlay color based on if class color is enabled
		if healthFrame.colorClass then
			element:SetVertexColor(0, 0, 0, 0.4)
		else
			local r, g, b = healthFrame:GetStatusBarColor()
			element:SetVertexColor(1-r, 1-g, 1-b, 0.4)
		end
		
		element:Show()
	else
		element:Hide()
	end

	if(element.PostUpdate) then
		element:PostUpdate(amount)
	end
end

local function Update(object, event, unit)
	if object.unit ~= unit then return end
	object.Health.NecroAbsorb = GetNecroticAbsorb(unit)
	UpdateOverlay(object)
end
 
local function Enable(object)
	if not object.Health or not object.Health.NecroticOverlay then return end
	local element = object.Health.NecroticOverlay
	element.__owner = object
	
	--Create overlay for this object
	if not element then
		element = object.Health:CreateTexture(nil, "OVERLAY", object.Health)
		element:SetAllPoints(object.Health)
		element:SetTexture(1, 1, 1, 1)
		element:SetBlendMode("BLEND")
		element:SetVertexColor(0, 0, 0, 0.4)
		element:Hide()
	end

	object:RegisterEvent("UNIT_AURA", Update)
	object:RegisterEvent("UNIT_HEALTH", Update)
	return true
end
 
local function Disable(object)
	if not object.Health then return end
	
	if object.Health.NecroticOverlay then
		object.Health.NecroticOverlay:Hide()
	end

	object:UnregisterEvent("UNIT_AURA", Update)
	object:UnregisterEvent("UNIT_HEALTH", Update)
end
 
oUF:AddElement('NecroStrike', Update, Enable, Disable)
 
for i, frame in ipairs(oUF.objects) do Enable(frame) end