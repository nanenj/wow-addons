-- Pawn by Vger-Azjol-Nerub
-- www.vgermods.com
-- © 2006-2012 Green Eclipse.  This mod is released under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 license.
-- See Readme.htm for more information.
-- 
-- Gem information
------------------------------------------------------------


-- Gem table row format:
-- { ItemID, Class, Red, Yellow, Blue, "Stat1" Quantity1, "Stat2", Quantity2 }
-- 	ItemID: The item ID of this gem.
-- 	Red: Is this gem red?
-- 	Yellow: Is this gem yellow?
-- 	Blue: Is this gem blue?
--	"Stat": The stat that this gem gives.
--	Quantity: How much of the stat that the gem gives.


--========================================
-- Colored level 60 common-quality vendor gems
--========================================
PawnGemData60Common =
{


------------------------------------------------------------
-- Red gems
------------------------------------------------------------

{ 28458, true, false, false, "Strength", 4 }, -- Bold Tourmaline
{ 28459, true, false, false, "Agility", 4 }, -- Delicate Tourmaline
{ 28460, true, false, false, "Intellect", 4 }, -- Brilliant Tourmaline


------------------------------------------------------------
-- Yellow gems
------------------------------------------------------------

{ 28467, false, true, false, "CritRating", 4 }, -- Smooth Amber
{ 28470, false, true, false, "DodgeRating", 4 }, -- Subtle Amber


------------------------------------------------------------
-- Blue gems
------------------------------------------------------------

{ 28463, false, false, true, "Stamina", 6 }, -- Solid Zircon
{ 28464, false, false, true, "Spirit", 4 }, -- Sparkling Zircon
{ 28468, false, false, true, "HitRating", 4 }, -- Rigid Zircon


}


--========================================
-- Colored level 70 uncommon-quality gems
--========================================
PawnGemData70Uncommon =
{


------------------------------------------------------------
-- Red gems
------------------------------------------------------------

{ 23094, true, false, false, "Intellect", 6 }, -- Brilliant Blood Garnet
{ 23095, true, false, false, "Strength", 6 }, -- Bold Blood Garnet
{ 28595, true, false, false, "Agility", 6 }, -- Delicate Blood Garnet


------------------------------------------------------------
-- Orange gems
------------------------------------------------------------

{ 23098, true, true, false, "CritRating", 3, "Strength", 3 }, -- Inscribed Flame Spessarite
{ 23099, true, true, false, "HasteRating", 3, "Intellect", 3 }, -- Reckless Flame Spessarite
{ 23101, true, true, false, "CritRating", 3, "Intellect", 3 }, -- Potent Flame Spessarite
{ 31869, true, true, false, "CritRating", 3, "Agility", 3 }, -- Deadly Flame Spessarite


------------------------------------------------------------
-- Yellow gems
------------------------------------------------------------

{ 23114, false, true, false, "CritRating", 6 }, -- Smooth Golden Draenite
{ 23115, false, true, false, "DodgeRating", 6 }, -- Subtle Golden Draenite


------------------------------------------------------------
-- Green gems
------------------------------------------------------------

{ 23103, false, true, true, "CritRating", 3, "SpellPenetration", 3 }, -- Radiant Deep Peridot
{ 23104, false, true, true, "CritRating", 3, "Stamina", 4 }, -- Jagged Deep Peridot
{ 23105, false, true, true, "DodgeRating", 3, "Stamina", 4 }, -- Regal Deep Peridot


------------------------------------------------------------
-- Blue gems
------------------------------------------------------------

{ 23116, false, false, true, "HitRating", 6 }, -- Rigid Azure Moonstone
{ 23118, false, false, true, "Stamina", 9 }, -- Solid Azure Moonstone
{ 23119, false, false, true, "Spirit", 6 }, -- Sparkling Azure Moonstone
{ 23120, false, false, true, "SpellPenetration", 6 }, -- Stormy Azure Moonstone


------------------------------------------------------------
-- Purple gems
------------------------------------------------------------

{ 23100, true, false, true, "HitRating", 3, "Agility", 3 }, -- Glinting Shadow Draenite
{ 23108, true, false, true, "Intellect", 3, "Stamina", 4 }, -- Timeless Shadow Draenite
{ 23109, true, false, true, "Intellect", 3, "Spirit", 3 }, -- Purified Shadow Draenite
{ 23110, true, false, true, "Stamina", 4, "Agility", 3 }, -- Shifting Shadow Draenite
{ 23111, true, false, true, "Strength", 3, "Stamina", 4 }, -- Sovereign Shadow Draenite
{ 31866, true, false, true, "Intellect", 3, "HitRating", 3 }, -- Veiled Shadow Draenite


}


--========================================
-- Colored level 70 rare-quality gems
--========================================
PawnGemData70Rare =
{


------------------------------------------------------------
-- Red gems
------------------------------------------------------------

{ 24027, true, false, false, "Strength", 8 }, -- Bold Living Ruby
{ 24028, true, false, false, "Agility", 8 }, -- Delicate Living Ruby
{ 24030, true, false, false, "Intellect", 8 }, -- Brilliant Living Ruby
{ 24036, true, false, false, "ParryRating", 8 }, -- Flashing Living Ruby


------------------------------------------------------------
-- Orange gems
------------------------------------------------------------

{ 24058, true, true, false, "CritRating", 4, "Strength", 4 }, -- Inscribed Noble Topaz
{ 24059, true, true, false, "Intellect", 4, "CritRating", 4 }, -- Potent Noble Topaz
{ 24060, true, true, false, "Intellect", 4, "HasteRating", 4 }, -- Reckless Noble Topaz
{ 31868, true, true, false, "CritRating", 4, "Agility", 4 }, -- Deadly Noble Topaz


------------------------------------------------------------
-- Yellow gems
------------------------------------------------------------

{ 24032, false, true, false, "DodgeRating", 8 }, -- Subtle Dawnstone
{ 24048, false, true, false, "CritRating", 8 }, -- Smooth Dawnstone
{ 24053, false, true, false, "ResilienceRating", 8 }, -- Mystic Dawnstone
{ 35315, false, true, false, "HasteRating", 8 }, -- Quick Dawnstone


------------------------------------------------------------
-- Green gems
------------------------------------------------------------

{ 24066, false, true, true, "CritRating", 4, "SpellPenetration", 4 }, -- Radiant Talasite
{ 24067, false, true, true, "CritRating", 4, "Stamina", 6 }, -- Jagged Talasite
{ 33782, false, true, true, "Stamina", 6, "ResilienceRating", 4 }, -- Steady Talasite
{ 35318, false, true, true, "HasteRating", 4, "Stamina", 6 }, -- Forceful Talasite
{ 35707, false, true, true, "DodgeRating", 4, "Stamina", 6 }, -- Regal Talasite


------------------------------------------------------------
-- Blue gems
------------------------------------------------------------

{ 24033, false, false, true, "Stamina", 12 }, -- Solid Star of Elune
{ 24035, false, false, true, "Spirit", 8 }, -- Sparkling Star of Elune
{ 24039, false, false, true, "SpellPenetration", 8 }, -- Stormy Star of Elune
{ 24051, false, false, true, "HitRating", 8 }, -- Rigid Star of Elune


------------------------------------------------------------
-- Purple gems
------------------------------------------------------------

{ 24054, true, false, true, "Strength", 4, "Stamina", 6 }, -- Sovereign Nightseye
{ 24055, true, false, true, "Stamina", 6, "Agility", 4 }, -- Shifting Nightseye
{ 24056, true, false, true, "Intellect", 5, "Stamina", 6 }, -- Timeless Nightseye
{ 24061, true, false, true, "HitRating", 4, "Agility", 4 }, -- Glinting Nightseye
{ 24065, true, false, true, "Intellect", 4, "Spirit", 4 }, -- Purified Nightseye
{ 31867, true, false, true, "Intellect", 4, "HitRating", 4 }, -- Veiled Nightseye


}


--========================================
-- Colored level 70 epic-quality gems
--========================================
PawnGemData70Epic =
{


------------------------------------------------------------
-- Red gems
------------------------------------------------------------

{ 32193, true, false, false, "Strength", 10 }, -- Bold Crimson Spinel
{ 32194, true, false, false, "Agility", 10 }, -- Delicate Crimson Spinel
{ 32195, true, false, false, "Intellect", 10 }, -- Brilliant Crimson Spinel
{ 32199, true, false, false, "ParryRating", 10 }, -- Flashing Crimson Spinel


------------------------------------------------------------
-- Orange gems
------------------------------------------------------------

{ 32217, true, true, false, "CritRating", 5, "Strength", 5 }, -- Inscribed Pyrestone
{ 32218, true, true, false, "Intellect", 5, "CritRating", 5 }, -- Potent Pyrestone
{ 32219, true, true, false, "Intellect", 5, "HasteRating", 5 }, -- Reckless Pyrestone
{ 32222, true, true, false, "CritRating", 5, "Agility", 5 }, -- Deadly Pyrestone


------------------------------------------------------------
-- Yellow gems
------------------------------------------------------------

{ 32198, false, true, false, "DodgeRating", 10 }, -- Subtle Lionseye
{ 32205, false, true, false, "CritRating", 10 }, -- Smooth Lionseye
{ 32209, false, true, false, "ResilienceRating", 10 }, -- Mystic Lionseye
{ 35761, false, true, false, "HasteRating", 10 }, -- Quick Lionseye


------------------------------------------------------------
-- Green gems
------------------------------------------------------------

{ 32223, false, true, true, "DodgeRating", 5, "Stamina", 7 }, -- Regal Seaspray Emerald
{ 32224, false, true, true, "CritRating", 5, "SpellPenetration", 5 }, -- Radiant Seaspray Emerald
{ 32226, false, true, true, "CritRating", 5, "Stamina", 7 }, -- Jagged Seaspray Emerald
{ 35758, false, true, true, "Stamina", 7, "ResilienceRating", 5 }, -- Steady Seaspray Emerald
{ 35759, false, true, true, "HasteRating", 5, "Stamina", 7 }, -- Forceful Seaspray Emerald


------------------------------------------------------------
-- Blue gems
------------------------------------------------------------

{ 32200, false, false, true, "Stamina", 15 }, -- Solid Empyrean Sapphire
{ 32201, false, false, true, "Spirit", 10 }, -- Sparkling Empyrean Sapphire
{ 32203, false, false, true, "SpellPenetration", 10 }, -- Stormy Empyrean Sapphire
{ 32206, false, false, true, "HitRating", 10 }, -- Rigid Empyrean Sapphire


------------------------------------------------------------
-- Purple gems
------------------------------------------------------------

{ 32211, true, false, true, "Strength", 5, "Stamina", 7 }, -- Sovereign Shadowsong Amethyst
{ 32212, true, false, true, "Stamina", 7, "Agility", 5 }, -- Shifting Shadowsong Amethyst
{ 32215, true, false, true, "Intellect", 5, "Stamina", 7 }, -- Timeless Shadowsong Amethyst
{ 32220, true, false, true, "HitRating", 5, "Agility", 5 }, -- Glinting Shadowsong Amethyst
{ 32221, true, false, true, "Intellect", 5, "HitRating", 5 }, -- Veiled Shadowsong Amethyst
{ 32225, true, false, true, "Intellect", 5, "Spirit", 5 }, -- Purified Shadowsong Amethyst


}


