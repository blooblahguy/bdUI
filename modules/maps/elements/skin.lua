local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Maps")

function mod:minimap_skin()
	local frames = {
		"MiniMapVoiceChatFrame", -- out in BFA
		"MiniMapWorldMapButton",
		"MinimapZoneTextButton",
		"MiniMapMailBorder",
		"MiniMapInstanceDifficulty",
		"MinimapNorthTag",
		"MinimapZoomOut",
		"MinimapZoomIn",
		"MinimapBackdrop",
		"GameTimeFrame",
		"GuildInstanceDifficulty",
		"MiniMapChallengeMode",
		"MinimapBorderTop",
		"MinimapBorder",
		"MinimapToggleButton",
	}
	for i = 1, #frames do
		if (_G[frames[i]]) then
			_G[frames[i]]:Hide()
			_G[frames[i]].Show = noop
		end
	end

	-- fixes texture issue with non round minimaps
	Minimap:EnableMouse(true)
	if (Minimap.SetQuestBlobRingAlpha) then
		Minimap:SetQuestBlobRingAlpha(0)
	end
	if (Minimap.SetArchBlobRingAlpha) then
		Minimap:SetArchBlobRingAlpha(0)
	end
	if (Minimap.SetArchBlobRingScalar) then
		Minimap:SetArchBlobRingScalar(0)
	end
	if (Minimap.SetQuestBlobRingScalar) then
		Minimap:SetQuestBlobRingScalar(0)
	end
end
