local bdUI, c, l = unpack(select(2, ...))

local raidauras = {}
local special = {}

-- general debuffs
raidauras["Ardent Defender"] = true

-- naxx debuffs
raidauras["Necrotic Aura"] = true
raidauras["Fungal Creep"] = true
raidauras["Mortal Wound"] = true
raidauras["Chill"] = true
raidauras["Silence"] = true
raidauras["Mortal Wound"] = true
raidauras["Rain of Fire"] = true
raidauras["Web Wrap"] = true
special["Web Wrap"] = true
raidauras["Mind Control"] = true
special["Mind Control"] = true
raidauras["Flame Tsunami"] = true
special["Flame Tsunami"] = true
raidauras["Icebolt"] = true
raidauras["Frost Blast"] = true
special["Frost Blast"] = true
raidauras["Chains of Kel'Thuzad"] = true
special["Chains of Kel'Thuzad"] = true
raidauras["Tail Lash"] = true


-- lowercase these
raidauras = bdUI:lowercase_table(raidauras)
special = bdUI:lowercase_table(special)

-- merge tables
for k,v in pairs(raidauras) do bdUI.aura_lists.raid[k] = v end
for k,v in pairs(special) do bdUI.aura_lists.special[k] = v end