--[[
	Enchantrix Addon for World of Warcraft(tm).
	Version: 5.15.5365 (LikeableLyrebird)
	Revision: $Id: EnxConstants.lua 5363 2012-09-24 02:36:04Z ccox $
	URL: http://enchantrix.org/

	Enchantrix Constants.

	License:
		This program is free software; you can redistribute it and/or
		modify it under the terms of the GNU General Public License
		as published by the Free Software Foundation; either version 2
		of the License, or (at your option) any later version.

		This program is distributed in the hope that it will be useful,
		but WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
		GNU General Public License for more details.

		You should have received a copy of the GNU General Public License
		along with this program(see GPL.txt); if not, write to the Free Software
		Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

	Note:
		This AddOn's source code is specifically designed to work with
		World of Warcraft's interpreted AddOn system.
		You have an implicit license to use this AddOn with these facilities
		since that is its designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
]]
Enchantrix_RegisterRevision("$URL: http://svn.norganna.org/auctioneer/trunk/Enchantrix/EnxConstants.lua $", "$Rev: 5363 $")

local const = Enchantrix.Constants

-- These are market norm prices, a median across all servers
-- Median prices from several sites updated August 23, 2009 - Updated by ccox
-- Prices are in copper aka GGSSCC
const.StaticPrices = {

-- needs update
	[74248] = 8000000, -- Sha Crystal
	[52722] = 800000, -- Maelstrom Crystal
	[34057] =  50000, -- Abyss Crystal
	[22450] =  10000, -- Void Crystal
	[20725] =  10000, -- Nexus Crystal

	[74247] = 800000, -- Etheral Shard
	[52721] = 200000, -- Heavenly Shard
	[34052] = 140000, -- Dream Shard
	[22449] =  60000, -- Large Prismatic Shard
	[14344] =  25000, -- Large Brilliant Shard
	[11178] = 110000, -- Large Radiant Shard
	[11139] =  10000, -- Large Glowing Shard
	[11084] =   6000, -- Large Glimmering Shard

	[74252] = 400000, -- Small Etheral Shard
	[52720] = 120000, -- Small Heavenly Shard
	[34053] =  60000, -- Small Dream Shard
	[22448] =  16000, -- Small Prismatic Shard
	[14343] =  23000, -- Small Brilliant Shard
	[11177] =  70000, -- Small Radiant Shard
	[11138] =   1000, -- Small Glowing Shard
	[10978] =    700, -- Small Glimmering Shard

--	[74251] = 500000, -- Greater Mysterious Essence - doesn't seem to be used
	[52719] = 200000, -- Greater Celestial Essence
	[34055] = 200000, -- Greater Cosmic Essence
	[22446] = 120000, -- Greater Planar Essence
	[16203] = 110000, -- Greater Eternal Essence
	[11175] =  95000, -- Greater Nether Essence
	[11135] =  11000, -- Greater Mystic Essence
	[11082] =   6000, -- Greater Astral Essence
	[10939] =   6000, -- Greater Magic Essence

	[74250] = 300000, -- Mysterious Essence
	[52717] =  80000, -- Lesser Celestial Essence
	[34056] =  75000, -- Lesser Cosmic Essence
	[22447] =  38000, -- Lesser Planar Essence
	[16202] =  52500, -- Lesser Eternal Essence
	[11174] =  35000, -- Lesser Nether Essence
	[11134] =   7500, -- Lesser Mystic Essence
	[10998] =   5000, -- Lesser Astral Essence
	[10938] =   4000, -- Lesser Magic Essence

	[74249] = 200000, -- Spirit Dust
	[52555] =  10000, -- Hypnotic Dust
	[34054] =  47500, -- Infinite Dust
	[22445] =  12500, -- Arcane Dust
	[16204] =  15000, -- Illusion Dust
	[11176] =   5000, -- Dream Dust
	[11137] =  11000, -- Vision Dust
	[11083] =   5000, -- Soul Dust
	[10940] =   3000, -- Strange Dust

-- needs update
	[2772] =   11500, -- Iron Ore
	[3356] =   11000, -- Kingsblood
	[3371] =      20, -- Empty Vial		-- should use vendor price
	[3372] =     200, -- Leaded Vial	-- should use vendor price
	[3819] =   21000, -- Wintersbite
	[3829] =  110000, -- Frost Oil
	[4470] =      38, -- Simple Wood	-- should use vendor price
	[4625] =   12500, -- Firebloom
	[5500] =   65000, -- Iridescent Pearl
	[5637] =   15000, -- Large Fang
	[6037] =   37500, -- Truesilver Bar
	[6048] =   10000, -- Shadow Protection Potion
	[6217] =     124, -- Copper Rod		-- should use vendor price
	[6370] =    7500, -- Blackmouth Oil
	[6371] =   15000, -- Fire Oil
	[7067] =   45000, -- Elemental Earth
	[7075] =   45000, -- Core of Earth
	[7077] =   30000, -- Heart of Fire
	[7078] =   20000, -- Essence of Fire
	[7079] =   35000, -- Globe of Water
	[7080] =   40000, -- Essence of Water
	[7081] =   70000, -- Breath of Wind
	[7082] =   35000, -- Essence of Air
	[7392] =    5000, -- Green Whelp Scale
	[7971] =   50000, -- Black Pearl
	[7972] =    1500, -- Ichor of Undeath
	[8153] =   13000, -- Wildvine
	[8170] =   10000, -- Rugged Leather
	[8831] =   13500, -- Purple Lotus
	[8838] =   12500, -- Sungrass
	[8925] =    2500, -- Crystal Vial	-- should use vendor price
	[9224] =   32500, -- Elixir of Demonslaying
	[11128] =  70000, -- Golden Rod
	[11144] = 150000, -- Truesilver Rod
	[11291] =   4500, -- Star Wood		-- should use vendor price
	[11382] = 400000, -- Blood of the Mountain
	[11754] =  15000, -- Black Diamond
	[12359] =  27500, -- Thorium Bar
	[12803] =  30000, -- Living Essence
	[12808] =  40000, -- Essence of Undeath
	[12809] =  75000, -- Guardian Stone
	[12811] = 220000, -- Righteous Orb
	[13444] =   6500, -- Major Mana Potion
	[13446] =   6000, -- Major Healing Potion
	[13467] =  15000, -- Icecap
	[13468] =  59000, -- Black Lotus
	[13926] =  80000, -- Golden Pearl
	[16206] = 580000, -- Arcanite Rod

-- needs update
	[17034] =    200, -- Maple Seed		-- should use vendor price
	[17035] =    400, -- Stranglethorn Seed		-- should use vendor price
	[18256] =  20000, -- Imbued Vial	-- should use vendor price
	[18512] =  45000, -- Larval Acid
	[21884] = 120000, -- Primal Fire
	[21885] = 130000, -- Primal Water
	[21886] =  70000, -- Primal Life
	[22451] = 200000, -- Primal Air
	[22452] =  25000, -- Primal Earth
	[22456] =  45000, -- Primal Shadow
	[22457] =  75000, -- Primal Mana
	[22791] =  15500, -- Netherbloom
	[22792] =  15000, -- Nightmare Vine
	[25843] = 650000, -- Fel Iron Rod
	[25844] = 850000, -- Adamantite Rod
	[25845] = 850000, -- Eternium Rod
	[23571] =1500000, -- Primal MIght
	[35622] =  80000, -- Eternal Water
	[35623] =  80000, -- Eternal Air
	[35624] =  80000, -- Eternal Earth
	[35625] =  80000, -- Eternal Life
	[35627] =  67500, -- Eternal Shadow
	[36860] = 200000, -- Eternal Fire
	[37705] =   7500, -- Crystallized Water
	[41745] = 750000, -- Titanium Rod
	[41163] = 150000, -- Titanium bar

	[24243] =  17500, 	-- ADAMANTITEPOWDER
	[46849] =  20000,	-- TITANIUMPOWDER

-- updated Jan 2011
	[39151] =   3500,	-- ALABASTER_PIGMENT
	[39334] =   3500,	-- DUSKY_PIGMENT
	[39338] =  10000,	-- GOLDEN_PIGMENT
	[39339] =  20000,	-- EMERALD_PIGMENT
	[39340] =  30000,	-- VIOLET_PIGMENT
	[39341] =  15000, 	-- SILVERY_PIGMENT
	[43103] =  17500,	-- VERDANT_PIGMENT
	[43104] =  20000,	-- BURNT_PIGMENT
	[43105] =  20000,	-- INDIGO_PIGMENT
	[43106] =  40000,	-- RUBY_PIGMENT
	[43107] =  80000, 	-- SAPPHIRE_PIGMENT
	[39342] =  20000, 	-- NETHER_PIGMENT
	[43108] =  20000, 	-- EBON_PIGMENT
	[39343] =  90000, 	-- AZURE_PIGMENT
	[43109] =  30000, 	-- ICY_PIGMENT
	[61979] =  40000,   -- ASHEN_PIGMENT
	[61980] =  90000,   -- BURNING_EMBERS
-- needs update, prices in flux due to expansion
	[79251] = 200000,   -- SHADOW_PIGMENT
	[79253] = 500000,   -- MISTY_PIGMENT

-- needs update, prices in flux due to expansion
	[818] =      7500, 	-- TIGERSEYE
	[774] =      5000, 	-- MALACHITE
	[1210] =    20000,	-- SHADOWGEM
	[1705] =    25000, 	-- LESSERMOONSTONE
	[1206] =    35000, 	-- MOSSAGATE
	[3864] =    35000, 	-- CITRINE
	[1529] =    40000, 	-- JADE
	[7909] =    50000, 	-- AQUAMARINE
	[7910] =    70000, 	-- STARRUBY
	[12800] =  100000, 	-- AZEROTHIANDIAMOND
	[12361] =   50000, 	-- BLUESAPPHIRE
	[12799] =   70000, 	-- LARGEOPAL
	[12364] =   50000, 	-- HUGEEMERALD
	
	[23077] =    7000, 	-- BLOODGARNET
	[21929] =    7000, 	-- FLAMESPESSARITE
	[23112] =    7000, 	-- GOLDENDRAENITE
	[23079] =    7000, 	-- DEEPPERIDOT
	[23117] =    7000, 	-- AZUREMOONSTONE
	[23107] =    7000, 	-- SHADOWDRAENITE
	
	[23436] =   10000,	-- LIVINGRUBY
	[23439] =   10000, 	-- NOBLETOPAZ
	[23440] =   10000, 	-- DAWNSTONE
	[23437] =   10000, 	-- TALASITE
	[23438] =   10000, 	-- STAROFELUNE
	[23441] =   10000, 	-- NIGHTSEYE
	
	[36923] =   10000, 	-- Chalcedony
	[36929] =   10000, 	-- Huge Citrine
	[36917] =   10000, 	-- Bloodstone
	[36926] =   10000, 	-- Shadow Crystal
	[36920] =   10000, 	-- Sun Crystal
	[36932] =   10000, 	-- Dark Jade
	
	[36933] =   10000, 	-- Forest Emerald
	[36918] =   10000, 	-- Scarlet Ruby
	[36927] =   10000, 	-- Twilight Opal
	[36930] =   10000, 	-- Monarch Topaz
	[36924] =   10000, 	-- Sky Sapphire
	[36921] =   10000, 	-- Autumn's Glow
	
	[36925] =   80000, 	-- MAJESTICZIRCON
	[36931] =   80000, 	-- AMETRINE
	[36922] =   80000, 	-- KINGSAMBER
	[36928] =   80000, 	-- DREADSTONE
	[36919] =   80000, 	-- CARDINALRUBY
	[36934] =   80000, 	-- EYEOFZUL
	
	[52177] =   20000,  -- CARNELIAN
	[52178] =   20000,  -- ZEPHYRITE
	[52179] =   20000,  -- ALICITE
	[52180] =   20000,  -- NIGHTSTONE
	[52181] =   20000,  -- HESSONITE
	[52182] =   20000,  -- JASPER

	[52190] =  100000,  -- INFERNORUBY
	[52191] =  100000,  -- OCEANSAPPHIRE
	[52192] =  100000,  -- DREAMEMERALD
	[52193] =  100000,  -- EMBERTOPAZ
	[52194] =  100000,  -- DEMONSEYE
	[52195] =  100000,  -- AMBERJEWEL
	
	[76130] =  100000,	-- TIGEROPAL
	[76133] =  100000,	-- LAPISLAZULI
	[76134] =  100000,	-- SUNSTONE
	[76135] =  100000,	-- ROGUESTONE
	[76136] =  100000,	-- PANDARIANGARNET
	[76137] =  100000,	-- ALEXANDRITE
	
	[76131] =  500000,	-- PRIMORDIALRUBY
	[76138] =  500000,	-- RIVERSHEART
	[76139] =  500000,	-- WILDJADE
	[76140] =  500000,	-- VERMILIONONYX
	[76141] =  500000,	-- IMPERIALAMETHYST
	[76142] =  500000,	-- SUNSRADIANCE
	

}

