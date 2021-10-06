local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Smart Bags (beta)")

function mod:create_bags()
	mod.regeant = mod:create_container("Reagents")
	mod.regeant.item_pool = CreateObjectPool(mod.item_pool_create, mod.item_pool_reset)

end