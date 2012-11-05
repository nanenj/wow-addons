local AddonName, a = ...
local L = a.Localize

a.LoadConfigs({
	CheckButtonOptions = {
		LeftCheckButton1 = {
			DefaultChecked = true,
			ConfigKey = "brewmaster_off",
			Label = L["Flash Brewmaster"],
		},
		LeftCheckButton2 = {
			DefaultChecked = true,
			ConfigKey = "windwalker_off",
			Label = L["Flash Windwalker"],
		},
	}
})
