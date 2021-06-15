local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Chat")

function mod:alt_invite()
	local InviteUnit = InviteUnit or C_PartyInfo.InviteUnit

	hooksecurefunc("SetItemRef", function(link)
		local type, value = link:match("(%a+):(.+)")

		if not IsAltKeyDown() then return end
		
		if type == "player" then
			local player = value:match("([^:]+)")
			InviteUnit(Ambiguate(player, "none"))
		elseif (type == "BNplayer") then
			-- full credit to funkydude here 
			local gameAccountID = link:match("^BNplayer:[^:]+:([^:]+)")
			local accountInfoTbl = C_BattleNet.GetAccountInfoByID(gameAccountID)
			if accountInfoTbl and accountInfoTbl.gameAccountInfo and accountInfoTbl.gameAccountInfo.gameAccountID then
				BNInviteFriend(accountInfoTbl.gameAccountInfo.gameAccountID)
			end
		end

		ChatEdit_OnEscapePressed(ChatFrame1EditBox)
	end)
end