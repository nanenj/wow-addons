local AddonName, a = ...
local L = a.Localize
local s = SpellFlashAddon
local c = BittensSpellFlashLibrary

local GetSpellCharges = GetSpellCharges
local GetTime = GetTime
local IsMounted = IsMounted
local SPELL_POWER_LIGHT_FORCE = SPELL_POWER_LIGHT_FORCE
local select = select

c.Init(a)

local spellCosts = {}

local function setCost(name, energy, chi)
	spellCosts[s.SpellName(c.GetID(name))] = { Energy = energy, Chi = chi }
end

function a.GetEnergyCost(localName)
	return spellCosts[localName] and spellCosts[localName].Energy
end

function a.GetChiCost(localName)
	return spellCosts[localName] and spellCosts[localName].Chi
end

setCost("Jab", 40, -1)
setCost("Expel Harm", 40, -1)
setCost("Keg Smash", 40, -2)
setCost("Blackout Kick", 0, 2)
setCost("Tiger Palm", 0, 1)
setCost("Rising Sun Kick", 0, 2)
setCost("Fists of Fury", 0, 3)
setCost("Spinning Crane Kick", 40, -1)
setCost("Dizzying Haze", 0, 0)
setCost("Breath of Fire", 0, 2)
setCost("Touch of Death", 0, 3)
setCost("Guard", 0, 2)
setCost("Purifying Brew", 0, 1)

------------------------------------------------------------------------ Common
local function modSpell(spell)
	spell.NoStopChannel = true
	
	local cost = spellCosts[s.SpellName(spell.ID)]
	if cost then
		spell.EvenIfNotUsable = true
		spell.NoPowerCheck = true
		spell.CheckLast = function()
--c.Debug("CheckLast", s.SpellName(spell.ID), a.Power, cost.Energy, a.Chi, cost.Chi)
			return a.Power >= cost.Energy and a.Chi >= cost.Chi
		end
	end
end

local function addSpell(name, tag, attributes)
	modSpell(c.AddSpell(name, tag, attributes))
end

local function addOptionalSpell(name, tag, attributes)
	modSpell(c.AddOptionalSpell(name, tag, attributes))
end

addOptionalSpell("Roll", nil, {
	FlashSize = s.FlashSizePercent() / 2,
	CheckFirst = function(z)
		if IsMounted() or not s.Moving("player") then
			return false
		end
		
		if not c.HasTalent("Momentum") then
			return true
		end
		
		local duration = c.GetBuffDuration("Momentum")
		if duration > 0 then
			return duration < 1
		end
		
		local charges, _, start, duration = GetSpellCharges(c.GetID("Roll"))
		if start + duration - GetTime() < 9 then
			charges = charges + 1
		end
		return charges >= 2
	end
})

addOptionalSpell("Legacy of the Emperor", nil, {
	NoRangeCheck = 1,
	CheckFirst = function()
		return c.RaidBuffNeeded(c.STAT_BUFFS)
	end
})

addOptionalSpell("Touch of Death", nil, {
	CheckFirst = function()
		return c.HasBuff("Death Note")
	end
})

addOptionalSpell("Expel Harm", nil, {
	CheckFirst = function()
		return s.HealthPercent("player") < 90
	end
})

addOptionalSpell("Chi Brew", nil, {
	CheckFirst = function()
		return a.Chi == 0
	end
})

addOptionalSpell("Rushing Jade Wind")

addOptionalSpell("Invoke Xuen, the White Tiger")

c.AddInterrupt("Spear Hand Strike")

-------------------------------------------------------------------- Brewmaster
local function canUseAndStillShuffle(chi)
	if not s.HasSpell(c.GetID("Brewmaster Training")) then
		return true
	end
	
	local timeToNextShuffle = c.GetBuffDuration("Shuffle")
	if timeToNextShuffle < 1 then
		return false
	end
	
	local chiByNextShuffle = a.Chi - chi + math.min(
		timeToNextShuffle - 1, 
		(a.Power + timeToNextShuffle * a.Regen) / 40)
	return chiByNextShuffle >= 2
