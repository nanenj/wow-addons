local addonName = "Altoholic"
local addon = _G[addonName]

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local WHITE		= "|cFFFFFFFF"
local GREEN		= "|cFF00FF00"
local GOLD		= "|cFFFFD700"
local THIS_ACCOUNT = "Default"

local ICON_NOT_STARTED = "Interface\\RaidFrame\\ReadyCheck-NotReady" 
local ICON_PARTIAL = "Interface\\RaidFrame\\ReadyCheck-Waiting"
local ICON_COMPLETED = "Interface\\RaidFrame\\ReadyCheck-Ready" 

local parent = "AltoholicTabGrids"
local classMenu = parent .. "ClassIconMenu"	-- name of mouse over menu frames (add a number at the end to get it)

local currentCategory	-- current category ( equipment, rep, currencies, etc.. )

local currentRealm = GetRealmName()
local currentAccount = THIS_ACCOUNT

local DDM_Add = addon.Helpers.DDM_Add
local DDM_AddTitle = addon.Helpers.DDM_AddTitle
local DDM_AddCloseMenu = addon.Helpers.DDM_AddCloseMenu

-- ** Left menu **
-- local VIEW_EQUIP = 1
-- local VIEW_REP = 2
-- local VIEW_TOKENS = 3
-- local VIEW_ALL_TABARDS = 4
-- local VIEW_ALL_COMPANIONS = 5
-- local VIEW_ALL_MOUNTS = 6

local ICON_QUESTIONMARK = "Interface\\RaidFrame\\ReadyCheck-Waiting"

local ICON_VIEW_EQUIP = "Interface\\Icons\\INV_Chest_Plate04"
local ICON_VIEW_REP = "Interface\\Icons\\INV_BannerPVP_02"
local ICON_VIEW_TOKENS = "Interface\\Icons\\Spell_Holy_SummonChampion"
local ICON_VIEW_TABARDS = "Interface\\Icons\\inv_chest_cloth_30"
local ICON_VIEW_COMPANIONS = "Interface\\Icons\\INV_Box_Birdcage_01"
local ICON_VIEW_MOUNTS = "Interface\\Icons\\Ability_Mount_RidingHorse"
local ICON_VIEW_TRADESKILLS = "Interface\\Icons\\Ability_Repair"
local ICON_VIEW_ARCHEOLOGY = "Interface\\Icons\\trade_archaeology"

addon.Tabs.Grids = {}

local ns = addon.Tabs.Grids		-- ns = namespace

-- *** Utility functions ***
local lastButton

local function StartAutoCastShine(button)
	local item = button:GetName()
	AutoCastShine_AutoCastStart(_G[ item .. "Shine" ]);
	lastButton = item
end

local function StopAutoCastShine()
	-- stop autocast shine on the last button that was clicked
	if lastButton then
		AutoCastShine_AutoCastStop(_G[ lastButton .. "Shine" ]);
	end
end

local function EnableIcon(name)
	_G[name]:Enable()
	_G[name.."IconTexture"]:SetDesaturated(0)
end

local function DisableIcon(name)
	_G[name]:Disable()
	_G[name.."IconTexture"]:SetDesaturated(1)
end

local function UpdateMenuIcons()
	
	if DataStore_Inventory then
		EnableIcon(parent .. "_Equipment")
	else
		DisableIcon(parent .. "_Equipment")
	end

	if DataStore_Reputations then
		EnableIcon(parent .. "_Factions")
	else
		DisableIcon(parent .. "_Factions")
	end
	
	if DataStore_Currencies then
		EnableIcon(parent .. "_Tokens")
	else
		DisableIcon(parent .. "_Tokens")
	end
	
	if DataStore_Pets then
		EnableIcon(parent .. "_Pets")
		EnableIcon(parent .. "_Mounts")
	else
		DisableIcon(parent .. "_Pets")
		DisableIcon(parent .. "_Mounts")
	end
	
	if DataStore_Achievements then
		EnableIcon(parent .. "_Tabards")
	else
		DisableIcon(parent .. "_Tabards")
	end
