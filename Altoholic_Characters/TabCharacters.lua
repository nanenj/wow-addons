local addonName = "Altoholic"
local addon = _G[addonName]

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local THIS_ACCOUNT = "Default"
local WHITE		= "|cFFFFFFFF"
local TEAL		= "|cFF00FF9A"
local ORANGE	= "|cFFFF7F00"
local GREEN		= "|cFF00FF00"
local YELLOW	= "|cFFFFFF00"
local GREY		= "|cFF808080"
local GOLD		= "|cFFFFD700"

local parent = "AltoholicTabCharacters"
local rcMenuName = parent .. "RightClickMenu"	-- name of right click menu frames (add a number at the end to get it)
local classMenu = parent .. "ClassIconMenu"	-- name of mouse over menu frames (add a number at the end to get it)

local currentCategory = 1	-- current category (characters, equipment, rep, currencies, etc.. )
local currentView = 0		-- current view in the characters category
local currentProfession

local currentAlt = UnitName("player")
local currentRealm = GetRealmName()
local currentAccount = THIS_ACCOUNT

-- ** Icons Menus **
local VIEW_BAGS = 1
local VIEW_QUESTS = 2
local VIEW_TALENTS = 3
local VIEW_GLYPHS = 4
local VIEW_AUCTIONS = 5
local VIEW_BIDS = 6
local VIEW_MAILS = 7
local VIEW_MOUNTS = 8
local VIEW_COMPANIONS = 9
local VIEW_SPELLS = 10
local VIEW_KNOWN_GLYPHS = 11
local VIEW_PROFESSION = 12

local ICON_CHARACTERS_ALLIANCE = "Interface\\Icons\\Achievement_Character_Gnome_Female"
local ICON_CHARACTERS_HORDE = "Interface\\Icons\\Achievement_Character_Orc_Male"
-- mini easter egg icons, if you read the code using these, please don't spoil it :)
local ICON_CHARACTERS_MIDSUMMER = "Interface\\Icons\\INV_Misc_Toy_07"
local ICON_CHARACTERS_HALLOWSEND_ALLIANCE = "Interface\\Icons\\INV_Mask_06"
local ICON_CHARACTERS_HALLOWSEND_HORDE = "Interface\\Icons\\INV_Mask_03"
local ICON_CHARACTERS_DOTD_ALLIANCE = "Interface\\Icons\\INV_Misc_Bone_HumanSkull_02"
local ICON_CHARACTERS_DOTD_HORDE = "Interface\\Icons\\INV_Misc_Bone_OrcSkull_01"
local ICON_CHARACTERS_WINTERVEIL_ALLIANCE = "Interface\\Icons\\Achievement_WorldEvent_LittleHelper"
local ICON_CHARACTERS_WINTERVEIL_HORDE = "Interface\\Icons\\Achievement_WorldEvent_XmasOgre"

-- Second mini easter egg, the bag icon changes depending on the amount of chars at level max (on the current realm), or based on the time of the year
local BAG_ICONS = {
	"Interface\\Icons\\INV_MISC_BAG_09",			-- mini pouch
	"Interface\\Icons\\INV_MISC_BAG_10_BLUE",		-- small bag
	"Interface\\Icons\\INV_Misc_Bag_12",			-- larger bag
	"Interface\\Icons\\INV_Misc_Bag_19",			-- bag 14
	"Interface\\Icons\\INV_Misc_Bag_08",			-- bag 16
	"Interface\\Icons\\INV_Misc_Bag_23_Netherweave",	-- 18
	"Interface\\Icons\\INV_Misc_Bag_EnchantedMageweave",	-- 20
	"Interface\\Icons\\INV_Misc_Bag_25_Mooncloth",
	"Interface\\Icons\\INV_Misc_Bag_26_Spellfire",
	"Interface\\Icons\\INV_Misc_Bag_33",
}

local ICON_BAGS_HALLOWSEND = "Interface\\Icons\\INV_Misc_Bag_28_Halloween"
local ICON_VIEW_BAGS = "Interface\\Icons\\INV_MISC_BAG_09"
local ICON_VIEW_TALENTS = "Interface\\Icons\\Spell_Nature_NatureGuardian"
local ICON_VIEW_QUESTS = "Interface\\LFGFrame\\LFGIcon-Quest"
local ICON_VIEW_AUCTIONS = "Interface\\Icons\\INV_Misc_Coin_01"
local ICON_VIEW_MAILS = "Interface\\Icons\\INV_Misc_Note_01"
local ICON_VIEW_SPELLBOOK = "Interface\\Icons\\INV_Misc_Book_09"
local ICON_VIEW_PROFESSIONS = "Interface\\Icons\\Achievement_GuildPerk_WorkingOvertime"

