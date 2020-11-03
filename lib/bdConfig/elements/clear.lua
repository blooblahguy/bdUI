local parent, ns = ...
local lib = ns.bdConfig

--========================================
-- Spawn Element
--========================================
local function create(options, parent)
	options.size = "full"
	local container = lib:create_container(options, parent)
	container:SetHeight(1)	

	return container
end

lib:register_element("clear", create)