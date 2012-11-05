local AddonName, a = ...
if a.BuildFail(50000) then return end
local L = a.Localize
local s = SpellFlashAddon
local c = BittensSpellFlashLibrary
local bcm = a.BCM

local GetPowerRegen = GetPowerRegen
local GetTime = GetTime
local math = math
local select = select

a.Rotations = {}
c.RegisterForEvents(a)
a.SetSpamFunction(function()
	bcm.UpdateVisibility()
	
	local mana = c.GetPower(select(2, GetPowerRegen()))
	a.ManaPercent = mana / s.MaxPower("player") * 100
	c.Flash(a)
end)

bcm.UpdateVisibility()

s.AddSettingsListener(
	function()
		bcm.UpdateVisibility()
	end
)

------------------------------------------------------------------------- 4pT13
a.StolenTimeRemaining = 10

local function auraApplied4pT13(spellID, cooldown)
	if not c.WearingSet(4, "T13") then
		a.StolenTimeRemaining = 0
	elseif spellID == c.GetID(cooldown) then
		a.StolenTimeRemaining = 10
		c.Debug("Event", "Stolen Time will reset", a.StolenTimeRemaining)
	elseif spellID == c.GetID("Stolen Time")
		and a.StolenTimeRemaining > 0
		and not s.Buff(c.GetID(cooldown), "player") then
			
		a.StolenTimeRemaining = a.StolenTimeRemaining - 1
		c.Debug("Event", "Stolen Time bump", a.StolenTimeRemaining)
	end
end

local function auraRemoved4pT13(spellID, cooldown)
	if spellID == c.GetID("Stolen Time") then
		a.StolenTimeRemaining = 10
		c.Debug("Event", "Stolen Time reset", 10)
	end
end

------------------------------------------------------------------------ Arcane
--local function setBlastColor(color)
--	c.GetSpell("Arcane Blast").FlashColor = color
--end
--
--local function flashBlast(color)
--	setBlastColor(color)
--	a.Flash("Arcane Blast")
--end
--
--local function flashNeutralAround(percent, manaRatio, warningRatio)
--	if warningRatio and manaRatio >= warningRatio then
--		setBlastColor("red")
--	else
--		setBlastColor(nil)
--	end
--	if manaRatio > percent / 100 then
--		a.FlashAll("Arcane Blast", "Conjure Mana Gem")
--	else
--		a.Flash("Arcane Missiles", "Arcane Blast")
--	end
--end

a.Rotations.Arcane = {
	Spec = 1,
	OffSwitch = "arcane_off",
	
	FlashInCombat = function()
		if c.IsCasting("Arcane Barrage") then
			a.ChargeStacks = 0
		else
			a.ChargeStacks = s.DebuffStack(c.GetID("Arcane Charge"), "player")
			if a.ChargeStacks < 6 and (
				c.IsCasting("Arcane Blast")
					or c.IsCasting("Arcane Missiles")) then
				
				a.ChargeStacks = a.ChargeStacks + 1
			end
		end
		
		---------------------------------------------------------- flashing
		c.FlashAll(
			"Counterspell", 
			"Spellsteal", 
			"Rune of Power",
			"Evocation for Invoker's Energy")
--c.Debug("Flash", a.ChargeStacks, string.format("%.1f", a.ManaPercent),
		c.PriorityFlash(
			"Nether Tempest",
			"Frost Bomb",
			"Living Bomb",
			"Mirror Image",
			"Evocation for Arcane",
			"Mana Gem",
			"Brilliant Mana Gem",
			"Arcane Power",
			"Presence of Mind",
			"Arcane Blast at Cap",
			"Arcane Missiles",
			"Arcane Barrage",
			"Arcane Blast")
--)
	end,
	
	FlashOutOfCombat = function()
		c.FlashAll("Conjure Mana Gem")
	end,
	
	FlashAlways = function()
		c.FlashAll(
			"Mage Armor",
			"Arcane Brilliance",
			"Dalaran Brilliance")
	end,
	
	AuraApplied = function(spellID)
		auraApplied4pT13(spellID, "Arcane Power")
	end,
	
	AuraRemoved = function(spellID)
		auraRemoved4pT13(spellID, "Arcane Power")
	end, 
}

-------------------------------------------------------------------------- Fire
local pendingProc = false
local pendingBlast = false
local pendingConsumption = 0
local affectsCritStreak = {
	[c.GetID("Combustion")] = true,
	[c.GetID("Fireball")] = "delay",
	[c.GetID("Frostfire Bolt")] = "delay",
--	[c.GetID("Inferno Blast")] = true,
	[c.GetID("Pyroblast")] = "delay",
	[c.GetID("Scorch")] = "delay",
}

local function applyFireProc()
	if a.HeatingProc then
		a.HeatingProc = false
		a.PyroProc = true
	else
		a.HeatingProc = true
	end
end

