local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Chat")

local texture_slices = {"Left","Middle","Mid","Right","SelectedLeft","SelectedRight","SelectedMiddle","HighlightLeft","HighlightMiddle","HighlightRight","ActiveLeft","ActiveMiddle","ActiveRight"}
local dont_fade = {}


local function skin_frame_bg(frame)
	local name = frame:GetName()
	local background = _G[name..'Background']

	-- move background
	background:ClearAllPoints()
	background:SetPoint("TOPLEFT", -8,  8)
	background:SetPoint("BOTTOMRIGHT", 8, -8)
	background.border = CreateFrame("frame", nil, frame, BackdropTemplateMixin and "BackdropTemplate")
	background.border:SetPoint("TOPLEFT", -8,  8)
	background.border:SetPoint("BOTTOMRIGHT", 8, -8)
	background.border:SetBackdrop({bgFile = bdUI.media.flat, edgeFile = bdUI.media.flat, edgeSize = bdUI.border})
	background.border:SetBackdropColor(0, 0, 0, 0)
	background.border:SetAlpha(background:GetAlpha())
	background.border:SetBackdropBorderColor(unpack(bdUI.media.border))
	hooksecurefunc(background, "SetAlpha", function(self, alpha)
		background.border:SetAlpha(alpha)
	end)
end

local function skin_tab(frame)
	local name = frame:GetName()
	local tab = _G[name..'Tab']
	local old_text = _G[tab:GetName().."Text"] or _G[tab:GetName()].Text
	local glow = _G[tab:GetName().."Glow"]

	-- replace tab text with new object
	old_text:Hide()
	old_text.Show = noop
	local text = tab:CreateFontString(nil)
	text:SetFontObject(bdUI:get_font(14, "THINOUTLINE"))
	text:SetPoint("CENTER")
	text:SetText(old_text:GetText())
	tab.newtext = text
	hooksecurefunc(StaticPopup1, "Hide", function(...)
		text:SetText(old_text:GetText())
	end)
	frame:RegisterEvent("CHANNEL_UI_UPDATE")
	frame:HookScript("OnEvent", function()
		text:SetText(old_text:GetText())
	end)

	-- hooking tab color into glow
	hooksecurefunc(glow, "Show", function()
		text:SetTextColor(.2, .3, 1)
	end)
	hooksecurefunc(glow, "Hide", function()
		text:SetTextColor(1, 1, 1)
	end)
	glow:SetTexture(nil)
	glow.SetTexture = noop
	
	-- clearing textures
	bdUI:strip_textures(tab, false)
	for index, value in pairs(texture_slices) do
		local texture = _G[name..'Tab'..value] or _G[name..'Tab'][value]
		if (texture) then
			texture:SetTexture("")
		end
	end

	-- set tab alpha if our frame is shown
	-- hooksecurefunc(frame, "Show", function(self)
	-- 	-- text:SetAlpha(1)
	-- end)
	-- hooksecurefunc(frame, "Hide", function(self)
	-- 	-- text:SetAlpha(.5)
	-- end)

	-- stop chat fade
	if (tab:IsShown()) then
		dont_fade[tab] = true
		hooksecurefunc(tab, "Hide", function(self) self:Show() end)
		hooksecurefunc(tab, "SetAlpha", function(self, alpha) 
			if (alpha == 0) then
				self:SetAlpha(1)
				if (frame:IsShown()) then
					self:SetAlpha(1)
				end
			end
		end)
	end
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
	local tex = {editbox:GetRegions()}
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
	--hide button frame
	buttonframe:Hide()
	buttonframe.Show = noop
	
	-- tab style
	skin_tab(frame)
	
	--editbox
	editbox:SetAltArrowKeyMode(false)
	for k, t in pairs(texture_slices) do
		local tex = _G[editbox:GetName()..t]
		if (tex) then
			tex:Hide()
			tex.Show = noop
		end
	end
	-- bdUI:strip_textures(editbox, false)
	bdUI:set_backdrop(editbox)
	editbox:ClearAllPoints()
	if name == "ChatFrame2" then
		editbox:SetPoint("BOTTOM",frame,"TOP",0,34)
	else
		editbox:SetPoint("BOTTOM",frame,"TOP",0,10)
	end
	editbox:SetPoint("LEFT",frame,-8,0)
	editbox:SetPoint("RIGHT",frame,8,0)	

	local name, size = frame:GetFont()
	frame:SetFont(bdUI.media.font, size, "THINOUTLINE")
	frame:SetShadowColor(0, 0, 0, 0)
	frame:SetShadowOffset(0, 0)

	dont_fade[frame] = true
end



function mod:skin_chat()
	--font size
	CHAT_FONT_HEIGHTS = {10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20}

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

	-- skin all the default chat channels
	for i = 1, NUM_CHAT_WINDOWS do
		local chatframe = _G["ChatFrame"..i]
		chatframe.oldAlpha = 0
		skin_frame(chatframe)
		skin_frame_bg(chatframe)
	end

	-- stop fade stuff
	FCF_FadeInChatFrame(ChatFrame1)
	hooksecurefunc("UIFrameFadeOut", function(frame) if (dont_fade[frame]) then UIFrameFadeRemoveFrame(frame) end end)
	hooksecurefunc("FCF_FadeOutChatFrame", function(frame) if (dont_fade[frame]) then UIFrameFadeRemoveFrame(frame) end end)
	hooksecurefunc("FCF_HideOnFadeFinished", function(frame) if (dont_fade[frame]) then frame:Show() end end)

	-- there doesn't seem to be a great way around this. this doesn't taint, but it doesn't feel good either
	OldFCF_FadeOutChatFrame = FCF_FadeOutChatFrame
	FCF_FadeOutChatFrame = function(frame)
		if (dont_fade[frame]) then
			frame.hasBeenFaded = nil
			return
		end
		OldFCF_FadeOutChatFrame(frame)
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