-- ** Left menu **
local ICON_CHARACTERS = "Interface\\Icons\\Achievement_GuildPerk_Everyones a Hero_rank2"

addon.Tabs.Characters = {}

local ns = addon.Tabs.Characters		-- ns = namespace

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

local function HideAll()
	AltoholicFrameContainers:Hide()
	AltoholicFrameTalents:Hide()
	AltoholicFrameMail:Hide()
	AltoholicFrameQuests:Hide()
	AltoholicFramePets:Hide()
	AltoholicFrameAuctions:Hide()
	AltoholicFrameRecipes:Hide()
	AltoholicFrameGlyphs:Hide()
	AltoholicFrameSpellbook:Hide()
end

local function EnableIcon(name)
	_G[name]:Enable()
	_G[name.."IconTexture"]:SetDesaturated(0)
end

local DDM_Add = addon.Helpers.DDM_Add
local DDM_AddTitle = addon.Helpers.DDM_AddTitle
local DDM_AddCloseMenu = addon.Helpers.DDM_AddCloseMenu

function ns:OnShow()
	if currentView == 0 then
		StartAutoCastShine(_G[parent .. "_Characters"])
		ns:ViewCharInfo(VIEW_BAGS)
	end
end

function ns:MenuItem_OnClick(frame, button)
	HideAll()
	DropDownList1:Hide()		-- hide any right-click menu that could be open
	
	StopAutoCastShine()
	StartAutoCastShine(frame)
	
	local id = frame:GetID()
	currentCategory = id

	_G[parent .. "_CharactersIcon"]:Show()
	_G[parent .. "_BagsIcon"]:Show()
	_G[parent .. "_QuestsIcon"]:Show()
	_G[parent .. "_TalentsIcon"]:Show()
	_G[parent .. "_AuctionIcon"]:Show()
	_G[parent .. "_MailIcon"]:Show()
	_G[parent .. "_SpellbookIcon"]:Show()
	_G[parent .. "_ProfessionsIcon"]:Show()
end

-- ** realm selection **
local function OnRealmChange(self, account, realm)
	local oldAccount = currentAccount
	local oldRealm = currentRealm

	currentAccount = account
	currentRealm = realm
	
	UIDropDownMenu_ClearAll(AltoholicTabCharacters_SelectRealm);
	UIDropDownMenu_SetSelectedValue(AltoholicTabCharacters_SelectRealm, account .."|".. realm)
	UIDropDownMenu_SetText(AltoholicTabCharacters_SelectRealm, GREEN .. account .. ": " .. WHITE.. realm)
	
	if oldRealm and oldAccount then	-- clear the "select char" drop down if realm or account has changed
		if (oldRealm ~= realm) or (oldAccount ~= account) then
			AltoholicTabCharactersStatus:SetText("")
			currentAlt = nil
			currentProfession = nil
			
			HideAll()
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


function ns:ViewCharInfo(index)
	index = index or self.value
	
	currentView = index
	HideAll()
	ns:SetMode(index)
	ns:ShowCharInfo(index)
end

function ns:ShowCharInfo(view)
	if view == VIEW_BAGS then
		addon:ClearScrollFrame(_G[ "AltoholicFrameContainersScrollFrame" ], "AltoholicFrameContainersEntry", 7, 41)
		
		addon.Containers:SetView((addon:GetOption("UI.Tabs.Characters.ViewBagsAllInOne") == 1))
		AltoholicFrameContainers:Show()
		addon.Containers:Update()
		
	elseif view == VIEW_QUESTS then
		AltoholicFrameQuests:Show()
		addon.Quests:InvalidateView()
		addon.Quests:Update()		
		
	elseif view == VIEW_TALENTS then
		addon.Talents:Reset();
		addon.Talents:Update();
	elseif view == VIEW_GLYPHS then
		AltoholicFrameGlyphs:Show()
		addon.Glyphs:Update();
	
	elseif view == VIEW_AUCTIONS then
		addon.AuctionHouse:SetListType("Auctions")
		AltoholicFrameAuctions:Show()
		addon.AuctionHouse:InvalidateView()
		addon.AuctionHouse:Update()
	elseif view == VIEW_BIDS then
		addon.AuctionHouse:SetListType("Bids")
		AltoholicFrameAuctions:Show()
		addon.AuctionHouse:InvalidateView()
		addon.AuctionHouse:Update()
	elseif view == VIEW_MAILS then
		AltoholicFrameMail:Show()
		addon.Mail:BuildView()
		addon.Mail:Update()
		
	elseif view == VIEW_SPELLS then
		addon.Spellbook:Update()
	elseif view == VIEW_MOUNTS then
		addon.Pets:SetSinglePetView("MOUNT")
		addon.Pets:UpdatePets()
	elseif view == VIEW_COMPANIONS then
		addon.Pets:SetSinglePetView("CRITTER")
		addon.Pets:UpdatePets()
	elseif view == VIEW_KNOWN_GLYPHS then
		addon.Spellbook:UpdateKnownGlyphs()
	elseif view == VIEW_PROFESSION then
		addon.TradeSkills.Recipes:InvalidateView()
		addon.TradeSkills.Recipes:Update()
	end
