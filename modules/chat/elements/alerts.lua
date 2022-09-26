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


-- Alert Frame
bdUI.alert = CreateFrame("Frame")
bdUI.alert:ClearAllPoints()
bdUI.alert:SetHeight(300)
bdUI.alert:SetWidth(300)
bdUI.alert:Hide()
bdUI.alert.text = bdUI.alert:CreateFontString(nil, "BACKGROUND")
bdUI.alert.text:SetFontObject(bdUI:get_font(16))
bdUI.alert.text:SetAllPoints()
bdUI.alert:SetPoint("CENTER", 0, 200)

function bdUI.alert:AddMessage(text, disablesound)
	bdUI.alert.text:SetText(text)
	bdUI.alert:SetAlpha(1)
	bdUI.alert:Show()
	bdUI.alert.time = GetTime()
	if (not disablesound) then
		PlaySound(3081, "master")
	end
	C_Timer.After(3, function()
		UIFrameFadeOut(bdUI.alert, 1, 1, 0)
	end)
end

-- TODO: Hook into editbox autocomplete

-- show alert box
local function alert_message(message)
	bdUI.alert:AddMessage(message)
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

	bdUI.alert:RegisterEvent('CHAT_MSG_ADDON')
	bdUI.alert:HookScript("OnEvent", function(self, event, arg1, arg2)
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