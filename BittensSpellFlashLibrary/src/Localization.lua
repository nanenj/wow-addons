-- To update a translation please use the localization utility at:
-- http://wow.curseforge.com/addons/bitten-common/localization/

local AddonName, a = ...
local function DefaultFunction(_, key) return key end
a.Localize = setmetatable({}, {__index = DefaultFunction})
local L = a.Localize

-- Example:
L["English text goes here."] = "Translated text goes here."

if GetLocale() == "ptBR" then -- Brazilian Portuguese
L["Print Debugging Info"] = "Imprimir Informações de Depuração" -- Needs review
-- L["Toggle AoE Mode"] = ""
-- L["Toggle Floating Combat Text"] = ""

elseif GetLocale() == "frFR" then -- French
-- L["Print Debugging Info"] = ""
-- L["Toggle AoE Mode"] = ""
-- L["Toggle Floating Combat Text"] = ""

elseif GetLocale() == "deDE" then -- German
-- L["Print Debugging Info"] = ""
-- L["Toggle AoE Mode"] = ""
-- L["Toggle Floating Combat Text"] = ""

elseif GetLocale() == "koKR" then -- Korean
-- L["Print Debugging Info"] = ""
-- L["Toggle AoE Mode"] = ""
-- L["Toggle Floating Combat Text"] = ""

elseif GetLocale() == "esMX" then -- Latin American Spanish
-- L["Print Debugging Info"] = ""
-- L["Toggle AoE Mode"] = ""
-- L["Toggle Floating Combat Text"] = ""

elseif GetLocale() == "ruRU" then -- Russian
L["Print Debugging Info"] = "Показать Окно Ошибок" -- Needs review
L["Toggle AoE Mode"] = "Включить режим АоЕ" -- Needs review
L["Toggle Floating Combat Text"] = "Включить Всплывающий Текст Боя" -- Needs review

elseif GetLocale() == "zhCN" then -- Simplified Chinese
-- L["Print Debugging Info"] = ""
-- L["Toggle AoE Mode"] = ""
-- L["Toggle Floating Combat Text"] = ""

elseif GetLocale() == "esES" then -- Spanish
-- L["Print Debugging Info"] = ""
-- L["Toggle AoE Mode"] = ""
-- L["Toggle Floating Combat Text"] = ""

elseif GetLocale() == "zhTW" then -- Traditional Chinese
-- L["Print Debugging Info"] = ""
-- L["Toggle AoE Mode"] = ""
-- L["Toggle Floating Combat Text"] = ""

end