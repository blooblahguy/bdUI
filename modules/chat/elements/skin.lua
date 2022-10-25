local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Chat")


local function skin_frame_bg(frame)
	if (not frame) then return end

	bdUI:set_backdrop(frame)
	frame._background:SetAlpha(mod.config.bgalpha)
	frame._background:SetPoint("TOPLEFT", ChatFrame1, "TOPLEFT", -10, 10)
	frame._background:SetPoint("BOTTOMRIGHT", ChatFrame1, "BOTTOMRIGHT", 10, -10)
	frame._border:SetAlpha(mod.config.bgalpha)
end

local function skin_frame(frame)
	-- skin frames
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
	
	-- kill textures
	for g = 1, #CHAT_FRAME_TEXTURES do
		_G[name..CHAT_FRAME_TEXTURES[g] ]:SetTexture(nil)
	end
	
	-- tab style
	-- _G[tab:GetName().."Text"]:SetFontObject(bdUI:get_font(fontSize, "OUTLINE"))
	-- _G[tab:GetName().."Text"]:SetTextColor(1,1,1)
	-- _G[tab:GetName().."Text"]:SetVertexColor(1,1,1)
	-- _G[tab:GetName().."Text"]:SetAlpha(.5)
	-- _G[tab:GetName().."Text"]:SetShadowOffset(0,0)
	-- _G[tab:GetName().."Text"]:SetShadowColor(0,0,0,0)
	-- _G[tab:GetName().."Text"].SetTextColor = noop
	-- _G[tab:GetName().."Text"].SetVertexColor = noop
	
	-- _G[tab:GetName().."Glow"]:SetTexture(bdUI.media.flat)
	-- _G[tab:GetName().."Glow"]:SetVertexColor(unpack(bdUI.media.blue))
	-- _G[tab:GetName().."Glow"].SetVertexColor = noop
	-- _G[tab:GetName().."Glow"].SetTextColor = noop
	
	-- for index, value in pairs(tabs) do
	-- 	local texture = _G[name..'Tab'..value]
	-- 	texture:SetTexture("")
	-- end
	-- hooksecurefunc(frame,"Show",function(self)
	-- 	_G[self:GetName().."TabText"]:SetAlpha(1)
	-- end)
	-- hooksecurefunc(frame,"Hide",function(self)
	-- 	_G[self:GetName().."TabText"]:SetAlpha(.5)
	-- end)
	
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
	ChatFontNormal:SetFontObject(bdUI:get_font(14, ""))
	ChatFontNormal:SetShadowOffset(1,1)
	ChatFontNormal:SetShadowColor(0,0,0)

	-- skin all the default chat channels
	for i = 1, NUM_CHAT_WINDOWS do
		local chatframe = _G["ChatFrame"..i]
		skin_frame(chatframe)
		skin_frame_bg(chatframe)
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