--[[	*** DataStore_Talents ***
Written by : Thaoky, EU-Marécages de Zangar
June 23rd, 2009
--]]
if not DataStore then return end

local addonName = "DataStore_Talents"

_G[addonName] = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0")

local addon = _G[addonName]

local THIS_ACCOUNT = "Default"
local commPrefix = "DS_Tal"		-- let's keep it a bit shorter than the addon name, this goes on a comm channel, a byte is a byte ffs :p

-- Message types
local MSG_TALENTS_REQUEST					= 1	-- request talents ..
local MSG_TALENTS_TRANSFER					= 2	-- .. and send the data


-- TODO: 
	-- add support for hunter pets' talent trees

local NUM_GLYPH_SLOTS = 6

local AddonDB_Defaults = {
	global = {
		Reference = {
			GlyphNames = {},		-- ex: Arcane Barrage
		},
		Guilds = {
			['*'] = {			-- ["Account.Realm.Name"] 
				Members = {
					['*'] = {				-- ["MemberName"] 
						lastUpdate = nil,
						Class = nil,
						TalentTrees = {},
					}
				}
			},
		},
		Characters = {
			['*'] = {				-- ["Account.Realm.Name"] 
				lastUpdate = nil,
				ActiveTalents = nil,		-- 1 for primary, 2 for secondary
				Class = nil,				-- englishClass
				PointsSpent = nil,		-- "51,5,15 ...	" 	3 numbers for primary spec, 3 for secondary, comma separated
				TalentTrees = {},
				Glyphs = {},				-- socketed glyphs
				GlyphList = {},			-- full list of glyphs
			}
		}
	}
}

-- This table saved reference data required to rebuild a talent tree for a class when logged in under another class.
-- The API does not provide that ability, but saving and reusing is fine
local ReferenceDB_Defaults = {
	global = {
		['*'] = {							-- "englishClass" like "MAGE", "DRUID" etc..
			Order = nil,
			Version = nil,					-- build number under which this class ref was saved
			Locale = nil,					-- locale under which this class ref was saved
			Glyphs = {},
			Trees = {
				['*'] = {					-- tree name
					icon = nil,
					background = nil,
					talents = {},			-- name, icon, max rank etc..for talent x in this tree
					prereqs = {}			-- prerequisites
				},
			}
		},
	}
}

local UI_ICONS_PATH = "Interface\\Icons\\"
local BACKGROUND_PATH = "Interface\\TalentFrame\\"

-- *** Utility functions ***
local bAnd = bit.band

local function GetVersion()
	local _, version = GetBuildInfo()
	return tonumber(version)
end

local function LeftShift(value, numBits)
	return value * (2 ^ numBits)
end

local function RightShift(value, numBits)
	-- for bits beyond bit 31
	return math.floor(value / 2^numBits)
end

local function GetThisGuild()
	local guild = GetGuildInfo("player")
	if guild then 
		local key = format("%s.%s.%s", THIS_ACCOUNT, GetRealmName(), guild)
		return addon.db.global.Guilds[key]
	end
end

local function GetMemberKey(guild, member)
	-- returns the appropriate key to address a guild member. 
	--	Either it's a known alt ==> point to the characters table
	--	Or it's a guild member ==> point to the guild table
	local main = DataStore:GetNameOfMain(member)
	if main and main == UnitName("player") then
		local key = format("%s.%s.%s", THIS_ACCOUNT, GetRealmName(), member)
		return addon.db.global.Characters[key]
	end
	return guild.Members[member]
end

local function GuildBroadcast(messageType, ...)
	local serializedData = addon:Serialize(messageType, ...)
	addon:SendCommMessage(commPrefix, serializedData, "GUILD")
end

local function GuildWhisper(player, messageType, ...)
	if DataStore:IsGuildMemberOnline(player) then
		local serializedData = addon:Serialize(messageType, ...)
		addon:SendCommMessage(commPrefix, serializedData, "WHISPER", player)
	end
end


-- *** Scanning functions ***
local LocaleExceptions = {}		--- see ScanTalentReference() for an explanation on the purpose of this table

-- SpellBookName = TalentTreeName	
if GetLocale() == "enUS" then
	LocaleExceptions["Elemental Combat"] = "Elemental"
	LocaleExceptions["Shadow Magic"] = "Shadow"
	LocaleExceptions["Feral"] = "Feral Combat"
