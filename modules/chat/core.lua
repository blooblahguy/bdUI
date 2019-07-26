--===============================================
-- FUNCTIONS
--===============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Chat")
local config
local gsub = string.gsub

--===============================================
-- Core functionality
-- place core functionality here
--===============================================
function mod:initialize()
	config = mod._config

	-- defaults
	mod:set_defaults()
	-- alerts
	mod:create_alerts()
	-- bubbles
	mod:create_chat_bubbles()
	-- telltarget command
	mod:telltarget()
	-- community mask
	mod:create_community()
	-- emojis
	mod:create_emojis()

	-- finally
	mod:skin_chats()
end

--=============================================
-- DEFAULTS
--=============================================
function mod:set_defaults()
	-- class color within text
	local function color_name(self, event, msg, ...)
		local test = msg:gsub("[^a-zA-Z%s]",'')
		
		local words = {strsplit(' ',test)}
		for i = 1, #words do
			local w = words[i]
			
			if (w and not (w == "player" or w == "target") and UnitName(w) and UnitIsPlayer(w)) then
				local class = select(2, UnitClass(w))
				local colors = RAID_CLASS_COLORS[class]
				if (colors) then
					msg = gsub(msg, w, "|cff"..RGBPercToHex(colors.r,colors.g,colors.b).."%1|r")
				end
			end
		end
		
		return false, msg, ...
	end
	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", color_name)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", color_name)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_OFFICER", color_name)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", color_name)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", color_name)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", color_name)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", color_name)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", color_name)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", color_name)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_WARNING", color_name)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", color_name)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", color_name)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", color_name)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", color_name)

	-- currency coloring
	COPPER_AMOUNT = "%d|cFF954F28"..COPPER_AMOUNT_SYMBOL.."|r";
	SILVER_AMOUNT = "%d|cFFC0C0C0"..SILVER_AMOUNT_SYMBOL.."|r";
	GOLD_AMOUNT = "%d|cFFF0D440"..GOLD_AMOUNT_SYMBOL.."|r";
	YOU_LOOT_MONEY = "+%s";
	LOOT_MONEY_SPLIT = "+%s";

	--font size
	CHAT_FONT_HEIGHTS = {10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20}

	--tabs
	CHAT_FRAME_FADE_TIME = 0
	CHAT_TAB_SHOW_DELAY = 0
	CHAT_TAB_HIDE_DELAY = 0
	CHAT_FRAME_FADE_OUT_TIME = 0
	CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA = 1
	CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 0
	CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA = 1
	CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = 0
	CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA = 1
	CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA = 1

	CHAT_WHISPER_GET              = "F %s "
	CHAT_WHISPER_INFORM_GET       = "T %s "
	CHAT_BN_WHISPER_GET           = "F %s "
	CHAT_BN_WHISPER_INFORM_GET    = "T %s "
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
	YOU_LOOT_MONEY_GUILD = YOU_LOOT_MONEY
	LOOT_MONEY_SPLIT_GUILD = LOOT_MONEY_SPLIT

	-- Enable Classcolor in chat author
	ToggleChatColorNamesByClassGroup(true, "SAY")
	ToggleChatColorNamesByClassGroup(true, "EMOTE")
	ToggleChatColorNamesByClassGroup(true, "YELL")
	ToggleChatColorNamesByClassGroup(true, "GUILD")
	ToggleChatColorNamesByClassGroup(true, "OFFICER")
	ToggleChatColorNamesByClassGroup(true, "GUILD_ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(true, "ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(true, "WHISPER")
	ToggleChatColorNamesByClassGroup(true, "PARTY")
	ToggleChatColorNamesByClassGroup(true, "PARTY_LEADER")
	ToggleChatColorNamesByClassGroup(true, "RAID")
	ToggleChatColorNamesByClassGroup(true, "RAID_LEADER")
	ToggleChatColorNamesByClassGroup(true, "RAID_WARNING")
	ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND")
	ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND_LEADER")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL1")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL2")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL3")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL4")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL5")
	ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT")
	ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT_LEADER")
end

