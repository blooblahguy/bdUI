local MAJOR, MINOR = "bdFrames-1.0", 1
local bdFrames, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not bdFrames then return end
local mod = bdFrames

--====================================================
-- Defaults & Scaling
--====================================================
mod.group = nil

mod.dimensions = {
	header = 30,
	padding = 10
}
mod.media = {
	flat = "Interface\\Buttons\\WHITE8x8",
	arrow = "Interface\\Buttons\\Arrow-Down-Down.PNG",
	font = "fonts\\ARIALN.ttf",
	fontSize = 14,
	fontHeaderScale = 1.1,
	padding = 10,
	border = {0.06, 0.08, 0.09, 1},
	border_size = 2,
	background = {0.11, 0.15, 0.18, 1},
	red = {0.62, 0.17, 0.18, 1},
	blue = {0.2, 0.4, 0.8, 1},
	green = {0.1, 0.7, 0.3, 1},
}

mod.arrow = UIParent:CreateTexture(nil, "OVERLAY")
mod.arrow:SetTexture(mod.media.arrow)
mod.arrow:SetTexCoord(0.9, 0.9, 0.9, 0.6)
mod.arrow:SetVertexColor(1, 1, 1, 0.5)

-- main font object
mod.font = CreateFont("bdFrames_font")
mod.font:SetFont(mod.media.font, mod.media.fontSize)
mod.font:SetShadowColor(0, 0, 0)
mod.font:SetShadowOffset(1, -1)
mod.foundBetterFont = false

-- Use fonts from other addons if possible, can extend this
local function find_better_font()
	local fonts = {}
	fonts[0] = bdUI and bdUI.media.font
	fonts[1] = bdlc and bdlc.font

	-- for k, font in pairs(fonts) do
	-- 	if (font) then
	-- 		dump(font)
	-- 		mod.font:SetFont(font, mod.media.fontSize)
	-- 		return
	-- 	end
	-- end
end
mod.eventer = CreateFrame("frame", nil)
mod.eventer:RegisterEvent("ADDON_LOADED")
mod.eventer:SetScript("OnEvent", find_better_font)

-- Use effective scale to create perfect border
function mod:get_border(frame)
	local screenheight = select(2, GetPhysicalScreenSize())
	local scale = 768 / screenheight
	local frame_scale = frame:GetEffectiveScale()
	local pixel = scale / frame_scale
	local border = pixel * mod.media.border_size

	return border
end

--====================================================
-- No/Low Function Frames
--====================================================
-- wrapper container for layouts
function mod:create_container(options)

end

-- clear layout row
function mod:create_clear(options)
	options.parent._row = options.parent._row or 0
	options.parent._row = 1
end

-- create's a ghetto texture shadow
function mod:create_shadow(frame, size)
	if (frame.shadow) then return end

	frame.shadow = {}
	local start = 0.092
	for s = 1, size do
		local shadow = frame:CreateTexture(nil, "BACKGROUND")
		shadow:SetTexture(mod.media.flat)
		shadow:SetVertexColor(0,0,0,1)
		shadow:SetPoint("TOPLEFT", frame, "TOPLEFT", -s, s)
		shadow:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", s, -s)
		shadow:SetAlpha(start - ((s / size) * start))
		frame.shadow[s] = shadow
	end
end

-- Create 2px background frame
function mod:create_backdrop(frame)
	local border = mod:get_border(frame)

	if (not frame.bd_background) then
		frame.bd_background = frame:CreateTexture(nil, "BACKGROUND", -7)
		frame.bd_background:SetTexture(mod.media.flat)
		frame.bd_background:SetVertexColor(unpack(mod.media.background))
		frame.bd_background:SetAllPoints()
		frame.bd_background.protected = true
		
		frame.bd_border = frame:CreateTexture(nil, "BACKGROUND", -8)
		frame.bd_border:SetTexture(mod.media.flat)
		frame.bd_border:SetVertexColor(unpack(mod.media.border))
		frame.bd_border.protected = true
	end

	frame.bd_border:SetPoint("TOPLEFT", frame, "TOPLEFT", -border, border)
	frame.bd_border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", border, -border)
end

--====================================================
-- Layout
--====================================================
-- Build container with widths/floats
function mod:position_element(options)
	local parent = mod.current_group

	local padding = mod.dimensions.padding
	local sizes = {
		half = 0.5,
		third = 0.33,
		twothird = 0.66,
		full = 1
	}

	-- track row width
	size = sizes[options.size or "full"]
	parent._row = parent._row or 0
	parent._row = parent._row + size
	parent._elements = parent._elements or {}

	local container = CreateFrame("frame", nil, parent)
	container:SetSize((parent:GetWidth() * size) - padding, 30)

	-- TESTING : shows a background around each container for debugging
	container:SetBackdrop({bgFile = mod.media.flat})
	container:SetBackdropColor(.1, .8, .2, 0.1)	

	if (parent._row > 1 or not parent._lastel) then
		-- new or first row
		parent._row = size
		container._isrow = true

		if (not parent._rowel) then
			-- first element
			container:SetPoint("TOPLEFT", parent, "TOPLEFT", padding, -padding)
			parent._rowel = container
		else
			-- new row
			container:SetPoint("TOPLEFT", parent._rowel, "BOTTOMLEFT", 0, -padding)
			parent._rowel = container
		end
	else
		-- same row
		container:SetPoint("BOTTOMLEFT", parent._lastel, "BOTTOMRIGHT", mod.padding, 0)
	end

	table.insert(parent._elements, container)
	parent._lastel = container

	return container
