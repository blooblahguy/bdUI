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
	bdUI[name] = bdUI[name] or CreateFrame("frame", name, bdParent)

	local module = {}
	module.name = name
	module.config = config
	module.config_callback = callback or noop	

	table.insert(bdUI.modules, module)

	return bdUI[name]
end

-- Load specific modules
function bdUI:get_module(name)
	return bdUI[name]
end

function bdUI:load_module(name)
	for k, module in pairs(bdUI.modules) do
		if (module.name == name) then
			if (not module.initialize) then
				bdUI:debug(module.name, "does not have an initialize() function and can't be loaded")
				return
			end

			module:initialize()
			module:config_callback()
			
			return
		end
	end
end

-- Load all modules
function bdUI:load_modules()
	for k, module in pairs(bdUI.modules) do
		bdUI[module.name].config = bdUI.config_instance:register_module(module.name, module.config)

		bdUI:load_module(module.name)
	end
end

bdUI:add_action("loaded", bdUI.load_modules)