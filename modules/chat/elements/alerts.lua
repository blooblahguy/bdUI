--============================================
-- ALERTS
-- Allow for @playername or @here to send alerts
-- to bdChat users
--============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Chat")
local gsub = string.gsub
local playername = UnitName("player",false)
local pcolors = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
pcolors = RGBPercToHex(pcolors.r, pcolors.g, pcolors.b)
local pstring = "@|cff"..pcolors..playername.."|r"


local function alert_message(message)
	mod.alert.text:SetText(message);
	mod.alert:SetAlpha(1);
	mod.alert:Show();
	mod.alert.time = GetTime();
	PlaySound(3081,"master")
end

function mod:create_alerts()
	-- Register Addon Message
	C_ChatInfo.RegisterAddonMessagePrefix("bdChat")

	-- Alert Frame
	mod.alert = CreateFrame("Frame");
	mod.alert:ClearAllPoints();
	mod.alert:SetHeight(300);
	mod.alert:SetWidth(300);
	mod.alert:Hide();
	mod.alert.text = mod.alert:CreateFontString(nil, "BACKGROUND");
	mod.alert.text:SetFontObject(bdUI:get_font(16));
	mod.alert.text:SetAllPoints();
	mod.alert:SetPoint("CENTER", 0, 200);
	mod.alert.time = 0;
	mod.alert:SetScript("OnUpdate", function(self)
		if (mod.alert.time < GetTime() - 3) then
			local alpha = mod.alert:GetAlpha();
			if (alpha ~= 0) then mod.alert:SetAlpha(alpha - .05); end
			if (alpha == 0) then mod.alert:Hide(); end
		end
	end);

	mod.alert:RegisterEvent('CHAT_MSG_ADDON');
	mod.alert:SetScript("OnEvent", function(self, event, arg1, arg2)
		if (event == "CHAT_MSG_ADDON" and arg1 == "bdChat") then
			alert_message(arg2)
		end
	end);

	-- bdUI:add_action("chat_message", filter_alerts)
	local function filter(chatFrame, event, msg, ...)
		local newMsg = msg
	
		--Alert players with @playername callouts
		local callout = msg:lower():find("@"..playername:lower()) or msg:lower():find(pstring:lower())
		if (callout) then
			alert_message(msg)
		end
		
		local everyonecallout = msg:lower():find("@everyone") or msg:lower():find("@here")
		if (everyonecallout) then
			if (msg:find("GUILD")) then
				C_ChatInfo.SendAddonMessage("bdChat", msg, "GUILD")
			elseif (msg:find("RAID")) then
				C_ChatInfo.SendAddonMessage("bdChat", msg, "RAID")
			elseif (msg:find("OFFICER")) then
				C_ChatInfo.SendAddonMessage("bdChat", msg, "OFFICER")
			elseif (msg:find("PARTY")) then
				C_ChatInfo.SendAddonMessage("bdChat", msg, "PARTY")
			end
		end

		return false, msg, ...
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

