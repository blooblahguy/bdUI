-- --===============================================
-- -- FUNCTIONS
-- --===============================================
-- local bdUI, c, l = unpack(select(2, ...))
-- local mod = bdUI:get_module("Chat")

-- --===============================================
-- -- Core functionality
-- -- place core functionality here
-- --===============================================
-- local bdChat = CreateFrame("frame",nil,UIParent)
-- C_ChatInfo.RegisterAddonMessagePrefix("bdChat")
-- local justreturn = false
-- local gsub = string.gsub
-- local update = 0
-- local numkids = 0
-- local bubbles = {}
-- local playername = UnitName("player",false)
-- local tabs = {"Left","Middle","Right","SelectedLeft","SelectedRight","SelectedMiddle","HighlightLeft","HighlightMiddle","HighlightRight"}

-- -- Alert Frame
-- bdChat.alert = CreateFrame("Frame");
-- bdChat.alert:ClearAllPoints();
-- bdChat.alert:SetHeight(300);
-- bdChat.alert:SetWidth(300);
-- bdChat.alert:Hide();
-- bdChat.alert.text = bdChat.alert:CreateFontString(nil, "BACKGROUND");
-- bdChat.alert.text:SetFont(bdUI.media.font, 16, "OUTLINE");
-- bdChat.alert.text:SetAllPoints();
-- bdChat.alert:SetPoint("CENTER", 0, 200);
-- bdChat.alert.time = 0;
-- bdChat.alert:SetScript("OnUpdate", function(self)
-- 	if (bdChat.alert.time < GetTime() - 3) then
-- 		local alpha = bdChat.alert:GetAlpha();
-- 		if (alpha ~= 0) then bdChat.alert:SetAlpha(alpha - .05); end
-- 		if (alpha == 0) then bdChat.alert:Hide(); end
-- 	end
-- end);
 
-- local function alertMessage(message)
-- 	bdChat.alert.text:SetText(message);
-- 	bdChat.alert:SetAlpha(1);
-- 	bdChat.alert:Show();
-- 	bdChat.alert.time = GetTime();
-- 	PlaySound(3081,"master")
-- end

-- -- tt functionality, thanks phanx for simple script
-- SLASH_TELLTARGET1 = "/tt"
-- SLASH_TELLTARGET2 = "/wt"
-- SlashCmdList.TELLTARGET = function(message)
-- 	if UnitIsPlayer("target") and (UnitIsUnit("player", "target") or UnitCanCooperate("player", "target")) then
-- 		SendChatMessage(message, "WHISPER", nil, GetUnitName("target", true))
-- 	end
-- end

-- --editbox font
-- ChatFontNormal:SetFont(bdUI.media.font, 14)
-- ChatFontNormal:SetShadowOffset(1,1)
-- ChatFontNormal:SetShadowColor(0,0,0)

-- --font size
-- CHAT_FONT_HEIGHTS = {10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20}

-- --tabs
-- CHAT_FRAME_FADE_TIME = 0
-- CHAT_TAB_SHOW_DELAY = 0
-- CHAT_TAB_HIDE_DELAY = 0
-- CHAT_FRAME_FADE_OUT_TIME = 0
-- CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA = 1
-- CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 0
-- CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA = 1
-- CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = 0
-- CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA = 1
-- CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA = 1

-- CHAT_WHISPER_GET              = "F %s "
-- CHAT_WHISPER_INFORM_GET       = "T %s "
-- CHAT_BN_WHISPER_GET           = "F %s "
-- CHAT_BN_WHISPER_INFORM_GET    = "T %s "
-- CHAT_BATTLEGROUND_GET         = "|Hchannel:Battleground|hBG.|h %s: "
-- CHAT_BATTLEGROUND_LEADER_GET  = "|Hchannel:Battleground|hBGL.|h %s: "
-- CHAT_GUILD_GET                = "|Hchannel:Guild|hG.|h %s: "
-- CHAT_OFFICER_GET              = "|Hchannel:Officer|hO.|h %s: "
-- CHAT_PARTY_GET                = "|Hchannel:Party|hP.|h %s: "
-- CHAT_PARTY_LEADER_GET         = "|Hchannel:Party|hPL.|h %s: "
-- CHAT_PARTY_GUIDE_GET          = "|Hchannel:Party|hPG.|h %s: "
-- CHAT_RAID_GET                 = "|Hchannel:Raid|hR.|h %s: "
-- CHAT_RAID_LEADER_GET          = "|Hchannel:Raid|hRL.|h %s: "
-- CHAT_RAID_WARNING_GET         = "|Hchannel:RaidWarning|hRW.|h %s: "
-- CHAT_INSTANCE_CHAT_GET        = "|Hchannel:Battleground|hI.|h %s: "
-- CHAT_INSTANCE_CHAT_LEADER_GET = "|Hchannel:Battleground|hIL.|h %s: "
-- YOU_LOOT_MONEY_GUILD = YOU_LOOT_MONEY
-- LOOT_MONEY_SPLIT_GUILD = LOOT_MONEY_SPLIT

