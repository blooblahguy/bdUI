local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Nameplates")

function mod:personal_style(self, event, unit)
	local config = mod._config
	
	if (self.currentStyle and self.currentStyle == "personal") then return end
	self.currentStyle = "personal"
end