end

function ns:SetMode(mode)
	local Columns = addon.Tabs.Columns
	Columns:Init()
	
	if not mode then return end		-- called without parameter for professions

	if mode == VIEW_MAILS then
		Columns:Add(MAIL_SUBJECT_LABEL, 220, function(self) addon.Mail:Sort(self, "name") end)
		Columns:Add(FROM, 140, function(self) addon.Mail:Sort(self, "from") end)
		Columns:Add(L["Expiry:"], 200, function(self) addon.Mail:Sort(self, "expiry") end)

	elseif mode == VIEW_AUCTIONS then
		Columns:Add(HELPFRAME_ITEM_TITLE, 220, function(self) addon.AuctionHouse:Sort(self, "name", "Auctions") end)
		Columns:Add(HIGH_BIDDER, 160, function(self) addon.AuctionHouse:Sort(self, "highBidder", "Auctions") end)
		Columns:Add(CURRENT_BID, 170, function(self) addon.AuctionHouse:Sort(self, "buyoutPrice", "Auctions") end)
	
	elseif mode == VIEW_BIDS then
		Columns:Add(HELPFRAME_ITEM_TITLE, 220, function(self) addon.AuctionHouse:Sort(self, "name", "Bids") end)
		Columns:Add(NAME, 160, function(self) addon.AuctionHouse:Sort(self, "owner", "Bids") end)
		Columns:Add(CURRENT_BID, 170, function(self) addon.AuctionHouse:Sort(self, "buyoutPrice", "Bids") end)
	end
end

function ns:SetCurrentProfession(prof)
	currentProfession = prof

	if currentProfession then
		addon.TradeSkills.Recipes:SetCurrentProfession(currentProfession)
		ns:ViewCharInfo(VIEW_PROFESSION)
	end
end

-- ** DB / Get **
function ns:GetAccount()
	return currentAccount
end

function ns:GetRealm()
	return currentRealm, currentAccount
end

function ns:GetAlt()
	return currentAlt, currentRealm, currentAccount
end

function ns:GetAltKey()
	if currentAlt and currentRealm and currentAccount then
		return format("%s.%s.%s", currentAccount, currentRealm, currentAlt)
	end
end

-- ** DB / Set **
function ns:SetAlt(alt, realm, account)
	currentAlt = alt
	currentRealm = (realm) and realm				-- only set the value if not nil
	currentAccount = (account) and account		-- only set the value if not nil
	
	-- set drop down menu
	ns:DropDownRealm_Initialize()
	UIDropDownMenu_SetSelectedValue(AltoholicTabCharacters_SelectRealm, account .."|".. realm)
end


-- ** Icon events **
local function OnCharacterChange(self)
	local oldAlt = currentAlt
	local _, _, newAlt = strsplit(".", self.value)
	currentAlt = newAlt
	
	EnableIcon(parent .. "_BagsIcon")
	EnableIcon(parent .. "_QuestsIcon")
	EnableIcon(parent .. "_TalentsIcon")
	EnableIcon(parent .. "_AuctionIcon")
	EnableIcon(parent .. "_MailIcon")
	EnableIcon(parent .. "_SpellbookIcon")
	EnableIcon(parent .. "_ProfessionsIcon")
	
	if (not oldAlt) or (oldAlt == newAlt) then return end

	currentProfession = nil
	if currentView ~= VIEW_TALENTS and currentView < VIEW_SPELLS then
		ns:ShowCharInfo(currentView)		-- this will show the same info from another alt (ex: containers/mail/ ..)
	else
		HideAll()
		AltoholicTabCharactersStatus:SetText(format("%s|r /", DataStore:GetColoredCharacterName(self.value)))
	end
end

local function OnContainerChange(self)
	if self.value == 1 then
		addon:ToggleOption(nil, "UI.Tabs.Characters.ViewBags")
	elseif self.value == 2 then
		addon:ToggleOption(nil, "UI.Tabs.Characters.ViewBank")
	elseif self.value == 3 then
		addon:ToggleOption(nil, "UI.Tabs.Characters.ViewVoidStorage")
	elseif self.value == 4 then
		addon:ToggleOption(nil, "UI.Tabs.Characters.ViewBagsAllInOne")
	end
	
	ns:ViewCharInfo(VIEW_BAGS)
end

local function OnRarityChange(self)
	addon:SetOption("UI.Tabs.Characters.ViewBagsRarity", self.value)
	addon.Containers:Update()
end