-- -- Enable Classcolor
-- ToggleChatColorNamesByClassGroup(true, "SAY")
-- ToggleChatColorNamesByClassGroup(true, "EMOTE")
-- ToggleChatColorNamesByClassGroup(true, "YELL")
-- ToggleChatColorNamesByClassGroup(true, "GUILD")
-- ToggleChatColorNamesByClassGroup(true, "OFFICER")
-- ToggleChatColorNamesByClassGroup(true, "GUILD_ACHIEVEMENT")
-- ToggleChatColorNamesByClassGroup(true, "ACHIEVEMENT")
-- ToggleChatColorNamesByClassGroup(true, "WHISPER")
-- ToggleChatColorNamesByClassGroup(true, "PARTY")
-- ToggleChatColorNamesByClassGroup(true, "PARTY_LEADER")
-- ToggleChatColorNamesByClassGroup(true, "RAID")
-- ToggleChatColorNamesByClassGroup(true, "RAID_LEADER")
-- ToggleChatColorNamesByClassGroup(true, "RAID_WARNING")
-- ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND")
-- ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND_LEADER")
-- ToggleChatColorNamesByClassGroup(true, "CHANNEL1")
-- ToggleChatColorNamesByClassGroup(true, "CHANNEL2")
-- ToggleChatColorNamesByClassGroup(true, "CHANNEL3")
-- ToggleChatColorNamesByClassGroup(true, "CHANNEL4")
-- ToggleChatColorNamesByClassGroup(true, "CHANNEL5")
-- ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT")
-- ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT_LEADER")


-- --------------------------------------------------
-- -- Hide communities chat by default
-- --------------------------------------------------
-- -- Credit to Nnogga
-- local commOpen = CreateFrame("frame", nil, UIParent)
-- commOpen:RegisterEvent("ADDON_LOADED")
-- commOpen:RegisterEvent("CHANNEL_UI_UPDATE")
-- commOpen:SetScript("OnEvent", function(self, event, addonName)    
--     if event == "ADDON_LOADED" and addonName == "Blizzard_Communities" then
--         --create overlay
--         local f = CreateFrame("Button",nil,UIParent)
--         f:SetFrameStrata("HIGH")
--         f.tex = f:CreateTexture(nil, "BACKGROUND")
--         f.tex:SetAllPoints()
--         f.tex:SetColorTexture(0.1,0.1,0.1,1)
--         f.text = f:CreateFontString()
--         f.text:SetFontObject("GameFontNormalMed3")
--         f.text:SetText("Chat Hidden. Click to show")
--         f.text:SetTextColor(1, 1, 1, 1)
--         f.text:SetJustifyH("CENTER")
--         f.text:SetJustifyV("CENTER")
--         f.text:SetHeight(20)
--         f.text:SetPoint("CENTER",f,"CENTER",0,0)
--         f:EnableMouse(true)
--         f:RegisterForClicks("AnyUp")
--         f:SetScript("OnClick",function(...)
--         	f:Hide()
--         end)
--         --toggle
--         local function toggleOverlay()       
--             if CommunitiesFrame:GetDisplayMode() == COMMUNITIES_FRAME_DISPLAY_MODES.CHAT and config.chatHide then
--                 f:SetAllPoints(CommunitiesFrame.Chat.InsetFrame)
--                 f:Show()
--             else
--                 f:Hide()
--             end
--         end
--         local function hideOverlay()
--             f:Hide()  
--         end        
--         toggleOverlay() --run once
        
--         --hook        
--         hooksecurefunc(CommunitiesFrame,"SetDisplayMode", toggleOverlay)
--         hooksecurefunc(CommunitiesFrame,"Show",toggleOverlay)
--         hooksecurefunc(CommunitiesFrame,"Hide",hideOverlay)
--         hooksecurefunc(CommunitiesFrame,"OnClubSelected", toggleOverlay)        
--     end
-- end)

-- -- Hide side buttons
-- ChatFrameMenuButton:Hide()
-- ChatFrameMenuButton.Show = noop
-- QuickJoinToastButton:Hide()
-- QuickJoinToastButton.Show = noop
-- ChatFrameChannelButton:Hide()
-- ChatFrameChannelButton.Show = noop

