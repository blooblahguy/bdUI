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

		self.callback(self.dropdown)
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

			if (selected > 0) then
				UIDropDownMenu_SetSelectedID(dropdown, selected)
			else
				UIDropDownMenu_SetSelectedID(dropdown, default_id)
			end
		end)
	end

	-- hook into actions for updates
	if (options.action) then
		lib:add_action(options.action, function(value)
			local results = options.lookup()
			options.options = results
			dropdown:populate(results)
		end)
	end

	dropdown:populate(options.options)

	return container
end

lib:register_element("select", create)