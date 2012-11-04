--[[	*** DataStore_Reputations ***
Written by : Thaoky, EU-Marécages de Zangar
June 22st, 2009
--]]
if not DataStore then return end

local addonName = "DataStore_Reputations"

_G[addonName] = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0")

local addon = _G[addonName]


local THIS_ACCOUNT = "Default"

local AddonDB_Defaults = {
	global = {
		Characters = {
			['*'] = {				-- ["Account.Realm.Name"] 
				lastUpdate = nil,
				guildName = nil,		-- nil = not in a guild, as returned by GetGuildInfo("player")
				guildRep = nil,
				Factions = {},
			}
		}
	}
}

-- ** Reference tables **
local BottomLevelNames = {
	[-42000] = FACTION_STANDING_LABEL1,	 -- "Hated"
	[-6000] = FACTION_STANDING_LABEL2,	 -- "Hostile"
	[-3000] = FACTION_STANDING_LABEL3,	 -- "Unfriendly"
	[0] = FACTION_STANDING_LABEL4,		 -- "Neutral"
	[3000] = FACTION_STANDING_LABEL5,	 -- "Friendly"
	[9000] = FACTION_STANDING_LABEL6,	 -- "Honored"
	[21000] = FACTION_STANDING_LABEL7,	 -- "Revered"
	[42000] = FACTION_STANDING_LABEL8,	 -- "Exalted"
}

local BottomLevels = { -42000, -6000, -3000, 0, 3000, 9000, 21000, 42000 }

local BF = LibStub("LibBabble-Faction-3.0"):GetUnstrictLookupTable()
local BZ = LibStub("LibBabble-Zone-3.0"):GetUnstrictLookupTable()

--[[	*** Faction UIDs ***
These UIDs have 2 purposes: 
- avoid saving numerous copies of the same string (the faction name)
- minimize the amount of data sent across the network when sharing accounts (since both sides have the same reference table)

Note: Let the system manage the ids, DO NOT delete entries from this table, if a faction is removed from the game, mark it as OLD_ or whatever.
--]]
local FactionUIDs = {
	BZ["Darnassus"],
	BF["Exodar"],
	BZ["Gnomeregan"],
	BZ["Ironforge"],
	BF["Stormwind"],
	BF["Darkspear Trolls"],
	BZ["Orgrimmar"],
	BZ["Thunder Bluff"],
	BZ["Undercity"],
	BZ["Silvermoon City"],
	BF["The League of Arathor"],
	BF["Silverwing Sentinels"],
	BF["Stormpike Guard"],
	BF["The Defilers"],
	BF["Warsong Outriders"],
	BF["Frostwolf Clan"],
	BZ["Booty Bay"],
	BZ["Everlook"],
	BZ["Gadgetzan"],
	BZ["Ratchet"],
	BF["Argent Dawn"],
	BF["Bloodsail Buccaneers"],
	BF["Brood of Nozdormu"],
	BF["Cenarion Circle"],
	BF["Darkmoon Faire"],
	BF["Gelkis Clan Centaur"],
	BF["Hydraxian Waterlords"],
	BF["Magram Clan Centaur"],
	BF["Ravenholdt"],
	BF["Shen'dralar"],
	BF["Syndicate"],
	BF["Thorium Brotherhood"],
	BF["Timbermaw Hold"],
	BF["Tranquillien"],
	BF["Wintersaber Trainers"],
	BF["Zandalar Tribe"],
	BF["Ashtongue Deathsworn"],
	BF["Cenarion Expedition"],
	BF["The Consortium"],
	BF["Honor Hold"],
	BF["Kurenai"],
	BF["The Mag'har"],
	BF["Netherwing"],
	BF["Ogri'la"],
	BF["Sporeggar"],
	BF["Thrallmar"],
	BF["Lower City"],
	BF["Sha'tari Skyguard"],
	BF["Shattered Sun Offensive"],
	BF["The Aldor"],
	BF["The Scryers"],
	BF["The Sha'tar"],
	BF["Keepers of Time"],
	BF["The Scale of the Sands"],
	BF["The Violet Eye"],
	BF["Argent Crusade"],
	BF["Kirin Tor"],
	BF["The Kalu'ak"],
	BF["The Wyrmrest Accord"],
	BF["Knights of the Ebon Blade"],
	BF["The Sons of Hodir"],
	BF["The Ashen Verdict"],
	BF["Alliance Vanguard"],
	BF["Explorers' League"],
	BF["The Frostborn"],
	BF["The Silver Covenant"],
	BF["Valiance Expedition"],
	BF["Horde Expedition"],
	BF["The Hand of Vengeance"],
	BF["The Sunreavers"],
	BF["The Taunka"],
	BF["Warsong Offensive"],
	BF["Frenzyheart Tribe"],
	BF["The Oracles"],
	BF["Alliance"],
	BF["Horde"],
	BF["Gilneas"],
	BF["Bilgewater Cartel"],
	
	-- cataclysm
	BF["Guardians of Hyjal"],
	BF["The Earthen Ring"],
	BF["Therazane"],
	BF["Wildhammer Clan"],
	BF["Ramkahen"],
	BF["Baradin's Wardens"],
	BF["Dragonmaw Clan"],
	BF["Hellscream's Reach"],
	BF["Avengers of Hyjal"],
	
	-- pandaria
	BF["Chee Chee"],
	BF["Ella"],
	BF["Farmer Fung"],
	BF["Fish Fellreed"],
	BF["Forest Hozen"],
	BF["Gina Mudclaw"],
	BF["Golden Lotus"],
	BF["Haohan Mudclaw"],
	BF["Jogu the Drunk"],
	BF["Nat Pagle"],
	BF["Old Hillpaw"],
	BF["Order of the Cloud Serpent"],
	BF["Pearlfin Jinyu"],
	BF["Shado-Pan"],
	BF["Shang Xi's Academy"],
	BF["Sho"],
	BF["The Anglers"],
	BF["The August Celestials"],
	BF["The Black Prince"],
	BF["The Brewmasters"],
	BF["The Klaxxi"],
	BF["The Lorewalkers"],
	BF["The Tillers"],
	BF["Tina Mudclaw"],
	BF["Tushui Pandaren"],
	BF["Huojin Pandaren"],
}

