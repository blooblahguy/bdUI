mod.dimensions = {
	left_column = 150,
	right_column = 600,
	height = 450,
	header = 30,
	padding = 10,
}

--=================================================================
-- BUILD CONFIGURATION WINDOWS
--=================================================================
function mod:create_windows(name, lock_toggle)
	local dimensions = mod.dimensions
	local media = bdFrames.media
	local border = bdFrames:get_border(UIParent)

	-- Parent
	local window = CreateFrame("Frame", "bdConfig Lib", UIParent)
	window:SetPoint("RIGHT", UIParent, "RIGHT", -20, 0)
	window:SetSize(dimensions.left_column + dimensions.right_column, dimensions.height + dimensions.header)
	window:SetMovable(true)
	window:SetUserPlaced(true)
	window:SetFrameStrata("DIALOG")
	window:SetClampedToScreen(true)
	window:Hide()

	-- Header
	window.header = CreateFrame("frame", nil, window)
	window.header:SetPoint("TOPLEFT")
	window.header:SetPoint("TOPRIGHT")
	window.header:SetHeight(dimensions.header)
	window.header:RegisterForDrag("LeftButton")
	window.header:EnableMouse(true)
	window.header:SetScript("OnDragStart", function(self) window:StartMoving() end)
	window.header:SetScript("OnDragStop", function(self) window:StopMovingOrSizing() end)
	bdFrames:create_backdrop(window.header)

	window.header.text = window.header:CreateFontString(nil, "OVERLAY", "bdFrames_font")
	window.header.text:SetPoint("LEFT", 10, 0)
	window.header.text:SetJustifyH("LEFT")
	window.header.text:SetText(name.." Configuration")
	window.header.text:SetJustifyV("MIDDLE")

	window.header.close = bdFrames:create_button(window.header)
	window.header.close:SetPoint("TOPRIGHT", window.header)
	window.header.close:SetText("x")
	window.header.close.inactiveColor = media.red
	window.header.close:OnLeave()
	window.header.close.OnClick = function()
		window:Hide()
	end

	window.header.reload = bdFrames:create_button(window.header)
	window.header.reload:SetPoint("TOPRIGHT", window.header.close, "TOPLEFT", -border, 0)
	window.header.reload:SetText("Reload UI")
	window.header.reload.inactiveColor = media.green
	window.header.reload:OnLeave()
	window.header.reload.OnClick = function()
		ReloadUI();
	end

	window.header.lock = bdFrames:create_button(window.header)
	window.header.lock:SetPoint("TOPRIGHT", window.header.reload, "TOPLEFT", -border, 0)
	window.header.lock:SetText("Unlock")
	window.header.lock.autoToggle = true
	window.header.lock.OnClick = function(self)
		lock_toggle()
		if (self:GetText() == "Lock") then
			self:SetText("Unlock")
		else
			self:SetText("Lock")
		end
	end

	-- Left Column
	window.left = CreateFrame( "Frame", nil, window)
	window.left:SetPoint("TOPLEFT", window, "TOPLEFT", 0, -dimensions.header - border)
	window.left:SetSize(dimensions.left_column, dimensions.height)
	bdFrames:create_backdrop(window.left)

	-- Right Column
	window.right = CreateFrame( "Frame", nil, window)
	window.right:SetPoint("TOPRIGHT", window, "TOPRIGHT", 0, -dimensions.header - border)
	window.right:SetSize(dimensions.right_column - border, dimensions.height)
	bdFrames:create_backdrop(window.right)
	window.right.bd_background:SetVertexColor(unpack(media.border))

	return window
end

-- Add single module
function mod:create_module(instance, name)
	local dimensions = mod.dimensions
	local media = bdFrames.media
	local border = bdFrames:get_border(UIParent)

	local module = bdFrames:create_scrollframe(instance._window.right)
	module.name = name
	module.tabs = {}
	module:Hide()
	bdFrames.group = module

	module:SetBackdrop({bgFile = bdFrames.media.flat})
	module:SetBackdropColor(.1, .8, .2, 0.1)	

	instance._modules[name] = module
	instance._default = instance._default or module

	-- module methods
	function module:select()
		if (module.active) then return end

		for name, otherModule in pairs(instance._modules) do
			otherModule:unselect()
		end

		instance._default = module
		module:Show()
		module.active = true
		module.link.active = true
		module.link:OnLeave()
	end
	function module:unselect()
		if (not module.active) then return end
		module:Hide()
		module.active = false
		module.link.active = false
		module.link:OnLeave()
	end

	-- Create Sidebar Link
	local link = bdFrames:create_button(instance._window.left)
	link.inactiveColor = {0, 0, 0, 0}
	link.hoverColor = {1, 1, 1, .2}
	link:OnLeave()
	link.OnClick = module.select
	link:SetText(name)
	link:SetWidth(dimensions.left_column)
	link.text:SetPoint("LEFT", link, "LEFT", 6, 0)
	if (not instance._lastLink) then
		link:SetPoint("TOPLEFT", instance._window.left, "TOPLEFT")
	else
		link:SetPoint("TOPLEFT", instance._lastLink, "BOTTOMLEFT")
	end
	instance._lastLink = link
	module.link = link

	return module
end