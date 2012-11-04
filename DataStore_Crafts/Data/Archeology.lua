local addonName = "DataStore_Crafts"
local addon = _G[addonName]

addon.artifactDB = {}

for i = 1, 12 do
	addon.artifactDB[i] = {}
end

local currentRace = 1

local function AddArtifact(itemID, spellID, rarity, fragments)
	table.insert(addon.artifactDB[currentRace], { itemID = itemID, spellID = spellID, rarity = rarity, fragments = fragments })
end

-- Data taken from Professor, code adjusted for my needs (rarity levels too)
AddArtifact(64489, 91227, 4, 150)  -- Staff of Sorcerer-Thane Thaurissan
AddArtifact(64373, 90553, 3, 100)  -- Chalice of the Mountain Kings
AddArtifact(64372, 90521, 3, 100)  -- Clockwork Gnome
AddArtifact(64488, 91226, 3, 150)  -- The Innkeeper's Daughter

AddArtifact(63113, 88910, 0,  34)  -- Belt Buckle with Anvilmar Crest
AddArtifact(64339, 90411, 0,  35)  -- Bodacious Door Knocker
AddArtifact(63112, 86866, 0,  32)  -- Bone Gaming Dice
AddArtifact(64340, 90412, 0,  34)  -- Boot Heel with Scrollwork
AddArtifact(63409, 86864, 0,  35)  -- Ceramic Funeral Urn
AddArtifact(64362, 90504, 0,  35)  -- Dented Shield of Horuz Killcrow
AddArtifact(66054, 93440, 0,  30)  -- Dwarven Baby Socks
AddArtifact(64342, 90413, 0,  35)  -- Golden Chamber Pot
AddArtifact(64344, 90419, 0,  36)  -- Ironstar's Petrified Shield
AddArtifact(64368, 90518, 0,  35)  -- Mithril Chain of Angerforge
AddArtifact(63414, 89717, 0,  34)  -- Moltenfist's Jeweled Goblet
AddArtifact(64337, 90410, 0,  35)  -- Notched Sword of Tunadil the Redeemer
AddArtifact(63408, 86857, 0,  35)  -- Pewter Drinking Cup
AddArtifact(64659, 91793, 0,  45)  -- Pipe of Franclorn Forgewright
AddArtifact(64487, 91225, 0,  45)  -- Scepter of Bronzebeard
AddArtifact(64367, 90509, 0,  35)  -- Scepter of Charlga Razorflank
AddArtifact(64366, 90506, 0,  35)  -- Scorched Staff of Shadow Priest Anund
AddArtifact(64483, 91219, 0,  45)  -- Silver Kris of Korl
AddArtifact(63411, 88181, 0,  34)  -- Silver Neck Torc
AddArtifact(64371, 90519, 0,  35)  -- Skull Staff of Shadowforge
AddArtifact(64485, 91223, 0,  45)  -- Spiked Gauntlets of Anvilrage
AddArtifact(63410, 88180, 0,  35)  -- Stone Gryphon
AddArtifact(64484, 91221, 0,  45)  -- Warmaul of Burningeye
AddArtifact(64343, 90415, 0,  35)  -- Winged Helm of Corehammer
AddArtifact(63111, 88909, 0,  28)  -- Wooden Whistle
AddArtifact(64486, 91224, 0,  45)  -- Word of Empress Zoe
AddArtifact(63110, 86865, 0,  30)  -- Worn Hunting Knife

currentRace = 2	-- draenei
AddArtifact(64456, 90983, 3, 124)  -- Arrival of the Naaru
AddArtifact(64457, 90984, 3, 130)  -- The Last Relic of Argus

