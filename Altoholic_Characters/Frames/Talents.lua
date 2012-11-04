local addonName = "Altoholic"
local addon = _G[addonName]

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local WHITE		= "|cFFFFFFFF"
local GREEN		= "|cFF00FF00"

local PLAYER_TREE = "Tree1"
local GUILD_TREE = "Tree2"

addon.Talents = {}

local ns = addon.Talents		-- ns = talents namespace

local parent = "AltoholicFrameTalents"
local currentTalentGroup
local currentClass		-- ex: "MAGE"
local currentTreeName	-- ex: "Fire"
local currentTreeID
local currentTreeFrame	-- Trre1 or Tree2
local currentGuildKey
local currentGuildMember	-- guild member currently displayed in the right pane
local currentGuildMemberTalentGroup = 1
local rightTreeKey		-- character key to use when drawing the rightmost tree

-- ** Arrows **
local INITIAL_OFFSET_X = 10				-- constants used for positioning talents
local INITIAL_OFFSET_Y = 8
local TALENT_OFFSET_X = 50
local TALENT_OFFSET_Y = 42
local TALENT_BUTTON_SIZE = 28
local NUM_TALENT_BUTTONS = 28

local numArrows

local function ResetArrowCount()
	numArrows = 1
end

local function HideUnusedArrows()
	while numArrows <= 30 do
		_G[ format("%s_%s_ArrowFrame_Arrow%d", parent, currentTreeFrame, numArrows) ]:Hide()
		numArrows = numArrows + 1
	end
	numArrows = nil
end

local function DrawArrow(tier, column, prereqTier, prereqColumn, blocked)
	local arrowType					-- algorithm taken from TalentFrameBase.lua, adjusted for my needs
	
	if (column == prereqColumn) then			-- Same column ? ==> TOP
		arrowType = "top"
	elseif (tier == prereqTier) then			-- Same tier ? ==> LEFT or RIGHT
		if (column < prereqColumn) then
			arrowType = "right"
		else
			arrowType = "left"
		end
	else												-- None of these ? ==> diagonal
		if not blocked then
			arrowType = "top"
		else
			if (column < prereqColumn) then
				arrowType = "right"
			else
				arrowType = "left"
			end
		end
	end
	
	if not arrowType then
		return
	end
	
	local x, y
	if arrowType == "top" then
		x = 2
		y = 18
	elseif arrowType == "left" then
		x = -17
		y = -2
	elseif arrowType == "right" then
--		x = 22
		x = 17
		y = -2
	end
	
	x = x + INITIAL_OFFSET_X + ((column-1) * TALENT_OFFSET_X)
	y = y - (INITIAL_OFFSET_Y + ((tier-1) * TALENT_OFFSET_Y))
	
	local arrow = _G[ format("%s_%s_ArrowFrame_Arrow%d", parent, currentTreeFrame, numArrows) ]
	local tc = TALENT_ARROW_TEXTURECOORDS[arrowType][1]
	
	arrow:SetTexCoord(tc[1], tc[2], tc[3], tc[4]);
	arrow:SetPoint("TOPLEFT",	_G[ format("%s_%s", parent, currentTreeFrame) ], "TOPLEFT", x, y)
	arrow:Show()
	
	numArrows = numArrows + 1
end

-- ** Buttons **
local numButtons

local function ResetButtonCount()
	numButtons = 1
end

local function HideUnusedButtons()
	local button
	while numButtons <= NUM_TALENT_BUTTONS do
		button = _G[ format("%s_%s_Talent%d", parent, currentTreeFrame, numButtons) ]
		button:Hide()
		button:SetID(0)	
		
		numButtons = numButtons + 1
	end
	numButtons = nil
end

