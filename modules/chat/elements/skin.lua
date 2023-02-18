local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Chat")

local tabs = {"Left","Middle","Right","SelectedLeft","SelectedRight","SelectedMiddle","HighlightLeft","HighlightMiddle","HighlightRight"}

local tab_font = CreateFont("bdChat_TabFont")
tab_font:SetFont(bdUI.media.font, 14, "OUTLINE")
tab_font:SetShadowColor(0, 0, 0, 0)
tab_font:SetShadowOffset(0, 0)

hooksecurefunc(tab_font, "SetFont", function(...) print("chaning my font", ...) end)

local function skin_frame_bg(frame)
	-- if (not frame) then return end

	-- bdUI:set_backdrop(frame)
	-- frame._background:SetAlpha(mod.config.bgalpha)
	-- frame._background:SetPoint("TOPLEFT", ChatFrame1, "TOPLEFT", -10, 10)
	-- frame._background:SetPoint("BOTTOMRIGHT", ChatFrame1, "BOTTOMRIGHT", 10, -10)
	-- frame._border:SetAlpha(mod.config.bgalpha)
end

local function skin_tab(frame)
	local name = frame:GetName()
	local tab = _G[name..'Tab']
	local old_text = _G[tab:GetName().."Text"]
	local glow = _G[tab:GetName().."Glow"]

	_G[tab:GetName().."Text"]:Hide()
	_G[tab:GetName().."Text"].Show = noop

	local text = tab:CreateFontString(nil)
	text:SetFontObject(tab_font)
	text:SetPoint("CENTER")
	text:SetText(old_text:GetText())
	-- text:SetFontObject(bdUI:get_font(14, "OUTLINE"))
	-- text:SetFontObject(tab_font)
	-- text:SetTextColor(1,1,1)
	-- text:SetVertexColor(1,1,1)
	-- text:SetAlpha(.5)
	-- text:SetShadowOffset(0,0)
	-- text:SetShadowColor(0,0,0,0)
	-- -- text.bdSetTextColor = text.SetTextColor
	-- -- text.bdSetFontObject = text.SetFontObject
	-- text.SetTextColor = noop
	-- text.SetFont = noop
	-- text.SetFontObject = noop

	-- local function force_font()
	-- 	if (text:GetFontObject() ~= bdUI:get_font(14, "OUTLINE")) then

	-- 	end
	-- end

	-- hooksecurefunc(text, "SetFont", function() print("set font") end)
	-- hooksecurefunc(text, "SetFontObject", function() print("set font object") end)

	-- frame:RegisterEvent("UPDATE_CHAT_WINDOWS")
	-- frame:RegisterEvent("UPDATE_CHAT_COLOR")
	-- frame:HookScript("OnEvent", function()
	-- 	text:bdSetFontObject(bdUI:get_font(14, "OUTLINE"))
	-- 	text:SetTextColor(1,1,1)
	-- end)

	hooksecurefunc(glow, "Show", function()
		text:SetTextColor(.6, .7, 1)
	end)
	hooksecurefunc(glow, "Hide", function()
		text:SetTextColor(1, 1, 1)
	end)
	
	glow:SetTexture(nil)
	glow.SetTexture = noop
	
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
end

local function skin_frame(frame)
	if (not frame) then return end
	if (frame.skinned) then return end
	frame.skinned = true


	local fontSize = 14
	local name = frame:GetName()
	local editbox = _G[name..'EditBox']
	local buttonframe = _G[name..'ButtonFrame']
	local thumb = _G[name..'ThumbTexture']
	local resize = _G[name..'ResizeButton']
	local background = _G[name..'Background']
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
	if (frame.SetResizeBounds) then
		frame:SetResizeBounds(100, 50, UIParent:GetWidth()/2, UIParent:GetHeight()/2)
	else
		frame:SetMaxResize(UIParent:GetWidth()/2, UIParent:GetHeight()/2)
		frame:SetMinResize(100, 50)
	end
	frame:SetFading(false)
	frame:SetClampedToScreen(false)
	resize:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 9,-5)
	resize:SetScale(.4)
	resize:SetAlpha(0.7)

	-- to do: find out how best to display chat actionables, instead of just hiding them all
	if (thumb) then
		thumb:Hide()
	end

	-- move background
	background:ClearAllPoints()
	background:SetPoint("TOPLEFT", -8,  8)
	background:SetPoint("BOTTOMRIGHT", 8, -8)
	background.border = CreateFrame("frame", nil, frame, BackdropTemplateMixin and "BackdropTemplate")
	background.border:SetPoint("TOPLEFT", -8,  8)
	background.border:SetPoint("BOTTOMRIGHT", 8, -8)
	background.border:SetBackdrop({bgFile = bdUI.media.flat, edgeFile = bdUI.media.flat, edgeSize = bdUI.border})
	background.border:SetBackdropColor(0, 0, 0, 0)
	background.border:SetBackdropBorderColor(unpack(bdUI.media.border))
	hooksecurefunc(background, "SetAlpha", function(self, alpha)
		background.border:SetAlpha(alpha)
	end)
	
	-- kill textures
	-- for g = 1, #CHAT_FRAME_TEXTURES do
	-- 	_G[name..CHAT_FRAME_TEXTURES[g] ]:SetTexture(nil)
	-- end
	
	-- tab style
	skin_tab(frame)
	
	--hide button frame
	buttonframe:Hide()
	buttonframe.Show = noop
	
	--editbox
	editbox:SetAltArrowKeyMode(false)
	bdUI:set_backdrop(editbox)
	_G[editbox:GetName().."Left"]:Hide()
	_G[editbox:GetName().."Mid"]:Hide()
	_G[editbox:GetName().."Right"]:Hide()
	-- for t = 6, #tex do tex[t]:SetAlpha(0) end
	editbox:ClearAllPoints()
	if name == "ChatFrame2" then
		editbox:SetPoint("BOTTOM",frame,"TOP",0,34)
	else
		editbox:SetPoint("BOTTOM",frame,"TOP",0,10)
	end
	editbox:SetPoint("LEFT",frame,-8,0)
	editbox:SetPoint("RIGHT",frame,8,0)	
