local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Tooltips")

function mod:create_castby()
	hooksecurefunc(GameTooltip, "SetUnitAura", function(self, unit, index, filter)
		local caster = select(7, UnitAura(unit, index, filter))
		local name = caster and UnitName(caster)

		if (not name) then return end
		if (not UnitIsPlayer(name)) then return end

		self:AddDoubleLine("Cast by:", name, nil, nil, nil, mod:getUnitColor(name))
		self:Show()
	end)
end