local function DrawTalent(texture, tier, column, count, id)
	local itemName = format("%s_%s_Talent%d", parent, currentTreeFrame, numButtons)
	local itemButton = _G[itemName]

	itemButton:SetPoint("TOPLEFT", itemButton:GetParent(), "TOPLEFT", 
		INITIAL_OFFSET_X + ((column-1) * TALENT_OFFSET_X), 
		-(INITIAL_OFFSET_Y + ((tier-1) * TALENT_OFFSET_Y)))
	itemButton:SetID(id)

	if texture then
		addon:SetItemButtonTexture(itemName, texture, TALENT_BUTTON_SIZE, TALENT_BUTTON_SIZE)
	end
	
	local itemCount = _G[itemName .. "Count"]
	local itemTexture = _G[itemName .. "IconTexture"]
	
	if count and count > 0 then
		itemCount:SetText(GREEN .. count)
		itemCount:Show()
		itemTexture:SetDesaturated(0)
	else
		itemTexture:SetDesaturated(1)
		itemCount:Hide()
	end
	itemButton:Show()

	numButtons = numButtons + 1
end

-- ** Branches **
local numBranches
local branchArray		-- a 2-dimensional array to hold branches

local function ResetBranchCount()
	numBranches = 1
end

local function InitializeBranchArray()
	branchArray = branchArray or {}
	wipe(branchArray)
	
	for i = 1, MAX_NUM_TALENT_TIERS do
		branchArray[i] = {};
		for j = 1, NUM_TALENT_COLUMNS do
			branchArray[i][j] = {};
		end
	end
end

local function ClearBranchArray()
	wipe(branchArray)
	branchArray = nil
end

local function InitBranch(tier, column, prereqTier, prereqColumn, blocked)

	-- algorithm taken from TalentFrameBase.lua, adjusted for my needs
	local left = min(column, prereqColumn);
	local right = max(column, prereqColumn);
	
	if (column == prereqColumn) then			-- Same column ? ==> TOP
		for i = prereqTier, tier - 1 do
			branchArray[i][column].down = true;
			if ( (i + 1) <= (tier - 1) ) then
				branchArray[i+1][column].up = true;
			end
		end
		return
	end
		
	if (tier == prereqTier) then			-- Same tier ? ==> LEFT or RIGHT
		for i = left, right-1 do
			branchArray[prereqTier][i].right = true;
			branchArray[prereqTier][i+1].left = true;
		end
		return
	end

	-- None of these ? ==> diagonal
	if not blocked then
		branchArray[prereqTier][column].down = true;
		branchArray[tier][column].up = true;
		
		for i = prereqTier, tier - 1 do
			branchArray[i][column].down = true;
			branchArray[i + 1][column].up = true;
		end

		for i = left, right - 1 do
			branchArray[prereqTier][i].right = true;
			branchArray[prereqTier][i+1].left = true;
		end
	else
		for i=prereqTier, tier-1 do
			branchArray[i][column].up = true;
			branchArray[i + 1][column].down = true;
		end
	end
end

local function SetBranchTexture(branchType, x, y)
	local branch = _G[ format("%s_%s_Branch%d", parent, currentTreeFrame, numBranches) ]
	local tc = TALENT_BRANCH_TEXTURECOORDS[branchType][1]
	
	branch:SetTexCoord(tc[1], tc[2], tc[3], tc[4]);
	branch:SetPoint("TOPLEFT",	_G[ format("%s_%s", parent, currentTreeFrame) ], "TOPLEFT", x, y)
	branch:Show()
	
	numBranches = numBranches + 1
end