const.DUST = 1
const.ESSENCE_LESSER = 2
const.ESSENCE_GREATER = 3
const.SHARD_SMALL = 4
const.SHARD_LARGE = 5
const.CRYSTAL = 6

const.CONSUMABLE = 0
const.CONTAINER  = 1
const.WEAPON     = 2
const.ARMOR      = 4
const.REAGENT    = 5
const.PROJECTILE = 6
const.TRADE      = 7
const.RECIPE     = 9
const.QUIVER     = 11
const.QUEST      = 12
const.KEY        = 13
const.MISC       = 15


const.InventoryTypes = {
	["INVTYPE_2HWEAPON"] = const.WEAPON,
	["INVTYPE_WEAPON"] = const.WEAPON,
	["INVTYPE_WEAPONMAINHAND"] = const.WEAPON,
	["INVTYPE_WEAPONOFFHAND"] = const.WEAPON,
	["INVTYPE_RANGED"] = const.WEAPON,
	["INVTYPE_RANGEDRIGHT"] = const.WEAPON,
	["INVTYPE_THROWN"] = const.WEAPON,
	["INVTYPE_BODY"] = const.ARMOR,
	["INVTYPE_CHEST"] = const.ARMOR,
	["INVTYPE_CLOAK"] = const.ARMOR,
	["INVTYPE_FEET"] = const.ARMOR,
	["INVTYPE_FINGER"] = const.ARMOR,
	["INVTYPE_HAND"] = const.ARMOR,
	["INVTYPE_HEAD"] = const.ARMOR,
	["INVTYPE_HOLDABLE"] = const.ARMOR,
	["INVTYPE_LEGS"] = const.ARMOR,
	["INVTYPE_NECK"] = const.ARMOR,
	["INVTYPE_ROBE"] = const.ARMOR,
	["INVTYPE_SHIELD"] = const.ARMOR,
	["INVTYPE_SHOULDER"] = const.ARMOR,
	["INVTYPE_TABARD"] = const.ARMOR,
	["INVTYPE_TRINKET"] = const.ARMOR,
	["INVTYPE_WAIST"] = const.ARMOR,
	["INVTYPE_WRIST"] = const.ARMOR,
	["INVTYPE_RELIC"] = const.ARMOR,
}

-- Enchanting reagents
local VOID = 22450
local NEXUS = 20725
local LPRISMATIC = 22449
local LBRILLIANT = 14344
local LRADIANT = 11178
local LGLOWING = 11139
local LGLIMMERING = 11084
local SPRISMATIC = 22448
local SBRILLIANT = 14343
local SRADIANT = 11177
local SGLOWING = 11138
local SGLIMMERING = 10978
local GPLANAR = 22446
local GETERNAL = 16203
local GNETHER = 11175
local GMYSTIC = 11135
local GASTRAL = 11082
local GMAGIC = 10939
local LPLANAR = 22447
local LETERNAL = 16202
local LNETHER = 11174
local LMYSTIC = 11134
local LASTRAL = 10998
local LMAGIC = 10938
local ARCANE = 22445
local ILLUSION = 16204
local DREAM = 11176
local VISION = 11137
local SOUL = 11083
local STRANGE = 10940

local DREAM_SHARD = 34052
local SDREAM_SHARD = 34053
local INFINITE = 34054
local GCOSMIC = 34055
local LCOSMIC = 34056
local ABYSS = 34057

local HEAVENLY_SHARD = 52721
local SHEAVENLY_SHARD = 52720
local HYPNOTIC = 52555
local GCELESTIAL = 52719
local LCELESTIAL = 52718
local MAELSTROM = 52722

local SHA_CRYSTAL = 74248
local ETHERAL = 74247
local SETHERAL = 74252
local SPIRIT = 74249
--local GMYSTERIOUS = 74251		-- doesn't seem to be used
local MYSTERIOUS = 74250


-- and in a form we can iterate over, with a fixed order for the UI

const.DisenchantReagentList = {

	74248, -- Sha Crystal
	52722, -- Maelstrom Crystal
	34057, -- Abyss Crystal
	22450, -- Void Crystal
	20725, -- Nexus Crystal

	74247, -- Etheral Shard
	52721, -- Heavenly Shard
	34052, -- Dream Shard
	22449, -- Large Prismatic Shard
	14344, -- Large Brilliant Shard
	11178, -- Large Radiant Shard
	11139, -- Large Glowing Shard
	11084, -- Large Glimmering Shard

	74252, -- Small Etheral Shard
	52720, -- Small Heavenly Shard
	34053, -- Small Dream Shard
	22448, -- Small Prismatic Shard
	14343, -- Small Brilliant Shard
	11177, -- Small Radiant Shard
	11138, -- Small Glowing Shard
	10978, -- Small Glimmering Shard

--	74251, -- Greater Mysterious Essence - doesn't seem to be used
	52719, -- Greater Celestial Essence
	34055, -- Greater Cosmic Essence
	22446, -- Greater Planar Essence
	16203, -- Greater Eternal Essence
	11175, -- Greater Nether Essence
	11135, -- Greater Mystic Essence
	11082, -- Greater Astral Essence
	10939, -- Greater Magic Essence

	74250, -- Mysterious Essence
	52718, -- Lesser Celestial Essence
	34056, -- Lesser Cosmic Essence
	22447, -- Lesser Planar Essence
	16202, -- Lesser Eternal Essence
	11174, -- Lesser Nether Essence
	11134, -- Lesser Mystic Essence
	10998, -- Lesser Astral Essence
	10938, -- Lesser Magic Essence

	74249, -- Spirit Dust
	52555, -- Hypnotic Dust
	34054, -- Infinite Dust
	22445, -- Arcane Dust
	16204, -- Illusion Dust
	11176, -- Dream Dust
	11137, -- Vision Dust
	11083, -- Soul Dust
	10940, -- Strange Dust

}


-- item qualities
local UNCOMMON = 2
local RARE = 3
local EPIC = 4


-- the big disenchant table, indexed by [quality][type][level bracket]
-- and yielding { { reagent type, drop probability, average drop quantity }, ... }
-- Thanks to Chardonnay, Tekkub, Wowhead, and many auctioneer forum contributors

const.baseDisenchantTable = {
 [UNCOMMON] = {
  [const.WEAPON] = {
   ["bounds"] = { 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 99, 120, 151, 200, 275, 290, 305, 315, 325, 350, 380, 390, 410, 450 },
   [15]  = { { STRANGE , 0.20, 1.5 }, { LMAGIC  , 0.80, 1.5 }, },
   [20]  = { { STRANGE , 0.20, 2.5 }, { GMAGIC  , 0.75, 1.5 }, { SGLIMMERING, 0.05, 1.0 }, },
   [25]  = { { STRANGE , 0.15, 5.0 }, { LASTRAL , 0.75, 1.5 }, { SGLIMMERING, 0.10, 1.0 }, },
   [30]  = { { SOUL    , 0.20, 1.5 }, { GASTRAL , 0.75, 1.5 }, { LGLIMMERING, 0.05, 1.0 }, },
   [35]  = { { SOUL    , 0.20, 3.5 }, { LMYSTIC , 0.75, 1.5 }, { SGLOWING   , 0.05, 1.0 }, },
   [40]  = { { VISION  , 0.20, 1.5 }, { GMYSTIC , 0.75, 1.5 }, { LGLOWING   , 0.05, 1.0 }, },
   [45]  = { { VISION  , 0.20, 3.5 }, { LNETHER , 0.75, 1.5 }, { SRADIANT   , 0.05, 1.0 }, },
   [50]  = { { DREAM   , 0.20, 1.5 }, { GNETHER , 0.75, 1.5 }, { LRADIANT   , 0.05, 1.0 }, },
   [55]  = { { DREAM   , 0.20, 3.5 }, { LETERNAL, 0.75, 1.5 }, { SBRILLIANT , 0.05, 1.0 }, },
   [60]  = { { ILLUSION, 0.20, 1.5 }, { GETERNAL, 0.75, 1.5 }, { LBRILLIANT , 0.05, 1.0 }, },
   [65]  = { { ILLUSION, 0.20, 3.5 }, { GETERNAL, 0.75, 2.5 }, { LBRILLIANT , 0.05, 1.0 }, },
   [99]  = { { ARCANE  , 0.20, 2.5 }, { LPLANAR , 0.75, 2.5 }, { SPRISMATIC , 0.05, 1.0 }, },
   [120] = { { ARCANE  , 0.20, 3.5 }, { GPLANAR , 0.75, 1.5 }, { LPRISMATIC , 0.05, 1.0 }, },	-- highest level BC green
   [151] = { { INFINITE, 0.20, 2.5 }, { LCOSMIC , 0.75, 1.5 }, { SDREAM_SHARD, 0.05, 1.0 }, },
   [200] = { { INFINITE, 0.20, 5.5 }, { GCOSMIC , 0.75, 1.5 }, { DREAM_SHARD , 0.05, 1.0 }, },	-- highest level LK green is 182
   
   -- no shards from greens in Cata
   [275] = { { HYPNOTIC, 0.25, 1.5 }, { LCELESTIAL , 0.75, 1.5 }, },
   [290] = { { HYPNOTIC, 0.25, 2.0 }, { LCELESTIAL , 0.75, 2.0 }, },
   [305] = { { HYPNOTIC, 0.25, 2.5 }, { LCELESTIAL , 0.75, 2.5 }, },
   [315] = { { HYPNOTIC, 0.25, 3.0 }, { GCELESTIAL , 0.75, 1.5 }, },
   [325] = { { HYPNOTIC, 0.25, 3.5 }, { GCELESTIAL , 0.75, 2.5 }, },
   [350] = { { HYPNOTIC, 0.25, 4.0 }, { GCELESTIAL , 0.75, 3.0 }, },	-- highest level Cata green is 333, first Panda is 377
   
   -- As of Sept 23, 2012, weapons were giving almost the same drops as armor (mostly dust)
   -- weapons do seem to drop more dusts
-- tested beta Sept 23, 2012
   [380] = { { SPIRIT, 0.85, 2.5 }, { MYSTERIOUS , 0.15, 1.0 }, },
   [390] = { { SPIRIT, 0.85, 3.0 }, { MYSTERIOUS , 0.15, 1.0 }, },
   [410] = { { SPIRIT, 0.85, 3.5 }, { MYSTERIOUS , 0.15, 1.5 }, },
   [450] = { { SPIRIT, 0.85, 4.0 }, { MYSTERIOUS , 0.15, 2.0 }, },	-- highest level Panda green is 437, so far

  },
  [const.ARMOR] = {
   ["bounds"] = { 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 99, 120, 151, 200, 275, 290, 305, 315, 325, 350, 380, 390, 410, 450 },
   [15]  = { { STRANGE , 0.80, 1.5 }, { LMAGIC  , 0.20, 1.5 }, },
   [20]  = { { STRANGE , 0.75, 2.5 }, { GMAGIC  , 0.20, 1.5 }, { SGLIMMERING, 0.05, 1.0 }, },
   [25]  = { { STRANGE , 0.75, 5.0 }, { LASTRAL , 0.15, 1.5 }, { SGLIMMERING, 0.10, 1.0 }, },
   [30]  = { { SOUL    , 0.75, 1.5 }, { GASTRAL , 0.20, 1.5 }, { LGLIMMERING, 0.05, 1.0 }, },
   [35]  = { { SOUL    , 0.75, 3.5 }, { LMYSTIC , 0.20, 1.5 }, { SGLOWING   , 0.05, 1.0 }, },
   [40]  = { { VISION  , 0.75, 1.5 }, { GMYSTIC , 0.20, 1.5 }, { LGLOWING   , 0.05, 1.0 }, },
   [45]  = { { VISION  , 0.75, 3.5 }, { LNETHER , 0.20, 1.5 }, { SRADIANT   , 0.05, 1.0 }, },
   [50]  = { { DREAM   , 0.75, 1.5 }, { GNETHER , 0.20, 1.5 }, { LRADIANT   , 0.05, 1.0 }, },
   [55]  = { { DREAM   , 0.75, 3.5 }, { LETERNAL, 0.20, 1.5 }, { SBRILLIANT , 0.05, 1.0 }, },
   [60]  = { { ILLUSION, 0.75, 1.5 }, { GETERNAL, 0.20, 1.5 }, { LBRILLIANT , 0.05, 1.0 }, },
   [65]  = { { ILLUSION, 0.75, 3.5 }, { GETERNAL, 0.20, 2.5 }, { LBRILLIANT , 0.05, 1.0 }, },
   [99]  = { { ARCANE  , 0.75, 2.5 }, { LPLANAR , 0.20, 2.5 }, { SPRISMATIC , 0.05, 1.0 }, },
   [120] = { { ARCANE  , 0.75, 3.5 }, { GPLANAR , 0.20, 1.5 }, { LPRISMATIC , 0.05, 1.0 }, },	-- highest level BC green
   [151] = { { INFINITE, 0.75, 2.5 }, { LCOSMIC , 0.20, 1.5 }, { SDREAM_SHARD, 0.05, 1.0 }, },
   [200] = { { INFINITE, 0.75, 5.5 }, { GCOSMIC , 0.20, 1.5 }, { DREAM_SHARD , 0.05, 1.0 }, },	-- highest level LK green is 182
   
   -- no shards from greens in Cata
   [275] = { { HYPNOTIC, 0.75, 1.5 }, { LCELESTIAL , 0.25, 1.5 }, },
   [290] = { { HYPNOTIC, 0.75, 2.0 }, { LCELESTIAL , 0.25, 2.0 }, },
   [305] = { { HYPNOTIC, 0.75, 2.5 }, { LCELESTIAL , 0.25, 2.5 }, },
   [315] = { { HYPNOTIC, 0.75, 3.0 }, { GCELESTIAL , 0.25, 1.5 }, },
   [325] = { { HYPNOTIC, 0.75, 3.5 }, { GCELESTIAL , 0.25, 2.5 }, },
   [350] = { { HYPNOTIC, 0.75, 4.0 }, { GCELESTIAL , 0.25, 3.0 }, },	-- highest level Cata green is 333, first Panda is 364
   
-- tested beta Sept 23, 2012
   [380] = { { SPIRIT, 0.85, 2.0 }, { MYSTERIOUS , 0.15, 1.0 }, },
   [390] = { { SPIRIT, 0.85, 2.5 }, { MYSTERIOUS , 0.15, 1.0 }, },
   [410] = { { SPIRIT, 0.85, 3.0 }, { MYSTERIOUS , 0.15, 1.5 }, },
   [450] = { { SPIRIT, 0.85, 3.5 }, { MYSTERIOUS , 0.15, 2.0 }, },	-- highest level Panda green is 437, so far
   
  },
 },
 [RARE] = {
 	-- weapon lookups will fall back to the armor table
 	-- 1% chance for better shard appears to have been removed in Cataclysm
  [const.ARMOR] = {
   ["bounds"] = { 25, 30, 35, 40, 45, 50, 55, 65, 99, 120, 164, 200, 316, 380, 424, 449, 450, 500 },
   [25]  = { { SGLIMMERING,     1.00, 1.0 } },
   [30]  = { { LGLIMMERING,     1.00, 1.0 } },
   [35]  = { { SGLOWING,        1.00, 1.0 } },
   [40]  = { { LGLOWING,        1.00, 1.0 } },
   [45]  = { { SRADIANT,        1.00, 1.0 } },
   [50]  = { { LRADIANT,        1.00, 1.0 } },
   [55]  = { { SBRILLIANT,      1.00, 1.0 } },
   [65]  = { { LBRILLIANT,      1.00, 1.0 } },
   [99]  = { { SPRISMATIC,      1.00, 1.0 } },
   [120] = { { LPRISMATIC,      1.00, 1.0 } },
   [164] = { { SDREAM_SHARD,    1.00, 1.0 } },
   [200] = { { DREAM_SHARD ,    1.00, 1.0 } },	-- highest level LK blue is 200, first Cata blue is 288
   [316] = { { SHEAVENLY_SHARD, 1.00, 1.0 } },
   [380] = { { HEAVENLY_SHARD,  1.00, 1.0 } },	-- highest level Cata blue is 377, first Panda blue is 384

-- tested beta, Spet 23, 2012
-- something weird is going on, some items have steady drops, while others seem random small and large
-- need a lot more data, could be crafted vs. drop?  Dragonling seems most mixed
   [424] = { { SETHERAL,        1.00, 1.0 } },	-- this seems solid
   [449] = { { ETHERAL,         1.00, 1.0 } },	-- this seems solid
   [450] = { { ETHERAL,         0.20, 1.0 }, { SETHERAL,        0.80, 1.0 } },	-- this is mixed
   [500] = { { ETHERAL,         1.00, 1.0 } },	-- this seems solid, highest level Panda blue is 463, so far
  },
 },
 [EPIC] = {
 	-- weapon lookups will fall back to the armor table
  [const.ARMOR] = {
   ["bounds"] = { 40, 45, 50, 55, 60, 94, 99, 164, 299, 419, 600 },
   [40]  = { { SRADIANT,    1.00, 3.0 } },
   [45]  = { { SRADIANT,    1.00, 3.5 } },
   [50]  = { { LRADIANT,    1.00, 3.5 } },
   [55]  = { { SBRILLIANT,  1.00, 3.5 } },
   [60]  = { { NEXUS,       1.00, 1.0 } },
   [94]  = { { NEXUS,       1.00, 1.5 } },	-- highest level classic item is 94, first BC epic is 95
   [99]  = { { VOID,        1.00, 1.0 } },
   [164] = { { VOID,        1.00, 1.5 } },	-- highest level BC epic is 164, first LK epic is 200
   [299] = { { ABYSS,       1.00, 1.0 } },	-- highest level LK epic is 284, first Cata epic is 300
   [419] = { { MAELSTROM,   1.00, 1.0 } },	-- highest level CATA epic is 416, first Panda epic is 420
   [600] = { { SHA_CRYSTAL, 1.00, 1.0 } },	-- highest level Panda epic so far is 516, so far
   
  },
 },
}