--========================================
-- Level 70 crafted meta gems
--========================================
PawnMetaGemData70Rare =
{


------------------------------------------------------------
-- Meta gems: Earthstorm
------------------------------------------------------------

{ 25896, true, false, false, "Stamina", 18, "MetaSocketEffect", 1 }, -- Powerful Earthstorm Diamond
{ 25897, true, false, false, "Intellect", 12, "MetaSocketEffect", 1 }, -- Bracing Earthstorm Diamond
{ 25898, true, false, false, "DodgeRating", 12, "MetaSocketEffect", 1 }, -- Tenacious Earthstorm Diamond
{ 25899, true, false, false, "MetaSocketEffect", 1 }, -- Brutal Earthstorm Diamond
{ 25901, true, false, false, "Intellect", 12, "MetaSocketEffect", 1 }, -- Insightful Earthstorm Diamond
{ 32409, true, false, false, "MetaSocketEffect", 1, "Agility", 12 }, -- Relentless Earthstorm Diamond
{ 35501, true, false, false, "DodgeRating", 12, "MetaSocketEffect", 1 }, -- Eternal Earthstorm Diamond


------------------------------------------------------------
-- Meta gems: Skyfire
------------------------------------------------------------

{ 25890, true, true, false, "CritRating", 14, "MetaSocketEffect", 1 }, -- Destructive Skyfire Diamond
{ 25893, true, true, false, "MetaSocketEffect", 1 }, -- Mystical Skyfire Diamond
{ 25894, true, true, false, "CritRating", 12, "MetaSocketEffect", 1 }, -- Swift Skyfire Diamond
{ 25895, true, true, false, "MetaSocketEffect", 1 }, -- Enigmatic Skyfire Diamond
{ 32410, true, true, false, "MetaSocketEffect", 1 }, -- Thundering Skyfire Diamond
{ 34220, true, true, false, "CritRating", 12, "MetaSocketEffect", 1 }, -- Chaotic Skyfire Diamond
{ 35503, true, true, false, "Intellect", 12, "MetaSocketEffect", 1 }, -- Ember Skyfire Diamond


}


--========================================
-- Colored level 80 uncommon-quality gems
--========================================
PawnGemData80Uncommon =
{


------------------------------------------------------------
-- Red gems
------------------------------------------------------------

{ 39900, true, false, false, "Strength", 12 }, -- Bold Bloodstone
{ 39905, true, false, false, "Agility", 12 }, -- Delicate Bloodstone
{ 39908, true, false, false, "ParryRating", 12 }, -- Flashing Bloodstone
{ 39910, true, false, false, "ExpertiseRating", 12 }, -- Precise Bloodstone
{ 39911, true, false, false, "Intellect", 12 }, -- Brilliant Bloodstone


------------------------------------------------------------
-- Orange gems
------------------------------------------------------------

{ 39946, true, true, false, "Intellect", 6, "HasteRating", 6 }, -- Reckless Huge Citrine
{ 39947, true, true, false, "Strength", 6, "CritRating", 6 }, -- Inscribed Huge Citrine
{ 39949, true, true, false, "Strength", 6, "DodgeRating", 6 }, -- Champion's Huge Citrine
{ 39950, true, true, false, "Strength", 6, "ResilienceRating", 6 }, -- Resplendent Huge Citrine
{ 39951, true, true, false, "Strength", 6, "HasteRating", 6 }, -- Fierce Huge Citrine
{ 39952, true, true, false, "CritRating", 6, "Agility", 6 }, -- Deadly Huge Citrine
{ 39954, true, true, false, "ResilienceRating", 6, "Agility", 6 }, -- Lucent Huge Citrine
{ 39955, true, true, false, "HasteRating", 6, "Agility", 6 }, -- Deft Huge Citrine
{ 39956, true, true, false, "Intellect", 6, "CritRating", 6 }, -- Potent Huge Citrine
{ 39958, true, true, false, "Intellect", 6, "ResilienceRating", 6 }, -- Willful Huge Citrine
{ 39964, true, true, false, "DodgeRating", 6, "ParryRating", 6 }, -- Stalwart Huge Citrine
{ 39967, true, true, false, "ExpertiseRating", 6, "DodgeRating", 6 }, -- Resolute Huge Citrine


------------------------------------------------------------
-- Yellow gems
------------------------------------------------------------

{ 39907, false, true, false, "DodgeRating", 12 }, -- Subtle Sun Crystal
{ 39909, false, true, false, "CritRating", 12 }, -- Smooth Sun Crystal
{ 39917, false, true, false, "ResilienceRating", 12 }, -- Mystic Sun Crystal
{ 39918, false, true, false, "HasteRating", 12 }, -- Quick Sun Crystal


------------------------------------------------------------
-- Green gems
------------------------------------------------------------

{ 39933, false, true, true, "CritRating", 6, "Stamina", 9 }, -- Jagged Dark Jade
{ 39938, false, true, true, "DodgeRating", 6, "Stamina", 9 }, -- Regal Dark Jade
{ 39975, false, true, true, "HitRating", 6, "DodgeRating", 6 }, -- Nimble Dark Jade
{ 39977, false, true, true, "Stamina", 9, "ResilienceRating", 6 }, -- Steady Dark Jade
{ 39978, false, true, true, "HasteRating", 6, "Stamina", 9 }, -- Forceful Dark Jade
{ 39980, false, true, true, "CritRating", 6, "Spirit", 6 }, -- Misty Dark Jade
{ 39981, false, true, true, "HitRating", 6, "HasteRating", 6 }, -- Lightning Dark Jade
{ 39982, false, true, true, "Spirit", 6, "ResilienceRating", 6 }, -- Turbid Dark Jade
{ 39983, false, true, true, "HasteRating", 6, "Spirit", 6 }, -- Energized Dark Jade
{ 39990, false, true, true, "CritRating", 6, "SpellPenetration", 6 }, -- Radiant Dark Jade
{ 39992, false, true, true, "HasteRating", 6, "SpellPenetration", 6 }, -- Shattered Dark Jade


------------------------------------------------------------
-- Blue gems
------------------------------------------------------------

{ 39915, false, false, true, "HitRating", 12 }, -- Rigid Chalcedony
{ 39919, false, false, true, "Stamina", 18 }, -- Solid Chalcedony
{ 39920, false, false, true, "Spirit", 12 }, -- Sparkling Chalcedony
{ 39932, false, false, true, "SpellPenetration", 12 }, -- Stormy Chalcedony


------------------------------------------------------------
-- Purple gems
------------------------------------------------------------

{ 39934, true, false, true, "Strength", 6, "Stamina", 9 }, -- Sovereign Shadow Crystal
{ 39935, true, false, true, "Stamina", 9, "Agility", 6 }, -- Shifting Shadow Crystal
{ 39936, true, false, true, "Intellect", 6, "Stamina", 9 }, -- Timeless Shadow Crystal
{ 39939, true, false, true, "Stamina", 9, "ParryRating", 6 }, -- Defender's Shadow Crystal
{ 39940, true, false, true, "ExpertiseRating", 6, "Stamina", 9 }, -- Guardian's Shadow Crystal
{ 39941, true, false, true, "Intellect", 6, "Spirit", 6 }, -- Purified Shadow Crystal
{ 39942, true, false, true, "HitRating", 6, "Agility", 6 }, -- Glinting Shadow Crystal
{ 39945, true, false, true, "Intellect", 6, "SpellPenetration", 6 }, -- Mysterious Shadow Crystal
{ 39948, true, false, true, "Strength", 6, "HitRating", 6 }, -- Etched Shadow Crystal
{ 39957, true, false, true, "Intellect", 6, "HitRating", 6 }, -- Veiled Shadow Crystal
{ 39966, true, false, true, "ExpertiseRating", 6, "HitRating", 6 }, -- Accurate Shadow Crystal


}