local function OnTalentChange(self)
	CloseDropDownMenus()
	
	local group = self.value
	if group then
		addon.Talents:SetCurrentGroup(group)
		addon.Talents:SetCurrentTreeID(self.arg1)
		ns:ViewCharInfo(VIEW_TALENTS)
	end
end

local function OnGlyphChange(self)
	CloseDropDownMenus()

	ns:ViewCharInfo(VIEW_GLYPHS)
end

local function OnSpellTabChange(self)
	CloseDropDownMenus()
	
	if self.value then
		addon.Spellbook:SetSchool(self.value)
		ns:ViewCharInfo(VIEW_SPELLS)
	end
end

local function OnGlyphSpellsChange(self)
	CloseDropDownMenus()
	
	if self.value then
		addon.Spellbook:SetGlyphType(self.value)
		ns:ViewCharInfo(VIEW_KNOWN_GLYPHS)
	end
end

local function OnProfessionChange(self)
	CloseDropDownMenus()
	ns:SetCurrentProfession(self.value)
end

local function OnProfessionColorChange(self)
	CloseDropDownMenus()
	
	if self.value then
		addon.TradeSkills.Recipes:SetCurrentColor(self.value)
		ns:ViewCharInfo(VIEW_PROFESSION)
	end
end

local function OnProfessionSlotChange(self)
	CloseDropDownMenus()
	
	if self.value then
		addon.TradeSkills.Recipes:SetCurrentSlots(self.value)
		ns:ViewCharInfo(VIEW_PROFESSION)
	end
end

local function OnProfessionSubClassChange(self)
	CloseDropDownMenus()
	
	if self.value then
		addon.TradeSkills.Recipes:SetCurrentSubClass(self.value)
		ns:ViewCharInfo(VIEW_PROFESSION)
	end
end


local function OnViewChange(self)
	if self.value then
		ns:ViewCharInfo(self.value)
	end
end

local function OnClearAHEntries(self)
	local character = ns:GetAltKey()
	
	local listType
	if currentView == VIEW_AUCTIONS then
		listType = "Auctions"
	elseif currentView == VIEW_BIDS then
		listType = "Bids"
	end
	
	if (self.value == 1) or (self.value == 3) then	-- clean this faction's data
		DataStore:ClearAuctionEntries(character, listType, 0)
	end
	
	if (self.value == 2) or (self.value == 3) then	-- clean goblin AH
		DataStore:ClearAuctionEntries(character, listType, 1)
	end
	
	addon.AuctionHouse:InvalidateView()
end

local function OnClearMailboxEntries(self)
	local character = ns:GetAltKey()
	DataStore:ClearMailboxEntries(character)
	addon.Mails:Update()
end


local function GetCharacterLoginText(character)
	local last = DataStore:GetLastLogout(character)
	local _, _, name = strsplit(".", character)
	
	if last then
		if name == UnitName("player") then
			last = GREEN..GUILD_ONLINE_LABEL
		else
			last = format("%s: %s", LASTONLINE, YELLOW..date("%m/%d/%Y %H:%M", last))
		end
	else
		last = format("%s: %s", LASTONLINE, RED..L["N/A"])
	end
	return format("%s %s(%s%s)", DataStore:GetColoredCharacterName(character), WHITE, last, WHITE)
end


-- ** Menu Icons **
function ns:Icon_OnEnter(frame)
	local currentMenuID = frame:GetID()
	
	-- hide all
	CloseDropDownMenus()

	-- show current
	ToggleDropDownMenu(1, nil, _G[ rcMenuName .. currentMenuID ], frame:GetName(), 0, -5);	
end

local function CharactersIcon_Initialize(self, level)
	DDM_AddTitle(L["Characters"])
	local nameList = {}		-- we want to list characters alphabetically
	for _, character in pairs(DataStore:GetCharacters(currentRealm, currentAccount)) do
		table.insert(nameList, character)	-- we can add the key instead of just the name, since they will all be like account.realm.name, where account & realm are identical
	end
	table.sort(nameList)
	
	local currentCharacterKey = ns:GetAltKey()
	for _, character in ipairs(nameList) do
		DDM_Add(GetCharacterLoginText(character), character, OnCharacterChange, nil, (currentCharacterKey == character))
	end

	DDM_AddCloseMenu()
end

