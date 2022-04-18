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

	mod:SetUIScale()

	mod:create_fighttimer()
end

function mod:SetUIScale()
	if (mod.config.set_ui_scale) then
		bdUI:SetCVar("useUiScale", 1)
		bdUI:SetCVar("uiScale", mod.config.ui_scale)
	else
		bdUI:SetCVar("useUiScale", 0)
	end
	bdUI:do_action("bdUI/border_size")
end

function mod:initialize()
	mod.config = mod:get_save()

	mod:SetUIScale()

	mod:create_viewports()
	mod:create_interrupt()
	mod:create_dcbo()
	mod:create_errorblock()
	mod:create_qol()
end