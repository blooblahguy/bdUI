local _, ns = ...
local oUF = ns.oUF

-- Determine source
local function IsFromMe(sourceFlags)
	if (CombatLog_Object_IsA(sourceFlags, COMBATLOG_FILTER_ME) or 
	CombatLog_Object_IsA(sourceFlags, COMBATLOG_FILTER_MINE) or
	CombatLog_Object_IsA(sourceFlags, COMBATLOG_FILTER_MY_PET)) then
		return true
	end
	
	return false
end

-- Determine destination
local function IsOnMe(destFlags)
	if (CombatLog_Object_IsA(destFlags, COMBATLOG_FILTER_ME) or 
	CombatLog_Object_IsA(destFlags, COMBATLOG_FILTER_MINE) or
	CombatLog_Object_IsA(destFlags, COMBATLOG_FILTER_MY_PET)) then
		return true
	end

	return false
end

local function Update(self, event, ...)
	local element = self.bdHealthPrediction
	if not element then return end

	local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool, a15, a16, a17, a18, a19, a20, a21, a22, a23, a24, a25 = CombatLogGetCurrentEventInfo()

	-- does this match our unit
	local guid = UnitGUID(self.unit)
	if (guid ~= sourceGUID or guid ~= destGUID) then return end

	-- does this have anything to do with me
	local IsFromMe = IsFromMe(sourceFlags)
	local IsOnMe = IsFromMe(destFlags)
	if (not IsFromMe or notIsOnMe) then return end

	--[[ Callback: bdSCT:PreUpdate(unit)
	Called before the element has been updated.

	* self - the HealthPrediction element
	* unit - the unit for which the update has been triggered (string)
	--]]
	if(element.PreUpdate) then
		element:PreUpdate(IsFromMe, IsOnMe, CombatLogGetCurrentEventInfo())
	end

	-- main logic

	--[[ Callback: bdSCT:PostUpdate(unit, myIncomingHeal, otherIncomingHeal, absorb, healAbsorb)
	Called after the element has been updated.

	* self              - the HealthPrediction element
	* unit              - the unit for which the update has been triggered (string)
	* incomingHeals     - the amount of incoming healing (number)
	* absorb            - the amount of damage the unit can absorb without losing health (number)
	* healAbsorb        - the amount of healing the unit can absorb without gaining health (number)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(IsFromMe, IsOnMe, CombatLogGetCurrentEventInfo())
	end
end

local function Path(self, ...)
	--[[ Override: bdSCT.Override(self, event, unit)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event
	--]]
	return (self.bdSCT.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local element = self.bdSCT
	if not element then return end

	self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED', Path, true)

	element:Show()
end
 
local function Disable(self)
	local element = self.bdSCT
	if not element then return end

	self:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED', Path, true)

	element:Hide()
end
 
oUF:AddElement('bdSCT', Path, Enable, Disable)