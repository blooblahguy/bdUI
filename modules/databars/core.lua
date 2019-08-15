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
local azerite, honor, rep, xp, altpower, container
function mod:initialize()
	config = mod:get_save()


	-- framestack bars
	container = CreateFrame("frame", "bdDatabars", UIParent)
	
	-- create the bars
	altpower = mod:create_altpower()
	xp = mod:create_xp()
	rep = mod:create_reputation()
	honor = mod:create_honor()
	azerite = mod:create_azerite()

	-- put into frame group
	bdUI:frame_group(container, "downwards", azerite, honor, rep, xp)
	container:SetPoint("TOP", bdParent, "TOP", 0, -10)
	bdMove:set_moveable(container, "Databars")
end


-- config callback
function mod:config_callback()
	xp:callback()
	rep:callback()
	honor:callback()
	azerite:callback()
	altpower:callback()

	xp:SetSize(config.databars_width, config.databars_height)
	rep:SetSize(config.databars_width, config.databars_height)
	honor:SetSize(config.databars_width, config.databars_height)
	azerite:SetSize(config.databars_width, config.databars_height)
	altpower:SetSize(config.alt_width, config.alt_height)
	
	bdUI:frame_group(container, "downwards", azerite, honor, rep, xp)
end