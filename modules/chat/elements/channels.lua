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

-- print(LOOT_ITEM_SELF_MULTIPLE)
-- print(makePattern(LOOT_ITEM_SELF_MULTIPLE))

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

local function add_basic_formatting(replacement_string, color)
	if (not color) then
		color = "AAAAAA"
	end

	return "|cff"..color..replacement_string.. "|r"
end
-- xp
match_strings[#match_strings+1] = {makePattern(COMBATLOG_XPGAIN_FIRSTPERSON), add_basic_formatting('%2 XP: %1', "4488FF")} -- something dies you gain experience
match_strings[#match_strings+1] = {makePattern(COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED), add_basic_formatting('%1 XP', "4488FF")} -- you gained experience
match_strings[#match_strings+1] = {makePattern(COMBATLOG_GUILD_XPGAIN), add_basic_formatting('%1 Guild XP', "4488FF")} -- you gained guildxp

-- honor
match_strings[#match_strings+1] = {makePattern(COMBATLOG_HONORAWARD), add_basic_formatting('%1 Honor')} -- you gained honor
match_strings[#match_strings+1] = {makePattern(COMBATLOG_HONORGAIN), add_basic_formatting('%3 Honor: %1')} -- you gained honor

-- reputation
match_strings[#match_strings+1] = {makePattern(FACTION_STANDING_DECREASED), add_basic_formatting('%2 Reputation: %1', "22FF66")} -- you lost reputation
match_strings[#match_strings+1] = {makePattern(FACTION_STANDING_DECREASED_GENERIC), add_basic_formatting('Reputation: %1', "22FF66")} -- you lost reputation
match_strings[#match_strings+1] = {makePattern(FACTION_STANDING_INCREASED), add_basic_formatting('%2 Reputation: %1', "22FF66")} -- you gained guildxp
match_strings[#match_strings+1] = {makePattern(FACTION_STANDING_INCREASED_GENERIC), add_basic_formatting('Reputation: %1', "22FF66")} -- you gained guildxp

-- loot
match_strings[#match_strings+1] = {makePattern(CURRENCY_GAINED_MULTIPLE), add_basic_formatting('+ %2 %1')}
match_strings[#match_strings+1] = {makePattern(LOOT_ITEM_SELF_MULTIPLE), add_basic_formatting('+ %2 %1')} -- loot multiple
match_strings[#match_strings+1] = {makePattern(LOOT_ITEM_CREATED_SELF_MULTIPLE), add_basic_formatting('+ %2 %1 Created')}
match_strings[#match_strings+1] = {makePattern(LOOT_ITEM_PUSHED_SELF_MULTIPLE), add_basic_formatting('+ %2 %1')}
match_strings[#match_strings+1] = {makePattern(LOOT_ITEM_REFUND_MULTIPLE), add_basic_formatting('+ %2 %1')}
match_strings[#match_strings+1] = {makePattern(LOOT_ITEM_SELF), add_basic_formatting('+ %1')} -- loot single
match_strings[#match_strings+1] = {makePattern(LOOT_ITEM_CREATED_SELF), add_basic_formatting('+ %1 Created')}
match_strings[#match_strings+1] = {makePattern(LOOT_ITEM_PUSHED_SELF), add_basic_formatting('+ %1')}
match_strings[#match_strings+1] = {makePattern(LOOT_ITEM_REFUND), add_basic_formatting('+ %1')}
match_strings[#match_strings+1] = {makePattern(CURRENCY_GAINED), add_basic_formatting('+ %1')}

-- loot rolls
match_strings[#match_strings+1] = {makePattern(LOOT_ROLL_GREED), add_basic_formatting("Greed %2 for: %1", "00AA11")}
match_strings[#match_strings+1] = {makePattern(LOOT_ROLL_GREED_SELF), add_basic_formatting("|HlootHistory:%1|h[Loot]|h: Greed selected for: %2", "00AA11")}
match_strings[#match_strings+1] = {makePattern(LOOT_ROLL_NEED), add_basic_formatting("Need %2 for: %1", "FFAA00")}
match_strings[#match_strings+1] = {makePattern(LOOT_ROLL_NEED_SELF), add_basic_formatting("|HlootHistory:%1|h[Loot]|h: Need selected for: %2", "FFAA00")}
match_strings[#match_strings+1] = {makePattern(LOOT_ROLL_PASSED), add_basic_formatting("Pass %2 for: %1")}
match_strings[#match_strings+1] = {makePattern(LOOT_ROLL_PASSED_SELF), add_basic_formatting("|HlootHistory:%1|h[Loot]|h: Pass selected for: %2")}

-- LOOT_ROLL_DISENCHANT = "%s has selected Disenchant for: %s";
-- LOOT_ROLL_DISENCHANT_SELF = "|HlootHistory:%d|h[Loot]|h: You have selected Disenchant for: %s";


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
	
	SetCVar("chatClassColorOverride", 0)

	if (mod.config.pastureschatconfig) then
		match_strings[1] = nil
		match_strings[9] = nil
		match_strings[10] = nil
	end
	mod:AddChatFilter(filter)
end

