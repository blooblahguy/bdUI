local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Chat")

function mod:alt_invite()
	local InviteUnit = InviteUnit or C_PartyInfo.InviteUnit

	hooksecurefunc("SetItemRef", function(link)
		if not IsAltKeyDown() then return end
		
		local player = value:match("^player:([^:]+)")
		local bnet = value:match("^BNplayer:[^:]+:([^:]+)")

		if player then
			InviteUnit(player)
			ChatEdit_OnEscapePressed(ChatFrame1EditBox)
		elseif (bnet) then
			-- full credit to funkydude here 
			local _, _, _, _, _, gameAccountId = BNGetFriendInfoByID(bnet)
			if gameAccountId then
				BNInviteFriend(gameAccountId)
				ChatEdit_OnEscapePressed(ChatFrame1EditBox)
			end
		end

	end)
end