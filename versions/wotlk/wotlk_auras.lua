local bdUI, c, l = unpack(select(2, ...))

local raidauras = {}
local special = {}
local auras = {}

-- general debuffs
auras["Ardent Defender"] = true
-- argent crusade
auras["Defend"] = true

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


-- ulduar
raidauras["Pursued"] = true
special["Hodir's Fury"] = true
raidauras["Unquenchable Flames"] = true
raidauras["Flame Buffet"] = true
raidauras["Slag Pot"] = true
raidauras["Flame Jets"] = true
special["Gravity Bomb"] = true
raidauras["Searing Light"] = true
raidauras["Static Disruption"] = true
raidauras["Overwhelming Power"] = true
raidauras["Rune of Death"] = true
special["Fusion Punch"] = true
raidauras["Phase Punch"] = true
raidauras["Black Hole"] = true
raidauras["Stone Grip"] = true
raidauras["Crunch Armor"] = true
raidauras["Feral Pounce"] = true
raidauras["Rip Flesh"] = true
raidauras["Freeze"] = true
raidauras["Biting Cold"] = true
raidauras["Unbalancing Strike"] = true
raidauras["Low Blow"] = true
raidauras["Frost Nova"] = true
raidauras["Unstable Energy"] = true
special["Nature's Fury"] = true
raidauras["Iron Roots"] = true
raidauras["Napalm Shell"] = true
special["Plasma Blast"] = true
raidauras["Shadow Crash"] = true
raidauras["Mark of the Faceless"] = true
raidauras["Searing Flames"] = true
raidauras["Brain Link"] = true
special["Sara's Fervor"] = true
special["Squeeze"] = true
raidauras["Draining Poison"] = true
raidauras["Black Plague"] = true
raidauras["Sara's Blessing"] = true
raidauras["Apathy"] = true
raidauras["Black Plague"] = true
special["Malady of the Mind"] = true
special["Dominate Mind"] = true
special["Curse of Doom"] = true

-- togc
special["Paralytic Toxin"] = true
special["Burning Bile"] = true
special["Penetrating Cold"] = true
special["Legion Flame"] = true
special["Incinerate Flesh"] = true
special["Fel Fireball"] = true
special["Pursued by Anub'arak"] = true
special["Touch of Light"] = true
special["Touch of Darkness"] = true
raidauras["Impale"] = true
raidauras["Ferocious Butt"] = true
raidauras["Arctic Breath"] = true
raidauras["Touch of Jaraxxus"] = true
raidauras["Legion Flame"] = true
raidauras["Empowered Darkness"] = true
raidauras["Empowered Light"] = true
raidauras["Permafrost"] = true
raidauras["Expose Weakness"] = true
raidauras["Acid-Drenched Mandibles"] = true
raidauras["Freezing Slash"] = true

-- ICC
raidauras["Impaled"] = true
raidauras["Touch of Insignificance"] = true
raidauras["Death and Decay"] = true
special["Dominate Mind"] = true
raidauras["Rending Throw"] = true
raidauras["Wounding Strike"] = true
raidauras["Rune of Blood"] = true
raidauras["Boiling Blood"] = true
special["Mark of the Fallen Champion"] = true
special["Gas Spore"] = true
raidauras["Gastric Bloat"] = true
raidauras["Inoculated"] = true
raidauras["Vile Gas"] = true
special["Mutated Infection"] = true
raidauras["Plague Sickness"] = true
raidauras["Unbound Plague"] = true
raidauras["Gas Variable"] = true
raidauras["Ooze Variable"] = true
special["Volatile Ooze Adhesive"] = true
raidauras["Shadow Prison"] = true
raidauras["Shadow Resonance"] = true
raidauras["Delirious Slash"] = true
special["Pact of the Darkfallen"] = true
raidauras["Blood Mirror"] = true
raidauras["Twisted Nightmares"] = true
raidauras["Chilled to the Bone"] = true
raidauras["Unchained Magic"] = true
raidauras["Instability"] = true
raidauras["Ice Tomb"] = true
raidauras["Asphyxiation"] = true
raidauras["Mystic Buffet"] = true
special["Frost Beacon"] = true
raidauras["Soul Shriek"] = true
special["Infest"] = true
special["Defile"] = true
raidauras["Soul Reaper"] = true


-- lowercase these
raidauras = bdUI:lowercase_table(raidauras)
special = bdUI:lowercase_table(special)

-- merge tables
for k,v in pairs(raidauras) do bdUI.aura_lists.raid[k] = v end
for k,v in pairs(special) do bdUI.aura_lists.special[k] = v end
for k,v in pairs(auras) do bdUI.aura_lists.whitelist[k] = v end