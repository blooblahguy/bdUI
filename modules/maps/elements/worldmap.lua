local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Maps")

-- todo; these globals changes
local function coordsResize()
	if WORLDMAP_SETTINGS and WORLDMAP_WINDOWED_SIZE and (WORLDMAP_SETTINGS.size == WORLDMAP_WINDOWED_SIZE) then
		mod.coords:SetPoint("BOTTOM", WorldMapFrame, "BOTTOM", 0, 20)
	else 
		mod.coords:SetPoint("BOTTOM", WorldMapFrame, "BOTTOM", 0, 10)
	end
end

-- thank you to xcoords
function mod:worldmap_coords()
	mod.coords = CreateFrame("frame", nil, WorldMapFrame)
	mod.coords.text = mod.coords:CreateFontString(nil, "OVERLAY")
	mod.coords.text:SetFont(bdUI.media.font, 14)
	mod.coords.text:SetAllPoints()
	mod.coords.text:SetJustifyH("CENTER")
	mod.coords:SetPoint("BOTTOM", WorldMapFrame, "BOTTOM")
	mod.coords:SetFrameStrata("TOOLTIP")
	mod.coords:SetSize(300, 40)
	mod.coords:SetScript("OnUpdate", function(self)
		-- Player
		local uiMapID = C_Map.GetBestMapForUnit("player")
		local position = C_Map.GetPlayerMapPosition(uiMapID, "player")

		if (not position) then return end
		
		local pX, pY = position:GetXY()
		local nick = '';

		if (not pX) then return end
		pX = pX*100
		pY = pY*100
		pX = math.floor(pX*10)/10
		pY = math.floor(pY*10)/10
		if pX == 0.0 or pY == 0.0 then
			Nick = "N/A";
		else
			Nick = UnitName("player")
			pX = string.format("%.1f", pX)
			pY = string.format("%.1f", pY)
			Nick = Nick .. ": |cffffffff" .. pX .. ", " .. pY;
		end

		-- Cursor
		local width, height, scale = WorldMapFrame:GetWidth(), WorldMapFrame:GetHeight(), WorldMapFrame:GetEffectiveScale();
		local cX, cY = WorldMapFrame:GetCenter()
		local left, bottom = cX - width / 2, cY + height /2;

		cX, cY = GetCursorPosition();
		cX, cY = (cX / scale - left) / width * 100, (bottom - cY / scale) / height * 100;
		
		if cX < 0 or cX > 100 or cY < 0 or cY > 100 then
			cursor = "N/A"
		else
			--cX = cX*100
			--cY = cY*100
			cX = math.floor(cX*10)/10
			cY = math.floor(cY*10)/10
			cX = string.format("%.1f", cX)
			cY = string.format("%.1f", cY)
			cursor = "Cursor: |cffffffff" .. cX .. ", " .. cY;
		end

		self.text:SetText(Nick .. "|r  -  " .. cursor .. "|r");

		if (WorldMapFrameSizeUpButton and not WorldMapFrameSizeUpButton.hooked) then
			WorldMapFrameSizeUpButton.hooked = true
			WorldMapFrameSizeUpButton:HookScript("OnClick", coordsResize)
		end
		if (not WorldMapFrame.hooked) then
			WorldMapFrame.hooked = true
			WorldMapFrame:HookScript("OnShow", coordsResize)
		end
	end)



end