-- BNToastFrame:SetClampedToScreen(true)
-- BNToastFrame:SetClampRectInsets(-15,15,15,-15)


-- GeneralDockManager:SetFrameStrata("HIGH")
-- local point, anchor, apoint, x, y = GeneralDockManager:GetPoint()
-- GeneralDockManager:SetPoint(point, anchor, apoint, 0, 16)
-- bdUI:set_backdrop(ChatFrame1, false, 10)

-- function configCallback()
-- 	ChatFrame1.bd_background:SetAlpha(config.bgalpha)
-- 	ChatFrame1.border:SetAlpha(config.bgalpha)
-- end
-- configCallback()

-- local function rawText(text)
-- 	-- starting from the beginning, replace item and spell links with just their names
-- 	text = gsub(text, "|r|h:(.+)|cff(.+)|H(.+)|h%[(.+)%]|h|r", "|r|h:%1%4");
-- 	text = strtrim(text)

-- 	return text
-- end

-- local function skinChat(frame)
-- 	if not frame then return end

-- 	local fontSize = 14
-- 	local name = frame:GetName()
-- 	local editbox = _G[name..'EditBox']
-- 	local bg = _G[name..'Background']
-- 	local buttonframe = _G[name..'ButtonFrame']
-- 	local thumb = _G[name..'ThumbTexture']
-- 	local resize = _G[name..'ResizeButton']
-- 	local tex = {editbox:GetRegions()}
-- 	local tab = _G[name..'Tab']
-- 	local index = gsub(name,"ChatFrame","")
-- 	local frameText = select(2,GetChatWindowInfo(index))
-- 	if (frameText and frameText > 0) then
-- 		fontSize = frameText
-- 	end
	
-- 	--main chat frame
-- 	frame:SetFrameStrata("LOW")
-- 	frame:SetClampRectInsets(0, 0, 0, 0)
-- 	frame:SetMaxResize(UIParent:GetWidth()/2, UIParent:GetHeight()/2)
-- 	frame:SetMinResize(100, 50)
-- 	frame:SetFading(false)
-- 	resize:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 9,-5)
-- 	resize:SetScale(.4)
-- 	resize:SetAlpha(0.7)

-- 	-- to do: find out how best to display chat actionables, instead of just hiding them all
-- 	thumb:Hide()
	
-- 	-- kill textures
-- 	for g = 1, #CHAT_FRAME_TEXTURES do
-- 		_G[name..CHAT_FRAME_TEXTURES[g] ]:SetTexture(nil)
-- 	end
	
-- 	-- tab style
-- 	_G[tab:GetName().."Text"]:SetFont(bdUI.media.font, fontSize,"thinoutline")
-- 	_G[tab:GetName().."Text"]:SetTextColor(1,1,1)
-- 	_G[tab:GetName().."Text"]:SetVertexColor(1,1,1)
-- 	_G[tab:GetName().."Text"]:SetAlpha(.5)
-- 	_G[tab:GetName().."Text"]:SetShadowOffset(0,0)
-- 	_G[tab:GetName().."Text"]:SetShadowColor(0,0,0,0)
-- 	_G[tab:GetName().."Text"].SetTextColor = noop
-- 	_G[tab:GetName().."Text"].SetVertexColor = noop
	
-- 	_G[tab:GetName().."Glow"]:SetTexture(bdUI.media.flat)
-- 	_G[tab:GetName().."Glow"]:SetVertexColor(unpack(bdUI.media.blue))
-- 	_G[tab:GetName().."Glow"].SetVertexColor = noop
-- 	_G[tab:GetName().."Glow"].SetTextColor = noop
	
-- 	for index, value in pairs(tabs) do
-- 		local texture = _G[name..'Tab'..value]
-- 		texture:SetTexture("")
-- 	end
-- 	hooksecurefunc(frame,"Show",function(self)
-- 		_G[self:GetName().."TabText"]:SetAlpha(1)
-- 	end)
-- 	hooksecurefunc(frame,"Hide",function(self)
-- 		_G[self:GetName().."TabText"]:SetAlpha(.5)
-- 	end)
	
-- 	--hide button frame
-- 	buttonframe:Hide()
-- 	buttonframe.Show = noop
	
