local AddonName, a = ...
local L = a.Localize
local s = SpellFlashAddon
local c = BittensSpellFlashLibrary

local GetPowerRegen = GetPowerRegen
local GetTime = GetTime
local SPELL_POWER_LIGHT_FORCE = SPELL_POWER_LIGHT_FORCE
local select = select

local lastPowerStrike = 0

c.Init(a)
c.RegisterForEvents(a)
a.Rotations = {}

local function monitorForPowerStrike(spellID)
	if spellID == c.GetID("Chi Sphere") then
		c.Debug("Event", "Power Strike", GetTime() - lastPowerStrike)
		lastPowerStrike = GetTime()
	end
end

s.RegisterModuleSpamFunction(AddonName, function()
	c.Init(a)
	local info = c.GetQueuedInfo()
	if info then
--c.Debug("Queue", info.Name)
		info.Cost = a.GetEnergyCost(info.Name)
	end
	a.Regen = select(2, GetPowerRegen())
	a.Power = c.GetPower(a.Regen)
	
	if info then
		if c.HasBuff("Combo Breaker: Blackout Kick")
			and c.InfoMatches(info, "Blackout Kick") then
			
			info.Cost = 0
		elseif c.HasBuff("Combo Breaker: Tiger Palm")
			and c.InfoMatches(info, "Tiger Palm") then
			
			info.Cost = 0
		else
			info.Cost = a.GetChiCost(info.Name)
			if (c.InfoMatches(info, "Jab") or c.InfoMatches("Expel Harm"))
				and s.Form(c.GetID("Stance of the Fierce Tiger")) then
				
				info.Cost = info.Cost - 1
			end
			if c.InfoMatches(info, "Jab") 
				and c.HasTalent("Power Strikes") 
				and GetTime() - lastPowerStrike >= 20 then
				
				info.Cost = info.Cost - 1
			end
		end
	end
	a.Chi = c.GetPower(0, SPELL_POWER_LIGHT_FORCE)
--c.Debug("Power Calcs", a.Chi, a.Power, a.Regen,
--c.HasBuff("Combo Breaker: Blackout Kick"), c.HasBuff("Combo Breaker: Tiger Palm"))
	
	c.Flash(a)
end)

-------------------------------------------------------------------------- Noob
a.Rotations.Noob = {
	FlashInCombat = function()
		if s.Flashable(c.GetID("Blackout Kick")) then
			c.PriorityFlash(
				"Tiger Palm for Tiger Power", "Blackout Kick", "Jab")
		else
			c.PriorityFlash("Tiger Palm", "Jab")
		end
	end,
	
	FlashAlways = function()
		c.FlashAll("Roll")
	end,
}

-------------------------------------------------------------------- Brewmaster
local uncontrolledMitigationBuffs = {}
a.Rotations.Brewmaster = {
	Spec = 1,
	OffSwitch = "brewmaster_off",
	
	FlashInCombat = function()
		c.FlashAll("Purifying Brew", "Spear Hand Strike", "Provoke")
		c.FlashMitigationBuffs(
			1,
			uncontrolledMitigationBuffs,
			"Guard",
			"Dampen Harm",
			"Fortifying Brew",
			"Elusive Brew")
		if c.AoE then
			c.PriorityFlash(
				"Blackout Kick for Shuffle",
				"Expel Harm for Brewmaster",
				"Dizzying Haze",
				"Spinning Crane Kick",
				"Flying Serpent Kick 1")
		else
c.Debug("Flash",
			c.PriorityFlash(
				"Touch of Death",
				"Blackout Kick for Shuffle",
				"Keg Smash for Dizzying Haze",
				"Expel Harm for Brewmaster",
				"Chi Wave for Brewmaster",
				"Zen Sphere for Brewmaster",
				"Chi Burst for Brewmaster",
				"Jab for Brewmaster",
				"Tiger Palm for Brewmaster")
)
		end
	end,
	
	FlashAlways = function(self)
		c.FlashAll("Stance of the Sturdy Ox", "Legacy of the Emperor", "Roll")
--		self.FlashInCombat()
	end,
	
	Energized = monitorForPowerStrike,
}

-------------------------------------------------------------------- Windwalker
a.Rotations.Windwalker = {
	Spec = 3,
	OffSwitch = "windwalker_off",
	
	FlashInCombat = function()
		c.FlashAll("Chi Brew", "Spear Hand Strike")
		if c.AoE then
			c.PriorityFlash(
				"Rising Sun Kick for Debuff",
				"Tiger Palm for Tiger Power",
				"Tigereye Brew",
				"Invoke Xuen, the White Tiger",
				"Rushing Jade Wind",
				"Spinning Crane Kick",
				"Flying Serpent Kick 1")
		else
c.Debug("Flash", a.Chi, a.Power,
			c.PriorityFlash(
				"Touch of Death",
				"Rising Sun Kick for Debuff",
				"Tiger Palm for Tiger Power",
				"Tigereye Brew",
				"Energizing Brew",
				"Invoke Xuen, the White Tiger",
				"Rushing Jade Wind",
				"Rising Sun Kick",
				"Fists of Fury",
				"Blackout Kick with high Chi",
				"Blackout Kick under Combo Breaker",
				"Tiger Palm under Combo Breaker",
				"Expel Harm for Windwalker",
				"Jab for Windwalker",
				"Blackout Kick without blocking RSK",
				"Flying Serpent Kick 1")
)
		end
	end,
	
	FlashAlways = function(self)
		c.FlashAll(
			"Stance of the Fierce Tiger", 
			"Legacy of the Emperor", 
			"Roll")
--		self.FlashInCombat()
	end,
	
	Energized = monitorForPowerStrike,
}
