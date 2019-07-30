local addonName, ns = ...
local mod = ns.bdConfig

--========================================
-- Methods Here
--========================================
local methods = {
	["set"] = function(self, save, key, value)
		if (not save) then save = self.save end
		if (not key) then key = self.key end
		if (not value) then value = self:get(save, key) end

		save[key] = value
	end,
	["get"] = function(self, options, save)
		if (not save) then save = self.save end
		if (not key) then key = self.key end

		return save[key]
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
	local container = mod:create_container(options, parent, 48)
	container.save = options.save
	container.key = options.key
	Mixin(container, methods)

	-- objects
	local label = container:CreateFontString(nil, "OVERLAY", "bdConfig_font")
	label:SetPoint("TOPLEFT", container, "TOPLEFT", 6, -2)
	label:SetText(options.label)
	local dropdown = CreateFrame("Button", options.module.."_"..options.key, container, "UIDropDownMenuTemplate")
	dropdown:SetPoint("TOPLEFT", label, "BOTTOMLEFT", -20, -2)
	dropdown.label = label

	local default_option = options.value
	-- recreate dropdown each time
	function dropdown:populate(items)
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

						options.save[options.key] = items[i]
						options.callback(dropdown, options, items[i])
					end

					-- select save value
					if (item == default_option) then 
						default_id = i
					end
					if (item == options.save[options.key]) then 
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
		mod:add_action(options.action, function(value)
			local results = options.lookup()
			dropdown:populate(results)
		end)
	end

	dropdown:populate(options.options)

	return container, dropdown
end

mod:register_element("select", create)