elseif GetLocale() == "frFR" then
	LocaleExceptions["Combat élémentaire"] = "Élémentaire"
--	LocaleExceptions["Arcanes"] = "Arcane"
	LocaleExceptions["Magie de l'ombre"] = "Ombre"
	LocaleExceptions["Farouche"] = "Combat farouche"
	LocaleExceptions["Equilibre"] = "Équilibre"
elseif GetLocale() == "deDE" then 
	LocaleExceptions["Elementarkampf"] = "Elementar" 
	LocaleExceptions["Schattenmagie"] = "Schatten" 
elseif GetLocale() == "koKR" then 
	LocaleExceptions["회복"] = "복원"
elseif GetLocale() == "zhTW" then 
	LocaleExceptions["生存技能"] = "生存"
	LocaleExceptions["暗影魔法"] = "暗影"
	LocaleExceptions["元素戰鬥"] = "元素"
end

local function ScanTalents()

	local level = UnitLevel("player")
	if not level or level < 10 then return end		-- don't scan anything for low level characters

	local char = addon.ThisCharacter
	local _, englishClass = UnitClass("player")
	
	char.ActiveTalents = GetActiveSpecGroup()			-- returns 1 or 2
	char.Class = englishClass
	
	wipe(char.TalentTrees)
	
	local attrib, offset
	for specNum = 1, 2 do												-- primary and secondary specs
		attrib = 0
		offset = 0
		
		-- bits 0-1 = talent 1
		-- bits 2-3 = talent 2
		-- etc..
		
		for talentNum = 1, GetNumTalents() do			-- all talents
			local _, _, _, column, isSelected = GetTalentInfo(talentNum, nil, specNum)
			if isSelected then
				attrib = attrib + LeftShift(column, offset)
			end
			offset = offset + 2		-- each rank takes 2 bits (values 0 to 3)
		end
		
		char["Talents" .. specNum] = attrib
	end

	char.lastUpdate = time()
end

local function ScanTalentReference(ref)
	-- ref : address of the reference table in which we're saving scanned data

	local level = UnitLevel("player")
	if not level or level < 15 then return end		-- don't scan anything for low level characters
	
	ref.Talents = {}
	
			
	for talentNum = 1, GetNumTalents() do
		local nameTalent, iconPath, tier, column = GetTalentInfo(talentNum)

		if nameTalent then
			-- all paths start with this prefix, let's hope blue does not change this :)
			-- saves a lot of memory not to keep the full path for each talent (about 16k in total for all classes)
			iconPath = string.gsub(iconPath, UI_ICONS_PATH, "")
			iconPath = string.gsub(iconPath, string.upper(UI_ICONS_PATH), "")
			
			local link = GetTalentLink(talentNum)
			local id = tonumber(link:match("talent:(%d+)"))
			
			ref.Talents[talentNum] = id .. "|" .. nameTalent .. "|" .. iconPath .. "|" .. tier .. "|" ..  column
		end
	end
end

local function ScanGlyphSockets()
	-- GLYPHTYPE_MAJOR = 1;
	-- GLYPHTYPE_MINOR = 2;

	--		1
	--	3		5
	--	6		4
	--		2

	local level = UnitLevel("player")
	if not level or level < 15 then return end		-- don't scan anything for low level characters
	
	local glyphs = addon.ThisCharacter.Glyphs
	wipe(glyphs)
	
	local enabled, glyphType, spell, glyphID
	local link, index
	local attrib

	for specNum = 1, GetNumSpecGroups() do
		for i = 1, NUM_GLYPH_SLOTS do
			index = ((specNum - 1) * NUM_GLYPH_SLOTS) + i
	      
		   enabled, glyphType, tooltipIndex, spell = GetGlyphSocketInfo(i, specNum)
			
			-- bit 0 : enabled
			-- bits 1-2 : glyphType
			-- bits 3-19 : spellID (yes, 17 bits, not 16, just in case spell ids go beyond 65k)
			-- bits 20-22 : tooltip index. So far only 0, 1, 2, but let's use 3 bits to play it safe.
			-- bits 23- : glyphID
			-- deprecated: icon : returned by GetSpellInfo()
			
			attrib = enabled or 0
			attrib = attrib + LeftShift(glyphType or 0, 1)
			if spell then
				attrib = attrib + LeftShift(spell, 3)
			end

			attrib = attrib + LeftShift(tooltipIndex, 20)
			
			if enabled then
				link = GetGlyphLink(i, specNum)
				if link then
					glyphID = link:match("glyph:(%d+)")
					if glyphID then
						attrib = attrib + LeftShift(glyphID, 23)
					end
				end
			end
			
			if attrib > 0 then
				glyphs[index] = attrib
			end
		end
	end
	
	addon.ThisCharacter.lastUpdate = time()
