local bdUI, c, l = unpack(select(2, ...))

bdUI.fonts = {}

-- dynamic font creation/fetching
function bdUI:get_font(size, outline)
	local name = outline and size.."_"..outline or size
	outline = outline and outline or ""
	
	if (not bdUI.fonts[name]) then
		local font = CreateFont("BDUI_"..name)

		font:SetFont(bdUI.media.font, tonumber(size), outline)
		font:SetShadowColor(0, 0, 0, 0)
		font:SetShadowOffset(0, 0)

		bdUI.fonts[name] = font
	end

	return bdUI.fonts[name]
end

-- update the objects that the ui uses
-- function bdUI:update_fonts()
-- 	for key, font in pairs(bdUI.fonts) do
-- 		local size, outline = strsplit("_", key)
-- 		if (outline == "NONE") then outline = nil end

-- 		local config_font = bdUI:get_module("General"):get_save().font

-- 		font:SetFont(config_font, tonumber(size), outline)
-- 	end
-- end

-- -- font changed or initialized
-- bdUI:add_action("profile_change,bdUI/fonts", function()
-- 	bdUI.media.font = bdUI:get_module("General"):get_save().font
-- 	bdUI.media.font = bdUI.shared:Fetch("font", bdUI.media.font)

-- 	bdUI.update_fonts()
-- 	bdUI:change_fonts()
-- end)

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