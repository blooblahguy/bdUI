--[[












]]

local parent = debugstack():match[[\AddOns\(.-)\]]

local version = 1
local _G = _G

-- a newer or same version has already been created, ignore this file
if _G.bdConfig and _G.bdConfig.version >= version then
	bdConfig = _G.bdConfig
	return
end
_G.bdConfig = {}

bdConfig.scale = 768/string.match(({GetScreenResolutions()})[GetCurrentResolution()], "%d+x(%d+)")
bdConfig.ui_scale = GetCVar("uiScale") or 1
bdConfig.pixel = bdConfig.scale / bdConfig.ui_scale

bdConfig.defaults = {
	left_column = 150,
	right_column = 600,
	height = 450,
	header = 30,
	padding = 10,

	media = {
		flat = "Interface\\Buttons\\WHITE8x8",
		arrow = "Interface\\Buttons\\Arrow-Down-Down.PNG",
		font = "fonts\\ARIALN.ttf",
		fontSize = 14,
		fontHeaderScale = 1.1,
		border = {0.06, 0.08, 0.09, 1},
		border_size = bdConfig.pixel * 2,
		background = {0.11, 0.15, 0.18, 1},
		red = {0.62, 0.17, 0.18, 1},
		blue = {0.2, 0.4, 0.8, 1},
		green = {0.1, 0.7, 0.3, 1},
	},
}

-- main font object
bdConfig.font = CreateFont("bdConfig_font")
bdConfig.font:SetFont(bdConfig.defaults.media.font, bdConfig.defaults.media.fontSize)
bdConfig.font:SetShadowColor(0, 0, 0)
bdConfig.font:SetShadowOffset(1, -1)
bdConfig.foundBetterFont = false

--[[ Use fonts from bdCore if possible, can extend this ]]
local function find_better_font()
	if (bdConfig.foundBetterFont) then return end
	local font = false

	if (bdUI) then
		font = bdUI.media.font
	elseif (bdlc) then
		font = bdlc.font
	end

	if (font) then
		bdConfig.foundBetterFont = true
		bdConfig.font:SetFont(font, bdConfig.defaults.media.fontSize)
	end
end

bdConfig.arrow = UIParent:CreateTexture(nil, "OVERLAY")
bdConfig.arrow:SetTexture(bdConfig.defaults.media.arrow)
bdConfig.arrow:SetTexCoord(0.9, 0.9, 0.9, 0.6)
bdConfig.arrow:SetVertexColor(1, 1, 1, 0.5)

-- Developer functions
local noop = function() return end
local function debug(...) print("|cffA02C2FbdConfigLib|r:", ...) end
local function round(num, idp) local mult = 10^(idp or 0) return floor(num * mult + 0.5) / mult end