local function BagsIcon_Initialize(self, level)
	local currentCharacterKey = ns:GetAltKey()
	if not currentCharacterKey then return end

	DDM_AddTitle(format("%s / %s", L["Containers"], DataStore:GetColoredCharacterName(currentCharacterKey)))
	DDM_Add(L["View"], nil, function() ns:ViewCharInfo(VIEW_BAGS) end)
	DDM_Add(L["Bags"], 1, OnContainerChange, nil, (addon:GetOption("UI.Tabs.Characters.ViewBags") == 1))
	DDM_Add(L["Bank"], 2, OnContainerChange, nil, (addon:GetOption("UI.Tabs.Characters.ViewBank") == 1))
	DDM_Add(VOID_STORAGE, 3, OnContainerChange, nil, (addon:GetOption("UI.Tabs.Characters.ViewVoidStorage") == 1))
	DDM_Add(L["All-in-one"], 4, OnContainerChange, nil, (addon:GetOption("UI.Tabs.Characters.ViewBagsAllInOne") == 1))
		
	DDM_AddTitle(" ")
	DDM_AddTitle("|r" ..RARITY)
	local rarity = addon:GetOption("UI.Tabs.Characters.ViewBagsRarity")
	DDM_Add(L["Any"], 0, OnRarityChange, nil, (rarity == 0))
	
	for i = 2, 6 do		-- Quality: 0 = poor .. 5 = legendary
		DDM_Add(ITEM_QUALITY_COLORS[i].hex .. _G["ITEM_QUALITY"..i.."_DESC"], i, OnRarityChange, nil, (rarity == i))
	end
	
	DDM_AddCloseMenu()
end

local function QuestsIcon_Initialize(self, level)
	local currentCharacterKey = ns:GetAltKey()
	if not currentCharacterKey then return end
	
	DDM_AddTitle(format("%s / %s", QUESTS_LABEL, DataStore:GetColoredCharacterName(currentCharacterKey)))
	DDM_Add(QUEST_LOG, VIEW_QUESTS, OnViewChange, nil, (currentView == VIEW_QUESTS))
	
	DDM_AddTitle("|r ")
	DDM_AddTitle(GAMEOPTIONS_MENU)
	if DataStore_Quests then
		DDM_Add("DataStore Quests", nil, function() Altoholic:ToggleUI(); InterfaceOptionsFrame_OpenToCategory(DataStoreQuestsOptions) end)
	end
	DDM_AddCloseMenu()
end

local function TalentsIcon_Initialize(self, level)
	
	local currentCharacterKey = ns:GetAltKey()
	if not currentCharacterKey then return end
	
	DDM_AddTitle(format("%s & %s / %s", TALENTS, GLYPHS, DataStore:GetColoredCharacterName(currentCharacterKey)))
	DDM_AddTitle(" ")
	DDM_Add(TALENT_SPEC_PRIMARY, 1, OnTalentChange, nil, nil)
	DDM_Add(TALENT_SPEC_SECONDARY, 2, OnTalentChange, nil, nil)
	DDM_AddTitle(" ")
	DDM_Add(GLYPHS, nil, OnGlyphChange)
	
	DDM_AddCloseMenu()
end

local function AuctionIcon_Initialize(self, level)
	local currentCharacterKey = ns:GetAltKey()
	if not currentCharacterKey then return end
	
	DDM_AddTitle(format("%s / %s", BUTTON_LAG_AUCTIONHOUSE, DataStore:GetColoredCharacterName(currentCharacterKey)))
	
	local last = DataStore:GetModuleLastUpdateByKey("DataStore_Auctions", currentCharacterKey)
	if DataStore_Auctions and last then
		local numAuctions = DataStore:GetNumAuctions(currentCharacterKey) or 0
		local numBids = DataStore:GetNumBids(currentCharacterKey) or 0
		
		DDM_Add(format(L["Auctions %s(%d)"], GREEN, numAuctions), VIEW_AUCTIONS, OnViewChange, nil, (currentView == VIEW_AUCTIONS))
		DDM_Add(format(L["Bids %s(%d)"], GREEN, numBids), VIEW_BIDS, OnViewChange, nil, (currentView == VIEW_BIDS))
	else
		DDM_Add(format(L["Auctions %s(%d)"], GREY, 0), nil, nil)
		DDM_Add(format(L["Bids %s(%d)"], GREY, 0), nil, nil)
	end
	
	-- actions
	DDM_AddTitle(" ")
	DDM_Add(WHITE .. L["Clear your faction's entries"], 1, OnClearAHEntries)
	DDM_Add(WHITE .. L["Clear goblin AH entries"], 2, OnClearAHEntries)
	DDM_Add(WHITE .. L["Clear all entries"], 3, OnClearAHEntries)
	
	DDM_AddTitle("|r ")
	DDM_AddTitle(GAMEOPTIONS_MENU)
	if DataStore_Auctions then
		DDM_Add("DataStore Auctions", nil, function() Altoholic:ToggleUI(); InterfaceOptionsFrame_OpenToCategory(DataStoreAuctionsOptions) end)
	end
	DDM_AddCloseMenu()
end