--========================================
-- Colored level 80 rare-quality gems
--========================================
PawnGemData80Rare =
{


------------------------------------------------------------
-- Red gems
------------------------------------------------------------

{ 39996, true, false, false, "Strength", 16 }, -- Bold Scarlet Ruby
{ 39997, true, false, false, "Agility", 16 }, -- Delicate Scarlet Ruby
{ 39998, true, false, false, "Intellect", 16 }, -- Brilliant Scarlet Ruby
{ 40001, true, false, false, "ParryRating", 16 }, -- Flashing Scarlet Ruby
{ 40003, true, false, false, "ExpertiseRating", 16 }, -- Precise Scarlet Ruby


------------------------------------------------------------
-- Orange gems
------------------------------------------------------------

{ 40037, true, true, false, "Strength", 8, "CritRating", 8 }, -- Inscribed Monarch Topaz
{ 40039, true, true, false, "Strength", 8, "DodgeRating", 8 }, -- Champion's Monarch Topaz
{ 40040, true, true, false, "Strength", 8, "ResilienceRating", 8 }, -- Resplendent Monarch Topaz
{ 40041, true, true, false, "Strength", 8, "HasteRating", 8 }, -- Fierce Monarch Topaz
{ 40043, true, true, false, "CritRating", 8, "Agility", 8 }, -- Deadly Monarch Topaz
{ 40045, true, true, false, "ResilienceRating", 8, "Agility", 8 }, -- Lucent Monarch Topaz
{ 40046, true, true, false, "HasteRating", 8, "Agility", 8 }, -- Deft Monarch Topaz
{ 40047, true, true, false, "Intellect", 8, "HasteRating", 8 }, -- Reckless Monarch Topaz
{ 40048, true, true, false, "Intellect", 8, "CritRating", 8 }, -- Potent Monarch Topaz
{ 40050, true, true, false, "Intellect", 8, "ResilienceRating", 8 }, -- Willful Monarch Topaz
{ 40056, true, true, false, "DodgeRating", 8, "ParryRating", 8 }, -- Stalwart Monarch Topaz
{ 40059, true, true, false, "ExpertiseRating", 8, "DodgeRating", 8 }, -- Resolute Monarch Topaz


------------------------------------------------------------
-- Yellow gems
------------------------------------------------------------

{ 40000, false, true, false, "DodgeRating", 16 }, -- Subtle Autumn's Glow
{ 40002, false, true, false, "CritRating", 16 }, -- Smooth Autumn's Glow
{ 40016, false, true, false, "ResilienceRating", 16 }, -- Mystic Autumn's Glow
{ 40017, false, true, false, "HasteRating", 16 }, -- Quick Autumn's Glow


------------------------------------------------------------
-- Green gems
------------------------------------------------------------

{ 40031, false, true, true, "DodgeRating", 8, "Stamina", 12 }, -- Regal Forest Emerald
{ 40033, false, true, true, "CritRating", 8, "Stamina", 12 }, -- Jagged Forest Emerald
{ 40088, false, true, true, "HitRating", 8, "DodgeRating", 8 }, -- Nimble Forest Emerald
{ 40090, false, true, true, "Stamina", 12, "ResilienceRating", 8 }, -- Steady Forest Emerald
{ 40091, false, true, true, "HasteRating", 8, "Stamina", 12 }, -- Forceful Forest Emerald
{ 40095, false, true, true, "CritRating", 8, "Spirit", 8 }, -- Misty Forest Emerald
{ 40098, false, true, true, "CritRating", 8, "SpellPenetration", 8 }, -- Radiant Forest Emerald
{ 40099, false, true, true, "HitRating", 8, "HasteRating", 8 }, -- Lightning Forest Emerald
{ 40102, false, true, true, "Spirit", 8, "ResilienceRating", 8 }, -- Turbid Forest Emerald
{ 40104, false, true, true, "HasteRating", 8, "Spirit", 8 }, -- Energized Forest Emerald
{ 40106, false, true, true, "HasteRating", 8, "SpellPenetration", 8 }, -- Shattered Forest Emerald


------------------------------------------------------------
-- Blue gems
------------------------------------------------------------

{ 40008, false, false, true, "Stamina", 24 }, -- Solid Sky Sapphire
{ 40009, false, false, true, "Spirit", 16 }, -- Sparkling Sky Sapphire
{ 40011, false, false, true, "SpellPenetration", 16 }, -- Stormy Sky Sapphire
{ 40014, false, false, true, "HitRating", 16 }, -- Rigid Sky Sapphire


------------------------------------------------------------
-- Purple gems
------------------------------------------------------------

{ 40022, true, false, true, "Strength", 8, "Stamina", 12 }, -- Sovereign Twilight Opal
{ 40023, true, false, true, "Stamina", 12, "Agility", 8 }, -- Shifting Twilight Opal
{ 40024, true, false, true, "HitRating", 8, "Agility", 8 }, -- Glinting Twilight Opal
{ 40025, true, false, true, "Intellect", 8, "Stamina", 12 }, -- Timeless Twilight Opal
{ 40026, true, false, true, "Intellect", 8, "Spirit", 8 }, -- Purified Twilight Opal
{ 40028, true, false, true, "Intellect", 8, "SpellPenetration", 8 }, -- Mysterious Twilight Opal
{ 40032, true, false, true, "Stamina", 12, "ParryRating", 8 }, -- Defender's Twilight Opal
{ 40034, true, false, true, "ExpertiseRating", 8, "Stamina", 12 }, -- Guardian's Twilight Opal
{ 40038, true, false, true, "Strength", 8, "HitRating", 8 }, -- Etched Twilight Opal
{ 40049, true, false, true, "Intellect", 8, "HitRating", 8 }, -- Veiled Twilight Opal
{ 40058, true, false, true, "ExpertiseRating", 8, "HitRating", 8 }, -- Accurate Twilight Opal


}


--========================================
-- Colored level 80 epic-quality gems
--========================================
PawnGemData80Epic =
{


------------------------------------------------------------
-- Red gems
------------------------------------------------------------

{ 40111, true, false, false, "Strength", 20 }, -- Bold Cardinal Ruby
{ 40112, true, false, false, "Agility", 20 }, -- Delicate Cardinal Ruby
{ 40113, true, false, false, "Intellect", 20 }, -- Brilliant Cardinal Ruby
{ 40116, true, false, false, "ParryRating", 20 }, -- Flashing Cardinal Ruby
{ 40118, true, false, false, "ExpertiseRating", 20 }, -- Precise Cardinal Ruby


------------------------------------------------------------
-- Orange gems
------------------------------------------------------------

{ 40142, true, true, false, "Strength", 10, "CritRating", 10 }, -- Inscribed Ametrine
{ 40144, true, true, false, "Strength", 10, "DodgeRating", 10 }, -- Champion's Ametrine
{ 40145, true, true, false, "Strength", 10, "ResilienceRating", 10 }, -- Resplendent Ametrine
{ 40146, true, true, false, "Strength", 10, "HasteRating", 10 }, -- Fierce Ametrine
{ 40147, true, true, false, "CritRating", 10, "Agility", 10 }, -- Deadly Ametrine
{ 40149, true, true, false, "ResilienceRating", 10, "Agility", 10 }, -- Lucent Ametrine
{ 40150, true, true, false, "HasteRating", 10, "Agility", 10 }, -- Deft Ametrine
{ 40152, true, true, false, "Intellect", 10, "CritRating", 10 }, -- Potent Ametrine
{ 40154, true, true, false, "Intellect", 10, "ResilienceRating", 10 }, -- Willful Ametrine
{ 40155, true, true, false, "Intellect", 10, "HasteRating", 10 }, -- Reckless Ametrine
{ 40160, true, true, false, "DodgeRating", 10, "ParryRating", 10 }, -- Stalwart Ametrine
{ 40163, true, true, false, "ExpertiseRating", 10, "DodgeRating", 10 }, -- Resolute Ametrine


------------------------------------------------------------
-- Yellow gems
------------------------------------------------------------

{ 40115, false, true, false, "DodgeRating", 20 }, -- Subtle King's Amber
{ 40117, false, true, false, "CritRating", 20 }, -- Smooth King's Amber
{ 40127, false, true, false, "ResilienceRating", 20 }, -- Mystic King's Amber
{ 40128, false, true, false, "HasteRating", 20 }, -- Quick King's Amber


------------------------------------------------------------
-- Green gems
------------------------------------------------------------

{ 40138, false, true, true, "DodgeRating", 10, "Stamina", 15 }, -- Regal Eye of Zul
{ 40140, false, true, true, "CritRating", 10, "Stamina", 15 }, -- Jagged Eye of Zul
{ 40166, false, true, true, "HitRating", 10, "DodgeRating", 10 }, -- Nimble Eye of Zul
{ 40168, false, true, true, "Stamina", 15, "ResilienceRating", 10 }, -- Steady Eye of Zul
{ 40169, false, true, true, "HasteRating", 10, "Stamina", 15 }, -- Forceful Eye of Zul
{ 40171, false, true, true, "CritRating", 10, "Spirit", 10 }, -- Misty Eye of Zul
{ 40172, false, true, true, "HitRating", 10, "HasteRating", 10 }, -- Lightning Eye of Zul
{ 40173, false, true, true, "Spirit", 10, "ResilienceRating", 10 }, -- Turbid Eye of Zul
{ 40174, false, true, true, "HasteRating", 10, "Spirit", 10 }, -- Energized Eye of Zul
{ 40180, false, true, true, "CritRating", 10, "SpellPenetration", 10 }, -- Radiant Eye of Zul
{ 40182, false, true, true, "HasteRating", 10, "SpellPenetration", 10 }, -- Shattered Eye of Zul


------------------------------------------------------------
-- Blue gems
------------------------------------------------------------

{ 40119, false, false, true, "Stamina", 30 }, -- Solid Majestic Zircon
{ 40120, false, false, true, "Spirit", 20 }, -- Sparkling Majestic Zircon
{ 40122, false, false, true, "SpellPenetration", 20 }, -- Stormy Majestic Zircon
{ 40125, false, false, true, "HitRating", 20 }, -- Rigid Majestic Zircon


------------------------------------------------------------
-- Purple gems
------------------------------------------------------------

{ 40129, true, false, true, "Strength", 10, "Stamina", 15 }, -- Sovereign Dreadstone
{ 40130, true, false, true, "Stamina", 15, "Agility", 10 }, -- Shifting Dreadstone
{ 40131, true, false, true, "HitRating", 10, "Agility", 10 }, -- Glinting Dreadstone
{ 40132, true, false, true, "Intellect", 10, "Stamina", 15 }, -- Timeless Dreadstone
{ 40133, true, false, true, "Intellect", 10, "Spirit", 10 }, -- Purified Dreadstone
{ 40135, true, false, true, "Intellect", 10, "SpellPenetration", 10 }, -- Mysterious Dreadstone
{ 40139, true, false, true, "Stamina", 15, "ParryRating", 10 }, -- Defender's Dreadstone
{ 40141, true, false, true, "ExpertiseRating", 10, "Stamina", 15 }, -- Guardian's Dreadstone
{ 40143, true, false, true, "Strength", 10, "HitRating", 10 }, -- Etched Dreadstone
{ 40153, true, false, true, "Intellect", 10, "HitRating", 10 }, -- Veiled Dreadstone
{ 40162, true, false, true, "ExpertiseRating", 10, "HitRating", 10 }, -- Accurate Dreadstone


}


