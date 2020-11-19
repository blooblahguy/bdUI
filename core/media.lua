local bdUI, c, l = unpack(select(2, ...))

--========================================================
-- Themes
--========================================================
function bdUI:register_theme(name, callback)
	
	
	-- callback()
end

bdUI:register_theme("bdUI", {
	["primaryFont"] = 2,
	["secondaryFont"] = 2,
	["primaryColor"] = 2,
	["secondaryColor"] = 2,
	["borderSize"] = 2,
	["backgroundColor"] = 2,
	["borderColor"] = 2,
})

--========================================================
-- Fonts
--========================================================

function bdUI:new_font(name)
	size = size or 15
	outline = outline or "OUTLINE"

	local font = CreateFont(name, size, outline)
	font:SetFont(bdUI.media.font, size, outline)
	font:SetShadowColor(0, 0, 0)
	font:SetShadowOffset(0, 0)

	bdUI.fonts[name] = font
	
	return font
end

function bdUI:get_font_path(font)
	return bdUI.shared:Fetch("font", font)
end

function bdUI:get_fonts()
	local fonts = {}
	local shared_fonts = bdUI.shared:List("font")

	return shared_fonts
end


--========================================================
-- Frames Groups
-- automatically positions frames in given direction, and
-- returns dimensions of the "stack"
--========================================================
function bdUI:frame_group(container, direction, ...)
	direction = string.lower(direction) or "down"
	local last = nil
	local height = 0
	local width = 0
	local children = {...}

	-- first, do height, and hook vision
	for k, frame in pairs(children) do
		-- ignore frames that are hidden
		if (frame and type(frame) == "table" and frame:IsShown()) then
			if (direction == "upwards" or direction == "downwards") then
				width = frame:GetWidth() > width and frame:GetWidth() or width
				height = height + frame:GetHeight() + bdUI.border
			elseif (direction == "left" or direction == "right") then
				height = frame:GetHeight() > height and frame:GetHeight() or height
				width = width + frame:GetWidth() + bdUI.border
			end
		end

		if (not frame._hooked) then
			frame._hooked = true
			hooksecurefunc(frame, "Show", function()
				bdUI:frame_group(container, direction, unpack(children))
			end)
			hooksecurefunc(frame, "Hide", function()
				bdUI:frame_group(container, direction, unpack(children))
			end)
		end
	end

	container:SetSize(width, height)

	-- loop through frames provided in other parameters	
	for k, frame in pairs(children) do
		-- ignore frames that are hidden
		if (frame and type(frame) == "table" and frame:IsShown()) then
			-- frame #1 gets to be the "anchor" point
			if (not last) then
				frame:ClearAllPoints()
				if (direction == "downwards") then
					frame:SetPoint("TOP", container, "TOP")
				elseif (direction == "upwards") then
					frame:SetPoint("BOTTOM", container, "BOTTOM")
				elseif (direction == "right") then
					frame:SetPoint("RIGHT", container, "RIGHT")
				elseif (direction == "left") then
					frame:SetPoint("LEFT", container, "LEFT")
				end
			else
				-- everything else is positioned opposite
				frame:ClearAllPoints()
				if (direction == "downwards") then
					frame:SetPoint("TOP", last, "BOTTOM", 0, -bdUI.border)
				elseif (direction == "upwards") then
					frame:SetPoint("BOTTOM", last, "TOP", 0, bdUI.border)
				elseif (direction == "right") then
					frame:SetPoint("LEFT", last, "RIGHT", bdUI.border, 0)
				elseif (direction == "left") then
					frame:SetPoint("RIGHT", last, "LEFT", -bdUI.border, 0)
				end
			end

			last = frame
		end
	end

	-- returns max of one dimension, and total of other dimension, based on direction provided
	return container
end

