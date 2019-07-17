--[[












]]

local addonName, ns = ...
local mod = ns.bdConfig

-- Developer functions
local xpcall = xpcall
local function errorhandler(err)
	return geterrorhandler()(err)
end
local function safecall(func, ...)
	if func then
		return xpcall(func, errorhandler, ...)
	end
end

--=================================================================
-- REGISTER ADDON
--=================================================================
function mod:register(name, lock_toggle)
	local instance = {}
	instance._sv = GetAddOnMetadata(addonName, 'SavedVariables')
	instance._ns = name
	instance._modules = {}
	instance._window = mod:create_windows(name, lock_toggle)
	instance.save = mod:initialize_saved_variables(instance._sv)

	-- show config window toggle
	function instance:toggle()
		if (self._window:IsShown()) then
			self._window:Hide()
		else
			self._window:Show()
			self._default:select()
		end
	end

	--========================================
	-- Called by individual modules/addons
	--========================================
	function instance:register_module(name, config, callback)
		local module = mod:create_module(instance, name)
		module._config = config
		module.tree = {}

		--========================================
		-- Recursively build config
		--========================================
		function module:build(config, name, parent)
			instance.save[name] = instance.save[name] or {}
			parent.children = parent.children or {}
			local sv = instance.save[name]

			-- loop through options
			for option, info in pairs(config) do
				-- initiate sv default
				mod:ensure_value(sv, option, info.value)

				-- frame build here
				info.parent = parent
				info.name = option
				info.save = sv

				-- container group
				if (mod.container[info.type]) then
					parent = mod.container(info, save, parent)
				elseif (mod.elements[info.type])
					parent = mod.container(info, save, parent)
				else
					mod:debug("No module found for", info.type)
				end

				-- recursive call
				if (info.args) then
					module:build(info.args, name, parent)
				end
			end

		end

		-- Build Module Layout
		function module:layout()

		end

		-- call recursive build function
		module:build(config, name, module)

		-- return configuration reference
		return instance.save[name]
	end

	-- debug - show configuration window
	bdUI:add_action("post_loaded", function()
		instance:toggle()
	end)

	-- returns instance to be called
	return instance
end

--=================================================================
-- ELEMENTS & CONTAINERS
--=================================================================
local mod.containers = {}
function mod:register_container(options, create)
	mod.containers[name] = create
end

local mod.elements = {}
function mod:register_element(options, create)
	mod.elements[name]['start'] = create
end

--=================================================================
-- LAYOUT FRAMES
--=================================================================
function mod:create_container(options)

end