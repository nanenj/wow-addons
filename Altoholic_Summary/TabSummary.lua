local addonName = "Altoholic"
local addon = _G[addonName]

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local GREEN		= "|cFF00FF00"

local parent = "AltoholicTabSummary"
local rcMenuName = parent .. "RightClickMenu"	-- name of right click menu frames (add a number at the end to get it)

local THISREALM_THISACCOUNT = 1
local THISREALM_ALLACCOUNTS = 2
local ALLREALMS_THISACCOUNT = 3
local ALLREALMS_ALLACCOUNTS = 4

local currentMode

local childrenFrames = {
	"Summary",
	"BagUsage",
	"Skills",
	"Activity",
}

local childrenObjects		-- these are the tables that actually contain the BuildView & Update methods. Not really OOP, but enough for our needs

addon.Tabs.Summary = {}

local ns = addon.Tabs.Summary		-- ns = namespace

local locationLabels = {
	[THISREALM_THISACCOUNT] = format("%s %s(%s)", L["This realm"], GREEN, L["This account"]),
	[THISREALM_ALLACCOUNTS] = format("%s %s(%s)", L["This realm"], GREEN, L["All accounts"]),
	[ALLREALMS_THISACCOUNT] = format("%s %s(%s)", L["All realms"], GREEN, L["This account"]),
	[ALLREALMS_ALLACCOUNTS] = format("%s %s(%s)", L["All realms"], GREEN, L["All accounts"]),
}

local function OnRealmFilterChange(self)
	UIDropDownMenu_SetSelectedValue(AltoholicTabSummary_SelectLocation, self.value);
	
	addon:SetOption("TabSummaryMode", self.value)
	addon.Characters:BuildList()
	addon.Characters:BuildView()
	ns:Refresh()
end

local function DropDownLocation_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	
	info.text = locationLabels[THISREALM_THISACCOUNT]
	info.value = THISREALM_THISACCOUNT
	info.func = OnRealmFilterChange
	info.checked = nil; 
	info.icon = nil; 
	UIDropDownMenu_AddButton(info, 1); 	
	
	info.text = locationLabels[THISREALM_ALLACCOUNTS]
	info.value = THISREALM_ALLACCOUNTS
	info.func = OnRealmFilterChange
	info.checked = nil; 
	info.icon = nil; 
	UIDropDownMenu_AddButton(info, 1); 	
	
	info.text = locationLabels[ALLREALMS_THISACCOUNT]
	info.value = ALLREALMS_THISACCOUNT
	info.func = OnRealmFilterChange
	info.checked = nil; 
	info.icon = nil; 
	UIDropDownMenu_AddButton(info, 1); 	

	info.text = locationLabels[ALLREALMS_ALLACCOUNTS]
	info.value = ALLREALMS_ALLACCOUNTS
	info.func = OnRealmFilterChange
	info.checked = nil; 
	info.icon = nil; 
	UIDropDownMenu_AddButton(info, 1); 	
end

function ns:MenuItem_OnClick(id)
	childrenObjects = childrenObjects or {
		addon.Summary,
		addon.BagUsage,
		addon.TradeSkills,
		addon.Activity,
	}

	for _, v in pairs(childrenFrames) do			-- hide all frames
		_G[ "AltoholicFrame" .. v]:Hide()
	end

	ns:SetMode(id)
	
	local f = _G[ "AltoholicFrame" .. childrenFrames[id]]
	local o = childrenObjects[id]
	
	if o.BuildView then
		o:BuildView()
	end
	f:Show()
	o:Update()
	
	for i=1, #childrenFrames do 
		_G[ "AltoholicTabSummaryMenuItem"..i ]:UnlockHighlight();
	end
	_G[ "AltoholicTabSummaryMenuItem"..id ]:LockHighlight();
end