-- map reagents to item levels they are obtainable from
-- ignoring the 1% chance for rare drops

-- manually copied from baseDisenchantTable

const.ReverseDisenchantLevelList = {
	
-- ccox, needs update
	[SHA_CRYSTAL] = { 420, 600 }, -- Sha Crystal
	[MAELSTROM]   = { 300, 419 }, -- Maelstrom Crystal
	[ABYSS]       = { 165, 299 }, -- Abyss Crystal
	[VOID]        = {  95, 164 }, -- Void Crystal
	[NEXUS]       = {  56,  94 }, -- Nexus Crystal
	
	[ETHERAL] 		  = { 425, 500 }, -- Etheral Shard
	[SETHERAL]        = { 380, 424 }, -- Small Etheral Shard
	[HEAVENLY_SHARD]  = { 317, 379 }, -- Heavenly Shard
	[SHEAVENLY_SHARD] = { 201, 316 }, -- Small Heavenly Shard
	[DREAM_SHARD]     = { 165, 200 }, -- Dream Shard
	[SDREAM_SHARD]    = { 121, 164 }, -- Small Dream Shard
	[LPRISMATIC]      = { 100, 120 }, -- Large Prismatic Shard
	[SPRISMATIC]      = {  66,  99 }, -- Small Prismatic Shard
	[LBRILLIANT]      = {  56,  65 }, -- Large Brilliant Shard
	[SBRILLIANT]      = {  51,  55 }, -- Small Brilliant Shard
	[LRADIANT]        = {  46,  50 }, -- Large Radiant Shard
	[SRADIANT]        = {  41,  45 }, -- Small Radiant Shard
	[LGLOWING]        = {  36,  40 }, -- Large Glowing Shard
	[SGLOWING]        = {  31,  35 }, -- Small Glowing Shard
	[LGLIMMERING]     = {  26,  30 }, -- Large Glimmering Shard
	[SGLIMMERING]     = {  1,   25 }, -- Small Glimmering Shard
	
	[MYSTERIOUS]  = { 351, 450 }, -- Lesser Mysterious Essence
	[GCELESTIAL]  = { 306, 350 }, -- Greater Celestial Essence
	[LCELESTIAL]  = { 201, 305 }, -- Lesser Celestial Essence
	[GCOSMIC]     = { 152, 200 }, -- Greater Cosmic Essence
	[LCOSMIC]     = { 121, 151 }, -- Lesser Cosmic Essence
	[GPLANAR]     = { 100, 120 }, -- Greater Planar Essence
	[LPLANAR]     = {  66,  99 }, -- Lesser Planar Essence
	[GETERNAL]    = {  56,  65 }, -- Greater Eternal Essence
	[LETERNAL]    = {  51,  55 }, -- Lesser Eternal Essence
	[GNETHER]     = {  46,  50 }, -- Greater Nether Essence
	[LNETHER]     = {  41,  45 }, -- Lesser Nether Essence
	[GMYSTIC]     = {  36,  40 }, -- Greater Mystic Essence
	[LMYSTIC]     = {  31,  35 }, -- Lesser Mystic Essence
	[GASTRAL]     = {  26,  30 }, -- Greater Astral Essence
	[LASTRAL]     = {  21,  25 }, -- Lesser Astral Essence
	[GMAGIC]      = {  16,  20 }, -- Greater Magic Essence
	[LMAGIC]      = {   1,  15 }, -- Lesser Magic Essence
	
	[SPIRIT]   = { 351, 450 }, -- Spirit Dust
	[HYPNOTIC] = { 201, 350 }, -- Hypnotic Dust
	[INFINITE] = { 121, 200 }, -- Infinite Dust
	[ARCANE]   = {  66, 120 }, -- Arcane Dust
	[ILLUSION] = {  56,  65 }, -- Illusion Dust
	[DREAM]    = {  46,  55 }, -- Dream Dust
	[VISION]   = {  36,  45 }, -- Vision Dust
	[SOUL]     = {  26,  35 }, -- Soul Dust
	[STRANGE]  = {   1,  25 }, -- Strange Dust

}




