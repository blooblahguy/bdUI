--============================================
-- CHAT BUBBLES
-- Bubble skinning for outside of raids/bg
--============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Chat")
local update = 0
local numkids = 0
local bubbles = {}
local gsub = string.gsub

-- Replaces player names in chat bubbles
local function skin_bubble_text(self)
	local text = self.text:GetText()
	local test = text:gsub("[^a-zA-Z%s]",'')
	local words = {strsplit(" ",test)}
	for i = 1, #words do
		local w = words[i]
		
		if (UnitName(w)) then
			local class = select(2, UnitClass(w))
			local colors = RAID_CLASS_COLORS[class]
			if (colors) then
				text = gsub(text, w, "|cff"..RGBPercToHex(colors.r,colors.g,colors.b).."%1|r")
			end
		end
	end
	self.text:SetText(text)
end

-- returns if its a skinnable chat bubble
local function ischatbubble(frame)
	if frame:IsForbidden() then return end
	if frame:GetName() then return end
	if not frame:GetRegions() then return end
	if not frame:GetRegions().GetTexture then return end
	return frame:GetRegions():GetTexture() == "Interface\\Tooltips\\ChatBubble-Background"
end

function mod:create_chat_bubbles()
	local config = mod:get_save()

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
		local border = bdUI:get_border(frame)
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
	
	mod:SetScript("OnUpdate", function(self, elapsed)
		update = update + elapsed
		if update > .05 then
			update = 0
			local newnumkids = WorldFrame:GetNumChildren()
			if newnumkids ~= numkids then
				for i = numkids + 1, newnumkids do
					local frame = select(i, WorldFrame:GetChildren())

					if ischatbubble(frame) then
						skinbubble(frame)
					end
				end
				numkids = newnumkids
			end
		end
	end)
end