local function MailIcon_Initialize(self, level)
	local currentCharacterKey = ns:GetAltKey()
	if not currentCharacterKey then return end
		
	DDM_AddTitle(format("%s / %s", MINIMAP_TRACKING_MAILBOX, DataStore:GetColoredCharacterName(currentCharacterKey)))

	local last = DataStore:GetModuleLastUpdateByKey("DataStore_Mails", currentCharacterKey)
	if DataStore_Mails and last then
		local numMails = DataStore:GetNumMails(currentCharacterKey) or 0
		DDM_Add(format(L["Mails %s(%d)"], GREEN, numMails), VIEW_MAILS, OnViewChange, nil, (currentView == VIEW_MAILS))
	else
		DDM_Add(format(L["Mails %s(%d)"], GREY, 0), nil, nil)
	end

	DDM_Add(WHITE .. L["Clear all entries"], nil, OnClearMailboxEntries)
	DDM_AddTitle("|r ")
	DDM_AddTitle(GAMEOPTIONS_MENU)
	DDM_Add(MAIL_LABEL, nil, function() Altoholic:ToggleUI(); InterfaceOptionsFrame_OpenToCategory(AltoholicMailOptions) end)
	if DataStore_Mails then
		DDM_Add("DataStore Mails", nil, function() Altoholic:ToggleUI(); InterfaceOptionsFrame_OpenToCategory(DataStoreMailOptions) end)
	end
	
	DDM_AddCloseMenu()
end

local function SpellbookIcon_Initialize(self, level)
	local currentCharacterKey = ns:GetAltKey()
	if not currentCharacterKey then return end
	
	DDM_AddTitle(format("%s / %s", SPELLBOOK, DataStore:GetColoredCharacterName(currentCharacterKey)))
	
	for index, spellTab in ipairs(DataStore:GetSpellTabs(currentCharacterKey)) do
		DDM_Add(spellTab, spellTab, OnSpellTabChange)
	end
	
	DDM_AddTitle(" ")
	
	local last = DataStore:GetModuleLastUpdateByKey("DataStore_Pets", currentCharacterKey)
	if DataStore_Pets and last then
		local pets = DataStore:GetPets(currentCharacterKey, "CRITTER")
		local numPets = DataStore:GetNumPets(pets) or 0
		pets = DataStore:GetPets(currentCharacterKey, "MOUNT")
		local numMounts = DataStore:GetNumPets(pets) or 0
	
		DDM_Add(format(MOUNTS .. " %s(%d)", GREEN, numMounts), VIEW_MOUNTS, OnViewChange, nil, (currentView == VIEW_MOUNTS))
		DDM_Add(format(COMPANIONS .. " %s(%d)", GREEN, numPets), VIEW_COMPANIONS, OnViewChange, nil, (currentView == VIEW_COMPANIONS))
	else
		DDM_Add(format(MOUNTS .. " %s(%d)", GREY, numMounts), nil, nil)
		DDM_Add(format(COMPANIONS .. " %s(%d)", GREY, numPets), nil, nil)
	end
	DDM_AddTitle(" ")
	DDM_AddTitle(GLYPHS)
	DDM_Add(MAJOR_GLYPHS, 1, OnGlyphSpellsChange)
	DDM_Add(MINOR_GLYPHS, 2, OnGlyphSpellsChange)
	DDM_AddCloseMenu()
end

