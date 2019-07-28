--===============================================
-- FUNCTIONS
--===============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Databars")
local config

--===============================================
-- Core functionality
-- place core functionality here
--===============================================
function mod:initialize()
	config = mod._config

	mod:create_xp()
end