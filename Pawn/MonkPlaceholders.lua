-- Placeholder monk scales for Pawn
-- © 2012 Green Eclipse.  This mod is released under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 license.
------------------------------------------------------------

local ScaleProviderName = "PawnPlaceholder"

function PawnPlaceholderScaleProvider_AddScales()



------------------------------------------------------------
-- Monk
------------------------------------------------------------

PawnAddPluginScale(
	ScaleProviderName,
	"MonkBrewmaster",
	PawnPlaceholderScale_MonkBrewmaster,
	"00ff96",
	{
		["Agility"] = 100, ["HitRating"] = 49, ["ExpertiseRating"] = 49, ["ParryRating"] = 45, ["DodgeRating"] = 45, ["Stamina"] = 33, ["HasteRating"] = 25, ["MasteryRating"] = 25, ["CritRating"] = 25, ["Strength"] = 10, ["Ap"] = 9, ["IsPlate"] = -1000000, ["IsMail"] = -1000000, ["IsShield"] = -1000000, ["IsDagger"] = -1000000, ["Is2HSword"] = -1000000, ["Is2HAxe"] = -1000000, ["Is2HMace"] = -1000000, ["IsBow"] = -1000000, ["IsCrossbow"] = -1000000, ["IsGun"] = -1000000, ["IsWand"] = -1000000, ["IsFrill"] = -1000000, ["MetaSocketEffect"] = 7200
	},
	1
)

PawnAddPluginScale(
	ScaleProviderName,
	"MonkMistweaver",
	PawnPlaceholderScale_MonkMistweaver,
	"00ff96",
	{
		["Intellect"] = 100, ["SpellPower"] = 85, ["Spirit"] = 75, ["HasteRating"] = 45, ["MasteryRating"] = 45, ["CritRating"] = 45, ["Stamina"] = .1, ["IsPlate"] = -1000000, ["IsMail"] = -1000000, ["IsShield"] = -1000000, ["IsDagger"] = -1000000, ["Is2HSword"] = -1000000, ["Is2HAxe"] = -1000000, ["Is2HMace"] = -1000000, ["IsBow"] = -1000000, ["IsCrossbow"] = -1000000, ["IsGun"] = -1000000, ["IsWand"] = -1000000, ["MetaSocketEffect"] = 7200
	},
	1
)

PawnAddPluginScale(
	ScaleProviderName,
	"MonkWindwalker",
	PawnPlaceholderScale_MonkWindwalker,
	"00ff96",
	{
		["Dps"] = 150, ["Agility"] = 100, ["HitRating"] = 49, ["ExpertiseRating"] = 49, ["Strength"] = 48, ["Ap"] = 45, ["HasteRating"] = 45, ["CritRating"] = 40, ["MasteryRating"] = 35, ["Stamina"] = .1, ["IsPlate"] = -1000000, ["IsMail"] = -1000000, ["IsShield"] = -1000000, ["IsDagger"] = -1000000, ["Is2HSword"] = -1000000, ["Is2HAxe"] = -1000000, ["Is2HMace"] = -1000000, ["IsBow"] = -1000000, ["IsCrossbow"] = -1000000, ["IsGun"] = -1000000, ["IsWand"] = -1000000, ["IsFrill"] = -1000000, ["MetaSocketEffect"] = 7200
	},
	1
)

------------------------------------------------------------

-- PawnPlaceholderScaleProviderOptions.LastAdded keeps track of the last time that we tried to automatically enable scales for this character.
if not PawnPlaceholderScaleProviderOptions then PawnPlaceholderScaleProviderOptions = { } end
if not PawnPlaceholderScaleProviderOptions.LastAdded then PawnPlaceholderScaleProviderOptions.LastAdded = 0 end

local _, Class = UnitClass("player")
if PawnPlaceholderScaleProviderOptions.LastClass ~= nil and Class ~= PawnPlaceholderScaleProviderOptions.LastClass then
	-- If the character has changed class since last time, let's start over.
	PawnSetAllScaleProviderScalesVisible(ScaleProviderName, false)
	PawnPlaceholderScaleProviderOptions.LastAdded = 0
end
PawnPlaceholderScaleProviderOptions.LastClass = Class

if PawnPlaceholderScaleProviderOptions.LastAdded < 1 then
	-- Enable round one of scales based on the player's class.
	if Class == "MONK" then
		PawnSetScaleVisible(PawnGetProviderScaleName(ScaleProviderName, "MonkBrewmaster"), true)
		PawnSetScaleVisible(PawnGetProviderScaleName(ScaleProviderName, "MonkMistweaver"), true)
		PawnSetScaleVisible(PawnGetProviderScaleName(ScaleProviderName, "MonkWindwalker"), true)
	end
end

-- Don't reenable those scales again after the user has disabled them previously.
PawnPlaceholderScaleProviderOptions.LastAdded = 1

-- After this function terminates there's no need for it anymore, so cause it to self-destruct to save memory.
PawnPlaceholderScaleProvider_AddScales = nil

end -- PawnPlaceholderScaleProvider_AddScales

------------------------------------------------------------

PawnAddPluginScaleProvider(ScaleProviderName, PawnPlaceholderScale_Provider, PawnPlaceholderScaleProvider_AddScales)