local function ProfessionsIcon_Initialize(self, level)
	if not DataStore_Crafts then return end
	
	local currentCharacterKey = ns:GetAltKey()
	if not currentCharacterKey then return end
	
	if level == 1 then
		DDM_AddTitle(format("%s / %s", TRADE_SKILLS, DataStore:GetColoredCharacterName(currentCharacterKey)))

		local last = DataStore:GetModuleLastUpdateByKey("DataStore_Crafts", currentCharacterKey)

		local rank

		-- Cooking
		rank = DataStore:GetCookingRank(currentCharacterKey)
		if last and rank then
			DDM_Add(format("%s %s(%s)", PROFESSIONS_COOKING, GREEN, rank ), PROFESSIONS_COOKING, OnProfessionChange, nil, (PROFESSIONS_COOKING == (currentProfession or "")))
		else
			DDM_Add(GREY..PROFESSIONS_COOKING, nil, nil)
		end
		
		-- First Aid
		rank = DataStore:GetFirstAidRank(currentCharacterKey)
		if last and rank then
			DDM_Add(format("%s %s(%s)", PROFESSIONS_FIRST_AID, GREEN, rank ), PROFESSIONS_FIRST_AID, OnProfessionChange, nil, (PROFESSIONS_FIRST_AID == (currentProfession or "")))
		else
			DDM_Add(GREY..PROFESSIONS_FIRST_AID, nil, nil)
		end
		
		-- rank = DataStore:GetArchaeologyRank(currentCharacterKey)
		
		-- Profession 1
		local rank, professionName, _
		rank, _, _, professionName = DataStore:GetProfession1(currentCharacterKey)
		if last and rank then
			DDM_Add(format("%s %s(%s)", professionName, GREEN, rank ), professionName, OnProfessionChange, nil, (professionName == (currentProfession or "")))
		elseif professionName then
			DDM_Add(GREY..professionName, nil, nil)
		end
		
		-- Profession 2
		rank, _, _, professionName = DataStore:GetProfession2(currentCharacterKey)
		if last and rank then
			DDM_Add(format("%s %s(%s)", professionName, GREEN, rank ), professionName, OnProfessionChange, nil, (professionName == (currentProfession or "")))
		elseif professionName then
			DDM_Add(GREY..professionName, nil, nil)
		end
		
		DDM_AddTitle(" ")
		DDM_AddTitle(FILTERS)
		
		if currentProfession then		-- if a profession is visible, display filters
			local info = UIDropDownMenu_CreateInfo()

			info.text = WHITE..COLOR
			info.hasArrow = 1
			info.checked = nil
			info.value = 1
			info.func = nil
			UIDropDownMenu_AddButton(info, level)

			info.text = WHITE..TRADESKILL_FILTER_SLOTS
			info.hasArrow = 1
			info.checked = nil
			info.value = 2
			info.func = nil
			UIDropDownMenu_AddButton(info, level)

			info.text = WHITE..TRADESKILL_FILTER_SUBCLASS
			info.hasArrow = 1
			info.checked = nil
			info.value = 3
			info.func = nil
			UIDropDownMenu_AddButton(info, level)
			
		else		-- grey out filters
			DDM_Add(GREY..COLOR, nil, nil)
			DDM_Add(GREY..TRADESKILL_FILTER_SLOTS, nil, nil)
			DDM_Add(GREY..TRADESKILL_FILTER_SUBCLASS, nil, nil)
		end

		DDM_AddCloseMenu()
		
	elseif level == 2 then	-- ** filters **
		local info = UIDropDownMenu_CreateInfo()

		if UIDROPDOWNMENU_MENU_VALUE == 1 then		-- colors
			for index = 0, 3 do 
				info.text = addon.TradeSkills.Recipes:GetRecipeColorName(index)
				info.value = index
				info.checked = (addon.TradeSkills.Recipes:GetCurrentColor() == index)
				info.func = OnProfessionColorChange
				UIDropDownMenu_AddButton(info, level)
			end

			info.text = L["Any"]
			info.value = 4
			info.checked = (addon.TradeSkills.Recipes:GetCurrentColor() == 4)
			info.func = OnProfessionColorChange
			UIDropDownMenu_AddButton(info, level)
			
		elseif UIDROPDOWNMENU_MENU_VALUE == 2 then	-- slots
			info.text = ALL_INVENTORY_SLOTS
			info.value = ALL_INVENTORY_SLOTS
			info.checked = (addon.TradeSkills.Recipes:GetCurrentSlots() == ALL_INVENTORY_SLOTS)
			info.func = OnProfessionSlotChange
			UIDropDownMenu_AddButton(info, level)
			
			local invSlots = {}
			local profession = DataStore:GetProfession(currentCharacterKey, currentProfession)
				
			for index = 1, DataStore:GetNumCraftLines(profession) do
				local isHeader, _, spellID = DataStore:GetCraftLineInfo(profession, index)
				
				if not isHeader then		-- NON header !!
					local itemID = DataStore:GetCraftInfo(spellID)
					
					if itemID then
						local _, _, _, _, _, itemType, _, _, itemEquipLoc = GetItemInfo(itemID)
						
						if itemEquipLoc and strlen(itemEquipLoc) > 0 then
							local slot = Altoholic.Equipment:GetInventoryTypeName(itemEquipLoc)
							if slot then
								invSlots[slot] = itemEquipLoc
							end
						end
					end
				end
			end
			
			for k, v in pairs(invSlots) do		-- add all the slots found
				info.text = k
				info.value = v
				info.checked = (addon.TradeSkills.Recipes:GetCurrentSlots() == v)
				info.func = OnProfessionSlotChange
				UIDropDownMenu_AddButton(info, level)
			end

			--NONEQUIPSLOT = "Created Items"; -- Items created by enchanting
			info.text = NONEQUIPSLOT
			info.value = NONEQUIPSLOT
			info.checked = (addon.TradeSkills.Recipes:GetCurrentSlots() == NONEQUIPSLOT)
			info.func = OnProfessionSlotChange
			UIDropDownMenu_AddButton(info, level)
			
		elseif UIDROPDOWNMENU_MENU_VALUE == 3 then	-- subclass
		
			info.text = ALL_SUBCLASSES
			info.value = ALL_SUBCLASSES
			info.checked = (addon.TradeSkills.Recipes:GetCurrentSubClass() == ALL_SUBCLASSES)
			info.func = OnProfessionSubClassChange
			UIDropDownMenu_AddButton(info, level)
		
			local profession = DataStore:GetProfession(currentCharacterKey, currentProfession)
			for index = 1, DataStore:GetNumCraftLines(profession) do
				local isHeader, _, name = DataStore:GetCraftLineInfo(profession, index)
				
				if isHeader then
					info.text = name
					info.value = name
					info.checked = (addon.TradeSkills.Recipes:GetCurrentSubClass() == name)
					info.func = OnProfessionSubClassChange
					UIDropDownMenu_AddButton(info, level)
				end
			end
		end
	end
