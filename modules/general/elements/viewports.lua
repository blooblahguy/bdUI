local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("General")

-- viewports
local function createViewport() 
	local frame = CreateFrame("frame", "bdCore Top Viewport", nil)
	frame:SetBackdrop({bgFile = bdUI.media.flat})
	frame:SetBackdropBorderColor(0, 0, 0, 0)
	frame:SetFrameStrata("BACKGROUND")

	return frame
end

function mod:create_viewports()
	local config = mod.config

	local top = 0
	local bottom = 0

	bdUI.topViewport = bdUI.topViewport or createViewport()
	bdUI.topViewport:SetBackdropColor(unpack(config.topViewportBGColor))
	bdUI.topViewport:SetPoint("TOPLEFT", UIParent, "TOPLEFT")
	bdUI.topViewport:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT")
	bdUI.topViewport:SetHeight(config.topViewport)
	bdUI.topViewport:Show()
	if (config.topViewport <= 0) then
		bdUI.topViewport:Hide()
	end

	top = config.topViewport

	bdUI.bottomViewport = bdUI.bottomViewport or createViewport()
	bdUI.bottomViewport:SetBackdropColor(unpack(config.bottomViewportBGColor))
	bdUI.bottomViewport:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT")
	bdUI.bottomViewport:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT")
	bdUI.bottomViewport:SetHeight(config.bottomViewport)
	bdUI.bottomViewport:Show()
	if (config.bottomViewport <= 0) then
		bdUI.bottomViewport:Hide()
	end

	bottom = config.bottomViewport

	WorldFrame:ClearAllPoints()
	WorldFrame:SetPoint("TOPLEFT", 0, -( top ) )
	WorldFrame:SetPoint("BOTTOMRIGHT", 0, ( bottom ) )
end