local function DrawBranches()
	local x, y
	local ignoreUp
	
	for i = 1, MAX_NUM_TALENT_TIERS do
		for j = 1, NUM_TALENT_COLUMNS do
			local p = branchArray[i][j]
			
			x = INITIAL_OFFSET_X + ((j-1) * TALENT_OFFSET_X) + 2
			y = -(INITIAL_OFFSET_Y + ((i-1) * TALENT_OFFSET_Y)) - 2
			
			if p.node then			-- there's a talent there
				if p.up then
					if not ignoreUp then
						SetBranchTexture("up", x, y + TALENT_BUTTON_SIZE)
					else
						ignoreUp = nil
					end
				end
				if p.down then
					SetBranchTexture("down", x, y - TALENT_BUTTON_SIZE + 1)
				end
				if p.left then
					SetBranchTexture("left", x - TALENT_BUTTON_SIZE, y)
				end
				if p.right then
					SetBranchTexture("right", x + TALENT_BUTTON_SIZE, y)
				end			
			else
				if p.up and p.left and p.right then
					SetBranchTexture("tup", x, y)
				elseif p.down and p.left and p.right then
					SetBranchTexture("tdown", x, y)
				elseif p.left and p.down then
					SetBranchTexture("topright", x, y)
					--SetBranchTexture("down", x, y-32)
					SetBranchTexture("down", x, y-TALENT_BUTTON_SIZE)
				elseif p.left and p.up then
					SetBranchTexture("bottomright", x, y)
				elseif p.left and p.right then
					SetBranchTexture("right", x + TALENT_BUTTON_SIZE, y)
					SetBranchTexture("left", x+1, y)
				elseif p.right and p.down then
					SetBranchTexture("topleft", x, y)
					SetBranchTexture("down", x, y-32)
				elseif p.right and p.up then
					SetBranchTexture("bottomleft", x, y)
				elseif p.up and p.down then
					SetBranchTexture("up", x, y)
					--SetBranchTexture("down", x, y-32)
					SetBranchTexture("down", x, y-TALENT_BUTTON_SIZE)
					ignoreUp = true
				end
			end

			p.up = nil			-- clear after use
			p.left = nil
			p.right = nil
			p.down = nil
			p.node = nil
		end
	end
end

local function HideUnusedBranches()
	while numBranches <= 30 do
		_G[ format("%s_%s_Branch%d", parent, currentTreeFrame, numBranches) ]:Hide()
		numBranches = numBranches + 1
	end
	numBranches = nil
end


-- *** Talents ***
local function DrawClassIcons(iconGroup, class, character, guildMember)
	local text = _G[ format("%s_Icons%dText", parent, iconGroup) ]
	local icon1 = _G[ format("%s_Icons%d_SpecIcon1", parent, iconGroup) ]

	local isPlayer = (iconGroup < 3)					-- 1 or 2 = player, 3 or 4 = guild
	local isPrimary = (iconGroup % 2 == 1)			-- 1 or 3 = primary, 2 or 4 = secondary
	
	if isPlayer then
		text:SetJustifyH("LEFT")
		icon1:SetPoint("TOPLEFT", 10, -15)
	else
		text:SetJustifyH("RIGHT")
		icon1:SetPoint("TOPLEFT", 90, -15)
	end
	
	if isPrimary then
		text:SetText(TALENT_SPEC_PRIMARY)
	else
		text:SetText(TALENT_SPEC_SECONDARY)
	end
	
	local index = 1
	for tree in DataStore:GetClassTrees(class) do						-- draw spec icons
		local itemName = format("%s_Icons%d_SpecIcon%d", parent, iconGroup, index)
		local itemButton = _G[itemName]
		local itemCount = _G[itemName .."Count"]
		local itemTexture = _G[itemName .. "IconTexture"]
		local icon = DataStore:GetTreeInfo(class, tree)
		
		addon:SetItemButtonTexture(itemName, icon, 30, 30)
		
		local count = 0
		if character then
			count = DataStore:GetNumPointsSpent(character, tree, isPrimary and 1 or 2)
		elseif guildMember then
			count = DataStore:GetGuildMemberNumPointsSpent(currentGuildKey, guildMember, tree, isPrimary and 1 or 2)
		end
		itemCount:SetText(WHITE .. count)
		itemCount:Show()
		itemButton:Show()
		
		if not isPlayer then
			itemTexture:SetDesaturated((character or guildMember) and 0 or 1)
		end
		
		index = index + 1
	end
end