--=========================================================
-- CONFIG CALLBACK
--=========================================================
function mod:config_callback()
	if (not ChatFrame1.bd_backdrop) then
		bdUI:set_backdrop(ChatFrame1)
	end
	ChatFrame1.bd_background:SetAlpha(config.bgalpha)
	ChatFrame1.bd_background:SetPoint("TOPLEFT", ChatFrame1, "TOPLEFT", -10, 10)
	ChatFrame1.bd_background:SetPoint("BOTTOMRIGHT", ChatFrame1, "BOTTOMRIGHT", 10, -10)
	ChatFrame1.border:SetAlpha(config.bgalpha)
end

--=========================================================
-- SKIN ALL CHAT FRAMES
--=========================================================
function mod:skin_chats()
	-- Hide side buttons
	ChatFrameMenuButton:Hide()
	ChatFrameMenuButton.Show = noop
	QuickJoinToastButton:Hide()
	QuickJoinToastButton.Show = noop
	ChatFrameChannelButton:Hide()
	ChatFrameChannelButton.Show = noop

	BNToastFrame:SetClampedToScreen(true)
	BNToastFrame:SetClampRectInsets(-15, 15, 15, -15)

	local point, anchor, apoint, x, y = GeneralDockManager:GetPoint()
	GeneralDockManager:SetPoint(point, anchor, apoint, 0, 16)
	GeneralDockManager:SetFrameStrata("HIGH")

	--editbox font
	ChatFontNormal:SetFont(bdUI.media.font, 14)
	ChatFontNormal:SetShadowOffset(1,1)
	ChatFontNormal:SetShadowColor(0,0,0)

	bdUI:set_backdrop(ChatFrame1)

	-- skin all the default chat channels
	for i = 1, NUM_CHAT_WINDOWS do
		local chatframe = _G["ChatFrame"..i]
		mod:skin_single_chat(chatframe)
		if (i ~= 2) then
			chatframe.DefaultAddMessage = chatframe.AddMessage
			chatframe.AddMessage = mod.filter_message
		end
	end

	-- skin pop up chats
	hooksecurefunc("FCF_OpenTemporaryWindow", function()
		for devb, name in next, CHAT_FRAMES do
			local frame = _G[name]
			if (frame.isTemporary) then
				mod:skin_single_chat(frame)
			end
		end
	end)

	-- scroll wheel functionality
	FloatingChatFrame_OnMouseScroll = function(self,dir)
		if(dir > 0) then
			if(IsShiftKeyDown()) then 
				self:ScrollToTop() 
			else 
				self:ScrollUp()
				if (IsControlKeyDown()) then
					self:ScrollUp()
				end
			end
		else
			if(IsShiftKeyDown()) then 
				self:ScrollToBottom() 
			else 
				self:ScrollDown() 
				if (IsControlKeyDown()) then
					self:ScrollDown()
				end
			end
		end
	end

	-- Alt-invite and url clicks
	local DefaultSetItemRef = SetItemRef
	function SetItemRef(link, ...)
		local type, value = link:match("(%a+):(.+)")
		if IsAltKeyDown() and type == "player" then
			InviteUnit(value:match("([^:]+)"))
		elseif (type == "url") then
			local eb = LAST_ACTIVE_CHAT_EDIT_BOX or ChatFrame1EditBox
			if not eb then return end
			eb:Show()
			eb:SetText(value)
			eb:SetFocus()
			eb:HighlightText()
		else
			return DefaultSetItemRef(link, ...)
		end
	end
end

