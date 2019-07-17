local bdUI, c, l = unpack(select(2, ...))

--================================================
-- Mod should have
---- mod:initialize()
---- mod:config_callback()
-- Upon savedvariables load
--================================================

--================================================
-- Allows for modules to be registered and 
-- automatically loaded / disabled as needed
bdUI.modules = {}
--================================================
function bdUI:register_module(name, config)
	if (name == "Name") then return {} end
	if (bdUI[name]) then
		bdUI:debug('"', name, '"', "already exists as a module. Use unique names for new modules")
		return
	end
	bdUI[name] = bdUI[name] or CreateFrame("frame", name, bdParent)

	local module = bdUI[name]
	module._name = name
	module._config = config
	module._config_callback = callback or "config_callback"
	table.insert(bdUI.modules, module)

	return module
end

-- Load specific modules
function bdUI:get_module(name)
	return bdUI[name]
end

function bdUI:load_module(name)

	local module = bdUI[name]

	if (not module.initialize) then
		bdUI:debug(module._name, "does not have an initialize() function and can't be loaded")
		return
	end

	if (module:initialize(module._config) ~= false) then
		-- config & initalize callback
		if (type(module._config_callback) == "string") then
			module[module._config_callback](module._config)
		elseif (module._config_callback) then
			module:_config_callback(module._config)
		end
		return module
	end
	
end

-- Load all modules
function bdUI:load_modules()
	for k, module in pairs(bdUI.modules) do
	
		if (type(module._config_callback) == "string") then
			module._config_callback = module[module._config_callback]
		end

		module._config = bdUI.config_instance:register_module(module._name, module._config, module._config_callback)

		bdUI:load_module(module._name)
	end
end

bdUI:add_action("loaded", bdUI.load_modules)