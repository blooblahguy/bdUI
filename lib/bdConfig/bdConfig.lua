--[[












]]

local addonName, ns = ...
ns.bdConfig = {}
local mod = ns.bdConfig
mod.callback = LibStub("CallbackHandler-1.0"):New(mod, "Register", "Unregister", "UnregisterAll")

-- Developer functions
local xpcall = xpcall
function mod:noop() return end
function mod:debug(...) print("|cffA02C2FbdConfig|r:", ...) end
function mod:round(num, idp) local mult = 10^(idp or 0) return floor(num * mult + 0.5) / mult end
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
		function module:build(config, name)
			instance.save[name] = instance.save[name] or {}
			local sv = instance.save[name]

			-- loop through options
			for option, info in pairs(config) do
				-- initiate sv default
				mod:ensure_value(sv, option, info.value)

				-- frame build here
				info.parent = info.parent or module
				info.name = option
				info.save = sv

				-- container group
				if (mod.container[info.type]) then
					module.tree
				end

					-- recursive call
					if (info.args) then
						module:build(info.args, name)
					end

				-- end layout
				if (mod["end_"..info.type]) then
					mod["end_"..info.type](bdConfig, info)
				end
			end

		end

		-- Build Module Layout
		function module:layout()

		end

		-- call recursive build function
		module:build(config, name)

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
function mod:register_container(name, create)
	local container = create
	mod.containers[name] = create
end

local mod.elements = {}
function mod:register_element(name, create)
	mod.elements[name]['start'] = create
end

--=================================================================
-- LAYOUT FRAMES
--=================================================================
function mod:create_container(options)

end