-- 	--editbox
-- 	editbox:SetAltArrowKeyMode(false)
-- 	bdUI:setBackdrop(editbox)
-- 	_G[editbox:GetName().."Left"]:Hide()
-- 	_G[editbox:GetName().."Mid"]:Hide()
-- 	_G[editbox:GetName().."Right"]:Hide()
-- 	for t = 6, #tex do tex[t]:SetAlpha(0) end
-- 	editbox:ClearAllPoints()
-- 	if name == "ChatFrame2" then
-- 		editbox:SetPoint("BOTTOM",frame,"TOP",0,34)
-- 	else
-- 		editbox:SetPoint("BOTTOM",frame,"TOP",0,10)
-- 	end
-- 	editbox:SetPoint("LEFT",frame,-8,0)
-- 	editbox:SetPoint("RIGHT",frame,8,0)

-- end

-- local function RGBPercToHex(r, g, b)
-- 	r = r <= 1 and r >= 0 and r or 0
-- 	g = g <= 1 and g >= 0 and g or 0
-- 	b = b <= 1 and b >= 0 and b or 0
-- 	return string.format("%02x%02x%02x", r*255, g*255, b*255)
-- end

-- local pcolors = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
-- pcolors = RGBPercToHex(pcolors.r, pcolors.g, pcolors.b)
-- local pstring = "@|cff"..pcolors..playername.."|r"

-- local function AddMessage(self, text, ...)
-- 	-- Remove player brackets
-- 	text = text:gsub("|Hplayer:([^%|]+)|h%[([^%]]+)%]|h", "|Hplayer:%1|h%2|h")
	
-- 	text = text:gsub("<Away>", "")
-- 	text = text:gsub("<Busy>", "")

-- 	-- Strip yells: says: from chat
-- 	text = text:gsub("|Hplayer:([^%|]+)|h(.+)|h says:", "|Hplayer:%1|h%2|h:");
-- 	text = text:gsub("|Hplayer:([^%|]+)|h(.+)|h yells:", "|Hplayer:%1|h%2|h:");

-- 	-- Whispers are now done with globals
-- 	--text = text:gsub("|Hplayer:([^%|]+)|h(.+)|h whispers:", "F |Hplayer:%1|h%2|h:")
-- 	--text = text:gsub("^To ", "T ")
-- 	text = text:gsub("Guild Message of the Day:", "GMotD -")
-- 	text = text:gsub("has come online.", "+")
-- 	text = text:gsub("has gone offline.", "-")
		
-- 	--channel replace (Trade and custom)
-- 	--text = text:gsub("%[(%d0?)%. .-%]", "%1") -- removes channel #
-- 	--text = text:gsub("^|Hchannel:[^%|]+|h%[[^%]]+%]|h ", "") -- clears all channel names
-- 	text = text:gsub('|h%[(%d+)%. .-%]|h', '|h%1.|h')
	
-- 	--url search
-- 	text = text:gsub('([wWhH][wWtT][wWtT][%.pP]%S+[^%p%s])', '|cffffffff|Hurl:%1|h[%1]|h|r')
	
-- 	-- Alert players with @playername callouts
-- 	local callout = text:lower():find("@"..playername:lower()) or text:lower():find(pstring:lower())
-- 	if (callout) then alertMessage(text) end
	
-- 	local everyonecallout = text:lower():find("@everyone")
-- 	if (everyonecallout) then
-- 		if (text:find("GUILD")) then
-- 			C_ChatInfo.SendAddonMessage("bdChat",text,"GUILD")
-- 		elseif (text:find("RAID")) then
-- 			C_ChatInfo.SendAddonMessage("bdChat",text,"RAID")
-- 		elseif (text:find("OFFICER")) then
-- 			C_ChatInfo.SendAddonMessage("bdChat",text,"OFFICER")
-- 		elseif (text:find("PARTY")) then
-- 			C_ChatInfo.SendAddonMessage("bdChat",text,"PARTY")
-- 		end
-- 	end
	
-- 	if (justreturn) then
-- 		return text
-- 	else
-- 		return self.DefaultAddMessage(self, text, ...)
-- 	end
-- end


-- local function colorName(self, event, msg, ...)
-- 	local test = msg:gsub("[^a-zA-Z%s]",'')
	
-- 	local words = {strsplit(' ',test)}
-- 	for i = 1, #words do
-- 		local w = words[i]
		
-- 		if (w and not (w == "player" or w == "target") and UnitName(w) and UnitIsPlayer(w)) then
-- 			local class = select(2, UnitClass(w))
-- 			local colors = RAID_CLASS_COLORS[class]
-- 			if (colors) then
-- 				msg = gsub(msg, w, "|cff"..RGBPercToHex(colors.r,colors.g,colors.b).."%1|r")
-- 			end
-- 		end
-- 	end
	
