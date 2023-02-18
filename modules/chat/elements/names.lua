local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Chat")

local cache_channels = {
	["CHAT_MSG_GUILD"] = true,
	["CHAT_MSG_OFFICER"] = true,
	["CHAT_MSG_SYSTEM"] = true,
	["CHAT_MSG_RAID"] = true,
	["CHAT_MSG_RAID_LEADER"] = true,
}

function mod:color_names()
	-- gonna cache names of people from known environments
	local config = mod:get_save()
	config.name_cache = config.name_cache or {}
	local cache = config.name_cache


	local function filter(chatFrame, event, msg, ...)
		local newMsg = msg

		local test = newMsg:gsub("[^a-zA-Z%s]",'')

		local words = {strsplit(' ', test)}
		for i = 1, #words do
			local w = words[i]
			
			if (w and UnitName(w) == w and UnitIsPlayer(w)) then
				local class = select(2, UnitClass(w))
				local colors = RAID_CLASS_COLORS[class]
				if (colors) then
					newMsg = gsub(newMsg, w, "|cff"..RGBPercToHex(colors.r,colors.g,colors.b).."%1|r")
				end
			end
		end

		return false, newMsg, ...
	end

	ChatFrame_AddMessageEventFilter("CHAT_MSG_ACHIEVEMENT", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL_NOTICE", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_TRADESKILLS", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_TEXT_EMOTE", filter)
	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_TARGETICONS", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_EMOTE", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", filter)
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

	ToggleChatColorNamesByClassGroup(true, "SAY")
	ToggleChatColorNamesByClassGroup(true, "EMOTE")
	ToggleChatColorNamesByClassGroup(true, "YELL")
	ToggleChatColorNamesByClassGroup(true, "GUILD")
	ToggleChatColorNamesByClassGroup(true, "OFFICER")
	ToggleChatColorNamesByClassGroup(true, "GUILD_ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(true, "ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(true, "WHISPER")
	ToggleChatColorNamesByClassGroup(true, "PARTY")
	ToggleChatColorNamesByClassGroup(true, "PARTY_LEADER")
	ToggleChatColorNamesByClassGroup(true, "RAID")
	ToggleChatColorNamesByClassGroup(true, "RAID_LEADER")
	ToggleChatColorNamesByClassGroup(true, "RAID_WARNING")
	ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND")
	ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND_LEADER")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL1")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL2")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL3")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL4")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL5")
	ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT")
	ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT_LEADER")
end