AddArtifact(64440, 90853, 0,  45)  -- Anklet with Golden Bells
AddArtifact(64453, 90968, 0,  46)  -- Baroque Sword Scabbard
AddArtifact(64442, 90860, 0,  45)  -- Carved Harp of Exotic Wood
AddArtifact(64455, 90975, 0,  45)  -- Dignified Portrait
AddArtifact(64454, 90974, 0,  44)  -- Fine Crystal Candelabra
AddArtifact(64458, 90987, 0,  45)  -- Plated Elekk Goad
AddArtifact(64444, 90864, 0,  46)  -- Scepter of the Nathrezim
AddArtifact(64443, 90861, 0,  46)  -- Strange Silver Paperweight


currentRace = 3	-- fossil
AddArtifact(60954, 90619, 4, 100)  -- Fossilized Raptor
AddArtifact(69764, 98533, 4, 150)  -- Extinct Turtle Shell
AddArtifact(60955, 89693, 3,  85)  -- Fossilized Hatchling
AddArtifact(69821, 98582, 3, 120)  -- Pterrodax Hatchling
AddArtifact(69776, 98560, 3, 100)  -- Ancient Amber

AddArtifact(64355, 90452, 0,  35)  -- Ancient Shark Jaws
AddArtifact(63121, 88930, 0,  25)  -- Beautiful Preserved Fern
AddArtifact(63109, 88929, 0,  31)  -- Black Trilobite
AddArtifact(64349, 90432, 0,  35)  -- Devilsaur Tooth
AddArtifact(64385, 90617, 0,  33)  -- Feathered Raptor Arm
AddArtifact(64473, 91132, 0,  45)  -- Imprint of a Kraken Tentacle
AddArtifact(64350, 90433, 0,  35)  -- Insect in Amber
AddArtifact(64468, 91089, 0,  45)  -- Proto-Drake Skeleton
AddArtifact(66056, 93442, 0,  30)  -- Shard of Petrified Wood
AddArtifact(66057, 93443, 0,  35)  -- Strange Velvet Worm
AddArtifact(63527, 89895, 0,  35)  -- Twisted Ammonite Shell
AddArtifact(64387, 90618, 0,  35)  -- Vicious Ancient Fish


currentRace = 4	-- night elf
AddArtifact(64651, 91773, 4, 150)  -- Wisp Amulet
AddArtifact(64645, 91757, 4, 150)  -- Tyrande's Favorite Doll
AddArtifact(64646, 91761, 4, 150)  -- Bones of Transformation
AddArtifact(64643, 90616, 4, 100)  -- Queen Azshara's Dressing Gown
AddArtifact(64361, 90493, 3, 100)  -- Druid and Priest Statue Set
AddArtifact(64358, 90464, 3, 100)  -- Highborne Soul Mirror
AddArtifact(64383, 90614, 3,  98)  -- Kaldorei Wind Chimes

AddArtifact(64647, 91762, 0,  45)  -- Carcanet of the Hundred Magi
AddArtifact(64379, 90610, 0,  34)  -- Chest of Tiny Glass Animals
AddArtifact(63407, 89696, 0,  35)  -- Cloak Clasp with Antlers
AddArtifact(63525, 89893, 0,  35)  -- Coin from Eldre'Thalas
AddArtifact(64381, 90611, 0,  35)  -- Cracked Crystal Vial
AddArtifact(64357, 90458, 0,  35)  -- Delicate Music Box
AddArtifact(63528, 89896, 0,  35)  -- Green Dragon Ring
AddArtifact(64356, 90453, 0,  35)  -- Hairpin of Silver and Malachite
AddArtifact(63129, 89009, 0,  30)  -- Highborne Pyxis
AddArtifact(63130, 89012, 0,  30)  -- Inlaid Ivory Comb
AddArtifact(64354, 90451, 0,  35)  -- Kaldorei Amphora
AddArtifact(66055, 93441, 0,  30)  -- Necklace with Elune Pendant
AddArtifact(63131, 89014, 0,  30)  -- Scandalous Silk Nightgown
AddArtifact(64382, 90612, 0,  35)  -- Scepter of Xavius
AddArtifact(63526, 89894, 0,  35)  -- Shattered Glaive
AddArtifact(64648, 91766, 0,  45)  -- Silver Scroll Case
AddArtifact(64378, 90609, 0,  35)  -- String of Small Pink Pearls
AddArtifact(64650, 91769, 0,  45)  -- Umbra Crescent