--========================================
-- Level 80 crafted meta gems
--========================================
PawnMetaGemData80Rare =
{


------------------------------------------------------------
-- Meta gems: Earthsiege
------------------------------------------------------------

{ 41380, false, false, false, "Stamina", 32, "MetaSocketEffect", 1 }, -- Austere Earthsiege Diamond
{ 41381, false, false, false, "CritRating", 21, "MetaSocketEffect", 1 }, -- Persistent Earthsiege Diamond
{ 41382, false, false, false, "Intellect", 21, "MetaSocketEffect", 1 }, -- Trenchant Earthsiege Diamond
{ 41385, false, false, false, "HasteRating", 21, "MetaSocketEffect", 1 }, -- Invigorating Earthsiege Diamond
{ 41389, false, false, false, "CritRating", 21, "MetaSocketEffect", 1 }, -- Beaming Earthsiege Diamond
{ 41395, false, false, false, "Intellect", 21, "MetaSocketEffect", 1 }, -- Bracing Earthsiege Diamond
{ 41396, false, false, false, "DodgeRating", 21, "MetaSocketEffect", 1 }, -- Eternal Earthsiege Diamond
{ 41397, false, false, false, "Stamina", 32, "MetaSocketEffect", 1 }, -- Powerful Earthsiege Diamond
{ 41398, false, false, false, "MetaSocketEffect", 1, "Agility", 21 }, -- Relentless Earthsiege Diamond
{ 41401, false, false, false, "Intellect", 21, "MetaSocketEffect", 1 }, -- Insightful Earthsiege Diamond


------------------------------------------------------------
-- Meta gems: Skyflare
------------------------------------------------------------

{ 41285, false, false, false, "CritRating", 21, "MetaSocketEffect", 1 }, -- Chaotic Skyflare Diamond
{ 41307, false, false, false, "CritRating", 25, "MetaSocketEffect", 1 }, -- Destructive Skyflare Diamond
{ 41333, false, false, false, "Intellect", 21, "MetaSocketEffect", 1 }, -- Ember Skyflare Diamond
{ 41335, false, false, false, "MetaSocketEffect", 1 }, -- Enigmatic Skyflare Diamond
{ 41339, false, false, false, "CritRating", 21, "MetaSocketEffect", 1 }, -- Swift Skyflare Diamond
{ 41375, false, false, false, "Intellect", 21, "MetaSocketEffect", 1 }, -- Tireless Skyflare Diamond
{ 41376, false, false, false, "Spirit", 22, "MetaSocketEffect", 1 }, -- Revitalizing Skyflare Diamond
{ 41377, false, false, false, "Stamina", 32, "MetaSocketEffect", 1 }, -- Shielded Skyflare Diamond
{ 41378, false, false, false, "Intellect", 21, "MetaSocketEffect", 1 }, -- Forlorn Skyflare Diamond
{ 41379, false, false, false, "CritRating", 21, "MetaSocketEffect", 1 }, -- Impassive Skyflare Diamond
{ 41400, false, false, false, "MetaSocketEffect", 1 }, -- Thundering Skyflare Diamond


}


--========================================
-- Colored level 85 uncommon-quality gems
--========================================
PawnGemData85Uncommon =
{


------------------------------------------------------------
-- Red gems
------------------------------------------------------------

{ 52081, true, false, false, "Strength", 30 }, -- Bold Carnelian
{ 52082, true, false, false, "Agility", 30 }, -- Delicate Carnelian
{ 52083, true, false, false, "ParryRating", 30 }, -- Flashing Carnelian
{ 52084, true, false, false, "Intellect", 30 }, -- Brilliant Carnelian
{ 52085, true, false, false, "ExpertiseRating", 30 }, -- Precise Carnelian


------------------------------------------------------------
-- Orange gems
------------------------------------------------------------

{ 52106, true, true, false, "DodgeRating", 15, "Agility", 15 }, -- Polished Hessonite
{ 52107, true, true, false, "ExpertiseRating", 15, "DodgeRating", 15 }, -- Resolute Hessonite
{ 52108, true, true, false, "Strength", 15, "CritRating", 15 }, -- Inscribed Hessonite
{ 52109, true, true, false, "CritRating", 15, "Agility", 15 }, -- Deadly Hessonite
{ 52110, true, true, false, "Intellect", 15, "CritRating", 15 }, -- Potent Hessonite
{ 52111, true, true, false, "Strength", 15, "HasteRating", 15 }, -- Fierce Hessonite
{ 52112, true, true, false, "HasteRating", 15, "Agility", 15 }, -- Deft Hessonite
{ 52113, true, true, false, "Intellect", 15, "HasteRating", 15 }, -- Reckless Hessonite
{ 52114, true, true, false, "Strength", 15, "MasteryRating", 15 }, -- Skillful Hessonite
{ 52115, true, true, false, "MasteryRating", 15, "Agility", 15 }, -- Adept Hessonite
{ 52116, true, true, false, "MasteryRating", 15, "ParryRating", 15 }, -- Fine Hessonite
{ 52117, true, true, false, "Intellect", 15, "MasteryRating", 15 }, -- Artful Hessonite
{ 52118, true, true, false, "ExpertiseRating", 15, "MasteryRating", 15 }, -- Keen Hessonite


------------------------------------------------------------
-- Yellow gems
------------------------------------------------------------

{ 52090, false, true, false, "DodgeRating", 30 }, -- Subtle Alicite
{ 52091, false, true, false, "CritRating", 30 }, -- Smooth Alicite
{ 52092, false, true, false, "ResilienceRating", 30 }, -- Mystic Alicite
{ 52093, false, true, false, "HasteRating", 30 }, -- Quick Alicite
{ 52094, false, true, false, "MasteryRating", 30 }, -- Fractured Alicite


------------------------------------------------------------
-- Green gems
------------------------------------------------------------

{ 52119, false, true, true, "DodgeRating", 15, "Stamina", 23 }, -- Regal Jasper
{ 52120, false, true, true, "DodgeRating", 15, "HitRating", 15 }, -- Nimble Jasper
{ 52121, false, true, true, "CritRating", 15, "Stamina", 23 }, -- Jagged Jasper
{ 52122, false, true, true, "CritRating", 15, "HitRating", 15 }, -- Piercing Jasper
{ 52123, false, true, true, "Stamina", 23, "ResilienceRating", 15 }, -- Steady Jasper
{ 52124, false, true, true, "HasteRating", 15, "Stamina", 23 }, -- Forceful Jasper
{ 52125, false, true, true, "HasteRating", 15, "HitRating", 15 }, -- Lightning Jasper
{ 52126, false, true, true, "Stamina", 23, "MasteryRating", 15 }, -- Puissant Jasper
{ 52127, false, true, true, "Spirit", 15, "MasteryRating", 15 }, -- Zen Jasper
{ 52128, false, true, true, "HitRating", 15, "MasteryRating", 15 }, -- Sensei's Jasper


------------------------------------------------------------
-- Blue gems
------------------------------------------------------------

{ 52086, false, false, true, "Stamina", 45 }, -- Solid Zephyrite
{ 52087, false, false, true, "Spirit", 30 }, -- Sparkling Zephyrite
{ 52088, false, false, true, "SpellPenetration", 30 }, -- Stormy Zephyrite
{ 52089, false, false, true, "HitRating", 30 }, -- Rigid Zephyrite


------------------------------------------------------------
-- Purple gems
------------------------------------------------------------

{ 52095, true, false, true, "Strength", 15, "Stamina", 23 }, -- Sovereign Nightstone
{ 52096, true, false, true, "Agility", 15, "Stamina", 23 }, -- Shifting Nightstone
{ 52097, true, false, true, "ParryRating", 15, "Stamina", 23 }, -- Defender's Nightstone
{ 52098, true, false, true, "Intellect", 15, "Stamina", 23 }, -- Timeless Nightstone
{ 52099, true, false, true, "ExpertiseRating", 15, "Stamina", 23 }, -- Guardian's Nightstone
{ 52100, true, false, true, "Intellect", 15, "Spirit", 15 }, -- Purified Nightstone
{ 52101, true, false, true, "Strength", 15, "HitRating", 15 }, -- Etched Nightstone
{ 52102, true, false, true, "Agility", 15, "HitRating", 15 }, -- Glinting Nightstone
{ 52103, true, false, true, "ParryRating", 15, "HitRating", 15 }, -- Retaliating Nightstone
{ 52104, true, false, true, "Intellect", 15, "HitRating", 15 }, -- Veiled Nightstone
{ 52105, true, false, true, "ExpertiseRating", 15, "HitRating", 15 }, -- Accurate Nightstone


}


