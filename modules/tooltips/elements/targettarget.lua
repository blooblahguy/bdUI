local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Tooltips")

-- add dynamic tooltip information
function mod:create_targettarget()
	GameTooltip:HookScript('OnTooltipSetUnit', function(self)
		local name, unit = self:GetUnit()
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
	end)
end