end

local function UpdateClassIcons()
	local key = addon:GetOption(format("Tabs.Grids.%s.%s.Column1", currentAccount, currentRealm))
	if not key then	-- first time this realm is displayed, or reset by player
	
		local index = 1

		-- add the first 10 keys found on this realm
		for characterName, characterKey in pairs(DataStore:GetCharacters(currentRealm, currentAccount)) do	
			-- ex: : ["Tabs.Grids.Default.MyRealm.Column4"] = "Account.realm.alt7"

			addon:SetOption(format("Tabs.Grids.%s.%s.Column%d", currentAccount, currentRealm, index), characterKey)
			
			index = index + 1
			if index > 10 then
				break
			end
		end
		
		while index <= 10 do
			addon:SetOption(format("Tabs.Grids.%s.%s.Column%d", currentAccount, currentRealm, index), nil)
			index = index + 1
		end
	end
	
	local itemName, itemButton, itemTexture
	local class, _
	
	for i = 1, 10 do
		itemName = parent .. "_ClassIcon" .. i
		itemButton = _G[itemName]
		
		key = addon:GetOption(format("Tabs.Grids.%s.%s.Column%d", currentAccount, currentRealm, i))
		itemTexture = _G[itemName .. "IconTexture"]
		addon:CreateButtonBorder(itemButton)
		
		if key then
			_, class = DataStore:GetCharacterClass(key)
		end
		
		if key and class then
			local tc = CLASS_ICON_TCOORDS[class]
		
			itemTexture:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes");
			itemTexture:SetTexCoord(tc[1], tc[2], tc[3], tc[4]);
	
			if DataStore:GetCharacterFaction(key) == "Alliance" then
				itemButton.border:SetVertexColor(0.1, 0.25, 1, 0.5)
			else
				itemButton.border:SetVertexColor(1, 0, 0, 0.5)
			end

		else	-- no key ? display a question mark icon
			itemTexture:SetTexture(ICON_PARTIAL)
			itemTexture:SetTexCoord(0, 1, 0, 1)
			
			itemButton.border:SetVertexColor(0, 1, 0, 0.5)
		end
		
		itemTexture:SetWidth(36)
		itemTexture:SetHeight(36)
		itemTexture:SetAllPoints(itemButton)
		
		itemButton.border:Show()
		itemButton:Show()
	end
end

local gridCallbacks = {}

function ns:RegisterGrid(category, callbacks)
	gridCallbacks[category] = callbacks
end

function ns:OnShow()
	if not currentCategory then
		StartAutoCastShine(_G[parent .. "_Equipment"])
		currentCategory = 1
		
		-- Button Borders
		for column = 1, 10 do
			for row = 1, 8 do
				addon:CreateButtonBorder(_G["AltoholicFrameGridsEntry".. row .. "Item" .. column])
			end
		end
	end

	UpdateMenuIcons()
	ns:Update()
end

function ns:MenuItem_OnClick(frame, button)
	DropDownList1:Hide()		-- hide any right-click menu that could be open
	
	StopAutoCastShine()
	StartAutoCastShine(frame)
	
	currentCategory = frame:GetID()

	local obj = gridCallbacks[currentCategory]	-- point to the callbacks of the current object (equipment, tabards, ..)
	obj.InitViewDDM(_G[parent.."_SelectView"], _G[parent.."TextView"])
	
	ns:Update()
end

