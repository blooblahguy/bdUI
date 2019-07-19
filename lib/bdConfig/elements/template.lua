local addonName, ns = ...
local mod = ns.bdConfig

--========================================
-- Methods Here
--========================================
local methods = {
	["set"] = function(self, options, save)

	end,
	["get"] = function(self, options, save)

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
	local element = mod:create_container(options, parent)
	Mixin(element, methods)


end

mod:register_element("toggle", create)