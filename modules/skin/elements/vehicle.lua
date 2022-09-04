local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Skinning")
local vehicle_move = CreateFrame("frame", nil, bdParent)

function mod:move_vehicle(...)
	if (not VehicleSeatIndicator) then return end
	-- print("test", ...)
	Minimap.background = Minimap.background or Minimap
	-- VehicleSeatIndicator:ClearAllPoints()
	-- VehicleSeatIndicator:SetPoint("BOTTOMRIGHT", Minimap.background, "BOTTOMLEFT", -4, 0)

	vehicle_move:RegisterEvent("VEHICLE_UPDATE")
	vehicle_move:RegisterEvent("PLAYER_GAINS_VEHICLE_DATA")
	vehicle_move:SetScript("OnEvent", mod.move_vehicle)
end