function ns:SetMode(mode)
	currentMode = mode
	
	AltoholicTabSummaryStatus:SetText("")
	AltoholicTabSummaryToggleView:Show()
	AltoholicTabSummary_SelectLocation:Show()
	AltoholicTabSummary_RequestSharing:Show()
	AltoholicTabSummary_Options:Show()
	AltoholicTabSummary_OptionsDataStore:Show()
	
	local Columns = addon.Tabs.Columns
	Columns:Init()
	
	local title

	if currentMode == 1 then
		Columns:Add(NAME, 100, function(self) addon.Characters:Sort(self, "GetCharacterName") end)
		Columns:Add(LEVEL, 60, function(self) addon.Characters:Sort(self, "GetCharacterLevel")	end)
		Columns:Add(MONEY, 115, function(self)	addon.Characters:Sort(self, "GetMoney") end)
		Columns:Add(PLAYED, 105, function(self) addon.Characters:Sort(self, "GetPlayTime") end)
		Columns:Add(XP, 55, function(self) addon.Characters:Sort(self, "GetXPRate") end)
		Columns:Add(TUTORIAL_TITLE26, 70, function(self) addon.Characters:Sort(self, "GetRestXPRate") end)
		Columns:Add("AiL", 55, function(self) addon.Characters:Sort(self, "GetAverageItemLevel")	end)
	
	elseif currentMode == 2 then
		Columns:Add(NAME, 100, function(self) addon.Characters:Sort(self, "GetCharacterName") end)
		Columns:Add(LEVEL, 60, function(self) addon.Characters:Sort(self, "GetCharacterLevel") end)
		Columns:Add(L["Bags"], 120, function(self) addon.Characters:Sort(self, "GetNumBagSlots") end)
		Columns:Add(L["free"], 50, function(self) addon.Characters:Sort(self, "GetNumFreeBagSlots") end)
		Columns:Add(L["Bank"], 190, function(self) addon.Characters:Sort(self, "GetNumBankSlots") end)
		Columns:Add(L["free"], 50, function(self)	addon.Characters:Sort(self, "GetNumFreeBankSlots")	end)
		
	elseif currentMode == 3 then
		Columns:Add(NAME, 100, function(self) addon.Characters:Sort(self, "GetCharacterName") end)
		Columns:Add(LEVEL, 60, function(self) addon.Characters:Sort(self, "GetCharacterLevel") end)
		Columns:Add(L["Prof. 1"], 65, function(self) addon.Characters:Sort(self, "skillName1") end)
		Columns:Add(L["Prof. 2"], 65, function(self) addon.Characters:Sort(self, "skillName2") end)
		title = GetSpellInfo(2550)		-- cooking
		Columns:Add(title, 65, function(self) addon.Characters:Sort(self, "GetCookingRank") end)
		title = GetSpellInfo(3273)		-- First Aid
		Columns:Add(title, 65, function(self) addon.Characters:Sort(self, "GetFirstAidRank") end)
		title = GetSpellInfo(131474)	-- Fishing
		Columns:Add(title, 65, function(self) addon.Characters:Sort(self, "GetFishingRank") end)
		title = string.sub(GetSpellInfo(78670), 1, 4)	-- Archaeology
		Columns:Add(title, 65, function(self) addon.Characters:Sort(self, "GetArchaeologyRank") end)
		
	elseif currentMode == 4 then
		Columns:Add(NAME, 100, function(self) addon.Characters:Sort(self, "GetCharacterName") end)
		Columns:Add(LEVEL, 60, function(self) addon.Characters:Sort(self, "GetCharacterLevel") end)
		Columns:Add(L["Mails"], 60, function(self) addon.Characters:Sort(self, "GetNumMails") end)
		Columns:Add(L["Visited"], 60, function(self) addon.Characters:Sort(self, "GetMailboxLastVisit") end)
		Columns:Add(AUCTIONS, 70, function(self) addon.Characters:Sort(self, "GetNumAuctions") end)
		Columns:Add(BIDS, 60, function(self) addon.Characters:Sort(self, "GetNumBids") end)
		Columns:Add(L["Visited"], 60, function(self) addon.Characters:Sort(self, "GetAuctionHouseLastVisit") end)
		Columns:Add(LASTONLINE, 90, function(self) addon.Characters:Sort(self, "GetLastLogout") end)
	end
end

function ns:Refresh()
	if AltoholicFrameSummary:IsVisible() then
		addon.Summary:Update()
	elseif AltoholicFrameBagUsage:IsVisible() then
		addon.BagUsage:Update()
	elseif AltoholicFrameSkills:IsVisible() then
		addon.TradeSkills:Update()
	elseif AltoholicFrameActivity:IsVisible() then
		addon.Activity:Update()
	end
end

function ns:ToggleView(frame)
	if not frame.isCollapsed then
		frame.isCollapsed = true
		AltoholicTabSummaryToggleView:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
	else
		frame.isCollapsed = nil
		AltoholicTabSummaryToggleView:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up"); 
	end

	if (currentMode >= 1) and (currentMode <= 4) then
		addon.Characters:ToggleView(frame)
		ns:Refresh()
	end
end

function ns:AccountSharingButton_OnEnter(self)
	AltoTooltip:SetOwner(self, "ANCHOR_RIGHT")
	AltoTooltip:ClearLines()
	AltoTooltip:SetText(L["Account Sharing Request"])
	AltoTooltip:AddLine(L["Click this button to ask a player\nto share his entire Altoholic Database\nand add it to your own"],1,1,1)
	AltoTooltip:Show()
end