-- needed because GetItemInfo fails when items are not in the user's cache
-- it would be nice if it failed a lot less often
const.BackupReagentItemInfo = {
	[774] = "Malachite#|cff1eff00|Hitem:774:0:0:0:0:0:0:0:88:0:0|h[Malachite]|h|r#2#7#0#Gem#Simple#20##Interface\\Icons\\INV_Misc_Gem_Emerald_03",
	[785] = "Mageroyal#|cffffffff|Hitem:785:0:0:0:0:0:0:0:70|h[Mageroyal]|h|r#1#10#0#Trade Goods#Herb#20##Interface\\Icons\\INV_Jewelry_Talisman_03",
	[818] = "Tigerseye#|cff1eff00|Hitem:818:0:0:0:0:0:0:0:88:0:0|h[Tigerseye]|h|r#2#15#0#Gem#Simple#20##Interface\\Icons\\INV_Misc_Gem_Opal_03",
	[1206] = "Moss Agate#|cff1eff00|Hitem:1206:0:0:0:0:0:0:0:80:0|h[Moss Agate]|h|r#2#25#0#Gem#Simple#20##Interface\\Icons\\INV_Misc_Gem_Emerald_02",
	[1210] = "Shadowgem#|cff1eff00|Hitem:1210:0:0:0:0:0:0:0:88:0:0|h[Shadowgem]|h|r#2#20#0#Gem#Simple#20##Interface\\Icons\\INV_Misc_Gem_Amethyst_01",
	[1529] = "Jade#|cff1eff00|Hitem:1529:0:0:0:0:0:0:0:80:0|h[Jade]|h|r#2#35#0#Gem#Simple#20##Interface\\Icons\\INV_Misc_Gem_Stone_01",
	[1705] = "Lesser Moonstone#|cff1eff00|Hitem:1705:0:0:0:0:0:0:0:80:0|h[Lesser Moonstone]|h|r#2#30#0#Gem#Simple#20##Interface\\Icons\\INV_Misc_Gem_Crystal_01",
	[2770] = "Copper Ore#|cffffffff|Hitem:2770:0:0:0:0:0:0:0:10:0:0|h[Copper Ore]|h|r#1#10#0#Trade Goods#Metal & Stone#20##Interface\\Icons\\INV_Ore_Copper_01",
	[2771] = "Tin Ore#|cffffffff|Hitem:2771:0:0:0:0:0:0:0:80:0|h[Tin Ore]|h|r#1#20#0#Trade Goods#Metal & Stone#20##Interface\\Icons\\INV_Ore_Tin_01",
	[2772] = "Iron Ore#|cffffffff|Hitem:2772:0:0:0:0:0:0:0:80:0|h[Iron Ore]|h|r#1#30#0#Trade Goods#Metal & Stone#20##Interface\\Icons\\INV_Ore_Iron_01",
	[3356] = "Kingsblood#|cffffffff|Hitem:3356:0:0:0:0:0:0:0:70|h[Kingsblood]|h|r#1#24#0#Trade Goods#Herb#20##Interface\\Icons\\INV_Misc_Herb_03",
	[3819] = "Wintersbite#|cffffffff|Hitem:3819:0:0:0:0:0:0:0:70|h[Wintersbite]|h|r#1#39#0#Trade Goods#Herb#20##Interface\\Icons\\INV_Misc_Flower_03",
	[3824] = "Shadow Oil#|cffffffff|Hitem:3824:0:0:0:0:0:0:0|h[Shadow Oil]|h|r#1#34#24#Consumable#Consumable#5##Interface\\Icons\\INV_Potion_23",
	[3829] = "Frost Oil#|cffffffff|Hitem:3829:0:0:0:0:0:0:0|h[Frost Oil]|h|r#1#40#30#Consumable#Other#5##Interface\\Icons\\INV_Potion_20",
	[3858] = "Mithril Ore#|cffffffff|Hitem:3858:0:0:0:0:0:0:0:80:0|h[Mithril Ore]|h|r#1#40#0#Trade Goods#Metal & Stone#20##Interface\\Icons\\INV_Ore_Mithril_02",
	[3860] = "Mithril Bar#|cffffffff|Hitem:3860:0:0:0:0:0:0:0:80|h[Mithril Bar]|h|r#1#40#0#Trade Goods#Metal & Stone#20##Interface\\Icons\\INV_Ingot_06",
	[3864] = "Citrine#|cff1eff00|Hitem:3864:0:0:0:0:0:0:0:80:0|h[Citrine]|h|r#2#40#0#Gem#Simple#20##Interface\\Icons\\INV_Misc_Gem_Opal_02",
	[4470] = "Simple Wood#|cffffffff|Hitem:4470:0:0:0:0:0:0:0|h[Simple Wood]|h|r#1#5#0#Trade Goods#Other#20##Interface\\Icons\\INV_TradeskillItem_01",
	[5498] = "Small Lustrous Pearl#|cff1eff00|Hitem:5498:0:0:0:0:0:0:0|h[Small Lustrous Pearl]|h|r#2#15#0#Gem#Simple#20##Interface\\Icons\\INV_Misc_Gem_Pearl_03",
	[5500] = "Iridescent Pearl#|cff1eff00|Hitem:5500:0:0:0:0:0:0:0|h[Iridescent Pearl]|h|r#2#25#0#Gem#Simple#20##Interface\\Icons\\INV_Misc_Gem_Pearl_02",
	[5637] = "Large Fang#|cffffffff|Hitem:5637:0:0:0:0:0:0:0|h[Large Fang]|h|r#1#30#0#Trade Goods#Trade Goods#5##Interface\\Icons\\INV_Misc_Bone_08",
	[6037] = "Truesilver Bar#|cff1eff00|Hitem:6037:0:0:0:0:0:0:0:45|h[Truesilver Bar]|h|r#2#50#0#Trade Goods#Metal & Stone#20##Interface\\Icons\\INV_Ingot_08",
	[6048] = "Shadow Protection Potion#|cffffffff|Hitem:6048:0:0:0:0:0:0:0:70|h[Shadow Protection Potion]|h|r#1#27#17#Consumable#Potion#5##Interface\\Icons\\INV_Potion_44",
	[6217] = "Copper Rod#|cffffffff|Hitem:6217:0:0:0:0:0:0:0|h[Copper Rod]|h|r#1#5#0#Trade Goods#Enchanting#1##Interface\\Icons\\INV_Misc_Flute_01",
	[6218] = "Runed Copper Rod#|cffffffff|Hitem:6218:0:0:0:0:0:0:0|h[Runed Copper Rod]|h|r#1#5#1#Trade Goods#Trade Goods#1##Interface\\Icons\\INV_Staff_Goldfeathered_01",
	[6338] = "Silver Rod#|cffffffff|Hitem:6338:0:0:0:0:0:0:0|h[Silver Rod]|h|r#1#20#0#Trade Goods#Trade Goods#1##Interface\\Icons\\INV_Staff_01",
	[6339] = "Runed Silver Rod#|cffffffff|Hitem:6339:0:0:0:0:0:0:0|h[Runed Silver Rod]|h|r#1#20#1#Trade Goods#Trade Goods#1##Interface\\Icons\\INV_Staff_01",
	[6370] = "Blackmouth Oil#|cffffffff|Hitem:6370:0:0:0:0:0:0:0:70|h[Blackmouth Oil]|h|r#1#15#0#Trade Goods#Other#20##Interface\\Icons\\INV_Drink_12",
	[6371] = "Fire Oil#|cffffffff|Hitem:6371:0:0:0:0:0:0:0:57|h[Fire Oil]|h|r#1#25#0#Trade Goods#Other#20##Interface\\Icons\\INV_Potion_38",
	[7067] = "Elemental Earth#|cffffffff|Hitem:7067:0:0:0:0:0:0:0:70|h[Elemental Earth]|h|r#1#25#0#Trade Goods#Elemental#10##Interface\\Icons\\INV_Ore_Iron_01",
	[7068] = "Elemental Fire#|cffffffff|Hitem:7068:0:0:0:0:0:0:0:70|h[Elemental Fire]|h|r#1#25#0#Trade Goods#Elemental#10##Interface\\Icons\\Spell_Fire_Fire",
	[7070] = "Elemental Water#|cffffffff|Hitem:7070:0:0:0:0:0:0:0|h[Elemental Water]|h|r#1#25#0#Reagent#Reagent#10##Interface\\Icons\\INV_Potion_03",
	[7075] = "Core of Earth#|cffffffff|Hitem:7075:0:0:0:0:0:0:0:70|h[Core of Earth]|h|r#1#45#0#Trade Goods#Elemental#10##Interface\\Icons\\INV_Stone_05",
	[7077] = "Heart of Fire#|cffffffff|Hitem:7077:0:0:0:0:0:0:0:70|h[Heart of Fire]|h|r#1#45#0#Trade Goods#Elemental#10##Interface\\Icons\\Spell_Fire_LavaSpawn",
	[7078] = "Essence of Fire#|cff1eff00|Hitem:7078:0:0:0:0:0:0:0:70|h[Essence of Fire]|h|r#2#55#0#Trade Goods#Elemental#10##Interface\\Icons\\Spell_Fire_Volcano",
	[7079] = "Globe of Water#|cffffffff|Hitem:7079:0:0:0:0:0:0:0:70|h[Globe of Water]|h|r#1#45#0#Trade Goods#Elemental#10##Interface\\Icons\\INV_Misc_Orb_01",
	[7080] = "Essence of Water#|cff1eff00|Hitem:7080:0:0:0:0:0:0:0:74|h[Essence of Water]|h|r#2#55#0#Trade Goods#Elemental#10##Interface\\Icons\\Spell_Nature_Acid_01",
	[7081] = "Breath of Wind#|cffffffff|Hitem:7081:0:0:0:0:0:0:0:70|h[Breath of Wind]|h|r#1#45#0#Trade Goods#Elemental#10##Interface\\Icons\\Spell_Nature_Cyclone",
	[7082] = "Essence of Air#|cff1eff00|Hitem:7082:0:0:0:0:0:0:0:74|h[Essence of Air]|h|r#2#55#0#Trade Goods#Elemental#10##Interface\\Icons\\Spell_Nature_EarthBind",
	[7909] = "Aquamarine#|cff1eff00|Hitem:7909:0:0:0:0:0:0:0:88:0:0|h[Aquamarine]|h|r#2#45#0#Gem#Simple#20##Interface\\Icons\\INV_Misc_Gem_Crystal_02",
	[7910] = "Star Ruby#|cff1eff00|Hitem:7910:0:0:0:0:0:0:0:80:0|h[Star Ruby]|h|r#2#50#0#Gem#Simple#20##Interface\\Icons\\INV_Misc_Gem_Ruby_02",
	[7971] = "Black Pearl#|cff1eff00|Hitem:7971:0:0:0:0:0:0:0|h[Black Pearl]|h|r#2#40#0#Gem#Simple#20##Interface\\Icons\\INV_Misc_Gem_Pearl_01",
	[7972] = "Ichor of Undeath#|cffffffff|Hitem:7972:0:0:0:0:0:0:0:70|h[Ichor of Undeath]|h|r#1#45#0#Trade Goods#Elemental#10##Interface\\Icons\\INV_Misc_Slime_01",
	[8153] = "Wildvine#|cffffffff|Hitem:8153:0:0:0:0:0:0:0|h[Wildvine]|h|r#1#40#0#Trade Goods#Herb#20##Interface\\Icons\\INV_Misc_Herb_03",
	[8170] = "Rugged Leather#|cffffffff|Hitem:8170:0:0:0:0:0:0:0:14|h[Rugged Leather]|h|r#1#50#0#Trade Goods#Leather#20##Interface\\Icons\\INV_Misc_LeatherScrap_02",
	[8838] = "Sungrass#|cffffffff|Hitem:8838:0:0:0:0:0:0:0:20|h[Sungrass]|h|r#1#46#0#Trade Goods#Herb#20##Interface\\Icons\\INV_Misc_Herb_18",
	[9224] = "Elixir of Demonslaying#|cffffffff|Hitem:9224:0:0:0:0:0:0:0:70|h[Elixir of Demonslaying]|h|r#1#50#40#Consumable#Elixir#20##Interface\\Icons\\INV_Potion_27",
	[10620] = "Thorium Ore#|cffffffff|Hitem:10620:0:0:0:0:0:0:0:80:0|h[Thorium Ore]|h|r#1#40#0#Trade Goods#Metal & Stone#20##Interface\\Icons\\INV_Ore_Thorium_02",
	[10648] = "Common Parchment#|cffffffff|Hitem:10648:0:0:0:0:0:0:0:70|h[Common Parchment]|h|r#1#40#0#Trade Goods#Other#20##Interface\\Icons\\INV_Inscription_Parchment",
	[10938] = "Lesser Magic Essence#|cff1eff00|Hitem:10938:0:0:0:0:0:0:0:88:0:0|h[Lesser Magic Essence]|h|r#2#10#0#Trade Goods#Enchanting#10##Interface\\Icons\\INV_Enchant_EssenceMagicSmall",
	[10939] = "Greater Magic Essence#|cff1eff00|Hitem:10939:0:0:0:0:0:0:0:88:0:0|h[Greater Magic Essence]|h|r#2#15#0#Trade Goods#Enchanting#10##Interface\\Icons\\INV_Enchant_EssenceMagicLarge",
	[10940] = "Strange Dust#|cffffffff|Hitem:10940:0:0:0:0:0:0:0:88:0:0|h[Strange Dust]|h|r#1#10#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Enchant_DustStrange",
	[10978] = "Small Glimmering Shard#|cff0070dd|Hitem:10978:0:0:0:0:0:0:0:88:0:0|h[Small Glimmering Shard]|h|r#3#20#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Enchant_ShardGlimmeringSmall",
	[10998] = "Lesser Astral Essence#|cff1eff00|Hitem:10998:0:0:0:0:0:0:0:88:0:0|h[Lesser Astral Essence]|h|r#2#20#0#Trade Goods#Enchanting#10##Interface\\Icons\\INV_Enchant_EssenceAstralSmall",
	[11082] = "Greater Astral Essence#|cff1eff00|Hitem:11082:0:0:0:0:0:0:0:88:0:0|h[Greater Astral Essence]|h|r#2#25#0#Trade Goods#Enchanting#10##Interface\\Icons\\INV_Enchant_EssenceAstralLarge",
	[11083] = "Soul Dust#|cffffffff|Hitem:11083:0:0:0:0:0:0:0:88:0:0|h[Soul Dust]|h|r#1#25#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Enchant_DustSoul",
	[11084] = "Large Glimmering Shard#|cff0070dd|Hitem:11084:0:0:0:0:0:0:0:88:0:0|h[Large Glimmering Shard]|h|r#3#25#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Enchant_ShardGlimmeringLarge",
	[11128] = "Golden Rod#|cffffffff|Hitem:11128:0:0:0:0:0:0:0|h[Golden Rod]|h|r#1#30#0#Trade Goods#Trade Goods#1##Interface\\Icons\\INV_Staff_10",
	[11130] = "Runed Golden Rod#|cffffffff|Hitem:11130:0:0:0:0:0:0:0|h[Runed Golden Rod]|h|r#1#30#0#Trade Goods#Trade Goods#1##Interface\\Icons\\INV_Staff_10",
	[11134] = "Lesser Mystic Essence#|cff1eff00|Hitem:11134:0:0:0:0:0:0:0:88:0:0|h[Lesser Mystic Essence]|h|r#2#30#0#Trade Goods#Enchanting#10##Interface\\Icons\\INV_Enchant_EssenceMysticalSmall",
	[11135] = "Greater Mystic Essence#|cff1eff00|Hitem:11135:0:0:0:0:0:0:0:88:0:0|h[Greater Mystic Essence]|h|r#2#35#0#Trade Goods#Enchanting#10##Interface\\Icons\\INV_Enchant_EssenceMysticalLarge",
	[11137] = "Vision Dust#|cffffffff|Hitem:11137:0:0:0:0:0:0:0:88:0:0|h[Vision Dust]|h|r#1#35#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Enchant_DustVision",
	[11138] = "Small Glowing Shard#|cff0070dd|Hitem:11138:0:0:0:0:0:0:0:88:0:0|h[Small Glowing Shard]|h|r#3#30#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Enchant_ShardGlowingSmall",
	[11139] = "Large Glowing Shard#|cff0070dd|Hitem:11139:0:0:0:0:0:0:0:88:0:0|h[Large Glowing Shard]|h|r#3#35#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Enchant_ShardGlowingLarge",
	[11144] = "Truesilver Rod#|cffffffff|Hitem:11144:0:0:0:0:0:0:0|h[Truesilver Rod]|h|r#1#40#0#Trade Goods#Trade Goods#1##Interface\\Icons\\INV_Staff_11",
	[11174] = "Lesser Nether Essence#|cff1eff00|Hitem:11174:0:0:0:0:0:0:0:88:0:0|h[Lesser Nether Essence]|h|r#2#40#0#Trade Goods#Enchanting#10##Interface\\Icons\\INV_Enchant_EssenceNetherSmall",
	[11175] = "Greater Nether Essence#|cff1eff00|Hitem:11175:0:0:0:0:0:0:0:85:0:0|h[Greater Nether Essence]|h|r#2#45#0#Trade Goods#Enchanting#10##Interface\\Icons\\INV_Enchant_EssenceNetherLarge",
	[11176] = "Dream Dust#|cffffffff|Hitem:11176:0:0:0:0:0:0:0:85:0:0|h[Dream Dust]|h|r#1#45#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Enchant_DustDream",
	[11177] = "Small Radiant Shard#|cff0070dd|Hitem:11177:0:0:0:0:0:0:0:88:0:0|h[Small Radiant Shard]|h|r#3#40#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Enchant_ShardRadientSmall",
	[11178] = "Large Radiant Shard#|cff0070dd|Hitem:11178:0:0:0:0:0:0:0:85:0:0|h[Large Radiant Shard]|h|r#3#45#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Enchant_ShardRadientLarge",
	[11291] = "Star Wood#|cffffffff|Hitem:11291:0:0:0:0:0:0:0|h[Star Wood]|h|r#1#30#0#Reagent#Reagent#20##Interface\\Icons\\INV_TradeskillItem_03",
	[12361] = "Blue Sapphire#|cff1eff00|Hitem:12361:0:0:0:0:0:0:0:80:0|h[Blue Sapphire]|h|r#2#55#0#Gem#Simple#20##Interface\\Icons\\INV_Misc_Gem_Sapphire_02",
	[12364] = "Huge Emerald#|cff1eff00|Hitem:12364:0:0:0:0:0:0:0:80:0|h[Huge Emerald]|h|r#2#60#0#Gem#Simple#20##Interface\\Icons\\INV_Misc_Gem_Emerald_01",
	[12799] = "Large Opal#|cff1eff00|Hitem:12799:0:0:0:0:0:0:0:80:0|h[Large Opal]|h|r#2#55#0#Gem#Simple#20##Interface\\Icons\\INV_Misc_Gem_Opal_01",
	[12800] = "Azerothian Diamond#|cff1eff00|Hitem:12800:0:0:0:0:0:0:0:80:0|h[Azerothian Diamond]|h|r#2#60#0#Gem#Simple#20##Interface\\Icons\\INV_Misc_Gem_Diamond_01",
	[12803] = "Living Essence#|cff1eff00|Hitem:12803:0:0:0:0:0:0:0:70|h[Living Essence]|h|r#2#55#0#Trade Goods#Elemental#10##Interface\\Icons\\Spell_Nature_AbolishMagic",
	[12808] = "Essence of Undeath#|cff1eff00|Hitem:12808:0:0:0:0:0:0:0:70|h[Essence of Undeath]|h|r#2#55#0#Trade Goods#Elemental#10##Interface\\Icons\\Spell_Shadow_ShadeTrueSight",
	[12811] = "Righteous Orb#|cff1eff00|Hitem:12811:0:0:0:0:0:0:0|h[Righteous Orb]|h|r#2#60#0#Trade Goods#Trade Goods#20##Interface\\Icons\\INV_Misc_Gem_Pearl_03",
	[13446] = "Major Healing Potion#|cffffffff|Hitem:13446:0:0:0:0:0:0:0:70|h[Major Healing Potion]|h|r#1#55#45#Consumable#Potion#5##Interface\\Icons\\INV_Potion_54",
	[13467] = "Icecap#|cffffffff|Hitem:13467:0:0:0:0:0:0:0:74|h[Icecap]|h|r#1#58#0#Trade Goods#Herb#20##Interface\\Icons\\INV_Misc_Herb_IceCap",
	[14343] = "Small Brilliant Shard#|cff0070dd|Hitem:14343:0:0:0:0:0:0:0:88:0:0|h[Small Brilliant Shard]|h|r#3#50#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Enchant_ShardBrilliantSmall",
	[14344] = "Large Brilliant Shard#|cff0070dd|Hitem:14344:0:0:0:0:0:0:0:88:0:0|h[Large Brilliant Shard]|h|r#3#55#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Enchant_ShardBrilliantLarge",
	[16202] = "Lesser Eternal Essence#|cff1eff00|Hitem:16202:0:0:0:0:0:0:0:88:0:0|h[Lesser Eternal Essence]|h|r#2#50#0#Trade Goods#Enchanting#10##Interface\\Icons\\INV_Enchant_EssenceEternalSmall",
	[16203] = "Greater Eternal Essence#|cff1eff00|Hitem:16203:0:0:0:0:0:0:0:88:0:0|h[Greater Eternal Essence]|h|r#2#55#0#Trade Goods#Enchanting#10##Interface\\Icons\\INV_Enchant_EssenceEternalLarge",
	[16204] = "Illusion Dust#|cffffffff|Hitem:16204:0:0:0:0:0:0:0:88:0:0|h[Illusion Dust]|h|r#1#55#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Enchant_DustIllusion",
	[17034] = "Maple Seed#|cffffffff|Hitem:17034:0:0:0:0:0:0:0|h[Maple Seed]|h|r#1#20#0#Miscellaneous#Reagent#20##Interface\\Icons\\INV_Misc_Food_02",
	[17035] = "Stranglethorn Seed#|cffffffff|Hitem:17035:0:0:0:0:0:0:0|h[Stranglethorn Seed]|h|r#1#30#0#Reagent#Reagent#20##Interface\\Icons\\INV_Misc_Food_02",
	[18256] = "Imbued Vial#|cffffffff|Hitem:18256:0:0:0:0:0:0:0|h[Imbued Vial]|h|r#1#55#0#Trade Goods#Other#20##Interface\\Icons\\INV_Drink_06",
	[20725] = "Nexus Crystal#|cffa335ee|Hitem:20725:0:0:0:0:0:0:0:88:0:0|h[Nexus Crystal]|h|r#4#60#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Enchant_ShardNexusLarge",
	[21884] = "Primal Fire#|cff1eff00|Hitem:21884:0:0:0:0:0:0:0:70|h[Primal Fire]|h|r#2#65#0#Trade Goods#Elemental#20##Interface\\Icons\\INV_Elemental_Primal_Fire",
	[21885] = "Primal Water#|cff1eff00|Hitem:21885:0:0:0:0:0:0:0:70|h[Primal Water]|h|r#2#65#0#Trade Goods#Elemental#20##Interface\\Icons\\INV_Elemental_Primal_Water",
	[21886] = "Primal Life#|cff1eff00|Hitem:21886:0:0:0:0:0:0:0:73|h[Primal Life]|h|r#2#65#0#Trade Goods#Elemental#20##Interface\\Icons\\INV_Elemental_Primal_Life",
	[21929] = "Flame Spessarite#|cff1eff00|Hitem:21929:0:0:0:0:0:0:0:88:0:0|h[Flame Spessarite]|h|r#2#65#0#Gem#Orange#20##Interface\\Icons\\INV_Misc_Gem_FlameSpessarite_03",
	[22445] = "Arcane Dust#|cffffffff|Hitem:22445:0:0:0:0:0:0:0:88:0:0|h[Arcane Dust]|h|r#1#60#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Enchant_DustArcane",
	[22446] = "Greater Planar Essence#|cff1eff00|Hitem:22446:0:0:0:0:0:0:0:88:0:0|h[Greater Planar Essence]|h|r#2#65#0#Trade Goods#Enchanting#10##Interface\\Icons\\INV_Enchant_EssenceArcaneLarge",
	[22447] = "Lesser Planar Essence#|cff1eff00|Hitem:22447:0:0:0:0:0:0:0:88:0:0|h[Lesser Planar Essence]|h|r#2#60#0#Trade Goods#Enchanting#10##Interface\\Icons\\INV_Enchant_EssenceArcaneSmall",
	[22448] = "Small Prismatic Shard#|cff0070dd|Hitem:22448:0:0:0:0:0:0:0:88:0:0|h[Small Prismatic Shard]|h|r#3#65#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Enchant_ShardPrismaticSmall",
	[22449] = "Large Prismatic Shard#|cff0070dd|Hitem:22449:0:0:0:0:0:0:0:85:0:0|h[Large Prismatic Shard]|h|r#3#70#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Enchant_ShardPrismaticLarge",
	[22450] = "Void Crystal#|cffa335ee|Hitem:22450:0:0:0:0:0:0:0:88:0:0|h[Void Crystal]|h|r#4#70#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Enchant_VoidCrystal",
	[22451] = "Primal Air#|cff1eff00|Hitem:22451:0:0:0:0:0:0:0:72|h[Primal Air]|h|r#2#65#0#Trade Goods#Elemental#20##Interface\\Icons\\INV_Elemental_Primal_Air",
	[22452] = "Primal Earth#|cff1eff00|Hitem:22452:0:0:0:0:0:0:0:72|h[Primal Earth]|h|r#2#65#0#Trade Goods#Elemental#20##Interface\\Icons\\INV_Elemental_Primal_Earth",
	[22456] = "Primal Shadow#|cff1eff00|Hitem:22456:0:0:0:0:0:0:0|h[Primal Shadow]|h|r#2#65#0#Trade Goods#Elemental#20##Interface\\Icons\\INV_Elemental_Primal_Shadow",
	[22457] = "Primal Mana#|cff1eff00|Hitem:22457:0:0:0:0:0:0:0:70|h[Primal Mana]|h|r#2#65#0#Trade Goods#Elemental#20##Interface\\Icons\\INV_Elemental_Primal_Mana",
	[22573] = "Mote of Earth#|cffffffff|Hitem:22573:0:0:0:0:0:0:0|h[Mote of Earth]|h|r#1#65#0#Trade Goods#Elemental#10##Interface\\Icons\\INV_Elemental_Mote_Earth01",
	[22577] = "Mote of Shadow#|cffffffff|Hitem:22577:0:0:0:0:0:0:0:70|h[Mote of Shadow]|h|r#1#65#0#Trade Goods#Elemental#10##Interface\\Icons\\INV_Elemental_Mote_Shadow01",
	[22789] = "Terocone#|cffffffff|Hitem:22789:0:0:0:0:0:0:0|h[Terocone]|h|r#1#60#0#Trade Goods#Herb#20##Interface\\Icons\\INV_Misc_Herb_Terrocone",
	[22790] = "Ancient Lichen#|cffffffff|Hitem:22790:0:0:0:0:0:0:0|h[Ancient Lichen]|h|r#1#68#0#Trade Goods#Herb#20##Interface\\Icons\\INV_MISC_HERB_ANCIENTLICHEN",
	[22792] = "Nightmare Vine#|cffffffff|Hitem:22792:0:0:0:0:0:0:0|h[Nightmare Vine]|h|r#1#73#0#Trade Goods#Herb#20##Interface\\Icons\\INV_Misc_Herb_Nightmarevine",
	[22793] = "Mana Thistle#|cffffffff|Hitem:22793:0:0:0:0:0:0:0|h[Mana Thistle]|h|r#1#75#0#Trade Goods#Herb#20##Interface\\Icons\\INV_Misc_Herb_Manathistle",
	[22794] = "Fel Lotus#|cffffffff|Hitem:22794:0:0:0:0:0:0:0|h[Fel Lotus]|h|r#1#75#0#Trade Goods#Herb#20##Interface\\Icons\\INV_Misc_Herb_FelLotus",
	[22824] = "Elixir of Major Strength#|cffffffff|Hitem:22824:0:0:0:0:0:0:0|h[Elixir of Major Strength]|h|r#1#61#50#Consumable#Elixir#20##Interface\\Icons\\INV_Potion_147",
	[22832] = "Super Mana Potion#|cffffffff|Hitem:22832:0:0:0:0:0:0:0:70|h[Super Mana Potion]|h|r#1#68#55#Consumable#Potion#5##Interface\\Icons\\INV_Potion_137",
	[23077] = "Blood Garnet#|cff1eff00|Hitem:23077:0:0:0:0:0:0:0:88:0:0|h[Blood Garnet]|h|r#2#65#0#Gem#Red#20##Interface\\Icons\\INV_Misc_Gem_BloodGem_03",
	[23079] = "Deep Peridot#|cff1eff00|Hitem:23079:0:0:0:0:0:0:0:88:0:0|h[Deep Peridot]|h|r#2#65#0#Gem#Green#20##Interface\\Icons\\INV_Misc_Gem_DeepPeridot_03",
	[23107] = "Shadow Draenite#|cff1eff00|Hitem:23107:0:0:0:0:0:0:0:88:0:0|h[Shadow Draenite]|h|r#2#65#0#Gem#Purple#20##Interface\\Icons\\INV_Misc_Gem_EbonDraenite_03",
	[23112] = "Golden Draenite#|cff1eff00|Hitem:23112:0:0:0:0:0:0:0:88:0:0|h[Golden Draenite]|h|r#2#65#0#Gem#Yellow#20##Interface\\Icons\\INV_Misc_Gem_GoldenDraenite_03",
	[23117] = "Azure Moonstone#|cff1eff00|Hitem:23117:0:0:0:0:0:0:0:88:0:0|h[Azure Moonstone]|h|r#2#65#0#Gem#Blue#20##Interface\\Icons\\INV_Misc_Gem_AzureDraenite_03",
	[23424] = "Fel Iron Ore#|cffffffff|Hitem:23424:0:0:0:0:0:0:0:88:0:0|h[Fel Iron Ore]|h|r#1#60#0#Trade Goods#Metal & Stone#20##Interface\\Icons\\INV_Ore_FelIron",
	[23425] = "Adamantite Ore#|cffffffff|Hitem:23425:0:0:0:0:0:0:0:88:0:0|h[Adamantite Ore]|h|r#1#65#0#Trade Goods#Metal & Stone#20##Interface\\Icons\\INV_Ore_Adamantium",
	[23427] = "Eternium Ore#|cff1eff00|Hitem:23427:0:0:0:0:0:0:0:70|h[Eternium Ore]|h|r#2#70#0#Trade Goods#Metal & Stone#20##Interface\\Icons\\INV_Ore_Eternium",
	[23436] = "Living Ruby#|cff0070dd|Hitem:23436:0:0:0:0:0:0:0:88:0:0|h[Living Ruby]|h|r#3#70#0#Gem#Red#20##Interface\\Icons\\INV_Jewelcrafting_LivingRuby_02",
	[23437] = "Talasite#|cff0070dd|Hitem:23437:0:0:0:0:0:0:0:88:0:0|h[Talasite]|h|r#3#70#0#Gem#Green#20##Interface\\Icons\\INV_Jewelcrafting_Talasite_02",
	[23438] = "Star of Elune#|cff0070dd|Hitem:23438:0:0:0:0:0:0:0:88:0:0|h[Star of Elune]|h|r#3#70#0#Gem#Blue#20##Interface\\Icons\\INV_Jewelcrafting_StarOfElune_02",
	[23439] = "Noble Topaz#|cff0070dd|Hitem:23439:0:0:0:0:0:0:0:88:0:0|h[Noble Topaz]|h|r#3#70#0#Gem#Orange#20##Interface\\Icons\\INV_Jewelcrafting_NobleTopaz_02",
	[23440] = "Dawnstone#|cff0070dd|Hitem:23440:0:0:0:0:0:0:0:88:0:0|h[Dawnstone]|h|r#3#70#0#Gem#Yellow#20##Interface\\Icons\\INV_Jewelcrafting_Dawnstone_02",
	[23441] = "Nightseye#|cff0070dd|Hitem:23441:0:0:0:0:0:0:0:88:0:0|h[Nightseye]|h|r#3#70#0#Gem#Purple#20##Interface\\Icons\\INV_Jewelcrafting_Nightseye_02",
	[23445] = "Fel Iron Bar#|cffffffff|Hitem:23445:0:0:0:0:0:0:0|h[Fel Iron Bar]|h|r#1#60#0#Trade Goods#Metal & Stone#20##Interface\\Icons\\INV_Ingot_FelIron",
	[23446] = "Adamantite Bar#|cffffffff|Hitem:23446:0:0:0:0:0:0:0|h[Adamantite Bar]|h|r#1#65#0#Trade Goods#Metal & Stone#20##Interface\\Icons\\INV_Ingot_10",
	[23447] = "Eternium Bar#|cff1eff00|Hitem:23447:0:0:0:0:0:0:0|h[Eternium Bar]|h|r#2#70#0#Trade Goods#Metal & Stone#20##Interface\\Icons\\INV_Ingot_11",
	[23448] = "Felsteel Bar#|cff1eff00|Hitem:23448:0:0:0:0:0:0:0|h[Felsteel Bar]|h|r#2#60#0#Trade Goods#Metal & Stone#20##Interface\\Icons\\INV_Ingot_Felsteel",
	[23449] = "Khorium Bar#|cff1eff00|Hitem:23449:0:0:0:0:0:0:0|h[Khorium Bar]|h|r#2#70#0#Trade Goods#Metal & Stone#20##Interface\\Icons\\INV_Ingot_09",
	[23571] = "Primal Might#|cff0070dd|Hitem:23571:0:0:0:0:0:0:0|h[Primal Might]|h|r#3#65#0#Trade Goods#Elemental#20##Interface\\Icons\\Spell_Nature_LightningOverload",
	[23572] = "Primal Nether#|cff0070dd|Hitem:23572:0:0:0:0:0:0:0|h[Primal Nether]|h|r#3#65#0#Trade Goods#Materials#20##Interface\\Icons\\INV_Elemental_Primal_Nether",
	[24243] = "Adamantite Powder#|cffffffff|Hitem:24243:0:0:0:0:0:0:0:88:0:0|h[Adamantite Powder]|h|r#1#70#0#Trade Goods#Jewelcrafting#20##Interface\\Icons\\INV_Misc_Powder_Adamantite",
	[30183] = "Nether Vortex#|cffa335ee|Hitem:30183:0:0:0:0:0:0:0|h[Nether Vortex]|h|r#4#75#0#Trade Goods#Materials#20##Interface\\Icons\\INV_Elemental_Mote_Nether",
	[34052] = "Dream Shard#|cff0070dd|Hitem:34052:0:0:0:0:0:0:0:88:0:0|h[Dream Shard]|h|r#3#80#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Enchant_DreamShard_02",
	[34053] = "Small Dream Shard#|cff0070dd|Hitem:34053:0:0:0:0:0:0:0:88:0:0|h[Small Dream Shard]|h|r#3#80#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Enchant_DreamShard_01",
	[34054] = "Infinite Dust#|cffffffff|Hitem:34054:0:0:0:0:0:0:0:88:0:0|h[Infinite Dust]|h|r#1#70#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Misc_Dust_Infinite",
	[34055] = "Greater Cosmic Essence#|cff1eff00|Hitem:34055:0:0:0:0:0:0:0:88:0:0|h[Greater Cosmic Essence]|h|r#2#75#0#Trade Goods#Enchanting#10##Interface\\Icons\\INV_Enchant_EssenceCosmicGreater",
	[34056] = "Lesser Cosmic Essence#|cff1eff00|Hitem:34056:0:0:0:0:0:0:0:88:0:0|h[Lesser Cosmic Essence]|h|r#2#70#0#Trade Goods#Enchanting#10##Interface\\Icons\\INV_Enchant_EssenceCosmicLesser",
	[34057] = "Abyss Crystal#|cffa335ee|Hitem:34057:0:0:0:0:0:0:0:88:0:0|h[Abyss Crystal]|h|r#4#80#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Enchant_AbyssCrystal",
	[35622] = "Eternal Water#|cff1eff00|Hitem:35622:0:0:0:0:0:0:0:80|h[Eternal Water]|h|r#2#75#0#Trade Goods#Elemental#20##Interface\\Icons\\INV_Elemental_Eternal_Water",
	[35623] = "Eternal Air#|cff1eff00|Hitem:35623:0:0:0:0:0:0:0:80:0|h[Eternal Air]|h|r#2#75#0#Trade Goods#Elemental#20##Interface\\Icons\\INV_Elemental_Eternal_Air",
	[35624] = "Eternal Earth#|cff1eff00|Hitem:35624:0:0:0:0:0:0:0:80|h[Eternal Earth]|h|r#2#75#0#Trade Goods#Elemental#20##Interface\\Icons\\INV_Elemental_Eternal_Earth",
	[35625] = "Eternal Life#|cff1eff00|Hitem:35625:0:0:0:0:0:0:0:80|h[Eternal Life]|h|r#2#75#0#Trade Goods#Elemental#20##Interface\\Icons\\INV_Elemental_Eternal_Life",
	[35627] = "Eternal Shadow#|cff1eff00|Hitem:35627:0:0:0:0:0:0:0:80|h[Eternal Shadow]|h|r#2#75#0#Trade Goods#Elemental#20##Interface\\Icons\\INV_Elemental_Eternal_Shadow",
	[36784] = "Siren's Tear#|cff0070dd|Hitem:36784:0:0:0:0:0:0:0:80|h[Siren's Tear]|h|r#3#75#0#Gem#Simple#20##Interface\\Icons\\INV_Misc_Gem_Pearl_11",
	[36860] = "Eternal Fire#|cff1eff00|Hitem:36860:0:0:0:0:0:0:0:80|h[Eternal Fire]|h|r#2#75#0#Trade Goods#Elemental#20##Interface\\Icons\\INV_Elemental_Eternal_Fire",
	[36901] = "Goldclover#|cffffffff|Hitem:36901:0:0:0:0:0:0:0:80|h[Goldclover]|h|r#1#72#0#Trade Goods#Herb#20##Interface\\Icons\\INV_Misc_Herb_GoldClover",
	[36903] = "Adder's Tongue#|cffffffff|Hitem:36903:0:0:0:0:0:0:0:80|h[Adder's Tongue]|h|r#1#77#0#Trade Goods#Herb#20##Interface\\Icons\\INV_Misc_Herb_EvergreenMoss",
	[36904] = "Tiger Lily#|cffffffff|Hitem:36904:0:0:0:0:0:0:0:70|h[Tiger Lily]|h|r#1#72#0#Trade Goods#Herb#20##Interface\\Icons\\INV_Misc_Herb_Tigerlily",
	[36905] = "Lichbloom#|cffffffff|Hitem:36905:0:0:0:0:0:0:0:62|h[Lichbloom]|h|r#1#80#0#Trade Goods#Herb#20##Interface\\Icons\\INV_Misc_Herb_Whispervine",
	[36906] = "Icethorn#|cffffffff|Hitem:36906:0:0:0:0:0:0:0:62|h[Icethorn]|h|r#1#80#0#Trade Goods#Herb#20##Interface\\Icons\\INV_Misc_Herb_IceThorn",
	[36907] = "Talandra's Rose#|cffffffff|Hitem:36907:0:0:0:0:0:0:0:80|h[Talandra's Rose]|h|r#1#72#0#Trade Goods#Herb#20##Interface\\Icons\\INV_Misc_Herb_TalandrasRose",
	[36908] = "Frost Lotus#|cff1eff00|Hitem:36908:0:0:0:0:0:0:0:62|h[Frost Lotus]|h|r#2#80#0#Trade Goods#Herb#20##Interface\\Icons\\INV_Misc_Herb_FrostLotus",
	[36909] = "Cobalt Ore#|cffffffff|Hitem:36909:0:0:0:0:0:0:0:88:0:0|h[Cobalt Ore]|h|r#1#72#0#Trade Goods#Metal & Stone#20##Interface\\Icons\\INV_Ore_Cobalt",
	[36910] = "Titanium Ore#|cff1eff00|Hitem:36910:0:0:0:0:0:0:0:88:0:0|h[Titanium Ore]|h|r#2#80#0#Trade Goods#Metal & Stone#20##Interface\\Icons\\INV_Ore_Platinum_01",
	[36912] = "Saronite Ore#|cffffffff|Hitem:36912:0:0:0:0:0:0:0:88:0:0|h[Saronite Ore]|h|r#1#75#0#Trade Goods#Metal & Stone#20##Interface\\Icons\\INV_Ore_Saronite_01",
	[36913] = "Saronite Bar#|cffffffff|Hitem:36913:0:0:0:0:0:0:0:80:0|h[Saronite Bar]|h|r#1#80#0#Trade Goods#Metal & Stone#20##Interface\\Icons\\INV_Ingot_Yoggthorite",
	[36917] = "Bloodstone#|cff1eff00|Hitem:36917:0:0:0:0:0:0:0:88:0:0|h[Bloodstone]|h|r#2#75#0#Gem#Red#20##Interface\\Icons\\INV_Jewelcrafting_Gem_12",
	[36918] = "Scarlet Ruby#|cff0070dd|Hitem:36918:0:0:0:0:0:0:0:88:0:0|h[Scarlet Ruby]|h|r#3#80#0#Gem#Red#20##Interface\\Icons\\INV_Jewelcrafting_Gem_04",
	[36919] = "Cardinal Ruby#|cffa335ee|Hitem:36919:0:0:0:0:0:0:0:88:0:0|h[Cardinal Ruby]|h|r#4#80#0#Gem#Red#20##Interface\\Icons\\inv_jewelcrafting_gem_32",
	[36920] = "Sun Crystal#|cff1eff00|Hitem:36920:0:0:0:0:0:0:0:88:0:0|h[Sun Crystal]|h|r#2#75#0#Gem#Yellow#20##Interface\\Icons\\INV_Jewelcrafting_Gem_08",
	[36921] = "Autumn's Glow#|cff0070dd|Hitem:36921:0:0:0:0:0:0:0:88:0:0|h[Autumn's Glow]|h|r#3#80#0#Gem#Yellow#20##Interface\\Icons\\INV_Jewelcrafting_Gem_03",
	[36922] = "King's Amber#|cffa335ee|Hitem:36922:0:0:0:0:0:0:0:88:0:0|h[King's Amber]|h|r#4#80#0#Gem#Yellow#20##Interface\\Icons\\inv_jewelcrafting_gem_36",
	[36923] = "Chalcedony#|cff1eff00|Hitem:36923:0:0:0:0:0:0:0:88:0:0|h[Chalcedony]|h|r#2#75#0#Gem#Blue#20##Interface\\Icons\\INV_Jewelcrafting_Gem_10",
	[36924] = "Sky Sapphire#|cff0070dd|Hitem:36924:0:0:0:0:0:0:0:88:0:0|h[Sky Sapphire]|h|r#3#80#0#Gem#Blue#20##Interface\\Icons\\INV_Jewelcrafting_Gem_05",
	[36925] = "Majestic Zircon#|cffa335ee|Hitem:36925:0:0:0:0:0:0:0:88:0:0|h[Majestic Zircon]|h|r#4#80#0#Gem#Blue#20##Interface\\Icons\\inv_jewelcrafting_gem_35",
	[36926] = "Shadow Crystal#|cff1eff00|Hitem:36926:0:0:0:0:0:0:0:88:0:0|h[Shadow Crystal]|h|r#2#75#0#Gem#Purple#20##Interface\\Icons\\INV_Jewelcrafting_Gem_11",
	[36927] = "Twilight Opal#|cff0070dd|Hitem:36927:0:0:0:0:0:0:0:88:0:0|h[Twilight Opal]|h|r#3#80#0#Gem#Purple#20##Interface\\Icons\\INV_Jewelcrafting_Gem_06",
	[36928] = "Dreadstone#|cffa335ee|Hitem:36928:0:0:0:0:0:0:0:88:0:0|h[Dreadstone]|h|r#4#80#0#Gem#Purple#20##Interface\\Icons\\inv_jewelcrafting_gem_31",
	[36929] = "Huge Citrine#|cff1eff00|Hitem:36929:0:0:0:0:0:0:0:88:0:0|h[Huge Citrine]|h|r#2#75#0#Gem#Orange#20##Interface\\Icons\\INV_Jewelcrafting_Gem_09",
	[36930] = "Monarch Topaz#|cff0070dd|Hitem:36930:0:0:0:0:0:0:0:88:0:0|h[Monarch Topaz]|h|r#3#80#0#Gem#Orange#20##Interface\\Icons\\INV_Jewelcrafting_Gem_02",
	[36931] = "Ametrine#|cffa335ee|Hitem:36931:0:0:0:0:0:0:0:88:0:0|h[Ametrine]|h|r#4#80#0#Gem#Orange#20##Interface\\Icons\\inv_jewelcrafting_gem_33",
	[36932] = "Dark Jade#|cff1eff00|Hitem:36932:0:0:0:0:0:0:0:88:0:0|h[Dark Jade]|h|r#2#75#0#Gem#Green#20##Interface\\Icons\\INV_Jewelcrafting_Gem_07",
	[36933] = "Forest Emerald#|cff0070dd|Hitem:36933:0:0:0:0:0:0:0:88:0:0|h[Forest Emerald]|h|r#3#80#0#Gem#Green#20##Interface\\Icons\\INV_Jewelcrafting_Gem_01",
	[36934] = "Eye of Zul#|cffa335ee|Hitem:36934:0:0:0:0:0:0:0:88:0:0|h[Eye of Zul]|h|r#4#80#0#Gem#Green#20##Interface\\Icons\\inv_jewelcrafting_gem_34",
	[37663] = "Titansteel Bar#|cff1eff00|Hitem:37663:0:0:0:0:0:0:0:43|h[Titansteel Bar]|h|r#2#80#0#Trade Goods#Metal & Stone#20##Interface\\Icons\\INV_Ingot_Titansteel_blue",
	[37701] = "Crystallized Earth#|cffffffff|Hitem:37701:0:0:0:0:0:0:0:70|h[Crystallized Earth]|h|r#1#75#0#Trade Goods#Elemental#10##Interface\\Icons\\INV_Crystallized_Earth",
	[37704] = "Crystallized Life#|cffffffff|Hitem:37704:0:0:0:0:0:0:0:62|h[Crystallized Life]|h|r#1#75#0#Trade Goods#Elemental#10##Interface\\Icons\\INV_Elemental_Crystal_Life",
	[37705] = "Crystallized Water#|cffffffff|Hitem:37705:0:0:0:0:0:0:0:80:0|h[Crystallized Water]|h|r#1#75#0#Trade Goods#Elemental#10##Interface\\Icons\\INV_Elemental_Crystal_Water",
	[38426] = "Eternium Thread#|cffffffff|Hitem:38426:0:0:0:0:0:0:0:80|h[Eternium Thread]|h|r#1#70#0#Trade Goods#Cloth#20##Interface\\Icons\\INV_Misc_Thread_01",
	[39151] = "Alabaster Pigment#|cffffffff|Hitem:39151:0:0:0:0:0:0:0:88:0:0|h[Alabaster Pigment]|h|r#1#1#0#Trade Goods#Other#20##Interface\\Icons\\INV_Inscription_Pigment_White",
	[39334] = "Dusky Pigment#|cffffffff|Hitem:39334:0:0:0:0:0:0:0:86:0:0|h[Dusky Pigment]|h|r#1#10#0#Trade Goods#Other#20##Interface\\Icons\\INV_Inscription_Pigment_Grey",
	[39338] = "Golden Pigment#|cffffffff|Hitem:39338:0:0:0:0:0:0:0:86:0:0|h[Golden Pigment]|h|r#1#20#0#Trade Goods#Other#20##Interface\\Icons\\INV_Inscription_Pigment_Golden",
	[39339] = "Emerald Pigment#|cffffffff|Hitem:39339:0:0:0:0:0:0:0:86:0:0|h[Emerald Pigment]|h|r#1#30#0#Trade Goods#Other#20##Interface\\Icons\\INV_Inscription_Pigment_Emerald",
	[39340] = "Violet Pigment#|cffffffff|Hitem:39340:0:0:0:0:0:0:0:86:0:0|h[Violet Pigment]|h|r#1#40#0#Trade Goods#Other#20##Interface\\Icons\\INV_Inscription_Pigment_Violet",
	[39341] = "Silvery Pigment#|cffffffff|Hitem:39341:0:0:0:0:0:0:0:86:0:0|h[Silvery Pigment]|h|r#1#50#0#Trade Goods#Other#20##Interface\\Icons\\INV_Inscription_Pigment_Silvery",
	[39342] = "Nether Pigment#|cffffffff|Hitem:39342:0:0:0:0:0:0:0:85:0:0|h[Nether Pigment]|h|r#1#60#0#Trade Goods#Other#20##Interface\\Icons\\INV_Inscription_Pigment_Nether",
	[39343] = "Azure Pigment#|cffffffff|Hitem:39343:0:0:0:0:0:0:0:85:0:0|h[Azure Pigment]|h|r#1#70#0#Trade Goods#Other#20##Interface\\Icons\\INV_Inscription_Pigment_Azure",
	[39354] = "Light Parchment#|cffffffff|Hitem:39354:0:0:0:0:0:0:0:70|h[Light Parchment]|h|r#1#1#0#Trade Goods#Other#20##Interface\\Icons\\INV_Inscription_Papyrus",
	[39469] = "Moonglow Ink#|cffffffff|Hitem:39469:0:0:0:0:0:0:0:70|h[Moonglow Ink]|h|r#1#1#0#Trade Goods#Parts#20##Interface\\Icons\\INV_Inscription_InkWhite02",
	[39501] = "Heavy Parchment#|cffffffff|Hitem:39501:0:0:0:0:0:0:0:70|h[Heavy Parchment]|h|r#1#60#0#Trade Goods#Other#20##Interface\\Icons\\INV_Misc_Note_02",
	[39502] = "Resilient Parchment#|cffffffff|Hitem:39502:0:0:0:0:0:0:0:80|h[Resilient Parchment]|h|r#1#80#0#Trade Goods#Other#20##Interface\\Icons\\INV_Inscription_Certificate",
	[39774] = "Midnight Ink#|cffffffff|Hitem:39774:0:0:0:0:0:0:0:70|h[Midnight Ink]|h|r#1#10#0#Trade Goods#Parts#20##Interface\\Icons\\INV_Inscription_InkBlack01",
	[39970] = "Fire Leaf#|cffffffff|Hitem:39970:0:0:0:0:0:0:0:62|h[Fire Leaf]|h|r#1#75#0#Consumable#Other#20##Interface\\Icons\\INV_Misc_Herb_11a",
	[40411] = "Enchanted Vial#|cffffffff|Hitem:40411:0:0:0:0:0:0:0:80|h[Enchanted Vial]|h|r#1#75#0#Trade Goods#Other#20##Interface\\Icons\\INV_Alchemy_EnchantedVial",
	[41163] = "Titanium Bar#|cff1eff00|Hitem:41163:0:0:0:0:0:0:0:80:0|h[Titanium Bar]|h|r#2#80#0#Trade Goods#Metal & Stone#20##Interface\\Icons\\INV_Ingot_Platinum",
	[43102] = "Frozen Orb#|cff0070dd|Hitem:43102:0:0:0:0:0:0:0:80|h[Frozen Orb]|h|r#3#80#0#Trade Goods#Other#20##Interface\\Icons\\Spell_Frost_FrozenCore",
	[43103] = "Verdant Pigment#|cff1eff00|Hitem:43103:0:0:0:0:0:0:0:88:0:0|h[Verdant Pigment]|h|r#2#20#0#Trade Goods#Other#20##Interface\\Icons\\INV_Inscription_Pigment_Verdant",
	[43104] = "Burnt Pigment#|cff1eff00|Hitem:43104:0:0:0:0:0:0:0:85:0:0|h[Burnt Pigment]|h|r#2#30#0#Trade Goods#Other#20##Interface\\Icons\\INV_Inscription_Pigment_Burnt",
	[43105] = "Indigo Pigment#|cff1eff00|Hitem:43105:0:0:0:0:0:0:0:86:0:0|h[Indigo Pigment]|h|r#2#40#0#Trade Goods#Other#20##Interface\\Icons\\INV_Inscription_Pigment_Indigo",
	[43106] = "Ruby Pigment#|cff1eff00|Hitem:43106:0:0:0:0:0:0:0:86:0:0|h[Ruby Pigment]|h|r#2#50#0#Trade Goods#Other#20##Interface\\Icons\\INV_Inscription_Pigment_Ruby",
	[43107] = "Sapphire Pigment#|cff1eff00|Hitem:43107:0:0:0:0:0:0:0:86:0:0|h[Sapphire Pigment]|h|r#2#60#0#Trade Goods#Other#20##Interface\\Icons\\INV_Inscription_Pigment_Sapphire",
	[43108] = "Ebon Pigment#|cff1eff00|Hitem:43108:0:0:0:0:0:0:0:85:0:0|h[Ebon Pigment]|h|r#2#70#0#Trade Goods#Other#20##Interface\\Icons\\INV_Inscription_Pigment_Ebon",
	[43109] = "Icy Pigment#|cff1eff00|Hitem:43109:0:0:0:0:0:0:0:85:0:0|h[Icy Pigment]|h|r#2#80#0#Trade Goods#Other#20##Interface\\Icons\\INV_Inscription_Pigment_Icy",
	[43116] = "Lion's Ink#|cffffffff|Hitem:43116:0:0:0:0:0:0:0:70|h[Lion's Ink]|h|r#1#20#0#Trade Goods#Parts#20##Interface\\Icons\\INV_Inscription_InkYellow02",
	[43126] = "Ink of the Sea#|cffffffff|Hitem:43126:0:0:0:0:0:0:0:80|h[Ink of the Sea]|h|r#1#70#0#Trade Goods#Parts#20##Interface\\Icons\\INV_Inscription_InkPurple01",
	[43127] = "Snowfall Ink#|cff1eff00|Hitem:43127:0:0:0:0:0:0:0:80:0|h[Snowfall Ink]|h|r#2#70#0#Trade Goods#Parts#20##Interface\\Icons\\INV_Inscription_InkBlueWhite01",
	[46849] = "Titanium Powder#|cff1eff00|Hitem:46849:0:0:0:0:0:0:0:88:0:0|h[Titanium Powder]|h|r#2#80#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Misc_Dust_03",
	[52177] = "Carnelian#|cff1eff00|Hitem:52177:0:0:0:0:0:0:0:88:0:0|h[Carnelian]|h|r#2#81#0#Gem#Red#20##Interface\\Icons\\inv_misc_uncutgemsuperior4",
	[52178] = "Zephyrite#|cff1eff00|Hitem:52178:0:0:0:0:0:0:0:88:0:0|h[Zephyrite]|h|r#2#81#0#Gem#Blue#20##Interface\\Icons\\inv_misc_uncutgemsuperior6",
	[52179] = "Alicite#|cff1eff00|Hitem:52179:0:0:0:0:0:0:0:88:0:0|h[Alicite]|h|r#2#81#0#Gem#Yellow#20##Interface\\Icons\\inv_misc_uncutgemsuperior",
	[52180] = "Nightstone#|cff1eff00|Hitem:52180:0:0:0:0:0:0:0:88:0:0|h[Nightstone]|h|r#2#81#0#Gem#Purple#20##Interface\\Icons\\inv_misc_uncutgemsuperior3",
	[52181] = "Hessonite#|cff1eff00|Hitem:52181:0:0:0:0:0:0:0:88:0:0|h[Hessonite]|h|r#2#81#0#Gem#Orange#20##Interface\\Icons\\inv_misc_uncutgemsuperior5",
	[52182] = "Jasper#|cff1eff00|Hitem:52182:0:0:0:0:0:0:0:88:0:0|h[Jasper]|h|r#2#81#0#Gem#Green#20##Interface\\Icons\\inv_misc_uncutgemsuperior2",
	[52183] = "Pyrite Ore#|cff1eff00|Hitem:52183:0:0:0:0:0:0:0:88:0:0|h[Pyrite Ore]|h|r#2#85#0#Trade Goods#Metal & Stone#20##Interface\\Icons\\inv_ore_arcanite_01",
	[52185] = "Elementium Ore#|cffffffff|Hitem:52185:0:0:0:0:0:0:0:88:0:0|h[Elementium Ore]|h|r#1#83#0#Trade Goods#Metal & Stone#20##Interface\\Icons\\item_pyriumore",
	[52190] = "Inferno Ruby#|cff0070dd|Hitem:52190:0:0:0:0:0:0:0:88:0:0|h[Inferno Ruby]|h|r#3#84#0#Gem#Red#20##Interface\\Icons\\inv_misc_uncutgemnormal3",
	[52191] = "Ocean Sapphire#|cff0070dd|Hitem:52191:0:0:0:0:0:0:0:88:0:0|h[Ocean Sapphire]|h|r#3#84#0#Gem#Blue#20##Interface\\Icons\\inv_misc_uncutgemnormal2",
	[52192] = "Dream Emerald#|cff0070dd|Hitem:52192:0:0:0:0:0:0:0:88:0:0|h[Dream Emerald]|h|r#3#84#0#Gem#Green#20##Interface\\Icons\\inv_misc_uncutgemnormal1",
	[52193] = "Ember Topaz#|cff0070dd|Hitem:52193:0:0:0:0:0:0:0:88:0:0|h[Ember Topaz]|h|r#3#84#0#Gem#Orange#20##Interface\\Icons\\inv_misc_uncutgemnormal",
	[52194] = "Demonseye#|cff0070dd|Hitem:52194:0:0:0:0:0:0:0:88:0:0|h[Demonseye]|h|r#3#84#0#Gem#Purple#20##Interface\\Icons\\inv_misc_uncutgemnormal4",
	[52195] = "Amberjewel#|cff0070dd|Hitem:52195:0:0:0:0:0:0:0:88:0:0|h[Amberjewel]|h|r#3#84#0#Gem#Yellow#20##Interface\\Icons\\inv_misc_uncutgemnormal5",
	[52327] = "Volatile Earth#|cffffffff|Hitem:52327:0:0:0:0:0:0:0:88:0:0|h[Volatile Earth]|h|r#1#83#0#Trade Goods#Elemental#200##Interface\\Icons\\inv_misc_volatileearth",
	[52555] = "Hypnotic Dust#|cffffffff|Hitem:52555:0:0:0:0:0:0:0:85:0:0|h[Hypnotic Dust]|h|r#1#81#0#Trade Goods#Enchanting#20##Interface\\Icons\\inv_enchant_dust",
	[52718] = "Lesser Celestial Essence#|cff1eff00|Hitem:52718:0:0:0:0:0:0:0:85:0:0|h[Lesser Celestial Essence]|h|r#2#81#0#Trade Goods#Enchanting#10##Interface\\Icons\\inv_misc_lesseressence",
	[52719] = "Greater Celestial Essence#|cff1eff00|Hitem:52719:0:0:0:0:0:0:0:85:0:0|h[Greater Celestial Essence]|h|r#2#83#0#Trade Goods#Enchanting#10##Interface\\Icons\\inv_misc_greateressence",
	[52720] = "Small Heavenly Shard#|cff0070dd|Hitem:52720:0:0:0:0:0:0:0:85:0:0|h[Small Heavenly Shard]|h|r#3#85#0#Trade Goods#Enchanting#20##Interface\\Icons\\inv_misc_smallshard_superior",
	[52721] = "Heavenly Shard#|cff0070dd|Hitem:52721:0:0:0:0:0:0:0:85:0:0|h[Heavenly Shard]|h|r#3#85#0#Trade Goods#Enchanting#20##Interface\\Icons\\inv_misc_largeshard_superior",
	[52722] = "Maelstrom Crystal#|cffa335ee|Hitem:52722:0:0:0:0:0:0:0:85:0:0|h[Maelstrom Crystal]|h|r#4#85#0#Trade Goods#Enchanting#20##Interface\\Icons\\inv_misc_crystalepic",
	[53038] = "Obsidium Ore#|cffffffff|Hitem:53038:0:0:0:0:0:0:0:88:0:0|h[Obsidium Ore]|h|r#1#81#0#Trade Goods#Metal & Stone#20##Interface\\Icons\\item_elementiumore",
	[61978] = "Blackfallow Ink#|cffffffff|Hitem:61978:0:0:0:0:0:0:0:85:0:0|h[Blackfallow Ink]|h|r#1#81#0#Trade Goods#Parts#20##Interface\\Icons\\inv_inscription_inkblack03",
	[61979] = "Ashen Pigment#|cffffffff|Hitem:61979:0:0:0:0:0:0:0:85:0:0|h[Ashen Pigment]|h|r#1#81#0#Trade Goods#Other#20##Interface\\Icons\\inv_misc_ashenpigment",
	[61980] = "Burning Embers#|cff1eff00|Hitem:61980:0:0:0:0:0:0:0:85:0:0|h[Burning Embers]|h|r#2#81#0#Trade Goods#Other#20##Interface\\Icons\\inv_misc_embers",
	[61981] = "Inferno Ink#|cff1eff00|Hitem:61981:0:0:0:0:0:0:0:80:0|h[Inferno Ink]|h|r#2#85#0#Trade Goods#Parts#20##Interface\\Icons\\inv_inscription_inkred03",
	[72092] = "Ghost Iron Ore#|cffffffff|Hitem:72092:0:0:0:0:0:0:0:85:0:0|h[Ghost Iron Ore]|h|r#1#86#0#Trade Goods#Metal & Stone#20##Interface\\Icons\\inv_ore_ghostiron",
	[72093] = "Kyparite#|cffffffff|Hitem:72093:0:0:0:0:0:0:0:85:0:0|h[Kyparite]|h|r#1#88#0#Trade Goods#Metal & Stone#200##Interface\\Icons\\inv_ore_manticyte",
	[72094] = "Black Trillium Ore#|cff1eff00|Hitem:72094:0:0:0:0:0:0:0:85:0:0|h[Black Trillium Ore]|h|r#2#90#0#Trade Goods#Metal & Stone#20##Interface\\Icons\\inv_ore_trilliumblack",
	[72103] = "White Trillium Ore#|cff1eff00|Hitem:72103:0:0:0:0:0:0:0:85:0:0|h[White Trillium Ore]|h|r#2#90#0#Trade Goods#Metal & Stone#20##Interface\\Icons\\inv_ore_trilliumwhite",
	[74247] = "Ethereal Shard#|cff0070dd|Hitem:74247:0:0:0:0:0:0:0:85:0:0|h[Ethereal Shard]|h|r#3#90#0#Trade Goods#Enchanting#20##Interface\\Icons\\TRADE_ENCHANTING_LARGEETHEREALSHARD",
	[74248] = "Sha Crystal#|cffa335ee|Hitem:74248:0:0:0:0:0:0:0:85:0:0|h[Sha Crystal]|h|r#4#90#0#Trade Goods#Enchanting#20##Interface\\Icons\\inv_misc_crystalepic2",
	[74249] = "Spirit Dust#|cffffffff|Hitem:74249:0:0:0:0:0:0:0:85:0:0|h[Spirit Dust]|h|r#1#86#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Misc_Powder_Copper",
	[74250] = "Mysterious Essence#|cff1eff00|Hitem:74250:0:0:0:0:0:0:0:85:0:0|h[Mysterious Essence]|h|r#2#87#0#Trade Goods#Enchanting#20##Interface\\Icons\\TRADE_ENCHANTING_GREATERMYSTERIOUSESSENCE",
	[74251] = "Greater Mysterious Essence#|cff1eff00|Hitem:74251:0:0:0:0:0:0:0:85:0:0|h[Greater Mysterious Essence]|h|r#2#87#0#Trade Goods#Enchanting#20##Interface\\Icons\\TRADE_ENCHANTING_GREATERMYSTERIOUSESSENCE",
	[74252] = "Small Ethereal Shard#|cff0070dd|Hitem:74252:0:0:0:0:0:0:0:85:0:0|h[Small Ethereal Shard]|h|r#3#87#0#Trade Goods#Enchanting#20##Interface\\Icons\\TRADE_ENCHANTING_SMALLETHEREALSHARD",
	[76130] = "Tiger Opal#|cff1eff00|Hitem:76130:0:0:0:0:0:0:0:85:0:0|h[Tiger Opal]|h|r#2#87#0#Gem#Orange#20##Interface\\Icons\\inv_misc_gem_opalrough_03",
	[76131] = "Primordial Ruby#|cff0070dd|Hitem:76131:0:0:0:0:0:0:0:85:0:0|h[Primordial Ruby]|h|r#3#90#0#Gem#Red#20##Interface\\Icons\\inv_misc_gem_x4_rare_uncut_red",
	[76133] = "Lapis Lazuli#|cff1eff00|Hitem:76133:0:0:0:0:0:0:0:85:0:0|h[Lapis Lazuli]|h|r#2#87#0#Gem#Blue#20##Interface\\Icons\\INV_MISC_GEM_SAPHIREROUGH_03",
	[76134] = "Sunstone#|cff1eff00|Hitem:76134:0:0:0:0:0:0:0:85:0:0|h[Sunstone]|h|r#2#87#0#Gem#Yellow#20##Interface\\Icons\\INV_MISC_GEM_TOPAZROUGH_03",
	[76135] = "Roguestone#|cff1eff00|Hitem:76135:0:0:0:0:0:0:0:85:0:0|h[Roguestone]|h|r#2#87#0#Gem#Purple#20##Interface\\Icons\\INV_MISC_GEM_AMETHYSTROUGH_03",
	[76136] = "Pandarian Garnet#|cff1eff00|Hitem:76136:0:0:0:0:0:0:0:85:0:0|h[Pandarian Garnet]|h|r#2#87#0#Gem#Red#20##Interface\\Icons\\INV_MISC_GEM_RUBYROUGH_03",
	[76137] = "Alexandrite#|cff1eff00|Hitem:76137:0:0:0:0:0:0:0:85:0:0|h[Alexandrite]|h|r#2#87#0#Gem#Green#20##Interface\\Icons\\INV_MISC_GEM_EMERALDROUGH_03",
	[76138] = "River's Heart#|cff0070dd|Hitem:76138:0:0:0:0:0:0:0:85:0:0|h[River's Heart]|h|r#3#90#0#Gem#Blue#20##Interface\\Icons\\inv_misc_gem_x4_rare_uncut_blue",
	[76139] = "Wild Jade#|cff0070dd|Hitem:76139:0:0:0:0:0:0:0:85:0:0|h[Wild Jade]|h|r#3#90#0#Gem#Green#20##Interface\\Icons\\inv_misc_gem_x4_rare_uncut_green",
	[76140] = "Vermilion Onyx#|cff0070dd|Hitem:76140:0:0:0:0:0:0:0:85:0:0|h[Vermilion Onyx]|h|r#3#90#0#Gem#Orange#20##Interface\\Icons\\inv_misc_gem_x4_rare_uncut_orange",
	[76141] = "Imperial Amethyst#|cff0070dd|Hitem:76141:0:0:0:0:0:0:0:85:0:0|h[Imperial Amethyst]|h|r#3#90#0#Gem#Purple#20##Interface\\Icons\\inv_misc_gem_x4_rare_uncut_purple",
	[76142] = "Sun's Radiance#|cff0070dd|Hitem:76142:0:0:0:0:0:0:0:85:0:0|h[Sun's Radiance]|h|r#3#90#0#Gem#Yellow#20##Interface\\Icons\\inv_misc_gem_x4_rare_uncut_yellow",
	[79251] = "Shadow Pigment#|cffffffff|Hitem:79251:0:0:0:0:0:0:0:85:0:0|h[Shadow Pigment]|h|r#1#86#0#Trade Goods#Other#20##Interface\\Icons\\inv_inscription_pigment_shadow",
	[79253] = "Misty Pigment#|cff1eff00|Hitem:79253:0:0:0:0:0:0:0:85:0:0|h[Misty Pigment]|h|r#2#86#0#Trade Goods#Other#20##Interface\\Icons\\inv_inscription_pigment_misty",
	[90407] = "Sparkling Shard#|cffffffff|Hitem:90407:0:0:0:0:0:0:0:85:0:0|h[Sparkling Shard]|h|r#1#87#0#Trade Goods#Other#20##Interface\\Icons\\INV_Misc_Gem_Diamond_03",

}


