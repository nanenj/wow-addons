local AddonName, a = ...
if a.BuildFail(50000) then return end
local L = a.Localize
local s = SpellFlashAddon
local c = BittensSpellFlashLibrary

local UnitSpellHaste = UnitSpellHaste

a.Rotations = {}
c.RegisterForEvents(a)
a.SetSpamFunction(function()
	c.Flash(a)
end)

a.Rotations.Shadow = {
	Spec = 3,
	OffSwitch = "shadow_off",
	
	FlashInCombat = function()
		c.FlashAll("Power Infusion")
c.Debug("Flash",
		c.PriorityFlash(
			"Mind Spike under Surge of Darkness Cap",
			"Devouring Plague to Prevent Cap",
			"Mind Blast",
			"Shadow Word: Insanity",
			"Mind Spike under Surge of Darkness",
			"Shadow Word: Pain",
			"Shadow Word: Death",
			"Vampiric Touch",
			"Mindbender",
			"Shadowfiend",
			"Devouring Plague",
			"Mind Flay")
)
	end,
	
	FlashOutOfCombat = function()
		c.PriorityFlash("Dispursion")
	end,
	
	FlashAlways = function()
		c.FlashAll(
			"Power Word: Fortitude",
			"Shadowform", 
			"Inner Fire")
	end,
}
