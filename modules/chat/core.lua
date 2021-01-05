--===============================================
-- FUNCTIONS
--===============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Chat")
local config
local gsub = string.gsub

--===============================================
-- Core functionality
-- place core functionality here
--===============================================
function mod:initialize()
	mod.config = mod:get_save()
	config = mod.config
	if (not config.enabled) then return end

	-- alerts
	mod:create_alerts()

	-- skin
	mod:skin_chat()

	-- url copy
	mod:chat_urls()

	-- alt invite
	mod:alt_invite()

	-- bubbles
	mod:create_chat_bubbles()
	
	-- names
	mod:color_names()
	
	-- channels
	mod:format_channels()

	-- emojis
	mod:create_emojis()
	
	-- telltarget command
	mod:telltarget()
	-- community mask
	mod:create_community()

	mod:config_callback()
end

function mod:config_callback()
	mod.config = mod:get_save()
	config = mod.config

	if (not config.enabled) then return end

	
end