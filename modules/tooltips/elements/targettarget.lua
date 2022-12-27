local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Tooltips")

local function target_target(self, unit)
	local name
	if (self.GetUnit) then
		name, unit = self:GetUnit()
	end
	unit = unit or "mouseover"
	-- print(unit)
	-- who's targeting whom?
	if (unit and UnitExists(unit..'target')) then
		local r, g, b = mod:getReactionColor(unit..'target')

		if (UnitIsUnit(unit..'target', "player")) then
			GameTooltip:AddDoubleLine("Target", UnitName(unit..'target'), .7, .2, .2, r, g, b)
		else
			GameTooltip:AddDoubleLine("Target", UnitName(unit..'target'), .7, .7, .7, r, g, b)
		end
	end
end

-- add dynamic tooltip information
function mod:create_targettarget()
	if (TooltipDataProcessor) then
		TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, target_target);
	else
		GameTooltip:HookScript('OnTooltipSetUnit', target_target)
	end
end