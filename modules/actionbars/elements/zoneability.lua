local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Actionbars")

function mod:create_zone_ability()
	local za_holder = CreateFrame("frame", "bdUI_ZoneAbility", UIParent)
	za_holder:SetSize(ZoneAbilityFrame:GetSize())
	za_holder:SetPoint("BOTTOM", 0, 0)
	bdMove:set_moveable(za_holder)

	za_holder.size = function(self, frame)
		if (not za_holder.forced) then
			za_holder.forced = true
			za_holder:SetSize(ZoneAbilityFrame:GetSize())
			ZoneAbilityFrame:ClearAllPoints()
			ZoneAbilityFrame:SetPoint("CENTER", za_holder)
			za_holder.forced = false
		end
	end

	

	hooksecurefunc(ZoneAbilityFrame, "SetSize", za_holder.size)
	hooksecurefunc(ZoneAbilityFrame, "SetWidth", za_holder.size)
	hooksecurefunc(ZoneAbilityFrame, "SetPoint", za_holder.size)
end