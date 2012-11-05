local AddonName, a = ...
if a.BuildFail(50000) then return end
local L = a.Localize
local s = SpellFlashAddon
local c = BittensSpellFlashLibrary

local SPELL_POWER_SHADOW_ORBS = SPELL_POWER_SHADOW_ORBS
local math = math

c.Init(a)

------------------------------------------------------------------------ common
--local function needsInner()
--	return not s.Buff(c.GetID("Inner Fire"), "player")
--		and not s.Buff(c.GetID("Inner Will"), "player")
--end

c.AddOptionalSpell("Power Word: Fortitude", nil, {
	NoRangeCheck = true,
	CheckFirst = function()
		return c.RaidBuffNeeded(c.STAMINA_BUFFS)
	end
})

c.AddOptionalSpell("Inner Fire", nil, {
	Buff = "Inner Fire",
	BuffUnit = "player",
})

c.AddOptionalSpell("Power Infusion", nil, {
	NoGCD = true,
	NoRangeCheck = true,
})
--
--c.AddOptionalSpell("Flash Heal", "under Surge of Light", {
--	NoRangeCheck = true,
--	NoStopChannel = true,
--	CheckFirst = function()
--		return c.HasBuff("Surge of Light")
--	end
--})
--
--c.AddOptionalSpell("Binding Heal", nil, {
--	NoRangeCheck = true,
--	CheckFirst = function()
--		local target = nil
--		if a.GetConfig("mouseover") then
--			target = "mouseover"
--		else
--			target = s.UnitSelection()
--		end
--		return not UnitIsUnit(target, "player")
--			and UnitIsFriend(target, "player")
--			and s.HealthDamage(target) > 30000
--			and s.HealthDamage("player") > 30000
--	end
--})
--
--c.AddOptionalSpell("Shadowfiend", "for Mana", {
--	NoStopChannel = true,
--	CheckFirst = function()
--		return s.PowerPercent("player") < 70
--	end
--})
--
--c.AddOptionalSpell("Inner Fire", "unless Inner Will", {
--	CheckFirst = needsInner,
--})
--
--c.AddOptionalSpell("Inner Will", nil, {
--	Buff = "Inner Will",
--	BuffUnit = "player",
--})
--
--c.AddOptionalSpell("Inner Will", "unless Inner Fire", {
--	CheckFirst = needsInner,
--})
--
--c.AddOptionalSpell("Desperate Prayer", nil, {
--	NoStopChannel = true,
--	NoRangeCheck = true,
--	CheckFirst = function()
--		return s.HealthPercent("player") < 70
--	end
--})

------------------------------------------------------------------------ shadow
c.AddOptionalSpell("Shadowform", nil, {
	Type = "form",
})

c.AddSpell("Mind Spike", "under Surge of Darkness", {
	Override = function()
		local stack = c.GetBuffStack("Surge of Darkness")
		if c.IsCasting("Mind Spike") then
			stack = stack - 1
		end
		return stack > 0
	end
})

c.AddSpell("Mind Spike", "under Surge of Darkness Cap", {
	Override = function()
		return c.GetBuffStack("Surge of Darkness") == 2
			and not c.IsCasting("Mind Spike")
	end
})

c.AddSpell("Devouring Plague", nil, {
	EarlyRefresh = 99,
	Override = function(z)
		if c.IsCasting("Devouring Plague") then
			return false
		end
		
		if c.GetMyDebuffDuration("Devouring Plague") > z.EarlyRefresh then
			return false
		end
		
		local orbs = s.Power("player", SPELL_POWER_SHADOW_ORBS)
		if c.IsCasting("Mind Blast") then
			orbs = orbs + 1
		elseif c.IsCasting("Shadow Word: Death") and s.HealthPercent() < 20 then
			orbs = orbs + 1
		end
		return orbs >= 3
	end
})
c.ManageDotRefresh("Devouring Plague", 3)

