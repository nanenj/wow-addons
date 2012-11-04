--[[	*** DataStore_Crafts ***
Written by : Thaoky, EU-Marécages de Zangar
June 23rd, 2009
--]]
if not DataStore then return end

local addonName = "DataStore_Crafts"

_G[addonName] = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0", "AceTimer-3.0")

local addon = _G[addonName]

local THIS_ACCOUNT = "Default"
-- local commPrefix = "DS_Craft"
local BI = LibStub("LibBabble-Inventory-3.0"):GetLookupTable()
local L = LibStub("AceLocale-3.0"):GetLocale("DataStore_Crafts")
local PT = LibStub("LibPeriodicTable-3.1")

local MSG_SEND_LOGIN								= 1	-- Sends a login message, to request crafts to other players
local MSG_LOGIN_REPLY							= 2	-- ..reply
local MSG_SEND_PROFESSION						= 3	-- Sends a profession link, or profession id if no full link

local AddonDB_Defaults = {
	global = {
		Options = {
			BroadcastProfs = 1,					-- Broadcast professions at login or not
		},
		Guilds = {
			['*'] = {			-- ["Account.Realm.Name"] 
				Members = {
					['*'] = {				-- ["MemberName"] 
						lastUpdate = nil,
						Version = nil,
						Professions = {},		-- 3 profession links : [1] & [2] for the 2 primary professions, [3] for cooking ([4] for archaeology ? wait & see)
					}
				}
			},
		},
		Characters = {
			['*'] = {				-- ["Account.Realm.Name"] 
				lastUpdate = nil,
				Professions = {
					['*'] = {
						FullLink = nil,		-- Tradeskill link
						NumCrafts = 0,			-- total number of crafts for this tradeskill
						Rank = 0,
						MaxRank = 0,
						Icon = nil,
						Crafts = { ['*'] = nil },
						Cooldowns = { ['*'] = nil },		-- list of active cooldowns
					}
				},
				ArcheologyItems = {},
			}
		}
	}
}

local SPELL_ID_ALCHEMY = 2259
local SPELL_ID_BLACKSMITHING = 3100
local SPELL_ID_ENCHANTING = 7411
local SPELL_ID_ENGINEERING = 4036
local SPELL_ID_INSCRIPTION = 45357
local SPELL_ID_JEWELCRAFTING = 25229
local SPELL_ID_LEATHERWORKING = 2108
local SPELL_ID_TAILORING = 3908
local SPELL_ID_SKINNING = 8613
local SPELL_ID_MINING = 2575
local SPELL_ID_HERBALISM = 2366
local SPELL_ID_SMELTING = 2656
local SPELL_ID_COOKING = 2550
local SPELL_ID_FIRSTAID = 3273
local SPELL_ID_FISHING = 131474
local SPELL_ID_ARCHAEOLOGY = 78670

local ProfessionSpellID = {
	-- GetSpellInfo with this value will return localized spell name
	["Alchemy"] = SPELL_ID_ALCHEMY,
	["Blacksmithing"] = SPELL_ID_BLACKSMITHING,
	["Enchanting"] = SPELL_ID_ENCHANTING,
	["Engineering"] = SPELL_ID_ENGINEERING,
	["Inscription"] = SPELL_ID_INSCRIPTION,
	["Jewelcrafting"] = SPELL_ID_JEWELCRAFTING,
	["Leatherworking"] = SPELL_ID_LEATHERWORKING,
	["Tailoring"] = SPELL_ID_TAILORING,
	["Skinning"] = SPELL_ID_SKINNING,
	["Mining"] = SPELL_ID_MINING,
	["Herbalism"] = SPELL_ID_HERBALISM,
	["Smelting"] = SPELL_ID_SMELTING,

	["Cooking"] = SPELL_ID_COOKING,
	["First Aid"] = SPELL_ID_FIRSTAID,
	["Fishing"] = SPELL_ID_FISHING,
}

-- *** Utility functions ***
local bAnd = bit.band
local LShift = bit.lshift
local RShift = bit.rshift

local function GetOption(option)
	return addon.db.global.Options[option]
end

local function GetProfessionID(profession)
	-- profession = localized profession name "Cooking" or "Cuisine", "Alchemy"...
	-- note: we're not using a reverse lookup table because of the localization issue.
	
	if ProfessionSpellID[profession] then
		return ProfessionSpellID[profession]
	end

	for _, id in pairs( ProfessionSpellID ) do
		if profession == GetSpellInfo(id) then		-- profession found ?
			ProfessionSpellID[profession] = id		-- cache the result to speed up future searches
			return id
		end
	end