end

addOptionalSpell("Elusive Brew", nil, {
	Buff = "Elusive Brew",
	BuffUnit = "player",
	UseBuffID = true,
	RequireBuff = "Elusive Brew Stacker",
	RequireBuffUnit = "player",
	RequireUseBuffID = true,
})

c.AddOptionalSpell("Stance of the Sturdy Ox", nil, {
	Type = "form",
})

addSpell("Blackout Kick", "for Shuffle", {
	CheckFirst = function(z)
		return c.GetBuffDuration("Shuffle") < 2
			and not c.IsAuraPendingFor("Blackout Kick")
			and s.HasSpell(c.GetID("Brewmaster Training"))
	end
})
c.RegisterAura("Blackout Kick", "Shuffle")

addSpell("Keg Smash", nil, {
	Melee = true,
})

addSpell("Keg Smash", "for Dizzying Haze", {
	Melee = true,
	CheckFirst = function()
		return not s.Debuff(c.GetID("Dizzying Haze"), nil, 2 + c.GetBusyTime())
			and not c.IsAuraPendingFor("Keg Smash")
	end
})
c.RegisterAura("Keg Smash", "Dizzying Haze")

addSpell("Jab", "for Brewmaster", {
	CheckFirst = function()
		if s.MaxPower("player") - a.Power < a.Regen then
			return true -- we will cap within 1 second
		end
		
		if a.Chi == s.MaxPower("player", SPELL_POWER_LIGHT_FORCE) then
			return false -- don't waste chi
		end
		
		-- jab unless we can wait and get better use out of expel harm
		return c.GetCooldown("Expel Harm") > 40 / a.Regen
			or not s.HasSpell("Expel Harm")
	end
})

addSpell("Expel Harm", "for Brewmaster", {
	CheckFirst = function()
		return s.HealthPercent("player") < 90
	end
})

c.AddSpell("Tiger Palm", "for Brewmaster", {
	Override = function()
		return s.MeleeDistance()
			and s.HasSpell(c.GetID("Brewmaster Training"))
	end
})

addSpell("Chi Wave", "for Brewmaster", {
	CheckFirst = function()
		return s.HealthPercent("player") < 90 and canUseAndStillShuffle(2)
	end
})

addSpell("Zen Sphere", "for Brewmaster", {
	NoRangeCheck = true,
	CheckFirst = function()
		return canUseAndStillShuffle(2)
			and (not c.HasBuff("Zen Sphere") or s.HealthPercent("player") < 90)
			and not c.IsCasting("Zen Sphere")
	end
})

addSpell("Chi Burst", "for Brewmaster", {
	CheckFirst = function()
		return s.HealthPercent("player") < 90 and canUseAndStillShuffle(2)
	end
})

addSpell("Dizzying Haze", nil, {
	NoRangeCheck = true,
	CheckFirst = function()
		return not s.Debuff(c.GetID("Dizzying Haze"), nil, 2 + c.GetBusyTime())
			and not c.IsAuraPendingFor("Dizzying Haze")
	end
})

addOptionalSpell("Purifying Brew", nil, {
	CheckFirst = function()
		return s.Debuff(c.GetID("Moderate Stagger"), "player")
			or s.Debuff(c.GetID("Heavy Stagger"), "player")
			or (s.Debuff(c.GetID("Light Stagger"), "player") and a.Chi > 2)
	end	
})

addOptionalSpell("Guard", nil, {
	CheckFirst = function()
		return a.Chi >= 4 -- leave enough Chi for Blackout Kick
			and (c.GetBuffStack("Power Guard") == 3
				or not s.HasSpell(c.GetID("Brewmaster Training")))
	end
})

addOptionalSpell("Dampen Harm")

addOptionalSpell("Fortifying Brew")

