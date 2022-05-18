--============================================
-- ALERTS
-- Allow for @playername or @here to send alerts
-- to bdChat users
--============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Chat")

local playername = UnitName("player",false):lower()
local pcolors = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
pcolors = RGBPercToHex(pcolors.r, pcolors.g, pcolors.b)
local pstring = "@|cff"..pcolors..playername.."|r"

-- TODO: Hook into editbox autocomplete

-- show alert box
local function alert_message(message)
	mod.alert.text:SetText(message)
	mod.alert:SetAlpha(1)
	mod.alert:Show()
	mod.alert.time = GetTime()
	PlaySound(3081,"master")
	C_Timer.After(3, function()
		UIFrameFadeOut(mod.alert, 1, 1, 0)
	end)
end

-- listen to the chat frames
local function path(chatFrame, channel, originalMsg, ...)
	local msg = originalMsg:lower()

	--Alert players with @playername callouts
	local callout = msg:find("@"..playername) --or msg:lower():find(pstring:lower())
	if (callout) then
		alert_message(msg)
	end
	
	local everyonecallout = msg:find("@everyone") or msg:find("@here")
	if (everyonecallout) then
		if (channel == "CHAT_MSG_GUILD") then
			C_ChatInfo.SendAddonMessage("bdChat", originalMsg, "GUILD")
		elseif (channel == "CHAT_MSG_RAID" or channel == "CHAT_MSG_RAID_LEADER" or channel == "CHAT_MSG_RAID_WARNING") then
			C_ChatInfo.SendAddonMessage("bdChat", originalMsg, "RAID")
		elseif (channel == "CHAT_MSG_OFFICER") then
			C_ChatInfo.SendAddonMessage("bdChat", originalMsg, "OFFICER")
		elseif (channel == "CHAT_MSG_PARTY" or channel == "CHAT_MSG_PARTY_LEADER") then
			C_ChatInfo.SendAddonMessage("bdChat", originalMsg, "PARTY")
		end
	end

	return false, originalMsg, ...
end

-- create the basic functionality
function mod:create_alerts()
	-- Register Addon Message
	C_ChatInfo.RegisterAddonMessagePrefix("bdChat")

	-- Alert Frame
	mod.alert = CreateFrame("Frame")
	mod.alert:ClearAllPoints()
	mod.alert:SetHeight(300)
	mod.alert:SetWidth(300)
	mod.alert:Hide()
	mod.alert.text = mod.alert:CreateFontString(nil, "BACKGROUND")
	mod.alert.text:SetFontObject(bdUI:get_font(16))
	mod.alert.text:SetAllPoints()
	mod.alert:SetPoint("CENTER", 0, 200)

	mod.alert:RegisterEvent('CHAT_MSG_ADDON')
	mod.alert:SetScript("OnEvent", function(self, event, arg1, arg2)
		if (event == "CHAT_MSG_ADDON" and arg1 == "bdChat") then
			alert_message(arg2)
		end
	end);
end


local function enable(config)
	if (not config.enabled) then return false end

	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", path)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", path)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_OFFICER", path)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", path)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", path)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", path)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", path)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", path)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", path)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_WARNING", path)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", path)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", path)

	return true
end

local function disable(config)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_CHANNEL", path)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_GUILD", path)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_OFFICER", path)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SAY", path)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_YELL", path)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_PARTY", path)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_PARTY_LEADER", path)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_RAID", path)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_RAID_LEADER", path)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_RAID_WARNING", path)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_BN_WHISPER", path)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_WHISPER", path)
end

mod:add_element('alerts', path, enable, disable)