--========================================
-- Colored level 85 rare-quality gems
--========================================
PawnGemData85Rare =
{


------------------------------------------------------------
-- Red gems
------------------------------------------------------------

{ 52206, true, false, false, "Strength", 40 }, -- Bold Inferno Ruby
{ 52207, true, false, false, "Intellect", 40 }, -- Brilliant Inferno Ruby
{ 52212, true, false, false, "Agility", 40 }, -- Delicate Inferno Ruby
{ 52216, true, false, false, "ParryRating", 40 }, -- Flashing Inferno Ruby
{ 52230, true, false, false, "ExpertiseRating", 40 }, -- Precise Inferno Ruby


------------------------------------------------------------
-- Orange gems
------------------------------------------------------------

{ 52204, true, true, false, "MasteryRating", 20, "Agility", 20 }, -- Adept Ember Topaz
{ 52205, true, true, false, "Intellect", 20, "MasteryRating", 20 }, -- Artful Ember Topaz
{ 52208, true, true, false, "Intellect", 20, "HasteRating", 20 }, -- Reckless Ember Topaz
{ 52209, true, true, false, "CritRating", 20, "Agility", 20 }, -- Deadly Ember Topaz
{ 52211, true, true, false, "HasteRating", 20, "Agility", 20 }, -- Deft Ember Topaz
{ 52214, true, true, false, "Strength", 20, "HasteRating", 20 }, -- Fierce Ember Topaz
{ 52215, true, true, false, "MasteryRating", 20, "ParryRating", 20 }, -- Fine Ember Topaz
{ 52222, true, true, false, "Strength", 20, "CritRating", 20 }, -- Inscribed Ember Topaz
{ 52224, true, true, false, "ExpertiseRating", 20, "MasteryRating", 20 }, -- Keen Ember Topaz
{ 52229, true, true, false, "DodgeRating", 20, "Agility", 20 }, -- Polished Ember Topaz
{ 52239, true, true, false, "Intellect", 20, "CritRating", 20 }, -- Potent Ember Topaz
{ 52240, true, true, false, "Strength", 20, "MasteryRating", 20 }, -- Skillful Ember Topaz
{ 52249, true, true, false, "ExpertiseRating", 20, "DodgeRating", 20 }, -- Resolute Ember Topaz
{ 68356, true, true, false, "Intellect", 20, "ResilienceRating", 20 }, -- Willful Ember Topaz
{ 68357, true, true, false, "ResilienceRating", 20, "Agility", 20 }, -- Lucent Ember Topaz
{ 68358, true, true, false, "Strength", 20, "ResilienceRating", 20 }, -- Resplendent Ember Topaz


------------------------------------------------------------
-- Yellow gems
------------------------------------------------------------

{ 52219, false, true, false, "MasteryRating", 40 }, -- Fractured Amberjewel
{ 52226, false, true, false, "ResilienceRating", 40 }, -- Mystic Amberjewel
{ 52232, false, true, false, "HasteRating", 40 }, -- Quick Amberjewel
{ 52241, false, true, false, "CritRating", 40 }, -- Smooth Amberjewel
{ 52247, false, true, false, "DodgeRating", 40 }, -- Subtle Amberjewel


------------------------------------------------------------
-- Green gems
------------------------------------------------------------

{ 52218, false, true, true, "HasteRating", 20, "Stamina", 30 }, -- Forceful Dream Emerald
{ 52223, false, true, true, "CritRating", 20, "Stamina", 30 }, -- Jagged Dream Emerald
{ 52225, false, true, true, "HasteRating", 20, "HitRating", 20 }, -- Lightning Dream Emerald
{ 52227, false, true, true, "DodgeRating", 20, "HitRating", 20 }, -- Nimble Dream Emerald
{ 52228, false, true, true, "CritRating", 20, "HitRating", 20 }, -- Piercing Dream Emerald
{ 52231, false, true, true, "Stamina", 30, "MasteryRating", 20 }, -- Puissant Dream Emerald
{ 52233, false, true, true, "DodgeRating", 20, "Stamina", 30 }, -- Regal Dream Emerald
{ 52237, false, true, true, "HitRating", 20, "MasteryRating", 20 }, -- Sensei's Dream Emerald
{ 52245, false, true, true, "Stamina", 30, "ResilienceRating", 20 }, -- Steady Dream Emerald
{ 52250, false, true, true, "Spirit", 20, "MasteryRating", 20 }, -- Zen Dream Emerald


------------------------------------------------------------
-- Blue gems
------------------------------------------------------------

{ 52235, false, false, true, "HitRating", 40 }, -- Rigid Ocean Sapphire
{ 52242, false, false, true, "Stamina", 60 }, -- Solid Ocean Sapphire
{ 52244, false, false, true, "Spirit", 40 }, -- Sparkling Ocean Sapphire
{ 52246, false, false, true, "SpellPenetration", 40 }, -- Stormy Ocean Sapphire


------------------------------------------------------------
-- Purple gems
------------------------------------------------------------

{ 52203, true, false, true, "ExpertiseRating", 20, "HitRating", 20 }, -- Accurate Demonseye
{ 52210, true, false, true, "Stamina", 30, "ParryRating", 20 }, -- Defender's Demonseye
{ 52213, true, false, true, "Strength", 20, "HitRating", 20 }, -- Etched Demonseye
{ 52217, true, false, true, "Intellect", 20, "HitRating", 20 }, -- Veiled Demonseye
{ 52220, true, false, true, "HitRating", 20, "Agility", 20 }, -- Glinting Demonseye
{ 52221, true, false, true, "ExpertiseRating", 20, "Stamina", 30 }, -- Guardian's Demonseye
{ 52234, true, false, true, "HitRating", 20, "ParryRating", 20 }, -- Retaliating Demonseye
{ 52236, true, false, true, "Intellect", 20, "Spirit", 20 }, -- Purified Demonseye
{ 52238, true, false, true, "Stamina", 30, "Agility", 20 }, -- Shifting Demonseye
{ 52243, true, false, true, "Strength", 20, "Stamina", 30 }, -- Sovereign Demonseye
{ 52248, true, false, true, "Intellect", 20, "Stamina", 30 }, -- Timeless Demonseye


}


--========================================
-- Colored level 85 epic-quality gems
--========================================
PawnGemData85Epic =
{

------------------------------------------------------------
-- Red gems
------------------------------------------------------------

{ 71879, true, false, false, "Agility", 50 }, -- Delicate Queen's Garnet
{ 71880, true, false, false, "ExpertiseRating", 50 }, -- Precise Queen's Garnet
{ 71881, true, false, false, "Intellect", 50 }, -- Brilliant Queen's Garnet
{ 71882, true, false, false, "ParryRating", 50 }, -- Flashing Queen's Garnet
{ 71883, true, false, false, "Strength", 50 }, -- Bold Queen's Garnet


------------------------------------------------------------
-- Orange gems
------------------------------------------------------------

{ 71840, true, true, false, "CritRating", 25, "Agility", 25 }, -- Deadly Lava Coral
{ 71841, true, true, false, "ExpertiseRating", 25, "CritRating", 25 }, -- Crafty Lava Coral
{ 71842, true, true, false, "Intellect", 25, "CritRating", 25 }, -- Potent Lava Coral
{ 71843, true, true, false, "Strength", 25, "CritRating", 25 }, -- Inscribed Lava Coral
{ 71844, true, true, false, "DodgeRating", 25, "Agility", 25 }, -- Polished Lava Coral
{ 71845, true, true, false, "ExpertiseRating", 25, "DodgeRating", 25 }, -- Resolute Lava Coral
{ 71846, true, true, false, "DodgeRating", 25, "ParryRating", 25 }, -- Stalwart Lava Coral
{ 71847, true, true, false, "Strength", 25, "DodgeRating", 25 }, -- Champion's Lava Coral
{ 71848, true, true, false, "HasteRating", 25, "Agility", 25 }, -- Deft Lava Coral
{ 71849, true, true, false, "ExpertiseRating", 25, "HasteRating", 25 }, -- Wicked Lava Coral
{ 71850, true, true, false, "Intellect", 25, "HasteRating", 25 }, -- Reckless Lava Coral
{ 71851, true, true, false, "Strength", 25, "HasteRating", 25 }, -- Fierce Lava Coral
{ 71852, true, true, false, "MasteryRating", 25, "Agility", 25 }, -- Adept Lava Coral
{ 71853, true, true, false, "ExpertiseRating", 25, "MasteryRating", 25 }, -- Keen Lava Coral
{ 71854, true, true, false, "Intellect", 25, "MasteryRating", 25 }, -- Artful Lava Coral
{ 71855, true, true, false, "MasteryRating", 25, "ParryRating", 25 }, -- Fine Lava Coral
{ 71856, true, true, false, "Strength", 25, "MasteryRating", 25 }, -- Skillful Lava Coral
{ 71857, true, true, false, "ResilienceRating", 25, "Agility", 25 }, -- Lucent Lava Coral
{ 71858, true, true, false, "ExpertiseRating", 25, "ResilienceRating", 25 }, -- Tenuous Lava Coral
{ 71859, true, true, false, "Intellect", 25, "ResilienceRating", 25 }, -- Willful Lava Coral
{ 71860, true, true, false, "ResilienceRating", 25, "ParryRating", 25 }, -- Splendid Lava Coral
{ 71861, true, true, false, "Strength", 25, "ResilienceRating", 25 }, -- Resplendent Lava Coral


------------------------------------------------------------
-- Yellow gems
------------------------------------------------------------

{ 71874, false, true, false, "CritRating", 50 }, -- Smooth Lightstone
{ 71875, false, true, false, "DodgeRating", 50 }, -- Subtle Lightstone
{ 71876, false, true, false, "HasteRating", 50 }, -- Quick Lightstone
{ 71877, false, true, false, "MasteryRating", 50 }, -- Fractured Lightstone
{ 71878, false, true, false, "ResilienceRating", 50 }, -- Mystic Lightstone


------------------------------------------------------------
-- Green gems
------------------------------------------------------------

{ 71822, false, true, true, "Spirit", 25, "CritRating", 25 }, -- Misty Elven Peridot
{ 71823, false, true, true, "CritRating", 25, "HitRating", 25 }, -- Piercing Elven Peridot
{ 71824, false, true, true, "HasteRating", 25, "HitRating", 25 }, -- Lightning Elven Peridot
{ 71825, false, true, true, "HitRating", 25, "MasteryRating", 25 }, -- Sensei's Elven Peridot
{ 71826, false, true, true, "SpellPenetration", 25, "MasteryRating", 25 }, -- Infused Elven Peridot
{ 71827, false, true, true, "Spirit", 25, "MasteryRating", 25 }, -- Zen Elven Peridot
{ 71828, false, true, true, "HitRating", 25, "ResilienceRating", 25 }, -- Balanced Elven Peridot
{ 71829, false, true, true, "SpellPenetration", 25, "ResilienceRating", 25 }, -- Vivid Elven Peridot
{ 71830, false, true, true, "Spirit", 25, "ResilienceRating", 25 }, -- Turbid Elven Peridot
{ 71831, false, true, true, "CritRating", 25, "SpellPenetration", 25 }, -- Radiant Elven Peridot
{ 71832, false, true, true, "HasteRating", 25, "SpellPenetration", 25 }, -- Shattered Elven Peridot
{ 71833, false, true, true, "HasteRating", 25, "Spirit", 25 }, -- Energized Elven Peridot
{ 71834, false, true, true, "CritRating", 25, "Stamina", 37 }, -- Jagged Elven Peridot
{ 71835, false, true, true, "DodgeRating", 25, "Stamina", 37 }, -- Regal Elven Peridot
{ 71836, false, true, true, "HasteRating", 25, "Stamina", 37 }, -- Forceful Elven Peridot
{ 71837, false, true, true, "HitRating", 25, "DodgeRating", 25 }, -- Nimble Elven Peridot
{ 71838, false, true, true, "Stamina", 37, "MasteryRating", 25 }, -- Puissant Elven Peridot
{ 71839, false, true, true, "Stamina", 37, "ResilienceRating", 25 }, -- Steady Elven Peridot


------------------------------------------------------------
-- Blue gems
------------------------------------------------------------

{ 71817, false, false, true, "HitRating", 50 }, -- Rigid Deepholm Iolite
{ 71820, false, false, true, "Stamina", 75 }, -- Solid Deepholm Iolite
{ 71819, false, false, true, "Spirit", 50 }, -- Sparkling Deepholm Iolite
{ 71818, false, false, true, "SpellPenetration", 50 }, -- Stormy Deepholm Iolite


------------------------------------------------------------
-- Purple gems
------------------------------------------------------------

{ 71862, true, false, true, "HitRating", 25, "Agility", 25 }, -- Glinting Shadow Spinel
{ 71863, true, false, true, "ExpertiseRating", 25, "HitRating", 25 }, -- Accurate Shadow Spinel
{ 71864, true, false, true, "Intellect", 25, "HitRating", 25 }, -- Veiled Shadow Spinel
{ 71865, true, false, true, "HitRating", 25, "ParryRating", 25 }, -- Retaliating Shadow Spinel
{ 71866, true, false, true, "Strength", 25, "HitRating", 25 }, -- Etched Shadow Spinel
{ 71867, true, false, true, "Intellect", 25, "SpellPenetration", 25 }, -- Mysterious Shadow Spinel
{ 71868, true, false, true, "Intellect", 25, "Spirit", 25 }, -- Purified Shadow Spinel
{ 71869, true, false, true, "Stamina", 37, "Agility", 25 }, -- Shifting Shadow Spinel
{ 71870, true, false, true, "ExpertiseRating", 25, "Stamina", 37 }, -- Guardian's Shadow Spinel
{ 71871, true, false, true, "Intellect", 25, "Stamina", 37 }, -- Timeless Shadow Spinel
{ 71872, true, false, true, "Stamina", 37, "ParryRating", 25 }, -- Defender's Shadow Spinel
{ 71873, true, false, true, "Strength", 25, "Stamina", 37 }, -- Sovereign Shadow Spinel

}


