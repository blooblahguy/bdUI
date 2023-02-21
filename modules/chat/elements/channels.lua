local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Chat")

-- /script print(string.find("|Hplayer:Update-Atiesh:200:WHISPER:UPDATE-ATIESH[Update] is Away: Away", ".+ is Away: .+"))

-- /script print(string.gsub("You receive loot: |cff9d9d9d|Hitem:33429::::::::72:::::::::|h[Ice Cleaver]|h|r.", "You receive loot%: (.+)%[(.+)%](.+)%.", '+ %1%2%3'))

-- Convert a WoW global string to a search pattern
local makePattern = function(msg)
	msg = string.gsub(msg, "%%d", "(%%d+)")
	msg = string.gsub(msg, "%%s", "(.+)")
	msg = string.gsub(msg, "%%(%d+)%$d", "%%%%%1$(%%d+)")
	msg = string.gsub(msg, "%%(%d+)%$s", "%%%%%1$(%%s+)")
	return msg
end

-- "You have been awarded %d Honor.";
print(LOOT_ITEM_SELF_MULTIPLE)
print(makePattern(LOOT_ITEM_SELF_MULTIPLE))

local match_strings = {}
match_strings[#match_strings+1] = {"|Hplayer:([^%|]+)|h%[([^%]]+)%]|h", "|Hplayer:%1|h%2|h"} -- remove_brackets from players
match_strings[#match_strings+1] = {"%[%d%d?%. "..TRADE.."[^%]]*%]", "T"} -- trade
match_strings[#match_strings+1] = {"%[%d%d?%. "..COMMUNITIES_DEFAULT_CHANNEL_NAME.."[^%]]*%]", "Gen"} -- general
match_strings[#match_strings+1] = {"<Away>", "<afk>"} -- afk
match_strings[#match_strings+1] = {"<Busy>", "<dnd>"} -- dnd
match_strings[#match_strings+1] = {"|Hplayer:([^%|]+)|h(.+)|h says:", "|Hplayer:%1|h%2|h:"} -- says
match_strings[#match_strings+1] = {"|Hplayer:([^%|]+)|h(.+)|h yells:", "|Hplayer:%1|h%2|h:"} -- yells
match_strings[#match_strings+1] = {".+ "..COMMUNITIES_SETTINGS_MOTD_LABEL..".+", "GMotD"} -- gmotd
match_strings[#match_strings+1] = {"has come online.", "+"} -- online
match_strings[#match_strings+1] = {"has gone offline.", "-"} -- offline
match_strings[#match_strings+1] = {'|h%[(%d+)%. (%w+)%]|h', '|h%2|h'} -- channels

-- xp
match_strings[#match_strings+1] = {makePattern(COMBATLOG_XPGAIN_FIRSTPERSON), '|cff777777+|r %2 XP: %1'} -- something dies you gain experience
match_strings[#match_strings+1] = {makePattern(COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED), '|cff777777+|r %1 XP'} -- you gained experience
match_strings[#match_strings+1] = {makePattern(COMBATLOG_GUILD_XPGAIN), '|cff777777+|r %1 Guild XP'} -- you gained guildxp
-- honor
match_strings[#match_strings+1] = {makePattern(COMBATLOG_HONORAWARD), '|cff777777+|r %1 Honor'} -- you gained honor
match_strings[#match_strings+1] = {makePattern(COMBATLOG_HONORGAIN), '|cff777777+|r %3 Honor: %1'} -- you gained honor
-- reputation
match_strings[#match_strings+1] = {makePattern(FACTION_STANDING_DECREASED), '|cffAA7777-|r %2 Reputation: %1'} -- you lost reputation
match_strings[#match_strings+1] = {makePattern(FACTION_STANDING_DECREASED_GENERIC), '|cffAA7777-|r Reputation: %1'} -- you lost reputation
match_strings[#match_strings+1] = {makePattern(FACTION_STANDING_INCREASED), '|cff777777+|r %2 Reputation: %1'} -- you gained guildxp
match_strings[#match_strings+1] = {makePattern(FACTION_STANDING_INCREASED_GENERIC), '|cff777777+|r Reputation: %1'} -- you gained guildxp
-- loot
match_strings[#match_strings+1] = {makePattern(LOOT_ITEM_SELF), '|cff777777+|r %1'} -- loot single
match_strings[#match_strings+1] = {makePattern(LOOT_ITEM_SELF_MULTIPLE), '|cff777777+|r %1|cff999999(%2)|r'} -- loot multiple

--items
match_strings[#match_strings+1] = {makePattern(LOOT_ITEM_CREATED_SELF_MULTIPLE), '|cff777777+|r %1 Created |cff999999(%2)|r'}
match_strings[#match_strings+1] = {makePattern(LOOT_ITEM_CREATED_SELF), '|cff777777+|r %1 Created'}

match_strings[#match_strings+1] = {makePattern(LOOT_ITEM_PUSHED_SELF_MULTIPLE), '|cff777777+|r %1 |cff999999(%2)|r'}
match_strings[#match_strings+1] = {makePattern(LOOT_ITEM_PUSHED_SELF), '|cff777777+|r %1'}
match_strings[#match_strings+1] = {makePattern(LOOT_ITEM_REFUND_MULTIPLE), '|cff777777+|r %1 |cff999999(%2)|r'}
match_strings[#match_strings+1] = {makePattern(LOOT_ITEM_REFUND), '|cff777777+|r %1'}
match_strings[#match_strings+1] = {makePattern(CURRENCY_GAINED), '|cff777777+|r %1'}
match_strings[#match_strings+1] = {makePattern(CURRENCY_GAINED_MULTIPLE), '|cff777777+|r %1'}



local function make_plain(orig_string)
	local str = gsub(orig_string, "|", "\124")
	str = gsub(str, "%[", "\91")
	str = gsub(str, "%]", "\93")

	return str
end

local escapes = {
    ["|c%x%x%x%x%x%x%x%x"] = "", -- color start
    ["|r"] = "", -- color end
    ["|H.-|h(.-)|h"] = "%1", -- links
    ["|T.-|t"] = "", -- textures
    ["{.-}"] = "", -- raid target icons
}
local function unescape(str)
    for k, v in pairs(escapes) do
        str = gsub(str, k, v)
    end
    return str
end

-- local function filter(chatFrame, event, msg, ...)
local function filter(msg)
	local newMsg = msg

	-- assert(false, make_plain(msg))

	if (not newMsg) then return msg end

	-- mass replace
	for name, gsub_info in pairs(match_strings) do
		local find, replace = unpack(gsub_info)
		newMsg = string.gsub(newMsg, find, replace)
		if (newMsg == nil) then return nil end
	end

	return newMsg
end

function mod:format_channels()
	-- Channels
	CHAT_WHISPER_GET              = "|cffB19CD9From|r %s: "
	CHAT_WHISPER_INFORM_GET       = "|cff966FD6To|r %s: "
	CHAT_BN_WHISPER_GET           = "|cffB19CD9From|r %s: "
	CHAT_BN_WHISPER_INFORM_GET    = "|cff966FD6To|r %s: "
	CHAT_BATTLEGROUND_GET         = "|Hchannel:Battleground|hBG.|h %s: "
	CHAT_BATTLEGROUND_LEADER_GET  = "|Hchannel:Battleground|hBGL.|h %s: "
	CHAT_GUILD_GET                = "|Hchannel:Guild|hG.|h %s: "
	CHAT_OFFICER_GET              = "|Hchannel:Officer|hO.|h %s: "
	CHAT_PARTY_GET                = "|Hchannel:Party|hP.|h %s: "
	CHAT_PARTY_LEADER_GET         = "|Hchannel:Party|hPL.|h %s: "
	CHAT_PARTY_GUIDE_GET          = "|Hchannel:Party|hPG.|h %s: "
	CHAT_RAID_GET                 = "|Hchannel:Raid|hR.|h %s: "
	CHAT_RAID_LEADER_GET          = "|Hchannel:Raid|hRL.|h %s: "
	CHAT_RAID_WARNING_GET         = "|Hchannel:RaidWarning|hRW.|h %s: "
	CHAT_INSTANCE_CHAT_GET        = "|Hchannel:Battleground|hI.|h %s: "
	CHAT_INSTANCE_CHAT_LEADER_GET = "|Hchannel:Battleground|hIL.|h %s: "

	
	-- for i = 1, NUM_CHAT_WINDOWS do
	-- 	local chatframe = _G["ChatFrame"..i]
	-- 	if (i ~= 2) then
	-- 		bdUI:RawHook(chatframe, "AddMessage", filter, true)
	-- 		-- chatframe.DefaultAddMessage = chatframe.AddMessage
	-- 		-- chatframe.AddMessage = filter
	-- 	end
	-- end
	
	SetCVar("chatClassColorOverride", 0)

	if (mod.config.pastureschatconfig) then
		match_strings[1] = nil
		match_strings[9] = nil
		match_strings[10] = nil
	end
	mod:AddChatFilter(filter)

	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", filter)
	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", filter)
	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD_ACHIEVEMENT", filter)
	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_COMMUNITIES_CHANNEL", filter)
	-- ChatFrame_AddMessageEventFilter("GUILD_MOTD", filter)
	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", filter)
	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_OFFICER", filter)
	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", filter)
	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", filter)
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
end

