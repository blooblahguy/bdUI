local addonName, ns = ...
local mod = ns.bdConfig

--========================================
-- Spawn Element
--========================================
local function create(options, parent)
	options.size = "full"
	local container = mod:create_container(options, parent)
	container:SetHeight(1)	

	return container
end

mod:register_element("clear", create)