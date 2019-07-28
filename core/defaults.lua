local bdUI, c, l = unpack(select(2, ...))

local config = {
	{
		key = "topViewport",
		type = "range",
		value = 0,
		step = 5,
		min = 0,
		max = 300,
		label = "Top Viewport Size"
	},
	{
		key = "topViewportBGColor",
		type = "color",
		value = bdUI.media.backdrop,
		label = "Top Viewport Color"
	},
	{
		key = "bottomViewport",
		type = "range",
		value = 0,
		step = 5,
		min = 0,
		max = 300,
		label = "Bottom Viewport Size"
	},
	{
		key = "bottomViewportBGColor",
		type = "color",
		value = bdUI.media.backdrop,
		label = "Bottom Viewport Color"
	},
}

local mod = bdUI:register_module("General", config)

	function mod:initialize()

	end
	-- viewports
	local function createViewport() 
		local frame = CreateFrame("frame", "bdCore Top Viewport", nil)
		frame:SetBackdrop({bgFile = bdUI.media.flat})
		frame:SetBackdropBorderColor(0, 0, 0, 0)
		frame:SetFrameStrata("BACKGROUND")

		return frame
	end
	function mod:config_callback()
		local config = mod._config

		local top = 0
		local bottom = 0

		bdUI.topViewport = bdUI.topViewport or createViewport()
		bdUI.topViewport:SetBackdropColor(unpack(config.topViewportBGColor))
		bdUI.topViewport:SetPoint("TOPLEFT", UIParent, "TOPLEFT")
		bdUI.topViewport:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT")
		bdUI.topViewport:SetHeight(config.topViewport)
		if (config.topViewport <= 0) then
			bdUI.topViewport:Hide()
		end

		top = config.topViewport

		bdUI.bottomViewport = bdUI.bottomViewport or createViewport()
		bdUI.bottomViewport:SetBackdropColor(unpack(config.bottomViewportBGColor))
		bdUI.bottomViewport:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT")
		bdUI.bottomViewport:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT")
		bdUI.bottomViewport:SetHeight(config.bottomViewport)
		if (config.bottomViewport <= 0) then
			bdUI.bottomViewport:Hide()
		end

		bottom = config.bottomViewport

		WorldFrame:ClearAllPoints()
		WorldFrame:SetPoint("TOPLEFT", 0, -( top ) )
		WorldFrame:SetPoint("BOTTOMRIGHT", 0, ( bottom ) )
	end