local bdUI, c, l = unpack(select(2, ...))

--================================================
-- Mod should have
---- mod:initialize()
---- mod:config_callback()
-- Upon savedvariables load?
--================================================

--================================================
-- Allows for modules to be registered and 
-- automatically loaded / disabled as needed
bdUI.modules = {}
--================================================
function bdUI:register_module(name, config, options)
	if (name == "Name") then return {} end
	if (bdUI[name]) then
		bdUI:debug('"', name, '"', "already exists as a module. Use unique names for new modules")
		return
	end

	local bdConfig = bdUI.bdConfig
	options = options or {}

	-- register module frame with bdConfig
	bdUI[name] = bdConfig:register_module(name, config, "config_callback", options)
	local module = bdUI[name]
	module._elements = {}

	bdUI.modules[name] = module

	return module
end

-- Load specific modules
function bdUI:get_module(name)
	return bdUI[name]
end

function bdUI:load_module(module)
	-- require initialize function
	if (not module.initialize) then
		bdUI:debug(module._name, "does not have an initialize() function and can't be loaded")
		return
	end

	-- load SVs and build module now
	local save = module:load()

	-- initalize and callback
	if (module:initialize() ~= false) then
		-- run callback
		-- module:callback()
		return module
	end

	-- run the element registry

end

-- Load all modules
function bdUI:load_modules()
	for k, module in pairs(bdUI.modules) do
		bdUI:load_module(module)
	end
end

bdUI:add_action("loaded", bdUI.load_modules, 1)