function ns:Update()
	UpdateClassIcons()

	-- update de la frame en cours
	local numVisibleLines = 8
	local frame = "AltoholicFrameGrids"
	_G[frame]:Show()
	
	local entry = frame.."Entry"
	local offset = FauxScrollFrame_GetOffset( _G[ frame.."ScrollFrame" ] );
	
	ns:SetStatus("")
	
	local obj = gridCallbacks[currentCategory]	-- point to the callbacks of the current object (equipment, tabards, ..)
	obj:OnUpdate()
	
	local size = obj:GetSize()

	local dataRowID
	local itemButton
	
	for row = 1, numVisibleLines do
		dataRowID = row + offset
		if dataRowID <= size then	-- if the row is visible

			obj:RowSetup(entry, row, dataRowID)
			
			for column = 1, 10 do
				itemButton = _G[entry.. row .. "Item" .. column]
				itemButton.border:Hide()
				
				character = addon:GetOption(format("Tabs.Grids.%s.%s.Column%d", currentAccount, currentRealm, column))
				if character then
					itemButton:SetScript("OnEnter", obj.OnEnter)
					itemButton:SetScript("OnClick", obj.OnClick)
					itemButton:SetScript("OnLeave", obj.OnLeave)
					
					itemButton:Show()	-- note: this Show() must remain BEFORE the next call, if the button has to be hidden, it's done in ColumnSetup
					obj:ColumnSetup(entry, row, column, dataRowID, character)
				else
					itemButton.id = nil
					itemButton:Hide()
				end
			end

			_G[ entry..row ]:Show()
		else
			_G[ entry..row ]:Hide()
		end
	end

	FauxScrollFrame_Update( _G[ frame.."ScrollFrame" ], size, numVisibleLines, 41);
end

function ns:GetRealm()
	return currentRealm, currentAccount
end

function ns:SetStatus(text)
	_G[parent .. "Status"]:SetText(text)
end

function ns:SetViewDDMText(text)
	UIDropDownMenu_SetText(_G[parent.."_SelectView"], text)
end


-- ** realm selection **
local function OnRealmChange(self, account, realm)
	local oldAccount = currentAccount
	local oldRealm = currentRealm

	currentAccount = account
	currentRealm = realm

	UIDropDownMenu_ClearAll(_G[ parent .. "_SelectRealm" ]);
	UIDropDownMenu_SetSelectedValue(_G[ parent .. "_SelectRealm" ], account .."|".. realm)
	UIDropDownMenu_SetText(_G[ parent .. "_SelectRealm" ], GREEN .. account .. ": " .. WHITE.. realm)
	
	if oldRealm and oldAccount then	-- clear the "select char" drop down if realm or account has changed
		if (oldRealm ~= realm) or (oldAccount ~= account) then
			_G[ parent .. "Status" ]:SetText("")
			ns:Update()
		end
	end
end

function ns:DropDownRealm_Initialize()
	if not currentAccount or not currentRealm then return end

	-- this account first ..
	DDM_AddTitle(GOLD..L["This account"])
	for realm in pairs(DataStore:GetRealms()) do
		local info = UIDropDownMenu_CreateInfo()

		info.text = WHITE..realm
		info.value = format("%s|%s", THIS_ACCOUNT, realm)
		info.checked = nil
		info.func = OnRealmChange
		info.arg1 = THIS_ACCOUNT
		info.arg2 = realm
		UIDropDownMenu_AddButton(info, 1)
	end

	-- .. then all other accounts
	local accounts = DataStore:GetAccounts()
	local count = 0
	for account in pairs(accounts) do
		if account ~= THIS_ACCOUNT then
			count = count + 1
		end
	end
	
	if count > 0 then
		DDM_AddTitle(" ")
		DDM_AddTitle(GOLD..OTHER)
		for account in pairs(accounts) do
			if account ~= THIS_ACCOUNT then
				for realm in pairs(DataStore:GetRealms(account)) do
					local info = UIDropDownMenu_CreateInfo()

					info.text = format("%s: %s", GREEN..account, WHITE..realm)
					info.value = format("%s|%s", account, realm)
					info.checked = nil
					info.func = OnRealmChange
					info.arg1 = account
					info.arg2 = realm
					UIDropDownMenu_AddButton(info, 1)
				end
			end
		end
	end
end


-- ** Icon events **
local function OnCharacterChange(self, id)
	if not id then return end		-- no icon id ? exit
	
	local key = self.value		-- key is either a datastore character key, or nil (if "None" is selected by the player for this column)

	if key == "empty" then		-- if the keyword "empty" is passed, save a nil value in the options
		key = nil
	end

	addon:SetOption(format("Tabs.Grids.%s.%s.Column%d", currentAccount, currentRealm, id), key)
	ns:Update()