--[[
	Config builder helper
]]
function bdConfig:helper_config()
	local helper = {}

	function helper:add(name, options)
		helper[#helper + 1] = {[name] = options}
	end

	return helper
end

--=================================================================
-- Register an addon to a new instance of bdConfig
-- returns a bdConfig instance tha you can add modules to
--=================================================================
function bdConfig:register(name, saved_variable_string, lock_toggle, settings)
	local config = CreateFrame("frame", nil, UIParent)
	config.modules = {}
	config.links = {}
	config.test = function() print("test") end

	-- Initaite saved variables
	_G[saved_variable_string] = _G[saved_variable_string] or {}
	config.sv = _G[saved_variable_string]

	function config:get_save(name)
		return config.sv[name]
	end

	-- Create configuration window
	find_better_font()
	config.window = bdConfig:create_windows(config, name, lock_toggle)
	function config:toggle()
		if (config.window:IsShown()) then
			config.window:Hide()
		else
			config.window:Show()
			config.default:select()
		end
	end

	--=================================================================
	-- The plggable callback to register a module
	-- @param name: the name of the module 
	-- @param options: the configuration options
	-- @param global: if options should be for all characters
	-- @param callback: callback function to be ran on config init/change 
	--=================================================================
	function config:register_module(name, options, callback)
		if (type(options[1]) ~= "table") then return end
		options.add = nil

		callback = callback or noop
		local dimensions = bdConfig.defaults
		local media = bdConfig.defaults.media
		local border = bdConfig.defaults.media.borderSize
		local module = bdConfig:create_module(self, name)

		-- BUILD CONFIGURATION
		local sv = _G[saved_variable_string]
		sv[name] = sv[name] or {}
		module.save = sv[name]

		for k, conf in pairs(options) do
			-- loop through the configuration table to setup, tabs, sliders, inputs, etc.
			for option, info in pairs(conf) do
				if (info.type) then

					-- initiate default values
					if (sv[name][option] == nil) then
						if (info.value == nil) then
							info.value = {}
						end
						sv[name][option] = info.value
					end		

					-- force blank callbacks if not set
					info.callback = info.callback or callback
					
					-- If the very first entry is not a tab, then create a general tab/page container
					if (info.type ~= "tab" and #module.tabs == 0) then
						module:create_page("General")
					end

					-- Master Call (slider = bdConfigLib.SliderElement(config, module, option, info))
					local method = string.lower(info.type).."_element"
					if (bdConfig[method]) then
						bdConfig[method](bdConfig, module, option, info)
					else
						debug("No module defined for "..method.." in "..name)
					end
				end
			end
		end

		module:set_page_scroll()


		-- return friendly options to access
		return module.save
	end

	-- return bdConfig instance
	return config
end

--[[========================================================
	CONFIGURATION INPUT ELEMENT METHODS
	This is all of the methods that create user interaction 
	elements. When adding support for new modules, start here
==========================================================]]

--[[========================================================
	ELEMENT CONTAINER WITH `COLUMN` SUPPORT
==========================================================]]
function  bdConfig:contain_element(module, info)
	local page = module.tabs[#module.tabs].page
	local element = info.type
	local container = CreateFrame("frame", nil, page)
	local padding = 15
	local sizing = {
		text = 1.0
		, table = 1.0
		, slider = 0.5
		, checkbox = 0.5
		, color = 0.33
		, dropdown = 0.5
		, clear = 1.0
		, button = 0.5
		, list = 1
		, textbox = 1.0
	}

	local size = sizing[string.lower(element)]
	if (not size) then
		print("size not found for "..element)
		size = 1
	end

	-- size the container ((pageWidth / %) - padding left)
	container:SetSize((page:GetWidth() * size) - padding, 30)

	-- TESTING : shows a background around each container for debugging
	-- container:SetBackdrop({bgFile = bdConfig.media.flat})
	-- container:SetBackdropColor(.1, .8, .2, 0.1)

	-- place the container
	page.rows = page.rows or {}
	page.row_width = page.row_width or 0
	page.row_width = page.row_width + size

	if (page.row_width > 1.0 or not page.lastContainer) then
		page.row_width = size	
		if (not page.lastContainer) then
			container:SetPoint("TOPLEFT", page, "TOPLEFT", padding, -padding)
		else
			container:SetPoint("TOPLEFT", page.lastRow, "BOTTOMLEFT", 0, -padding)
		end

		-- used to count / measure rows
		page.lastRow = container
		page.rows[#page.rows + 1] = container
	else
		container:SetPoint("LEFT", page.lastContainer, "RIGHT", padding, 0)
	end
	
	page.lastContainer = container
	return container
end

--[[========================================================
	ADDING NEW TABS / SETTING SCROLLFRAME
==========================================================]]
function bdConfig:tab_element(module, option, info)
	-- We're done with the current page contianer, cap it's slider/height and start a new tab / height
	-- module:SetPageScroll()

	-- add new tab
	module:create_page(info.value)
end

--[[========================================================
	TEXT ELEMENT FOR USER INFO
==========================================================]]
function bdConfig:text_element(module, option, info)
	local container =  bdConfig:contain_element(module, info)

	local text = container:CreateFontString(nil, "OVERLAY", "bdConfig_font")

	text:SetText(info.value)
	text:SetAlpha(0.8)
	text:SetJustifyH("LEFT")
	text:SetJustifyV("TOP")
	text:SetAllPoints(container)

	local lines = math.ceil(text:GetStringWidth() / (container:GetWidth() - 4))

	container:SetHeight( (lines * 14) + 10)

	return container
end

--[[========================================================
	CLEAR (clears the columns and starts a new row)
==========================================================]]
function bdConfig:clear_element(module, option, info)
	local container =  bdConfig:contain_element(module, info)

	container:SetHeight(1)

	return container
end

--[[========================================================
	TABLE ELEMENT
	lets you define a group of configs into a row, and allow for rows to be added
==========================================================]]
function bdConfig:list_element(module, option, info)
	local container =  bdConfig:contain_element(module, info)
	container:SetHeight(200)


	local title = container:CreateFontString(nil, "OVERLAY", "bdConfig_font")
	title:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
	title:SetText(info.label)

	local button = bdConfig:create_button(container)
	button:SetText("Add/Remove")

	local insertbox = CreateFrame("EditBox", nil, container)
	insertbox:SetFontObject("bdConfig_font")
	insertbox:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
	insertbox:SetSize(container:GetWidth() - 66, 24)
	insertbox:SetTextInsets(6, 2, 2, 2)
	insertbox:SetMaxLetters(200)
	insertbox:SetHistoryLines(1000)
	insertbox:SetAutoFocus(false) 
	insertbox:SetScript("OnEnterPressed", function(self, key) button:Click() end)
	insertbox:SetScript("OnEscapePressed", function(self, key) self:ClearFocus() end)
	bdConfig:create_backdrop(insertbox)

	insertbox.alert = insertbox:CreateFontString(nil, "OVERLAY", "bdConfig_font")
	insertbox.alert:SetPoint("TOPRIGHT",container,"TOPRIGHT", -2, 0)
	function insertbox:startFade()
		local total = 0
		self.alert:Show()
		self:SetScript("OnUpdate",function(self, elapsed)
			total = total + elapsed
			if (total > 2.5) then
				self.alert:SetAlpha(self.alert:GetAlpha()-0.02)
				
				if (self.alert:GetAlpha() <= 0.05) then
					self:SetScript("OnUpdate", function() return end)
					self.alert:Hide()
				end
			end
		end)
	end

	button:SetPoint("TOPLEFT", insertbox, "TOPRIGHT", 0, 2)
	insertbox:SetSize(container:GetWidth() - button:GetWidth() + 2, 24)

	local list = CreateFrame("frame", nil, container)
	list:SetPoint("TOPLEFT", insertbox, "BOTTOMLEFT", 0, -2)
	list:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT")
	bdConfig:create_backdrop(list)

	local content = bdConfig:create_scrollframe(list)

	list.text = content:CreateFontString(nil, "OVERLAY", "bdConfig_font")
	list.text:SetPoint("TOPLEFT", content, "TOPLEFT", 5, 0)
	list.text:SetHeight(600)
	list.text:SetWidth(list:GetWidth() - 10)
	list.text:SetJustifyH("LEFT")
	list.text:SetJustifyV("TOP")
	list.text:SetText("test")
	

	-- show all config entries in this list
	function list:populate()
		local string = "";
		local height = 0;

		-- maintained list
		-- allows us to pass a list of variables that should be maintained inside of this listbox, but can be set to false and won't be added again
		if (info.autoadd or info.autoAdd or info.maintained) then
			local autoadd = info.autoadd or info.autoAdd or info.maintained -- alias
			for k, v in pairs(autoadd) do
				if (module.save[option][k] == nil) then
					module.save[option][k] = v
				end
			end
		end

		-- populated the saved options
		for k, v in pairs(module.save[option]) do
			if (v ~= false) then
				string = string..k.."\n";
				height = height + 14
			end
		end

		local scrollheight = (height - 200) 
		scrollheight = scrollheight > 1 and scrollheight or 1

		list.scrollbar:SetMinMaxValues(1, scrollheight)
		if (scrollheight == 1) then 
			list.scrollbar:Hide()
		else
			list.scrollbar:Show()
		end

		list.text:SetHeight(height)
		list.text:SetText(string)
	end

	-- remove or add something, then redraw the text
	function list:addRemove(value)
		if (module.save[option][value]) then
			insertbox.alert:SetText(value.." removed")
			module.save[option][value] = false
		else
			insertbox.alert:SetText(value.." added")
			-- @todo pass in table or integer values here to alter display
			module.save[option][value] = true
		end
		insertbox:startFade()
		
		self:populate()
		info:callback()

		-- clear aura cache
		bdCore.caches.auras = {}
	end

	button.OnClick = function()
		local value = insertbox:GetText()

		if (strlen(value) > 0) then
			list:addRemove(insertbox:GetText())
		end

		insertbox:SetText("")
		insertbox:ClearFocus()
	end

	list:populate()

	return container
end
--[[========================================================
	BUTTON ELEMENT
	lets you define a group of configs into a row, and allow for rows to be added
==========================================================]]
function bdConfig:button_element(module, option, info)
	local container =  bdConfig:contain_element(module, info)

	local create = bdConfig:create_button(container)
	create:SetPoint("TOPLEFT", container, "TOPLEFT")
	create:SetText(info.value)

	create:SetScript("OnClick", function()
		info.callback()
	end)

	return container
end

--[[========================================================
	TEXTBOX ELEMENT
==========================================================]]
function bdConfig:textbox_element(module, option, info)
	local container =  bdConfig:contain_element(module, info)

	local create = CreateFrame("EditBox", nil, container)
	create:SetSize(200,24)
	create:SetFontObject("bdConfig_font")
	create:SetText(info.value)
	create:SetTextInsets(6, 2, 2, 2)
	create:SetMaxLetters(200)
	create:SetHistoryLines(1000)
	create:SetAutoFocus(false) 
	create:SetScript("OnEnterPressed", function(self, key) create.button:Click() end)
	create:SetScript("OnEscapePressed", function(self, key) self:ClearFocus() end)
	create:SetPoint("TOPLEFT", container, "TOPLEFT", 5, 0)
	bdConfig:create_backdrop(create)

	create.label = create:CreateFontString(nil, "OVERLAY", "bdConfig_font")
	create.label:SetText(info.description)
	create.label:SetPoint("BOTTOMLEFT", create, "TOPLEFT", 0, 4)

	create.button = bdConfig:create_button(create)
	create.button:SetPoint("LEFT", create, "RIGHT", 4, 0)
	create.button:SetText(info.button)
	create.button.OnClick = function()
		local text = create:GetText()
		info:callback(text)
		create:SetText("")
	end

	return container
end

--[[========================================================
	SLIDER ELEMENT
==========================================================]]
function bdConfig:slider_element(module, option, info)
	local container =  bdConfig:contain_element(module, info)

	local slider = CreateFrame("Slider", module.name.."_"..option, container, "OptionsSliderTemplate")
	slider:SetWidth(container:GetWidth())
	slider:SetHeight(14)
	slider:SetPoint("TOPLEFT", container ,"TOPLEFT", 0, -10)
	slider:SetOrientation('HORIZONTAL')
	slider:SetMinMaxValues(info.min, info.max)
	slider.SetObeyStepOnDrag = slider.SetObeyStepOnDrag or noop
	slider:SetObeyStepOnDrag(true)
	slider:SetValueStep(info.step)
	slider:SetValue(module.save[option])
	slider.tooltipText = info.tooltip

	local low = _G[slider:GetName() .. 'Low']
	local high = _G[slider:GetName() .. 'High']
	local label = _G[slider:GetName() .. 'Text']
	low:SetText(info.min);
	low:SetFontObject("bdConfig_font")
	low:ClearAllPoints()
	low:SetPoint("TOPLEFT",slider,"BOTTOMLEFT",0,-1)

	high:SetText(info.max);
	high:SetFontObject("bdConfig_font")
	high:ClearAllPoints()
	high:SetPoint("TOPRIGHT",slider,"BOTTOMRIGHT",0,-1)

	label:SetText(info.label);
	label:SetFontObject("bdConfig_font")
	
	slider.value = slider:CreateFontString(nil, "OVERLAY", "bdConfig_font")
	slider.value:SetPoint("TOP", slider, "BOTTOM", 0, -2)
	slider.value:SetText(module.save[option])

	slider:Show()
	slider.lastValue = 0
	slider:SetScript("OnValueChanged", function(self)
		local newval
		if (info.step >= 1) then
			newval = round(slider:GetValue())
		else
			newval = round(slider:GetValue(), 1)
		end

		if (slider.lastValue == newval) then return end
		if (module.save[option] == newval) then -- throttle it changing on the same pixel
			return false
		end

		module.save[option] = newval
		slider.lastValue = newval

		slider:SetValue(newval)
		slider.value:SetText(newval)
		
		info:callback()
	end)

	container:SetHeight(52)

	return container
end

--[[========================================================
	CHECKBOX ELEMENT
==========================================================]]
function bdConfig:checkbox_element(module, option, info)
	local container =  bdConfig:contain_element(module, info)
	container:SetHeight(35)

	local check = CreateFrame("CheckButton", module.name.."_"..option, container, "ChatConfigCheckButtonTemplate")
	check:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
	local text = _G[check:GetName().."Text"]
	text:SetText(info.label)
	text:SetFontObject("bdConfig_font")
	text:ClearAllPoints()
	text:SetPoint("LEFT", check, "RIGHT", 2, 1)
	check.tooltip = info.tooltip;
	check:SetChecked(module.save[option])

	check:SetScript("OnClick", function(self)
		module.save[option] = self:GetChecked()

		info:callback(check)
	end)

	return container
end

--[[========================================================
	COLORPICKER ELEMENT
==========================================================]]
function bdConfig:color_element(module, option, info)
	local container =  bdConfig:contain_element(module, info)

	local picker = CreateFrame("button", nil, container)
	picker:SetSize(20, 20)
	picker:SetBackdrop({bgFile = bdConfig.defaults.media.flat, edgeFile = bdConfig.defaults.media.flat, edgeSize = 2, insets = {top = 2, right = 2, bottom = 2, left = 2}})
	picker:SetBackdropColor(unpack(module.save[option]))
	picker:SetBackdropBorderColor(0,0,0,1)
	picker:SetPoint("LEFT", container, "LEFT", 0, 0)
	
	picker.callback = function(self, r, g, b, a)
		module.save[option] = {r,g,b,a}
		picker:SetBackdropColor(r,g,b,a)

		info:callback()
		
		return r, g, b, a
	end
	
	picker:SetScript("OnClick",function()		
		HideUIPanel(ColorPickerFrame)
		local r, g, b, a = unpack(module.save[option])

		ColorPickerFrame:SetFrameStrata("FULLSCREEN_DIALOG")
		ColorPickerFrame:SetClampedToScreen(true)
		ColorPickerFrame.hasOpacity = true
		ColorPickerFrame.opacity = 1 - a
		ColorPickerFrame.old = {r, g, b, a}
		
		local function colorChanged()
			local r, g, b = ColorPickerFrame:GetColorRGB()
			local a = 1 - OpacitySliderFrame:GetValue()
			picker:callback(r, g, b, a)
		end

		ColorPickerFrame.func = colorChanged
		ColorPickerFrame.opacityFunc = colorChanged
		ColorPickerFrame.cancelFunc = function()
			local r, g, b, a = unpack(ColorPickerFrame.old) 
			picker:callback(r, g, b, a)
		end

		ColorPickerFrame:SetColorRGB(r, g, b)
		ColorPickerFrame:EnableKeyboard(false)
		ShowUIPanel(ColorPickerFrame)
	end)
	
	picker.text = picker:CreateFontString(nil, "OVERLAY", "bdConfig_font")
	picker.text:SetText(info.name)
	picker.text:SetPoint("LEFT", picker, "RIGHT", 8, 0)

	container:SetHeight(30)

	return container
end

--[[========================================================
	DROPDOWN ELEMENT
==========================================================]]
function bdConfig:dropdown_element(module, option, info)
	local container =  bdConfig:contain_element(module, info)

	local label = container:CreateFontString(nil, "OVERLAY", "bdConfig_font")
	label:SetPoint("TOPLEFT", container, "TOPLEFT")
	label:SetText(info.label)
	container:SetHeight(45)

	local dropdown = CreateFrame("Button", module.name.."_"..option, container, "UIDropDownMenuTemplate")
	dropdown:SetPoint("TOPLEFT", label, "BOTTOMLEFT", -15, -2)

	-- recreate dropdown each time
	function dropdown:populate(options, value)
		if (not value) then value = info.value end
		UIDropDownMenu_SetWidth(dropdown, container:GetWidth() - 20)
		UIDropDownMenu_JustifyText(dropdown, "LEFT")

		UIDropDownMenu_Initialize(dropdown, function(self, level)
			local selected = 1
			for i, item in pairs(options) do
				if (type(item) == "string") then
					opt = UIDropDownMenu_CreateInfo()
					opt.text = item:gsub("^%l", string.upper)
					opt.value = item
					if (value == nil) then
						value = item
					end
					opt.func = function(self)
						UIDropDownMenu_SetSelectedID(dropdown, self:GetID())
						CloseDropDownMenus()

						module.save[option] = options[i]
						value = options[i]

						info:callback(options[i])
					end

					if (info.override) then
						if item == value then
							selected = i
						end
					else
						if (item == module.save[option]) then selected = i end
					end

					UIDropDownMenu_AddButton(opt, level)
				end
			end

			UIDropDownMenu_SetSelectedID(dropdown, selected)
		end)
	end

	local dropdownproxy = setmetatable({}, {
		__newindex = function(self, key, value)
			if not rawget(info.options, key) then
				rawset(info.options, key, value == true and key or value)
				
				dropdown:populate(info.options)
			end
		end
	})

	-- if (info.update_action and info.update) then
	-- 	bd_add_action(info.update_action, function(updateTable)
	-- 		info:update(dropdown)
	-- 	end)
	-- end

	dropdown:populate(info.options)

	return container
end


--[[
	CREATE MODULE
	creates module with page functionality and link
]]
function bdConfig:create_module(config, name)
	local dimensions = bdConfig.defaults
	local media = bdConfig.defaults.media
	local border = bdConfig.defaults.media.border_size

	local module = {}
	module.name = name
	module.tabs = {}
	config.modules[name] = module
	config.default = config.default or module

	-- create tab container
	local tabContainer = CreateFrame("frame", nil, config.window.right)
	tabContainer:SetPoint("TOPLEFT")
	tabContainer:SetPoint("TOPRIGHT")
	tabContainer:Hide()
	tabContainer:SetHeight(dimensions.header)
	bdConfig:create_backdrop(tabContainer)
	local r, g, b, a = unpack(media.background)
	tabContainer.bd_border:Hide()
	tabContainer.bd_background:SetVertexColor(r, g, b, 0.5)
	
	module.tabContainer = tabContainer

	-- module methods
	function module:select()
		if (module.active) then return end

		-- unselect all modules
		for name, otherModule in pairs(config.modules) do
			otherModule:unselect()
			for k, t in pairs(otherModule.tabs) do
				t:unselect()
			end
		end

		config.default = module
		module.active = true
		module.link.active = true
		module.link:OnLeave()
		module.tabContainer:Show()
		module.tabs[1]:select()
		
		-- If we only have 1 tab, hide it
		local current_tab = module.tabs[#module.tabs]
		if (current_tab.text:GetText() == "General") then
			module.tabContainer:Hide()
			current_tab.page.scrollParent:SetHeight(dimensions.height - border)
		end
	end
	function module:unselect()
		if (not module.active) then return end
		module.active = false
		module.link.active = false
		module.link:OnLeave()
		module.tabContainer:Hide()
	end

	function module:create_link()
		local link = bdConfig:create_button(config.window.left)
		link.inactiveColor = {0, 0, 0, 0}
		link.hoverColor = {1, 1, 1, .2}
		link:OnLeave()
		link.OnClick = module.select
		link:SetText(name)
		link:SetWidth(dimensions.left_column)
		link.text:SetPoint("LEFT", link, "LEFT", 6, 0)
		if (not config.lastLink) then
			link:SetPoint("TOPLEFT", config.window.left, "TOPLEFT")
			config.firstLink = link
		else
			link:SetPoint("TOPLEFT", config.lastLink, "BOTTOMLEFT")
		end
		config.lastLink = link
		module.link = link
	end

	function module:create_page(page_name)
		local index = #module.tabs + 1
		local page = bdConfig:create_scrollframe(config.window.right)

		-- create tab to link to this page
		local tab = bdConfig:create_button(module.tabContainer)
		tab.inactiveColor = {1,1,1,0}
		tab.hoverColor = {1,1,1,0.1}
		tab:OnLeave()

		function tab:select()
			-- tab:Show()
			tab.page:Show()
			if (not tab.page.noScrollbar) then
				tab.page.scrollbar:Show()
			end

			tab.active = true
			tab.page.active = true
			tab:OnLeave()
			module.activePage = page
		end

		function tab:unselect()
			-- tab:Hide()
			tab.page.scrollbar:Hide()
			tab.page:Hide()
			tab.active = false
			tab.page.active = false
			tab:OnLeave()

			module.activePage = false
		end
		tab.OnClick = function()
			-- unselect / hide other tabs
			for i, t in pairs(module.tabs) do
				t:unselect()
			end
			tab:select()
		end
		tab:SetText(page_name)
		if (index == 1) then
			tab:SetPoint("LEFT", module.tabContainer, "LEFT", 0, 0)
		else
			tab:SetPoint("LEFT", module.tabs[index - 1], "RIGHT", 1, 0)
		end

		-- give data to the objects, to reference eachother easily
		tab.page, tab.name, tab.index = page, page_name, index
		page.tab, page.name, page.index = tab, page_name, index

		-- append to tab storage
		module.activePage = page
		module.tabs[index] = tab

		return index
	end

	-- Caps/hide the scrollbar as necessary
	-- also resize the page
	function module:set_page_scroll()
		-- now that all configs have been created, loop through the tabs
		for index, tab in pairs(module.tabs) do
			local page = tab.page
		
			local height = 0
			if (page.rows) then
				for k, container in pairs(page.rows) do
					height = height + container:GetHeight() + 10
				end
			end

			-- size based on if there are tabs or scrollbars
			local scrollHeight = 0
			if (#module.tabs > 1) then
				scrollHeight = math.max(dimensions.height, height + dimensions.header) - dimensions.height + 1			
				page.scrollParent:SetPoint("TOPLEFT", page.parent, "TOPLEFT", 0, - dimensions.header)
				page.scrollParent:SetHeight(page.scrollParent:GetParent():GetHeight() - dimensions.header)
			else
				scrollHeight = math.max(dimensions.height, height) - dimensions.height + 1
			end

			-- make the scrollbar only scroll the height of the page
			page.scrollbar:SetMinMaxValues(1, scrollHeight)

			if (scrollHeight <= 1) then
				page.noScrollbar = true
				page.scrollbar:Hide()
			else
				page.noScrollbar = false
				page.scrollbar:Show()
			end
		end
	end

	-- Create module link (for sidebar)
	module:create_link()

	return module
end

--=================================================================
-- FRAME CREATION
-- Creates the configuration window frames
--=================================================================
-- Create configuration window frames
function bdConfig:create_windows(parent, name, lock_toggle)
	local dimensions = bdConfig.defaults
	local media = bdConfig.defaults.media
	local border = media.border_size

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
	do
		window.header = CreateFrame("frame", nil, window)
		window.header:SetPoint("TOPLEFT")
		window.header:SetPoint("TOPRIGHT")
		window.header:SetHeight(dimensions.header)
		window.header:RegisterForDrag("LeftButton", "RightButton")
		window.header:EnableMouse(true)
		window.header:SetScript("OnDragStart", function(self) window:StartMoving() end)
		window.header:SetScript("OnDragStop", function(self) window:StopMovingOrSizing() end)
		window.header:SetScript("OnMouseUp", function(self) window:StopMovingOrSizing() end)
		bdConfig:create_backdrop(window.header)

		window.header.text = window.header:CreateFontString(nil, "OVERLAY", "bdConfig_font")
		window.header.text:SetPoint("LEFT", 10, 0)
		window.header.text:SetJustifyH("LEFT")
		window.header.text:SetText(name.." Configuration")
		window.header.text:SetJustifyV("MIDDLE")

		window.header.close = bdConfig:create_button(window.header)
		window.header.close:SetPoint("TOPRIGHT", window.header)
		window.header.close:SetText("x")
		window.header.close.inactiveColor = media.red
		window.header.close:OnLeave()
		window.header.close.OnClick = function()
			window:Hide()
		end

		window.header.reload = bdConfig:create_button(window.header)
		window.header.reload:SetPoint("TOPRIGHT", window.header.close, "TOPLEFT", -border, 0)
		window.header.reload:SetText("Reload UI")
		window.header.reload.inactiveColor = media.green
		window.header.reload:OnLeave()
		window.header.reload.OnClick = function()
			ReloadUI();
		end

		window.header.lock = bdConfig:create_button(window.header)
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
	end

	-- Left Column
	do
		window.left = CreateFrame( "Frame", nil, window)
		window.left:SetPoint("TOPLEFT", window, "TOPLEFT", 0, -dimensions.header - border)
		window.left:SetSize(dimensions.left_column, dimensions.height)
		bdConfig:create_backdrop(window.left)
	end

	-- Right Column
	do
		window.right = CreateFrame( "Frame", nil, window)
		window.right:SetPoint("TOPRIGHT", window, "TOPRIGHT", 0, -dimensions.header - border)
		window.right:SetSize(dimensions.right_column - border, dimensions.height)
		bdConfig:create_backdrop(window.right)
		window.right.bd_background:SetVertexColor(unpack(media.border))
	end

	return window
end

-- creates basic button template
function bdConfig:create_button(parent)
	local dimensions = bdConfig.defaults
	local media = bdConfig.defaults.media
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
	button:SetHeight(dimensions.header)
	button:EnableMouse(true)

	button.text = button:CreateFontString(nil, "OVERLAY", "bdConfig_font")
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
		button:SetWidth(button.text:GetStringWidth() + dimensions.header)
	end

	button:SetScript("OnEnter", button.OnEnter)
	button:SetScript("OnLeave", button.OnLeave)
	button:SetScript("OnClick", button.OnClickDefault)

	return button
end

-- dirty create shadow (no external textures)
function bdConfig:create_shadow(frame, size)
	if (frame.shadow) then return end

	local media = bdConfig.defaults.media

	frame.shadow = {}
	local start = 0.092
	for s = 1, size do
		local shadow = frame:CreateTexture(nil, "BACKGROUND")
		shadow:SetTexture(media.flat)
		shadow:SetVertexColor(0,0,0,1)
		shadow:SetPoint("TOPLEFT", frame, "TOPLEFT", -s, s)
		shadow:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", s, -s)
		shadow:SetAlpha(start - ((s / size) * start))
		frame.shadow[s] = shadow
	end
end

-- create consistent with border
function bdConfig:create_backdrop(frame)
	if (frame.bd_background) then return end

	local media = bdConfig.defaults.media
	local border = media.border_size

	local background = frame:CreateTexture(nil, "BORDER", -1)
	background:SetTexture(media.flat)
	background:SetVertexColor(unpack(media.background))
	background:SetAllPoints()
	
	local bd_border = frame:CreateTexture(nil, "BACKGROUND", -8)
	bd_border:SetTexture(media.flat)
	bd_border:SetVertexColor(unpack(media.border))
	bd_border:SetPoint("TOPLEFT", frame, "TOPLEFT", -border, border)
	bd_border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", border, -border)

	frame.bd_background = background
	frame.bd_border = bd_border

	return frame
end

-- creates scroll frame and returns its content
function bdConfig:create_scrollframe(parent, width, height)
	local dimensions = bdConfig.defaults

	width = width or parent:GetWidth()
	height = height or parent:GetHeight()

	-- scrollframe
	local scrollParent = CreateFrame("ScrollFrame", nil, parent) 
	scrollParent:SetPoint("TOPLEFT", parent) 
	scrollParent:SetSize(width - dimensions.padding, height)

	--scrollbar 
	local scrollbar = CreateFrame("Slider", nil, scrollParent, "UIPanelScrollBarTemplate") 
	scrollbar:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -2, -18) 
	scrollbar:SetPoint("BOTTOMLEFT", parent, "BOTTOMRIGHT", -18, 18) 
	scrollbar:SetMinMaxValues(1, 600)
	scrollbar:SetValueStep(1)
	scrollbar.scrollStep = 1
	scrollbar:SetValue(0)
	scrollbar:SetWidth(16)
	bdConfig:create_backdrop(scrollbar)
	parent.scrollbar = scrollbar

	--content frame 
	local content = CreateFrame("Frame", nil, scrollParent) 
	content:SetPoint("TOPLEFT", parent, "TOPLEFT") 
	content:SetSize(scrollParent:GetWidth() - (dimensions.padding * 2), scrollParent:GetHeight())
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