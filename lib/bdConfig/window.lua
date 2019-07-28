local addonName, ns = ...
local mod = ns.bdConfig

--=================================================================
-- BUILD CONFIGURATION WINDOWS
--=================================================================
function mod:create_windows(name, lock_toggle)
	local dimensions = mod.dimensions
	local media = mod.media
	local border = mod:get_border(UIParent)

	-- main font object
	mod.font = CreateFont("bdConfig_font")
	mod.font:SetFont(mod.media.font, mod.media.fontSize)
	mod.font:SetShadowColor(0, 0, 0)
	mod.font:SetShadowOffset(1, -1)
	mod.foundBetterFont = false

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
	mod:create_backdrop(window.header)

	window.header.text = window.header:CreateFontString(nil, "OVERLAY", "bdConfig_font")
	window.header.text:SetPoint("LEFT", 10, 0)
	window.header.text:SetJustifyH("LEFT")
	window.header.text:SetText(name.." Configuration")
	window.header.text:SetJustifyV("MIDDLE")

	window.header.close = mod.elements['button']({}, window.header)
	window.header.close:SetPoint("TOPRIGHT", window.header)
	window.header.close:SetText("x")
	window.header.close.inactiveColor = media.red
	window.header.close:OnLeave()
	window.header.close.OnClick = function()
		window:Hide()
	end

	window.header.reload = mod.elements['button']({}, window.header)
	window.header.reload:SetPoint("TOPRIGHT", window.header.close, "TOPLEFT", -border, 0)
	window.header.reload:SetText("Reload UI")
	window.header.reload.inactiveColor = media.green
	window.header.reload:OnLeave()
	window.header.reload.OnClick = function()
		ReloadUI();
	end

	window.header.lock = mod.elements['button']({}, window.header)
	window.header.lock:SetPoint("TOPRIGHT", window.header.reload, "TOPLEFT", -border, 0)
	window.header.lock:SetText("Unlock")
	window.header.lock.autoToggle = true
	window.header.lock.OnClick = function(self)
		lock_toggle()
		if (self:GetText() == "Lock") then
			self:SetText("Unlock")
			window.left:Show()
			window.right:Show()
			window:SetWidth(dimensions.left_column + dimensions.right_column)
		else
			self:SetText("Lock")
			window.left:Hide()
			window.right:Hide()
			window:SetWidth(350)
		end
	end

	-- Left Column
	window.left = CreateFrame( "Frame", nil, window)
	window.left:SetPoint("TOPLEFT", window, "TOPLEFT", 0, -dimensions.header - border)
	window.left:SetSize(dimensions.left_column, dimensions.height)
	mod:create_backdrop(window.left)

	-- Right Column
	window.right = CreateFrame( "Frame", nil, window)
	window.right:SetPoint("TOPRIGHT", window, "TOPRIGHT", 0, -dimensions.header - border)
	window.right:SetSize(dimensions.right_column - border, dimensions.height)
	mod:create_backdrop(window.right)

	return window
end

-- Add single module
function mod:create_module(instance, name)
	local dimensions = mod.dimensions
	local media = mod.media
	local border = mod:get_border(UIParent)

	local module = mod:create_scrollframe(instance._window.right)
	module.name = name
	module.tabs = {}
	module:Hide()
	module.scrollParent:Hide()
	mod.group = module

	-- module:SetBackdrop({bgFile = mod.media.flat})
	-- module:SetBackdropColor(.1, .1, .9, 0.1)	

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
		module.scrollParent:Show()
		module.active = true
		module.link.active = true
		module.link:OnLeave()
		module:update_scroll()
	end
	function module:unselect()
		if (not module.active) then return end
		module:Hide()
		module.scrollParent:Hide()
		module.active = false
		module.link.active = false
		module.link:OnLeave()
	end

	-- Create Sidebar Link
	local link = mod.elements['button']({}, instance._window.left)
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