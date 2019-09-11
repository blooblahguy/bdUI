local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("General")

function mod:create_qol()
	local config = mod:get_save()
	-- increase equipment sets per player
	setglobal("MAX_EQUIPMENT_SETS_PER_PLAYER", 100)


	if (config.autodismount) then

		local eFrame = CreateFrame("FRAME")
		eFrame:RegisterEvent("UI_ERROR_MESSAGE")
		eFrame:SetScript("OnEvent", function(self, event, messageType, msg)
			-- Auto stand
			if msg == SPELL_FAILED_NOT_STANDING
			or msg == ERR_CANTATTACK_NOTSTANDING
			or msg == ERR_LOOT_NOTSTANDING
			or msg == ERR_TAXINOTSTANDING
			then
				DoEmote("stand")
				UIErrorsFrame:Clear()
			-- Auto dismount
			elseif msg == ERR_ATTACK_MOUNTED
			or msg == ERR_MOUNT_ALREADYMOUNTED
			or msg == ERR_NOT_WHILE_MOUNTED
			or msg == ERR_TAXIPLAYERALREADYMOUNTED
			or msg == SPELL_FAILED_NOT_MOUNTED
			then
				if IsMounted() then
					Dismount()
					UIErrorsFrame:Clear()
				end
			end
		end)

	end
end