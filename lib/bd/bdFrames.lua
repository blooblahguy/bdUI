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
	check:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
	local text = _G[check:GetName().."Text"]
	text:SetText(options.label)
	text:SetFontObject("bdFrames_font")
	text:ClearAllPoints()
	text:SetPoint("LEFT", check, "RIGHT", 2, 1)
	check.tooltip = options.tooltip;
	-- check:SetChecked(module.save[option])

	-- check:SetScript("OnClick", function(self)
	-- 	module.save[option] = self:GetChecked()

	-- 	info:callback(check)
	-- end)

	return container
end
function mod:create_select(options)

end
function mod:create_multiselect(options)

end

--====================================================
-- High Complexity Objects
--====================================================
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
	bdFrames:create_backdrop(scrollbar)
	parent.scrollbar = scrollbar

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
		scrollbar:SetValue(scrollbar:GetValue() - (delta*20))
	end
	scrollbar:SetScript("OnMouseWheel", scroll)
	scrollParent:SetScript("OnMouseWheel", scroll)
	content:SetScript("OnMouseWheel", scroll)

	-- store
	parent.scrollParent = scrollParent
	parent.scrollbar = scrollbar
	parent.content = content

	content.scrollParent = scrollParent
	content.scrollbar = scrollbar
	content.parent = parent

	return content
end

--===========================================
-- TABS
--===========================================
local mod.last_tab = nil
function mod:end_tab(options)
	if (not mod.last_tab) then return end

end


function mod:create_tab(options)

	-- create tab container
	if (not group.tabContainer) then
		local tabContainer = CreateFrame("frame", nil, group)
		tabContainer:SetPoint("BOTTOMLEFT", group, "TOPLEFT")
		tabContainer:SetPoint("BOTTOMRIGHT", group, "TOPRIGHT")
		tabContainer:SetHeight(mod.dimensions.header)

		group.tabContainer = tabContainer
		group.tabs = {}
	end
	
	mod:end_tab()

	local group = mod:create_group(options)
	mod.last_tab = group

	-- create tab to link to this page
	local index = #group.tabs + 1
	local tab = bdFrames:create_button(group.tabContainer)
	tab.inactiveColor = {1,1,1,0}
	tab.hoverColor = {1,1,1,0.1}
	tab:OnLeave()
	tab:SetText(options.value)
	tab.page = group
	tab.page:Hide()

	-- show page on select
	function tab:select()
		tab.page:Show()

		tab.active = true
		tab.page.active = true
		tab:OnLeave()
		group.activePage = page
	end

	-- hide page on tab unselect
	function tab:unselect()
		tab.page:Hide()
		tab.active = false
		tab.page.active = false
		tab:OnLeave()

		group.activePage = false
	end

	-- unselect / hide other tabs
	tab.OnClick = function()
		for i, t in pairs(group.tabs) do
			t:unselect()
		end
		tab:select()
	end

	-- position
	if (index == 1) then
		tab:SetPoint("LEFT", group.tabContainer, "LEFT", 0, 0)
	else
		tab:SetPoint("LEFT", group.tabs[index - 1], "RIGHT", 1, 0)
	end

	group.tabs[index] = tab
end

--===========================================
-- GROUPS
--===========================================
mod.groups = {}
mod.first_group = nil
mod.last_group = nil
mod.current_group = nil

function mod:end_group(options)
	mod.last_group = mod.groups[#mod.groups]
	if (mod.last_group) then
		-- set group height
		mod.last_group:update()
		table.remove(mod.groups, #mod.groups)
	end

	mod.current_group = nil
end

function mod:position_group(options)
	local parent = mod.current_group or mod.last_group or options.parent

	local group = CreateFrame("frame", nil, parent)
	local space = mod.dimensions.padding
	if (options.heading) then space = space + 20 end
	if (options.type == "tab") then space = space + 30 end
	if (not mod.last_group) then
		group:SetSize(parent:GetWidth() - (mod.dimensions.padding * 2), 30)
		group:SetPoint("TOPLEFT", parent, "TOPLEFT", mod.dimensions.padding, -space)
	else
		group:SetSize(parent:GetWidth(), 30)
		group:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 0, -space)
	end

	--====================================
	-- Functions
	--====================================
	-- Recursively Get Group Height
	function group:calculate_height()
		local height = 0

		if (not self._elements) then return end -- not a layout child

		for row, element in pairs(self._elements) do
			if (element._isrow) then
				height = height + element:GetHeight() + mod.dimensions.padding
			end
		end

		return height + mod.dimensions.padding
	end

	-- update when children change
	function group:update()
		local height = self:calculate_height() or 0
		group:SetHeight(height)
	end

	return group
end

function mod:create_group(options)
	local group = mod:position_group(options)
	mod.current_group = group
	mod:create_backdrop(group)
	table.insert(mod.groups, group)

	if (options.heading) then
		mod:create_heading({
			parent = group,
			value = options.heading
		})
	end

	return group
end
