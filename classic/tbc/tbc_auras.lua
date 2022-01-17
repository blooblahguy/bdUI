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
special["Flamestrike"] = true
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
raidauras["Persuasion"] = true
special["Persuasion"] = true
raidauras["Paralyze"] = true
special["Paralyze"] = true
special["Toxic Spores"] = true

-- Hyjal
raidauras["Death and Decay"] = true
special["Death and Decay"] = true
raidauras["Icebolt"] = true
special["Icebolt"] = true
raidauras["Frost Nova"] = true

raidauras["Carrion Swarm"] = true
raidauras["Sleep"] = true
raidauras["Inferno"] = true

raidauras["Mark of Kaz'rogal"] = true
special["Mark of Kaz'rogal"] = true

raidauras["Rain of Fire"] = true
raidauras["Howl of Azgalor"] = true
raidauras["Doom"] = true

raidauras["Air Burst"] = true
raidauras["Tears of the Goddess"] = true
raidauras["Doomfire"] = true
raidauras["Fear"] = true
raidauras["Grip of the Legion"] = true
raidauras["Soul Charge"] = true

-- BT
raidauras["Vile Slime"] = true
raidauras["Sludge Nova"] = true

raidauras["Impaling Spine"] = true
special["Impaling Spine"] = true

raidauras["Molten Flame"] = true
raidauras["Volcanic Geyser"] = true
special["Fixate"] = true

raidauras["Shadow of Death"] = true
special["Shadow of Death"] = true
raidauras["Incinerate"] = true
special["Incinerate"] = true

raidauras["Soul Drain"] = true
special["Soul Drain"] = true
raidauras["Deaden"] = true
special["Deaden"] = true
raidauras["Seathe"] = true
raidauras["Spite"] = true
special["Spite"] = true

raidauras["Bloodboil"] = true
raidauras["Bewildering Strike"] = true
raidauras["Fel Rage"] = true
special["Fel Rage"] = true
raidauras["Fel-Acid Breath"] = true

raidauras["Fatal Attraction"] = true

raidauras["Flamestrike"] = true
raidauras["Blizzard"] = true
raidauras["Consecration"] = true
raidauras["Judgement of Blood"] = true
raidauras["Envenom"] = true
special["Envenom"] = true

raidauras["Draw Soul"] = true
raidauras["Shear"] = true
special["Shear"] = true
raidauras["Flame Crash"] = true
raidauras["Parasitic Shadowfiend"] = true
raidauras["Blaze"] = true
raidauras["Dark Barrage"] = true
special["Dark Barrage"] = true
special["Agonizing Flames"] = true
special["Aura of Dread"] = true

-- merge tables
for k,v in pairs(raidauras) do bdUI.aura_lists.raid[k] = v end
for k,v in pairs(special) do bdUI.aura_lists.special[k] = v end