local function DrawBackground(frameName, class, treeName, disabled)
	-- draws the background of a given class/tree,
	-- disabled : color or grayscale
	
	local topleft = _G[format("%s_%s%s" , parent, frameName, "TopLeft")]
	local topright = _G[format("%s_%s%s" , parent, frameName, "TopRight")]
	local bottomleft = _G[format("%s_%s%s" , parent, frameName, "BottomLeft")]
	local bottomright = _G[format("%s_%s%s" , parent, frameName, "BottomRight")]

	local _, bg = DataStore:GetTreeInfo(class, treeName)
	topleft:SetTexture(bg.."-TopLeft")
	topright:SetTexture(bg.."-TopRight")
	bottomleft:SetTexture(bg.."-BottomLeft")
	bottomright:SetTexture(bg.."-BottomRight")
	
	SetDesaturation(topleft, disabled)
	SetDesaturation(topright, disabled)
	SetDesaturation(bottomleft, disabled)
	SetDesaturation(bottomright, disabled)
end

local function DrawTree(frameName, class, treeName, character, guildMember)
	-- character = character key of the alt 
	-- guildMember = in case no character key is passed, it's a guild member, only his name is necessary

	currentTreeFrame = frameName
	
	ResetButtonCount()
	ResetArrowCount()
	ResetBranchCount()
	InitializeBranchArray()
	
	-- draw all icons in their respective slot
	for i = 1, DataStore:GetNumTalents(class, treeName) do
		local _, _, texture, tier, column = DataStore:GetTalentInfo(class, treeName, i)
		local rank
		
		if character then
			rank = DataStore:GetTalentRank(character, treeName, currentTalentGroup, i)
		elseif guildMember then
			rank = DataStore:GetGuildMemberTalentRank(currentGuildKey, guildMember, treeName, currentGuildMemberTalentGroup, i)
		end
		
		DrawTalent(texture, tier, column, rank, i)
		branchArray[tier][column].node = true;
				
		-- Draw arrows & branches where applicable
		local prereqTier, prereqColumn = DataStore:GetTalentPrereqs(class, treeName, i)
		if prereqTier and prereqColumn then
			local left = min(column, prereqColumn);
			local right = max(column, prereqColumn);

			if ( left == prereqColumn ) then		-- Don't check the location of the current button
				left = left + 1;
			else
				right = right - 1;
			end
			
			local blocked								-- Check for blocking talents
			for j = 1, DataStore:GetNumTalents(class, treeName) do
				local _, _, _, searchedTier, searchedColumn = DataStore:GetTalentInfo(class, treeName, j)
			
				if searchedTier == prereqTier then				-- do nothing if lower tier, process if same tier, exit if higher tier
					if (searchedColumn >= left) and (searchedColumn <= right) then
						blocked = true
						break
					end
				elseif searchedTier > prereqTier then
					break
				end
			end
			
			DrawArrow(tier, column, prereqTier, prereqColumn, blocked)
			InitBranch(tier, column, prereqTier, prereqColumn, blocked)
		end
	end
	DrawBranches()
	
	HideUnusedButtons()
	HideUnusedArrows()
	HideUnusedBranches()
	ClearBranchArray()
end

local function StopAutoCast(group)
	-- stop auto cast shine on all icons in this group
	for i = 1, 3 do
		AutoCastShine_AutoCastStop( _G[ format("%s_Icons%d_SpecIcon%dShine", parent, group, i) ] )
	end
end
	
local function StartAutoCast(group, id)
	-- if an id is specified, start auto cast shine on this icon
	AutoCastShine_AutoCastStart( _G[ format("%s_Icons%d_SpecIcon%dShine", parent, group, id) ] )
end

