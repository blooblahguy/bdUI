local bdUI, c, l = unpack(select(2, ...))

local raidauras = {}
local special = {}

-- Kara
raidauras["Knockdown"] = true
raidauras["Brittle Bones"] = true
raidauras["Drunken Skull Crack"] = true
raidauras["Seduction"] = true
raidauras["Banshee Shriek"] = true
raidauras["Ice Tomb"] = true
raidauras["Bad Poetry"] = true
raidauras["Disarm"] = true

raidauras["Intangible Presence"] = true
raidauras["Gouge"] = true
raidauras["Blind"] = true
raidauras["Garrote"] = true
raidauras["Hammer of Justice"] = true
raidauras["Mortal Strike"] = true
raidauras["Repentance"] = true

raidauras["Terrifying Howl"] = true
raidauras["Powerful Attraction"] = true
raidauras["Frightened Scream"] = true
raidauras["Brain Wipe"] = true
raidauras["Brain Bash"] = true

raidauras["Sacrifice"] = true

raidauras["Counterspell"] = true
raidauras["Dragon's Breath"] = true
raidauras["Flame Wreath"] = true

raidauras["Nether Portal - Perseverence"] = true
raidauras["Nether Portal - Dominance"] = true
raidauras["Nether Portal - Serenity"] = true

raidauras["Enfeeble"] = true
raidauras["Sunder Armor"] = true
raidauras["Amplify Damage"] = true
special["Amplify Damage"] = true

raidauras["Distracting Ash"] = true
raidauras["Charred Earth"] = true
raidauras["Bellowing Roar"] = true

-- Gruul
raidauras["Death Coil"] = true
raidauras["Blast Wave"] = true
special["Blast Wave"] = true
raidauras["Intimidating Roar"] = true

raidauras["Reverberation"] = true
raidauras["Cave In"] = true

-- Mag
raidauras["Fear"] = true
raidauras["Conflagaration"] = true
raidauras["Debris"] = true
raidauras["Mind Exhaustion"] = true

-- TK
raidauras["Flame Buffet"] = true
raidauras["Flame Patch"] = true
special["Flame Patch"] = true

raidauras["Melt Armor"] = true
special["Melt Armor"] = true

raidauras["Wrath of the Astromancer"] = true

raidauras["Conflagaration"] = true
raidauras["Silence"] = true
raidauras["Remote Toy"] = true
raidauras["Flamestrike"] = true
sepcial["Flamestrike"] = true
raidauras["Nether Vapor"] = true

-- SSC
raidauras["Atrophic Blow"] = true
raidauras["Initial Infection"] = true
special["Initial Infection"] = true
raidauras["Sepentshrine Parasite"] = true

raidauras["Water Tomb"] = true
raidauras["Vile Sludge"] = true
special["Vile Sludge"] = true

raidauras["Chaos Blast"] = true
raidauras["Inner Demon"] = true
raidauras["Insidious Whisper"] = true
raidauras["Whirlwind"] = true

raidauras["Watery Grave"] = true
special["Watery Grave"] = true

raidauras["Static Charge"] = true
raidauras["Entangle"] = true
raidauras["Persuasion"] = true
raidauras["Howl of Terror"] = true
special["Persuasion"] = true
raidauras["Paralyze"] = true
special["Paralyze"] = true

-- Hyjal

-- BT

-- merge tables
for k,v in pairs(raidauras) do bdUI.aura_lists.raid[k] = v end
for k,v in pairs(special) do bdUI.aura_lists.special[k] = v end