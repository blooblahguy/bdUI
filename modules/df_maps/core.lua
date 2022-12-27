local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Maps")
local config
local bdMinimap = CreateFrame("frame", nil, UIParent)

local frames = {
	"MinimapCluster",
	"MinimapBackdrop",
	-- "Minimap"
}

function mod:initialize()
	config = mod:get_save()
	if (not config.enabled) then return end

	-- bdMinimap:SetPoint("CENTER", UIParent)
	-- bdMinimap:SetSize(200, 200)

	-- for k, frame in pairs(frames) do
	-- 	local f = _G[frame]
	-- 	f:SetParent(bdMinimap)
	-- 	f:ClearAllPoints()
	-- 	f:SetAllPoints()
	-- end

	-- MinimapCluster:ClearAllPoints()
	-- MinimapCluster:SetPoint("TOPRIGHT", UIParent, "CENTER", -20, -20)
	-- MinimapBackdrop:ClearAllPoints()
	-- MinimapBackdrop:SetPoint("TOPRIGHT", UIParent, "CENTER", -20, -20)
	-- Minimap:ClearAllPoints()
	-- Minimap:SetPoint("TOPRIGHT", UIParent, "CENTER", -20, -20)

end