end

local function ScanGlyphList()
	ToggleGlyphFilter(7)		-- this will attempt to open all categories
	if GetNumGlyphs() == 2 then	-- if 1 was closed, all we be closed after toggling the filter, and there will be exactly 3 lines (the headers)
		ToggleGlyphFilter(7)			-- so toggle again to make sure all categories are expanded
	end
	
	local NamesRef = addon.db.global.Reference.GlyphNames
	local glyphs = addon.ThisCharacter.GlyphList
	wipe(glyphs)
	
	local attrib
	for index = 1, GetNumGlyphs() do
		local name, group, isKnown, _, glyphID = GetGlyphInfo(index)
		
		-- bit 0 : isHeader
		-- bits 1-2 : group (value = 1 2 or 3)
		-- bit 3: isKnown
		-- bits 4- : glyphID
		
		if name == "header" then
			attrib = 1
			isKnown = 1
			glyphID = 0
		else
		
			-- if not addon.GlyphIDToSpellID[glyphID] then
				-- DEFAULT_CHAT_FRAME:AddMessage("glyph id " .. glyphID .. " missing : " .. name)
			-- end
		
			attrib = 0
			isKnown = (isKnown == true) and 1 or 0
			NamesRef[glyphID] = name
		end
		
		attrib = attrib + LeftShift(group, 1)
		attrib = attrib + LeftShift(isKnown, 3)
		attrib = attrib + LeftShift(glyphID, 4)
		
		glyphs[index] = attrib
	end
end

-- *** Event Handlers ***
local function OnPlayerAlive()
	ScanTalents()
	ScanGlyphList()
	ScanGlyphSockets()
	
	local _, class = UnitClass("player")		-- we need the englishClass
	local ref = addon.ref.global[class]
	
	ref.Version = GetVersion()
	ref.Locale = GetLocale()
	
	ScanTalentReference(ref)
end


-- ** Mixins **
local function _GetReferenceTable()
	return addon.ref.global
end

local function	_GetClassReference(class)
	assert(type(class) == "string")
	return addon.ref.global[class]
end

local function _GetTreeReference(class, tree)
	assert(type(class) == "string")
	assert(type(tree) == "string")
	return addon.ref.global[class].Trees[tree]
end

local function _IsClassKnown(class)
	class = class or ""	-- if by any chance nil is passed, trap it to make sure the function does not fail, but returns nil anyway
	
	local ref = _GetClassReference(class)
	if ref.Order then		-- if the Order field is not nil, we have data for this class
		return true
	end
end

local function _ImportClassReference(class, data)
	assert(type(class) == "string")
	assert(type(data) == "table")
	
	addon.ref.global[class] = data
end

local function _GetClassTrees(class)
	assert(type(class) == "string")
	
	local ref = _GetClassReference(class)
	local order = ref.Order
	if order then
		return order:gmatch("([^,]+)")
	end
	-- to do, add a return value that does not require validity testing by the caller
end

local function _GetTreeInfo(class, tree)
	local t = _GetTreeReference(class, tree)
	
	if t then
		return UI_ICONS_PATH..t.icon, BACKGROUND_PATH .. t.background
	end
end

local function _GetTreeNameByID(class, id)
	-- returns the name of tree "id" for a given class
	assert(type(class) == "string")
	
	local index = 1
	for name in _GetClassTrees(class) do
		if index == id then
			return name
		end
		index = index + 1
	end
end

local function _GetTalentLink(id, rank, name)
	return format("|cff4e96f7|Htalent:%s:%s|h[%s]|h|r", id, (rank-1), name)
end

local function _GetNumTalents(class, tree)
	-- returns the number of talents in a given tree
	local t = _GetTreeReference(class, tree)

	if t then
		return #t.talents
	end
