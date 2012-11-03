--[[
	Auctioneer
	Version: 5.15.5365 (LikeableLyrebird)
	Revision: $Id: CoreMain.lua 5361 2012-09-21 10:54:27Z brykrys $
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
]]


--[[
	See CoreAPI.lua for a description of the modules API
]]
local AucAdvanced = AucAdvanced
if not AucAdvanced then return end

if (not AucAdvancedData) then AucAdvancedData = {} end
if (not AucAdvancedLocal) then AucAdvancedLocal = {} end
if (not AucAdvancedConfig) then AucAdvancedConfig = {} end

local _, internal = AucAdvanced.GetCoreModule() -- Don't need a module but do need the addon internal storage area.


-- For our modular stats system, each stats engine should add their
-- subclass to AucAdvanced.Modules.<type>.<name> and store their data into their own
-- data table in AucAdvancedData.Stats.<type><name>
if (not AucAdvanced.Modules) then AucAdvanced.Modules = {Filter={}, Match={}, Stat={}, Util={}} end
if (not AucAdvancedData.Stats) then AucAdvancedData.Stats = {} end
if (not AucAdvancedLocal.Stats) then AucAdvancedLocal.Stats = {} end

-- Load DebugLib
local DebugLib = LibStub("DebugLib")

local tooltip
local ALTCHATLINKTOOLTIP_OPEN
local ScheduleMessage -- function("event", delay)

local function OnTooltip(calltype, tip, hyperlink, quantity, name, quality)
	if InCombatLockdown() and not AucAdvanced.Settings.GetSetting("core.tooltip.enableincombat") then return end
	if not tip then return end
	local ModTTShow = AucAdvanced.Settings.GetSetting("ModTTShow")
	if ModTTShow then
		if ModTTShow == "never" then
			return
		elseif ModTTShow == "noalt" and IsAltKeyDown() then
			return
		elseif ModTTShow == "alt" and not IsAltKeyDown() then
			return
		elseif ModTTShow == "noshift" and IsShiftKeyDown() then
			return
		elseif ModTTShow == "shift" and not IsShiftKeyDown() then
			return
		elseif ModTTShow == "noctrl" and IsControlKeyDown() then
			return
		elseif ModTTShow == "ctrl" and not IsControlKeyDown() then
			return
		end
	else
		AucAdvanced.Settings.SetSetting("ModTTShow", "always")
	end

	local decoded = {}
	local linkType = AucAdvanced.DecodeLink(hyperlink, decoded)
	if linkType ~= calltype then -- bad link or mismatched link type
		return
	end

	tooltip:SetFrame(tip)
	local additional = tooltip:GetExtra()
	quantity = tonumber(quantity) or 1

	-- Check to see if we need to load scandata
	if AucAdvanced.Settings.GetSetting("scandata.tooltip.display") then
		AucAdvanced.Scan.LoadScanData()
	end

	local saneLink = AucAdvanced.SanitizeLink(hyperlink)

	tooltip:SetColor(0.3, 0.9, 0.8)
	tooltip:SetMoneyAsText(false)
	tooltip:SetEmbed(false)

	local modules = AucAdvanced.GetAllModules()

	if AucAdvanced.Settings.GetSetting("tooltip.marketprice.show") then
		local L = AucAdvanced.localizations
		local market, seen = AucAdvanced.API.GetMarketValue(saneLink)
		if not market then
			tooltip:AddLine(L"ADV_Interface_MarketPrice" ..": ".. L"ADV_Tooltip_NotAvailable")--Market Price // Not Available
		else
			if seen and seen > 0 then
				tooltip:AddLine(L"ADV_Interface_MarketPrice" ..": "..format(L"ADV_Tooltip_SeenBrackets", tostring(seen)), market)--Market Price // (seen %s)
			else
				tooltip:AddLine(L"ADV_Interface_MarketPrice", market) --Market Price
			end
			if ((quantity > 1) and AucAdvanced.Settings.GetSetting("tooltip.marketprice.stacksize")) then
				tooltip:AddLine(L"ADV_Interface_MarketPrice" .." x"..tostring(quantity)..": ", market*quantity) --Market Price
			end
		end

		if IsShiftKeyDown() then
			for pos, engineLib in ipairs(modules) do
				if engineLib.GetItemPDF then
					local price
					if engineLib.GetPriceSeen then
						price = engineLib.GetPriceSeen(saneLink)
					end
					if not price and engineLib.GetPriceArray then
						local pricearray = engineLib.GetPriceArray(saneLink)
						if pricearray then
							price = pricearray.price
						end
					end
					if price and price > 0 then
						local text = format(L"ADV_Interface_Algorithm_Price", engineLib.GetLocalName()) --%s Price
						if quantity == 1 then
							tooltip:AddLine("  "..text..":", price)
						else
							tooltip:AddLine("  "..text.." x"..tostring(quantity)..":", price*quantity)
						end
					end
				end
			end
		end
	end

	if calltype == "item" then
		--[[
		In future there will be support for issuing multiple Processor messages with different serverKeys
		Modules whose tooltip display depends on a serverKey (i.e. most pricing modules) must use the provided serverKey for each message
			if the module does not support that particular serverKey the message should be ignored
		Modules whose tooltip does not depend on serverKey should check the order parameter to ensure they don't duplicate their output in the tooltip
			usually they would only respond when order == 1
		]]
		local serverKey = AucAdvanced.Resources.ServerKeyCurrent
		local order = 1
		AucAdvanced.SendProcessorMessage("itemtooltip", tooltip, hyperlink, serverKey, quantity, decoded, additional, order)

		-- Old-style "tooltip" message - Deprecated
		local extra = AucAdvanced.Replicate(additional) -- replicate it so we don't change the original table
		for k, v in pairs(decoded) do extra[k] = v end
		local cost
		if extra.event == "SetLootItem" then
			cost = extra.price
		elseif extra.event == "SetAuctionItem" then
			cost = extra.bidAmount
			if cost then cost = cost + extra.minIncrement
			else cost = extra.minBid
			end
		end
		AucAdvanced.SendProcessorMessage("tooltip", tooltip, name, hyperlink, quality, quantity, cost, extra)
	elseif calltype == "battlepet" then
		local serverKey = AucAdvanced.Resources.ServerKeyCurrent
		local order = 1
		AucAdvanced.SendProcessorMessage("battlepettooltip", tooltip, hyperlink, serverKey, quantity, decoded, additional, order)
	end
	tooltip:ClearFrame(tip)
