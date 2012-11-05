if select(4, GetBuildInfo()) < 50000 then return end

local libName, lib = ...
local s = SpellFlashAddon
local c = BittensSpellFlashLibrary

local type = type
local select = select
local pairs = pairs
local math = math

c.STAT_BUFFS = {
	1126, -- Mark of the Wild
	115921, -- Legacy of the Emperor
	20217, -- Blessing of Kings
	90363, -- Embrace of the Shale Spider
}

c.STAMINA_BUFFS = {
	21562, -- Power Word: Fortitude
	103127, -- Imp: Blood Pact
	469, -- Commanding Shout
	90364, -- Qiraji Fortitude
}

c.ATTACK_POWER_BUFFS = {
	57330, -- Horn of Winter
	19506, -- Trueshot Arua
	6673, -- Battle Shout
}

c.SPELL_POWER_BUFFS = {
	1459, -- Arcane Brilliance
	61316, -- Dalaran Brialliance
	77747, -- Burning Wrath
	109773, -- Dark Intent
	126309, -- Still Water
}

c.MELEE_HASTE_BUFFS = {
	55610, -- Unholy Aura
	113742, -- Swiftblade's Cunning
	30809, -- Unleashed Rage
	128432, -- Cackling Howl
	128433, -- Serpent's Swiftness
}

c.SPELL_HASTE_BUFFS = {
	24907, -- Moonkin Aura
	15473, -- Shadowform
	49868, -- Mind Quickening
	51470, -- Elemental Oath
}

c.CRIT_BUFFS = {
	17007, -- Leader of the Pack
	1459, -- Arcane Brilliance
	61316, -- Dalaran Brialliance
	97229, -- Bellowing Roar
	24604, -- Furious Howl
	90309, -- Terrifying Roar
	126373, -- Fearless Roar
	126309, -- Still Water
}

c.MASTERY_BUFFS = {
	19740, -- Blessing of Might
	116956, -- Grace of Air
	93435, -- Roar of Courage
	128997, -- Spirit Beast Blessing
}

c.BLOODLUST_BUFFS = {
    90355, -- Ancient Hysteria
    80353, -- Time Warp
    2825, -- Bloodlust
    32182, -- Heroism
}

c.ARMOR_DEBUFFS = 113746

c.PHYSICAL_VULNERABILITY_DEBUFFS = 81326

c.MAGIC_VULNERABILITY_DEBUFFS = {
	58410, -- Master Poisoner
	1490, -- Curse of the Elements
	34889, -- Fire Breath
	24844, -- Lightning Breath
}

c.WEAKENED_BLOWS_DEBUFFS = 115798

c.SLOW_CASTING_DEBUFFS = {
	73975, -- Necrotic Strike
	31589, -- Slow
	5761, -- Mind-numbing Poison
	109466, -- Curse of Enfeeblement
	50274, -- Spore Cloud
	90314, -- Tailspin
	126402, -- Trample
	58604, -- Lava Breath
}

c.MORTAL_WOUNDS_DEBUFFS = 115804

local function getScore(buff)
	return type(buff) == "string"
		and lib.A.Spells[buff]
		and lib.A.Spells[buff].Score
		or 1
end

local function isUp(buff)
	if type(buff) ~= "string" then
		return c.HasBuff(buff)
	end
	
	local spell = lib.A.Spells[buff]
	if spell == nil then
		return c.HasBuff(buff)
	end
	
	buff = spell.Buff or buff
	return s.Buff(
		buff, 
		"player", 
		c.GetBusyTime(spell.NoGCD), 
		nil, 
		nil, 
		spell.UseBuffID)
end

local function getCurrentScore(buff)
	if type(buff) == "table" then
		local score = 0
		for _, buff in pairs(buff) do
			score = score + getCurrentScore(buff)
		end
		return score
	end
	
	return isUp(buff) and getScore(buff) or 0
end

function c.FlashMitigationBuffs(targetScore, ...)
	if not c.IsTanking() and not s.Dummy() then
		return
	end
	
	for i = 1, select("#", ...) do
		targetScore = targetScore - getCurrentScore(select(i, ...))
	end
	for i = 1, select("#", ...) do
		if targetScore <= 0 then
			return
		end
		
		-- test castable before flashable, in case it changes the id
		local name = select(i, ...)
		local spell = lib.A.Spells[name]
		if spell and s.Castable(spell) then
			if spell.Type == "item" then
				if s.ItemFlashable(spell.ID) then
					if spell.ShouldHold == nil or not spell.ShouldHold() then
						s.FlashItem(spell.ID, spell.FlashColor, spell.FlashSize)
					end
					targetScore = targetScore - (spell.Score or 1)
				end
			else
				if s.Flashable(spell.ID) then
					if spell.ShouldHold == nil or not spell.ShouldHold() then
						s.Flash(spell.ID, spell.FlashColor, spell.FlashSize)
					end
					targetScore = targetScore - (spell.Score or 1)
				end
			end
		end
	end
end

function c.HasBuff(name, noGCD, matchSpellID)
	local duration = s.BuffDuration(
		c.GetID(name), "player", nil, nil, nil, matchSpellID)
	if duration == 0 then
		-- duration == 0 for permanent buffs
		return s.Buff(c.GetID(name), "player", nil, nil, nil, matchSpellID)
	else
		return duration > c.GetBusyTime(noGCD)
	end
end

function c.GetBuffDuration(name, noGCD, matchSpellID)
	return math.max(
		0, 
		s.BuffDuration(c.GetID(name), "player", nil, nil, nil, matchSpellID)
			- c.GetBusyTime(noGCD))
end

function c.GetBuffStack(name, noGCD, matchSpellID)
	if c.HasBuff(name, noGCD, matchSpellID) then -- ensure won't to expire
		return s.BuffStack(c.GetID(name), "player", nil, nil, nil, matchSpellID)
	else
		return 0
	end
end

function c.HasMyDebuff(name, noGCD, matchSpellID)
	return c.GetMyDebuffDuration(name, noGCD, matchSpellID) > 0
end

function c.GetMyDebuffStack(name, noGCD, matchSpellID)
	if c.HasMyDebuff(name, noGCD, matchSpellID) then -- ensure it won't expire
		return s.MyDebuffStack(c.GetID(name), nil, nil, nil, nil, matchSpellID)
	else
		return 0
	end
end

function c.GetMyDebuffDuration(name, noGCD, matchSpellID)
	return math.max(
		0, 
		s.MyDebuffDuration(c.GetID(name), nil, nil, nil, nil, matchSpellID) 
			- c.GetBusyTime(noGCD))
end

function c.GetDebuffDuration(name, noGCD, matchSpellID)
	return math.max(
		0, 
		s.DebuffDuration(c.GetID(name), nil, nil, nil, nil, matchSpellID) 
			- c.GetBusyTime(noGCD))
end

function c.SelfBuffNeeded(name)
	if s.InCombat() then
		return not c.HasBuff(name)
	else
		return c.GetBuffDuration(name) < 5 * 60
	end
end

function c.RaidBuffNeeded(idTable)
	local duration = 0
	if not s.InCombat() then
		duration = 5 * 60
	end
	local flags = "raid|all|range"
--	if idTable == c.INTELLECT_BUFFS then
--		flags = flags .. "|mana"
--	end
	return not s.Buff(idTable, flags, duration)
end