local FactionUIDsRev = {}

for k, v in pairs(FactionUIDs) do
	FactionUIDsRev[v] = k	-- ex : [BZ["Darnassus"]] = 1
end

-- *** Utility functions ***
local headersState = {}
local inactive = {}

local function SaveHeaders()
	local headerCount = 0		-- use a counter to avoid being bound to header names, which might not be unique.
	
	for i = GetNumFactions(), 1, -1 do		-- 1st pass, expand all categories
		local name, _, _, _, _, _, _,	_, isHeader, isCollapsed = GetFactionInfo(i)
		if isHeader then
			headerCount = headerCount + 1
			if isCollapsed then
				ExpandFactionHeader(i)
				headersState[headerCount] = true
			end
		end
	end
	
	-- code disabled until I can find the other addon that conflicts with this and slows down the machine.
	
	-- If a header faction, like alliance or horde, has all child factions set to inactive, it will not be visible, so activate it, and deactivate it after the scan (thanks Zaphon for this)
	-- for i = GetNumFactions(), 1, -1 do
		-- if IsFactionInactive(i) then
			-- local name = GetFactionInfo(i)
			-- inactive[name] = true
			-- SetFactionActive(i)
		-- end
	-- end
end

local function RestoreHeaders()
	local headerCount = 0
	for i = GetNumFactions(), 1, -1 do
		local name, _, _, _, _, _, _,	_, isHeader = GetFactionInfo(i)
		
		-- if inactive[name] then
			-- SetFactionInactive(i)
		-- end
		
		if isHeader then
			headerCount = headerCount + 1
			if headersState[headerCount] then
				CollapseFactionHeader(i)
			end
		end
	end
	wipe(headersState)
end

local function GetLimits(earned)
	-- return the bottom & top values of a given rep level based on the amount of earned rep
	local top = 43000
	local index = #BottomLevels
	
	while (earned < BottomLevels[index]) do
		top = BottomLevels[index]
		index = index - 1
	end
	
	return BottomLevels[index], top
end

local function GetEarnedRep(character, faction)
	local earned 
	if character.guildName and faction == character.guildName then
		return character.guildRep
	end
	return character.Factions[FactionUIDsRev[faction]]
end

-- *** Scanning functions ***
local currentGuildName

local function ScanReputations()
	SaveHeaders()
	local factions = addon.ThisCharacter.Factions
	wipe(factions)
	
	for i = 1, GetNumFactions() do		-- 2nd pass, data collection
		local name, _, _, _, _, earned = GetFactionInfo(i)
		if (earned and earned > 0) then		-- new in 3.0.2, headers may have rep, ex: alliance vanguard + horde expedition
			if FactionUIDsRev[name] then		-- is this a faction we're tracking ?
				factions[FactionUIDsRev[name]] = earned
			end
		end
	end

	RestoreHeaders()
	addon.ThisCharacter.lastUpdate = time()
end

