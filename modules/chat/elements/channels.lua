local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Chat")

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

	local function filter(self, msg, ...)
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
		
		-- local esc = unescape(msg)

		return self.DefaultAddMessage(self, newMsg, ...)
	end

	for i = 1, NUM_CHAT_WINDOWS do
		local chatframe = _G["ChatFrame"..i]
		if (i ~= 2) then
			chatframe.DefaultAddMessage = chatframe.AddMessage
			chatframe.AddMessage = filter
		end
	end
end