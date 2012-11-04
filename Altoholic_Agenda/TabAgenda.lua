local addonName = "Altoholic"
local addon = _G[addonName]

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local GREEN		= "|cFF00FF00"

local parent = "AltoholicTabAgenda"

local currentMode

local childrenFrames = {
	"Calendar",
	"Contacts",
}

local childrenObjects = {}		-- these are the tables that actually contain the BuildView & Update methods. Not really OOP, but enough for our needs

addon.Tabs.Agenda = {}

local ns = addon.Tabs.Agenda		-- ns = namespace

function ns:MenuItem_OnClick(id)

	for _, v in pairs(childrenFrames) do			-- hide all frames
		if _G[ "AltoholicFrame" .. v] then
			_G[ "AltoholicFrame" .. v]:Hide()
		end
	end

	ns:SetMode(id)
	
	local f = _G[ "AltoholicFrame" .. childrenFrames[id]]
	local o = childrenObjects[id]
	
	if o.BuildView then
		o:BuildView()
	end
	f:Show()
	o:Update()
	
	for i=1, 5 do 
		_G[ parent .. "MenuItem"..i ]:UnlockHighlight();
	end
	_G[ parent .. "MenuItem"..id ]:LockHighlight();
end

function ns:SetMode(mode)
	currentMode = mode
	
	-- AltoholicTabSummaryStatus:SetText("")
	-- AltoholicTabSummaryToggleView:Show()
	-- AltoholicTabSummary_SelectLocation:Show()
	-- AltoholicTabSummary_RequestSharing:Show()
	-- AltoholicTabSummary_Options:Show()
	-- AltoholicTabSummary_OptionsDataStore:Show()

	-- if currentMode == 1 then
	-- elseif currentMode == 2 then
	-- elseif currentMode == 3 then
	-- elseif currentMode == 4 then
	-- elseif currentMode == 5 then
	-- end
end

function ns:Refresh()
	if AltoholicFrameCalendar:IsVisible() then
		addon.Calendar:Update()
	elseif AltoholicFrameContacts:IsVisible() then
		addon.Contacts:Update()
	end
end

function ns:RegisterChildPane(pane)
	table.insert(childrenObjects, pane)
end

function ns:OnLoad()
	_G[ parent .. "MenuItem1"]:SetText(L["Calendar"])
	_G[ parent .. "MenuItem2"]:SetText("Contacts")
	_G[ parent .. "MenuItem3"]:SetText("Tasks")
	_G[ parent .. "MenuItem4"]:SetText("Notes")
	_G[ parent .. "MenuItem5"]:SetText("Mail")
	
	addon:RegisterMessage("DATASTORE_ITEM_COOLDOWN_UPDATED")
	addon:RegisterMessage("DATASTORE_CALENDAR_SCANNED")
end

function addon:DATASTORE_ITEM_COOLDOWN_UPDATED(event, itemID)
	addon.Calendar:InvalidateView()
	ns:Refresh()
end

function addon:DATASTORE_CALENDAR_SCANNED(event)
	addon.Calendar:InvalidateView()
	ns:Refresh()
end