end

local function _GetTalentInfo(class, tree, index)
	local t = _GetTreeReference(class, tree)
	local talentInfo = t.talents[index]
	
	if not talentInfo then return end
	
	local id, name, icon, tier, column = strsplit("|", talentInfo)
	
	return tonumber(id), name, UI_ICONS_PATH..icon, tonumber(tier), tonumber(column), tonumber(maximumRank)
end

local function _GetTalentRank(character, tree, specNum, index)
	local attrib = character.TalentTrees[format("%s|%s", tree, specNum)] 	-- ex: "Arcane|1"
	if not attrib then return 0 end	-- not in the DB ? 0 points spent

	index = (index - 1) * 2		-- ex: 3rd talent = bits 4-5
	return bAnd(RightShift(attrib, index), 3)
end

local function _GetActiveTalents(character)
	return character.ActiveTalents
end
	
local function _GetTalentPrereqs(class, tree, index)
	local t = _GetTreeReference(class, tree)
	local prereq = t.prereqs[index]
		
	if prereq then
		local prereqTier, prereqColumn = strsplit("|", prereq)
		return tonumber(prereqTier), tonumber(prereqColumn)
	end
end

local function _GetGlyphSocketInfo(character, specNum, index)
	index = ((specNum - 1) * NUM_GLYPH_SLOTS) + index		-- 4th glyph = 4 for spec 1, 13 for spec 2
	local glyph = character.Glyphs[index]
	if not glyph then return 0 end
		
	-- bit 0 : enabled
	-- bits 1-2 : glyphType
	-- bits 3-19 : spellID (yes, 17 bits, not 16, just in case spell ids go beyond 65k)
	-- bits 20-22 : tooltip index. So far only 0, 1, 2, but let's use 3 bits to play it safe.
	-- bits 23- : glyphID
	
	local enabled = bAnd(glyph, 1)
	local glyphType = bAnd(RightShift(glyph, 1), 3)
	local spell = bAnd(RightShift(glyph, 3), 131071)	-- 17 bits mask
	local tooltipIndex = bAnd(RightShift(glyph, 20), 7)
	local glyphID = RightShift(glyph, 23)
	local _, _, icon = GetSpellInfo(spell)

	return enabled, glyphType, spell, icon, glyphID, tooltipIndex
end
	
local function _GetGlyphLink(glyphID)
	local spellID = addon.GlyphIDToSpellID[glyphID]
	if spellID then
		local name = GetSpellInfo(spellID)
		if name then
			return format("|cff66bbff|Hglyph:%s|h[%s]|h|r", glyphID, name)
		end
	end
end

local function _GetNumGlyphs(character)
	-- returns the number of glyphs in the full list
	return #character.GlyphList
end

local function _GetGlyphInfo(character, index)
	-- return info about an entry in the glyph list
	local glyph = character.GlyphList[index]
	if not glyph then return end
	
	-- bit 0 : isHeader
	-- bits 1-2 : group (value = 1 2 or 3)
	-- bit 3: isKnown
	-- bits 4- : spellID
	
	local isHeader = bAnd(glyph, 1)
	isHeader = (isHeader == 1) and true or nil
	
	local group = bAnd(RightShift(glyph, 1), 3)
	local isKnown = bAnd(RightShift(glyph, 3), 1)
	isKnown = (isKnown == 1) and true or nil
	
	local glyphID = RightShift(glyph, 4)
	
	return isHeader, isKnown, group, glyphID
end

local function _GetGlyphInfoByID(glyphID)
	local NamesRef = addon.db.global.Reference.GlyphNames

	local spellID = addon.GlyphIDToSpellID[glyphID]
	local name, icon, link
	if spellID then
		name, _, icon = GetSpellInfo(spellID)
		
		if name then
			link = format("|cff66bbff|Hglyph:%s|h[%s]|h|r", glyphID, name)
		end
	end
	
	-- name, icon, link
	return NamesRef[glyphID], icon or "", link
end

local function _IsGlyphKnown(character, itemID)
	--[[	3 possible outcome
		1) return nil, nil : doesn't know the glyph, can't learn it
		2) return nil, true : doesn't know the glyph, but can learn it (same class)
		3) return true, true : knows the glyph
	--]]
	
	local glyphID = addon.ItemIDToGlyphID[itemID]
	if not glyphID then return end
	
	local id
	for index, glyph in ipairs(character.GlyphList) do
		id = RightShift(glyph, 4)

		if id == glyphID then
			local isKnown = bAnd(RightShift(glyph, 3), 1)
			return (isKnown == 1) and true or nil, true
		end
	end