end

-- Wrappers used to pass through the different parameters provided by the caller in the correct order for OnTooltip
local function OnItemTooltip(tooltip, item, quantity, name, hyperlink, quality, ilvl, rlvl, itype, isubtype, stack, equiploc, texture)
	return OnTooltip("item", tooltip, hyperlink, quantity, name, quality)
end
local function OnPetTooltip(tooltip, link, quantity, name, speciesID, breedQuality, level)
	return OnTooltip("battlepet", tooltip, link, quantity, name, breedQuality)
end

local function HookClickBag(hookParams, returnValue, self, button, ignoreShift)
	if button == "RightButton" and IsAltKeyDown() and AucAdvanced.Settings.GetSetting("clickhook.enable") then
		if AuctionFrame and AuctionFrameBrowse and AuctionFrameBrowse:IsVisible() then
			local bag = self:GetParent():GetID()
			local slot = self:GetID()
			local link = GetContainerItemLink(bag, slot)
			if link then
				local itemName
				if link:match("item:%d") then
					itemName = GetItemInfo(link)
				else
					itemName = link:match("|Hbattlepet:[^|]+|h%[(.+)%]")
				end
				if itemName then
					AuctionFrameBrowse_Reset(BrowseResetButton)
					AuctionFrameBrowse.page = 0
					BrowseName:SetText(itemName)
					AuctionFrameBrowse_Search()
				end
			end
		end
	end
end

local function HookClickLink(self, item, link, button)
	if button == "RightButton" and IsAltKeyDown() and AucAdvanced.Settings.GetSetting("clickhook.enable") then
		if AuctionFrame and AuctionFrameBrowse and AuctionFrameBrowse:IsVisible() then
			local itemName
			if link:match("item:%d") then
				itemName = GetItemInfo(link)
			else
				itemName = link:match("|Hbattlepet:[^|]+|h%[(.+)%]")
			end
			if itemName then
				AuctionFrameBrowse_Reset(BrowseResetButton)
				AuctionFrameBrowse.page = 0
				BrowseName:SetText(itemName)
				AuctionFrameBrowse_Search()
			end
		end
	end
