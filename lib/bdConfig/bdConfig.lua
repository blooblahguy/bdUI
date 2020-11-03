--[[












]]

local parent, ns = ...
local lib = ns.bdConfig

--=================================================================
-- MODULE METHODS
-- Hooked into method
--=================================================================
local module_methods = {
	['reload'] = function(self, profile)
		self:get_save()
		self:ensure_values(self.config)
		self:callback()
	end,
	-- builds frame objects in layout window
	['build'] = function(self, config, parent)
		if (not self.first) then self.first = parent end

		-- loop through options
		for option, info in pairs(config) do

			-- frame build here
			info.module = self
			info.save = self.save
			info.name = self.name
			-- wrapped callback
			info.self_callback = info.callback
			local module = self
			function info.callback(self, ...)
				if (info.self_callback) then
					info:self_callback(...)
				end
				module:callback()
			end

			if (not self.options.hide_ui and (lib.containers[info.type] or lib.elements[info.type])) then -- only if we've created this module
				local group = parent

				-- create type module
				if (lib.containers[info.type]) then -- container group, chagne parents
					group = group:add(lib.containers[info.type](info, group))
				elseif (lib.elements[info.type]) then -- sub element
					local element = group:add(lib.elements[info.type](info, group))
					if (element.set) then
						lib:add_action("profile_change", function()
							element:set()
						end, 20)
					end
				end

				-- recursive call
				if (info.args and info.type ~= "repeater") then
					self:build(info.args, group)
				end

				parent.last_frame = group
			elseif (not self.options.hide_ui) then
				lib:debug("No module found for", info.type, "for", info.key)
			end
		end

		-- parent:update()
	end,
	['ensure_values'] = function(self, config)
		for option, info in pairs(config) do
			lib:ensure_value(self.save, info.key, info.value, self.options.persistent) -- initiate sv default

			if (info.args) then
				self:ensure_values(info.args)
			end
		end
	end,
	-- load and build the module now that SVs are available
	['load'] = function(self)
		self:get_save()
		self:ensure_values(self.config)

		-- store callback
		if (self[self.callback]) then
			self.callback = self[self.callback]
		else
			self.callback = lib.noop
		end

		-- call recursive build function
		local group = lib.containers["group"]({}, self, true)
		self:build(self.config, group)
		group:update()
		
		if (group:GetHeight() < lib.dimensions.height) then
			group:SetHeight(lib.dimensions.height - (lib.dimensions.padding * 2))
		end

		return self.save
	end,
	-- Update scrollframe to size of build
	['update_scroll'] = function(self)
		local height = self.first:GetHeight() + lib.dimensions.padding

		local scrollHeight = math.max(lib.dimensions.height, height) - lib.dimensions.height + 1
		if (height > lib.dimensions.height) then
			height = lib.dimensions.height
		end
		self.scrollParent:SetHeight(height)
		self.scrollbar:SetMinMaxValues(1, scrollHeight)

		if (scrollHeight <= 1) then
			self.noScrollbar = true
			self.scrollbar:Hide()
		else
			self.noScrollbar = false
			self.scrollbar:Show()
		end
	end,
	-- fetch and return save for current profile to addons
	['get_save'] = function(self)
		self.save = lib:get_save(self.sv_string, self.name, self.options.persistent)
		return self.save
	end
}

--=================================================================
-- INSTANCE METHODS
-- Hooked into instance
--=================================================================
local methods = {
	-- toggles visibility of configuration window
	["toggle"] = function(self)
		if (self:IsShown()) then
			self:Hide()
		else
			self:Show()
			self.default:select()
		end
	end,
	-- store save object, now that sv is available
	['load'] = function(self, options)
		options = options or {}

		-- create saves
		lib:initialize_saved_variables(self.sv_string)
		self.save = lib:get_save(self.sv_string)

		-- create profiles
		if (not options.hide_profiles) then
			lib:create_profiles(self, options)
		end
	end,
	-- fetch and return save for current profile to addons
	['get_save'] = function(self)
		self.save = lib:get_save(self.sv_string, nil, false)
		return self.save
	end,
	-- register a blank module frame that we can reference and update
	['register_module'] = function(self, name, config, callback, options)
		options = options or {}
		local module
		if (options.hide_ui) then
			module = CreateFrame("frame", nil, UIParent)
		else
			module = lib:create_module(self, name, config, callback, options)
		end

		-- cascading variables
		module.name = name
		module.config = config
		module.callback = callback
		module.options = options
		module.sv_string = self.sv_string
		module.save = false

		-- add methods to object
		Mixin(module, module_methods)

		-- Hook into profile changes
		lib:add_action("profile_change", function() module:reload() end, 15)

		return module
	end,
}

--=================================================================
-- REGISTER A NEW ADDON
-- lib:new(name, sv_string, lock_toggle)
--=================================================================
function lib:new(name, sv_string, lock_toggle)
	local instance = lib:create_windows(name, lock_toggle)

	instance.name = name
	instance.sv_string = sv_string
	instance.modules = {}

	Mixin(instance, methods)

	return instance
end