end

local sentRequests		-- recently sent requests

local function _RequestGuildMemberTalents(member)
	-- requests the equipment of a given character (alt or main)
	local player = UnitName("player")
	local main = DataStore:GetNameOfMain(member)
	if not main then 		-- player is offline, check if his talents are in the DB
		local thisGuild = GetThisGuild()
		if thisGuild and thisGuild.Members[member] then		-- player found
		
			-- todo : trigger event and pass data along
			if thisGuild.Members[member].TalentTrees then		-- equipment found
				addon:SendMessage("DATASTORE_PLAYER_TALENTS_RECEIVED", player, member)
				return
			end
		end
	end
	
	-- todo
	-- if main == player then	-- if player requests the equipment of one of own alts, process the request locally, using the network works fine, but let's save the traffic.
		-- trigger the same event, _GetGuildMemberInventoryItem will take care of picking the data in the right place
		-- addon:SendMessage("DATASTORE_PLAYER_TALENTS_RECEIVED", player, member)
		-- return
	-- end
	
	-- prevent spamming remote players with too many requests
	sentRequests = sentRequests or {}
	
	if sentRequests[main] and ((time() - sentRequests[main]) < 5) then		-- if there's a known timestamp , and it was sent less than 5 seconds ago .. exit
		return
	end
	
	sentRequests[main] = time()		-- timestamp of the last request sent to this player
	GuildWhisper(main, MSG_TALENTS_REQUEST, member)
end

local function _GetGuildMemberTalentRank(guild, member, tree, specNum, index)
	local character = GetMemberKey(guild, member)
	if not character then return end

	local attrib = character.TalentTrees[format("%s|%s", tree, specNum)] 	-- ex: "Arcane|1"
	if not attrib then return 0 end	-- not in the DB ? 0 points spent

	index = (index - 1) * 2		-- ex: 3rd talent = bits 4-5
	return bAnd(RightShift(attrib, index), 3)
end

local function _GetGuildMemberNumPointsSpent(guild, member, tree, specNum)
	local character = GetMemberKey(guild, member)
	if not character then return end
	
	local attrib = character.TalentTrees[format("%s|%s", tree, specNum)] 	-- ex: "Arcane|1"
	if not attrib then return 0 end	-- not in the DB ? 0 points spent
	
	local points = 0
	while attrib ~= 0 do
		points = points + bAnd(attrib, 3)	-- add the lowest 2 bits ..
		attrib = RightShift(attrib, 2)		-- shift 2 bits to the right
	end
	return points
end

local function _GetGuildTalentsByClass(guild, class)
	-- note: I'm not inspired, this might not be the best function name :/
	local out = {}

	for name, member in pairs(guild.Members) do
		if member.Class == class then
			table.insert(out, name)
		end
	end
	
	return out
end

local PublicMethods = {
	GetReferenceTable = _GetReferenceTable,
	GetClassReference = _GetClassReference,
	GetTreeReference = _GetTreeReference,
	IsClassKnown = _IsClassKnown,
	ImportClassReference = _ImportClassReference,
	GetClassTrees = _GetClassTrees,
	GetTreeInfo = _GetTreeInfo,
	GetTreeNameByID = _GetTreeNameByID,
	GetTalentLink = _GetTalentLink,
	GetTalentInfo = _GetTalentInfo,
	GetTalentRank = _GetTalentRank,
	GetActiveTalents = _GetActiveTalents,
	GetNumPointsSpent = _GetNumPointsSpent,
	GetTalentPrereqs = _GetTalentPrereqs,
	GetGlyphSocketInfo = _GetGlyphSocketInfo,
	GetGlyphLink = _GetGlyphLink,
	GetNumGlyphs = _GetNumGlyphs,
	GetGlyphInfo = _GetGlyphInfo,
	GetGlyphInfoByID = _GetGlyphInfoByID,
	IsGlyphKnown = _IsGlyphKnown,
	RequestGuildMemberTalents = _RequestGuildMemberTalents,
	GetGuildMemberTalentRank = _GetGuildMemberTalentRank,
	GetGuildMemberNumPointsSpent = _GetGuildMemberNumPointsSpent,
	GetGuildTalentsByClass = _GetGuildTalentsByClass,
}


