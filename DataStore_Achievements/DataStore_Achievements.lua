--[[	*** DataStore_Achievements ***
Written by : Thaoky, EU-Marécages de Zangar
June 21st, 2009
--]]
if not DataStore then return end

local addonName = "DataStore_Achievements"

_G[addonName] = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0")

local addon = _G[addonName]

local THIS_ACCOUNT = "Default"

local AddonDB_Defaults = {
	global = {
		Account = {
			Partial = {},
			Completed = {},
			CompletionDates = {},
		},
		Guilds = {
			['*'] = {			-- ["Account.Realm.Name"] 
				numAchievements = 0,
				numCompletedAchievements = 0,
				numAchievementPoints = 0,
				
				Partial = {},
				Completed = {},
				CompletionDates = {},
			},
		},
		Characters = {
			['*'] = {					-- ["Account.Realm.Name"] 
				lastUpdate = nil,
				numAchievements = 0,
				numCompletedAchievements = 0,
				numAchievementPoints = 0,
				guid = nil,
				
				Partial = {},
				Completed = {},
				CompletionDates = {},
				Tabards = {},
			}
		}
	}
}

-- *** Utility functions ***
local bAnd = bit.band
local bOr = bit.bor

local function TestBit(value, pos)
   local mask = 2^pos
   if bAnd(value, mask) == mask then
      return true
   end
end

-- *** Scanning functions ***
local CriteriaCache = {}

local function ScanTabards()
	local TABARDS_ACHIEVEMENT_ID = 621
	local NUM_TABARDS = 89
	
	for i = 1, NUM_TABARDS do
		local _, _, _, _, _, _, _, _, _, criteriaID = GetAchievementCriteriaInfo(TABARDS_ACHIEVEMENT_ID, i)
		if criteriaID then
			local _, _, isCompleted = GetAchievementCriteriaInfoByID(TABARDS_ACHIEVEMENT_ID, criteriaID)

			addon.ThisCharacter.Tabards[criteriaID] = (isCompleted == true) and true or nil
		end
	end
end

local function ScanSingleAchievement(id, isCompleted, month, day, year, flags, wasEarnedByMe)
	local storage		-- pointer to the destination location of this achievement's info (ie = character or account)
	
	local isAccountBound = ( bit.band(flags, ACHIEVEMENT_FLAGS_ACCOUNT) == ACHIEVEMENT_FLAGS_ACCOUNT ) 
	
	if isAccountBound then	
		-- if true, achievement is account wide, save in a shared location
		storage = addon.db.global.Account
	else
		storage = addon.ThisCharacter
	end
	
	storage.lastUpdate = time()
	
	--[[ Achievements can have 3 different statuses :
	
	Completed : the achievement has been completed, so implicitly, all criterias have been completed too, saved in the table "Completed"
	Partially complete : a string of values describes the state of completion, saved in the table "Partial"
	Not started : if an achievement is in neither table, it has not been started, not even a single criteria
	--]]

	-- 1) Fully completed achievements
	if isCompleted and wasEarnedByMe then
		local completed = storage.Completed
		local bitPos = (id % 32)	
		local index = ceil(id / 32)
		
		-- true when completed, all criterias are completed thus
		completed[index] = bOr((completed[index] or 0), 2^bitPos)	-- read: value = SetBit(value, bitPosition)
		
		storage.CompletionDates[id] = format("%d:%d:%d", month, day, year)
		return
	end

	local num = GetAchievementNumCriteria(id)
	
	-- 2) Partially completed achievements (with a single criteria)
	if num == 1 then
		-- if there's only 1 criteria, we know for sure it hasn't been completed (otherwise the achievement itself would be completed)
		-- so only the quantity matters (and only if it's > 0)
		local _, _, _, quantity = GetAchievementCriteriaInfo(id, 1);
		if quantity and quantity > 0 then
			storage.Partial[id] = quantity
		end
		return 
	end
	
	wipe(CriteriaCache)
	
	-- 3) Partially completed achievements (with multiple criteria)
	for j = 1, num do
		-- ** calling GetAchievementCriteriaInfo in this loop is what costs the most in terms of cpu time **
		local _, _, critCompleted, quantity, reqQuantity = GetAchievementCriteriaInfo(id, j);
		
		-- MoP fix, some achievements not completed by current alt, but completed by another alt, return that the criteria is completed, even when it's not
		-- This is visible for reputation achievements for example.
		if quantity < reqQuantity then
			critCompleted = false
		end
		
	   if critCompleted then 
	      table.insert(CriteriaCache, tostring(j))
	   else                  
	      if quantity and reqQuantity and quantity > 0 and reqQuantity > 1 then		-- a quantity of 0 = not started, don't save !
	         table.insert(CriteriaCache, j .. ":" .. quantity)
	      end
	   end
	end
	
	if #CriteriaCache > 0 then		-- if at least one criteria completed, save the entry, do nothing otherwise
		storage.Partial[id] = table.concat(CriteriaCache, ",")
	end