currentRace = 5	-- nerubian
AddArtifact(64481, 91214, 4, 140)  -- Blessing of the Old God
AddArtifact(64482, 91215, 4, 140)  -- Puzzle Box of Yogg-Saron

AddArtifact(64479, 91209, 0,  45)  -- Ewer of Jormungar Blood
AddArtifact(64477, 91191, 0,  45)  -- Gruesome Heart Box
AddArtifact(64476, 91188, 0,  45)  -- Infested Ruby Ring
AddArtifact(64475, 91170, 0,  45)  -- Scepter of Nezar'Azret
AddArtifact(64478, 91197, 0,  45)  -- Six-Clawed Cornice
AddArtifact(64474, 91133, 0,  45)  -- Spidery Sundial
AddArtifact(64480, 91211, 0,  45)  -- Vizier's Scrawled Streamer


currentRace = 6	-- orc
AddArtifact(64644, 90843, 4, 130)  -- Headdress of the First Shaman

AddArtifact(64436, 90831, 0,  45)  -- Fiendish Whip
AddArtifact(64421, 90734, 0,  45)  -- Fierce Wolf Figurine
AddArtifact(64418, 90728, 0,  45)  -- Gray Candle Stub
AddArtifact(64417, 90720, 0,  45)  -- Maul of Stone Guard Mur'og
AddArtifact(64419, 90730, 0,  45)  -- Rusted Steak Knife
AddArtifact(64420, 90732, 0,  45)  -- Scepter of Nekros Skullcrusher
AddArtifact(64438, 90833, 0,  45)  -- Skull Drinking Cup
AddArtifact(64437, 90832, 0,  45)  -- Tile of Glazed Clay
AddArtifact(64389, 90622, 0,  45)  -- Tiny Bronze Scorpion


currentRace = 7	-- tol'vir
AddArtifact(60847, 92137, 4, 150)  -- Crawling Claw
AddArtifact(64881, 92145, 4, 150)  -- Pendant of the Scarab Storm
AddArtifact(64904, 92168, 4, 150)  -- Ring of the Boy Emperor
AddArtifact(64883, 92148, 4, 150)  -- Scepter of Azj'Aqir
AddArtifact(64885, 92163, 4, 150)  -- Scimitar of the Sirocco
AddArtifact(64880, 92139, 4, 150)  -- Staff of Ammunae

AddArtifact(64657, 91790, 0,  45)  -- Canopic Jar
AddArtifact(64652, 91775, 0,  45)  -- Castle of Sand
AddArtifact(64653, 91779, 0,  45)  -- Cat Statue with Emerald Eyes
AddArtifact(64656, 91785, 0,  45)  -- Engraved Scimitar Hilt
AddArtifact(64658, 91792, 0,  45)  -- Sketch of a Desert Palace
AddArtifact(64654, 91780, 0,  45)  -- Soapstone Scarab Necklace
AddArtifact(64655, 91782, 0,  45)  -- Tiny Oasis Mosaic


currentRace = 8	-- troll
AddArtifact(64377, 90608, 4, 150)  -- Zin'rokh, Destroyer of Worlds
AddArtifact(69824, 98588, 3, 100)  -- Voodoo Figurine
AddArtifact(69777, 98556, 3, 100)  -- Haunted War Drum

