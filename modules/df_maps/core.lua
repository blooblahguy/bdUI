local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Maps")
local config

local function position_minimap()
	Minimap:SetAllPoints(mod.MapHolder)
end

local function position_cluster(_, anchor)
	if anchor ~= holder then
		MinimapCluster:SetAllPoints(mod.MapHolder)
	end
end

function mod:initialize()
	config = mod:get_save()
	if (not config.enabled) then return end

	-- get blizzard out of here PLEASE
	bdUI:KillEditMode(MinimapCluster)

	-- global holder
	local mapHolder = CreateFrame('Frame', 'bdUI_MinimapHolder', Minimap)
	mapHolder:SetPoint('TOPRIGHT', UIParent, -3, -3)
	mapHolder:SetSize(Minimap:GetSize())
	bdMove:set_moveable(mapHolder)
	mod.MapHolder = mapHolder

	-- handle cluster
	position_cluster()
	MinimapCluster:EnableMouse(false)
	MinimapCluster:SetFrameLevel(20) -- set before minimap itself
	hooksecurefunc(MinimapCluster, 'SetPoint', position_cluster)

	-- handle MM
	Minimap:EnableMouseWheel(true)
	Minimap:SetFrameLevel(10)
	Minimap:SetFrameStrata('LOW')
	bdUI:set_backdrop(Minimap)

	-- keep minimap in location
	hooksecurefunc(MinimapCluster, "SetHeaderUnderneath", position_minimap)
	hooksecurefunc(Minimap, "SetPoint", function(_, _, anchor, _, _, _, shouldIgnore)
		if not shouldIgnore and anchor == MinimapCluster then
			position_minimap()
		end
	end)
end