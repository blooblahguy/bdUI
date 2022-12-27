local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Maps")
local config

local bdMinimap = CreateFrame('Frame', 'bdUI_Minimap', UIParent, BackdropTemplateMixin and "BackdropTemplate")

-- minimap being held/scaled with us
local function position_minimap()
	GetMinimapShape = function() return "SQUARE" end
	Minimap:SetMaskTexture("Interface\\BUTTONS\\WHITE8X8")

	-- size and scale things
	Minimap:SetAllPoints(bdMinimap)
end

-- force cluster into our position
local function position_cluster(_, anchor)
	if anchor ~= holder then
		MinimapCluster:SetAllPoints(bdMinimap)
	end
end

function mod:create_minimap()
	config = mod:get_save()

	-- load blizzard things
	if not IsAddOnLoaded("Blizzard_Calendar") then
		LoadAddOn('Blizzard_Calendar')
	end
	if not IsAddOnLoaded("Blizzard_TimeManager") then
		LoadAddOn('Blizzard_TimeManager')
	end

	-- get blizzard out of here PLEASE
	bdUI:KillEditMode(MinimapCluster)

	-- global holder
	bdMinimap:SetPoint('TOPRIGHT', UIParent, -3, -3)
	bdMinimap:SetSize(Minimap:GetSize())
	bdMinimap:SetBackdrop({bgFile = bdUI.media.flat, edgeFile = bdUI.media.flat, edgeSize = bdUI.border})
	bdMinimap:SetBackdropColor(0,0,0,0)
	bdMinimap:SetBackdropBorderColor(unpack(bdUI.media.border))
	mod.bdMinimap = bdMinimap
	bdMove:set_moveable(bdMinimap)

	-- handle cluster
	position_cluster()
	MinimapCluster:EnableMouse(false)
	MinimapCluster:SetFrameLevel(20) -- set before minimap itself
	hooksecurefunc(MinimapCluster, 'SetPoint', position_cluster)

	-- handle MM
	Minimap:EnableMouseWheel(true)
	Minimap:SetFrameLevel(10)
	Minimap:SetFrameStrata('LOW')

	-- keep minimap in location
	position_minimap()
	if (MinimapCluster.SetHeaderUnderneath) then
		hooksecurefunc(MinimapCluster, "SetHeaderUnderneath", position_minimap)
	end
	hooksecurefunc(Minimap, "SetPoint", function(_, _, anchor, _, _, _, shouldIgnore)
		if not shouldIgnore and anchor == MinimapCluster then
			position_minimap()
		end
	end)

	

	

	-- skin out textures from minimap
	mod:minimap_skin()
	
	-- manage blizzard exclusive displays (time, mail, garrison)
	mod:minimap_blizzard_elements()

	-- add zone
	mod:minimap_zones()

	-- add difficulty
	mod:minimap_difficulty()
end