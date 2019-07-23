local bdUI, c, l = unpack(select(2, ...))

--================================================
-- Media Functions
--================================================
	function bdUI:strip_textures(object, strip_text)
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

		frame:SetBackdrop({bgFile = bdUI.media.flat, insets = {top = -bdUI.border, left = -bdUI.border, right = -bdUI.border, bottom = -bdUI.border}})
		frame:SetBackdropColor(unpack(bdUI.media.border))

		frame.background = true
	end

	function bdUI:get_border(frame)
		local screenheight = select(2, GetPhysicalScreenSize())
		local scale = 768 / screenheight
		local frame_scale = frame:GetEffectiveScale()
		local pixel = scale / frame_scale
		local border = pixel * 2

		return border
	end

	function bdUI:set_backdrop(frame, alpha)
		local border = bdUI:get_border(frame)
		alpha = alpha or 0.9
		local r, g, b, a = unpack(bdUI.media.backdrop)

		if (not frame.bd_background) then
			frame.bd_background = frame:CreateTexture(nil, "BACKGROUND", nil, -7)
			frame.bd_background:SetTexture(bdUI.media.flat)
			frame.bd_background:SetAllPoints()
			frame.bd_background:SetVertexColor(r, g, b, alpha)
			frame.bd_background.protected = true

			frame.t = frame:CreateTexture(nil, "BACKGROUND", nil, -8)
			frame.t:SetTexture(bdUI.media.flat)
			frame.t:SetVertexColor(unpack(bdUI.media.border))
			frame.t:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", -border, 0)
			frame.t:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", border, 0)

			frame.l = frame:CreateTexture(nil, "BACKGROUND", nil, -8)
			frame.l:SetTexture(bdUI.media.flat)
			frame.l:SetVertexColor(unpack(bdUI.media.border))
			frame.l:SetPoint("TOPRIGHT", frame, "TOPLEFT", 0, border)
			frame.l:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", 0, -border)

			frame.r = frame:CreateTexture(nil, "BACKGROUND", nil, -8)
			frame.r:SetTexture(bdUI.media.flat)
			frame.r:SetVertexColor(unpack(bdUI.media.border))
			frame.r:SetPoint("TOPLEFT", frame, "TOPRIGHT", 0, border)
			frame.r:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 0, -border)

			frame.b = frame:CreateTexture(nil, "BACKGROUND", nil, -8)
			frame.b:SetTexture(bdUI.media.flat)
			frame.b:SetVertexColor(unpack(bdUI.media.border))
			frame.b:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", -border, 0)
			frame.b:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", border, 0)

			frame.border = frame:CreateTexture(nil, "BACKGROUND")
			frame.border:Hide()
			frame.border.SetVertexColor = function(self, r, g, b, a)
				frame.t:SetVertexColor(r, g, b, a)
				frame.b:SetVertexColor(r, g, b, a)
				frame.l:SetVertexColor(r, g, b, a)
				frame.r:SetVertexColor(r, g, b, a)
			end
		end

		frame.t:SetHeight(border)
		frame.b:SetHeight(border)
		frame.l:SetWidth(border)
		frame.r:SetWidth(border)
	end

	function bdUI:create_shadow(frame, offset)
		if f._shadow then return end
		
		local shadow = CreateFrame("Frame", nil, frame)
		shadow:SetFrameLevel(1)
		shadow:SetFrameStrata(frame:GetFrameStrata())
		shadow:SetPoint("TOPLEFT", -offset, offset)
		shadow:SetPoint("BOTTOMLEFT", -offset, -offset)
		shadow:SetPoint("TOPRIGHT", offset, offset)
		shadow:SetPoint("BOTTOMRIGHT", offset, -offset)
		shadow:SetAlpha(0.7)
		
		shadow:SetBackdrop( { 
			edgeFile = bdUI.media.shadow, edgeSize = offset,
			insets = {left = offset, right = offset, top = offset, bottom = offset},
		})
		
		shadow:SetBackdropColor(0, 0, 0, 0)
		shadow:SetBackdropBorderColor(0, 0, 0, 0.8)
		frame._shadow = shadow
	end

	function bdUI:set_highlight(frame, icon)
		if frame.SetHighlightTexture and not frame.highlighter then
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

	RGBToHex = RGBToHex or function(r, g, b)
		r = r <= 255 and r >= 0 and r or 0
		g = g <= 255 and g >= 0 and g or 0
		b = b <= 255 and b >= 0 and b or 0
		return string.format("%02x%02x%02x", r, g, b)
	end

	RGBPercToHex = RGBPercToHex or function(r, g, b)
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

	function bdUI:numberize(v)
		if v <= 9999 then return v end
		if v >= 1000000000 then
			local value = string.format("%.1fb", v/1000000000)
			return value
		elseif v >= 1000000 then
			local value = string.format("%.1fm", v/1000000)
			return value
		elseif v >= 10000 then
			local value = string.format("%.1fk", v/1000)
			return value
		end
	end

	-- Skin Button
	function bdUI:skin_button(f,small,color)
		local colors = bdUI.media.backdrop
		local hovercolors = {0,0.55,.85,1}
		if (color == "red") then
			colors = {.6,.1,.1,0.6}
			hovercolors = {.6,.1,.1,1}
		elseif (color == "blue") then
			colors = {0,0.55,.85,0.6}
			hovercolors = {0,0.55,.85,1}
		elseif (color == "dark") then
			colors = bdUI.media.backdrop
			hovercolors = {.1,.1,.1,1}
		end
		f:SetBackdrop({bgFile = bdUI.media.flat, edgeFile = bdUI.media.flat, edgeSize = 2, insets = {left=2,top=2,right=2,bottom=2}})
		f:SetBackdropColor(unpack(colors)) 
		f:SetBackdropBorderColor(unpack(bdUI.media.border))
		f:SetNormalFontObject("BDUI_SMALL")
		f:SetHighlightFontObject("BDUI_SMALL")
		f:SetPushedTextOffset(0,-1)
		f:SetScale(1)
		
		f:SetWidth(f:GetTextWidth()+22)
		
		--if (f:GetWidth() < 24) then
		if (small and f:GetWidth() <= 24 ) then
			f:SetWidth(20)
		end
		
		if (small) then
			f:SetHeight(18)
		else
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

	-- Allows us to track is mouse is over SpellFlyout child
	local function spell_flyout_hook(self)
		local topParent = self:GetParent():GetParent():GetParent()
		if (not topParent.__fader) then return end

		-- toplevel
		if (not self.__faderParent) then
			self.__faderParent = topParent
			self:HookScript("OnEnter", EnterLeaveHandle)
			self:HookScript("OnLeave", EnterLeaveHandle)
		end

		-- children
		for i=1, NUM_ACTIONBAR_BUTTONS do
			local button = _G["SpellFlyoutButton"..i]
			if not button then break end

			if not button.__faderParent then
				button.__faderParent = topParent
				button:HookScript("OnEnter", EnterLeaveHandle)
				button:HookScript("OnLeave", EnterLeaveHandle)
			end
		end
	end
	SpellFlyout:HookScript("OnShow", spell_flyout_hook)