end

-- ** Menu Icons **
function ns:Icon_OnEnter(frame)
	local currentMenuID = frame:GetID()
	
	-- hide all
	CloseDropDownMenus()

	-- show current
	ToggleDropDownMenu(1, nil, _G[ classMenu .. currentMenuID ], frame:GetName(), 0, -5);	
	
	local key = addon:GetOption(format("Tabs.Grids.%s.%s.Column%d", currentAccount, currentRealm, currentMenuID))
	if key then
		addon:DrawCharacterTooltip(frame, key)
	end
end

local function ClassIcon_Initialize(self, level)
	local id = self:GetID()
	
	DDM_AddTitle(L["Characters"])
	local nameList = {}		-- we want to list characters alphabetically
	for _, character in pairs(DataStore:GetCharacters(currentRealm, currentAccount)) do
		table.insert(nameList, character)	-- we can add the key instead of just the name, since they will all be like account.realm.name, where account & realm are identical
	end
	table.sort(nameList)
	
	-- get the key associated with this button
	local key = addon:GetOption(format("Tabs.Grids.%s.%s.Column%d", currentAccount, currentRealm, id)) or ""
	
	for _, character in ipairs(nameList) do
		local info = UIDropDownMenu_CreateInfo(); 
		
		info.text		= DataStore:GetColoredCharacterName(character)
		info.value		= character
		info.func		= OnCharacterChange
		info.checked	= (key == character)
		info.arg1		= id
		UIDropDownMenu_AddButton(info, 1)
	end
	
	DDM_AddTitle(" ")
	
	local info = UIDropDownMenu_CreateInfo()
	info.text		= (id == 1) and RESET or NONE
	info.value		= "empty"
	info.func		= OnCharacterChange
	info.checked	= (key == "")
	info.arg1		= id
	UIDropDownMenu_AddButton(info, 1)

	DDM_AddCloseMenu()
end

function ns:OnLoad()
	local size = 30

	-- Left Menu
	_G[parent .. "Text1"]:SetText(L["Realm"])

	-- ** Equipment / Reputations / Currencies / Tabards **
	addon:SetItemButtonTexture(parent .. "_Equipment", ICON_VIEW_EQUIP, size, size)
	_G[parent .. "_Equipment"].text = L["Equipment"]
	addon:SetItemButtonTexture(parent .. "_Factions", ICON_VIEW_REP, size, size)
	_G[parent .. "_Factions"].text = L["Reputations"]
	addon:SetItemButtonTexture(parent .. "_Tokens", ICON_VIEW_TOKENS, size, size)
	_G[parent .. "_Tokens"].text = CURRENCY
	addon:SetItemButtonTexture(parent .. "_Tabards", ICON_VIEW_TABARDS, size, size)
	_G[parent .. "_Tabards"].text = "Tabards"

	-- ** Pets / Mounts  **
	addon:SetItemButtonTexture(parent .. "_Pets", ICON_VIEW_COMPANIONS, size, size)
	_G[parent .. "_Pets"].text = COMPANIONS
	addon:SetItemButtonTexture(parent .. "_Mounts", ICON_VIEW_MOUNTS, size, size)
	_G[parent .. "_Mounts"].text = MOUNTS
	
	-- ** Secondary Professions  **
	addon:SetItemButtonTexture(parent .. "_TradeSkills", ICON_VIEW_TRADESKILLS, size, size)
	_G[parent .. "_TradeSkills"].text = TRADESKILLS
	addon:SetItemButtonTexture(parent .. "_Archeology", ICON_VIEW_ARCHEOLOGY, size, size)
	_G[parent .. "_Archeology"].text = GetSpellInfo(78670)
	
	-- Class Icons
	for column = 1, 10 do
		addon:DDM_Initialize(_G[classMenu..column], ClassIcon_Initialize)
	end
end
