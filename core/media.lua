local bdUI, c, l = unpack(select(2, ...))

--================================================
-- Media Functions
--================================================
	function bdUI:set_backdrop_basic(frame)
		if (frame.background) then return end

		frame:SetBackdrop({bgFile = bdUI.media.flat, insets = {top = -bdUI.border, left = -bdUI.border, right = -bdUI.border, bottom = -bdUI.border}})
		frame:SetBackdropColor(unpack(bdUI.media.border))

		frame.background = true
	end

	function bdUI:set_backdrop(frame, resize, padding)
		if (frame.background) then return end
		padding = padding or 0
		local border = bdUI.border

		frame.background = frame:CreateTexture(nil, "BACKGROUND", nil, -7)
		frame.background:SetTexture(bdUI.media.flat)
		frame.background:SetPoint("TOPLEFT", frame, "TOPLEFT", -padding, padding)
		frame.background:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", padding, -padding)
		frame.background:SetVertexColor(unpack(bdUI.media.backdrop))
		frame.background.protected = true
		
		frame.border = frame:CreateTexture(nil, "BACKGROUND", nil, -8)
		frame.border:SetTexture(bdUI.media.flat)
		frame.border:SetPoint("TOPLEFT", frame, "TOPLEFT", -(padding + border), (padding + border))
		frame.border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", (padding + border), -(padding + border))
		frame.border:SetVertexColor(unpack(bdUI.media.border))
		frame.border.protected = true -- so this texture doesn't get stripped
	end

	function bdUI:set_highlight(frame, icon)
		if frame.SetHighlightTexture and not frame.highlighter then
			icon = icon or frame
			local highlight = frame:CreateTexture(nil, "HIGHLIGHT")
			highlight:SetTexture(1, 1, 1, 0.1)
			highlight:SetAllPoints(icon)

			frame.highlighter = highlight
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