--========================================
-- Level 85 rare-quality cogwheels
--========================================
PawnCogwheelData85Rare =
{


------------------------------------------------------------
-- Cogwheels
------------------------------------------------------------

{ 59477, false, false, false, "DodgeRating", 208 }, -- Subtle Cogwheel
{ 59478, false, false, false, "CritRating", 208 }, -- Smooth Cogwheel
{ 59479, false, false, false, "HasteRating", 208 }, -- Quick Cogwheel
{ 59480, false, false, false, "MasteryRating", 208 }, -- Fractured Cogwheel
{ 59489, false, false, false, "ExpertiseRating", 208 }, -- Precise Cogwheel
{ 59491, false, false, false, "ParryRating", 208 }, -- Flashing Cogwheel
{ 59493, false, false, false, "HitRating", 208 }, -- Rigid Cogwheel
{ 59496, false, false, false, "Spirit", 208 }, -- Sparkling Cogwheel
{ 68660, false, false, false, "ResilienceRating", 208 }, -- Mystic Cogwheel


}


--========================================
-- Level 85 crafted meta gems
--========================================
PawnMetaGemData85Rare =
{


------------------------------------------------------------
-- Meta gems: Shadowspirit
------------------------------------------------------------

{ 52289, false, false, false, "MetaSocketEffect", 1, "MasteryRating", 54 }, -- Fleet Shadowspirit Diamond
{ 52291, false, false, false, "CritRating", 54, "MetaSocketEffect", 1 }, -- Chaotic Shadowspirit Diamond
{ 52292, false, false, false, "Intellect", 54, "MetaSocketEffect", 1 }, -- Bracing Shadowspirit Diamond
{ 52293, false, false, false, "Stamina", 81, "MetaSocketEffect", 1 }, -- Eternal Shadowspirit Diamond
{ 52294, false, false, false, "Stamina", 81, "MetaSocketEffect", 1 }, -- Austere Shadowspirit Diamond
{ 52295, false, false, false, "Stamina", 81, "MetaSocketEffect", 1 }, -- Effulgent Shadowspirit Diamond
{ 52296, false, false, false, "Intellect", 54, "MetaSocketEffect", 1 }, -- Ember Shadowspirit Diamond
{ 52297, false, false, false, "Spirit", 54, "MetaSocketEffect", 1 }, -- Revitalizing Shadowspirit Diamond
{ 52298, false, false, false, "CritRating", 54, "MetaSocketEffect", 1 }, -- Destructive Shadowspirit Diamond
{ 52299, false, false, false, "Stamina", 81, "MetaSocketEffect", 1 }, -- Powerful Shadowspirit Diamond
{ 52300, false, false, false, "CritRating", 54, "MetaSocketEffect", 1 }, -- Enigmatic Shadowspirit Diamond
{ 52301, false, false, false, "CritRating", 54, "MetaSocketEffect", 1 }, -- Impassive Shadowspirit Diamond
{ 52302, false, false, false, "Intellect", 54, "MetaSocketEffect", 1 }, -- Forlorn Shadowspirit Diamond
{ 68778, false, false, false, "Agility", 54, "MetaSocketEffect", 1 }, -- Agile Shadowspirit Diamond
{ 68779, false, false, false, "Strength", 54, "MetaSocketEffect", 1 }, -- Reverberating Shadowspirit Diamond
{ 68780, false, false, false, "Intellect", 54, "MetaSocketEffect", 1 }, -- Burning Shadowspirit Diamond


}