end

local function HookAltChatLinkTooltip(link, text, button, chatFrame)
	if button == "LeftButton"
	and AucAdvanced.Settings.GetSetting("core.tooltip.altchatlink_leftclick")
	and (link:sub(1, 4) == "item" or link:sub(1, 9) == "battlepet") then
		return ALTCHATLINKTOOLTIP_OPEN
	end
end

local function HookAH()
	Stubby.UnregisterAddOnHook("Blizzard_AuctionUI", "Auc-Advanced")
	hooksecurefunc("AuctionFrameBrowse_Update", AucAdvanced.API.ListUpdate)
	AucAdvanced.SendProcessorMessage("auctionui")
end

local function OnLoad(addon)
	addon = addon:lower()

	-- Check if the actual addon itself is loading
	if addon == "auc-advanced" then
		--updated saved variables format
		internal.Settings.upgradeSavedVariables()

		-- Load the dummy CoreModule
		AucAdvanced.CoreModuleOnLoad(addon)
	end

	-- Look for a matching module
	local auc, sys, eng = strsplit("-", addon)
	local moduleLib
	if auc == "auc" and sys and eng then
		moduleLib = AucAdvanced.GetModule(sys, eng)
	end
	if not moduleLib then
		moduleLib = internal.Util.GetModuleForName(addon)
	end

	-- Notify the actual module if it exists
	if moduleLib and moduleLib.OnLoad then
		moduleLib.OnLoad(addon)
	end

	-- Notify all processors that an auctioneer addon has loaded
	if moduleLib or (auc == "auc" and sys and #sys > 0) then -- identify names in both "auc-name" and "auc-system-name" formats
		AucAdvanced.SendProcessorMessage("load", addon)
	end

	-- Check all modules' load triggers and pass event to processors
	local modules = AucAdvanced.GetAllModules("LoadTriggers")
	for pos, engineLib in ipairs(modules) do
		if engineLib.LoadTriggers[addon] then
			if (engineLib.OnLoad) then
				engineLib.OnLoad(addon)
			end
		end
	end

	if moduleLib then
		internal.Util.SendModuleCallbacks(moduleLib)
	end

	if addon == "auc-advanced" then
		for pos, module in ipairs(AucAdvanced.EmbeddedModules) do
			-- These embedded modules have also just been loaded
			OnLoad(module)
		end
	end
end

local function OnUnload()
	local modules = AucAdvanced.GetAllModules("OnUnload")
	for pos, engineLib in ipairs(modules) do
		engineLib.OnUnload()
	end
end

local function OnEnteringWorld(frame)
	frame:UnregisterEvent("PLAYER_ENTERING_WORLD") -- we only want the first instance of this event
	OnEnteringWorld = nil

	if not AucAdvanced or AucAdvanced.ABORTLOAD then
		-- something's gone wrong - silently abort loading (any error should have been reported elsewhere)
		return
	end

	frame:RegisterEvent("ITEM_LOCK_CHANGED")
	frame:RegisterEvent("BAG_UPDATE")
	-- Following items are for experimental scan processor modifications
	frame:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
	frame:RegisterEvent("AUCTION_OWNED_LIST_UPDATE")

	Stubby.RegisterAddOnHook("Blizzard_AuctionUI", "Auc-Advanced", HookAH)
	Stubby.RegisterFunctionHook("ContainerFrameItemButton_OnModifiedClick", -200, HookClickBag)
	hooksecurefunc("ChatFrame_OnHyperlinkShow", HookClickLink)

	tooltip = AucAdvanced.GetTooltip()
	tooltip:Activate()
	tooltip:AddCallback({type = "item", callback = OnItemTooltip}, 600)
	tooltip:AddCallback({type = "battlepet", callback = OnPetTooltip}, 600)
	tooltip:AltChatLinkRegister(HookAltChatLinkTooltip)
	ALTCHATLINKTOOLTIP_OPEN = tooltip:AltChatLinkConstants()

	-- CoreResources must be activated first, in case other modules need to use the resources
	internal.Resources.Activate()

	-- send general activate message
	AucAdvanced.SendProcessorMessage("gameactive")

	if AucAdvanced.Settings.GetSetting("scandata.force") then
		AucAdvanced.Scan.LoadScanData()
	end
end

local function OnEvent(self, event, arg1, arg2, ...)
	if event == "AUCTION_ITEM_LIST_UPDATE" then
		internal.Scan.NotifyItemListUpdated()
	elseif event == "AUCTION_OWNED_LIST_UPDATE" then
		internal.Scan.NotifyOwnedListUpdated()
	elseif (event == "ITEM_LOCK_CHANGED" and arg2) or event == "BAG_UPDATE" then
		if arg1 >= 0 and arg1 <= 4 then
			ScheduleMessage("inventory", 0.05) -- collect multiple events for same bag change using a slight delay
		end
	elseif event == "ADDON_LOADED" then
		OnLoad(arg1)
	elseif event == "PLAYER_LOGOUT" then
		internal.Scan.Logout()
		OnUnload()
	elseif event == "PLAYER_ENTERING_WORLD" then
		OnEnteringWorld(self)
	end
end

local EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("ADDON_LOADED")
EventFrame:RegisterEvent("PLAYER_LOGOUT")
EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
EventFrame:SetScript("OnEvent", OnEvent)

do -- ScheduleMessage handler
	local scheduled = {}
	ScheduleMessage = function(event, delay) -- declared local above
		scheduled[event] = GetTime() + delay
	end
	local function OnUpdate(...)
		if not next(scheduled) then return end
		local now = GetTime()
		for event, trigger in pairs(scheduled) do
			if now >= trigger then
				AucAdvanced.SendProcessorMessage(event, trigger)
				scheduled[event] = nil
			end
		end
	end
	EventFrame:SetScript("OnUpdate", OnUpdate)
end


-- Auctioneer's debug functions
AucAdvanced.Debug = {}
local addonName = "Auctioneer" -- the addon's name as it will be displayed in
                               -- the debug messages
-------------------------------------------------------------------------------
-- Prints the specified message to nLog.
--
-- syntax:
--    errorCode, message = debugPrint([message][, category][, title][, errorCode][, level])
--
-- parameters:
--    message   - (string) the error message
--                nil, no error message specified
--    category  - (string) the category of the debug message
--                nil, no category specified
--    title     - (string) the title for the debug message
--                nil, no title specified
--    errorCode - (number) the error code
--                nil, no error code specified
--    level     - (string) nLog message level
--                         Any nLog.levels string is valid.
--                nil, no level specified
--
-- returns:
--    errorCode - (number) errorCode, if one is specified
--                nil, otherwise
--    message   - (string) message, if one is specified
--                nil, otherwise
-------------------------------------------------------------------------------
function AucAdvanced.Debug.DebugPrint(message, category, title, errorCode, level)
	return DebugLib.DebugPrint(addonName, message, category, title, errorCode, level)
end

-------------------------------------------------------------------------------
-- Used to make sure that conditions are met within functions.
-- If test is false, the error message will be written to nLog and the user's
-- default chat channel.
--
-- Brings the Level parameter into the auctioneer API fold.
AucAdvanced.Debug.Level = DebugLib.Level

-------------------------------------------------------------------------------
-- Used to make sure that conditions are met within functions.
-- If test is false, the error message will be written to nLog and the user's
-- default chat channel.
--
-- syntax:
--    assertion = assert(test, message)
--
-- parameters:
--    test    - (any)     false/nil, if the assertion failed
--                        anything else, otherwise
--    message - (string)  the message which will be output to the user
--
-- returns:
--    assertion - (boolean) true, if the test passed
--                          false, otherwise
-------------------------------------------------------------------------------
function AucAdvanced.Debug.Assert(test, message)
	return DebugLib.Assert(addonName, test, message)
end

AucAdvanced.RegisterRevision("$URL: http://svn.norganna.org/auctioneer/trunk/Auc-Advanced/CoreMain.lua $", "$Rev: 5361 $")
