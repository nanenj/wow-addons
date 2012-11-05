-- To update a translation please use the localization utility at:
-- http://wow.curseforge.com/addons/bittens-spellflash-priest/localization/

local AddonName, a = ...
local function DefaultFunction(_, key) return key end
a.Localize = setmetatable({}, {__index = DefaultFunction})
local L = a.Localize

if GetLocale() == "ptBR" then -- Brazilian Portuguese
-- L["Flash Discipline"] = ""
-- L["Flash Holy"] = ""
-- L["Flash Shadow"] = ""
-- L["PW: Shield & Binding Heal on Mouseover"] = ""

elseif GetLocale() == "frFR" then -- French
-- L["Flash Discipline"] = ""
-- L["Flash Holy"] = ""
-- L["Flash Shadow"] = ""
-- L["PW: Shield & Binding Heal on Mouseover"] = ""

elseif GetLocale() == "deDE" then -- German
L["Flash Discipline"] = "Aufblitzen bei Disziplin" -- Needs review
L["Flash Holy"] = "Aufblitzen bei Heilig" -- Needs review
L["Flash Shadow"] = "Aufblitzen bei Schatten" -- Needs review
-- L["PW: Shield & Binding Heal on Mouseover"] = ""

elseif GetLocale() == "koKR" then -- Korean
-- L["Flash Discipline"] = ""
-- L["Flash Holy"] = ""
-- L["Flash Shadow"] = ""
-- L["PW: Shield & Binding Heal on Mouseover"] = ""

elseif GetLocale() == "esMX" then -- Latin American Spanish
-- L["Flash Discipline"] = ""
-- L["Flash Holy"] = ""
-- L["Flash Shadow"] = ""
-- L["PW: Shield & Binding Heal on Mouseover"] = ""

elseif GetLocale() == "ruRU" then -- Russian
-- L["Flash Discipline"] = ""
-- L["Flash Holy"] = ""
-- L["Flash Shadow"] = ""
-- L["PW: Shield & Binding Heal on Mouseover"] = ""

elseif GetLocale() == "zhCN" then -- Simplified Chinese
-- L["Flash Discipline"] = ""
-- L["Flash Holy"] = ""
-- L["Flash Shadow"] = ""
-- L["PW: Shield & Binding Heal on Mouseover"] = ""

elseif GetLocale() == "esES" then -- Spanish
-- L["Flash Discipline"] = ""
-- L["Flash Holy"] = ""
-- L["Flash Shadow"] = ""
-- L["PW: Shield & Binding Heal on Mouseover"] = ""

elseif GetLocale() == "zhTW" then -- Traditional Chinese
-- L["Flash Discipline"] = ""
-- L["Flash Holy"] = ""
-- L["Flash Shadow"] = ""
-- L["PW: Shield & Binding Heal on Mouseover"] = ""

end