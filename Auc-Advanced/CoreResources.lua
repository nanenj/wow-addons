--[[
	Auctioneer
	Version: 5.15.5365 (LikeableLyrebird)
	Revision: $Id: CoreResources.lua 5285 2012-04-17 15:45:55Z brykrys $
	URL: http://auctioneeraddon.com/

	This is an addon for World of Warcraft that adds statistical history to the auction data that is collected
	when the auction is scanned, so that you can easily determine what price
	you will be able to sell an item for at auction or at a vendor whenever you
	mouse-over an item in the game

	License:
		This program is free software; you can redistribute it and/or
		modify it under the terms of the GNU General Public License
		as published by the Free Software Foundation; either version 2
		of the License, or (at your option) any later version.

		This program is distributed in the hope that it will be useful,
		but WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
		GNU General Public License for more details.

		You should have received a copy of the GNU General Public License
		along with this program(see GPL.txt); if not, write to the Free Software
		Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

	Note:
		This AddOn's source code is specifically designed to work with
		World of Warcraft's interpreted AddOn system.
		You have an implicit license to use this AddOn with these facilities
		since that is its designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
--]]

--[[
	Dynamic Resource support module

	Maintain a table of commonly used values that may change during play,
	for use in a similar manner to the Const table.
	Other modules or AddOns may read from the Resources table at any time, but must not modify it!

	Includes:
	Status flags for AuctionHouse, Mailbox
	Faction information
	Pre-formed serverKeys

	Additionally, Processor event messages will be generated when certain values change
--]]

local AucAdvanced = AucAdvanced
if not AucAdvanced then return end

local coremodule, internal = AucAdvanced.GetCoreModule("CoreResources")
local Const = AucAdvanced.Const

-- internal constants
local PLAYER_REALM = Const.PlayerRealm
local SELECT_HOME = 1
local SELECT_NEUTRAL = 2
local CUT_HOME = 0.05
local CUT_NEUTRAL = 0.15
local NEUTRAL_MAP_IDS = { -- Reference: http://www.wowpedia.org/MapID
	[161] = true, -- Tanaris
	[281] = true, -- Winterspring
	[673] = true, -- The Cape of Stranglethorn
}
local WATCHED_SETTINGS = {
	["core.general.alwaysHomeFaction"] = true,
	["profile.save"] = true,
	["profile.duplicate"] = true,
	["profile.delete"] = true,
	["profile.default"] = true,
	["profile"] = true,
}

-- internal variables
local EventFrame
local ZoneFactionCache = {}
local LastSelectedFaction
local PlayerCutRate -- will contain CUT_HOME or CUT_NEUTRAL depending on PlayerFaction

-- local references to Globals
local GetZoneText, GetCurrentMapAreaID, GetCurrentMapDungeonLevel = GetZoneText, GetCurrentMapAreaID, GetCurrentMapDungeonLevel
local SetMapByID, SetDungeonMapLevel = SetMapByID, SetDungeonMapLevel

-- Placeholders for local references (filled in by Activate function)
local GetSetting


--[[ Install AucAdvanced.Resources table ]]--
local lib = {
	Active = false,
	AuctionHouseOpen = false,
	MailboxOpen = false,
}
AucAdvanced.Resources = lib


