local addonName, ns = ...
ns.bdConfig = {}
local mod = ns.bdConfig
mod.callback = LibStub("CallbackHandler-1.0"):New(mod, "Register", "Unregister", "UnregisterAll")

-- Developer functions
function mod:noop() return end
function mod:debug(...) print("|cffA02C2FbdConfig|r:", ...) end
function mod:round(num, idp) local mult = 10^(idp or 0) return floor(num * mult + 0.5) / mult end

mod.dimensions = {
	left_column = 150,
	right_column = 600,
	height = 450,
	header = 30,
	padding = 10,
}

mod.media = {
	flat = "Interface\\Buttons\\WHITE8x8",
	arrow = "Interface\\Buttons\\Arrow-Down-Down.PNG",
	font = "fonts\\ARIALN.ttf",
	fontSize = 14,
	fontHeaderScale = 1.1,
	padding = 10,
	border_size = 2,
	background = {0.06, 0.07, 0.09},
	border = {0.03, 0.04, 0.06, 1},
	red = {0.62, 0.17, 0.18, 1},
	blue = {0.2, 0.4, 0.8, 1},
	green = {0.1, 0.7, 0.3, 1},
}
mod.media.primary = mod.media.blue

mod.arrow = UIParent:CreateTexture(nil, "OVERLAY")
mod.arrow:SetTexture(mod.media.arrow)
mod.arrow:SetTexCoord(0.9, 0.9, 0.9, 0.6)
mod.arrow:SetVertexColor(1, 1, 1, 0.5)

-- main font object
mod.font = CreateFont("bdConfig_font")
mod.font:SetFont(mod.media.font, mod.media.fontSize)
mod.font:SetShadowColor(0, 0, 0)
mod.font:SetShadowOffset(1, -1)
mod.foundBetterFont = false

--===========================================
-- MEDIA FUNCTIONS
--===========================================
-- Use effective scale to create perfect border
function mod:get_border(frame)
	local screenheight = select(2, GetPhysicalScreenSize())
	local scale = 768 / screenheight
	local frame_scale = frame:GetEffectiveScale()
	local pixel = scale / frame_scale
	local border = pixel * mod.media.border_size

	return border
end

-- Create 2px background frame
function mod:create_backdrop(frame, alpha)
	local border = mod:get_border(frame)
	alpha = alpha or 0.97
	if (frame.bd_background) then return end

	local r, g, b, a = unpack(mod.media.background)

	frame.bd_background = CreateFrame("frame", nil, frame)
	frame.bd_background:SetFrameStrata("BACKGROUND")
	frame.bd_background:SetFrameLevel(0)
	frame.bd_background:SetBackdrop({bgFile = mod.media.flat, edgeFile = mod.media.flat, edgeSize = border})
	frame.bd_background:SetBackdropColor(r, g, b, alpha)
	frame.bd_background:SetBackdropBorderColor(unpack(mod.media.border))
	frame.bd_background:SetPoint("TOPLEFT", frame, "TOPLEFT", -border, border)
	frame.bd_background:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", border, -border)
end

-- scrollframe
function mod:create_scrollframe(parent)
	local padding = mod.dimensions.padding

	width = width or parent:GetWidth()
	height = height or parent:GetHeight()

	-- scrollframe
	local scrollParent = CreateFrame("ScrollFrame", nil, parent) 
	scrollParent:SetPoint("TOPLEFT", parent) 
	scrollParent:SetSize(width - padding, height)

	--scrollbar 
	local scrollbar = CreateFrame("Slider", nil, scrollParent, "UIPanelScrollBarTemplate") 
	scrollbar:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -2, -18) 
	scrollbar:SetPoint("BOTTOMLEFT", parent, "BOTTOMRIGHT", -18, 18) 
	scrollbar:SetMinMaxValues(1, 600)
	scrollbar:SetValueStep(1)
	scrollbar.scrollStep = 1
	scrollbar:SetValue(0)
	scrollbar:SetWidth(16)

	--content frame 
	local content = CreateFrame("Frame", nil, scrollParent) 
	content:SetPoint("TOPLEFT", parent, "TOPLEFT") 
	content:SetSize(scrollParent:GetWidth() - (padding * 2), scrollParent:GetHeight())
	scrollParent.content = content
	scrollParent:SetScrollChild(content)

	-- scripts
	scrollbar:SetScript("OnValueChanged", function (self, value) 
		self:GetParent():SetVerticalScroll(value) 
	end)

	-- scroller
	local function scroll(self, delta)
		scrollbar:SetValue(scrollbar:GetValue() - (delta*30))
	end
	scrollbar:SetScript("OnMouseWheel", scroll)
	scrollParent:SetScript("OnMouseWheel", scroll)
	content:SetScript("OnMouseWheel", scroll)

	content.scrollParent = scrollParent
	content.scrollbar = scrollbar
	content.parent = parent

	return content
end