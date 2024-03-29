local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("General")

local function set_position(_, _, relativeTo)
	local vehicle = _G.VehicleSeatIndicator
	local mover = vehicle.mover
	if mover and relativeTo ~= mover then
		vehicle:ClearAllPoints()
		vehicle:SetPoint('TOPLEFT', mover, 'TOPLEFT', 0, 0)
	end
end

function mod:move_vehicles()
	local vehicle = _G.VehicleSeatIndicator
	vehicle:ClearAllPoints()
	vehicle:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMLEFT", -10, 0)
	bdMove:set_moveable(vehicle, "Vehicle Frame")

	hooksecurefunc(vehicle, 'SetPoint', set_position)
end