--[[ Faction handlers ]]--
local function UpdateServerKey()
	local factionSelect
	if lib.AuctionHouseOpen or not GetSetting("core.general.alwaysHomeFaction") then
		local currentZone = GetZoneText()
		factionSelect = ZoneFactionCache[currentZone]
		if not factionSelect then
			local lastMapID, lastFloor = GetCurrentMapAreaID(), GetCurrentMapDungeonLevel() -- store old map info
			SetMapToCurrentZone()
			local curMapID, curFloor = GetCurrentMapAreaID(), GetCurrentMapDungeonLevel()
			if NEUTRAL_MAP_IDS[curMapID] then
				factionSelect = SELECT_NEUTRAL
			else
				factionSelect = SELECT_HOME
			end
			if currentZone and currentZone ~= "" then -- only cache if currentZone is valid zone
				ZoneFactionCache[currentZone] = factionSelect
			end
			if curMapID ~= lastMapID or curFloor ~= lastFloor then
				-- restore map info
				SetMapByID(lastMapID)
				SetDungeonMapLevel(lastFloor)
			end
		end
	else
		factionSelect = SELECT_HOME
	end
	if factionSelect ~= LastSelectedFaction then
		local currentFaction, serverKey, cutRate
		if factionSelect == SELECT_NEUTRAL then
			currentFaction = "Neutral"
			serverKey = lib.ServerKeyNeutral
			cutRate = CUT_NEUTRAL
		else -- SELECT_HOME
			currentFaction = lib.PlayerFaction
			serverKey = lib.ServerKeyHome
			cutRate = PlayerCutRate
		end
		LastSelectedFaction = factionSelect

		lib.CurrentFaction = currentFaction
		lib.ServerKeyCurrent = serverKey
		lib.AHCutRate = cutRate
		lib.AHCutAdjust = 1 - cutRate

		-- copy into AucAdvanced for compatibility (### Deprecated ###)
		AucAdvanced.curFactionGroup = currentFaction
		AucAdvanced.curServerKey = serverKey
		AucAdvanced.cutRate = cutRate

		-- notify the change
		AucAdvanced.SendProcessorMessage("serverkey", serverKey)
	end
end

local function SetFaction()
	local playerFaction = UnitFactionGroup("player")
	local opposingFaction
	if playerFaction == "Alliance" then
		opposingFaction = "Horde"
		PlayerCutRate = CUT_HOME
	elseif playerFaction == "Horde" then
		opposingFaction = "Alliance"
		PlayerCutRate = CUT_HOME
	else
		playerFaction = "Neutral" -- just in case it was nil
		opposingFaction = "Neutral"
		PlayerCutRate = CUT_NEUTRAL
	end

	lib.PlayerFaction = playerFaction
	lib.ServerKeyHome = PLAYER_REALM.."-"..playerFaction
	lib.OpposingFaction = opposingFaction
	lib.ServerKeyOpposing = PLAYER_REALM.."-"..opposingFaction

	if playerFaction == "Alliance" or playerFaction == "Horde" then
		SetFaction = nil
	end
end
SetFaction()
-- really a constant, but included in Resources along with other serverKey values:
lib.ServerKeyNeutral = PLAYER_REALM.."-Neutral"
-- it's too early in the load process to call UpdateServerKey; assume home faction for now
lib.ServerKeyCurrent = lib.ServerKeyHome
lib.CurrentFaction = lib.PlayerFaction
lib.AHCutRate = PlayerCutRate
lib.AHCutAdjust = 1 - PlayerCutRate
-- For compatibility (### Deprecated ###)
AucAdvanced.curFactionGroup = lib.PlayerFaction
AucAdvanced.curServerKey = lib.ServerKeyHome
AucAdvanced.cutRate = PlayerCutRate

-- special handling for Pandaren characters, for the moment they choose their faction
local function OnFactionSelect()
	OnFactionSelect = nil
	EventFrame:UnregisterEvent("NEUTRAL_FACTION_SELECT_RESULT")
	if SetFaction then
		SetFaction()
	end
	LastSelectedFaction = nil -- force an update
	UpdateServerKey()
	AucAdvanced.SendProcessorMessage("factionselect", lib.PlayerFaction)
end

--[[ Event handlers and other entry points ]]--
local function OnEvent(self, event, ...)
	if event == "AUCTION_HOUSE_SHOW" then
		lib.AuctionHouseOpen = true
		UpdateServerKey()
		AucAdvanced.SendProcessorMessage("auctionopen")
	elseif event == "AUCTION_HOUSE_CLOSED" then
		-- AUCTION_HOUSE_CLOSED usually fires twice; only send message for the first one
		if lib.AuctionHouseOpen then
			lib.AuctionHouseOpen = false
			UpdateServerKey()
			AucAdvanced.SendProcessorMessage("auctionclose")
			internal.Scan.AHClosed()
		end
	elseif event == "MAIL_SHOW" then
		lib.MailboxOpen = true
		AucAdvanced.SendProcessorMessage("mailopen")
	elseif event == "MAIL_CLOSED" then
		-- MAIL_CLOSED usually fires twice; only send message for the first one
		if lib.MailboxOpen then
			lib.MailboxOpen = false
			AucAdvanced.SendProcessorMessage("mailclose")
		end
	elseif event == "ZONE_CHANGED_NEW_AREA" then
		-- used to update the current serverKey when entering a zone containing a Neutral AH
		-- (if the user has not enabled the 'Always Home Faction' option)
		UpdateServerKey()
	elseif event == "NEUTRAL_FACTION_SELECT_RESULT" then
		-- triggered when a neutral Pandaren character chooses a Faction
		OnFactionSelect()
	end
end

coremodule.Processors = {
	configchanged = function(callbackType, setting, value)
		if WATCHED_SETTINGS[setting] then
			UpdateServerKey()
		end
	end,
}

internal.Resources = {
	-- Activate: called by CoreMain near the end of the load process
	-- (expected to be during PLAYER_ENTERING_WORLD or later)
	Activate = function()
		internal.Resources.Activate = nil -- only run once
		lib.Active = true

		-- Store local references to common functions (that weren't available at initial load time)
		GetSetting = AucAdvanced.Settings.GetSetting

		-- Setup Event handler
		EventFrame = CreateFrame("Frame")
		EventFrame:SetScript("OnEvent", OnEvent)
		EventFrame:RegisterEvent("AUCTION_HOUSE_SHOW")
		EventFrame:RegisterEvent("AUCTION_HOUSE_CLOSED")
		EventFrame:RegisterEvent("MAIL_SHOW")
		EventFrame:RegisterEvent("MAIL_CLOSED")
		EventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

		-- Set faction info
		if SetFaction then
			SetFaction()
		end
		if SetFaction then
			-- player is Neutral faction; register to detect when they choose a faction
			EventFrame:RegisterEvent("NEUTRAL_FACTION_SELECT_RESULT")
		else
			OnFactionSelect = nil
		end
		UpdateServerKey()
	end,
}
