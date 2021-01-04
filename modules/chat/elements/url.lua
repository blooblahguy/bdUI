local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Chat")


-- function ItemRefTooltip:SetHyperlink(link)
-- 	print(link)
-- 	self:SetPadding(0, 0);
-- 	self:SetHyperlink(link);
-- 	local title = _G[self:GetName().."TextLeft1"];
-- 	if ( title and title:GetRight() - self.CloseButton:GetLeft() > 0 ) then
-- 		local xPadding = 16;
-- 		self:SetPadding(xPadding, 0);
-- 	end
-- end

local patterns = {
	-- X://Y most urls
    "^(%a[%w+.-]+://%S+)",
    "%f[%S](%a[%w+.-]+://%S+)",
    -- www.X.Y domain and path
    "^([-%w_%%]+%.(%a%a+)/%S+)",
    "%f[%S]([-%w_%%]+%.(%a%a+)/%S+)",
    -- www.X.Y domain
    "^([-%w_%%]+%.(%a%a+))",
    "%f[%S]([-%w_%%]+%.(%a%a+))",
    -- email
    "(%S+@[%w_.-%%]+%.(%a%a+))",
}

function mod:chat_urls()

	local function filter(chatFrame, event, msg, ...)
		local newMsg = msg

		-- use pattern table
		for k, p in pairs(patterns) do
			if string.find(newMsg, p) then
				-- we use garrmission because blizzard checks for known types only
				newMsg = newMsg:gsub(p, '|cffffffff|Hgarrmission:%1|h[%1]|h|r')
			end
		end

		return false, newMsg, ...
	end

	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_OFFICER", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_WARNING", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT_LEADER", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", filter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_INLINE_TOAST_BROADCAST", filter)

	hooksecurefunc("SetItemRef", function(link, text)
		local type, value = link:match("(%a+):(.+)")

		local eb = LAST_ACTIVE_CHAT_EDIT_BOX or ChatFrame1EditBox
		if not eb then return end
		eb:Show()
		eb:SetText(value)
		eb:SetFocus()
		eb:HighlightText()
	end)
end