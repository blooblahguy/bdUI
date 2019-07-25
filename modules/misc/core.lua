--===============================================
-- FUNCTIONS
--===============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Misc")

--===============================================
-- Core functionality
-- place core functionality here
--===============================================
function mod:initialize()
	mod:create_dcbo()
	mod:create_errorblock()
	mod:create_gmotd()
	mod:create_qol()
end