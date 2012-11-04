--[[	*** DataStore_Spells ***
Written by : Thaoky, EU-Marécages de Zangar
July 6th, 2009
--]]
if not DataStore then return end

local addonName = "DataStore_Spells"

_G[addonName] = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0")

local addon = _G[addonName]

local THIS_ACCOUNT = "Default"

local AddonDB_Defaults = {
	global = {
		Characters = {
			['*'] = {				-- ["Account.Realm.Name"] 
				lastUpdate = nil,
				SpellTabs = {},
				Spells = {
					['*'] = {		-- "General", "Arcane", "Fire", etc...
						['*'] = nil
					}
				},
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

-- *** Scanning functions ***
local function ScanSpellTab(tabID)
	local tabName, _, offset, numSpells = GetSpellTabInfo(tabID);
	if not tabName then return end
	
	addon.ThisCharacter.SpellTabs[tabID] = tabName
	
	local spells = addon.ThisCharacter.Spells
	wipe(spells[tabName])
	
	local spellType, spellID
	local attrib
	
	for index = offset + 1, offset + numSpells do
		spellType, spellID = GetSpellBookItemInfo(index, BOOKTYPE_SPELL)
		if spellID then
			attrib = 0
			if spellType == "FUTURESPELL" then
				attrib = GetSpellAvailableLevel(index, BOOKTYPE_SPELL)	-- 8 bits for the level
			end

			if spellType == "FLYOUT" then	-- flyout spells, like list of mage portals
				local flyoutID = spellID
				local _, _, numSlots, isKnown = GetFlyoutInfo(flyoutID)
				
				if isKnown then
					for i = 1, numSlots do
						local flyoutSpellID, _, isFlyoutSpellKnown = GetFlyoutSlotInfo(flyoutID, i)
						if isFlyoutSpellKnown then
							-- all info on this spell can be retrieved with GetSpellInfo()
							table.insert(spells[tabName], LeftShift(flyoutSpellID, 8))
						end
					end
				end
			else
				-- bits 0-7 : level (0 if known spell)
				-- bits 8- : spellID
				
				attrib = attrib + LeftShift(spellID, 8)
				-- all info on this spell can be retrieved with GetSpellInfo()
				table.insert(spells[tabName], attrib)
			end
		end
	end
end

local function ScanSpells()
	wipe(addon.ThisCharacter.SpellTabs)
	for tabID = 1, GetNumSpellTabs() do
		ScanSpellTab(tabID)
	end
	addon.ThisCharacter.lastUpdate = time()
end

-- *** Event Handlers ***
local function OnPlayerAlive()
	ScanSpells()
end

local function OnLearnedSpellInTab()
	ScanSpells()
end

-- ** Mixins **
local function _GetNumSpells(character, school)
	return #character.Spells[school]
end
	
local function _GetSpellInfo(character, school, index)
	-- bits 0-7 : level (0 if known spell)
	-- bits 8- : spellID

	local spellID, availableAt
	
	local spell = character.Spells[school][index]
	if spell then
		availableAt = bAnd(spell, 255)
		spellID = RightShift(spell, 8)
	end
	return spellID, availableAt
end

local function _IsSpellKnown(character, spellID)
	for schoolName, _ in pairs(character.Spells) do
		for i = 1, _GetNumSpells(character, schoolName) do
			local id = _GetSpellInfo(character, schoolName, i)
			if id == spellID then
				return true
			end
		end
	end
end

local function _GetSpellTabs(character)
	return character.SpellTabs
end

local PublicMethods = {
	GetNumSpells = _GetNumSpells,
	GetSpellInfo = _GetSpellInfo,
	IsSpellKnown = _IsSpellKnown,
	GetSpellTabs = _GetSpellTabs,
}

function addon:OnInitialize()
	addon.db = LibStub("AceDB-3.0"):New(addonName .. "DB", AddonDB_Defaults)

	DataStore:RegisterModule(addonName, addon, PublicMethods)
	DataStore:SetCharacterBasedMethod("GetNumSpells")
	DataStore:SetCharacterBasedMethod("GetSpellInfo")
	DataStore:SetCharacterBasedMethod("IsSpellKnown")
	DataStore:SetCharacterBasedMethod("GetSpellTabs")
end
	
function addon:OnEnable()
	addon:RegisterEvent("PLAYER_ALIVE", OnPlayerAlive)
	addon:RegisterEvent("LEARNED_SPELL_IN_TAB", OnLearnedSpellInTab)
end

function addon:OnDisable()
	addon:UnregisterEvent("PLAYER_ALIVE")
	addon:UnregisterEvent("LEARNED_SPELL_IN_TAB")
end