AddArtifact(64348, 90429, 0,  35)  -- Atal'ai Scepter
AddArtifact(64346, 90421, 0,  35)  -- Bracelet of Jade and Coins
AddArtifact(63524, 89891, 0,  35)  -- Cinnabar Bijou
AddArtifact(64375, 90581, 0,  35)  -- Drakkari Sacrificial Knife
AddArtifact(63523, 89890, 0,  35)  -- Eerie Smolderthorn Idol
AddArtifact(63413, 89711, 0,  34)  -- Feathered Gold Earring
AddArtifact(63120, 88907, 0,  30)  -- Fetish of Hir'eek
AddArtifact(66058, 93444, 0,  32)  -- Fine Bloodscalp Dinnerware
AddArtifact(64347, 90423, 0,  35)  -- Gahz'rilla Figurine
AddArtifact(63412, 89701, 0,  35)  -- Jade Asp with Ruby Eyes
AddArtifact(63118, 88908, 0,  32)  -- Lizard Foot Charm
AddArtifact(64345, 90420, 0,  35)  -- Skull-Shaped Planter
AddArtifact(64374, 90558, 0,  35)  -- Tooth with Gold Filling
AddArtifact(63115, 88262, 0,  27)  -- Zandalari Voodoo Doll


currentRace = 9	-- vrykul
AddArtifact(64460, 90997, 4, 130)  -- Nifflevar Bearded Axe
AddArtifact(69775, 98569, 3, 100)  -- Vrykul Drinking Horn

AddArtifact(64464, 91014, 0,  45)  -- Fanged Cloak Pin
AddArtifact(64462, 91012, 0,  45)  -- Flint Striker
AddArtifact(64459, 90988, 0,  45)  -- Intricate Treasure Chest Key
AddArtifact(64461, 91008, 0,  45)  -- Scramseax
AddArtifact(64467, 91084, 0,  45)  -- Thorned Necklace

-- currentRace = 10	-- Other
-- AddArtifact(0, 0, 0,  0)  -- Placeholder

currentRace = 11	-- Pandaren
AddArtifact(89685, 113981, 3, 180)  -- Spear of Xuen
AddArtifact(89684, 113980, 3, 180)  -- Umbrella of Chi-Ji

AddArtifact(79903, 113977, 0,  50)  -- Apothecary Tins
AddArtifact(79901, 113975, 0,  50)  -- Carved Bronze Mirror
AddArtifact(79897, 113971, 0,  50)  -- Panderan Game Board
AddArtifact(79900, 113974, 0,  50)  -- Empty Keg of Brewfather Xin Wo Yin
AddArtifact(79902, 113976, 0,  50)  -- Gold-Inlaid Porecelain Funerary Figurine
AddArtifact(79904, 113978, 0,  50)  -- Pearl of Yu'lon
AddArtifact(79905, 113979, 0,  50)  -- Standard  of Niuzao
AddArtifact(79898, 113972, 0,  50)  -- Twin Stein Set of Brewfather Quan Tou Kuo
AddArtifact(79899, 113973, 0,  50)  -- Walking Cane of Brewfather Ren Yun
AddArtifact(79896, 113968, 0,  50)  -- Pandaren Tea Set


currentRace = 12	-- Mogu
AddArtifact(89614, 113993, 3, 180)  -- Anatomical Dummy
AddArtifact(89611, 113992, 3, 180)  -- Quilen Statuette

AddArtifact(79909, 113983, 0,  50)  -- Cracked Mogu Runestone
AddArtifact(79913, 113987, 0,  50)  -- Edicts of the Thunder King
AddArtifact(79914, 113988, 0,  50)  -- Iron Amulet
AddArtifact(79908, 113982, 0,  50)  -- Manacles of Rebellion
AddArtifact(79916, 113990, 0,  50)  -- Mogu Coin
AddArtifact(79911, 113985, 0,  50)  -- Petrified Bone Whip
AddArtifact(79910, 113984, 0,  50)  -- Terracotta Arm
AddArtifact(79912, 113986, 0,  50)  -- Thunder King Insignia
AddArtifact(79915, 113989, 0,  50)  -- Warlord's Branding Iron
AddArtifact(79917, 113991, 0,  50)  -- Worn Monument Ledger
