local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Skinning")

local function DBM_Style()

end

local function BW_Style()
	if not BigWigs then
		return
	end
	-- local bars = BigWigs:GetPlugin("Bars", true)
	-- if not bars then return end

	BigWigsAPI:RegisterBarStyle("Big Dumb", {
		apiVersion = 1,
		version = 1,
		-- barHeight = 16,
		GetSpacing = function(bar)
			return 8
		end,
		ApplyStyle = function(bar)
			bar.bg = CreateFrame('frame', nil, bar)
			bar.bg:SetFrameStrata("BACKGROUND")
			bar.bg:SetAllPoints(bar.candyBarBar)
			bdUI:set_backdrop(bar.bg)

			bar.ibg = CreateFrame('frame', nil, bar)
			bar.ibg:SetFrameStrata("BACKGROUND")
			bar.ibg:SetAllPoints(bar.candyBarIconFrame)
			bdUI:set_backdrop(bar.ibg)

			bar.candyBarIconFrame:ClearAllPoints()
			bar.candyBarIconFrame:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", 0, 0)
			bar.candyBarIconFrame:SetSize(20, 20)
			bar.candyBarIconFrame:SetTexCoord(.07, .93, .07, .93)

			-- bar
			bar.candyBarBar:ClearAllPoints()
			bar.candyBarBar:SetPoint("BOTTOMLEFT", bar.candyBarIconFrame, "BOTTOMRIGHT", 6, 0)
			bar.candyBarBar:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 0, 0)
			bar.candyBarBar:SetHeight(6)
			bar.candyBarBar:SetStatusBarTexture(bdUI.media.flat)
			bar.candyBarBar.OldSetPoint = bar.candyBarBar.SetPoint
			bar.candyBarBar.SetPoint = function()
				return
			end

			bar.candyBarDuration:SetFont(bdUI.media.font, 14, "THINOUTLINE")
			bar.candyBarDuration:SetShadowOffset(0, 0)
			bar.candyBarDuration:SetJustifyH("RIGHT")
			bar.candyBarDuration:ClearAllPoints()
			bar.candyBarDuration:SetPoint("BOTTOMRIGHT", bar.candyBarBar, "TOPRIGHT", 2, 2)

			bar.candyBarLabel:SetFont(bdUI.media.font, 13, "THINOUTLINE")
			bar.candyBarLabel:SetShadowOffset(0, 0)
			bar.candyBarLabel:SetJustifyH("LEFT")
			bar.candyBarLabel:ClearAllPoints()
			bar.candyBarLabel:SetPoint("BOTTOMLEFT", bar.candyBarBar, "TOPLEFT", -2, 2)

			bar.candyBarBackground:SetTexture(bdUI.media.flat)
			bar.candyBarBackground:SetVertexColor(.1, .1, .1, .4)
			bar.candyBarBackground.SetVertexColor = function()
				return
			end
		end,
		BarStopped = function(bar)
			bar.candyBarBar.SetPoint = bar.candyBarBar.OldSetPoint
		end,
		GetStyleName = function()
			return "BigDumb"
		end,
	})
end

local bm = CreateFrame("frame", nil, UIParent)
bm:RegisterEvent("ADDON_LOADED")
bm:RegisterEvent("PLAYER_LOGIN")

local reason = nil
bm:SetScript("OnEvent", function(self, event, msg)
	if event == "ADDON_LOADED" then
		if not reason then
			reason = (select(6, C_AddOns.GetAddOnInfo("BigWigs_Plugins")))
		end
		if (reason == "MISSING" and msg == "BigWigs") or msg == "BigWigs_Plugins" then
			BW_Style()
			bm:UnregisterEvent("PLAYER_LOGIN")
		end
	elseif event == "PLAYER_LOGIN" then
		if C_AddOns.IsAddOnLoaded("BigWigs") then
			BW_Style()
		elseif C_AddOns.IsAddOnLoaded("DBM-Core") then
			DBM_Style()
		end
	end
end)
