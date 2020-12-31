--===============================================
-- FUNCTIONS
--===============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Auras")

mod.auras = {}
local class = select(2, UnitClass("player"))

--===============================================
-- Core functionality
-- place core functionality here
--===============================================
function mod:initialize()
	mod.config = mod:get_save()

	mod:store_lowercase_auras()
end

function mod:config_callback()
	mod.config = mod:get_save()
	bdUI.caches.auras = {}

	mod:store_lowercase_auras()
end

function mod:store_lowercase_auras()
	mod.config = mod:get_save()

	local auras = {
		['blacklist'] = mod.config.blacklist,
		['whitelist'] = mod.config.whitelist,
		['mine'] = mod.config.mine,
	}

	for category, spells in pairs(auras) do
		mod.auras[category] = {}

		for spell, v in pairs(spells) do
			mod.auras[category][string.lower(spell)] = true
		end
	end

	mod.auras[class] = {}
	for spell, v in pairs(mod.config[class]) do

		-- print(k, spells)
		mod.auras[class][string.lower(spell)] = true

		-- for spell, v in pairs(spells) do
		-- end
	end
end