end

local function ScanAllAchievements()
	wipe(addon.db.global.Account.Partial)
	wipe(addon.db.global.Account.Completed)
	wipe(addon.db.global.Account.CompletionDates)
	wipe(addon.ThisCharacter.Partial)
	wipe(addon.ThisCharacter.Completed)
	wipe(addon.ThisCharacter.CompletionDates)
	
	local cats = GetCategoryList()
	local prevID
	
	for _, categoryID in ipairs(cats) do
		for i = 1, GetCategoryNumAchievements(categoryID) do
			local achievementID, _, _, achCompleted, month, day, year, _, flags,_, _, _, wasEarnedByMe, earnedBy = GetAchievementInfo(categoryID, i)
			ScanSingleAchievement(achievementID, achCompleted, month, day, year, flags, wasEarnedByMe)
			
			-- track previous steps of a progressive achievements
			prevID = GetPreviousAchievement(achievementID)
			
			while type(prevID) ~= "nil" do
				local achievementID, _, _, achCompleted, month, day, year, _, flags,_, _, _, wasEarnedByMe, earnedBy = GetAchievementInfo(prevID)
				ScanSingleAchievement(achievementID, achCompleted, month, day, year, flags, wasEarnedByMe)
				prevID = GetPreviousAchievement(achievementID)
			end
		end
	end	
end

local function ScanProgress()
	local char = addon.ThisCharacter
	local total, completed = GetNumCompletedAchievements()
	
	char.numAchievements = total
	char.numCompletedAchievements = completed
	char.numAchievementPoints = GetTotalAchievementPoints()
end


-- *** Event Handlers ***
local function OnPlayerAlive()
	-- for some reason, since 4.1, the event seems to be triggered repeatedly when a player releases after death, I could not clearly identify the cause
	-- but I could reproduce the issue and work around it by unregistering the event.
	addon:UnregisterEvent("PLAYER_ALIVE")
	
	ScanAllAchievements()
	ScanProgress()
	ScanTabards()
	
	addon.ThisCharacter.guid = strsub(UnitGUID("player"), 3)	-- get rid at the 0x at the beginning of the string
end

local function OnAchievementEarned(event, id)
	if id then
		local _, _, _, achCompleted, month, day, year, _, flags  = GetAchievementInfo(id)
		ScanSingleAchievement(id, true, month, day, year, flags)
		ScanProgress()
	end
end

local function OnPlayerEquipmentChanged(slot)
	-- if it's the tavard slot and we actually equipped one, then scan
	if slot == GetInventorySlotInfo("TabardSlot") and GetInventoryItemLink("player", tabardSlot) then
		ScanTabards()
	end
end

-- ** Mixins **
local function _GetAchievementInfo(character, achievementID, isAccountBound)
	local index = ceil(achievementID / 32)
	local source = (isAccountBound) and addon.db.global.Account or character
	
	if source.Completed[index] then				-- if there's a potential index for this id ..
		local bitPos = (achievementID % 32)	
		if TestBit(source.Completed[index], bitPos) then -- .. and if the right bit is set ..
			return true, true			-- .. then achievement is started and completed
		end
	end
	
	if source.Partial[achievementID] then
		return true, nil		-- started, not completed
	end
	
	-- implicit return of nil, nil otherwise
end
	
local function _GetCriteriaInfo(character, achievementID, criteriaIndex, isAccountBound)
	local source = (isAccountBound) and addon.db.global.Account or character

	local achievement = source.Partial[achievementID]
	
	if type(achievement) == "number" then	-- number = only 1 criteria
		return true, nil, achievement			-- started, not complete, quantity
	end
	
	if type(achievement) == "string" then	-- string = multiple criteria

		for v in achievement:gmatch("([^,]+)") do
			local index, qty = strsplit(":", v)
			
			index = tonumber(index)
			qty = tonumber(qty)
			
			if criteriaIndex == index then
				local isStarted = true				-- .. the criteria has been worked on
				local isComplete
				if not qty then						-- ..and might even have been completed (no qty means complete)
					isComplete = true
				end
				
				-- this will return :
					-- true, true, nil		if the criteria is 100% completed
					-- true, nil, value		if the criteria is partially complete
				return isStarted, isComplete, qty
			end
		end
	end
	-- implicit return of nil, nil , nil 	(not started, not complete)
