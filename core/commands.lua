local bdUI, c, l = unpack(select(2, ...))

-- slash commands
function bdUI:set_slash_command(name, func, ...)
	SlashCmdList[name] = func
	for i = 1, select('#', ...) do
		_G['SLASH_'..name..i] = '/'..select(i, ...)
	end
end

-- reload
bdUI:set_slash_command('ReloadUI', ReloadUI, 'rl', 'reset')
-- readycheck
bdUI:set_slash_command('DoReadyCheck', DoReadyCheck, 'rc', 'ready')

SLASH_BDUI1, SLASH_BDUI2 = "/bdcore", '/bd'
SlashCmdList["BDUI"] = function(msg, editbox)
	local s1, s2, s3 = strsplit(" ", msg)

	if (s1 == "") then
		print(bdUI.colorString.." Options:")
		print("   /"..bdUI.colorString.." lock - unlocks/locks moving bd addons")
		print("   /"..bdUI.colorString.." config - opens the configuration for bd addons")
		print("   /"..bdUI.colorString.." reset - reset the saved settings account-wide (careful)")
		--print("-- /bui lock - locks the UI")
	elseif (s1 == "unlock" or s1 == "lock") then
		bdMove.toggle_lock()
	elseif (s1 == "reset") then
		BDUI_SAVE = nil
		bdMove:reset_positions()
	elseif (s1 == "config" or s1 == "conf") then
		bdUI.config_instance:toggle()
	else
		print(bdUI.colorString.." "..msg.." not recognized as a command.")
	end
end