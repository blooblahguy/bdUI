local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Maps")
local config

-- thank you to xcoords
function mod:worldmap_coords()
	mod.coords = CreateFrame("frame", nil, WorldMapFrame)
	mod.coords.text = mod.coords:CreateFontString(nil, "OVERLAY")
	mod.coords.text:SetFontObject(bdUI:get_font(14, "THINOUTLINE"))
	mod.coords.text:SetAllPoints()
	mod.coords.text:SetJustifyH("CENTER")
	mod.coords:SetPoint("BOTTOM", WorldMapFrame, "BOTTOM")
	mod.coords:SetFrameStrata("TOOLTIP")
	mod.coords:SetSize(300, 40)
	local total = 0
	mod.coords:SetScript("OnUpdate", function(self, elapsed)
		total = total + elapsed
		if (total >= 0.2) then
			total = 0

			-- Player
			local uiMapID = C_Map.GetBestMapForUnit("player")
			if (not uiMapID) then return end
			local position = C_Map.GetPlayerMapPosition(uiMapID, "player")
			if (not position) then return end

			local pX, pY = position:GetXY()
			local nick = '';

			if (not pX) then return end
			pX = pX * 100
			pY = pY * 100
			pX = math.floor(pX * 10) / 10
			pY = math.floor(pY * 10) / 10
			if pX == 0.0 or pY == 0.0 then
				Nick = "N/A";
			else
				Nick = UnitName("player")
				pX = string.format("%.1f", pX)
				pY = string.format("%.1f", pY)
				Nick = Nick .. ": |cffffffff" .. pX .. ", " .. pY;
			end

			-- Cursor		
			local cX, cY = WorldMapFrame:GetNormalizedCursorPosition()
			cX = cX * 100
			cY = cY * 100

			if cX < 0 or cX > 100 or cY < 0 or cY > 100 then
				cursor = "N/A"
			else
				cX = string.format("%.1f", cX)
				cY = string.format("%.1f", cY)
				cursor = "Cursor: |cffffffff" .. cX .. ", " .. cY;
			end

			self.text:SetText(Nick .. "|r  -  " .. cursor .. "|r");
		end
	end)
end
