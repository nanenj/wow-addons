if not DataStore then return end

local addonName = "DataStore_Characters"
local addon = _G[addonName]
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

function addon:SetupOptions()
	DataStore:AddOptionCategory(DataStoreCharactersOptions, addonName, "DataStore")

	-- localize options
	DataStoreCharactersOptions_RequestPlayTimeText:SetText(L["REQUEST_PLAYTIME_TEXT"])
	DataStoreCharactersOptions_HideRealPlayTimeText:SetText(L["HIDE_PLAYTIME_TEXT"])
	
	DataStore:SetCheckBoxTooltip(DataStoreCharactersOptions_RequestPlayTime, L["REQUEST_PLAYTIME_TITLE"], L["REQUEST_PLAYTIME_ENABLED"], L["REQUEST_PLAYTIME_DISABLED"])
	DataStore:SetCheckBoxTooltip(DataStoreCharactersOptions_HideRealPlayTime, L["HIDE_PLAYTIME_TITLE"], L["HIDE_PLAYTIME_ENABLED"], L["HIDE_PLAYTIME_DISABLED"])
	
	-- restore saved options to gui
	DataStoreCharactersOptions_RequestPlayTime:SetChecked(DataStore:GetOption(addonName, "RequestPlayTime"))
	DataStoreCharactersOptions_HideRealPlayTime:SetChecked(DataStore:GetOption(addonName, "HideRealPlayTime"))
end
