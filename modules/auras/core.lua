--===============================================
-- FUNCTIONS
--===============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Auras")

--===============================================
-- Core functionality
-- place core functionality here
--===============================================
function mod:initialize()

end

function mod:config_callback()
	bdUI.caches.auras = {}
end