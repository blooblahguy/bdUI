--============================================
-- CHAT BUBBLES
-- Bubble skinning for outside of raids/bg
--============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Chat")
local messageGuid = {}
local messageSender = {}

local bubbles = CreateFrame("frame")
bubbles:RegisterEvent('PLAYER_ENTERING_WORLD')
bubbles:RegisterEvent('CHAT_MSG_SAY')
bubbles:RegisterEvent('CHAT_MSG_YELL')
bubbles:RegisterEvent('CHAT_MSG_MONSTER_SAY')
bubbles:RegisterEvent('CHAT_MSG_MONSTER_YELL')

function mod:create_chat_bubbles()
	local config = mod:get_save()
	local instanceType = select(2, GetInstanceInfo())

	if (instanceType == "none" and config.enabled and config.skinchatbubbles == "Skinned") then
		bubbles:SetScript("OnEvent", bubbles.event)
		bubbles:SetScript("OnUpdate", bubbles.scan)
	else
		bubbles:SetScript("OnEvent", nil)
		bubbles:SetScript("OnUpdate", nil)
	end
end

function bubbles:event(event, msg, sender, _, _, sender2, _, _, _, _, _, _, guid)
	if (event == "PLAYER_ENTERING_WORLD") then
		mod:create_chat_bubbles()
		messageGuid = {}
		messageSender = {}
	else
		messageGuid[msg] = guid
		messageSender[msg] = Ambiguate(sender, 'none')
	end
end

local update = 0;
function bubbles:scan(elapsed)
	update = update + elapsed
	if (update > 0.2 or forced) then
		update = 0;

		for k, frame in pairs(C_ChatBubbles.GetAllChatBubbles()) do
			local backdrop = frame:GetChildren(1)
			if backdrop and not backdrop:IsForbidden() and not frame._skinned then
				bubbles:skin(frame, backdrop)
			end
		end
	end
end

function bubbles:format_text(frame)
	local text = frame.text:GetText()
	local test = text:gsub("[^a-zA-Z%s]", '')
	local words = { strsplit(" ", test) }
	for i = 1, #words do
		local w = words[i]

		if (UnitName(w)) then
			local class = select(2, UnitClass(w))
			local colors = RAID_CLASS_COLORS[class]
			if (colors) then
				text = string.gsub(text, w, "|c" .. colors:GenerateHexColor() .. "%1|r")
			end
		end
	end
	frame.text:SetText(text)
end

function bubbles:add_author(frame)
	local name = frame.name and frame.name:GetText()
	if name then frame.name:SetText() end

	local text = frame.text:GetText()
	if not text then return end

	local name = messageSender[text]
	local guid = messageGuid[text]

	if (name) then
		local color = RAID_CLASS_COLORS.PRIEST
		if (guid and guid ~= '') then
			local class = select(2, GetPlayerInfoByGUID(guid))
			if class and RAID_CLASS_COLORS[class] then
				color = RAID_CLASS_COLORS[class]
			end
		end
		color = color:GenerateHexColor()

		frame.name:SetFormattedText('|c%s%s|r', color, name)
		-- frame.name:SetWidth(frame:GetWidth()-10)
	end
end

function bubbles:on_show(frame)
	bubbles:add_author(frame)
	bubbles:format_text(frame)
end

function bubbles:skin(frame, backdrop)
	frame:SetFrameStrata('DIALOG')
	frame:SetClampedToScreen(false)

	frame.backdrop = frame.backdrop or backdrop
	frame.text = frame.backdrop.String
	frame.text:SetJustifyH('LEFT')
	frame.text:SetFontObject(bdUI:get_font(10, "THINOUTLINE"))

	frame.name = frame:CreateFontString(nil, "OVERLAY")
	frame.name:SetPoint('BOTTOMLEFT', frame.text, 'TOPLEFT', 0, bdUI.border * 3)
	frame.name:SetJustifyH('LEFT')
	frame.name:SetFontObject(bdUI:get_font(10, "THINOUTLINE"))

	backdrop.BottomEdge:Hide()
	backdrop.BottomLeftCorner:Hide()
	backdrop.BottomRightCorner:Hide()
	backdrop.Center:Hide()
	backdrop.LeftEdge:Hide()
	backdrop.RightEdge:Hide()
	backdrop.TopEdge:Hide()
	backdrop.TopLeftCorner:Hide()
	backdrop.TopRightCorner:Hide()
	backdrop.Tail:Hide()

	-- trigger on show
	frame:HookScript('OnShow', function(self)
		bubbles:on_show(frame)
	end)
	bubbles:on_show(frame)

	frame._skinned = true
end