--================================================
-- Media Functions
--================================================
	function bdUI:strip_textures(object, strip_text)
		if (not object) then return end
		for i = 1, object:GetNumRegions() do
			local region = select(i, object:GetRegions())

			if (not region.protected) then
				if region:GetObjectType() == "Texture" then
					region:SetTexture(nil)
					region:Hide()
					region:SetAlpha(0)
					region.Show = noop
				elseif (strip_text) then
					region:Hide()
					region:SetAlpha(0)
					region.Show = noop
				end
			end
		end	
	end

	function bdUI:set_backdrop_basic(frame)
		if (frame.background) then return end

		if (not frame.SetBackdrop) then
			Mixin(frame, BackdropTemplateMixin)
		end
		frame:SetBackdrop({bgFile = bdUI.media.flat, insets = {top = -bdUI.border, left = -bdUI.border, right = -bdUI.border, bottom = -bdUI.border}})
		frame:SetBackdropColor(unpack(bdUI.media.backdrop))
		frame:SetBackdropBorderColor(unpack(bdUI.media.border))

		frame.background = true

		bdUI:add_action("bdUI/border_size, loaded", function()
			local border = bdUI:get_border(frame)

			frame:SetBackdrop({bgFile = bdUI.media.flat, insets = {top = -bdUI.border, left = -bdUI.border, right = -bdUI.border, bottom = -bdUI.border}})
		end)
	end

	function bdUI:get_border_size()
		return bdUI:get_module("General"):get_save().border_size
	end

	function bdUI:get_border(frame)
		-- local general = 
		-- print(general.border_size)

		local screenheight = select(2, GetPhysicalScreenSize())
		local scale = 768 / screenheight
		local frame_scale = frame:GetEffectiveScale()
		local pixel = scale / frame_scale
		local border = pixel * bdUI:get_border_size()

		return border
	end

	local function border_gen(parent)
		local frame = parent:CreateTexture(nil, "BACKGROUND", nil, -5)
		frame:SetTexture(bdUI.media.flat)
		frame:SetVertexColor(unpack(bdUI.media.border))
		frame.protected = true

		return frame
	end

	function bdUI:set_backdrop(frame, force_border)
		if (frame._background) then return end

		local border = bdUI.border or bdUI:get_border(frame)
		if (force_border) then
			border = bdUI:get_border(frame)
		end
		local r, g, b, a = unpack(bdUI.media.backdrop)

		frame._background = frame:CreateTexture(nil, "BACKGROUND", nil, -6)
		frame._background:SetTexture(bdUI.media.flat)
		frame._background:SetAllPoints()
		frame._background:SetVertexColor(r, g, b, a)
		frame._background.protected = true

		frame.t = border_gen(frame)
		frame.l = border_gen(frame)
		frame.r = border_gen(frame)
		frame.b = border_gen(frame)

		frame._border = frame:CreateTexture(nil, "BACKGROUND")
		frame._border:Hide()
		frame._border.protected = true
		frame._border.SetAlpha = function(self, alpha)
			frame.t:SetAlpha(alpha)
			frame.b:SetAlpha(alpha)
			frame.l:SetAlpha(alpha)
			frame.r:SetAlpha(alpha)
		end
		frame._border.SetVertexColor = function(self, r, g, b, a)
			frame.t:SetVertexColor(r, g, b, a)
			frame.b:SetVertexColor(r, g, b, a)
			frame.l:SetVertexColor(r, g, b, a)
			frame.r:SetVertexColor(r, g, b, a)
		end

		frame.set_border_color = function(self, r, g, b, a)
			frame._border:SetVertexColor(r, g, b, a)
		end
		frame.reset_border_color = function(self, r, g, b, a)
			frame._border:SetVertexColor(unpack(bdUI.media.border))
		end
		frame.set_border_size = function(self, size)
			frame.t:SetHeight(size)
			frame.b:SetHeight(size)
			frame.l:SetWidth(size)
			frame.r:SetWidth(size)

			frame.t:SetPoint("BOTTOMLEFT", frame._background, "TOPLEFT", -size, 0)
			frame.t:SetPoint("BOTTOMRIGHT", frame._background, "TOPRIGHT", size, 0)

			frame.l:SetPoint("TOPRIGHT", frame._background, "TOPLEFT", 0, size)
			frame.l:SetPoint("BOTTOMRIGHT", frame._background, "BOTTOMLEFT", 0, -size)

			frame.r:SetPoint("TOPLEFT", frame._background, "TOPRIGHT", 0, size)
			frame.r:SetPoint("BOTTOMLEFT", frame._background, "BOTTOMRIGHT", 0, -size)
			
			frame.b:SetPoint("TOPLEFT", frame._background, "BOTTOMLEFT", -size, 0)
			frame.b:SetPoint("TOPRIGHT", frame._background, "BOTTOMRIGHT", size, 0)

			if (size == 0) then
				frame.t:Hide()
				frame.l:Hide()
				frame.r:Hide()
				frame.b:Hide()
			else
				frame.t:Show()
				frame.l:Show()
				frame.r:Show()
				frame.b:Show()
			end
		end 

		frame:set_border_size(border)

		bdUI:add_action("bdUI/border_size, loaded", function()
			local border = bdUI:get_border(frame)

			frame:set_border_size(border)
		end)
	end

	function bdUI:create_shadow(frame, offset)
		if frame._shadow then return end
		
		local shadow = CreateFrame("Frame", nil, frame, BackdropTemplateMixin and "BackdropTemplate")
		shadow:SetFrameLevel(1)
		shadow:SetFrameStrata(frame:GetFrameStrata())
		shadow:SetAlpha(0.7)
		shadow:SetBackdropColor(0, 0, 0, 0)
		shadow:SetBackdropBorderColor(0, 0, 0, 0.8)
		shadow.offset = offset

		shadow.SetColor = function(self, r, g, b, a)
			a = a or 1
			self:SetBackdropColor(r, g, b, a)
			self:SetBackdropBorderColor(r, g, b, a)
		end

		shadow.set_size = function(self, offset)
			shadow:SetPoint("TOPLEFT", -offset, offset)
			shadow:SetPoint("BOTTOMLEFT", -offset, -offset)
			shadow:SetPoint("TOPRIGHT", offset, offset)
			shadow:SetPoint("BOTTOMRIGHT", offset, -offset)

			shadow:SetBackdrop( { 
				edgeFile = bdUI.media.shadow, edgeSize = offset,
				insets = {left = offset, right = offset, top = offset, bottom = offset},
			})
		end

		shadow:set_size(offset)
		frame._shadow = shadow

		bdUI:add_action("bdUI/border_size, loaded", function()
			local border = bdUI:get_border(frame)

			shadow:set_size(border * shadow.offset)
		end)
	end

	function bdUI:set_highlight(frame, icon)
		if frame.SetHighlightTexture and not (frame.highlighter or frame.hover) then
			icon = icon or frame
			local highlight = frame:CreateTexture(nil, "HIGHLIGHT")
			local border = bdUI:get_border(frame)
			highlight:SetTexture(1, 1, 1, 0.1)
			highlight:SetPoint("TOPLEFT", icon, border, -border)
			highlight:SetPoint("BOTTOMRIGHT", icon, -border, border)

			frame.highlighter = highlight
			frame.hover = highlight
			frame:SetHighlightTexture(highlight)
		end
	end

	function bdUI:ColorGradient(perc, ...)
		if perc >= 1 then
			local r, g, b = select(select('#', ...) - 2, ...)
			return r, g, b
		elseif perc <= 0 then
			local r, g, b = ...
			return r, g, b
		end
		
		local num = select('#', ...) / 3

		local segment, relperc = math.modf(perc*(num-1))
		local r1, g1, b1, r2, g2, b2 = select((segment*3)+1, ...)

		return r1 + (r2-r1)*relperc, g1 + (g2-g1)*relperc, b1 + (b2-b1)*relperc
	end

	function RGBToHex(r, g, b)
		if (type(r) == "table") then
			g = r.g
			b = r.b
			r = r.r
		end
		if (not r and not g and not b) then
			r = 255
			g = 255
			b = 255
		end
		r = r <= 255 and r >= 0 and r or 0
		g = g <= 255 and g >= 0 and g or 0
		b = b <= 255 and b >= 0 and b or 0
		return string.format("%02x%02x%02x", r, g, b)
	end

	function RGBPercToHex(r, g, b)
		if (type(r) == "table") then
			g = r.g
			b = r.b
			r = r.r
		end
		r = r <= 1 and r >= 0 and r or 0
		g = g <= 1 and g >= 0 and g or 0
		b = b <= 1 and b >= 0 and b or 0
		return string.format("%02x%02x%02x", r*255, g*255, b*255)
	end

	GetQuadrant = GetQuadrant or function(frame)
		local x,y = frame:GetCenter()
		local hhalf = (x > UIParent:GetWidth()/2) and "RIGHT" or "LEFT"
		local vhalf = (y > UIParent:GetHeight()/2) and "TOP" or "BOTTOM"
		return vhalf..hhalf, vhalf, hhalf
	end

	-- lua doesn't have a good function for round
	function bdUI:round(num, idp)
		local mult = 10^(idp or 0)
		return floor(num * mult + 0.5) / mult
	end

	-- math clamp
	function math.clamp( _in, low, high )
		return math.min( math.max( _in, low ), high )
	end

	function math.restrict(_in, low, high)
		if (_in < low) then _in = low end
		if (_in > high) then _in = high end
		return _in
	end

	function bdUI:numberize(n)
		if n >= 10^6 then
			return string.format("%.1fm", n / 10^6)
		elseif n >= 10^3 then
			return string.format("%.0fk", n / 10^3)
		else
			return tostring(n)
		end

		-- if v <= 999 then return v end
		-- if v >= 1000000000 then
		-- 	local value = string.format("%.1fb", v/1000000000)
		-- 	return value
		-- elseif v >= 1000000 then
		-- 	local value = string.format("%.1fm", v/1000000)
		-- 	return value
		-- elseif v >= 1000 then
		-- 	local value = string.format("%.1fk", v/1000)
		-- 	return value
		-- end
	end

	-- Skin Button
	function bdUI:skin_button(f, small, color)
		local colors = bdUI.media.backdrop
		local hovercolors = bdUI.media.blue
		if (color == "red") then
			colors = {.6,.1,.1,0.6}
			hovercolors = {.6,.1,.1,1}
		elseif (color == "blue") then
			colors = bdUI.media.blue
			hovercolors = {0,0.55,.85,1}
		elseif (color == "dark") then
			colors = bdUI.media.backdrop
			hovercolors = {.1,.1,.1,1}
		end
		if (not f.SetBackdrop) then
			Mixin(f, BackdropTemplateMixin)
		end
		f:SetBackdrop({bgFile = bdUI.media.flat, edgeFile = bdUI.media.flat, edgeSize = 2, insets = {left=2,top=2,right=2,bottom=2}})
		f:SetBackdropColor(unpack(colors)) 
		f:SetBackdropBorderColor(unpack(bdUI.media.border))
		f:SetPushedTextOffset(0,-1)
		f:SetScale(1)
		
		f:SetWidth(f:GetTextWidth()+22)
		
		--if (f:GetWidth() < 24) then
		if (small and f:GetWidth() <= 24 ) then
			f:SetWidth(20)
		end

		bdUI:set_highlight(f)
		f.highlighter:SetTexture(bdUI.media.flat)
		f.highlighter:SetVertexColor(1, 1, 1)
		f.highlighter:SetAlpha(.1)
		
		if (small) then
			f:SetNormalFontObject("BDUI_SMALL")
			f:SetHighlightFontObject("BDUI_SMALL")
			f:SetHeight(18)
		else
			f:SetNormalFontObject("BDUI_MEDIUM")
			f:SetHighlightFontObject("BDUI_MEDIUM")
			f:SetHeight(28)
		end
		
		f:HookScript("OnEnter", function(f) 
			f:SetBackdropColor(unpack(hovercolors)) 
		end)
		f:HookScript("OnLeave", function(f) 
			f:SetBackdropColor(unpack(colors)) 
		end)
		
		return true
	end

