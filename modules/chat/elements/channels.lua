local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Chat")


function mod:format_channels()

	local function filter(chatFrame, event, msg, ...)
		local newMsg = msg

		if (not mod.config.pastureschatconfig) then
			newMsg = newMsg:gsub("|Hplayer:([^%|]+)|h%[([^%]]+)%]|h", "|Hplayer:%1|h%2|h")
		end
		
		-- Abbreviate
		newMsg = newMsg:gsub("<Away>", "<afk>")
		newMsg = newMsg:gsub("<Busy>", "<dnd>")
	
		-- Strip yells: says: from chat
		newMsg = newMsg:gsub("|Hplayer:([^%|]+)|h(.+)|h says:", "|Hplayer:%1|h%2|h:");
		newMsg = newMsg:gsub("|Hplayer:([^%|]+)|h(.+)|h yells:", "|Hplayer:%1|h%2|h:");
	
		-- Whispers are now done with globals
		newMsg = newMsg:gsub("Guild Message of the Day:", "GMotD -")
		
		if (not mod.config.pastureschatconfig) then
			newMsg = newMsg:gsub("has come online.", "+")
			newMsg = newMsg:gsub("has gone offline.", "-")
		end
			
		--channel replace (Trade and custom)
		newMsg = newMsg:gsub('|h%[(%d+)%. .-%]|h', '|h%1.|h')

		return false, newMsg, ...
	end

	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_OFFICER", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_WARNING", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", filter)
end