local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")


mod.custom_layout["arena"] = function(self, unit)
	local config = mod:get_save()
	
	mod.align_text(self)
end