local function ScanGuildReputation()
	SaveHeaders()
	for i = 1, GetNumFactions() do		-- 2nd pass, data collection
		local name, _, _, _, _, earned = GetFactionInfo(i)
		if name and name == currentGuildName then
			addon.ThisCharacter.guildRep = earned
		end
	end
	RestoreHeaders()
end

-- *** Event Handlers ***
local function OnPlayerAlive()
	ScanReputations()
end

local function OnPlayerGuildUpdate()
	-- at login this event is called between OnEnable and PLAYER_ALIVE, where GetGuildInfo returns a wrong value
	-- however, the value returned here is correct
	if IsInGuild() and not currentGuildName then		-- the event may be triggered multiple times, and GetGuildInfo may return incoherent values in subsequent calls, so only save if we have no value.
		currentGuildName = GetGuildInfo("player")
		if currentGuildName then	
			addon.ThisCharacter.guildName = currentGuildName
			ScanGuildReputation()
		end
	end
end

local function OnFactionChange(event, messageType, faction, amount)
	if messageType ~= "FACTION" then return end
	
	if faction == GUILD then
		ScanGuildReputation()
		return
	end
	
	local bottom, top, earned = DataStore:GetRawReputationInfo(DataStore:GetCharacter(), faction)
	if not earned then 	-- faction not in the db, scan all
		ScanReputations()	
		return 
	end
	
	local newValue = earned + amount
	if newValue >= top then	-- rep status increases (to revered, etc..)
		ScanReputations()					-- so scan all
	else
		addon.ThisCharacter.Factions[FactionUIDsRev[faction]] = format("%s|%s|%s", bottom, top, newValue)
		addon.ThisCharacter.lastUpdate = time()
	end
end


-- ** Mixins **
local function _GetReputationInfo(character, faction)
	local earned = GetEarnedRep(character, faction)
	if not earned then return end

	local bottom, top = GetLimits(earned)
	local rate = (earned - bottom) / (top - bottom) * 100

	-- ex: "Revered", 15400, 21000, 73%
	return BottomLevelNames[bottom], (earned - bottom), (top - bottom), rate 
end

local function _GetRawReputationInfo(character, faction)
	-- same as GetReputationInfo, but returns raw values
	
	local earned = GetEarnedRep(character, faction)
	if not earned then return end

	return GetLimits(earned), earned
end

local function _GetReputations(character)
	return character.Factions
end

local function _GetGuildReputation(character)
	return character.guildRep or 0
end

local function _GetReputationLevels()
	return BottomLevels
end

local function _GetReputationLevelText(bottom)
	return BottomLevelNames[bottom]
end

local PublicMethods = {
	GetReputationInfo = _GetReputationInfo,
	GetRawReputationInfo = _GetRawReputationInfo,
	GetReputations = _GetReputations,
	GetGuildReputation = _GetGuildReputation,
	GetReputationLevels = _GetReputationLevels,
	GetReputationLevelText = _GetReputationLevelText,
}

function addon:OnInitialize()
	addon.db = LibStub("AceDB-3.0"):New(addonName .. "DB", AddonDB_Defaults)

	DataStore:RegisterModule(addonName, addon, PublicMethods)
	DataStore:SetCharacterBasedMethod("GetReputationInfo")
	DataStore:SetCharacterBasedMethod("GetRawReputationInfo")
	DataStore:SetCharacterBasedMethod("GetReputations")
	DataStore:SetCharacterBasedMethod("GetGuildReputation")
end

function addon:OnEnable()
	addon:RegisterEvent("PLAYER_ALIVE", OnPlayerAlive)
	addon:RegisterEvent("COMBAT_TEXT_UPDATE", OnFactionChange)
	addon:RegisterEvent("PLAYER_GUILD_UPDATE", OnPlayerGuildUpdate)				-- for gkick, gquit, etc..
end

function addon:OnDisable()
	addon:UnregisterEvent("PLAYER_ALIVE")
	addon:UnregisterEvent("COMBAT_TEXT_UPDATE")
	addon:UnregisterEvent("PLAYER_GUILD_UPDATE")
end

-- *** Utility functions ***
local PT = LibStub("LibPeriodicTable-3.1")

function addon:GetSource(searchedID)
	-- returns the faction where a given item ID can be obtained, as well as the level
	local level, repData = PT:ItemInSet(searchedID, "Reputation.Reward")
	if level and repData then
		local _, _, faction = strsplit(".", repData)		-- ex: "Reputation.Reward.Sporeggar"
		faction = BF[faction] or faction		-- localize faction name if possible
	
		-- level = 7,  29150:7 where 7 means revered
		return faction, _G["FACTION_STANDING_LABEL"..level]
	end
end
