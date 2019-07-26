--===============================================
-- FUNCTIONS
--===============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Chat")

--===============================================
-- Custom functionality
-- place custom functionality here
--===============================================
RGBPercToHex = RGBPercToHex or function(r, g, b)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return string.format("%02x%02x%02x", r*255, g*255, b*255)
end

function mod:rawText(text)
	-- starting from the beginning, replace item and spell links with just their names
	text = gsub(text, "|r|h:(.+)|cff(.+)|H(.+)|h%[(.+)%]|h|r", "|r|h:%1%4");
	text = strtrim(text)

	return text
end