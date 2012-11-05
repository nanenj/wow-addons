-- To update a translation please use the localization utility at:
-- http://wow.curseforge.com/addons/bittens-spellflash-monk/localization/

local AddonName, a = ...
local function DefaultFunction(_, key) return key end
a.Localize = setmetatable({}, {__index = DefaultFunction})
local L = a.Localize

if GetLocale() == "ptBR" then -- Brazilian Portuguese
-- L["Flash Brewmaster"] = ""
-- L["Flash Windwalker"] = ""

elseif GetLocale() == "frFR" then -- French
-- L["Flash Brewmaster"] = ""
-- L["Flash Windwalker"] = ""

elseif GetLocale() == "deDE" then -- German
-- L["Flash Brewmaster"] = ""
-- L["Flash Windwalker"] = ""

elseif GetLocale() == "koKR" then -- Korean
-- L["Flash Brewmaster"] = ""
-- L["Flash Windwalker"] = ""

elseif GetLocale() == "esMX" then -- Latin American Spanish
-- L["Flash Brewmaster"] = ""
-- L["Flash Windwalker"] = ""

elseif GetLocale() == "ruRU" then -- Russian
-- L["Flash Brewmaster"] = ""
-- L["Flash Windwalker"] = ""

elseif GetLocale() == "zhCN" then -- Simplified Chinese
-- L["Flash Brewmaster"] = ""
-- L["Flash Windwalker"] = ""

elseif GetLocale() == "esES" then -- Spanish
-- L["Flash Brewmaster"] = ""
-- L["Flash Windwalker"] = ""

elseif GetLocale() == "zhTW" then -- Traditional Chinese
-- L["Flash Brewmaster"] = ""
-- L["Flash Windwalker"] = ""

end