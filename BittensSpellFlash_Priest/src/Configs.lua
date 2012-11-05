local AddonName, a = ...
if a.BuildFail(50000) then return end
local L = a.Localize
local s = SpellFlashAddon
local config = {}

config.event = {}
config.CheckButtonOptions = {
--	LeftCheckButton1 = {
--		DefaultChecked = true,
--		ConfigKey = "disc_off",
--		Label = L["Flash Discipline"],
--	},
--	LeftCheckButton2 = {
--		DefaultChecked = true,
--		ConfigKey = "holy_off",
--		Label = L["Flash Holy"],
--	},
	LeftCheckButton3 = {
		DefaultChecked = true,
		ConfigKey = "shadow_off",
		Label = L["Flash Shadow"],
	},
--	LeftCheckButton5 = {
--		DefaultChecked = false,
--		ConfigKey = "mouseover",
--		Label = L["PW: Shield & Binding Heal on Mouseover"],
--	},
}

a.LoadConfigs(config)
