--===============================================
-- FUNCTIONS
--===============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Auras")

mod.auras = {}

--===============================================
-- Core functionality
-- place core functionality here
--===============================================
function mod:initialize()
	mod.config = mod:get_save()

	mod:lowercase_auras()
end

function mod:config_callback()
	mod.config = mod:get_save()
	bdUI.caches.auras = {}

	mod:lowercase_auras()
end

function mod:lowercase_auras()
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

	mod.auras.class = {}
	for class, spells in pairs(mod.config.class) do
		mod.auras.class[class] = {}

		for spell, v in pairs(spells) do
			mod.auras.class[class][string.lower(spell)] = true
		end
	end
end