end

local function GetThisGuild()
	local guild = GetGuildInfo("player")
	if guild then 
		local key = format("%s.%s.%s", THIS_ACCOUNT, GetRealmName(), guild)
		return addon.db.global.Guilds[key]
	end
end

local function GetVersion()
	local _, version = GetBuildInfo()
	return tonumber(version)
end

-- local function SaveVersion(sender, version)
	-- local thisGuild = GetThisGuild()
	-- if thisGuild and sender and version then
		-- thisGuild.Members[sender].Version = version
	-- end
-- end

-- local function GuildBroadcast(messageType, ...)
	-- local serializedData = addon:Serialize(messageType, ...)
	-- addon:SendCommMessage(commPrefix, serializedData, "GUILD")
-- end

-- local function GuildWhisper(player, messageType, ...)
	-- if DataStore:IsGuildMemberOnline(player) then
		-- local serializedData = addon:Serialize(messageType, ...)
		-- addon:SendCommMessage(commPrefix, serializedData, "WHISPER", player)
	-- end
-- end

-- local professionQueue		-- queue containing the professions to send to guildmates
-- local professionTimer		-- timer used to control the pace at which professions are placed on comm channels.

-- local function SendProfession()
	-- if #professionQueue == 0 then					-- nothing left in the queue ? cancel the timer & exit
		-- addon:CancelTimer(professionTimer)
		-- professionTimer = nil
		-- return
	-- end
	
	-- -- send the last profession found in the queue, then remove it 
	-- local profession = professionQueue[#professionQueue]		-- last element
	-- local alt = profession[1]
	-- local data = profession[2]
	-- local index = profession[3]
	-- local recipient = profession[4]
	-- -- DEFAULT_CHAT_FRAME:AddMessage(format("sending %s, %s to %s (size : %d)", alt, index, recipient or "guild", #professionQueue ))
	
	-- if profession[4] then		-- recipient found ? 
		-- GuildWhisper(recipient, MSG_SEND_PROFESSION, alt, data, index)
	-- else
		-- GuildBroadcast(MSG_SEND_PROFESSION, alt, data, index)
	-- end
	
	-- table.remove(professionQueue)
-- end

-- local function QueueCharacterProfessions(character, recipient)
	-- local index = 1
	-- local _, _, alt = strsplit(".", character)

	-- for profName, profession in pairs(addon.db.global.Characters[character].Professions) do
		-- local spellID = GetProfessionID(profName) or 0
		-- local data = profession.FullLink or spellID

		-- if profession.isPrimary then
			-- table.insert(professionQueue, { alt, data, index, recipient })
			-- index = index + 1
		-- elseif profession.isSecondary then
			-- if profName == GetSpellInfo(SPELL_ID_COOKING) then
				-- table.insert(professionQueue, { alt, data, 3, recipient })			--				index = 3
			-- end
		-- end
	-- end
-- end

-- local function SendAllProfessions(alts, recipient)
	-- if GetOption("BroadcastProfs") == 0 then
		-- return
	-- end

	-- professionQueue = professionQueue or {}
	
	-- -- sends the professions of the current character + his alts
	-- local character = DataStore:GetCharacter()	-- this character
	-- QueueCharacterProfessions(character, recipient)
	
	-- if strlen(alts) > 0 then
		-- for _, name in pairs( { strsplit("|", alts) }) do	-- then all his alts
			-- character = DataStore:GetCharacter(name)
			-- if character then
				-- QueueCharacterProfessions(character, recipient)
			-- end
		-- end
	-- end
	
	-- -- reuse current timer if already available (may be the case if 2 players connect simultaneously)
	-- professionTimer = professionTimer or addon:ScheduleRepeatingTimer(SendProfession, 0.5)		-- send 1 profession every half-second, max 15 seconds for 30 professions on a realm
-- end

-- local function SaveProfession(sender, alt, data, index)
	-- local thisGuild = GetThisGuild()
	-- if thisGuild and sender then
		-- local version = thisGuild.Members[sender].Version
		-- local member = thisGuild.Members[alt]
		
		-- member.Version = version
		-- member.Professions[index] = data
		-- member.lastUpdate = time()
	-- end
	-- addon:SendMessage("DATASTORE_GUILD_PROFESSION_RECEIVED", sender, alt, data, index)
-- end

local function ClearExpiredProfessions()
	-- this function will clear all the guild profession links that were saved with a build number anterior to the current one (they're invalid after a patch anyway)
	
	local thisGuild = GetThisGuild()
	if not thisGuild then return end
		
	local version = GetVersion()
	
	for name, member in pairs(thisGuild.Members) do
		if member.Version ~= version then
			thisGuild.Members[name] = nil		-- clear this member's entry if version is outdated
		end
	end
end

local function LocalizeProfessionSpellIDs()
	-- this function adds localized entries in the ProfessionSpellID table
	
	local localizedSpells = {}		-- avoid infinite loop by storing in a temp table first
	local localizedName
	for englishName, spellID in pairs(ProfessionSpellID) do
		localizedName = GetSpellInfo(spellID)
		localizedSpells[localizedName] = spellID
	end
	
	for name, id in pairs(localizedSpells) do
		ProfessionSpellID[name] = id
	end
end

-- *** Scanning functions ***

local selectedTradeSkillIndex
local subClasses, subClassID
local invSlots, invSlotID
local haveMats, hasSkillUp

local function SaveActiveFilters()
	selectedTradeSkillIndex = GetTradeSkillSelectionIndex()
	
	subClasses = { GetTradeSkillSubClasses() }
	invSlots = { GetTradeSkillInvSlots() }

	subClassID = TradeSkillFrame.filterTbl.subClassValue
	invSlotID = TradeSkillFrame.filterTbl.slotValue
	haveMats = TradeSkillFrame.filterTbl.hasMaterials
	hasSkillUp = TradeSkillFrame.filterTbl.hasSkillUp
	
	TradeSkillSetFilter(-1, -1)
	TradeSkillOnlyShowMakeable(false)
	TradeSkillOnlyShowSkillUps(false)
end

local function RestoreActiveFilters()
	if (subClassID > 0) then
		TradeSkillSetFilter(subClassID, 0, subClasses[subClassID], "")
	elseif (invSlotID > 0) then
		TradeSkillSetFilter(0, invSlotID, "", invSlots[invSlotID])
	end

	TradeSkillOnlyShowMakeable(haveMats)
	TradeSkillOnlyShowSkillUps(hasSkillUp)
	TradeSkillUpdateFilterBar()
	
	SelectTradeSkill(selectedTradeSkillIndex)
	
	wipe(subClasses)
	wipe(invSlots)
	
	subClasses = nil
	invSlots = nil
	subClassID = nil
	invSlotID = nil
	haveMats = nil
	hasSkillUp = nil
	selectedTradeSkillIndex = nil
end

local headersState = {}

local function SaveHeaders()
	local headerCount = 0		-- use a counter to avoid being bound to header names, which might not be unique.
	
	for i = GetNumTradeSkills(), 1, -1 do		-- 1st pass, expand all categories
		local _, skillType, _, isExpanded  = GetTradeSkillInfo(i)
		 if (skillType == "header") then
			headerCount = headerCount + 1
			if not isExpanded then
				ExpandTradeSkillSubClass(i)
				headersState[headerCount] = true
			end
		end
	end
end

local function RestoreHeaders()
	local headerCount = 0
	for i = GetNumTradeSkills(), 1, -1 do
		local _, skillType  = GetTradeSkillInfo(i)
		if (skillType == "header") then
			headerCount = headerCount + 1
			if headersState[headerCount] then
				CollapseTradeSkillSubClass(i)
			end
		end
	end
	wipe(headersState)
end

local function ScanCooldowns()
	local tradeskillName = GetTradeSkillLine()
	local char = addon.ThisCharacter
	local profession = char.Professions[tradeskillName]
	
	wipe(profession.Cooldowns)
	for i = 1, GetNumTradeSkills() do
		local skillName, skillType = GetTradeSkillInfo(i)
		
		if skillType ~= "header" then
			local cooldown = GetTradeSkillCooldown(i)
			if cooldown then
				table.insert(profession.Cooldowns, skillName .. "|" .. cooldown .. "|" .. time())
			end
		end
	end
end

local function ScanProfessionInfo(index, mainIndex)
	local char = addon.ThisCharacter

	if char and mainIndex and not index then
		char["Prof"..mainIndex] = nil			-- profession may have been cleared, nil it
	end

	if not char or not index then return end
	
	local profName, texture, rank, maxRank = GetProfessionInfo(index);
	local profession = char.Professions[profName]
	profession.Rank = rank
	profession.MaxRank = maxRank
	
	local profLink = select(2, GetSpellLink(profName))
	if profLink then	-- sometimes a nil value may be returned, so keep the old one if nil
		profession.FullLink = profLink
	end
	
	if mainIndex then
		char["Prof"..mainIndex] = profName
	end
end

local function ScanProfessionLinks()
	local prof1, prof2, arch, fish, cook, firstAid = GetProfessions()

	ScanProfessionInfo(cook)
	ScanProfessionInfo(firstAid)
	ScanProfessionInfo(fish)
	ScanProfessionInfo(arch)
	ScanProfessionInfo(prof1, 1)
	ScanProfessionInfo(prof2, 2)
	
	addon.ThisCharacter.lastUpdate = time()
end

local SkillTypeToColor = {
	["trivial"] = 0,		-- grey
	["easy"] = 1,			-- green
	["medium"] = 2,		-- yellow
	["optimal"] = 3,		-- orange
}

local function ScanRecipes()
	--[[ To do: 
		This function is called after TRADE_SKILL_SHOW. 
		Very often, it exits because the first line is not a header (which is what we want, since it indicates data is not entirely available)
		
		I have identified two situations:
		1) Right after login, the very first time a profession is opened, the series of events will be 
			TRADE_SKILL_UPDATE multiple times
			TRADE_SKILL_SHOW once
			TRADE_SKILL_UPDATE multiple times
			
			Ideally, scan should only happen after the last TRADE_SKILL_UPDATE
		
		2) A few seconds after 1), or assuming data is properly cached:
			TRADE_SKILL_UPDATE multiple times
			TRADE_SKILL_SHOW once
			
			scan should happen right after TRADE_SKILL_SHOW
			
		Todo: implement a timer to trigger the scan at the right time
	--]]


	local tradeskillName = GetTradeSkillLine()
	if not tradeskillName or tradeskillName == "UNKNOWN" then return end		-- may happen after a patch, or under extreme lag, so do not save anything to the db !

	local numTradeSkills = GetNumTradeSkills()
	if not numTradeSkills or numTradeSkills == 0 then return end
	
	local skillName, skillType = GetTradeSkillInfo(1)	-- test the first line
	if skillType ~= "header" then return end				-- skip scan if first line is not a header.
	
	local char = addon.ThisCharacter
	local profession = char.Professions[tradeskillName]
	local crafts = profession.Crafts
	wipe(crafts)

	profession.FullLink = select(2, GetSpellLink(tradeskillName))

	local NumCrafts = 0
	local color, link

	for i = 1, numTradeSkills do
		skillName, skillType = GetTradeSkillInfo(i)
		
		if skillType == "header" or skillType == "subheader" then
			crafts[i] = skillName or ""
		else
			link = GetTradeSkillRecipeLink(i)
			craftInfo = tonumber(link:match("enchant:(%d+)"))		-- this actually extracts the spellID
			crafts[i] = SkillTypeToColor[skillType] + LShift(craftInfo, 2)
			NumCrafts = NumCrafts + 1
		end
	end
	
	profession.NumCrafts = NumCrafts
	
	addon:SendMessage("DATASTORE_RECIPES_SCANNED", sender, tradeskillName)
end

local function ScanTradeSkills()
	SaveActiveFilters()
	SaveHeaders()
	ScanRecipes()
	ScanCooldowns()
	RestoreHeaders()
	RestoreActiveFilters()
	
	addon.ThisCharacter.lastUpdate = time()
end

local function ScanArcheologyItems()
	local items = addon.ThisCharacter.ArcheologyItems
	wipe(items)
	
	local names = {}
	local spellName
	local numArtifactsByRace
	
	for raceIndex = 1, GetNumArchaeologyRaces() do
		wipe(names)
		
		numArtifactsByRace = GetNumArtifactsByRace(raceIndex)
		
		if numArtifactsByRace > 0 and addon.artifactDB[raceIndex] then
			-- Create a table where ["Artifact Name"] = associated spell id 
			-- this is necessary because the archaeology API does not return any other way to match artifacts with either spell ID or item ID
			for index, artifact in pairs(addon.artifactDB[raceIndex]) do
				spellName = GetSpellInfo(artifact.spellID)
				names[spellName] = artifact.spellID
			end
			
			for artifactIndex = 1, GetNumArtifactsByRace(raceIndex) do
				local artifactName, _, _, _, _,  _, _, _, completionCount = GetArtifactInfoByRace(raceIndex, artifactIndex)

				if names[artifactName] and completionCount > 0 then
					items[names[artifactName]] = true
				end
			end
		end
	end
end

-- *** Event Handlers ***
local function OnPlayerAlive()
	ScanProfessionLinks()
end

local function OnTradeSkillClose()
	addon:UnregisterEvent("TRADE_SKILL_CLOSE")
	addon:UnregisterEvent("TRADE_SKILL_UPDATE")
	addon.isOpen = nil
end

local function OnTradeSkillShow()
	if IsTradeSkillLinked() or IsTradeSkillGuild() then return end
	
	addon.isOpen = true
	addon:RegisterEvent("TRADE_SKILL_CLOSE", OnTradeSkillClose)
	ScanTradeSkills()
end

local function OnTradeSkillUpdate()
	-- The hook in DoTradeSkill will register this event so that we only update skills once.
	-- unregister it before calling the update, or the event will be called recursively (due to expand/collapse)
	addon:UnregisterEvent("TRADE_SKILL_UPDATE")
	ScanCooldowns()	-- only cooldowns need to be refreshed
end

local function OnArtifactHistoryReady()
	ScanArcheologyItems()
end

local function OnArtifactComplete()
	ScanArcheologyItems()
end

-- this turns
--	"Your skill in %s has increased to %d."
-- into
--	"Your skill in (.+) has increased to (%d+)."
local arg1pattern, arg2pattern
if GetLocale() == "deDE" then		
	-- ERR_SKILL_UP_SI = "Eure Fertigkeit '%1$s' hat sich auf %2$d erhöht.";
	arg1pattern = "'%%1%$s'"
	arg2pattern = "%%2%$d"
else
	arg1pattern = "%%s"
	arg2pattern = "%%d"
end

local skillUpMsg = gsub(ERR_SKILL_UP_SI, arg1pattern, "(.+)")
skillUpMsg = gsub(skillUpMsg, arg2pattern, "(%%d+)")

local function OnChatMsgSkill(self, msg)
	if msg and addon.isOpen then	-- point gained while ts window is open ? rescan
		local skill = msg:match(skillUpMsg)
		if skill and skill == GetTradeSkillLine() then	-- if we gained a skill point in the currently opened profession pane, rescan
			ScanTradeSkills()
		end
	end
	ScanProfessionLinks() -- added to update skills upon firing of skillup event 
end


local unlearnMsg = gsub(ERR_SPELL_UNLEARNED_S, arg1pattern, "(.+)")

local function OnChatMsgSystem(self, msg)
	if msg then
		local skillLink = msg:match(unlearnMsg)
		if skillLink then
			local skillName = skillLink:match("%[(.+)%]")
			if skillName then		-- clear the list of recipes
				local char = addon.ThisCharacter
				wipe(char.Professions[skillName])
				char.Professions[skillName] = nil
			end
			
			-- this won't help, as GetProfessions does not return the right values right after the profession has been abandonned.
			-- The problem of listing Prof1 & Prof2 with potentially the same value fixes itself after the next logon though.
			-- Until I find more time to work around this issue, we will live with it .. it's not like players are abandonning professions 100x / day :)
			-- ScanProfessionLinks()	
		end
	end
end


-- ** Mixins **
local function _GetProfession(character, name)
	if name then
		return character.Professions[name]
	end
end
	
local function _GetProfessions(character)
	return character.Professions
end

local function _GetProfessionInfo(profession)
	-- accepts either a pointer (type == table)to the profession table, as returned by addon:GetProfession()
	-- or a link (type == string)
	
	local rank, maxRank, spellID
	local link
	
	if type(profession) == "table" then
		rank = profession.Rank
		maxRank = profession.MaxRank 
		link = profession.FullLink
	elseif type(profession) == "string" then
		link = profession
	end
	
	if link then
		spellID, rank, maxRank = link:match("trade:(%d+):(%d+):(%d+):")
	end
	
	return tonumber(rank) or 0, tonumber(maxRank) or 0, tonumber(spellID)
end

local function _GetNumCraftLines(profession)
	return #profession.Crafts
end
	
local function _GetCraftLineInfo(profession, index)
	local craft = profession.Crafts[index]
	if type(craft) == "string" then	-- headers are stored as strings
		return true, nil, craft
	end
	
	local color = bAnd(craft, 3)	-- first 2 bits = color
	local id = RShift(craft, 2)	-- other bits = spell id
	
	return false, color, id
end

local function _GetCraftCooldownInfo(profession, index)
	local cooldown = profession.Cooldowns[index]
	local name, reset, lastCheck = strsplit("|", cooldown)
	
	reset = tonumber(reset)
	lastCheck = tonumber(lastCheck)
	local expiresIn = reset - (time() - lastCheck)
	
	return name, expiresIn, reset, lastCheck
end

local function _GetNumActiveCooldowns(profession)
	assert(type(profession) == "table")		-- this is the pointer to a profession table, obtained through addon:GetProfession()
	return #profession.Cooldowns
end

local function _ClearExpiredCooldowns(profession)
	assert(type(profession) == "table")		-- this is the pointer to a profession table, obtained through addon:GetProfession()
	
	for i = #profession.Cooldowns, 1, -1 do		-- from last to first, to avoid messing up indexes when removing entries
		local _, expiresIn = _GetCraftCooldownInfo(profession, i)
		if expiresIn <= 0 then		-- already expired ? remove it
			table.remove(profession.Cooldowns, i)
		end
	end
end

local function _GetCraftInfo(spellID)
	-- get the id of the item that can be crafted by this spellID
	local itemID = PT:ItemInSet("-"..spellID, "Tradeskill.RecipeLinks")
	local reagents
	
	if itemID then
		itemID = tonumber(itemID)

		-- ex: itemID 10046 is made with reagents : "2996x2;2318x1;2320x1"
		reagents = PT:ItemInSet(itemID, "TradeskillResultMats.Forward")

		if itemID == -spellID then		-- enchants that do not yield  an item will return this, ex: enchant 7420 will return itemID -7420
			itemID = nil
		end
	end
	
	return itemID, reagents
end

local function _GetCraftLevels(spellID)
	-- get the id of the item that can be crafted by this spellID
	local itemID = PT:ItemInSet("-"..spellID, "Tradeskill.RecipeLinks")
	
	if itemID then
		itemID = tonumber(itemID)

		-- ex: itemID 10046 : levels = "20/50/67/85", the item turns yellow at 50, green at 67, grey at 85
		local levels = PT:ItemInSet(itemID, "TradeskillLevels")

		if levels then
			local orange, yellow, green, grey = strsplit("/", levels)
			return tonumber(orange), tonumber(yellow), tonumber(green), tonumber(grey)
		end
	end
end

local function _GetItemTradeSkillLevel(itemID, profession)
	-- variant: use item level for more accurate results
	
	-- profession should look like : "TradeskillLevels.Cooking",
	-- refer to LibPeriodicTable-3.1-TradeskillLevels.lua
	local PT = LibStub("LibPeriodicTable-3.1")
	
	local levels = PT:ItemInSet(itemID, profession)
	if not levels then return end
	
	return strsplit("/", levels)
end

local function _GetNumRecipesByColor(profession)
	-- counts the number of orange, yellow, green and grey recipes.
	local counts = { [0] = 0, [1] = 0, [2] = 0, [3] = 0 }
	
	for i = 1, _GetNumCraftLines(profession) do
		local isHeader, color = _GetCraftLineInfo(profession, i)
		
		if not isHeader then
			counts[color] = counts[color] + 1
		end
	end
	return counts[3], counts[2], counts[1], counts[0]		-- orange, yellow, green, grey
end

local function _IsCraftKnown(profession, spellID)
	-- returns true if a given spell ID is known in the profession passed as first argument
	for i = 1, _GetNumCraftLines(profession) do
		local isHeader, _, info = _GetCraftLineInfo(profession, i)
		
		if not isHeader then
			if info == spellID then
				return true
			end
		end
	end
end

local function _GetGuildCrafters(guild)
	return guild.Members
end

local function _GetGuildMemberProfession(guild, member, index)
	local m = guild.Members[member]
	local profession = m.Professions[index]
	
	if type(profession) == "string" then
		local spellID = profession:match("trade:(%d+):")
		return tonumber(spellID), profession, m.lastUpdate	-- return the profession spell ID + full link
	elseif type(profession) == "number" then
		return profession, nil, m.lastUpdate					-- return the profession spell ID
	end
end

local function _GetProfessionSpellID(name)
	-- name can be either the english name or the localized name
	return ProfessionSpellID[name]
end

local function _GetProfession1(character)
	local profession = _GetProfession(character, character.Prof1)
	if profession then
		local rank, maxRank, spellID = _GetProfessionInfo(profession)
		return rank, maxRank, spellID, character.Prof1
	end
end

local function _GetProfession2(character)
	local profession = _GetProfession(character, character.Prof2)
	if profession then
		local rank, maxRank, spellID = _GetProfessionInfo(profession)
		return rank, maxRank, spellID, character.Prof2
	end
end

local function _GetFirstAidRank(character)
	local profession = _GetProfession(character, GetSpellInfo(SPELL_ID_FIRSTAID))
	if profession then
		return _GetProfessionInfo(profession)
	end
end

local function _GetCookingRank(character)
	local profession = _GetProfession(character, GetSpellInfo(SPELL_ID_COOKING))
	if profession then
		return _GetProfessionInfo(profession)
	end
end

local function _GetFishingRank(character)
	local profession = _GetProfession(character, GetSpellInfo(SPELL_ID_FISHING))
	if profession then
		return _GetProfessionInfo(profession)
	end
end

local function _GetArchaeologyRank(character)
	local profession = _GetProfession(character, GetSpellInfo(SPELL_ID_ARCHAEOLOGY))
	if profession then
		return _GetProfessionInfo(profession)
	end
end

local function _GetArchaeologyRaceArtifacts(race)
	return addon.artifactDB[race]
end

local function _GetRaceNumArtifacts(race)
	return #addon.artifactDB[race]
end

local function _GetArtifactInfo(race, index)
	return addon.artifactDB[race][index]
end

local function _IsArtifactKnown(character, spellID)
	return character.ArcheologyItems[spellID]
end

local PublicMethods = {
	GetProfession = _GetProfession,
	GetProfessions = _GetProfessions,
	GetProfessionInfo = _GetProfessionInfo,
	GetNumCraftLines = _GetNumCraftLines,
	GetCraftLineInfo = _GetCraftLineInfo,
	GetCraftCooldownInfo = _GetCraftCooldownInfo,
	GetNumActiveCooldowns = _GetNumActiveCooldowns,
	ClearExpiredCooldowns = _ClearExpiredCooldowns,
	GetCraftInfo = _GetCraftInfo,
	GetCraftLevels = _GetCraftLevels,
	GetNumRecipesByColor = _GetNumRecipesByColor,
	IsCraftKnown = _IsCraftKnown,
	GetGuildCrafters = _GetGuildCrafters,
	GetGuildMemberProfession = _GetGuildMemberProfession,
	GetProfessionSpellID = _GetProfessionSpellID,
	GetProfession1 = _GetProfession1,
	GetProfession2 = _GetProfession2,
	GetFirstAidRank = _GetFirstAidRank,
	GetCookingRank = _GetCookingRank,
	GetFishingRank = _GetFishingRank,
	GetArchaeologyRank = _GetArchaeologyRank,
	GetItemTradeSkillLevel = _GetItemTradeSkillLevel,
	GetArchaeologyRaceArtifacts = _GetArchaeologyRaceArtifacts,
	GetRaceNumArtifacts = _GetRaceNumArtifacts,
	GetArtifactInfo = _GetArtifactInfo,
	IsArtifactKnown = _IsArtifactKnown,
}

-- *** Guild Comm ***
-- local function OnGuildAltsReceived(self, sender, alts)
	-- if sender == UnitName("player") then				-- if I receive my own list of alts in the same guild, same realm, same account..
		-- GuildBroadcast(MSG_SEND_LOGIN, GetVersion())
		-- addon:ScheduleTimer(SendAllProfessions, 5, alts)	-- broadcast my crafts to the guild 5 seconds later, to decrease the load at startup
	-- end
-- end

-- local GuildCommCallbacks = {
	-- [MSG_SEND_LOGIN] = function(sender, version)
			-- local player = UnitName("player")
			-- if sender ~= player then						-- don't send back to self
				-- GuildWhisper(sender, MSG_LOGIN_REPLY, GetVersion())
				-- local alts = DataStore:GetGuildMemberAlts(player)			-- get my own alts
				-- if alts then
					-- SendAllProfessions(alts, sender)	-- when another player sends me his login, reply with my own crafts
				-- end
			-- end
			-- SaveVersion(sender, version)
		-- end,
	-- [MSG_LOGIN_REPLY] = function(sender, version)
			-- SaveVersion(sender, version)
		-- end,
	-- [MSG_SEND_PROFESSION] = function(sender, alt, data, index)
			-- SaveProfession(sender, alt, data, index)
		-- end,
-- }

function addon:OnInitialize()
	addon.db = LibStub("AceDB-3.0"):New(addonName .. "DB", AddonDB_Defaults)

	DataStore:RegisterModule(addonName, addon, PublicMethods)
	-- DataStore:SetGuildCommCallbacks(commPrefix, GuildCommCallbacks)
	DataStore:SetCharacterBasedMethod("GetProfession")
	DataStore:SetCharacterBasedMethod("GetProfessions")
	
	DataStore:SetCharacterBasedMethod("GetProfession1")
	DataStore:SetCharacterBasedMethod("GetProfession2")
	DataStore:SetCharacterBasedMethod("GetFirstAidRank")
	DataStore:SetCharacterBasedMethod("GetCookingRank")
	DataStore:SetCharacterBasedMethod("GetFishingRank")
	DataStore:SetCharacterBasedMethod("GetArchaeologyRank")
	DataStore:SetCharacterBasedMethod("IsArtifactKnown")
	
	DataStore:SetGuildBasedMethod("GetGuildCrafters")
	DataStore:SetGuildBasedMethod("GetGuildMemberProfession")
	
	-- addon:RegisterMessage("DATASTORE_GUILD_ALTS_RECEIVED", OnGuildAltsReceived)
	-- addon:RegisterComm(commPrefix, DataStore:GetGuildCommHandler())
end

function addon:OnEnable()
	addon:RegisterEvent("PLAYER_ALIVE", OnPlayerAlive)
	addon:RegisterEvent("TRADE_SKILL_SHOW", OnTradeSkillShow)
	addon:RegisterEvent("CHAT_MSG_SKILL", OnChatMsgSkill)
	addon:RegisterEvent("CHAT_MSG_SYSTEM", OnChatMsgSystem)
	
	local _, _, arch = GetProfessions()

	if arch then
		addon:RegisterEvent("ARTIFACT_HISTORY_READY", OnArtifactHistoryReady)
		addon:RegisterEvent("ARTIFACT_COMPLETE", OnArtifactComplete)
		RequestArtifactCompletionHistory()		-- this will trigger ARTIFACT_HISTORY_READY
	end
	
--	addon:SetupOptions()
	ClearExpiredProfessions()	-- automatically cleanup guild profession links that are from an older version
	LocalizeProfessionSpellIDs()
end

function addon:OnDisable()
	addon:UnregisterEvent("PLAYER_ALIVE")
	addon:UnregisterEvent("TRADE_SKILL_SHOW")
	addon:UnregisterEvent("CHAT_MSG_SKILL")
end

function addon:GetSource(searchedID)
	local PT = LibStub("LibPeriodicTable-3.1")
	
	-- Returns "Profession, level"		ex: "Alchemy", "180"
	local level, data = PT:ItemInSet(searchedID, "Tradeskill.Crafted")
	if level and data then
		local _, _, profession = strsplit(".", data)		-- ex: "Tradeskill.Crafted.Inscription"
		local localizedProfession
		if ProfessionSpellID[profession] then
			localizedProfession = GetSpellInfo(ProfessionSpellID[profession])
		end
			
		return localizedProfession or profession, level
	end
end



function addon:IsTradeSkillWindowOpen()
	-- note : maybe there's a function in the WoW API to test this, but I did not find it :(
	return addon.isOpen
end

-- *** Hooks ***
-- todo : change the hooks, do them the Ace way
local Orig_DoTradeSkill = DoTradeSkill

function DoTradeSkill(index, repeatCount, ...)
	-- this hook is necessary to get cooldown information after a craft
	Orig_DoTradeSkill(index, repeatCount, ...)
	addon:RegisterEvent("TRADE_SKILL_UPDATE", OnTradeSkillUpdate)
end
