--===============================================
-- FUNCTIONS
--===============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Databars")

--===============================================
-- Custom functionality
-- place custom functionality here
--===============================================
function mod:create_databar(name)
	local bar = CreateFrame("StatusBar", name, UIParent)
	bar:SetFrameStrata("LOW")
	bar:SetFrameLevel(6)
	bar:SetStatusBarTexture(bdUI.media.flat)
	bar:SetValue(0)
	bar:SetSize(200, 20)
	bdUI:set_backdrop(bar)

	bar.layer = CreateFrame('StatusBar', nil, bar)
	bar.layer:SetAllPoints(bar)
	bar.layer:SetStatusBarTexture(bdUI.media.flat)
	bar.layer:SetValue(0)
	bar.layer:SetStatusBarColor(.2, .4, 0.8, 1)
	bar.layer:SetAlpha(0.4)
	bar.layer:Hide()

	bar.top = CreateFrame('StatusBar', nil, bar)
	bar.top:SetAllPoints(bar)
			
	bar.text = bar.top:CreateFontString(nil, "OVERLAY")
	bar.text:SetAllPoints()
	bar.text:SetJustifyH("CENTER")
	bar.text:SetJustifyV("CENTER")
	bar.text:SetFontObject(bdUI:get_font(11))
	bar.text:Hide()

	bar:SetScript("OnEnter", function() bar.text:Show() end)
	bar:SetScript("OnLeave", function() bar.text:Hide() end)

	return bar
end