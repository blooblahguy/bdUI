--===============================================
-- FUNCTIONS
--===============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("General")

--===============================================
-- Core functionality
-- place core functionality here
--===============================================
function mod:config_callback()
	mod.config = mod:get_save()
	
	mod:create_viewports()
	bdUI:do_action("bdUI/border_size")

	mod:create_fighttimer()
end
function mod:initialize()
	mod.config = mod:get_save()

	mod:create_viewports()
	mod:create_interrupt()
	mod:create_dcbo()
	mod:create_errorblock()
	mod:create_gmotd()
	mod:create_qol()
end