--========================================================
-- Frames / Faders
--========================================================
	function IsMouseOverFrame(self)
		if not (SpellFlyout) then return false end
		if MouseIsOver(self) then return true end
		if not SpellFlyout:IsShown() then return false end
		if not SpellFlyout.__faderParent then return false end
		if SpellFlyout.__faderParent == self and MouseIsOver(SpellFlyout) then return true end

		return false
	end

	-- fade out animation, basically mirrors itself onto the given frame
	local function CreateFaderAnimation(frame)
		local animFrame = CreateFrame("Frame", nil, frame)
		frame.fader = animFrame:CreateAnimationGroup()
		frame.fader.__owner = frame
		frame.fader.__animFrame = animFrame
		frame.fader.anim = frame.fader:CreateAnimation("Alpha")
		frame.fader:HookScript("OnFinished", function(self)
			self.__owner:SetAlpha(self.finAlpha)
		end)
		frame.fader:HookScript("OnUpdate", function(self)
			self.__owner:SetAlpha(self.__animFrame:GetAlpha())
		end)
	end

	-- fade in animation
	local function StartFadeIn(frame)
		if (not frame.enableFader) then return end
		if (frame.fader.direction == "in") then return end
		frame.fader:Pause()
		frame.fader.anim:SetFromAlpha(frame.outAlpha)
		frame.fader.anim:SetToAlpha(frame.inAlpha)
		frame.fader.anim:SetDuration(frame.duration)
		frame.fader.anim:SetSmoothing("OUT")
		frame.fader.anim:SetStartDelay(frame.outDelay)
		frame.fader.finAlpha = frame.inAlpha
		frame.fader.direction = "in"
		frame.fader:Play()
	end

	-- fade out animation
	local function StartFadeOut(frame)
		if (not frame.enableFader) then return end
		if (frame.fader.direction == "out") then return end
		frame.fader:Pause()
		frame.fader.anim:SetFromAlpha(frame.inAlpha)
		frame.fader.anim:SetToAlpha(frame.outAlpha)
		frame.fader.anim:SetDuration(frame.duration)
		frame.fader.anim:SetSmoothing("OUT")
		frame.fader.anim:SetStartDelay(frame.outDelay)
		frame.fader.finAlpha = frame.outAlpha
		frame.fader.direction = "out"
		frame.fader:Play()
	end

	local function EnterLeaveHandle(self)
		if (self.__faderParent) then
			self = self.__faderParent
		end

		if IsMouseOverFrame(self) then
			StartFadeIn(self)
		else
			StartFadeOut(self)
		end
	end

	-- Allows us to mouseover show a frame, with animation
	function bdUI:create_fader(frame, children, inAlpha, outAlpha, duration, outDelay)
		if (frame.fader) then return end

		-- set variables
		frame.inAlpha = inAlpha or 1
		frame.outAlpha = outAlpha or 0
		frame.duration = duration or 0.2
		frame.outDelay = outDelay or 0
		frame.enableFader = true
		frame:SetAlpha(frame.outAlpha)

		-- Create Animation Frame
		CreateFaderAnimation(frame)

		-- Hook Events / Listeners
		frame:EnableMouse(true)
		frame:HookScript("OnEnter", EnterLeaveHandle)
		frame:HookScript("OnLeave", EnterLeaveHandle)

		-- Hook all animation into these events
		frame:HookScript("OnShow", StartFadeIn)
		frame:HookScript("OnHide", StartFadeOut)

		-- Hook Children
		for i, button in next, children do
			if not button.__faderParent then
				button.__faderParent = frame
				button:HookScript("OnEnter", EnterLeaveHandle)
				button:HookScript("OnLeave", EnterLeaveHandle)
			end
		end
	end