-- 	return false, msg, ...
-- end
-- ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", colorName)
-- ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", colorName)
-- ChatFrame_AddMessageEventFilter("CHAT_MSG_OFFICER", colorName)
-- ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", colorName)
-- ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", colorName)
-- ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", colorName)
-- ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", colorName)
-- ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", colorName)
-- ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", colorName)
-- ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_WARNING", colorName)
-- ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", colorName)
-- ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", colorName)
-- ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", colorName)
-- ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", colorName)

-- -- do all the default chat channels
-- for i = 1, NUM_CHAT_WINDOWS do
-- 	local chatframe = _G["ChatFrame"..i]
-- 	skinChat(chatframe)
-- 	if (i ~= 2) then
-- 		chatframe.DefaultAddMessage = chatframe.AddMessage
-- 		chatframe.AddMessage = AddMessage
-- 	end
-- end

-- hooksecurefunc("FCF_OpenTemporaryWindow", function()
-- 	for devb, name in next, CHAT_FRAMES do
-- 		local frame = _G[name]
-- 		if (frame.isTemporary) then
-- 			skinChat(frame)
-- 		end
-- 	end
-- end)

-- local DefaultSetItemRef = SetItemRef
-- function SetItemRef(link, ...)
-- 	local type, value = link:match("(%a+):(.+)")
-- 	--print(type)
-- 	if IsAltKeyDown() and type == "player" then
-- 		InviteUnit(value:match("([^:]+)"))
-- 	elseif (type == "url") then
-- 		local eb = LAST_ACTIVE_CHAT_EDIT_BOX or ChatFrame1EditBox
-- 		if not eb then return end
-- 		eb:Show()
-- 		eb:SetText(value)
-- 		eb:SetFocus()
-- 		eb:HighlightText()
-- 	else
-- 		return DefaultSetItemRef(link, ...)
-- 	end
-- end

-- FloatingChatFrame_OnMouseScroll = function(self,dir)
-- 	if(dir > 0) then
-- 		if(IsShiftKeyDown()) then 
-- 			self:ScrollToTop() 
-- 		else 
-- 			self:ScrollUp()
-- 			if (IsControlKeyDown()) then
-- 				self:ScrollUp()
-- 			end
-- 		end
-- 	else
-- 		if(IsShiftKeyDown()) then 
-- 			self:ScrollToBottom() 
-- 		else 
-- 			self:ScrollDown() 
-- 			if (IsControlKeyDown()) then
-- 				self:ScrollDown()
-- 			end
-- 		end
-- 	end
-- end

-- bdChat:RegisterEvent('PLAYER_ENTERING_WORLD');
-- bdChat:RegisterEvent('ENCOUNTER_START');
-- bdChat:RegisterEvent('ENCOUNTER_END');
-- bdChat:RegisterEvent('MAIL_SHOW');
-- bdChat:RegisterEvent('MAIL_CLOSED');
-- bdChat:RegisterEvent('CHAT_MSG_ADDON');
-- local activetabs = {}
-- local function eventHandler(self, event, arg, arg2)
-- 	if event == "MAIL_SHOW" then
-- 		COPPER_AMOUNT = "%d"
-- 		SILVER_AMOUNT = "%d"
-- 		GOLD_AMOUNT = "%d"
-- 	elseif (event == "ENCOUNTER_START") then
-- 		if not config.hideincombat then return end
-- 		for i = 1, NUM_CHAT_WINDOWS do
-- 			local frame = _G["ChatFrame"..i]
-- 			if frame:IsShown() then
-- 				activetabs[#activetabs+1] = frame
-- 			end
-- 			frame:Hide()
-- 		end
-- 	elseif (event == "ENCOUNTER_END") then
-- 		if not config.hideincombat then return end
-- 		for k, v in pairs(activetabs) do
-- 			v:Show()
-- 		end
-- 	elseif (event == "CHAT_MSG_ADDON" and arg == "bdChat") then
-- 		alertMessage(arg2)
-- 	else
-- 		COPPER_AMOUNT = "%d|cFF954F28"..COPPER_AMOUNT_SYMBOL.."|r";
-- 		SILVER_AMOUNT = "%d|cFFC0C0C0"..SILVER_AMOUNT_SYMBOL.."|r";
-- 		GOLD_AMOUNT = "%d|cFFF0D440"..GOLD_AMOUNT_SYMBOL.."|r";
-- 	end
-- 	YOU_LOOT_MONEY = "+%s";
-- 	LOOT_MONEY_SPLIT = "+%s";
-- end
-- bdChat:SetScript("OnEvent", eventHandler);

