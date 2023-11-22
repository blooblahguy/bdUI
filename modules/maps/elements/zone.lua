local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Maps")
local config

function mod:minimap_zones()
	--===========================
	-- Zone
	--===========================
	MinimapZoneText:Hide()
	if (MinimapZoneText.EnableMouse) then
		MinimapZoneText:EnableMouse(false)
		if (MinimapCluster.BorderTop) then
			MinimapCluster.BorderTop:Hide()
			MinimapCluster.BorderTop:EnableMouse(false)
			MinimapCluster.Tracking:Hide()
			MinimapCluster.Tracking:EnableMouse(false)
			MinimapCluster.ZoneTextButton:Hide()
			MinimapCluster.ZoneTextButton:EnableMouse(false)
		end
	end

	Minimap.zone = CreateFrame("frame", nil, Minimap)
	Minimap.zone:Hide()
	Minimap.zone.text = Minimap.zone:CreateFontString(nil)
	Minimap.zone.text:SetFontObject(bdUI:get_font(12, "THINOUTLINE"))
	Minimap.zone.text:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 8, -8)
	Minimap.zone.text:SetJustifyH("LEFT")
	Minimap.zone.subtext = Minimap.zone:CreateFontString(nil)
	Minimap.zone.subtext:SetFontObject(bdUI:get_font(12, "THINOUTLINE"))
	Minimap.zone.subtext:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", -8, -8)
	Minimap.zone.subtext:SetJustifyH("RIGHT")
	Minimap.zone:RegisterEvent("ZONE_CHANGED")
	Minimap.zone:RegisterEvent("ZONE_CHANGED_INDOORS")
	Minimap.zone:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	Minimap.zone:RegisterEvent("PLAYER_ENTERING_WORLD")
	Minimap.zone:SetScript("OnEvent", function(self, event)
		Minimap.zone.text:SetText(GetZoneText())
		Minimap.zone.subtext:SetText(GetSubZoneText())
	end)

	Minimap:HookScript("OnEnter", function()
		Minimap.zone:Show()
	end)
	Minimap:HookScript("OnLeave", function()
		Minimap.zone:Hide()
	end)
end