function ns:Update()
	_G[ parent ]:Hide()
	
	local character = addon.Tabs.Characters:GetAltKey()
	if not character then return end
	
	local _, currentClass = DataStore:GetCharacterClass(character)
	if not DataStore:IsClassKnown(currentClass) then return end
	
	local level = DataStore:GetCharacterLevel(character)
	if not level or level < 10 then return end
	
	local isActiveTalentGroup = currentTalentGroup == DataStore:GetActiveTalents(character)

	local status = DataStore:GetColoredCharacterName(character)
	if currentTalentGroup == 1 then
		if isActiveTalentGroup then
			status = format("%s|r / %s", status, TALENT_SPEC_PRIMARY_ACTIVE)
		else
			status = format("%s|r / %s", status, TALENT_SPEC_PRIMARY)
		end
	else
		if isActiveTalentGroup then
			status = format("%s|r / %s", status, TALENT_SPEC_SECONDARY_ACTIVE)
		else
			status = format("%s|r / %s", status, TALENT_SPEC_SECONDARY)
		end
	end

	currentTreeName = DataStore:GetTreeNameByID(currentClass, currentTreeID or 1)
	status = format("%s / %s", status, currentTreeName)
	AltoholicTabCharactersStatus:SetText(status)
	
	-- background
	DrawBackground(PLAYER_TREE, currentClass, currentTreeName)
	DrawBackground(GUILD_TREE, currentClass, currentTreeName, (not currentGuildMember and not rightTreeKey))

	-- icons
	for i = 1, 4 do
		StopAutoCast(i)
	end
	
	DrawClassIcons(1, currentClass, character)
	DrawClassIcons(2, currentClass, character)
	DrawClassIcons(3, currentClass, rightTreeKey, currentGuildMember)
	DrawClassIcons(4, currentClass, rightTreeKey, currentGuildMember)
	
	StartAutoCast(currentTalentGroup, currentTreeID)
	StartAutoCast(currentGuildMemberTalentGroup+2, currentTreeID)

	-- trees
	DrawTree(PLAYER_TREE, currentClass, currentTreeName, character)
	DrawTree(GUILD_TREE, currentClass, currentTreeName, rightTreeKey, currentGuildMember)

	_G[ parent ]:Show()
end

local DDM_Add = addon.Helpers.DDM_Add

local function OnRightTreePlayerChange(self, key, member)
	rightTreeKey = key
	currentGuildMember = member
	
	local frame = _G[ parent .. "_SelectMember" ]
	UIDropDownMenu_ClearAll(frame)
	
	local name
	if currentGuildMember then
		currentGuildKey = DataStore:GetGuild()
		DataStore:RequestGuildMemberTalents(currentGuildMember)
		name = DataStore:GetClassColor(currentClass) .. currentGuildMember
	else
		name = DataStore:GetColoredCharacterName(rightTreeKey)
	end
	UIDropDownMenu_SetSelectedValue(frame, name)
	UIDropDownMenu_SetText(frame, name)
	
	ns:Update()
end

local function OnOtherGuildMemberChange(self, guild, member)
	rightTreeKey = nil
	currentGuildKey = guild
	currentGuildMember = member
	
	local name = DataStore:GetClassColor(currentClass) .. currentGuildMember

	local frame = _G[ parent .. "_SelectMember" ]
	UIDropDownMenu_ClearAll(frame)
	UIDropDownMenu_SetSelectedValue(frame, name)
	UIDropDownMenu_SetText(frame, name)
	
	ns:Update()
end