end
	
local function _GetNumAchievements(character)
	return character.numAchievements
end
	
local function _GetNumCompletedAchievements(character)
	return character.numCompletedAchievements
end
	
local function _GetNumAchievementPoints(character)
	return character.numAchievementPoints
end

local function _GetAchievementLink(character, achievementID)
	-- information sources : 
		-- http://www.wowwiki.com/AchievementLink
		-- http://www.wowwiki.com/AchievementString
	if not character.guid then return end

	local link
	local completion		-- will contain: finished (0 or 1), month, day, year
	local criterias

	local index = ceil(achievementID / 32)
	if character.Completed[index] then				-- if there's a potential index for this id ..
		local bitPos = (achievementID % 32)	
		if TestBit(character.Completed[index], bitPos) then -- .. and if the right bit is set ..
			-- .. then achievement is started and completed
			local completionDate = character.CompletionDates[achievementID]
			if not completionDate then return end		-- if there's no data yet for this achievement, the link can't be created, return nil
			
			completion = format("1:%s", completionDate)							-- ex: 1:12:19:8		1 = finished, on 12/19/2008
			criterias = "4294967295:4294967295:4294967295:4294967295"		-- 4294967295 = the highest 32-bit value = 32 bits set to 1			
		end
	end

	if not completion then	-- if it wasn't a completed achievement, maybe it's a partially completed one
		completion = "0:0:0:-1"
		
		local bitset = { 0, 0, 0, 0 }		-- a simple array that will contain the 4 values to store into "criterias"
		local numCriteria = GetAchievementNumCriteria(achievementID)
		
		for criteriaIndex = 1, numCriteria do			-- browse all criterias
			local index = ceil(criteriaIndex / 32)		-- store in bitset[1], [2] ..
			
			local _, isComplete = _GetCriteriaInfo(character, achievementID, criteriaIndex)
			if isComplete then
				local pos = mod(criteriaIndex, 32)		-- pos must be within [1 .. 32]
				pos = (pos == 0) and 32 or pos			-- if the modulo leads to 0, change it to 32
				bitset[index] = bitset[index] + (2^(pos-1))		-- I'll change this to use bit functions later on, for the time being, this works fine.
			end
		end
		
		criterias = table.concat(bitset, ":")
	end
	
	local _, name = GetAchievementInfo(achievementID)
	
	return format("|cffffff00|Hachievement:%s:%s:%s:%s|h\[%s\]|h|r", achievementID, character.guid, completion, criterias, name)
end

local function _IsTabardKnown(character, criteriaID)
	if character.Tabards[criteriaID] then
		return true
	end
end

local PublicMethods = {
	GetAchievementInfo = _GetAchievementInfo,
	GetCriteriaInfo = _GetCriteriaInfo,
	GetNumAchievements = _GetNumAchievements,
	GetNumCompletedAchievements = _GetNumCompletedAchievements,
	GetNumAchievementPoints = _GetNumAchievementPoints,
	GetAchievementLink = _GetAchievementLink,
	IsTabardKnown = _IsTabardKnown,
}

function addon:OnInitialize()
	addon.db = LibStub("AceDB-3.0"):New(addonName .. "DB", AddonDB_Defaults)
	
	DataStore:RegisterModule(addonName, addon, PublicMethods)
	DataStore:SetCharacterBasedMethod("GetAchievementInfo")
	DataStore:SetCharacterBasedMethod("GetCriteriaInfo")
	DataStore:SetCharacterBasedMethod("GetNumAchievements")
	DataStore:SetCharacterBasedMethod("GetNumCompletedAchievements")
	DataStore:SetCharacterBasedMethod("GetNumAchievementPoints")
	DataStore:SetCharacterBasedMethod("GetAchievementLink")
	DataStore:SetCharacterBasedMethod("IsTabardKnown")
end

function addon:OnEnable()
	addon:RegisterEvent("PLAYER_ALIVE", OnPlayerAlive)
	addon:RegisterEvent("ACHIEVEMENT_EARNED", OnAchievementEarned)
	addon:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", OnPlayerEquipmentChanged)
end

function addon:OnDisable()
	addon:UnregisterEvent("PLAYER_ALIVE")
	addon:UnregisterEvent("ACHIEVEMENT_EARNED")
	addon:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
end