c.AddSpell("Devouring Plague", "to Prevent Cap", {
	Override = function(z)
		if c.IsCasting("Devouring Plague") then
			return false
		end
		
		if not c.HasTalent("Divine Insight") 
			and (c.IsCasting("Mind Blast") 
				or c.GetCooldown("Mind Blast") > 3) then
			
			return false 
		end
		
		local orbs = s.Power("player", SPELL_POWER_SHADOW_ORBS)
		if c.IsCasting("Mind Blast") then
			orbs = orbs + 1
		elseif c.IsCasting("Shadow Word: Death") and s.HealthPercent() < 20 then
			orbs = orbs + 1
		end
		return orbs >= 3
	end
})

c.AddSpell("Mind Blast", nil, {
	Override = function()
		return c.GetCooldown("Mind Blast") == 0
			and not c.IsCasting("Mind Blast")
	end
})

c.AddSpell("Shadow Word: Pain", nil, {
	EarlyRefresh = 99,
	Override = function(z)
		return c.GetMyDebuffDuration("Shadow Word: Pain") < z.EarlyRefresh
			and not c.IsCastingOrInAir("Shadow Word: Pain")
	end
})
c.ManageDotRefresh("Shadow Word: Pain", 3)

c.AddSpell("Shadow Word: Death", nil, {
	Override = function(z)
		return s.HealthPercent() < 20
			and c.GetCooldown("Shadow Word: Death") == 0
			and not c.IsCasting("Shadow Word: Death")
	end
})

c.AddSpell("Vampiric Touch", nil, {
	EarlyRefresh = 99,
	Override = function(z)
		return c.GetMyDebuffDuration("Vampiric Touch") < z.EarlyRefresh
			and not c.IsCastingOrInAir("Vampiric Touch")
	end
})
c.ManageDotRefresh("Vampiric Touch", 3)

c.AddOptionalSpell("Shadowfiend", nil, {
	Override = function()
		return c.GetCooldown("Shadowfiend") == 0
	end
})

c.AddOptionalSpell("Mindbender", nil, {
	Override = function()
		return c.GetCooldown("Mindbender") == 0
	end
})

c.AddSpell("Shadow Word: Insanity", nil, {
	Override = function()
		local duration = c.GetMyDebuffDuration("Shadow Word: Pain")
		return duration > 0 
			and duration < c.GetSpell("Shadow Word: Pain").EarlyRefresh
			and not c.IsCasting("Shadow Word: Insanity")
	end
})

c.AddOptionalSpell("Dispursion", nil, {
	CheckFirst = function()
		return s.PowerPercent("player") < 64
	end
})

--
--c.AddOptionalSpell("Vampiric Embrace", nil, {
--	Buff = "Vampiric Embrace",
--	BuffUnit = "player",
--})
--
--c.AddSpell("Mind Blast", "at 3 Orbs", {
--	NotIfActive = true,
--	NoStopChannel = true,
--	CheckFirst = function()
--		return c.GetBuffStack("Shadow Orb") == 3
--	end
--})
--
--c.AddSpell("Mind Blast", "for Empowered Shadow", {
--	NotIfActive = true,
--	CheckFirst = function()
--		return c.HasBuff("Shadow Orb")
--	end
--})
--
--c.ManageDotRefresh("Mind Flay", 1)
--
--c.AddSpell("Mind Flay", "for Dark Evangelism", {
--	CheckFirst = function(z)
--		if not c.HasTalent("Evangelism") then
--			return false
--		end
--		
--		local stacks = c.GetBuffStack("Dark Evangelism")
--		if stacks < 5 and c.IsCasting("Mind Flay") then
--			local remaining = s.Channeling(z.ID, "player")
--			if remaining then
--				stacks = stacks
--					+ remaining / c.GetSpell("Mind Flay").EarlyRefresh
--			else
--				stacks = stacks + 3
--			end
--		end
--		return stacks < 5
--	end
--})
--
--c.AddSpell("Mind Flay", "for Empowered Shadow", {
--	CheckFirst = function()
--		return not c.HasBuff("Empowered Shadow")
--			and not c.IsCasting("Mind Blast")
--	end
--})
--
--c.AddOptionalSpell("Dark Archangel", nil, {
--	NoGCD = true,
--	CheckFirst = function()
--		return c.GetBuffStack("Dark Evangelism") == 5
--	end
--})