a.Rotations.Fire = {
	Spec = 2,
	OffSwitch = "fire_off",
	
	FlashInCombat = function()
		
		-- Manage Pyroblast! and Heating Up
		a.HeatingProc = c.HasBuff("Heating Up")
		a.PyroProc = c.HasBuff("Pyroblast!")
		if pendingBlast or c.IsCastingOrInAir("Inferno Blast") then
--c.Debug("Flash", "applying proc from Inferno Blast")
			applyFireProc()
		end
		if pendingProc then
--c.Debug("Flash", "applying proc from a natural crit")
			applyFireProc()
		elseif a.HeatingProc then
			local endDelay = c.GetBusyTime() - .25
			if GetTime() - pendingConsumption < .25
				or c.CountLandings("Pyroblast", -3, endDelay, false) > 0
				or c.CountLandings("Fireball", -3, endDelay, false) > 0 
				or c.CountLandings("Frostfire Bolt", -3, endDelay, false) > 0
				or c.CountLandings("Scorch", -3, endDelay, false) > 0 then
				
--c.Debug("Flash", "landing dirties heating up")
				a.HeatingProc = false
			end
		end
		if a.PyroProc and c.IsCasting("Pyroblast") then
--c.Debug("Flash", "consuming pyroblast!")
			a.PyroProc = false
		end
		
		-- Flash
		c.FlashAll(
			"Counterspell", 
			"Spellsteal", 
			"Mana Gem", 
			"Brilliant Mana Gem",
			"Rune of Power",
			"Evocation for Invoker's Energy")
--c.Debug("Flash", 
--"heat", s.Buff(c.GetID("Heating Up"), "player"), c.HasBuff("Heating Up"), "->", a.HeatingProc, 
--"(", pendingBlast, ")", 
--"pyro", s.Buff(c.GetID("Pyroblast!"), "player"), c.HasBuff("Pyroblast!"), "->", a.PyroProc,
		c.PriorityFlash(
			"Combustion when Big",
			"Nether Tempest",
			"Living Bomb",
			"Pyroblast",
			"Inferno Blast",
			"Presence of Mind",
			"Combustion",
			"Frost Bomb",
			"Mirror Image",
			"Evocation",
			"Scorch",
			"Frostfire Bolt",
			"Fireball")
--)
	end,
	
	FlashOutOfCombat = function()
		c.FlashAll("Conjure Mana Gem")
	end,
	
	FlashAlways = function()
		c.FlashAll(
			"Molten Armor",
			"Arcane Brilliance",
			"Dalaran Brilliance")
	end,
	
	CastSucceeded = function(info)
--c.Debug("Event", "Succeeded", info.Name)
		if c.InfoMatches(info, "Inferno Blast") then
			if s.Buff(c.GetID("Heating Up"), "player") then
				pendingBlast = true
				c.Debug("Event", "blast pending")
			end
		end
	end,
	
	SpellMissed = function(spellID)
		if spellID == c.GetID("Inferno Blast") then
			pendingBlast = false
			c.Debug("Event", "blast missed")
		end
	end,
	
	SpellDamage = function(spellID, _, amount, critical, _, _, isTick)
		if affectsCritStreak[spellID] and not isTick then
			if critical then
				pendingProc = true
			else
				pendingProc = false
				pendingConsumption = GetTime()
			end
			c.Debug("Event", s.SpellName(spellID), "crit?:", critical)
		end
	end,
	
	AuraApplied = function(spellID)
		if spellID == c.GetID("Pyroblast!")
			or spellID == c.GetID("Heating Up") then
			
			pendingProc = false
			pendingBlast = false
			pendingConsumption = 0
			c.Debug("Event", s.SpellName(spellID), "applied")
		end
	end,
	
	AuraRemoved = function(spellID)
		if spellID == c.GetID("Pyroblast!")
			or spellID == c.GetID("Heating Up") then
			
			pendingProc = false
			pendingBlast = false
			pendingConsumption = 0
			c.Debug("Event", s.SpellName(spellID), "removed")
		end
	end,
	
	LeftCombat = function()
		bcm.UpdateVisibility()
	end,
	
--CastQueued = function(info)
--c.Debug("Event", "Queued", info.Name)
--end,
}

------------------------------------------------------------------------- Frost
local blizzFingerCount = -1
a.FingerCount = blizzFingerCount

a.Rotations.Frost = {
    Spec = 3,
    OffSwitch = "frost_off",
    
    FlashInCombat = function()
        c.FlashAll(
            "Counterspell",
            "Spellsteal",
            "Presence of Mind",
			"Rune of Power")
--c.Debug("Flash", a.FingerCount, blizzFingerCount, 
        c.PriorityFlash(
        	"Ice Lance within 2",
        	"Frost Bomb",
        	"Living Bomb",
        	"Nether Tempest",
            "Frozen Orb",
            "Icy Veins", 
            "Mirror Image",
            "Evocation for Invoker's Energy",
            "Ice Lance within 5",
            "Frostbolt for Debuff",
            "Freeze",
            "Freeze on Pet Bar",
            "Ice Lance",
            "Frostfire Bolt under Brain Freeze",
            "Mana Gem",
            "Evocation",
            "Frostbolt")
--)
    end,
    
    FlashOutOfCombat = function()
        c.FlashAll("Conjure Mana Gem")
    end,
    
    FlashAlways = function()
        c.FlashAll(
            "Frost Armor", 
            "Summon Water Elemental", 
            "Arcane Brilliance", 
            "Dalaran Brilliance")
    end,
    
    CastSucceeded = function(info)
        if c.InfoMatches(info, "Ice Lance") then
            a.FingerCount = math.max(0, a.FingerCount - 1)
            c.Debug("Event", "Pretend FoF is now at", a.FingerCount)
        end
    end,
    
    AuraApplied = function(spellID, target, spellSchool)
        if spellID == c.GetID("Fingers of Frost") then
            local stack = c.GetBuffStack("Fingers of Frost")
            if a.FingerCount == blizzFingerCount - 1 then
                a.FingerCount = stack - 1
            else
                a.FingerCount = stack
            end
            c.Debug("Event",
                "Gained FoF. Stack =", stack, "Pretend =", a.FingerCount)
            blizzFingerCount = stack
        end
    end,
    
    AuraRemoved = function(spellID, target, spellSchool)
        if spellID == c.GetID("Fingers of Frost") then
            local stack = c.GetBuffStack("Fingers of Frost")
            a.FingerCount = stack
            c.Debug("Event", "Lost FoF. Stack =", stack)
            blizzFingerCount = stack
        end
    end, 
}