--=========================================================
-- SKIN SINGLE CHAT FRAME
--=========================================================
function mod:skin_single_chat(frame)
	local tabs = {"Left","Middle","Right","SelectedLeft","SelectedRight","SelectedMiddle","HighlightLeft","HighlightMiddle","HighlightRight"}

	if (not frame) then return end
	if (frame.skinned) then return end
	frame.skinned = true


	local fontSize = 14
	local name = frame:GetName()
	local editbox = _G[name..'EditBox']
	local buttonframe = _G[name..'ButtonFrame']
	local thumb = _G[name..'ThumbTexture']
	local resize = _G[name..'ResizeButton']
	local tex = {editbox:GetRegions()}
	local tab = _G[name..'Tab']
	local index = gsub(name,"ChatFrame","")
	local frameText = select(2, GetChatWindowInfo(index))
	if (frameText and frameText > 0) then
		fontSize = frameText
	end
	
	--main chat frame
	frame:SetFrameStrata("LOW")
	frame:SetClampRectInsets(0, 0, 0, 0)
	frame:SetMaxResize(UIParent:GetWidth()/2, UIParent:GetHeight()/2)
	frame:SetMinResize(100, 50)
	frame:SetFading(false)
	resize:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 9,-5)
	resize:SetScale(.4)
	resize:SetAlpha(0.7)

	-- to do: find out how best to display chat actionables, instead of just hiding them all
	thumb:Hide()
	
	-- kill textures
	for g = 1, #CHAT_FRAME_TEXTURES do
		_G[name..CHAT_FRAME_TEXTURES[g] ]:SetTexture(nil)
	end
	
	-- tab style
	_G[tab:GetName().."Text"]:SetFont(bdUI.media.font, fontSize,"thinoutline")
	_G[tab:GetName().."Text"]:SetTextColor(1,1,1)
	_G[tab:GetName().."Text"]:SetVertexColor(1,1,1)
	_G[tab:GetName().."Text"]:SetAlpha(.5)
	_G[tab:GetName().."Text"]:SetShadowOffset(0,0)
	_G[tab:GetName().."Text"]:SetShadowColor(0,0,0,0)
	_G[tab:GetName().."Text"].SetTextColor = noop
	_G[tab:GetName().."Text"].SetVertexColor = noop
	
	_G[tab:GetName().."Glow"]:SetTexture(bdUI.media.flat)
	_G[tab:GetName().."Glow"]:SetVertexColor(unpack(bdUI.media.blue))
	_G[tab:GetName().."Glow"].SetVertexColor = noop
	_G[tab:GetName().."Glow"].SetTextColor = noop
	
	for index, value in pairs(tabs) do
		local texture = _G[name..'Tab'..value]
		texture:SetTexture("")
	end
	hooksecurefunc(frame,"Show",function(self)
		_G[self:GetName().."TabText"]:SetAlpha(1)
	end)
	hooksecurefunc(frame,"Hide",function(self)
		_G[self:GetName().."TabText"]:SetAlpha(.5)
	end)
	
	--hide button frame
	buttonframe:Hide()
	buttonframe.Show = noop
	
	--editbox
	editbox:SetAltArrowKeyMode(false)
	bdUI:set_backdrop(editbox)
	_G[editbox:GetName().."Left"]:Hide()
	_G[editbox:GetName().."Mid"]:Hide()
	_G[editbox:GetName().."Right"]:Hide()
	for t = 6, #tex do tex[t]:SetAlpha(0) end
	editbox:ClearAllPoints()
	if name == "ChatFrame2" then
		editbox:SetPoint("BOTTOM",frame,"TOP",0,34)
	else
		editbox:SetPoint("BOTTOM",frame,"TOP",0,10)
	end
	editbox:SetPoint("LEFT",frame,-8,0)
	editbox:SetPoint("RIGHT",frame,8,0)
end

mod.filter_message = function(self, text, ...)
	-- Remove player brackets
	text = text:gsub("|Hplayer:([^%|]+)|h%[([^%]]+)%]|h", "|Hplayer:%1|h%2|h")
	
	-- Abbreviate
	text = text:gsub("<Away>", "<afk>")
	text = text:gsub("<Busy>", "<dnd>")

	-- Strip yells: says: from chat
	text = text:gsub("|Hplayer:([^%|]+)|h(.+)|h says:", "|Hplayer:%1|h%2|h:");
	text = text:gsub("|Hplayer:([^%|]+)|h(.+)|h yells:", "|Hplayer:%1|h%2|h:");

	-- Whispers are now done with globals
	text = text:gsub("Guild Message of the Day:", "GMotD -")
	text = text:gsub("has come online.", "+")
	text = text:gsub("has gone offline.", "-")
		
	--channel replace (Trade and custom)
	text = text:gsub('|h%[(%d+)%. .-%]|h', '|h%1.|h')
	
	--url search
	text = text:gsub('([wWhH][wWtT][wWtT][%.pP]%S+[^%p%s])', '|cffffffff|Hurl:%1|h[%1]|h|r')

	-- filter with plugins
	local filter = bdUI:do_action("chat_message", text)
	text = filter or text
	
	return self.DefaultAddMessage(self, text, ...)
end