end

function mod:skin_chat()
	--font size
	CHAT_FONT_HEIGHTS = {10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20}

	--tabs
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

	-- print("CHAT_FRAME_FADE_TIME", issecurevariable("CHAT_FRAME_FADE_TIME"))
	-- print("CHAT_TAB_SHOW_DELAY", issecurevariable("CHAT_TAB_SHOW_DELAY"))
	-- print("CHAT_TAB_HIDE_DELAY", issecurevariable("CHAT_TAB_HIDE_DELAY"))
	-- print("CHAT_FRAME_FADE_OUT_TIME", issecurevariable("CHAT_FRAME_FADE_OUT_TIME"))
	-- print("CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA", issecurevariable("CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA"))
	-- print("CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA", issecurevariable("CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA"))
	-- print("CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA", issecurevariable("CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA"))
	-- print("CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA", issecurevariable("CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA"))
	-- print("CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA", issecurevariable("CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA"))
	-- print("CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA", issecurevariable("CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA"))
	-- print("COPPER_AMOUNT", issecurevariable("COPPER_AMOUNT"))

	-- currency coloring
	COPPER_AMOUNT = "%d|cFF954F28"..COPPER_AMOUNT_SYMBOL.."|r";
	SILVER_AMOUNT = "%d|cFFC0C0C0"..SILVER_AMOUNT_SYMBOL.."|r";
	GOLD_AMOUNT = "%d|cFFF0D440"..GOLD_AMOUNT_SYMBOL.."|r";
	YOU_LOOT_MONEY = "+%s";
	LOOT_MONEY_SPLIT = "+%s";
	YOU_LOOT_MONEY_GUILD = YOU_LOOT_MONEY
	LOOT_MONEY_SPLIT_GUILD = LOOT_MONEY_SPLIT
	
	-- Skin chats
	-- Hide side buttons
	ChatFrameMenuButton:Hide()
	ChatFrameMenuButton.Show = noop
	if (QuickJoinToastButton) then
		QuickJoinToastButton:Hide()
		QuickJoinToastButton.Show = noop
	end
	ChatFrameChannelButton:Hide()
	ChatFrameChannelButton.Show = noop

	BNToastFrame:SetClampedToScreen(true)
	BNToastFrame:SetClampRectInsets(-15, 15, 15, -15)

	local point, anchor, apoint, x, y = GeneralDockManager:GetPoint()
	GeneralDockManager:SetPoint(point, anchor, apoint, 0, 16)
	GeneralDockManager:SetFrameStrata("HIGH")

	--editbox font
	ChatFontNormal:SetFontObject(bdUI:get_font(14, "OUTLINE"))
	ChatFontNormal:SetShadowOffset(1,1)
	ChatFontNormal:SetShadowColor(0,0,0)

	-- skin all the default chat channels
	for i = 1, NUM_CHAT_WINDOWS do
		local chatframe = _G["ChatFrame"..i]
		skin_frame(chatframe)
	end

	-- skin pop up chats
	hooksecurefunc("FCF_OpenTemporaryWindow", function()
		for devb, name in next, CHAT_FRAMES do
			local frame = _G[name]
			if (frame.isTemporary) then
				skin_frame(frame)
				skin_frame_bg(frame)
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
end