local _, ns = ...
local oUF = ns.oUF

local function Update(self, event, unit)
	local element = self.ThreatLite

	--[[ Callback: ThreatLite:PreUpdate()
	Called before the element has been updated.

	* self - the ThreatLite element
	--]]
	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local unitAlive = not UnitIsDead(unit) and not UnitIsGhost(unit) and UnitIsConnected(unit)
	local status = UnitThreatSituation(unit)

	if (not unitAlive) then
		element:Hide()
	else
		if (status and status >= 2) then
			element:Show()
		else
			element:Hide()
		end
	end

	--[[ Callback: ThreatLite:PostUpdate(inCombat)
	Called after the element has been updated.

	* self     - the ThreatLite element
	* inCombat - indicates if the player is affecting combat (boolean)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(status, unitAlive)
	end
end

local function Path(self, ...)
	--[[ Override: ThreatLite.Override(self, event)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	--]]
	return (self.ThreatLite.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate')
end

local function Enable(self, unit)
	local element = self.ThreatLite
	if(element and not oUF.classic) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", Path)

		return true
	end
end

local function Disable(self)
	local element = self.ThreatLite
	if (element) then
		element:Hide()

		self:UnregisterEvent("UNIT_THREAT_SITUATION_UPDATE", Path)
	end
end

oUF:AddElement('ThreatLite', Path, Enable, Disable)
