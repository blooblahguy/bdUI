local parent, ns = ...
local lib = ns.bdConfig

--=================================================================
-- BUILD CONFIGURATION WINDOWS
--=================================================================
function lib:create_windows(name, lock_toggle)
	local dimensions = lib.dimensions
	local media = lib.media
	local border = lib:get_border(UIParent)

	-- main font object
	lib.font = CreateFont("bdConfig_font")
	lib.font:SetFont(lib.media.font, lib.media.fontSize)
	lib.font:SetShadowColor(0, 0, 0)
	lib.font:SetShadowOffset(1, -1)
	lib.foundBetterFont = false

	-- Parent
	local window = CreateFrame("Frame", "bdConfig Lib", UIParent)
	window:SetPoint("RIGHT", UIParent, "RIGHT", -20, 0)
	window:SetSize(dimensions.left_column + dimensions.right_column, dimensions.height + dimensions.header)
	window:SetMovable(true)
	window:SetUserPlaced(true)
	window:SetFrameStrata("TOOLTIP")
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
	lib:create_backdrop(window.header)

	window.header.text = window.header:CreateFontString(nil, "OVERLAY", "bdConfig_font")
	window.header.text:SetPoint("LEFT", 10, 0)
	window.header.text:SetJustifyH("LEFT")
	window.header.text:SetText(name.." Configuration")
	window.header.text:SetJustifyV("MIDDLE")

	window.header.close = lib.elements['button']({solo = true}, window.header)
	window.header.close:SetPoint("TOPRIGHT", window.header)
	window.header.close:SetText("x")
	window.header.close.inactiveColor = media.red
	window.header.close:OnLeave()
	window.header.close.OnClick = function()
		window:Hide()
	end

	window.header.reload = lib.elements['button']({solo = true}, window.header)
	window.header.reload:SetPoint("TOPRIGHT", window.header.close, "TOPLEFT", -border, 0)
	window.header.reload:SetText("Reload UI")
	window.header.reload.inactiveColor = media.green
	window.header.reload:OnLeave()
	window.header.reload.OnClick = function()
		ReloadUI();
	end

	window.header.lock = lib.elements['button']({solo = true}, window.header)
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
	lib:create_backdrop(window.left)

	-- Right Column
	window.right = CreateFrame( "Frame", nil, window)
	window.right:SetPoint("TOPRIGHT", window, "TOPRIGHT", 0, -dimensions.header - border)
	window.right:SetSize(dimensions.right_column - border, dimensions.height)
	lib:create_backdrop(window.right)

	return window
end

-- Add single module
function lib:create_module(instance, name)
	local dimensions = lib.dimensions
	local media = lib.media
	local border = lib:get_border(UIParent)

	local module = lib:create_scrollframe(instance.right)
	module.name = name
	module.tabs = {}
	module:Hide()
	module.scrollParent:Hide()
	lib.group = module

	instance.modules[name] = module
	if (module.name ~= "Profiles") then
		instance.default = instance.default or module
	end

	-- module methods
	function module:select()
		if (module.active) then return end

		for name, otherModule in pairs(instance.modules) do
			otherModule:unselect()
		end

		instance.default = module
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
	local link = lib.elements['button']({solo = true}, instance.left)
	link.inactiveColor = {0, 0, 0, 0}
	link.hoverColor = {1, 1, 1, .2}
	link:OnLeave()
	link.OnClick = module.select
	link:SetText(name)
	link:SetWidth(dimensions.left_column)
	link.text:SetPoint("LEFT", link, "LEFT", 6, 0)
	if (not instance._lastLink) then
		link:SetPoint("TOPLEFT", instance.left, "TOPLEFT")
	else
		link:SetPoint("TOPLEFT", instance._lastLink, "BOTTOMLEFT")
	end

	if (name == "Profiles") then
		link:ClearAllPoints()
		link:SetPoint("BOTTOMLEFT", instance.left, "BOTTOMLEFT")
	else
		instance._lastLink = link
	end
	module.link = link

	return module
end