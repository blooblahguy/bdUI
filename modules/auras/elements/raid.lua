local bdUI, c, l = unpack(select(2, ...))
bdUI.aura_lists = bdUI.aura_lists or {}

local auras = {
	['Grievous Wound'] = true,

	----------------------------------------------------
	-- Emerald Nightmare
	----------------------------------------------------
	-- Nythendra
	['Infested Ground'] = true,
	['Volatile Rot'] = true,
	['Rot'] = true,
	['Burst of Corruption'] = true,
	['Infested Breath'] = true,
	
	-- Illgynoth
	['Spew Corruption'] = true,
	['Eye of Fate'] = true,
	['Cursed Blood'] = true,
	['Death Blossom'] = true,
	['Dispersed Spores'] = true,
	['Touch of Corruption'] = true,
	
	-- Renferal
	['Web of Pain'] = true,
	['Necrotic Venom'] = true,
	['Dripping Fangs'] = true,
	['Raking Talons'] = true,
	['Twisting Shadows'] = true,
	['Web of Pain'] = true,
	['Tangled Webs'] = true,
	
	-- Ursoc
	['Focused Gaze'] = true,
	['Overwhelm'] = true,
	['Rend Flesh'] = true,
	
	-- Dragons
	['Nightmare Bloom'] = true,
	['Slumbering Nightmare'] = true,
	['Defiled Vines'] = true,
	['Sleeping Fog'] = true,
	['Shadow Burst'] = true,
	
	-- Cenarius
	['Nightmare Javelin'] = true,
	['Scorned Touch'] = true,
	['Spear of Nightmares'] = true,
	['Nightmare Brambles'] = true,
	
	-- Xavius
	['Dream Simulacrum'] = true,
	['Blackening Soul'] = true,	
	['Darkening Soul'] = true,	
	['Tainted Discharge'] = true,	
	['Corruption: Decent into Madness'] = true,	
	['Bonds of Terror'] = true,	
	['Tormenting Fixation'] = true,	
	
	-- trash
	['Befoulment'] = true,
	
	----------------------------------------------------
	-- Trial of Valor
	----------------------------------------------------
	-- Odyn
	['Shield of Light'] = true,
	['Arcing Storm'] = true,
	['Expel Light'] = true,
	
	-- Guarm
	['Frost Lick'] = true,
	['Flame Lick'] = true,
	['Shadow Lick'] = true,
	
	['Flaming Volatile Foam'] = true,
	['Briney Volatile Foam'] = true,
	['Shadowy Volatile Foam'] = true,
	
	-- Helya
	['Orb of Corruption'] = true,
	['Orb of Corrosion'] = true,
	['Taint of the Sea'] = true,
	['Fetid Rot'] = true,
	['Corrupted Axiom'] = true,
	
	-- trash
	['Unholy Reckoning'] = true,
	
	----------------------------------------------------
	-- Nighthold
	----------------------------------------------------
	-- Skorpyron
	['Energy Surge'] = true,
	['Broken Shard'] = true,
	['Focused Blast'] = true,
	
	-- Chromatic Anomaly
	['Time Bomb'] = true,
	['Temporal Charge'] = true,
	['Time Release'] = true,
	
	-- Trilliax
	['Arcing Bonds'] = true,
	['Sterilize'] = true,
	['Annihilation'] = true,
	
	-- Aluriel
	["Frostbitten"] = true,
	["Annihilated"] = true,
	["Searing Brand"] = true,
	["Entombed in Ice"] = true,
	["Mark of Frost"] = true,
	
	-- Tichondrius
	['Carrion Plague'] = true,
	['Feast of Blood'] = true,
	['Essence of Night'] = true,
	
	-- Krosus
	['Orb of Destruction'] = true,
	['Searing Brand'] = true,
	
	-- Botanist
	['Parasitic Fixate'] = true,
	['Parasitic Fetter'] = true,
	['Toxic Spores'] = true,
	['Call of Night'] = true,
	
	-- Augor
	['Icy Ejection'] = true,
	['Chilled'] = true,
	['Voidburst'] = true,
	['Gravitational Pull'] = true,
	['Witness the Void'] = true,
	['Absolute Zero'] = true,
	['Felflame'] = true,
	
	-- Elisande
	['Ablation'] = true,
	['Arcanetic Ring'] = true,
	['Spanning Singularity'] = true,
	['Delphuric Beam'] = true,
	['Permeliative Torment'] = true,
	
	-- Gul'dan
	['Drain'] = true,
	['Fel Efflux'] = true,
	['Soul Sever'] = true,
	['Chaos Seed'] = true,
	['Bonds of Fel'] = true,
	['Soul Siphon'] = true,
	['Flames of Sargeras'] = true,
	['Soul Corrosion'] = true,
	["Eye of Gul'dan"] = true,
	["Empowered Eye of Gul'dan"] = true,
	["Empowered Bonds of Fel"] = true,
	["Bonds of Fel"] = true,
	["Parasitic Wound"] = true,
	["Chaos Seed"] = true,
	["Severed Soul"] = true,
	["Severed"] = true,
	["Time Stop"] = true,
	["Scattering Field"] = true,
	["Shadowy Gaze"] = true,
	
	-- Trash
	['Arcanic Release'] = true,
	['Necrotic Strike'] = true,
	['Surpress'] = true,
	['Sanguine Ichor'] = true,
	['Thunderstrike'] = true,
	['Will of the Legion'] = true,
	
	
	----------------------------------------------------
	-- Tomb of Sargeras
	----------------------------------------------------
	-- Gorth
	['Melted Armor'] = true,
	['Burning Armor'] = true,
	['Crashing Comet'] = true,
	['Fel Pool'] = true,
	['Shattering Star'] = true,
	
	-- Demonic Inquisition
	['Suffocating Dark'] = true,
	['Calcified Quills'] = true,
	['Unbearable Torment'] = true,
	
	-- Harjatan
	['Jagged Abrasion'] = true,
	['Aqueous Burst'] = true,
	['Drenching Waters'] = true,
	['Driven Assault'] = true,
	
	-- Sisters of the Moon
	['Moon Burn'] = true,
	['Twilight Volley'] = true,
	['Twilight Glaive'] = true,
	['Incorporeal Shot'] = true,
	
	-- Mistress Sassz'ine
	['Consuming Hunger'] = true,
	['Delicious Bufferfish'] = true,
	['Slicing Tornado'] = true,
	['Hydra Shot'] = true,
	['Slippery'] = true,
	
	-- Desolate Host
	["Soul Bind"] = true,
	["Spirit Chains"] = true,
	["Soul Rot"] = true,
	["Spear of Anguish"] = true,
	["Shattering Scream"] = true,
	
	-- Maiden of Vigilance
	['Unstable Soul'] = true,
	
	-- Fallen Avatar
	['Tainted Essence'] = true,
	['Black Winds'] = true,
	['Dark Mark'] = true,
	
	-- Kil'jaedan
	['Felclaws'] = true,
	['Shadow Reflection: Erupting'] = true,
	['Shadow Reflection: Wailing'] = true,
	['Shadow Reflection: Hopeless'] = true,
	['Armageddon Rain'] = true,
	['Lingering Eruption'] = true,
	['Lingering Wail'] = true,
	['Soul Anguish'] = true,
	['Focused Dreadflame'] = true,


	----------------------------------
	--	Antorus the Burning Throne
	----------------------------------
	-- Garothi
	["Fel Bombardment"] = true,
	["Haywire Decimation"] = true,
	["Decimation"] = true,

	-- Felhounds
	["Smouldering"] = true,
	["Siphoned"] = true,
	["Enflamed"] = true,
	["Singed"] = true,
	["Weight of Darkness"] = true,
	["Desolate Gaze"] = true,
	["Burning Remnant"] = true,
	["Molten Touch"] = true,
	["Consuming Sphere"] = true,

	-- High Command
	["Exploit Weakness"] = true,
	["Psychic Scarring"] = true,
	["Psychic Assault"] = true,
	["Shocked"] = true,
	["Shock Grenade"] = true,

	-- Portal Keeper
	["Reality Tear"] = true,
	["Cloying Shadows"] = true,
	["Caustic Slime"] = true,
	["Everburning Flames"] = true,
	["Fiery Detonation"] = true,
	["Mind Fog"] = true,
	["Flames of Xoroth"] = true,
	["Acidic Web"] = true,
	["Delusions"] = true,
	["Hungering Gloom"] = true,
	["Felsilk Wrap"] = true,

	-- Eonar
	["Feedback - Arcane Singularity"] = true,
	["Feedback - Targeted"] = true,
	["Feedback - Burning Embers"] = true,
	["Feedback - Foul Steps"] = true,
	["Fel Wake"] = true,
	["Rain of Fel"] = true,

	-- Imonar
	["Sever"] = true,
	["Charged Blasts"] = true,
	["Empowered Pulse Grenade"] = true,
	["Shrapnel Blast"] = true,
	["Shock Lance"] = true,
	["Empowered Shock Lance"] = true,
	["Shocked"] = true,
	["Conflagration"] = true,
	["Slumber Gas"] = true,
	["Sleep Canister"] = true,
	["Seared Skin"] = true,
	["Infernal Rockets"] = true,

	-- Kin'gorath
	["Forging Strike"] = true,
	["Ruiner"] = true,
	["Purging Protocol"] = true,

	-- Varimathras
	["Misery"] = true,
	["Echoes of Doom"] = true,
	["Necrotic Embrace"] = true,
	["Dark Fissure"] = true,
	["Marked Prey"] = true,

	-- Coven
	["Fiery Strike"] = true,
	["Flashfreeze"] = true,
	["Fury of Golganneth"] = true,
	["Fulminating Pulse"] = true,
	["Chilled Blood"] = true,
	["Cosmic Glare"] = true,
	["Spectral Army of Norgannon"] = true,
	["Whirling Saber"] = true,

	-- Aggramar
	["Taeshalach's Reach"] = true,
	["Empowered Flame Rend"] = true,
	["Foe Breaker"] = true,
	["Ravenous Blaze"] = true,
	["Wake of Flame"] = true,
	["Blazing Eruption"] = true,
	["Scorching Blaze"] = true,
	["Molten Remnants"] = true,

	-- Argus
	["Sweeping Scythe"] = true,
	["Avatar of Aggramar"] = true,
	["Soulburst"] = true,
	["Soulbomb"] = true,
	["Death Fog"] = true,
	["Soulblight"] = true,
	["Cosmic Ray"] = true,
	["Edge of Obliteration"] = true,
	["Gift of the Sea"] = true,
	["Gift of the Sky"] = true,
	["Cosmic Beacon"] = true,
	["Cosmic Smash"] = true,
	["Ember of Rage"] = true,
	["Deadly Scythe"] = true,
	["Sargeras' Rage"] = true,
	["Sargeras' Fear"] = true,
	["Unleashed Rage"] = true,
	["Crushing Fear"] = true,
	["Sentence of Sargeras"] = true,
	["Shattered Bonds"] = true,
	["Soul Detonation"] = true,



	------------------------------------------
	-- Uldir
	------------------------------------------
	-- Taloc
	["Plasma Dischard"] = true,
	["Blood Storm"] = true,
	["Hardened Arteries"] = true,
	["Enlarged Heart"] = true,
	["Uldir Defense Beam"] = true,

	-- Mother
	['Clinging Corruption'] = true,
	['Bacterial Outbreak'] = true,
	['Endemic Virus'] = true,
	['Spreading Epidemic'] = true,
	['Cleansing Purge'] = true,
	['Sanitizing Strike'] = true,
	['Purifying Flames'] = true,

	-- Fetic Devourer
	['Maldorous Miasma'] = true,
	['Putrid Paroxysm'] = true,

	-- Zek'voz
	['Titan Spark'] = true,
	['Void Lash'] = true,
	['Shatter'] = true,
	['Jagged Mandible'] = true,
	['Roiling Deceit'] = true,
	["Corruptor's Pact"] = true,
	['Will of the Corruptor'] = true,
	['Void Wail'] = true,
	['Psionic Blast'] = true,

	-- Vectis
	['Omega Vector'] = true,
	['Lingering Infection'] = true,
	['Bursting Legions'] = true,
	['Evolving Affliction'] = true,
	['Gestate'] = true,
	['Immunosuppression'] = true,
	['Plague Bomb'] = true,

	-- Zul
	['Absorbed in Darkness'] = true,
	['Corrupted Blood'] = true,
	['Unleashed Shadow'] = true,
	['Bound by Shadow'] = true,
	['Pit of Despair'] = true,
	['Engorged Burst'] = true,
	['Rupturing Blood'] = true,
	['Corrupted Blood'] = true,
	['Death Wish'] = true,

	-- Mythrax
	["Annihilation"] = true,
	["Essence Shear"] = true,
	["Obilivion Sphere"] = true,
	["Imminent Ruin"] = true,
	["Oblivion Veil"] = true,
	["Obliteration Beam"] = true,
	["Mind Flay"] = true,

	-- Ghuun
	["Blood Host"] = true,
	["Explosive Corruption"] = true,
	["Blighted Ground"] = true,
	["Torment"] = true,
	["Decaying Eruption"] = true,
	["Power Matrix"] = true,
	["Imperfect Physiology"] = true,
	["Matrix Surge"] = true,
	["Reorigination Blast"] = true,
	["Undulating Mass"] = true,
	["Tendrils of Corruption"] = true,
	["Unclean Contagion"] = true,
	["Growing Corruption"] = true,
	["Putrid Blood"] = true,
	["Blood Feast"] = true,
	["Gaze of G'Huun"] = true,

	-- BFA DUNGEONS
	["Stinging Venom"] = true,
	["Slicing Blast"] = true,
	["Deadeye"] = true,
	["Plague Step"] = true,
	["Jagged Nettles"] = true,
	["Iced Spritzer"] = true,
	["Neurotoxin"] = true,
	["Embalming Fluid"] = true,
	["Blood Maw"] = true,
	["Tainted Blood"] = true,
	["Cursed Slash"] = true,
	["Carve Flesh"] = true,
	["Incendiary Rounds"] = true,
	["Rat Traps"] = true,
	["Soul Thorns"] = true,
	["Brain Freeze"] = true,
	["Heart Attack"] = true,
	["Severing Blade"] = true,
	["Savage Cleave"] = true,
	["Venomfang Strike"] = true,
	["Crushing Slam"] = true,
	["Unending Darkness"] = true,
	["Massive Chomp"] = true,
	["Infected Wound"] = true,
	["Death Lens"] = true,
	["Rock Lance"] = true,
	["Snake Charm"] = true,
	["Suppression Slam"] = true,
	["Thirst For Blood"] = true,
	["Serrated Teeth"] = true,
	["Putrid Waters"] = true,
	["Rip Mind"] = true,
	["Itchy Bite"] = true,
	["Scabrous Bite"] = true,
	["Jagged Cut"] = true,
	["Blinding Sand"] = true,
	["Axe Barrage"] = true,
	["Serrated Fangs"] = true,
	["Abyssal Strike"] = true,
	["Sand Trap"] = true,
	["A Knot of Snakes"] = true,
	["Drain Fluids"] = true,
	["Putrid Blood"] = true,
	["Vicious Mauling"] = true,
	["Galvanize"] = true,
	["Dessication"] = true,
	["Explosive Burst"] = true,
	["Plague"] = true,
	["Shattered Defenses"] = true,
	
-- Battle for Dazar'alor,
	-- Grong,
	["Apetagonizer Core"] = 1,
	["Rending Bite"] = 1,
	["Bestial Throw Target"] = 2,

	--Jadefire,
	["Searing Embers"] = 2,
	["Rising Flames"] = 1,

	--Opulence,
	["Liquid Gold"] = 1,
	["Thief's bane"] = 1,
	-- Your designated gem (de)buff,
	["Volatile Charge"] = 1,
	["Hex of Lethargy"] = 2,

	--Conclave,
	["Bwomsamdi Curse"] = 1,
	["Kimbul Targeting Debuff"] = 1,
	["Mind Wipe"] = 2,
	["Crawling Hex"] = 1,
	["Lacerating Claws"] = 1,
	
	--Rastakhan,
	["Grievous Axe"] = 2,
	["Caress of Death"] = 1,
	["Scorching Detonation"] = 1,
	["Toad Toxin"] = 1,
	["Death's door"] = 1,

	--Mekkatorque,
	["Discombobulation"] = 1,
	["Gigavolt Blast"] = 1,
	["Gigavolt Charge"] = 1,
	["Buster Cannon "] = 1,
	["Gigavolt Radiation"] = 1,
	["Sheep Shrapnel"] = 1,

	--Blockade,
	["Tempting Song"] = 1,
	["Storm's Wail"] = 1,
	["Kelp-Wrapped"] = 1,

	--Jaina,
	["Broadside"] = 1,
	["Siegebreaker Blast"] = 1,


-- Battle for Dazar'alor,
	-- Wrathion
	['Incineration'] = true,
	['Scorching Blister'] = true,
	['Burning Madness'] = true,

	-- Maut
	['Shadow Wounds'] = true,
	['Devoured Abyss'] = true,
	['Devour Magic'] = true,
	['Drain Essence'] = true,

	-- Skitra
	['Shadow Shock'] = true,
	['Shred Psyche'] = true,

	-- Xanesh
	['Abyssal Strike'] = true,
	['Voidwoken'] = true,

	-- Hivemind
	['Acid Pool'] = true,
	['Nullification'] = true,
	['Corrosion'] = true,

	-- Shadhar
	['Disolve'] = true,
	['Debilitating Spit'] = true,
	['Entropic Breath'] = true,
	['Umbral Breath'] = true,

	-- Drestagath
	['Volatile Vulnerability'] = true,
	['Unleashed Insanity'] = true,
	['Void Glare'] = true,

	-- Ilgynoth
	['Recurring Nightmare'] = true,
	['Cursed Blood'] = true,
	['Touch of the Corruptor'] = true,

	-- Vexiona
	['Annihilation'] = true,
	['Terrifying Presence'] = true,
	['Twilight Decimator'] = true,

	-- Raden
	['Unstable Vita'] = true,
	['Unleashed Void'] = true,
	['Charged Bonds'] = true,
	['Nullifying Strike'] = true,

	-- Carapace
	['Mental Decay'] = true,
	['Nightmare Antibody'] = true,
	['Madness Bomb'] = true,
	["Gift of N'Zoth"] = true,
	["Servant of N'Zoth"] = true,
	["Mycelial Growth"] = true,
	["Insanity Bomb"] = true,
	["Breed Madness"] = true,

	-- Nzoth
	["Mindwrack"] = true,
	["Paranoia"] = true,
	["Anguish"] = true,
	["Evoke Anguish"] = true,
	["Corrupted Mind"] = true,

-- Shadowlands
	-- Castle

	-- Shriekwing
	["Exsanguinated"] = true,
	["Dark Descent"] = true,
	["Reverbating Pain"] = true,
	["Snaguine Ichor"] = true,
	["Echo Screech"] = true,
	["Dark Sonar"] = true,

	-- Huntsman Altimor
	["Sinseeker"] = true,
	["Vicious Wound"] = true,
	["Jagged Claws"] = true,
	["Deathly Roar"] = true,
	["Petrifying Howl"] = true,
	["Stone Shards"] = true,
	
	-- Hungering Destroyer
	['Gluttonous Miasma'] = true,
	['Volatile Injection'] = true,

	-- Sun King's Salvation
	["Smoldering Remnants"] = true,
	["Burning Remnants"] = true,
	["Ember Blast"] = true,
	["Lingering Embers"] = true,
	["Smoldering Plumage"] = true,
	["Vanquished"] = true,
	["Crimson Flurry"] = true,
	["Vulgar Brand"] = true,
	["Infuser's Boon"] = true,
	["Soul Infusion"] = true,
	["Greater Castigation"] = true,

	-- Artificer Xy'mox
	['Dimensional Tear'] = true,
	['Glyph of Destruction'] = true,
	['Arcane Vulnerability'] = true,
	['Statis Trap'] = true,
	['Statis Trap'] = true,
	['Possession'] = true,
	['Withering Touch'] = true,
	
	-- Lady Inerva Darkvein
	['Anima Release'] = true,
	['Warped Desires'] = true,
	['Lingering Anima'] = true,
	['Shared Suffering'] = true,
	['Ideminfication'] = true,
	['Anima Web'] = true,
	['Concentrated Anima'] = true,
	['Rooted in Anima'] = true,
	['Unconcionable Guilt'] = true,
	
	-- The council of Blood
	["Duelist's Riposte"] = true,
	["Drain Essence"] = true,
	["Dreadbolt Volley"] = true,
	["Soul Spikes"] = true,
	["Evasive Lunge"] = true,
	["Dark Recital"] = true,
	["Waltz of Blood"] = true,
	["Wrong Moves"] = true,
	
	
	-- Sludgefist
	["Shattering Chain"] = true,
	["Falling Rubble"] = true,
	["Stonequake"] = true,
	
	-- Stone Legion Generals
	["Wicked Laceration"] = true,
	["Stone Shatter"] = true,
	["Unstable Ground"] = true,
	["Curse of Petrification"] = true,
	["Stone Breaker's Combo"] = true,
	["Breath of Corruption"] = true,
	
	-- Sire Denathrius
	["Burden of Sin"] = true,
	["Cleansing of Pain"] = true,
	["Feeding Time"] = true,
	["Desolation"] = true,
	["Carnage"] = true,
	["Impale"] = true,
	["Wracking Pain"] = true,
	["Indignation"] = true,
	["Scorn"] = true,
	["Fatal Finesse"] = true,
}

bdUI.aura_lists.raid = auras