end

--====================================================
-- Functioning Objects
--====================================================
-- creates basic button template
function bdFrames:create_button(parent)
	local media = mod.media
	local border = media.border_size

	local button = CreateFrame("Button", nil, parent)

	button.inactiveColor = media.blue
	button.activeColor = media.blue
	button:SetBackdrop({bgFile = media.flat})

	function button:BackdropColor(r, g, b, a)
		button.inactiveColor = button.inactiveColor or media.blue
		button.activeColor = button.activeColor or media.blue

		if (r and b and g) then
			button:SetBackdropColorOld(r, g, b, a)
		end
	end

	button.SetBackdropColorOld = button.SetBackdropColor
	button.SetBackdropColor = button.BackdropColor
	button.SetVertexColor = button.BackdropColor

	button:SetBackdropColor(unpack(media.blue))
	button:SetAlpha(0.6)
	button:SetHeight(30)
	button:EnableMouse(true)

	button.text = button:CreateFontString(nil, "OVERLAY", "bdFrames_font")
	button.text:SetPoint("CENTER")
	button.text:SetJustifyH("CENTER")
	button.text:SetJustifyV("MIDDLE")

	function button:Select()
		button.SetVertexColor(unpack(button.activeColor))
	end
	function button:Deselect()
		button.SetVertexColor(unpack(button.inactiveColor))
	end
	function button:OnEnter()
		if (button.active) then
			button:SetBackdropColor(unpack(button.activeColor))
		else
			if (button.hoverColor) then
				button:SetBackdropColor(unpack(button.hoverColor))
			else
				button:SetBackdropColor(unpack(button.inactiveColor))
			end
		end
		button:SetAlpha(1)
	end

	function button:OnLeave()
		if (button.active) then
			button:SetBackdropColor(unpack(button.activeColor))
			button:SetAlpha(1)
		else
			button:SetBackdropColor(unpack(button.inactiveColor))
			button:SetAlpha(0.6)
		end
	end
	function button:OnClickDefault()
		if (button.OnClick) then button.OnClick(button) end
		if (button.autoToggle) then
			if (button.active) then
				button.active = false
			else
				button.active = true
			end
		end

		button:OnLeave()
	end
	function button:GetText()
		return button.text:GetText()
	end
	function button:SetText(text)
		button.text:SetText(text)
		button:SetWidth(button.text:GetStringWidth() + 30)
	end

	button:SetScript("OnEnter", button.OnEnter)
	button:SetScript("OnLeave", button.OnLeave)
	button:SetScript("OnClick", button.OnClickDefault)

	return button
end

function mod:create_heading(options)
	local heading = options.parent:CreateFontString(nil, "OVERLAY", "bdFrames_font")
	heading:SetText(options.value)
	heading:SetAlpha(1)
	heading:SetScale(1.1)
	heading:SetJustifyH("LEFT")
	heading:SetJustifyV("TOP")
	heading:SetPoint("BOTTOMLEFT", options.parent, "TOPLEFT", 4, 4)

end
function mod:create_description(options)
	local description = container:CreateFontString(nil, "OVERLAY", "bdFrames_font")

	description:SetText(options.value)
	description:SetAlpha(0.8)
	description:SetJustifyH("LEFT")
	description:SetJustifyV("TOP")
	description:SetAllPoints(container)

	local lines = math.ceil(text:GetStringWidth() / (container:GetWidth() - 4))

	container:SetHeight( (lines * 14) + 10)

	return description
end
function mod:create_input(options)

end
function mod:create_range(options)

end
function mod:create_color(options)

end

-- Toggle
function mod:create_toggle(options)
	options.size = options.size or "half"
	local container = mod:position_element(options)
	container:SetHeight(30)

	local check = CreateFrame("CheckButton", options.name, container, "ChatConfigCheckButtonTemplate")
	local text = _G[check:GetName().."Text"]
	check:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
	text:SetText(options.label)
	text:SetFontObject("bdFrames_font")
	text:ClearAllPoints()
	text:SetPoint("LEFT", check, "RIGHT", 2, 1)

	return container
end
function mod:create_select(options)

end
function mod:create_multiselect(options)

end