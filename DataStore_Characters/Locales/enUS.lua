local debug = false
--[===[@debug@
debug = true
--@end-debug@]===]

local L = LibStub("AceLocale-3.0"):NewLocale("DataStore_Characters", "enUS", true, debug)

L["HIDE_PLAYTIME_DISABLED"] = "Your real play time will be displayed."
L["HIDE_PLAYTIME_ENABLED"] = "A play time of zero days will be displayed."
L["HIDE_PLAYTIME_TEXT"] = "Hide real play time."
L["HIDE_PLAYTIME_TITLE"] = "Hide Real Play Time"
L["REQUEST_PLAYTIME_DISABLED"] = "Play time will not be queried at logon. The last known value will be sent to client addons."
L["REQUEST_PLAYTIME_ENABLED"] = "Play time will be queried every time you log in."
L["REQUEST_PLAYTIME_TEXT"] = "Request play time at logon."
L["REQUEST_PLAYTIME_TITLE"] = "Request Play Time"

