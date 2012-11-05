-- To update a translation please use the localization utility at:
-- http://wow.curseforge.com/addons/spellflashcore/localization/

local AddonName, a = ...
a.Localize = setmetatable({}, {__index = function(_, key) return key end})
local L = a.Localize

-- Example:
L["English text goes here."] = "Translated text goes here."

if GetLocale() == "ptBR" then -- Brazilian Portuguese
-- L["all events registered"] = ""
-- L["all events unregistered"] = ""
-- L["all settings cleared"] = ""
-- L["debug is disabled"] = ""
-- L["debug is enabled"] = ""

elseif GetLocale() == "frFR" then -- French
-- L["all events registered"] = ""
-- L["all events unregistered"] = ""
-- L["all settings cleared"] = ""
-- L["debug is disabled"] = ""
-- L["debug is enabled"] = ""

elseif GetLocale() == "deDE" then -- German
L["all events registered"] = "Alle Aktionen registriert" -- Needs review
L["all events unregistered"] = "Keine Aktion registriert" -- Needs review
L["all settings cleared"] = "Alle Einstellungen zurückgesetzt" -- Needs review
L["debug is disabled"] = "Fehlersuche ist deaktiviert"
L["debug is enabled"] = "Fehlersuche ist aktiviert"

elseif GetLocale() == "koKR" then -- Korean
L["all events registered"] = "모든 이벤트가 등록되었습니다."
L["all events unregistered"] = "모든 이벤트가 등록되지 않았습니다."
L["all settings cleared"] = "모든 설정이 삭제되었습니다."
L["debug is disabled"] = "디버깅이 비활성화되었습니다."
L["debug is enabled"] = "디버깅이 활성화되었습니다."

elseif GetLocale() == "esMX" then -- Latin American Spanish
-- L["all events registered"] = ""
-- L["all events unregistered"] = ""
-- L["all settings cleared"] = ""
-- L["debug is disabled"] = ""
-- L["debug is enabled"] = ""

elseif GetLocale() == "ruRU" then -- Russian
-- L["all events registered"] = ""
-- L["all events unregistered"] = ""
-- L["all settings cleared"] = ""
-- L["debug is disabled"] = ""
-- L["debug is enabled"] = ""

elseif GetLocale() == "zhCN" then -- Simplified Chinese
-- L["all events registered"] = ""
-- L["all events unregistered"] = ""
L["all settings cleared"] = "所有设置已清除"
L["debug is disabled"] = "除错停用"
L["debug is enabled"] = "除错启用"

elseif GetLocale() == "esES" then -- Spanish
-- L["all events registered"] = ""
-- L["all events unregistered"] = ""
-- L["all settings cleared"] = ""
-- L["debug is disabled"] = ""
-- L["debug is enabled"] = ""

elseif GetLocale() == "zhTW" then -- Traditional Chinese
L["all events registered"] = "所有事件已註冊"
L["all events unregistered"] = "所有事件已取消註冊"
L["all settings cleared"] = "所有設定已清除"
L["debug is disabled"] = "除錯停用"
L["debug is enabled"] = "除錯啟用"

end