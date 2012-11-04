local addonName = "Altoholic"
local addon = _G[addonName]

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local WHITE		= "|cFFFFFFFF"
local TEAL		= "|cFF00FF9A"
local GREEN		= "|cFF00FF00"
local YELLOW	= "|cFFFFFF00"


local parent = "AltoholicTabGuild"
local currentMode
local childrenObjects		-- these are the tables that actually contain the BuildView & Update methods. Not really OOP, but enough for our needs
local childrenFrames = {
	"GuildMembers",
	"GuildBank",
}

addon.Guild = {}
addon.Tabs.Guild = {}

local ns = addon.Tabs.Guild		-- ns = namespace

local function OnRosterUpdate()
	local _, onlineMembers = GetNumGuildMembers()
	_G[parent .. "MenuItem1"]:SetText(format("%s %s(%d)", L["Guild Members"], GREEN, onlineMembers))
	
	addon.Guild.Members:InvalidateView()
end

function ns:OnLoad()

	-- localization stuff
	_G[parent .. "MenuItem1"]:SetText(L["Guild Members"])
	_G[parent .. "MenuItem1"]:Show()
	_G[parent .. "MenuItem2"]:SetText(GUILD_BANK)
	_G[parent .. "MenuItem2"]:Show()
	
	-- register datastore events
	addon:RegisterMessage("DATASTORE_GUILD_ALTS_RECEIVED")

	addon:RegisterMessage("DATASTORE_BANKTAB_REQUEST_ACK")
	addon:RegisterMessage("DATASTORE_BANKTAB_REQUEST_REJECTED")
	addon:RegisterMessage("DATASTORE_BANKTAB_UPDATE_SUCCESS")
	addon:RegisterMessage("DATASTORE_GUILD_MEMBER_OFFLINE")
	
	if IsInGuild() then
		addon:RegisterEvent("GUILD_ROSTER_UPDATE", OnRosterUpdate);
	end
end

function ns:OnShow()
	if not currentMode then
		childrenObjects = {
			addon.Guild.Members,
			addon.Guild.Bank,
		}
		
		ns:MenuItem_OnClick(1)
	end
end

function ns:SetMode(mode)
	currentMode = mode

	local Columns = addon.Tabs.Columns
	Columns:Init()
	
	if mode == 1 then
		Columns:Add(NAME, 100, function(self) addon.Guild.Members:Sort(self, "name") end)
		Columns:Add(LEVEL, 60, function(self) addon.Guild.Members:Sort(self, "level") end)
		Columns:Add("AiL", 65, function(self) addon.Guild.Members:Sort(self, "averageItemLvl") end)
		Columns:Add(GAME_VERSION_LABEL, 80, function(self) addon.Guild.Members:Sort(self, "version") end)
		Columns:Add(CLASS, 100, function(self) addon.Guild.Members:Sort(self, "englishClass") end)
		return
	end

end

function ns:MenuItem_OnClick(id)
	for _, v in pairs(childrenFrames) do			-- hide all frames
		_G[ "AltoholicFrame" .. v]:Hide()
	end

	ns:SetMode(id)
	
	_G[ "AltoholicFrame" .. childrenFrames[id]]:Show()
	childrenObjects[id]:Update()

	for i = 1, 2 do 
		_G[ parent .. "MenuItem"..i ]:UnlockHighlight();
	end
	_G[ parent .. "MenuItem"..id ]:LockHighlight();
end

-- *** DataStore Event Handlers ***
function addon:DATASTORE_GUILD_ALTS_RECEIVED(event, sender, alts)
	addon.Guild.Members:InvalidateView()
end

function addon:DATASTORE_BANKTAB_REQUEST_ACK(event, sender)
	addon:Print(format(L["Waiting for %s to accept .."], sender))
end

function addon:DATASTORE_BANKTAB_REQUEST_REJECTED(event, sender)
	addon:Print(format(L["Request rejected by %s"], sender))
end

function addon:DATASTORE_BANKTAB_UPDATE_SUCCESS(event, sender, guildName, tabName, tabID)
	addon:Print(format(L["Guild bank tab %s successfully updated !"], tabName ))
	addon.Guild.Bank:Update()
end

function addon:DATASTORE_GUILD_MEMBER_OFFLINE(event, member)
	addon.Guild.Members:InvalidateView()
end
