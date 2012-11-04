--[[	*** DataStore_Pets ***
Written by : Thaoky, EU-Marécages de Zangar
June 22st, 2009
--]]
if not DataStore then return end

local addonName = "DataStore_Pets"

_G[addonName] = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0")

local addon = _G[addonName]

local THIS_ACCOUNT = "Default"

local AddonDB_Defaults = {
	global = {
		Reference = {
			Spells = {},			-- spell ids are unique, so both mounts & pets are in the same table
		},
		Characters = {
			['*'] = {				-- ["Account.Realm.Name"] 
				lastUpdate = nil,
				CRITTER = {},		-- companion types are used as table names
				MOUNT = {},
			}
		}
	}
}

-- *** Utility functions ***
local function GetPetReference(spellID)
	local modelID = addon.db.global.Reference.Spells[spellID]
	local name, _, icon = GetSpellInfo(spellID)
	
	return modelID, name, icon
end

-- *** Scanning functions ***
local function ScanCompanions(companionType)
	local list = addon.ThisCharacter[companionType]
	local ref = addon.db.global.Reference.Spells
	
	wipe(list)
	
	for i = 1, GetNumCompanions(companionType) do
		local modelID, _, spellID = GetCompanionInfo(companionType, i);
		if modelID and spellID then
			ref[spellID] = modelID
			list[i] = spellID
		end
	end
	
	addon.ThisCharacter.lastUpdate = time()
end

-- *** Event Handlers ***
local function OnPlayerAlive()
	ScanCompanions("CRITTER")
	ScanCompanions("MOUNT")
end

local function OnCompanionUpdate()
	-- COMPANION_UPDATE is triggered very often, but after the very first call, pets & mounts can be scanned automatically. After that, we only need to track COMPANION_LEARNED
	addon:UnregisterEvent("COMPANION_UPDATE")
	ScanCompanions("CRITTER")
	ScanCompanions("MOUNT")
end

local function OnCompanionLearned()
	ScanCompanions("CRITTER")
	ScanCompanions("MOUNT")
end

-- ** Mixins **
local function _GetPets(character, companionType)
	return character[companionType]
end

local function _GetNumPets(pets)
	assert(type(pets) == "table")		-- this is the pointer to a pet table, obtained through GetPets()
	return #pets
end

local function _GetPetInfo(pets, index)
	local spellID = pets[index]
	if spellID then
		local modelID, name, icon = GetPetReference(spellID)
		return modelID, name, spellID, icon
	end
end

local function _IsPetKnown(character, companionType, spellID)
	local pets = _GetPets(character, companionType)
	for i = 1, #pets do
		local _, _, id = _GetPetInfo(pets, i)
		if id == spellID then
			return true			-- returns true if a given spell ID is a known pet or mount
		end
	end
end

local function _GetMountList()
	return addon.MountList
end

local function _GetMountSpellID(itemID)
	-- returns nil if  id is not in the DB, returns the spellID otherwise
	return addon.MountToSpellID[itemID]
end

local function _GetCompanionList()
	return addon.CompanionList
end

local function _GetCompanionSpellID(itemID)
	-- returns nil if  id is not in the DB, returns the spellID otherwise
	return addon.CompanionToSpellID[itemID]
end

local function _GetCompanionLink(spellID)
	local name = GetSpellInfo(spellID)
	return format("|cff71d5ff|Hspell:%s|h[%s]|h|r", spellID, name)
end

local PublicMethods = {
	GetPets = _GetPets,
	GetNumPets = _GetNumPets,
	GetPetInfo = _GetPetInfo,
	IsPetKnown = _IsPetKnown,
	GetMountList = _GetMountList,
	GetMountSpellID = _GetMountSpellID,
	GetCompanionList = _GetCompanionList,
	GetCompanionSpellID = _GetCompanionSpellID,
	GetCompanionLink = _GetCompanionLink,
}

function addon:OnInitialize()
	addon.db = LibStub("AceDB-3.0"):New(addonName .. "DB", AddonDB_Defaults)

	DataStore:RegisterModule(addonName, addon, PublicMethods)
	DataStore:SetCharacterBasedMethod("GetPets")
	DataStore:SetCharacterBasedMethod("IsPetKnown")
end

function addon:OnEnable()
	addon:RegisterEvent("PLAYER_ALIVE", OnPlayerAlive)
	addon:RegisterEvent("COMPANION_UPDATE", OnCompanionUpdate)
	addon:RegisterEvent("COMPANION_LEARNED", OnCompanionLearned)
end

function addon:OnDisable()
	addon:UnregisterEvent("PLAYER_ALIVE")
	addon:UnregisterEvent("COMPANION_LEARNED")
end