--========================================
-- Colored level 90 uncommon-quality gems
--========================================
PawnGemData90Uncommon =
{


------------------------------------------------------------
-- Red gems
------------------------------------------------------------

{ 76560, true, false, false, "Agility", 120 }, -- Delicate Pandarian Garnet
{ 76561, true, false, false, "ExpertiseRating", 240 }, -- Precise Pandarian Garnet
{ 76562, true, false, false, "Intellect", 120 }, -- Brilliant Pandarian Garnet
{ 76563, true, false, false, "ParryRating", 240 }, -- Flashing Pandarian Garnet
{ 76564, true, false, false, "Strength", 120 }, -- Bold Pandarian Garnet


------------------------------------------------------------
-- Orange gems
------------------------------------------------------------

{ 76526, true, true, false, "CritRating", 120, "Agility", 60 }, -- Deadly Tiger Opal
{ 76527, true, true, false, "ExpertiseRating", 120, "CritRating", 120 }, -- Crafty Tiger Opal
{ 76528, true, true, false, "Intellect", 60, "CritRating", 120 }, -- Potent Tiger Opal
{ 76529, true, true, false, "Strength", 60, "CritRating", 120 }, -- Inscribed Tiger Opal
{ 76530, true, true, false, "DodgeRating", 120, "Agility", 60 }, -- Polished Tiger Opal
{ 76531, true, true, false, "ExpertiseRating", 120, "DodgeRating", 120 }, -- Resolute Tiger Opal
{ 76532, true, true, false, "DodgeRating", 120, "ParryRating", 120 }, -- Stalwart Tiger Opal
{ 76533, true, true, false, "Strength", 60, "DodgeRating", 120 }, -- Champion's Tiger Opal
{ 76534, true, true, false, "HasteRating", 120, "Agility", 60 }, -- Deft Tiger Opal
{ 76535, true, true, false, "ExpertiseRating", 120, "HasteRating", 120 }, -- Wicked Tiger Opal
{ 76536, true, true, false, "Intellect", 60, "HasteRating", 120 }, -- Reckless Tiger Opal
{ 76537, true, true, false, "Strength", 60, "HasteRating", 120 }, -- Fierce Tiger Opal
{ 76538, true, true, false, "MasteryRating", 120, "Agility", 60 }, -- Adept Tiger Opal
{ 76539, true, true, false, "ExpertiseRating", 120, "MasteryRating", 120 }, -- Keen Tiger Opal
{ 76540, true, true, false, "Intellect", 60, "MasteryRating", 120 }, -- Artful Tiger Opal
{ 76541, true, true, false, "MasteryRating", 120, "ParryRating", 120 }, -- Fine Tiger Opal
{ 76542, true, true, false, "Strength", 60, "MasteryRating", 120 }, -- Skillful Tiger Opal
{ 76543, true, true, false, "ResilienceRating", 120, "Agility", 60 }, -- Lucent Tiger Opal
{ 76544, true, true, false, "ExpertiseRating", 120, "ResilienceRating", 120 }, -- Tenuous Tiger Opal
{ 76545, true, true, false, "Intellect", 60, "ResilienceRating", 120 }, -- Willful Tiger Opal
{ 76546, true, true, false, "ResilienceRating", 120, "ParryRating", 120 }, -- Splendid Tiger Opal
{ 76547, true, true, false, "Strength", 60, "ResilienceRating", 120 }, -- Resplendent Tiger Opal


------------------------------------------------------------
-- Yellow gems
------------------------------------------------------------

{ 76565, false, true, false, "CritRating", 240 }, -- Smooth Sunstone
{ 76566, false, true, false, "DodgeRating", 240 }, -- Subtle Sunstone
{ 76567, false, true, false, "HasteRating", 240 }, -- Quick Sunstone
{ 76568, false, true, false, "MasteryRating", 240 }, -- Fractured Sunstone
{ 76569, false, true, false, "ResilienceRating", 240 }, -- Mystic Sunstone


------------------------------------------------------------
-- Green gems
------------------------------------------------------------

{ 76507, false, true, true, "Spirit", 120, "CritRating", 120 }, -- Misty Alexandrite
{ 76508, false, true, true, "CritRating", 120, "HitRating", 120 }, -- Piercing Alexandrite
{ 76509, false, true, true, "HasteRating", 120, "HitRating", 120 }, -- Lightning Alexandrite
{ 76510, false, true, true, "HitRating", 120, "MasteryRating", 120 }, -- Sensei's Alexandrite
{ 76511, false, true, true, "SpellPenetration", 120, "MasteryRating", 120 }, -- Effulgent Alexandrite
{ 76512, false, true, true, "Spirit", 120, "MasteryRating", 120 }, -- Zen Alexandrite
{ 76513, false, true, true, "HitRating", 120, "ResilienceRating", 120 }, -- Balanced Alexandrite
{ 76514, false, true, true, "SpellPenetration", 120, "ResilienceRating", 120 }, -- Vivid Alexandrite
{ 76515, false, true, true, "Spirit", 120, "ResilienceRating", 120 }, -- Turbid Alexandrite
{ 76517, false, true, true, "CritRating", 120, "SpellPenetration", 120 }, -- Radiant Alexandrite
{ 76518, false, true, true, "HasteRating", 120, "SpellPenetration", 120 }, -- Shattered Alexandrite
{ 76519, false, true, true, "HasteRating", 120, "Spirit", 120 }, -- Energized Alexandrite
{ 76520, false, true, true, "CritRating", 120, "Stamina", 90 }, -- Jagged Alexandrite
{ 76521, false, true, true, "DodgeRating", 120, "Stamina", 90 }, -- Regal Alexandrite
{ 76522, false, true, true, "HasteRating", 120, "Stamina", 90 }, -- Forceful Alexandrite
{ 76523, false, true, true, "HitRating", 120, "Stamina", 90 }, -- Nimble Alexandrite
{ 76524, false, true, true, "Stamina", 90, "MasteryRating", 120 }, -- Puissant Alexandrite
{ 76525, false, true, true, "Stamina", 90, "ResilienceRating", 120 }, -- Steady Alexandrite


------------------------------------------------------------
-- Blue gems
------------------------------------------------------------

{ 76502, false, false, true, "HitRating", 240 }, -- Rigid Lapis Lazuli
{ 76504, false, false, true, "SpellPenetration", 240 }, -- Stormy Lapis Lazuli
{ 76505, false, false, true, "Spirit", 240 }, -- Sparkling Lapis Lazuli
{ 76506, false, false, true, "Stamina", 180 }, -- Solid Lapis Lazuli


------------------------------------------------------------
-- Purple gems
------------------------------------------------------------

{ 76548, true, false, true, "HitRating", 120, "Agility", 60 }, -- Glinting Roguestone
{ 76549, true, false, true, "ExpertiseRating", 120, "HitRating", 120 }, -- Accurate Roguestone
{ 76550, true, false, true, "Intellect", 60, "HitRating", 120 }, -- Veiled Roguestone
{ 76551, true, false, true, "HitRating", 120, "ParryRating", 120 }, -- Retaliating Roguestone
{ 76552, true, false, true, "Strength", 60, "HitRating", 120 }, -- Etched Roguestone
{ 76553, true, false, true, "Intellect", 60, "SpellPenetration", 120 }, -- Mysterious Roguestone
{ 76554, true, false, true, "Intellect", 60, "Spirit", 120 }, -- Purified Roguestone
{ 76555, true, false, true, "Stamina", 90, "Agility", 60 }, -- Shifting Roguestone
{ 76556, true, false, true, "ExpertiseRating", 120, "Stamina", 90 }, -- Guardian's Roguestone
{ 76557, true, false, true, "Intellect", 60, "Stamina", 90 }, -- Timeless Roguestone
{ 76558, true, false, true, "Stamina", 90, "ParryRating", 120 }, -- Defender's Roguestone
{ 76559, true, false, true, "Strength", 60, "Stamina", 90 }, -- Sovereign Roguestone
{ 89675, true, false, true, "Strength", 60, "SpellPenetration", 120 }, -- Tense Roguestone
{ 89678, true, false, true, "Agility", 60, "SpellPenetration", 120 }, -- Assassin's Roguestone


}


--========================================
-- Colored level 90 rare-quality gems
--========================================
PawnGemData90Rare =
{


------------------------------------------------------------
-- Red gems
------------------------------------------------------------

{ 76692, true, false, false, "Agility", 160 }, -- Delicate Primordial Ruby
{ 76693, true, false, false, "ExpertiseRating", 320 }, -- Precise Primordial Ruby
{ 76694, true, false, false, "Intellect", 160 }, -- Brilliant Primordial Ruby
{ 76695, true, false, false, "ParryRating", 320 }, -- Flashing Primordial Ruby
{ 76696, true, false, false, "Strength", 160 }, -- Bold Primordial Ruby


------------------------------------------------------------
-- Orange gems
------------------------------------------------------------

{ 76658, true, true, false, "CritRating", 160, "Agility", 80 }, -- Deadly Vermilion Onyx
{ 76659, true, true, false, "ExpertiseRating", 160, "CritRating", 160 }, -- Crafty Vermilion Onyx
{ 76660, true, true, false, "Intellect", 80, "CritRating", 160 }, -- Potent Vermilion Onyx
{ 76661, true, true, false, "Strength", 80, "CritRating", 160 }, -- Inscribed Vermilion Onyx
{ 76662, true, true, false, "DodgeRating", 160, "Agility", 80 }, -- Polished Vermilion Onyx
{ 76663, true, true, false, "ExpertiseRating", 160, "DodgeRating", 160 }, -- Resolute Vermilion Onyx
{ 76664, true, true, false, "DodgeRating", 160, "ParryRating", 160 }, -- Stalwart Vermilion Onyx
{ 76665, true, true, false, "Strength", 80, "DodgeRating", 160 }, -- Champion's Vermilion Onyx
{ 76666, true, true, false, "HasteRating", 160, "Agility", 80 }, -- Deft Vermilion Onyx
{ 76667, true, true, false, "ExpertiseRating", 160, "HasteRating", 160 }, -- Wicked Vermilion Onyx
{ 76668, true, true, false, "Intellect", 80, "HasteRating", 160 }, -- Reckless Vermilion Onyx
{ 76669, true, true, false, "Strength", 80, "HasteRating", 160 }, -- Fierce Vermilion Onyx
{ 76670, true, true, false, "MasteryRating", 160, "Agility", 80 }, -- Adept Vermilion Onyx
{ 76671, true, true, false, "ExpertiseRating", 160, "MasteryRating", 160 }, -- Keen Vermilion Onyx
{ 76672, true, true, false, "Intellect", 80, "MasteryRating", 160 }, -- Artful Vermilion Onyx
{ 76673, true, true, false, "MasteryRating", 160, "ParryRating", 160 }, -- Fine Vermilion Onyx
{ 76674, true, true, false, "Strength", 80, "MasteryRating", 160 }, -- Skillful Vermilion Onyx
{ 76675, true, true, false, "ResilienceRating", 160, "Agility", 80 }, -- Lucent Vermilion Onyx
{ 76676, true, true, false, "ExpertiseRating", 160, "ResilienceRating", 160 }, -- Tenuous Vermilion Onyx
{ 76677, true, true, false, "Intellect", 80, "ResilienceRating", 160 }, -- Willful Vermilion Onyx
{ 76678, true, true, false, "ResilienceRating", 160, "ParryRating", 160 }, -- Splendid Vermilion Onyx
{ 76679, true, true, false, "Strength", 80, "ResilienceRating", 160 }, -- Resplendent Vermilion Onyx


------------------------------------------------------------
-- Yellow gems
------------------------------------------------------------

{ 76697, false, true, false, "CritRating", 320 }, -- Smooth Sun's Radiance
{ 76698, false, true, false, "DodgeRating", 320 }, -- Subtle Sun's Radiance
{ 76699, false, true, false, "HasteRating", 320 }, -- Quick Sun's Radiance
{ 76700, false, true, false, "MasteryRating", 320 }, -- Fractured Sun's Radiance
{ 76701, false, true, false, "ResilienceRating", 320 }, -- Mystic Sun's Radiance


------------------------------------------------------------
-- Green gems
------------------------------------------------------------

{ 76640, false, true, true, "Spirit", 160, "CritRating", 160 }, -- Misty Wild Jade
{ 76641, false, true, true, "CritRating", 160, "HitRating", 160 }, -- Piercing Wild Jade
{ 76642, false, true, true, "HasteRating", 160, "HitRating", 160 }, -- Lightning Wild Jade
{ 76643, false, true, true, "HitRating", 160, "MasteryRating", 160 }, -- Sensei's Wild Jade
{ 76644, false, true, true, "SpellPenetration", 160, "MasteryRating", 160 }, -- Effulgent Wild Jade
{ 76645, false, true, true, "Spirit", 160, "MasteryRating", 160 }, -- Zen Wild Jade
{ 76646, false, true, true, "HitRating", 160, "ResilienceRating", 160 }, -- Balanced Wild Jade
{ 76647, false, true, true, "SpellPenetration", 160, "ResilienceRating", 160 }, -- Vivid Wild Jade
{ 76648, false, true, true, "Spirit", 160, "ResilienceRating", 160 }, -- Turbid Wild Jade
{ 76649, false, true, true, "CritRating", 160, "SpellPenetration", 160 }, -- Radiant Wild Jade
{ 76650, false, true, true, "HasteRating", 160, "SpellPenetration", 160 }, -- Shattered Wild Jade
{ 76651, false, true, true, "HasteRating", 160, "Spirit", 160 }, -- Energized Wild Jade
{ 76652, false, true, true, "CritRating", 160, "Stamina", 120 }, -- Jagged Wild Jade
{ 76653, false, true, true, "DodgeRating", 160, "Stamina", 120 }, -- Regal Wild Jade
{ 76654, false, true, true, "HasteRating", 160, "Stamina", 120 }, -- Forceful Wild Jade
{ 76655, false, true, true, "HitRating", 160, "Stamina", 120 }, -- Nimble Wild Jade
{ 76656, false, true, true, "Stamina", 120, "MasteryRating", 160 }, -- Puissant Wild Jade
{ 76657, false, true, true, "Stamina", 120, "ResilienceRating", 160 }, -- Steady Wild Jade


------------------------------------------------------------
-- Blue gems
------------------------------------------------------------

{ 76636, false, false, true, "HitRating", 320 }, -- Rigid River's Heart
{ 76637, false, false, true, "SpellPenetration", 320 }, -- Stormy River's Heart
{ 76638, false, false, true, "Spirit", 320 }, -- Sparkling River's Heart
{ 76639, false, false, true, "Stamina", 240 }, -- Solid River's Heart


------------------------------------------------------------
-- Purple gems
------------------------------------------------------------

{ 76680, true, false, true, "HitRating", 160, "Agility", 80 }, -- Glinting Imperial Amethyst
{ 76681, true, false, true, "ExpertiseRating", 160, "HitRating", 160 }, -- Accurate Imperial Amethyst
{ 76682, true, false, true, "Intellect", 80, "HitRating", 160 }, -- Veiled Imperial Amethyst
{ 76683, true, false, true, "HitRating", 160, "ParryRating", 160 }, -- Retaliating Imperial Amethyst
{ 76684, true, false, true, "Strength", 80, "HitRating", 160 }, -- Etched Imperial Amethyst
{ 76685, true, false, true, "Intellect", 80, "SpellPenetration", 160 }, -- Mysterious Imperial Amethyst
{ 76686, true, false, true, "Intellect", 80, "Spirit", 160 }, -- Purified Imperial Amethyst
{ 76687, true, false, true, "Stamina", 120, "Agility", 80 }, -- Shifting Imperial Amethyst
{ 76688, true, false, true, "ExpertiseRating", 160, "Stamina", 120 }, -- Guardian's Imperial Amethyst
{ 76689, true, false, true, "Intellect", 80, "Stamina", 120 }, -- Timeless Imperial Amethyst
{ 76690, true, false, true, "Stamina", 120, "ParryRating", 160 }, -- Defender's Imperial Amethyst
{ 76691, true, false, true, "Strength", 80, "Stamina", 120 }, -- Sovereign Imperial Amethyst


}


