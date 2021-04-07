local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Tooltips")

-- add dynamic tooltip information
function mod:create_targettarget()
	GameTooltip:HookScript('OnTooltipSetUnit', function(self, unit)
		-- who's targeting whom?
		if (unit and UnitExists(unit..'target')) then
			local r, g, b = mod:getReactionColor(unit..'target')
			GameTooltip:AddDoubleLine("Target", UnitName(unit..'target'), .7, .7, .7, r, g, b)
		end
	end)
end