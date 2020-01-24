
local _, ns = ...
local oUF = ns.oUF

if WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then return end
 
local function Update(self, event, unit)
	if(self.unit ~= unit) then return end

	local element = self.bdHealthPrediction

	--[[ Callback: bdHealthPrediction:PreUpdate(unit)
	Called before the element has been updated.

	* self - the HealthPrediction element
	* unit - the unit for which the update has been triggered (string)
	--]]
	if(element.PreUpdate) then
		element:PreUpdate(unit)
	end

	local incomingHeals = UnitGetIncomingHeals(unit) or 0
	local absorb = UnitGetTotalAbsorbs(unit) or 0
	local healAbsorb = UnitGetTotalHealAbsorbs(unit) or 0
	local health, maxHealth = UnitHealth(unit), UnitHealthMax(unit)
	local overA = 0
	local overH = 0
	
	--============================================
	-- Incoming Heals
	--============================================
	if (incomingHeals > maxHealth - health) then
		incomingHeals = maxHealth - health
	end
	if(element.incomingHeals) then
		local hp_width = self.Health:GetWidth()
		element.incomingHeals:Show()
		element.incomingHeals:SetMinMaxValues(0, maxHealth)
		element.incomingHeals:SetValue(incomingHeals)
		element.incomingHeals:SetWidth(hp_width)
		element.incomingHeals:SetPoint("LEFT", self.Health, "LEFT", hp_width * (health / maxHealth), 0)
	end
	
	--============================================
	-- Absorb Bar 1
	--============================================
	if (absorb > maxHealth) then
		overA = absorb - maxHealth
	end
	if(element.absorbBar) then
		element.absorbBar:Show()
		element.absorbBar:SetMinMaxValues(0, UnitHealthMax(unit))
		element.absorbBar:SetValue(absorb)
	end
	
	--============================================
	-- Absorb Bar 2
	--============================================
	if(element.overAbsorb) then
		element.overAbsorb:SetMinMaxValues(0, UnitHealthMax(unit))
		element.overAbsorb:SetValue(overA)
		if (overA > 0) then
			element.overAbsorb:Show()
		else
			element.overAbsorb:Hide()
		end
	end

	--============================================
	-- Heal Absorb Bar 1
	--============================================
	if (healAbsorb > maxHealth) then
		overH = healAbsorb - maxHealth
	end
	if(element.healAbsorbBar) then
		element.healAbsorbBar:Show()
		element.healAbsorbBar:SetMinMaxValues(0, UnitHealthMax(unit))
		element.healAbsorbBar:SetValue(healAbsorb)
	end
	
	--============================================
	-- Heal Absorb Bar 2
	--============================================
	if(element.overHealAbsorb) then
		element.overHealAbsorb:SetMinMaxValues(0, UnitHealthMax(unit))
		element.overHealAbsorb:SetValue(overH)
		if (overH > 0) then
			element.overHealAbsorb:Show()
		else
			element.overHealAbsorb:Hide()
		end
	end
	
	--[[ Callback: bdHealthPrediction:PostUpdate(unit, myIncomingHeal, otherIncomingHeal, absorb, healAbsorb)
	Called after the element has been updated.

	* self              - the HealthPrediction element
	* unit              - the unit for which the update has been triggered (string)
	* incomingHeals     - the amount of incoming healing (number)
	* absorb            - the amount of damage the unit can absorb without losing health (number)
	* healAbsorb        - the amount of healing the unit can absorb without gaining health (number)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(unit, incomingHeals, absorb, healAbsorb)
	end
end
 
local function Path(self, ...)
	--[[ Override: bdHealthPrediction.Override(self, event, unit)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event
	--]]
	return (self.bdHealthPrediction.Override or Update) (self, ...)
end
 
local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end
 
local function Enable(self)
	local element = self.bdHealthPrediction
	if not element then return end

	element.__owner = self
	element.ForceUpdate = ForceUpdate
	self:RegisterEvent('UNIT_HEALTH', Path)
	self:RegisterEvent('UNIT_ABSORB_AMOUNT_CHANGED', Path)
	self:RegisterEvent('UNIT_HEAL_ABSORB_AMOUNT_CHANGED', Path)
	self:RegisterEvent('UNIT_MAXHEALTH', Path)
	self:RegisterEvent('UNIT_HEAL_PREDICTION', Path)

	element.colors = element.colors or {}
	element.colors.heals = {0.6, 1, 0.6, .2}
	element.colors.absorb1 = {.1, .1, .2, .6}
	element.colors.absorb2 = {.1, .1, .2, .6}
	element.colors.heal_absorb1 = {.3, 0, 0,.5}
	element.colors.heal_absorb2 = {.3, 0, 0,.5}

	if(element.incomingHeals) then
		element.incomingHeals:SetPoint("TOP")
		element.incomingHeals:SetPoint("BOTTOM")
	end
	if(element.absorbBar) then
		element.absorbBar:SetAllPoints()
	end
	if(element.overAbsorb) then
		element.overAbsorb:SetAllPoints()
	end
	if(element.healAbsorbBar) then
		element.healAbsorbBar:SetAllPoints()
	end
	if(element.overHealAbsorb) then
		element.overHealAbsorb:SetAllPoints()
	end

	return true
end
 
local function Disable(self)
	local element = self.bdHealthPrediction
	if not element then return end

	self:UnregisterEvent('UNIT_HEALTH', Path)
	self:UnregisterEvent('UNIT_ABSORB_AMOUNT_CHANGED', Path)
	self:UnregisterEvent('UNIT_HEAL_ABSORB_AMOUNT_CHANGED', Path)
	self:UnregisterEvent('UNIT_MAXHEALTH', Path)
	self:UnregisterEvent('UNIT_HEAL_PREDICTION', Path)

	if(element.incomingHeals) then
		element.incomingHeals:Hide()
	end
	if(element.absorbBar) then
		element.absorbBar:Hide()
	end
	if(element.overAbsorb) then
		element.overAbsorb:Hide()
	end
	if(element.healAbsorbBar) then
		element.healAbsorbBar:Hide()
	end
	if(element.overHealAbsorb) then
		element.overHealAbsorb:Hide()
	end
end
 
oUF:AddElement('TotalAbsorb', Path, Enable, Disable)