c.AddTaunt("Provoke", nil, { NoGCD = true })

-------------------------------------------------------------------- Windwalker
--c.RegisterAura("Tiger Palm", "Tiger Power")

addSpell("Tiger Palm", "for Tiger Power", {
	CheckFirst = function()
		local stack = c.GetBuffStack("Tiger Power")
		local duration = c.GetBuffDuration("Tiger Power")
		if c.IsCasting("Tiger Palm") then
			stack = stack + 1
			duration = 20
		end
		return duration < 3
			or (stack < 3 and a.Power + 2 * a.Regen <= s.MaxPower("player"))
	end
})

addSpell("Tiger Palm", "under Combo Breaker", {
	CheckFirst = function()
		return c.HasBuff("Combo Breaker: Tiger Palm")
			and not c.IsCasting("Tiger Palm")
	end
})

addSpell("Tiger Palm", "to save Tiger Power AoE", {
	CheckFirst = function()
		local duration = c.GetBuffDuration("Tiger Power")
		return duration > .1 and duration < 3.2
	end
})

addSpell("Rising Sun Kick")

addSpell("Rising Sun Kick", "for Debuff", {
	CheckFirst = function()
		return c.GetMyDebuffDuration("Rising Sun Kick") < 3
			and not c.IsAuraPendingFor("Rising Sun Kick")
	end
})

addOptionalSpell("Expel Harm", "at Cap", {
	CheckFirst = function()
		return s.HealthPercent("player") < 90
			and s.MaxPower("player") - s.Power("player") < 10
	end
})

addOptionalSpell("Tigereye Brew", nil, {
	CheckFirst = function()
		return c.GetBuffStack("Tigereye Brew") == 10
	end
})

addSpell("Fists of Fury", nil, {
	Melee = true,
	CheckFirst = function()
		if c.HasBuff("Energizing Brew") 
			or a.Power + a.Regen * c.GetHastedTime(4) > s.MaxPower("player")
			or c.GetBuffStack("Tiger Power") < 3 then
			
			return false
		end
		
		local tpLeft = c.GetBuffDuration("Tiger Power") - c.GetHastedTime(4)
		if a.Chi < 4 then
			tpLeft = tpLeft - 1
		end
		return tpLeft > 0
	end
})
c.RegisterForFullChannels("Fists of Fury", 4)

addSpell("Blackout Kick", "with high Chi", {
	CheckFirst = function()
		return a.Power + a.Regen * 2 < s.MaxPower("player")
			and a.Chi + 2 > s.MaxPower("player", SPELL_POWER_LIGHT_FORCE)
	end
})

addSpell("Blackout Kick", "under Combo Breaker", {
	CheckFirst = function()
		return c.HasBuff("Combo Breaker: Blackout Kick")
			and not c.IsCasting("Blackout Kick")
	end
})

addSpell("Blackout Kick", "without blocking RSK", {
	CheckFirst = function()
		if not s.HasSpell("Rising Sun Kick") then
			return true
		end
		
		local cd = c.GetCooldown("Rising Sun Kick")
		return a.Chi >= 4
			or (cd >= 1 and a.Power + a.Regen * (cd - 1) >= 40)
	end
})

addOptionalSpell("Expel Harm", "for Windwalker", {
	CheckFirst = function()
		return s.HealthPercent("player") < 90
			and a.Chi + 2 <= s.MaxPower("player", SPELL_POWER_LIGHT_FORCE)
	end
})

addSpell("Jab", "for Windwalker", {
	CheckFirst = function()
		return a.Chi + 2 <= s.MaxPower("player", SPELL_POWER_LIGHT_FORCE)
	end
})

addOptionalSpell("Energizing Brew", nil, {
	CheckFirst = function()
		return s.MaxPower("player") - a.Power > 10 + a.Regen
	end
})

c.AddOptionalSpell("Stance of the Fierce Tiger", nil, {
	Type = "form",
})
