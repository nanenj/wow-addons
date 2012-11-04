--[[	*** DataStore_Currencies ***
Written by : Thaoky, EU-Marécages de Zangar
July 6th, 2009
--]]
if not DataStore then return end

local addonName = "DataStore_Currencies"

_G[addonName] = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0")

local addon = _G[addonName]

local THIS_ACCOUNT = "Default"

local AddonDB_Defaults = {
	global = {
		Reference = {
			Currencies = {},			-- ex: [1] = "Dungeon and Raid", [2] = "Justice Points", ...
			CurrencyTextRev = {},	-- reverse lookup

			Headers = {},			-- ex: [1] = "Dungeon and Raid", [2] = "Miscellaneous", ...
			HeadersRev = {},		-- reverse lookup of Headers
		},
		Characters = {
			['*'] = {				-- ["Account.Realm.Name"] 
				lastUpdate = nil,
				Currencies = {},
				Archeology = {},
			}
		}
	}
}

-- *** Utility functions ***
local bAnd = bit.band

local function LeftShift(value, numBits)
	return value * (2 ^ numBits)
end

local function RightShift(value, numBits)
	-- for bits beyond bit 31
	return math.floor(value / 2^numBits)
end

local headersState
local headerCount

local function SaveHeaders()
	headersState = {}
	headerCount = 0		-- use a counter to avoid being bound to header names, which might not be unique.
	
	for i = GetCurrencyListSize(), 1, -1 do		-- 1st pass, expand all categories
		local _, isHeader, isExpanded = GetCurrencyListInfo(i)
		if isHeader then
			headerCount = headerCount + 1
			if not isExpanded then
				ExpandCurrencyList(i, 1)
				headersState[headerCount] = true
			end
		end
	end
end

local function RestoreHeaders()
	headerCount = 0
	for i = GetCurrencyListSize(), 1, -1 do
		local _, isHeader = GetCurrencyListInfo(i)
		if isHeader then
			headerCount = headerCount + 1
			if headersState[headerCount] then
				ExpandCurrencyList(i, 0)		-- collapses the header
			end
		end
	end
	headersState = nil
end


-- *** Scanning functions ***
local function ScanCurrencies()
	SaveHeaders()
	
	local ref = addon.db.global.Reference
	local currencies = addon.ThisCharacter.Currencies
	wipe(currencies)
	
	local attrib, refIndex
	
	
	for i = 1, GetCurrencyListSize() do
		local name, isHeader, _, _, _, count, icon = GetCurrencyListInfo(i)
		
		if not ref.CurrencyTextRev[name] then		-- currency does not exist yet in our reference table
			table.insert(ref.Currencies, format("%s|%s", name, icon or "") )			-- ex; [3] = "PVP"
			ref.CurrencyTextRev[name] = #ref.Currencies		-- ["PVP"] = 3
		end

		-- bit 0 : isHeader
		-- bits 1-6 : index in the reference table (up to 64 values, should leave room for some time)
		-- bits 7- : count
		
		if isHeader then
			attrib = 1
			count = 0
		else
			attrib = 0
		end
		
		attrib = attrib + LeftShift(ref.CurrencyTextRev[name], 1)	-- index in the ref table
		attrib = attrib + LeftShift(count, 7)	-- item count

		currencies[i] = attrib
	end
	
	RestoreHeaders()
	
	addon.ThisCharacter.lastUpdate = time()
end

local function ScanArcheology()
	local currencies = addon.ThisCharacter.Archeology
	wipe(currencies)
	
	for i = 1, GetNumArchaeologyRaces() do
		-- Warning for extreme caution here: while testing MoP, the following line of code triggered an error while trying to activate a glyph.
		-- _, _, _, currencies[i] = GetArchaeologyRaceInfo(i)
		-- The work around is to simply unroll the code on two lines.. I'll have to investigate why
		-- At first sight, the problem seems to come from addressing the table element direcly, same has happened in DataStore_Stats.
		
		local _, _, _, n = GetArchaeologyRaceInfo(i)
		currencies[i] = n
	end

end

-- *** Event Handlers ***
local function OnPlayerAlive()
	ScanCurrencies()
end

local function OnCurrencyDisplayUpdate()
	ScanCurrencies()
	ScanArcheology()
end

local function OnChatMsgSystem(event, arg)
	if arg and arg == ITEM_REFUND_MSG then
		ScanCurrencies()
		ScanArcheology()
	end
end

local function OnArtifactHistoryReady()
	ScanArcheology()
end

-- ** Mixins **
local function _GetNumCurrencies(character)
	return #character.Currencies
end

local function _GetCurrencyInfo(character, index)
	local ref = addon.db.global.Reference
	local currency = character.Currencies[index]
	
	
	local isHeader = bAnd(currency, 1)
	isHeader = (isHeader == 1) and true or nil
	
	local refIndex = bAnd(RightShift(currency, 1), 63)
	local count = RightShift(currency, 7)

	local info = ref.Currencies[refIndex]
	local name, icon = strsplit("|", info)
	
	return isHeader, name, count, icon
end

local function _GetCurrencyInfoByName(character, token)
	local ref = addon.db.global.Reference
	
	local isHeader, name, count, icon
	for i = 1, #character.Currencies do
		isHeader, name, count, icon = _GetCurrencyInfo(character, i)
	
		if name == token then
			return isHeader, name, count, icon
		end
	end

end

local function _GetCurrencyItemCount(character, searchedID)
	return 0		-- quick workaround / temporary fix
	
	-- local isHeader, id, count
	
	-- for i = 1, #character.Currencies do
		-- isHeader, id, count = strsplit("|", character.Currencies[i])
	
		-- if isHeader == "1" then
			-- if tonumber(id) == searchedID then
				-- return tonumber(count)
			-- end
		-- end
	-- end
end

local function _GetArcheologyCurrencyInfo(character, index)
	return character.Archeology[index] or 0
end

local PublicMethods = {
	GetNumCurrencies = _GetNumCurrencies,
	GetCurrencyInfo = _GetCurrencyInfo,
	GetCurrencyInfoByName = _GetCurrencyInfoByName,
	GetCurrencyItemCount = _GetCurrencyItemCount,
	GetArcheologyCurrencyInfo = _GetArcheologyCurrencyInfo,
}

function addon:OnInitialize()
	addon.db = LibStub("AceDB-3.0"):New(addonName .. "DB", AddonDB_Defaults)

	DataStore:RegisterModule(addonName, addon, PublicMethods)
	DataStore:SetCharacterBasedMethod("GetNumCurrencies")
	DataStore:SetCharacterBasedMethod("GetCurrencyInfo")
	DataStore:SetCharacterBasedMethod("GetCurrencyInfoByName")
	DataStore:SetCharacterBasedMethod("GetCurrencyItemCount")
	DataStore:SetCharacterBasedMethod("GetArcheologyCurrencyInfo")
end

function addon:OnEnable()
	addon:RegisterEvent("PLAYER_ALIVE", OnPlayerAlive)
	addon:RegisterEvent("CURRENCY_DISPLAY_UPDATE", OnCurrencyDisplayUpdate)
	addon:RegisterEvent("CHAT_MSG_SYSTEM", OnChatMsgSystem)
	
	local _, _, arch = GetProfessions()

	if arch then
		addon:RegisterEvent("ARTIFACT_HISTORY_READY", OnArtifactHistoryReady)
		RequestArtifactCompletionHistory()		-- this will trigger ARTIFACT_HISTORY_READY
	end
end

function addon:OnDisable()
	addon:UnregisterEvent("CURRENCY_DISPLAY_UPDATE")
end
