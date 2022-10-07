local bdUI, c, l = unpack(select(2, ...))

local raidauras = {}
local special = {}



-- lowercase these
raidauras = bdUI:lowercase_table(raidauras)
special = bdUI:lowercase_table(special)

-- merge tables
for k,v in pairs(raidauras) do bdUI.aura_lists.raid[k] = v end
for k,v in pairs(special) do bdUI.aura_lists.special[k] = v end