--========================================
-- Level 90 rare-quality cogwheels
--========================================
PawnCogwheelData90Rare =
{


------------------------------------------------------------
-- Cogwheels
------------------------------------------------------------

{ 77540, false, false, false, "DodgeRating", 567 }, -- Subtle Tinker's Gear
{ 77541, false, false, false, "CritRating", 567 }, -- Smooth Tinker's Gear
{ 77542, false, false, false, "HasteRating", 567 }, -- Quick Tinker's Gear
{ 77543, false, false, false, "ExpertiseRating", 567 }, -- Precise Tinker's Gear
{ 77544, false, false, false, "ParryRating", 567 }, -- Flashing Tinker's Gear
{ 77545, false, false, false, "HitRating", 567 }, -- Rigid Tinker's Gear
{ 77546, false, false, false, "Spirit", 567 }, -- Sparkling Tinker's Gear
{ 77547, false, false, false, "MasteryRating", 567 }, -- Fractured Tinker's Gear


}


--========================================
-- Level 90 legendary-quality crystals of fear
--========================================
PawnCrystalOfFearData90Legendary =
{


------------------------------------------------------------
-- Crystals of Fear
------------------------------------------------------------

{ 89873, false, false, false, "Agility", 500 }, -- Crystallized Dread
{ 89881, false, false, false, "Strength", 500 }, -- Crystallized Terror
{ 89882, false, false, false, "Intellect", 500 }, -- Crystallized Horror


}


--========================================
-- Level 90 crafted meta gems
--========================================
PawnMetaGemData90Rare =
{


------------------------------------------------------------
-- Meta gems: Primal
------------------------------------------------------------

{ 76879, false, false, false, "Intellect", 216, "MetaSocketEffect", 1 }, -- Ember Primal Diamond
{ 76884, false, false, false, "MetaSocketEffect", 1, "Agility", 216 }, -- Agile Primal Diamond
{ 76885, false, false, false, "Intellect", 216, "MetaSocketEffect", 1 }, -- Burning Primal Diamond
{ 76886, false, false, false, "Strength", 216, "MetaSocketEffect", 1 }, -- Reverberating Primal Diamond
{ 76887, false, false, false, "MetaSocketEffect", 1, "MasteryRating", 432 }, -- Fleet Primal Diamond
{ 76888, false, false, false, "Spirit", 432, "MetaSocketEffect", 1 }, -- Revitalizing Primal Diamond
{ 76890, false, false, false, "CritRating", 432, "MetaSocketEffect", 1 }, -- Destructive Primal Diamond
{ 76891, false, false, false, "Stamina", 324, "MetaSocketEffect", 1 }, -- Powerful Primal Diamond
{ 76892, false, false, false, "CritRating", 432, "MetaSocketEffect", 1 }, -- Enigmatic Primal Diamond
{ 76893, false, false, false, "CritRating", 432, "MetaSocketEffect", 1 }, -- Impassive Primal Diamond
{ 76894, false, false, false, "Intellect", 216, "MetaSocketEffect", 1 }, -- Forlorn Primal Diamond
{ 76895, false, false, false, "Stamina", 324, "MetaSocketEffect", 1 }, -- Austere Primal Diamond
{ 76896, false, false, false, "DodgeRating", 432, "MetaSocketEffect", 1 }, -- Eternal Primal Diamond
{ 76897, false, false, false, "Stamina", 324, "MetaSocketEffect", 1 }, -- Effulgent Primal Diamond


}


--========================================

-- The master list of all tables of Pawn gem data

PawnGemQualityLevels =
{
	{ 60, PawnLocal.GemQualityLevel60Common },
	{ 70, PawnLocal.GemQualityLevel70Uncommon },
	{ 71, PawnLocal.GemQualityLevel70Rare },
	{ 72, PawnLocal.GemQualityLevel70Epic },
	{ 80, PawnLocal.GemQualityLevel80Uncommon },
	{ 81, PawnLocal.GemQualityLevel80Rare },
	{ 82, PawnLocal.GemQualityLevel80Epic },
	{ 85, PawnLocal.GemQualityLevel85Uncommon },
	{ 86, PawnLocal.GemQualityLevel85Rare },
	{ 87, PawnLocal.GemQualityLevel85Epic },
	{ 90, PawnLocal.GemQualityLevel90Uncommon },
	{ 91, PawnLocal.GemQualityLevel90Rare },
}
PawnGemQualityTables =
{
	[60] = PawnGemData60Common,
	[70] = PawnGemData70Uncommon,
	[71] = PawnGemData70Rare,
	[72] = PawnGemData70Epic,
	[80] = PawnGemData80Uncommon,
	[81] = PawnGemData80Rare,
	[82] = PawnGemData80Epic,
	[85] = PawnGemData85Uncommon,
	[86] = PawnGemData85Rare,
	[87] = PawnGemData85Epic,
	[90] = PawnGemData90Uncommon,
	[91] = PawnGemData90Rare,
}
PawnDefaultGemQualityLevel = 86

PawnMetaGemQualityLevels =
{
	{ 71, PawnLocal.MetaGemQualityLevel70Rare },
	{ 81, PawnLocal.MetaGemQualityLevel80Rare },
	{ 86, PawnLocal.MetaGemQualityLevel85Rare },
	{ 91, PawnLocal.MetaGemQualityLevel90Rare },
}
PawnMetaGemQualityTables =
{
	[71] = PawnMetaGemData70Rare,
	[81] = PawnMetaGemData80Rare,
	[86] = PawnMetaGemData85Rare,
	[91] = PawnMetaGemData90Rare,
}
PawnDefaultMetaGemQualityLevel = 86

PawnCogwheelQualityLevels =
{
	{ 86, PawnLocal.CogwheelQualityLevel85Rare },
	{ 91, PawnLocal.CogwheelQualityLevel90Rare },
}
PawnCogwheelQualityTables =
{
	[86] = PawnCogwheelData85Rare,
	[91] = PawnCogwheelData90Rare,
}
PawnDefaultCogwheelGemQualityLevel = 86

PawnCrystalOfFearQualityLevels =
{
	{ 93, EMPTY_SOCKET_HYDRAULIC }
}
PawnCrystalOfFearQualityTables =
{
	[93] = PawnCrystalOfFearData90Legendary,
}
PawnDefaultCrystalOfFearGemQualityLevel = 93
