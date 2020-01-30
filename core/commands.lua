local bdUI, c, l = unpack(select(2, ...))

-- slash commands
function bdUI:set_slash_command(name, func, ...)
	SlashCmdList[name] = func
	for i = 1, select('#', ...) do
		_G['SLASH_'..name..i] = '/'..select(i, ...)
	end
end

-- reload
bdUI:set_slash_command('ReloadUI', ReloadUI, 'rl')

-- readycheck
bdUI:set_slash_command('DoReadyCheck', DoReadyCheck, 'rc', 'ready')

-- lock/unlock
bdUI:set_slash_command('ToggleLock', bdMove.toggle_lock, 'bdlock')
bdUI:set_slash_command('ResetPositions', function()
	BDUI_SAVE = nil
	bdMove:reset_positions()
end, 'bdreset', 'reset')

-- framename
bdUI:set_slash_command('Frame', function()
	print(GetMouseFocus():GetName())
end, 'frame')

-- texture
bdUI:set_slash_command('Texture', function()
	local type, id, book = GetCursorInfo();
	print((type=="item") and GetItemIcon(id) or (type=="spell") and GetSpellTexture(id,book) or (type=="macro") and select(2,GetMacroInfo(id)))
end, 'texture')

-- itemid
bdUI:set_slash_command('ItemID', function()
	local infoType, info1, info2 = GetCursorInfo(); 
	if infoType == "item" then 
		print( info1 )
	end
end, 'item')

SLASH_BDUI1, SLASH_BDUI2 = "/bdcore", '/bd'
SlashCmdList["BDUI"] = function(msg, editbox)
	local s1, s2, s3 = strsplit(" ", msg)

	if (s1 == "") then
		print(bdUI.colorString.." Options:")
		print("   /"..bdUI.colorString.." lock - unlocks/locks moving bd addons")
		print("   /"..bdUI.colorString.." config - opens the configuration for bd addons")
		print("   /"..bdUI.colorString.." reset - options to reset the saved settings")
		--print("-- /bui lock - locks the UI")
	elseif (s1 == "unlock" or s1 == "lock") then
		bdMove.toggle_lock()
	elseif (s1 == "reset") then
		if (s2 == "") then
			print(bdUI.colorString.." Reset:")
			print("   /"..bdUI.colorString.." all - Resets all profiles and positions")
			print("   /"..bdUI.colorString.." positions - Resets positions of current profile")
			return
		elseif (s2 == "all") then
			bdMove:reset_positions()
			BDUI_SAVE = nil
		elseif (s2 == "positions") then
			bdMove:reset_positions()
		end

		ReloadUI()
	elseif (s1 == "config" or s1 == "conf") then
		bdUI.bdConfig:toggle()
	else
		print(bdUI.colorString.." "..msg.." not recognized as a command.")
	end
end


--======================================
-- World Marker Buttons
--======================================
if WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then
	local marks_table = {
		[1] = {"Blue", "0496ff", 6}
		, [2] = {"Green", "119c0c", 4}
		, [3] = {"Purple", "a80ec0", 3}
		, [4] = {"Red", "a6140d", 7}
		, [5] = {"Yellow", "deda32", 1}
		, [6] = {"Orange", "d16f00", 2}
		, [7] = {"Silver", "749bb3", 5}
		, [8] = {"White", "f3f1eb", 8}
	}

	local bdui_wm_buttons = CreateFrame("frame", nil, bdParent)
	BINDING_HEADER_BDUI = "bdUI"
	for i = 1, 8 do
		local name, color, index = unpack(marks_table[i])

		local text = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_"..index..":12|t |cff"..color..name.."|r World Marker"

		_G["BINDING_NAME_CLICK BDUI_WM"..i..":LeftButton"] = text
	end

	_G["BINDING_NAME_CLICK BDUI_CWM:LeftButton"] = "Clear All World Markers"

	for i = 1, 8 do
		local button = CreateFrame("Button", "BDUI_WM"..i, bdui_wm_buttons, "SecureActionButtonTemplate");
		button:SetID(i)
		button:RegisterForClicks("AnyUp","AnyDown");
		button:SetAttribute("type","macro")
		button:SetAttribute("macrotext", "/cwm "..i.."\n/wm "..i)
	end

	-- clear all button
	local button = CreateFrame("Button", "BDUI_CWM", bdui_wm_buttons, "SecureActionButtonTemplate");
	button:SetID(9)
	button:RegisterForClicks("AnyUp","AnyDown");
	button:SetAttribute("type","macro")
	button:SetAttribute("macrotext", "/cwm 0")
end