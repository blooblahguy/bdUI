local bdUI, c, l = unpack(select(2, ...))

bdUI.fonts = {}

-- dynamic font creation/fetching
function bdUI:get_font(size, outline, shadow)
	size = bdUI:round(size)
	local name = outline and size .. "_" .. outline or size
	name = shadow and name .. "_shadow" or name
	outline = outline and outline or ""


	if (not bdUI.fonts[name]) then
		local font = CreateFont("BDUI_" .. name)

		font:SetFont(bdUI.media.font, tonumber(size), outline)
		if (shadow) then
			font:SetShadowColor(0, 0, 0, 1)
			font:SetShadowOffset(1, -1)
		else
			font:SetShadowColor(0, 0, 0, 0)
			font:SetShadowOffset(0, 0)
		end

		bdUI.fonts[name] = font
	end

	return bdUI.fonts[name]
end

-- update the objects that the ui uses
function bdUI:update_fonts()
	for font_name, font in pairs(bdUI.fonts) do
		local config_font_path = bdUI.media.font

		local size, outline, shadow = strsplit("_", font_name)
		outline = outline and outline or ""
		-- print(size, outline, shadow)
		-- if (outline == "NONE") then outline = nil end

		font:SetFont(bdUI.media.font, tonumber(size), outline)
		if (shadow) then
			font:SetShadowColor(0, 0, 0, 1)
			font:SetShadowOffset(1, -1)
		else
			font:SetShadowColor(0, 0, 0, 0)
			font:SetShadowOffset(0, 0)
		end

		-- print(config_font)

		-- font:SetFont(config_font, tonumber(size), outline)
	end
end

-- -- font changed or initialized
bdUI:add_action("profile_change,bdUI/fonts", function()
	bdUI.media.font_name = bdUI:get_module("General"):get_save().ui_font
	bdUI.media.font = bdUI.shared:Fetch("font", bdUI.media.font_name)

	bdUI.update_fonts()
end)

-- when fonts are ready, run this event
local sharedmedia = CreateFrame("frame", nil, bdParent)
sharedmedia:RegisterEvent("LOADING_SCREEN_DISABLED")
sharedmedia:SetScript("OnEvent", function()
	bdUI:do_action("bdUI/fonts")
end)


-- return the actual path of the shared media font
function bdUI:get_font_path(font)
	return bdUI.shared:Fetch("font", font)
end

-- get a list of fonts for the config list
function bdUI:get_fonts()
	local fonts = {}
	local shared_fonts = bdUI.shared:List("font")

	-- dump(shared_fonts)

	return shared_fonts
end
