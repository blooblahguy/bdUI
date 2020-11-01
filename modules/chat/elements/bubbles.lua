--============================================
-- CHAT BUBBLES
-- Bubble skinning for outside of raids/bg
--============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Chat")
local messageGuid = {}
local messageSender = {}
-- local update = 0
-- local numkids = 0
-- local bubbles = {}
-- local gsub = string.gsub



local bubbles = CreateFrame("frame")
bubbles:RegisterEvent('PLAYER_ENTERING_WORLD')
bubbles:RegisterEvent('CHAT_MSG_SAY')
bubbles:RegisterEvent('CHAT_MSG_YELL')
bubbles:RegisterEvent('CHAT_MSG_MONSTER_SAY')
bubbles:RegisterEvent('CHAT_MSG_MONSTER_YELL')

function mod:create_chat_bubbles()
	local config = mod:get_save()
	local instanceType = select(2, GetInstanceInfo())

	if (instanceType == "none" and config.enabled and config.skinchatbubbles) then
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
	local test = text:gsub("[^a-zA-Z%s]",'')
	local words = {strsplit(" ",test)}
	for i = 1, #words do
		local w = words[i]
		
		if (UnitName(w)) then
			local class = select(2, UnitClass(w))
			local colors = RAID_CLASS_COLORS[class]
			if (colors) then
				text = string.gsub(text, w, "|c"..colors:GenerateHexColor().."%1|r")
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

	frame.name = frame:CreateFontString(nil, "OVERLAY")
	frame.name:SetPoint('BOTTOMLEFT', frame.text, 'TOPLEFT', 0, bdUI.border * 3)
	frame.name:SetJustifyH('LEFT')
	frame.name:SetFont(bdUI.media.font, 12, "OUTLINE")

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

-- Replaces player names in chat bubbles
-- local function skin_bubble_text(self)
-- 	local text = self.text:GetText()
-- 	local test = text:gsub("[^a-zA-Z%s]",'')
-- 	local words = {strsplit(" ",test)}
-- 	for i = 1, #words do
-- 		local w = words[i]
		
-- 		if (UnitName(w)) then
-- 			local class = select(2, UnitClass(w))
-- 			local colors = RAID_CLASS_COLORS[class]
-- 			if (colors) then
-- 				text = string.gsub(text, w, "|cff"..RGBPercToHex(colors.r,colors.g,colors.b).."%1|r")
-- 			end
-- 		end
-- 	end
-- 	self.text:SetText(text)
-- end

-- Skin chat bubbles once each
local function skinbubble(frame)
	if (frame.hooked) then return end
	frame.hooked = true

	-- get region information
	for i= 1, frame:GetNumRegions() do
		local region = select(i, frame:GetRegions())
		if region:GetObjectType() == "Texture" then
			region.defaulttex = region:GetTexture()
			region:SetTexture(nil)
		elseif region:GetObjectType() == "FontString" then
			frame.text = region
			frame.defaultfont, frame.defaultsize = frame.text:GetFont()
		end
	end
	local border = bdUI.border
	skin_bubble_text(frame)
	frame:HookScript("OnShow", skin_bubble_text)
	
	bdUI:add_action("bdChat_bubble_updated", function()
		if (config.skinchatbubbles == "Default*") then		
			frame.text:SetFont(frame.defaultfont, frame.defaultsize)

			for i=1, frame:GetNumRegions() do
				local region = select(i, frame:GetRegions())
				if region:GetObjectType() == "Texture" then
					region:SetTexture(region.defaulttex)
				end
			end
		elseif (config.skinchatbubbles == "Removed") then
			frame.text:SetFont(bdUI.media.font, 13, "OUTLINE")
			frame:SetBackdrop({bgFile = bdUI.media.flat})
			frame:SetBackdropColor(0,0,0,0)
			frame:SetBackdropBorderColor(0,0,0,0)
		elseif (config.skinchatbubbles == "Skinned" or config.skinchatbubbles) then
			frame.text:SetFont(bdUI.media.font, 13, "OUTLINE")
			frame:SetBackdrop({
				bgFile = bdUI.media.flat,
				edgeFile = bdUI.media.flat,
				edgeSize = border,
				insets = {left = border, right = border, top = border, bottom = border}
			})
			frame:SetBackdropColor(unpack(bdUI.media.backdrop))
			frame:SetBackdropBorderColor(unpack(bdUI.media.border))
		end
	end)
	
	bdUI:do_action("bdChat_bubble_updated")
	tinsert(bubbles, frame)
end

-- returns if its a skinnable chat bubble
-- local function ischatbubble(frame)

-- dump(frame)
-- 	-- for k, v in pairs({frame:GetChildren()}) do
-- 	-- 	print(v, v:GetName())
-- 	-- end
-- 	-- if frame:IsForbidden() then print("forbidden") return end
-- 	-- if frame:GetName() then print("noname") return end
-- 	-- if not frame.Center then print("no center")  return end
-- 	-- if not frame.Center.GetTexture then print("no rexture") return end
-- 	-- print(frame.Center:GetTexture())
-- 	-- return frame:GetRegions():GetTexture() == "Interface\\Tooltips\\ChatBubble-Background"

-- 	return false;
-- end

-- function mod:create_chat_bubbles()
-- 	local config = mod.config

-- 	local _, instanceType = GetInstanceInfo()
	
-- 	scanner:SetScript("OnUpdate", function(self, elapsed)
-- 		update = update + elapsed
-- 		if update > .05 then
-- 			update = 0
-- 			local newnumkids = WorldFrame:GetNumChildren()
-- 			if newnumkids ~= numkids then
-- 				for i = numkids + 1, newnumkids do
-- 					local frame = select(i, WorldFrame:GetChildren())

-- 					if ischatbubble(frame) then
-- 						skinbubble(frame)
-- 					end
-- 				end
-- 				numkids = newnumkids
-- 			end
-- 		end
-- 	end)
-- end