function ns:DropDownMembers_Initialize(level)
	if not level then return end

	local info = UIDropDownMenu_CreateInfo()
	
	if level == 1 then
		local guildName = GetGuildInfo("player")
		
		if IsInGuild() then
			info.text = GREEN..guildName
			info.hasArrow = 1
			info.checked = nil
			info.value = 1
			info.func = nil
			UIDropDownMenu_AddButton(info, level)
		end
		
		info.text = L["Other guilds"]
		info.hasArrow = 1
		info.checked = nil
		info.value = 2
		info.func = nil
		UIDropDownMenu_AddButton(info, level)
		
		info.text = L["Other characters"]
		info.hasArrow = 1
		info.checked = nil
		info.value = 3
		info.func = nil
		UIDropDownMenu_AddButton(info, level)

	elseif level == 2 then
		if UIDROPDOWNMENU_MENU_VALUE == 1 then
			if IsInGuild() then
				GuildRoster()

				local characterName = addon.Tabs.Characters:GetAlt()
				local englishClass, playerLevel
				local list = {}
				
				for member in pairs(DataStore:GetOnlineGuildMembers()) do
					local version = addon:GetGuildMemberVersion(member)
					if version and version >= "v4.0.004" then		-- version found = altoholic user
						-- add this players' main ?
						playerLevel = select(4, DataStore:GetGuildMemberInfo(member)) or 0
						englishClass = select(11, DataStore:GetGuildMemberInfo(member))
						if playerLevel >= 10 and englishClass == currentClass and characterName ~= member then	-- only keep the right class, and skip alt already displayed in the left pane
							list[member] = true
						end

						-- add any of his alts ?
						if member ~= UnitName("player") then
							local alts = DataStore:GetGuildMemberAlts(member)
							if alts then
								local altsTable = { strsplit("|", alts) }
								
								for _, altName in ipairs(altsTable) do
									playerLevel = select(4, DataStore:GetGuildMemberInfo(altName)) or 0
									englishClass = select(11, DataStore:GetGuildMemberInfo(altName))
									if playerLevel >= 10 and englishClass == currentClass then
										list[altName] = true
									end
								end
							end
						end
					end
				end
				
				for _, member in pairs(DataStore:GetGuildTalentsByClass(DataStore:GetGuild(), currentClass)) do
					list[member] = true
				end
				
				local sortedList = {}
				for member in pairs(list) do
					table.insert(sortedList, member)
				end
				table.sort(sortedList)

				if #sortedList == 0 then
					info.text = NONE
					info.value = nil
					info.checked = nil
					info.func = nil
					UIDropDownMenu_AddButton(info, level)
				else
					for _, member in ipairs(sortedList) do
						info.text = DataStore:GetClassColor(currentClass) .. member
						info.checked = nil
						info.func = OnRightTreePlayerChange
						info.arg1 = nil		-- guild member, so no datastore key
						info.arg2 = member	-- the actual guild member
						UIDropDownMenu_AddButton(info, level)
					end
				end
			end
		
		elseif UIDROPDOWNMENU_MENU_VALUE == 2 then
			local thisRealm = GetRealmName()
			local thisGuild = GetGuildInfo("player")
			
			local altListed	-- at least one alt listed ?
			
			for realm in pairs(DataStore:GetRealms()) do						-- get this account's realms
				for guildName, guild in pairs(DataStore:GetGuilds(realm)) do		-- all guilds on this realm
					if not (realm == thisRealm and guildName == thisGuild) then
						for _, member in pairs(DataStore:GetGuildTalentsByClass(guild, currentClass)) do
							info.text = format("%s / %s / %s", WHITE..realm, GREEN..guildName..WHITE, DataStore:GetClassColor(currentClass) .. member)
							info.checked = nil
							info.func = OnOtherGuildMemberChange
							info.arg1 = guild		-- guild key
							info.arg2 = member	-- the actual guild member
							UIDropDownMenu_AddButton(info, level)
							
							altListed = true
						end
					end
				end
			end
			
			if not altListed then
				info.text = NONE
				info.value = nil
				info.checked = nil
				info.func = nil
				UIDropDownMenu_AddButton(info, level)
			end
			
		elseif UIDROPDOWNMENU_MENU_VALUE == 3 then
			-- list characters of the same class of all accounts, all realms
			
			for account in pairs(DataStore:GetAccounts()) do
				for realm in pairs(DataStore:GetRealms(account)) do
					for name, key in pairs(DataStore:GetCharacters(realm, account)) do
						local _, class = DataStore:GetCharacterClass(key)
						if class == currentClass and DataStore:GetCharacterLevel(key) >= 10 then
							if account == "Default" then
								info.text = format("%s / %s", WHITE..realm, DataStore:GetColoredCharacterName(key) ) 
							else
								info.text = format("%s / %s %s(%s)", WHITE..realm, DataStore:GetColoredCharacterName(key), GREEN, account ) 
							end
							info.value = name
							info.checked = nil
							info.func = OnRightTreePlayerChange
							info.arg1 = key		-- datastore key
							info.arg2 = nil		-- not a guild member, so nil
							UIDropDownMenu_AddButton(info, level)
						end
					end
				end
			end
			
		end
	end

