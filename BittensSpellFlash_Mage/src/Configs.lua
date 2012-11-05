local AddonName, a = ...
if a.BuildFail(50000) then return end
local L = a.Localize
local s = SpellFlashAddon
local c = BittensSpellFlashLibrary

local config = {}
config.event = {}

config.CheckButtonOptions = {
	LeftCheckButton1 = {
		DefaultChecked = true,
		ConfigKey = "arcane_off",
		Label = L["Flash Arcane"],
	},
	LeftCheckButton2 = {
		DefaultChecked = true,
		ConfigKey = "fire_off",
		Label = L["Flash Fire"],
	},
	LeftCheckButton3 = {
		DefaultChecked = true,
		ConfigKey = "frost_off",
		Label = L["Flash Frost"],
	},
	RightCheckButton2 = {
		DefaultChecked = true,
		ConfigKey = "hide_BCM",
		Label = L["Show Combustion Monitor"],
	},
}

config.EditBoxOptions = {
	LeftEditBox1 = {
		DefaultValue = "10",
		Numeric = true,
		MaxCharacters = 3,
		ConfigKey = "burn_length",
		Label = L["Length of burn phase:"],
	},
	LeftEditBox2 = {
		DefaultValue = "55",
		Numeric = true,
		MaxCharacters = 2,
		ConfigKey = "evocate_percent",
		Label = L["Evocate at % mana:"],
	},
	RightEditBox1 = {
		DefaultValue = "97",
		Numeric = true,
		MaxCharacters = 2,
		ConfigKey = "cap_percent",
		Label = L["Exclusively Arcane Blast over % mana:"],
	},
	RightEditBox2 = {
		DefaultValue = "80000",
		Numeric = true,
		MaxCharacters = 7,
		ConfigKey = "combust_at",
		Label = L["Minumum Combustion total damage:"],
	},
}

a.LoadConfigs(config)