function ns:AccountSharingButton_OnClick()
	if addon:GetOption("AccSharingHandlerEnabled") == 0 then
		addon:Print(L["Both parties must enable account sharing\nbefore using this feature (see options)"])
		return
	end
	addon:ToggleUI()
	
	if AltoAccountSharing_SendButton.requestMode then
		addon.Comm.Sharing:SetMode(2)
	else
		addon.Comm.Sharing:SetMode(1)
	end
	AltoAccountSharing:Show()
end


local DDM_Add = addon.Helpers.DDM_Add
local DDM_AddTitle = addon.Helpers.DDM_AddTitle
local DDM_AddCloseMenu = addon.Helpers.DDM_AddCloseMenu
local NUM_RC_MENUS = 2

-- ** Icon events **
local function ShowOptionsCategory(self)
	addon:ToggleUI()
	InterfaceOptionsFrame_OpenToCategory(self.value)
end

-- ** Menu Icons **
function ns:Icon_OnEnter(frame)
	local currentMenuID = frame:GetID()
	
	-- hide all
	for i = 1, NUM_RC_MENUS do
		if i ~= currentMenuID and _G[ rcMenuName .. i ].visible then
			ToggleDropDownMenu(1, nil, _G[ rcMenuName .. i ], frame:GetName(), 0, -5);	
			_G[ rcMenuName .. i ].visible = false
		end
	end

	-- show current
	ToggleDropDownMenu(1, nil, _G[ rcMenuName .. currentMenuID ], frame:GetName(), 0, -5);	
	_G[ rcMenuName .. currentMenuID ].visible = true
end

local function AltoholicOptionsIcon_Initialize(self, level)
	DDM_AddTitle(format("%s: %s", GAMEOPTIONS_MENU, addonName))

	DDM_Add(GENERAL, AltoholicGeneralOptions, ShowOptionsCategory)
	DDM_Add(L["Calendar"], AltoholicCalendarOptions, ShowOptionsCategory)
	DDM_Add(MAIL_LABEL, AltoholicMailOptions, ShowOptionsCategory)
	DDM_Add(MISCELLANEOUS, AltoholicMiscOptions, ShowOptionsCategory)
	DDM_Add(SEARCH, AltoholicSearchOptions, ShowOptionsCategory)
	DDM_Add(L["Tooltip"], AltoholicTooltipOptions, ShowOptionsCategory)
	
	DDM_AddTitle(" ")	
	DDM_AddTitle(OTHER)	
	DDM_Add("What's new?", AltoholicWhatsNew, ShowOptionsCategory)
	DDM_Add("Getting support", AltoholicSupport, ShowOptionsCategory)
	DDM_Add(L["Memory used"], AltoholicMemoryOptions, ShowOptionsCategory)
	DDM_Add(HELP_LABEL, AltoholicHelp, ShowOptionsCategory)
	DDM_AddCloseMenu()
end

local addonList = {
	"DataStore_Auctions",
	"DataStore_Characters",
	"DataStore_Inventory",
	"DataStore_Mails",
	"DataStore_Quests",
}

local function DataStoreOptionsIcon_Initialize(self, level)
	DDM_AddTitle(format("%s: %s", GAMEOPTIONS_MENU, "DataStore"))
	
	for _, module in ipairs(addonList) do
		if _G[module] then	-- only add loaded modules
			DDM_Add(module, module, ShowOptionsCategory)
		end
	end
	
	DDM_AddTitle(" ")	
	DDM_Add(HELP_LABEL, DataStoreHelp, ShowOptionsCategory)
	DDM_AddCloseMenu()
end

function ns:OnLoad()
	AltoholicTabSummaryMenuItem1:SetText(L["Account Summary"])
	AltoholicTabSummaryMenuItem2:SetText(L["Bag Usage"])
	AltoholicTabSummaryMenuItem4:SetText(L["Activity"])
	AltoholicTabSummary_RequestSharing:SetText(L["Account Sharing"])

	addon:DDM_Initialize(_G[rcMenuName.."1"], AltoholicOptionsIcon_Initialize)
	addon:DDM_Initialize(_G[rcMenuName.."2"], DataStoreOptionsIcon_Initialize)
	
	local f = AltoholicTabSummary_SelectLocation
	UIDropDownMenu_SetSelectedValue(f, addon:GetOption("TabSummaryMode"))
	UIDropDownMenu_SetText(f, select(addon:GetOption("TabSummaryMode"), locationLabels[THISREALM_THISACCOUNT], locationLabels[THISREALM_ALLACCOUNTS], locationLabels[ALLREALMS_THISACCOUNT], locationLabels[ALLREALMS_ALLACCOUNTS]))
	addon:DDM_Initialize(f, DropDownLocation_Initialize)
end
