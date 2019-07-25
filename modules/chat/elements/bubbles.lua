local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Chat")

function mod:create_chat_bubbles()
	-- Replaces player names in chat bubbles
	local function skinChat(self)
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

	-- Skin Chat Bubbles
	--local rawtextbox = CreateFrame("EditBox",nil,UIParent)
	-- --rawtextbox:SetAutoFocus(false)
	-- local function rawText(text)
		-- -- starting from the beginning, replace item and spell links with just their names
		-- text = gsub(text, "|r|h:(.+)|cff(.+)|H(.+)|h%[(.+)%]|h|r", "|r|h:%1%4");
		-- text = strtrim(text)
		-- --text = gsub(text, "\124", "\124\124"); -- if we ever need to see the raw itemlinks
		-- return text
	-- end

	local function skinbubble(frame)
		for i=1, frame:GetNumRegions() do
			local region = select(i, frame:GetRegions())
			if region:GetObjectType() == "Texture" then
				region.defaulttex = region:GetTexture()
				region:SetTexture(nil)
			elseif region:GetObjectType() == "FontString" then
				frame.text = region
				frame.defaultfont, frame.defaultsize = frame.text:GetFont()
			end
		end
		local scale = UIParent:GetEffectiveScale()*2
		
		if (not frame.hooked) then
			frame:HookScript("OnShow",skinChat)	
			frame.hooked = true
		end
		skinChat(frame)
		
		bdCore:hookEvent("bdChat_bubble_updated",function()
			if (config.skinchatbubbles == "Default*") then		
				frame.text:SetFont(frame.defaultfont, frame.defaultsize)

				for i=1, frame:GetNumRegions() do
					local region = select(i, frame:GetRegions())
					if region:GetObjectType() == "Texture" then
						region:SetTexture(region.defaulttex)
					end
				end
			elseif (config.skinchatbubbles == "Removed") then
				frame.text:SetFont(bdCore.media.font, 13, "OUTLINE")
				frame:SetBackdrop({bgFile = bdCore.media.flat})
				frame:SetBackdropColor(0,0,0,0)
				frame:SetBackdropBorderColor(0,0,0,0)
			elseif (config.skinchatbubbles == "Skinned" or config.skinchatbubbles) then
				frame.text:SetFont(bdCore.media.font, 13, "OUTLINE")
				frame:SetBackdrop({
					bgFile = bdCore.media.flat,
					edgeFile = bdCore.media.flat,
					edgeSize = scale,
					insets = {left = scale, right = scale, top = scale, bottom = scale}
				})
				frame:SetBackdropColor(unpack(bdCore.media.backdrop))
				frame:SetBackdropBorderColor(unpack(bdCore.media.border))
			end
		end)
		
		bdCore:triggerEvent("bdChat_bubble_updated")
		tinsert(bubbles, frame)
	end
	local function ischatbubble(frame)
		if frame:IsForbidden() then return end
		if frame:GetName() then return end
		if not frame:GetRegions() then return end
		if not frame:GetRegions().GetTexture then return end
		return frame:GetRegions():GetTexture() == "Interface\\Tooltips\\ChatBubble-Background"
	end
	bdChat:SetScript("OnUpdate", function(self, elapsed)
		update = update + elapsed
		if update > .05 then
			update = 0
			local newnumkids = WorldFrame:GetNumChildren()
			if newnumkids ~= numkids then
				for i=numkids + 1, newnumkids do
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