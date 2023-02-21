local _, ns = ...
local oUF = ns.oUF

local total = 0

local fixateSpells = {}
fixateSpells[268074] = true

local function RGBPercToHex(r, g, b)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return string.format("%02x%02x%02x", r*255, g*255, b*255)
end

local function Update(self, event, unit)
	if (not self.unit) then return end
	local element = self.FixateAlert

	-- if (not UnitIsUnit(unit, self.unit)) then return end

	--[[ Callback: FixateAlert:PreUpdate()
	Called before the element has been updated.

	* self - the FixateAlert element
	--]]
	if (element.PreUpdate) then
		element:PreUpdate()
	end

	local target = self.unit.."target"
	local isTargeting = UnitExists(target) --and UnitIsPlayer(target)
	local isTargetingPlayer = UnitIsUnit(target, "player")

	if (isTargeting and isTargetingPlayer) then
		element:Show()
		element:SetText(UnitName(target))
	else
		element:Hide()
	end

	--[[ Callback: FixateAlert:PostUpdate(unit, isTargeting, isPlayer)
	Called after the element has been updated.

	* self     - the FixateAlert element
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(self.unit, target, isTargeting, isTargetingPlayer)
	end
end

local function Path(self, ...)
	--[[ Override: FixateAlert.Override(self, event)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	--]]
	return (self.FixateAlert.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate')
end

local function Enable(self, unit)
	local element = self.FixateAlert
	if (element and not oUF.classic) then
	
		element.__owner = self
		element.ForceUpdate = ForceUpdate
		element.throttle = element.throttle or 0.1
		element.icon = select(3, GetSpellInfo(210099))
		if (not element.icon) then
			element.icon = select(3, GetSpellInfo(12021))
		end
		element:SetJustifyH("LEFT")
		element:SetTextColor(1,1,1)
		element.SetText_Old = element.SetText
		element.SetText = function(self, unit)
			local cc = RAID_CLASS_COLORS[select(2, UnitClass(unit))]
			if (not cc) then return end
			local color = RGBPercToHex(cc.r, cc.g, cc.b)
			if (unit and UnitIsUnit(unit, "player")) then
				self:SetAlpha(1)
				self:SetText_Old("|cffFF0000>|r|cff"..color..unit.."|r|cffFF0000<|r")
			else
				self:SetAlpha(0.8)
				self:SetText_Old("|cff"..color..unit.."|r")
			end
		end

		element:Hide()

		-- self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Path) -- todo, account for combat log fixates
		-- self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", Path, true)
		-- self:RegisterEvent("NAME_PLATE_UNIT_REMOVED", Path, true)
		-- self:RegisterEvent("NAME_PLATE_UNIT_ADDED", Path, true)
		-- self:RegisterEvent("UNIT_TARGET", Path)
		-- self:RegisterEvent("PLAYER_TARGET_CHANGED", Path)
		-- self:RegisterEvent('UNIT_SPELLCAST_START', Path)
		-- self:RegisterEvent('UNIT_SPELLCAST_CHANNEL_START', Path)
		-- self:RegisterEvent('UNIT_SPELLCAST_STOP', Path)
		-- self:RegisterEvent('UNIT_SPELLCAST_CHANNEL_STOP', Path)
		-- self:RegisterEvent('UNIT_SPELLCAST_DELAYED', Path)
		-- self:RegisterEvent('UNIT_SPELLCAST_CHANNEL_UPDATE', Path)
		-- self:RegisterEvent('UNIT_SPELLCAST_FAILED', Path)
		-- self:RegisterEvent('UNIT_SPELLCAST_INTERRUPTED', Path)
		-- moving to just an on update
		element.updater = element.updater or CreateFrame("frame", nil, self)
		element.updater:SetScript("OnUpdate", function(updater, elapsed)
			total = total + elapsed
			if (total > element.throttle) then
				total = 0
				Path(self)
			end
		end)

		return true
	end
end

local function Disable(self)
	local element = self.FixateAlert
	if (element) then
		element:Hide()
		element.updater:SetScript("OnUpdate", function() return end)

		-- self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Path) -- todo, account for combat log fixates
		-- self:UnregisterEvent("UNIT_THREAT_SITUATION_UPDATE", Path, true)
		-- self:UnregisterEvent("NAME_PLATE_UNIT_REMOVED", Path, true)
		-- self:UnregisterEvent("NAME_PLATE_UNIT_ADDED", Path, true)
		-- self:UnregisterEvent("UNIT_TARGET", Path)
		-- self:UnregisterEvent("PLAYER_TARGET_CHANGED", Path)
		-- self:UnregisterEvent('UNIT_SPELLCAST_START', Path)
		-- self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_START', Path)
		-- self:UnregisterEvent('UNIT_SPELLCAST_STOP', Path)
		-- self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_STOP', Path)
		-- self:UnregisterEvent('UNIT_SPELLCAST_DELAYED', Path)
		-- self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_UPDATE', Path)
		-- self:UnregisterEvent('UNIT_SPELLCAST_FAILED', Path)
		-- self:UnregisterEvent('UNIT_SPELLCAST_INTERRUPTED', Path)
	end
end

oUF:AddElement('FixateAlert', Path, Enable, Disable)
