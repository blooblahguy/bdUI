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

-- Search text and find alerts
local function filter_alerts(text)
	-- mod:alert_message(text)
	-- if (not text) then return end

	--Alert players with @playername callouts
	local callout = text:lower():find("@"..playername:lower()) or text:lower():find(pstring:lower())
	if (callout) then mod:alert_message(text) end
	
	local everyonecallout = text:lower():find("@everyone") or text:lower():find("@here")
	if (everyonecallout) then
		if (text:find("GUILD")) then
			C_ChatInfo.SendAddonMessage("bdChat", text, "GUILD")
		elseif (text:find("RAID")) then
			C_ChatInfo.SendAddonMessage("bdChat", text, "RAID")
		elseif (text:find("OFFICER")) then
			C_ChatInfo.SendAddonMessage("bdChat", text, "OFFICER")
		elseif (text:find("PARTY")) then
			C_ChatInfo.SendAddonMessage("bdChat", text, "PARTY")
		end
	end
end

function mod:alert_message(message)
	mod.alert.text:SetText(message);
	mod.alert:SetAlpha(1);
	mod.alert:Show();
	mod.alert.time = GetTime();
	PlaySound(3081,"master")
end

function mod:create_alerts()
	-- Register Addon Message
	C_ChatInfo.RegisterAddonMessagePrefix("bdChat")
	mod:RegisterEvent('CHAT_MSG_ADDON');
	mod:SetScript("OnEvent", function(self, event, arg1)
		if (event == "CHAT_MSG_ADDON" and arg == "bdChat") then
			mod:alert_message(arg2)
		end
	end);

	-- Alert Frame
	mod.alert = CreateFrame("Frame");
	mod.alert:ClearAllPoints();
	mod.alert:SetHeight(300);
	mod.alert:SetWidth(300);
	mod.alert:Hide();
	mod.alert.text = mod.alert:CreateFontString(nil, "BACKGROUND");
	mod.alert.text:SetFont(bdUI.media.font, 16, "OUTLINE");
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

	bdUI:add_action("chat_message", filter_alerts)
end

