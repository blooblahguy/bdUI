local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Chat")

-- allows for message filters from the very beginning of string, isntead of just the messagechat
local chat_filters = {}
local function ChatFilter(self)
	local num = self.headIndex
	if num == 0 then
		num = self.maxElements
	end

	local tbl = self.elements[num]
	local text = tbl and tbl.message
	if text then
		text = tostring(text)
		for k, callback in pairs(chat_filters) do
			text = chat_filters[k](text)
		end
		-- assert(false, text)
		self.elements[num].message = text
	end
end

function mod:AddChatFilter(callback)
	table.insert(chat_filters, callback)
end

local function path(chatFrame, event, originalMsg, ...)
	local msg = originalMsg:lower()
	local config = mod:get_save()

	-- loop through config patterns and filter out matches
	for pattern, v in pairs(config.chat_filters) do
		if (strfind(msg, pattern) ~= nil) then
			-- assert(false, "filtered: "..msg.." ("..unpack({...})..")")
			return true -- filter out
		end
	end

	return false, originalMsg, ...
end

local function enable(config)
	if (not config.enabled) then return false end

	for i = 1, 10 do
		local chatFrame = _G["ChatFrame"..i]
		hooksecurefunc(chatFrame.historyBuffer, "PushFront", ChatFilter)
	end

	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", path)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", path)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_CURRENCY", path)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_MONEY", path)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_TEXT_EMOTE", path)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", path)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_EMOTE", path)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_DND", path)

	return true
end

local function disable(config)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_CHANNEL", path)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_LOOT", path)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_CURRENCY", path)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_MONEY", path)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_TEXT_EMOTE", path)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_YELL", path)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_EMOTE", path)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_DND", path)
end

mod:add_element('filters', path, enable, disable)