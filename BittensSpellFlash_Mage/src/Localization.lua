-- To update a translation please use the localization utility at:
-- http://wow.curseforge.com/addons/bittens-spellflash-mage/localization/

local AddonName, a = ...
local function DefaultFunction(_, key) return key end
a.Localize = setmetatable({}, {__index = DefaultFunction})
local L = a.Localize

if GetLocale() == "ptBR" then -- Brazilian Portuguese
-- L["Evocate at % mana:"] = ""
-- L["Flash Arcane"] = ""
-- L["Flash Fire"] = ""
-- L["Flash Frost"] = ""
-- L["Length of burn phase:"] = ""
-- L["Minumum Combustion total damage:"] = ""
-- L["Show Combustion Monitor"] = ""
-- L["Use Arcane Missiles below % mana:"] = ""

elseif GetLocale() == "frFR" then -- French
-- L["Evocate at % mana:"] = ""
-- L["Flash Arcane"] = ""
-- L["Flash Fire"] = ""
-- L["Flash Frost"] = ""
-- L["Length of burn phase:"] = ""
-- L["Minumum Combustion total damage:"] = ""
-- L["Show Combustion Monitor"] = ""
-- L["Use Arcane Missiles below % mana:"] = ""

elseif GetLocale() == "deDE" then -- German
L["Evocate at % mana:"] = "Hervorrufung bei % Mana"
L["Flash Arcane"] = "Aufblitzen bei Arkan"
-- L["Flash Fire"] = ""
L["Flash Frost"] = "Aufblitzen bei Frost"
L["Length of burn phase:"] = "Dauer der Burnphase"
-- L["Minumum Combustion total damage:"] = ""
-- L["Show Combustion Monitor"] = ""
L["Use Arcane Missiles below % mana:"] = "Benutze Arkane Geschosse unter % Mana"

elseif GetLocale() == "koKR" then -- Korean
-- L["Evocate at % mana:"] = ""
-- L["Flash Arcane"] = ""
-- L["Flash Fire"] = ""
-- L["Flash Frost"] = ""
-- L["Length of burn phase:"] = ""
-- L["Minumum Combustion total damage:"] = ""
-- L["Show Combustion Monitor"] = ""
-- L["Use Arcane Missiles below % mana:"] = ""

elseif GetLocale() == "esMX" then -- Latin American Spanish
-- L["Evocate at % mana:"] = ""
-- L["Flash Arcane"] = ""
-- L["Flash Fire"] = ""
-- L["Flash Frost"] = ""
-- L["Length of burn phase:"] = ""
-- L["Minumum Combustion total damage:"] = ""
-- L["Show Combustion Monitor"] = ""
-- L["Use Arcane Missiles below % mana:"] = ""

elseif GetLocale() == "ruRU" then -- Russian
-- L["Evocate at % mana:"] = ""
-- L["Flash Arcane"] = ""
-- L["Flash Fire"] = ""
-- L["Flash Frost"] = ""
-- L["Length of burn phase:"] = ""
-- L["Minumum Combustion total damage:"] = ""
-- L["Show Combustion Monitor"] = ""
-- L["Use Arcane Missiles below % mana:"] = ""

elseif GetLocale() == "zhCN" then -- Simplified Chinese
-- L["Evocate at % mana:"] = ""
-- L["Flash Arcane"] = ""
-- L["Flash Fire"] = ""
-- L["Flash Frost"] = ""
-- L["Length of burn phase:"] = ""
-- L["Minumum Combustion total damage:"] = ""
-- L["Show Combustion Monitor"] = ""
-- L["Use Arcane Missiles below % mana:"] = ""

elseif GetLocale() == "esES" then -- Spanish
-- L["Evocate at % mana:"] = ""
-- L["Flash Arcane"] = ""
-- L["Flash Fire"] = ""
-- L["Flash Frost"] = ""
-- L["Length of burn phase:"] = ""
-- L["Minumum Combustion total damage:"] = ""
-- L["Show Combustion Monitor"] = ""
-- L["Use Arcane Missiles below % mana:"] = ""

elseif GetLocale() == "zhTW" then -- Traditional Chinese
-- L["Evocate at % mana:"] = ""
-- L["Flash Arcane"] = ""
-- L["Flash Fire"] = ""
-- L["Flash Frost"] = ""
-- L["Length of burn phase:"] = ""
-- L["Minumum Combustion total damage:"] = ""
-- L["Show Combustion Monitor"] = ""
-- L["Use Arcane Missiles below % mana:"] = ""

end