-- *** Guild Comm ***

local GuildCommCallbacks = {
	[MSG_TALENTS_REQUEST] = function(sender, alt)
			local character = DataStore:GetCharacterTable(addonName, alt)
			if character and character.Class then
				
				-- Note: DO NOT send the tree order, only send the actual data, this is important to keep the whole thing working across multiple languages.
				
				-- Data will be sent in the following format : 
				-- [1] = tree 1 spec 1 ; [2] = tree 1 spec 2
				-- [3] = tree 2 spec 1 ; [4] = tree 2 spec 2
				-- [5] = tree 3 spec 1 ; [6] = tree 3 spec 2
				
				local out = {}	
				local index = 1
				for tree in _GetClassTrees(character.Class) do		-- keep the order of talent trees, this one is consistant across languages.
					out[index] = character.TalentTrees[format("%s|%s", tree, 1)]
					index = index + 1
					out[index] = character.TalentTrees[format("%s|%s", tree, 2)]
					index = index + 1
				end
				
				GuildWhisper(sender, MSG_TALENTS_TRANSFER, alt, character.Class, out)
			end
		end,
	[MSG_TALENTS_TRANSFER] = function(sender, character, class, talents)
			local thisGuild = GetThisGuild()
			if thisGuild then
				local member = thisGuild.Members[character]
				local trees = member.TalentTrees
				
				local index = 1
				for tree in _GetClassTrees(class) do			-- keep the order of talent trees, this one is consistant across languages.
					trees[format("%s|%s", tree, 1)] = talents[index]
					index = index + 1
					trees[format("%s|%s", tree, 2)] = talents[index]
					index = index + 1
				end
				
				member.Class = class
				member.lastUpdate = time()
				addon:SendMessage("DATASTORE_PLAYER_TALENTS_RECEIVED", sender, character)
			end
		end,
}


function addon:OnInitialize()
	addon.db = LibStub("AceDB-3.0"):New(addonName .. "DB", AddonDB_Defaults)
	addon.ref = LibStub("AceDB-3.0"):New(addonName .. "RefDB", ReferenceDB_Defaults)

	DataStore:RegisterModule(addonName, addon, PublicMethods)
	DataStore:SetGuildCommCallbacks(commPrefix, GuildCommCallbacks)
	
	DataStore:SetCharacterBasedMethod("GetTalentRank")
	DataStore:SetCharacterBasedMethod("GetActiveTalents")
	DataStore:SetCharacterBasedMethod("GetGlyphSocketInfo")
	DataStore:SetCharacterBasedMethod("GetNumGlyphs")
	DataStore:SetCharacterBasedMethod("GetGlyphInfo")
	DataStore:SetCharacterBasedMethod("IsGlyphKnown")
	
	DataStore:SetGuildBasedMethod("GetGuildMemberTalentRank")
	DataStore:SetGuildBasedMethod("GetGuildMemberNumPointsSpent")
	DataStore:SetGuildBasedMethod("GetGuildTalentsByClass")
	
	addon:RegisterComm(commPrefix, DataStore:GetGuildCommHandler())
end

function addon:OnEnable()
	addon:RegisterEvent("PLAYER_ALIVE", OnPlayerAlive)
	addon:RegisterEvent("PLAYER_TALENT_UPDATE", ScanTalents)
	addon:RegisterEvent("GLYPH_ADDED", ScanGlyphSockets)
	addon:RegisterEvent("GLYPH_REMOVED", ScanGlyphSockets)
	addon:RegisterEvent("GLYPH_UPDATED", ScanGlyphSockets)
	addon:RegisterEvent("USE_GLYPH", ScanGlyphList)
end

function addon:OnDisable()
	addon:UnregisterEvent("PLAYER_ALIVE")
	addon:UnregisterEvent("PLAYER_TALENT_UPDATE")
	addon:UnregisterEvent("GLYPH_ADDED")
	addon:UnregisterEvent("GLYPH_REMOVED")
	addon:UnregisterEvent("GLYPH_UPDATED")
	-- addon:UnregisterEvent("USE_GLYPH")
end
