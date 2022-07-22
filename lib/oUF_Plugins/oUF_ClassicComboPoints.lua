local _, ns = ...
local oUF = ns.oUF

-- in wod combo points were made to be player stored and not target stored
local PlayerClass = select(2, UnitClass("player"))
if select(4, GetBuildInfo()) > 60000 then return end
if not PlayerClass == "ROGUE" and not PlayerClass == "DRUID" then return end

local element_name = "ClassicComboPoints"

-- variables about what combo points we're working with
-- sourced from FrameXML/Constants.lua
local SPELL_POWER_COMBO_POINTS = Enum.PowerType.ComboPoints or 5
local RequirePower, RequireSpell
local ClassPowerID = SPELL_POWER_COMBO_POINTS
local ClassPowerType = 'COMBO_POINTS'
-- if(PlayerClass == 'DRUID') then
-- 	RequirePower = SPELL_POWER_ENERGY
-- 	RequireSpell = 768
-- end

local function UpdateColor(element, powerType)
	local color = element.__owner.colors.power[powerType]
	local r, g, b = color[1], color[2], color[3]
	for i = 1, #element do
		local bar = element[i]
		bar:SetStatusBarColor(r, g, b)

		local bg = bar.bg
		if(bg) then
			local mu = bg.multiplier or 1
			bg:SetVertexColor(r * mu, g * mu, b * mu)
		end
	end

	--[[ Callback: ClassPower:PostUpdateColor(r, g, b)
	Called after the element color has been updated.

	* self - the ClassPower element
	* r    - the red component of the used color (number)[0-1]
	* g    - the green component of the used color (number)[0-1]
	* b    - the blue component of the used color (number)[0-1]
	--]]
	if(element.PostUpdateColor) then
		element:PostUpdateColor(r, g, b)
	end
end

local function Update(self, event, unit, powerType)
	if (event ~= "NAME_PLATE_UNIT_ADDED") then
		if ((unit ~= "player" and unit ~= nil) or powerType ~= ClassPowerType) then return end
	end
	local element = self[element_name]

	--[[ Callback: ClassPower:PreUpdate(event)
	Called before the element has been updated.

	* self  - the ClassPower element
	]]
	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local cur, max, mod, oldMax, chargedPoints
	if(event ~= 'ClassPowerDisable') then
		local powerID = ClassPowerID
		cur = GetComboPoints('player', self.unit)
		max = UnitPowerMax("player", powerID)
		mod = UnitPowerDisplayMod(powerID)

		-- mod should never be 0, but according to Blizz code it can actually happen
		cur = mod == 0 and 0 or cur / mod


		local numActive = cur + 0.9
		-- print(cur, max, numActive)
		for i = 1, max do
			if(i > numActive) then
				element[i]:Hide()
				element[i]:SetValue(0)
			else
				-- print(i, "show")
				element[i]:Show()
				element[i]:SetValue(1) --cur - i + 1)
			end
		end

		oldMax = element.__max
		if(max ~= oldMax) then
			if(max < oldMax) then
				for i = max + 1, oldMax do
					element[i]:Hide()
					element[i]:SetValue(0)
				end
			end

			element.__max = max
		end
	end
	--[[ Callback: ClassPower:PostUpdate(cur, max, hasMaxChanged, powerType)
	Called after the element has been updated.

	* self          - the ClassPower element
	* cur           - the current amount of power (number)
	* max           - the maximum amount of power (number)
	* hasMaxChanged - indicates whether the maximum amount has changed since the last update (boolean)
	* powerType     - the active power type (string)
	* chargedTable  - current chargedPoints table
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(cur, max, oldMax ~= max, powerType, chargedPoints)  -- ElvUI uses chargedPoints as table
	end
end

local function Path(self, ...)
	--[[ Override: ClassPower.Override(self, event, unit, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	* ...   - the arguments accompanying the event
	--]]
	return (self[element_name].Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return VisibilityPath(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Visibility(self, event, unit)
	local element = self[element_name]
	local isEnabled = element.__isEnabled

	--[[ Override: ClassPower:UpdateColor(powerType)
	Used to completely override the internal function for updating the widgets' colors.

	* self      - the ClassPower element
	* powerType - the active power type (string)
	--]]
	local fn = element.UpdateColor or UpdateColor
	fn(element, ClassPowerType)

	if(not isEnabled) then
		ClassicComboPointsEnable(self)

		--[[ Callback: ClassPower:PostVisibility(isVisible)
		Called after the element's visibility has been changed.

		* self      - the ClassPower element
		* isVisible - the current visibility state of the element (boolean)
		--]]
		if(element.PostVisibility) then
			element:PostVisibility(true)
		end
	end

	Path(self, event, unit, ClassPowerType)
end

local function VisibilityPath(self, ...)
	--[[ Override: ClassPower.OverrideVisibility(self, event, unit)
	Used to completely override the internal visibility function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	--]]
	return (self[element_name].OverrideVisibility or Visibility) (self, ...)
end

do
	function ClassicComboPointsEnable(self)
		self:RegisterEvent('UNIT_POWER_FREQUENT', Path, true)
		self:RegisterEvent('UNIT_MAXPOWER', Path, true)
		self:RegisterEvent('PLAYER_TARGET_CHANGED', VisibilityPath, true)

		self[element_name].__isEnabled = true

		Path(self, 'ClassPowerEnable', 'player', ClassPowerType)
	end

	function ClassicComboPointsDisable(self)
		self:UnregisterEvent('UNIT_POWER_FREQUENT', Path, true)
		self:UnregisterEvent('UNIT_MAXPOWER', Path, true)
		self:UnregisterEvent('PLAYER_TARGET_CHANGED', VisibilityPath)

		local element = self[element_name]
		for i = 1, #element do
			element[i]:Hide()
		end

		element.__isEnabled = false
		Path(self, 'ClassPowerDisable', 'player', ClassPowerType)
	end
end

local function Enable(self, unit)
	local element = self[element_name]

	if(element and (PlayerClass == "ROGUE" or PlayerClass == "DRUID")) then
		element.__owner = self
		element.__max = #element
		element.ForceUpdate = ForceUpdate

		if(RequirePower) then
			self:RegisterEvent('UNIT_DISPLAYPOWER', VisibilityPath)
		end

		element.ClassPowerEnable = ClassicComboPointsEnable
		element.ClassPowerDisable = ClassicComboPointsDisable

		for i = 1, #element do
			local bar = element[i]
			if(bar:IsObjectType('StatusBar')) then
				if(not (bar:GetStatusBarTexture() or bar:GetStatusBarAtlas())) then
					bar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
				end

				bar:SetMinMaxValues(0, 1)
			end
		end

		return true
	end
end

local function Disable(self)
	if(self[element_name]) then
		ClassPowerDisable(self)

		self:UnregisterEvent('UNIT_DISPLAYPOWER', VisibilityPath)
		self:UnregisterEvent('SPELLS_CHANGED', Visibility)
	end
end

oUF:AddElement('ClassicComboPoints', VisibilityPath, Enable, Disable)