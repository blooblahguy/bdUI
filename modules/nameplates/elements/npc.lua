local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Nameplates")

function mod:npc_style(self, event, unit)
	local config = mod._config
	
	if (self.currentStyle and self.currentStyle == "npc") then return end
	self.currentStyle = "npc"
end