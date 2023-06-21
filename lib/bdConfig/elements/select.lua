local parent, ns = ...
local lib = ns.bdConfig

--========================================
-- Methods Here
--========================================
local methods = {
	-- set value to profile[key]
	["set"] = function(self, value)
		self.save = self.module:get_save()

		if (not value) then value = self:get() end
		self.save[self.key] = value

		self.dropdown:populate()
	end,
	-- return value from profile[key]
	["get"] = function(self)
		self.save = self.module:get_save()

		return self.save[self.key]
	end,
	["onchange"] = function(self, options, save)

	end,
	["onclick"] = function(self, options, save)
		
	end
}

local function skin(frame, pos)

	local frameName = frame.GetName and frame:GetName()
	local button = frame.Button or frameName and (_G[frameName.."Button"] or _G[frameName.."_Button"])
	local text = frameName and _G[frameName.."Text"] or frame.Text
	local icon = frame.Icon


	for k, v in pairs ({frame:GetRegions()}) do
		if (v:GetObjectType() == "TEXTURE") then
			v:SetTexture("")
			v:Hide()
		end
	end

	lib:create_backdrop(frame)
	frame:SetFrameLevel(frame:GetFrameLevel() + 2)
	-- frame.backdrop:SetPoint("TOPLEFT", 20, -2)
	-- frame.backdrop:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)

	button:ClearAllPoints()

	if pos then
		button:SetPoint("TOPRIGHT", frame.Right, -20, -21)
	else
		button:SetPoint("RIGHT", frame, "RIGHT", -10, 3)
	end

	button.SetPoint = lib.noop
	-- S:HandleNextPrevButton(button)

	if text then
		text:ClearAllPoints()
		text:SetPoint("RIGHT", button, "LEFT", -2, 0)
	end

	if icon then
		icon:SetPoint("LEFT", 23, 0)
	end
end

--========================================
-- Spawn Element
--========================================
local function create(options, parent)
	options.size = options.size or "half"
	local container = lib:create_container(options, parent, 48)

	container.save = options.save
	container.key = options.key
	container.module = options.module
	container.callback = options.callback
	Mixin(container, methods)

	-- objects
	local label = container:CreateFontString(nil, "OVERLAY", "bdConfig_font")
	label:SetPoint("TOPLEFT", container, "TOPLEFT", 6, -2)
	label:SetText(options.label)
	label:SetAlpha(lib.media.muted)
	local dropdown = CreateFrame("Button", options.name.."_"..options.key, container, "UIDropDownMenuTemplate")
	dropdown:SetPoint("TOPLEFT", label, "BOTTOMLEFT", -20, -2)
	container.label = label
	container.dropdown = dropdown

	local default_option = options.value
	-- recreate dropdown each time
	function dropdown:populate(items)
		items = items or options.options
		if (not value) then value = options.value end

		UIDropDownMenu_SetWidth(dropdown, container:GetWidth() - 20)
		UIDropDownMenu_JustifyText(dropdown, "LEFT")

		UIDropDownMenu_Initialize(dropdown, function(self, level)
			local selected = 0
			local default_id = 1
			for i, item in pairs(items) do
				if (type(item) == "string") then
					opt = UIDropDownMenu_CreateInfo()
					opt.text = item:gsub("^%l", string.upper)
					opt.value = item
	
					opt.func = function(self)
						UIDropDownMenu_SetSelectedID(dropdown, self:GetID())
						CloseDropDownMenus()

						container.save[options.key] = items[i]
						container.callback(dropdown, options, items[i])
					end

					-- select save value
					if (item == default_option) then 
						default_id = i
					end
					if (item == container.save[options.key]) then 
						selected = i
					end

					UIDropDownMenu_AddButton(opt, level)
				end
			end

			if (selected and selected ~= 0) then
				UIDropDownMenu_SetSelectedID(dropdown, selected)
			else
				UIDropDownMenu_SetSelectedID(dropdown, default_id)
			end
		end)
	end

	

	dropdown:populate(options.options)

	-- hook into actions for updates
	if (options.action) then
		lib:add_action(options.action, function(value)
			local results = options.lookup()
			options.options = results
			dropdown:populate(results)
		end)
	end

	-- lib:do_action(options.action)

	-- skin(dropdown)

	-- options.callback(dropdown)

	container:set()

	return container
end

lib:register_element("select", create)