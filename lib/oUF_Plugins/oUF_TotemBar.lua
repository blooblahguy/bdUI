--[[
# Element: Totem Indicator

Handles the updating and visibility of totems.

## Widget

Totems - A `table` to hold sub-widgets.

## Sub-Widgets

Totem - Any UI widget.

## Sub-Widget Options

.Icon     - A `Texture` representing the totem icon.
.Cooldown - A `Cooldown` representing the duration of the totem.

## Notes

OnEnter and OnLeave script handlers will be set to display a Tooltip if the `Totem` widget is mouse enabled.

## Examples

    local Totems = {}
    for index = 1, 5 do
        -- Position and size of the totem indicator
        local Totem = CreateFrame('Button', nil, self)
        Totem:SetSize(40, 40)
        Totem:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', index * Totem:GetWidth(), 0)

        local Icon = Totem:CreateTexture(nil, 'OVERLAY')
        Icon:SetAllPoints()

        local Cooldown = CreateFrame('Cooldown', nil, Totem, 'CooldownFrameTemplate')
        Cooldown:SetAllPoints()

        Totem.Icon = Icon
        Totem.Cooldown = Cooldown

        Totems[index] = Totem
    end

    -- Register with oUF
    self.Totems = Totems
--]]

local _, ns = ...
local oUF = ns.oUF
local total = 0
local delay = 0.1

local colors = {
	[1] = {0.752,0.172,0.02},
	[2] = {0.741,0.580,0.03},		
	[3] = {0,0.443,0.631},
	[4] = {0.6,1,0.945},	
}

local function UpdateTooltip(self)
	GameTooltip:SetTotem(self:GetID())
end

local function OnEnter(self)
	if(not self:IsVisible()) then return end

	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
	self:UpdateTooltip()
end

local function OnLeave()
	GameTooltip:Hide()
end

local function UpdateTotem(self, event, slot)
	local totem = self.TotemBar[slot]

	local haveTotem, name, startTime, duration, totemIcon = GetTotemInfo(slot)
	
	totem:SetStatusBarColor(unpack(colors[slot]))
	totem:SetValue(0)
	
	-- Multipliers
	if (totem.bg.multiplier) then
		local mu = totem.bg.multiplier
		local r, g, b = totem:GetStatusBarColor()
		r, g, b = r*mu, g*mu, b*mu
		totem.bg:SetVertexColor(r, g, b) 
	end
	
	totem.ID = slot
	
	-- If we have a totem then set his value 
	if(haveTotem) then
		
		if totem.Name then
			totem.Name:SetText(Abbrev(name))
		end					
		if(duration >= 0) then
			totem:SetValue(1 - ((GetTime() - startTime) / duration))
			totem:Show()
			-- Status bar update
			totem:SetScript("OnUpdate",function(self, elapsed)
				total = total + elapsed
				if total >= delay then
					total = 0
					haveTotem, name, startTime, duration, totemIcon = GetTotemInfo(self.ID)
						if ((GetTime() - startTime) == 0) then
							self:SetValue(0)
						else
							self:SetValue(1 - ((GetTime() - startTime) / duration))
						end
				end
			end)					
		else
			-- There's no need to update because it doesn't have any duration
			totem:SetScript("OnUpdate",nil)
			totem:SetValue(0)
			totem:Hide()
		end 
	else
		-- No totem = no time 
		if totem.Name then
			totem.Name:SetText(" ")
		end
		totem:SetValue(0)
		totem:Hide()
	end

	--[[ Callback: Totems:PostUpdate(slot, haveTotem, name, start, duration, icon)
	Called after the element has been updated.

	* self      - the Totems element
	* slot      - the slot of the updated totem (number)
	* haveTotem - indicates if a totem is present in the given slot (boolean)
	* name      - the name of the totem (string)
	* start     - the value of `GetTime()` when the totem was created (number)
	* duration  - the total duration for which the totem should last (number)
	* icon      - the totem's icon (Texture)
	--]]
	if(self.TotemBar.PostUpdate) then
		return self.TotemBar:PostUpdate(slot, haveTotem, name, start, duration, icon)
	end
end

local function Path(self, ...)
	--[[ Override: Totem.Override(self, event, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* ...   - the arguments accompanying the event
	--]]
	return (self.TotemBar.Override or UpdateTotem) (self, ...)
end

local function Update(self, event)
	for i = 1, #self.TotemBar do
		Path(self, event, i)
	end
end

local function ForceUpdate(element)
	return Update(element.__owner, 'ForceUpdate')
end

local function Enable(self)
	local element = self.TotemBar
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		for i = 1, #element do
			local totem = element[i]

			totem:SetID(i)

			if(totem:IsMouseEnabled()) then
				totem:SetScript('OnEnter', OnEnter)
				totem:SetScript('OnLeave', OnLeave)

				--[[ Override: TotemBar[slot]:UpdateTooltip()
				Used to populate the tooltip when the totem is hovered.

				* self - the widget at the given slot index
				--]]
				if(not totem.UpdateTooltip) then
					totem.UpdateTooltip = UpdateTooltip
				end
			end
		end

		self:RegisterEvent('PLAYER_TOTEM_UPDATE', Path, true)

		TotemFrame:UnregisterEvent('PLAYER_TOTEM_UPDATE')
		TotemFrame:UnregisterEvent('PLAYER_ENTERING_WORLD')
		TotemFrame:UnregisterEvent('UPDATE_SHAPESHIFT_FORM')
		TotemFrame:UnregisterEvent('PLAYER_TALENT_UPDATE')

		return true
	end
end

local function Disable(self)
	local element = self.TotemBar
	if(element) then
		for i = 1, #element do
			element[i]:Hide()
		end

		TotemFrame:RegisterEvent('PLAYER_TOTEM_UPDATE')
		TotemFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
		TotemFrame:RegisterEvent('UPDATE_SHAPESHIFT_FORM')
		TotemFrame:RegisterEvent('PLAYER_TALENT_UPDATE')

		self:UnregisterEvent('PLAYER_TOTEM_UPDATE', Path)
	end
end

oUF:AddElement('TotemBar', Update, Enable, Disable)
