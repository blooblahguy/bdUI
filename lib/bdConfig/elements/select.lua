local addonName, ns = ...
local mod = ns.bdConfig

--========================================
-- Methods Here
--========================================
local methods = {
	["set"] = function(self, options, save)
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
	Mixin(container, methods)

	-- objects
	local label = container:CreateFontString(nil, "OVERLAY", "bdConfig_font")
	label:SetPoint("TOPLEFT", container, "TOPLEFT", 6, -2)
	label:SetText(options.label)
	local dropdown = CreateFrame("Button", options.module.."_"..options.key, container, "UIDropDownMenuTemplate")
	dropdown:SetPoint("TOPLEFT", label, "BOTTOMLEFT", -20, -2)

	-- recreate dropdown each time
	function dropdown:populate(items, value)
		if (not value) then value = options.value end
		UIDropDownMenu_SetWidth(dropdown, container:GetWidth() - 20)
		UIDropDownMenu_JustifyText(dropdown, "LEFT")

		UIDropDownMenu_Initialize(dropdown, function(self, level)
			local selected = 1
			for i, item in pairs(items) do
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

						options.save[options.key] = items[i]
						print(options.save[options.key])
						value = items[i]

						options:callback(dropdown, options, items[i])
					end

					-- select save value
					if (item == options.save[options.key]) then selected = i end

					UIDropDownMenu_AddButton(opt, level)
				end
			end

			UIDropDownMenu_SetSelectedID(dropdown, selected)
		end)
	end

	local dropdownproxy = setmetatable({}, {
		__newindex = function(self, key, value)
			if not rawget(options.options, key) then
				rawset(options.options, key, value == true and key or value)
				
				dropdown:populate(options.options)
			end
		end
	})

	dropdown:populate(options.options)

	return container
end

mod:register_element("select", create)