end

function ns:Icon_OnEnter(frame)
	local treeName = DataStore:GetTreeNameByID(currentClass, frame:GetID())
	if treeName then
		AltoTooltip:ClearLines();
		AltoTooltip:SetOwner(frame, "ANCHOR_RIGHT");
		AltoTooltip:AddLine(treeName,1,1,1);
		AltoTooltip:Show();
	end
end

function ns:Icon_OnClick(frame, button)
	currentTreeID = frame:GetID()					-- set the current tree
	
	local group = frame:GetParent():GetID()	-- which group of icons did we click ? 1 to 4
	local isPlayer = (group < 3)					-- 1 or 2 = player, 3 or 4 = guild
	local isPrimary = (group % 2 == 1)			-- 1 or 3 = primary, 2 or 4 = secondary

	if isPlayer then
		if isPrimary then
			currentTalentGroup = 1
		else
			currentTalentGroup = 2
		end
	else
		if isPrimary then
			currentGuildMemberTalentGroup = 1
		else
			currentGuildMemberTalentGroup = 2
		end
	end
	
	ns:Update()
end

local function GetTalentLink(frame)
	local spellNumber = frame:GetID()
	local id, name = DataStore:GetTalentInfo(currentClass, currentTreeName, spellNumber)
	
	local paneID = frame:GetParent():GetID()
	local rank = 0
	
	if paneID == 1 then		-- 1 = left pane = player pane
		local character = addon.Tabs.Characters:GetAltKey()
		rank = DataStore:GetTalentRank(character, currentTreeName, currentTalentGroup, spellNumber)
	elseif paneID == 2 then		-- 2 = right pane
	
		if rightTreeKey then					-- a datastore character
			rank = DataStore:GetTalentRank(rightTreeKey, currentTreeName, currentTalentGroup, spellNumber)
		elseif currentGuildMember then	-- a guild member
			rank = DataStore:GetGuildMemberTalentRank(currentGuildKey, currentGuildMember, currentTreeName, currentGuildMemberTalentGroup, spellNumber)
		end
	end
	
	return DataStore:GetTalentLink(id, rank, name)
end

function ns:Button_OnEnter(frame)
	local link = GetTalentLink(frame)
	if not link then return	end

	AltoTooltip:ClearLines();
	AltoTooltip:SetOwner(frame, "ANCHOR_RIGHT");
	AltoTooltip:SetHyperlink(link);
	AltoTooltip:Show();
end

function ns:Button_OnClick(frame, button)
	if ( button == "LeftButton" ) and ( IsShiftKeyDown() ) then
		local chat = ChatEdit_GetLastActiveWindow()
		if chat:IsShown() then
			local link = GetTalentLink(frame)
			if link then
				chat:Insert(link)
			end
		end
	end
end

function ns:SetCurrentGroup(group)
	currentTalentGroup = group
end

function ns:SetCurrentTreeID(id)
	currentTreeID = id
end

function ns:Reset()
	rightTreeKey = nil
	currentGuildKey = nil
	currentGuildMember = nil
	currentGuildMemberTalentGroup = 1
	
	--UIDropDownMenu_SetText(_G[ parent .. "_SelectMember" ], L["Guild Members"])
	UIDropDownMenu_SetText(_G[ parent .. "_SelectMember" ], L["Compare with"])
end

local function OnPlayerTalentUpdate()
	if _G[ parent ]:IsVisible() then
		ns:Update()
	end
end	

function addon:DATASTORE_PLAYER_TALENTS_RECEIVED(event, sender, character)
	ns:Update()
end

addon:RegisterEvent("PLAYER_TALENT_UPDATE", OnPlayerTalentUpdate)
addon:RegisterMessage("DATASTORE_PLAYER_TALENTS_RECEIVED")
