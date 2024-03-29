local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Chat")

local cache_channels = {
	["CHAT_MSG_GUILD"] = true,
	["CHAT_MSG_OFFICER"] = true,
	["CHAT_MSG_SYSTEM"] = true,
	["CHAT_MSG_RAID"] = true,
	["CHAT_MSG_RAID_LEADER"] = true,
}

local function make_plain(orig_string)
	local str = gsub(orig_string, "|", "\124")
	str = gsub(str, "%[", "\91")
	str = gsub(str, "%]", "\93")

	return str
end

local function replacetext(source, find, replace, wholeword)
	if wholeword then
		find = "%f[^%z%s]"..find--.."%f[%z%s]"
	end
	return (source:gsub(find,replace))
end

-- local testr = "Update does Taxic |cffaaaaaaTo|r |Hplayer:update-Atiesh:48:WHISPER:update-ATIESH|cffaaaaaa[|cff111111update|r]|r: test update update! Update. update rolls 30 (1-100)"

local function filter(msg)
	local newMsg = msg

	if (not newMsg) then return msg end

	local uname = UnitName("player")

	-- local new = newMsg
	-- newMsg = newMsg:gsub("^"..uname:lower(), "|c%1|r")
	-- newMsg = newMsg:gsub("^"..uname, "|c%1|r")
	-- newMsg = newMsg:gsub("%s"..uname:lower(), " |c%1|r")
	-- newMsg = newMsg:gsub("%s"..uname, " |c%1|r")

	for word in newMsg:gmatch("[^%s]%a+") do
		local name = UnitName(word)
		if (name and name:lower() == word:lower() and UnitIsPlayer(word)) then
			local class = select(2, UnitClass(word))
			local colors = RAID_CLASS_COLORS[class]

			newMsg = replacetext(newMsg, word, "|cff"..RGBPercToHex(colors.r, colors.g, colors.b)..word.."|r", true)
			--newMsg = gsub(newMsg, word, "|cff"..RGBPercToHex(colors.r, colors.g, colors.b).."%1|r")
		end
		--if (word:lower() == "update" or word:lower() == "taxic") then
		--table.insert(words, word)
		--end
	end

	-- local newMsg = msg
	-- local test = newMsg:gsub("[^a-zA-Z%s]",'')
	-- assert(false, make_plain(newMsg))

	-- for word in newMsg:gmatch("%w+") do
	-- 	-- assert(false, w and w.len)
	-- 	if (word and string.len(word) > 0) then
	-- 		local name = UnitName(word)
	-- 		if (name and name:lower() == word:lower() and UnitIsPlayer(word)) then
	-- 			local class = select(2, UnitClass(word))
	-- 			local colors = RAID_CLASS_COLORS[class]
	-- 			if (colors) then
	-- 				newMsg = gsub(newMsg, word, "|cff"..RGBPercToHex(colors.r, colors.g, colors.b).."%1|r")
	-- 			end
	-- 		end
	-- 	end
	-- end

	-- -- if (event == "CHAT_MSG_SYSTEM") then
	-- print(words)
	-- -- -- end
	-- for i = 1, #words do
	-- 	local w = words[i]
		
	-- 	if (w and UnitName(w) == w and UnitIsPlayer(w)) then
	-- 		local class = select(2, UnitClass(w))
	-- 		local colors = RAID_CLASS_COLORS[class]
	-- 		if (colors) then
	-- 			newMsg = gsub(newMsg, w, "|cff"..RGBPercToHex(colors.r, colors.g, colors.b).."%1|r")
	-- 		end
	-- 	end
	-- end

	return newMsg

	-- return false, newMsg, ...
end

function mod:color_names()
	-- gonna cache names of people from known environments
	local config = mod:get_save()
	config.name_cache = config.name_cache or {}
	local cache = config.name_cache
	

	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_ACHIEVEMENT", filter)
	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL_NOTICE", filter)
	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_TRADESKILLS", filter)
	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_TEXT_EMOTE", filter)
	-- -- ChatFrame_AddMessageEventFilter("CHAT_MSG_TARGETICONS", filter)
	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_EMOTE", filter)
	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", filter)
	-- -- print("channel names?")
	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", filter)
	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", filter)
	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", filter)
	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_OFFICER", filter)
	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", filter)
	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", filter)
	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", filter)
	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", filter)
	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", filter)
	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", filter)
	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_WARNING", filter)
	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", filter)
	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", filter)
	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", filter)
	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", filter)

	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_RESTRICTED", filter)
	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_TEXT_EMOTE", filter)
	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_ACHIEVEMENT", filter)

	mod:AddChatFilter(filter)

	ToggleChatColorNamesByClassGroup(true, "SAY")
	ToggleChatColorNamesByClassGroup(true, "EMOTE")
	ToggleChatColorNamesByClassGroup(true, "YELL")
	ToggleChatColorNamesByClassGroup(true, "GUILD")
	ToggleChatColorNamesByClassGroup(true, "OFFICER")
	ToggleChatColorNamesByClassGroup(true, "GUILD_ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(true, "ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(true, "WHISPER")
	ToggleChatColorNamesByClassGroup(true, "SYSTEM")
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