end


function ns:OnLoad()
	-- Menu Icons
	-- mini easter egg, change the character icon depending on the time of year :)
	-- if you find this code, please don't spoil it :)
	
	local size = 30
	local faction = UnitFactionGroup("player")
	local day = (tonumber(date("%m")) * 100) + tonumber(date("%d"))	-- ex: dec 15 = 1215, for easy tests below
	local icon = (faction == "Alliance") and ICON_CHARACTERS_ALLIANCE or ICON_CHARACTERS_HORDE
	local bagIcon = ICON_VIEW_BAGS

	-- bag icon gets better with more chars at lv max
	local LVMax = 85
	local numLvMax = 0
	for _, character in pairs(DataStore:GetCharacters()) do
		if DataStore:GetCharacterLevel(character) >= LVMax then
			numLvMax = numLvMax + 1
		end
	end

	if numLvMax > 0 then
		bagIcon = BAG_ICONS[numLvMax]
	end
	
	if (day >= 1215) or (day <= 102) then				-- winter veil
		icon = (faction == "Alliance") and ICON_CHARACTERS_WINTERVEIL_ALLIANCE or ICON_CHARACTERS_WINTERVEIL_HORDE
	elseif (day >= 621) and (day <= 704) then			-- midsummer
		icon = ICON_CHARACTERS_MIDSUMMER
	elseif (day >= 1018) and (day <= 1031) then		-- hallow's end
		icon = (faction == "Alliance") and ICON_CHARACTERS_HALLOWSEND_ALLIANCE or ICON_CHARACTERS_HALLOWSEND_HORDE
		bagIcon = ICON_BAGS_HALLOWSEND
	elseif (day >= 1101) and (day <= 1102) then		-- day of the dead
		icon = (faction == "Alliance") and ICON_CHARACTERS_DOTD_ALLIANCE or ICON_CHARACTERS_DOTD_HORDE
	end
	
	addon:SetItemButtonTexture(parent .. "_CharactersIcon", icon, size, size)
	addon:SetItemButtonTexture(parent .. "_BagsIcon", bagIcon, size, size)
	addon:SetItemButtonTexture(parent .. "_QuestsIcon", ICON_VIEW_QUESTS, size, size)
	addon:SetItemButtonTexture(parent .. "_TalentsIcon", ICON_VIEW_TALENTS, size, size)
	addon:SetItemButtonTexture(parent .. "_AuctionIcon", ICON_VIEW_AUCTIONS, size, size)
	addon:SetItemButtonTexture(parent .. "_MailIcon", ICON_VIEW_MAILS, size, size)
	addon:SetItemButtonTexture(parent .. "_SpellbookIcon", ICON_VIEW_SPELLBOOK, size, size)
	addon:SetItemButtonTexture(parent .. "_ProfessionsIcon", ICON_VIEW_PROFESSIONS, size, size)
	
	addon:DDM_Initialize(_G[rcMenuName.."1"], CharactersIcon_Initialize)
	addon:DDM_Initialize(_G[rcMenuName.."2"], BagsIcon_Initialize)
	addon:DDM_Initialize(_G[rcMenuName.."3"], QuestsIcon_Initialize)
	addon:DDM_Initialize(_G[rcMenuName.."4"], TalentsIcon_Initialize)
	addon:DDM_Initialize(_G[rcMenuName.."5"], AuctionIcon_Initialize)
	addon:DDM_Initialize(_G[rcMenuName.."6"], MailIcon_Initialize)
	addon:DDM_Initialize(_G[rcMenuName.."7"], SpellbookIcon_Initialize)
	addon:DDM_Initialize(_G[rcMenuName.."8"], ProfessionsIcon_Initialize)
	
	-- Left Menu
	_G[parent .. "Text1"]:SetText(L["Realm"])
	
	-- ** Characters / Equipment / Reputations / Currencies **
	addon:SetItemButtonTexture(parent .. "_Characters", ICON_CHARACTERS, size, size)
	_G[parent .. "_Characters"].text = L["Characters"]
	
	addon:RegisterMessage("DATASTORE_RECIPES_SCANNED")
end

function addon:DATASTORE_RECIPES_SCANNED(event, sender, tradeskillName)
	addon.TradeSkills.Recipes:InvalidateView()
end
