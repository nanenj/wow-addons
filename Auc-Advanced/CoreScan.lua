--[[
	Auctioneer
	Version: 5.15.5365 (LikeableLyrebird)
	Revision: $Id: CoreScan.lua 5352 2012-09-14 13:17:35Z brykrys $
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
	Auctioneer Scanning Engine.

	Provides a service to walk through an AH Query, reporting changes in the AH to registered utilities and stats modules

	System Overview

		Overloads function QueryAuctionItems.
			when called checks to see if a scan is in progress.
			If we are currently in a scan, store the last recieved page if not saved just in case (shouldn't be necessary).
			Scrubs parameters for when called directly to keep D/Cs from happening (like Blizzard does via UI)
			If in a scan and the current call doesn't match it, commits current scan.
			Else if not in a scan, record the start of a new scan including whether a manual or automated scan.
			if first page of scan, indicate to all clients that a scan has started.
			calls original Blizzard QueryAuctionItems.

		We add a listener on the AH window, and fire every frame it is opened.
			If commit coroutine is asleep, resume it.
			If commit routine is dead and there are scans needing committed, wake it up.
			If current scan is paused or an error occurs, exit out of routine to cut loading on system.
			If scans are queued and we are not currently active scanning, start the next scan and exit.
			If an ah request has been sent and we haven't started to store page, exit if if know data isn't ready to be stored.
			If a store routine is going and is suspended, restart it (if been stopped long enough)
			If it is time to get the next page in an automated scan, send the next page query and exit.
			If AH is open and we were unexpected closed earlier, restart last scan here and exit.
			If AH is open and we made it here start to Store last page recieved.
			IF AH is not open, pause the current scan and put it on the scan stack.

		Storing a Page.
			When a store page is requested, it starts a coroutine.  The coroutine is responsible for all work.
			Note: store page keeps verifying throughout that store hasn't been requested to stop.  It exits immediately if it has.
			Also, this area uses defaults for items from GetItemInfo instead of calling for each auction.
			If a getAll scan, turn off updating of AH Windows.
			Updates scan processors that the page is being stored.
			skips walking through and storing auctions if page isn't later than pages already done.
			walks through all auctions returned.  If data is ready, stores it in page store.  If not, records location # in retry list.
			while retry list has items and retries left is greater than 0, do following
				pauses for 1 second
				decrement retries left
				walks through all auctions in retries list.
					If data is ready, stores it in page store and resets retry count to max.
					If not, records location # in newRetry list.
				replaces retry list with newRetry list.

			add the items to the scan store and record what the next page we need is.
			if isGetAll, put AH Window back in normal state.
			otherwise if an automated scan and there are more pages, start the scan of the next page.
			otherwise if an automated scan then Commit the scan.
			otherwise if a manual scan and on the last page, commit the scan.

			this routine means that a page store can take up to NumActionsOnPage*RetryCount seconds to complete
			for a default page, that is 5 minutes.  For a getall, it could take forever.
			In practice, it adds up to 15 seconds to what already happens for a regular page, and 5 minutes for getAll.

		Committing a scan.
			the commit routine is responsible for storing the scan store into a list and then starting a coroutine (if not already running) that can commit it.
			The coroutine runs in a loop until there are no more items in the commit queue.
			Pull first item from commit queue.

			Stage 1.  Pre-Process new scan. Retrieve item info
			While itemlink lookup has entries and retry count not 0
				create empty next itemlink lookup table
				decrement retry count
				Walk through items in itemlink lookup
					call GetItemInfo for item
					If GetItemInfo returns data
						walk through auction list and fix up data returned for each.
						reset retry count to max.
					else add item to next itemLink lookup
				replace itemlink lookup with next itemLink lookup
			if there are still items in itemlink lookup
				walk scan table from back to front, and remove any item with an ILEVEL of -1
				mark scan an an incomplete scan.


			Stage 2.  Prep AH Image
				mark all auctions in auction house image that match current scan as still needing resolved against scan
				mark all auctions in auction house image that don't match current scan as NOT needing resolved against scan
				build a look-up table for the next stage

			Stage 3.  Merge new scan with AH Image
				walk through all items in new scan.
				if a match is found in AH Image that still needs resolved
					if auction in AH Image was not filtered then
						check if AH exactly matches current info.
						if not, then send 'update' processor message.
						otherwise send 'leave' processor message.
					update item in AH Image from scan info and mark entry as resolved.
				otherwise
					send 'filter' processor message.
					If no filters indicate auction to be filtered, then
						send 'create' processor message.
					otherwise
						add flag to auction to indicate it is filtered.
					add auction to AH Image.

			Stage 4.  Remove unseen from AH Image
				walk through all items in AH Image
				if needs resolved then
					if expired, then remove from image, sending 'delete' processor message
					otherwise if not expired and a complete scan, remove from image, sending 'delete' process message
					otherwise if flagged unseen prior scan, remove from image sending 'delete' processor message
					otherwise mark unseen in AH Scan image.
]]
local _G = _G

if not _G.AucAdvanced then return end
local coremodule, internal = _G.AucAdvanced.GetCoreModule("CoreScan")
if not coremodule or not internal then return end -- Someone has explicitely broken us

if (not _G.AucAdvanced.Scan) then _G.AucAdvanced.Scan = {} end

local SCANDATA_VERSION = "A" -- must match Auc-ScanData INTERFACE_VERSION

local TOLERANCE_LOWERLIMIT = 250
local TOLERANCE_TAPERLIMIT = 10000

local lib = _G.AucAdvanced.Scan
local private = {}

local Const = _G.AucAdvanced.Const
local Resources = AucAdvanced.Resources
local _print,decode,_,_,replicate,empty,get,set,default,debugPrint,fill, _TRANS = _G.AucAdvanced.GetModuleLocals()
local GetFaction = _G.AucAdvanced.GetFaction
local EquipCodeToInvIndex = _G.AucAdvanced.Const.EquipCodeToInvIndex

local table, tinsert, tremove, gsub, string, coroutine, pcall, time = _G.table, _G.tinsert, _G.tremove, _G.gsub, _G.string, _G.coroutine, _G.pcall, _G.time
local ceil, math, mod, floor = _G.ceil, _G.math, _G.mod, _G.floor
local unpack, select = _G.unpack, _G.select
local bitand, bitor, bitnot = bit.band, bit.bor, bit.bnot
local type, wipe = type, wipe
local pairs, ipairs, next = _G.pairs, _G.ipairs, _G.next
local tonumber = tonumber
local GetTime = GetTime

private.isScanning = false
private.auctionItemListUpdated = false

function private.LoadScanData()
	if not private.loadingScanData then
		local _, _, _, enabled, load, reason = GetAddOnInfo("Auc-ScanData")
		if not (enabled and load) then
			private.loadingScanData = "fallback"
			private.FallbackScanData = reason or "Unknown reason"
		elseif IsAddOnLoaded("Auc-ScanData") then
			-- if another AddOn has force-loaded Auc-ScanData
			private.loadingScanData = "loading"
		else
			private.loadingScanData = "block" -- prevents re-entry to this function during the LoadAddOn call
			load, reason = LoadAddOn("Auc-ScanData")
			if load then
				private.loadingScanData = "loading"
			elseif reason then
				private.loadingScanData = "fallback"
				private.FallbackScanData = reason
			else
				-- LoadAddOn sometimes returns nil, nil if called too early during game startup
				-- assume it needs to be called again at a later stage
				private.loadingScanData = nil
			end
		end
	end
	if private.loadingScanData == "loading" then
		local ready, version
		local scanmodule = _G.AucAdvanced.Modules.Util.ScanData
		if scanmodule and scanmodule.GetAddOnInfo then
			ready, version = scanmodule.GetAddOnInfo()
		end
		if version ~= SCANDATA_VERSION then
			private.loadingScanData = "fallback"
			private.FallbackScanData = "Incorrect version"
		elseif ready then
			-- install functions from Auc-ScanData
			private.GetScanData = scanmodule.GetScanData
			lib.ClearScanData = scanmodule.ClearScanData
			-- cleanup
			private.loadingScanData = nil
			private.LoadScanData = nil
			-- signal success
			return private.GetScanData
		end
	end
	if private.loadingScanData == "fallback" then
		-- cannot load Auc-ScanData, go to fallback image handler
		local fallbackscandata = {}
		private.GetScanData = function(serverKey)
			local scandata = fallbackscandata[serverKey]
			if scandata then return scandata end
			local test = _G.AucAdvanced.SplitServerKey(serverKey)
			if not test then return end
			scandata = {image = {}, scanstats = {ImageUpdated = time()}}
			fallbackscandata[serverKey] = scandata
			return scandata
		end
		-- fallback message
		local text = format(_TRANS("ADV_Interface_ScanDataNotLoaded"), private.FallbackScanData) --The Auc-ScanData storage module could not be loaded: %s
		if get("core.scan.disable_scandatawarning") then
			_print("|cffff7f3f"..text.."|r")
		else
			message(text)
		end
		-- cleanup
		private.loadingScanData = nil
		private.LoadScanData = nil
		-- signal success
		return private.GetScanData
	end
end

function lib.LoadScanData()
	if private.LoadScanData then private.LoadScanData() end
end

-- scandataTable = private.GetScanData(serverKey)
-- parameter: serverKey (required)
-- returns: scandataTable = {image = imageTable, scanstats = scanstatsTable} for the specified serverKey
-- returns: nil if there is no data for serverKey (or if serverKey is invalid)
-- CAUTION: the following is a stub function, which will be overloaded with the real function by LoadScanData
function private.GetScanData(serverKey)
	if private.LoadScanData then
		local newfunc = private.LoadScanData()
		if newfunc then
			return newfunc(serverKey)
		end
	end
end

-- _G.AucAdvanced.Scan.ClearScanData(serverKey)
-- _G.AucAdvanced.Scan.ClearScanData(realmName)
-- _G.AucAdvanced.Scan.ClearScanData("SERVER") -- all data for current server
-- _G.AucAdvanced.Scan.ClearScanData("FACTION") -- data for current faction (as determined by _G.AucAdvanced.GetFaction())
-- _G.AucAdvanced.Scan.ClearScanData("ALL")
-- CAUTION: the following is a stub function, which will be overloaded with the real function by LoadScanData
function lib.ClearScanData(key)
	_print(_TRANS("ADV_Interface_ScanDataNotCleared")) --Scan Data cannot be cleared because {{Auc-ScanData}} is not loaded
end

function lib.StartPushedScan(name, minLevel, maxLevel, invTypeIndex, classIndex, subclassIndex, isUsable, qualityIndex, GetAll, NoSummary)
	name, minLevel, maxLevel, invTypeIndex, classIndex, subclassIndex, isUsable, qualityIndex = private.QueryScrubParameters(
		name, minLevel, maxLevel, invTypeIndex, classIndex, subclassIndex, isUsable, qualityIndex)

	if private.scanStack then
		for _, scan in ipairs(private.scanStack) do
			if not scan[8] and private.QueryCompareParameters(scan[3], name, minLevel, maxLevel, invTypeIndex, classIndex, subclassIndex, isUsable, qualityIndex) then
				-- duplicate of exisiting queued query
				if (_G.nLog) then
					_G.nLog.AddMessage("Auctioneer", "Scan", _G.N_INFO, "Duplicate pushed scan detected, cancelling duplicate")
				end
				return
			end
		end
	else
		private.scanStack = {}
	end

	local query = private.NewQueryTable(name, minLevel, maxLevel, invTypeIndex, classIndex, subclassIndex, isUsable, qualityIndex)
	query.qryinfo.pushed = true
	if NoSummary then query.qryinfo.nosummary = true end

	if (_G.nLog) then
		_G.nLog.AddMessage("Auctioneer", "Scan", _G.N_INFO, ("Starting pushed scan %d (%s)"):format(query.qryinfo.id, query.qryinfo.sig))
	end

	tinsert(private.scanStack, {time(), false, query, {}, {}, false, 0, false, 0})
end

function lib.PushScan()
	if private.isGetAll then
		-- A GetAll scan cannot be Popped; do not allow it to be Pushed
		_print("Warning: Scan cannot be Pushed because it is a GetAll scan")
		return
	end
	if private.isScanning then
		if (_G.nLog) then
			_G.nLog.AddMessage("Auctioneer", "Scan", _G.N_INFO, ("Scan %d (%s) Paused, next page to scan is %d"):format(private.curQuery.qryinfo.id, private.curQuery.qryinfo.sig, private.curQuery.qryinfo.page+1))
		end
		-- _print(("Pausing current scan at page {{%d}}."):format(private.curQuery.qryinfo.page+1))
		if not private.scanStack then private.scanStack = {} end
		private.StopStorePage()
		tinsert(private.scanStack, {
			private.scanStartTime,
			private.sentQuery,
			private.curQuery,
			private.curPages,
			private.curScan,
			private.scanStarted,
			private.totalPaused,
			GetTime(),
			private.storeTime
		})
		local oldquery = private.curQuery
		private.curQuery = nil
		private.scanStartTime = nil
		private.scanStarted = nil
		private.totalPaused = nil
		private.curScan = nil
		private.storeTime = nil
		private.curPages = nil
		private.sentQuery = nil
		private.isScanning = false
		private.UpdateScanProgress(false, nil, nil, nil, nil, nil, oldquery)
	end
end

function lib.PopScan()
	if private.scanStack and #private.scanStack > 0 then
		local now, pauseTime = GetTime()
		private.scanStartTime,
		private.sentQuery,
		private.curQuery,
		private.curPages,
		private.curScan,
		private.scanStarted,
		private.totalPaused,
		pauseTime,
		private.storeTime = unpack(private.scanStack[1])
		tremove(private.scanStack, 1)

		private.scanStarted = private.scanStarted or now -- scans created by StartPushedScan measure start time from when first popped
		local elapsed = pauseTime and (now - pauseTime) or 0
		if elapsed > 300 then
			-- 5 minutes old
			--_print("Paused scan is older than 5 minutes, commiting what we have and aborting")
			if (_G.nLog) then
				_G.nLog.AddMessage("Auctioneer", "Scan", _G.N_WARNING, ("Scan %d Too Old, committing what we have and aborting"):format(private.curQuery.qryinfo.id))
			end
			private.Commit(true, false, false) -- Scan terminated early.
			return
		end

		private.totalPaused = private.totalPaused + elapsed
		if (_G.nLog) then
			_G.nLog.AddMessage("Auctioneer", "Scan", _G.N_INFO, ("Scan %d Resumed, next page to scan is %d"):format(private.curQuery.qryinfo.id, private.curQuery.qryinfo.page+1))
		end
		--_print(("Resuming paused scan at page {{%d}}..."):format(private.curQuery.qryinfo.page+1))
		private.isScanning = true
		private.sentQuery = false
		private.ScanPage(private.curQuery.qryinfo.page+1)
		private.UpdateScanProgress(true, nil, nil, nil, nil, nil, private.curQuery)
	end
end

--[[This function is now in core API]]
function lib.ProgressBars(name, value, show, text, options)
	_G.AucAdvanced.API.ProgressBars(name, value, show, text, options)
end

function lib.StartScan(name, minUseLevel, maxUseLevel, invTypeIndex, classIndex, subclassIndex, isUsable, qualityIndex, GetAll, NoSummary)
	if _G.AuctionFrame and _G.AuctionFrame:IsVisible() then
		if private.isPaused then
			_G.message("Scanning is currently paused")
			return
		end
		if private.isScanning then
			_G.message("Scan is currently in progress")
			return
		end
		local CanQuery, CanQueryAll = CanSendAuctionQuery()
		if GetAll then
			local now = time()
			if not CanQueryAll then
				local text = "You cannot do a GetAll scan at this time."
				if private.LastGetAll then
					local timeleft = 900 - (now - private.LastGetAll) -- 900 = 15 * 60 sec = 15 min
					if timeleft > 0 then
						local minleft = floor(timeleft / 60)
						local secleft = timeleft - minleft * 60
						text = text.." You must wait "..minleft..":"..secleft.." until you can scan again."
					end
				end
				_G.message(text)
				return
			end

			_G.AucAdvanced.API.BlockUpdate(true, false)
			BrowseSearchButton:Hide()
			lib.ProgressBars("GetAllProgressBar", 0, true, "Auctioneer: Scanning")
			private.isGetAll = true -- indicates that certain functions must take special action, and that the above changes need to be undone

			private.LastGetAll = now
		else
			if not CanQuery then
				private.queueScan = {
					name, minUseLevel, maxUseLevel, invTypeIndex, classIndex, subclassIndex, isUsable, qualityIndex, GetAll, NoSummary
				}
				private.queueScanParams = 10 -- must match the number of entries we put into the table, including nils. Used when unpacking
				return
			end
		end

		if private.curQuery then
			private.Commit(true, false, false) -- sets private.curQuery to nil and commits prior cancelled query
		end

		private.isScanning = true
		private.isNoSummary = NoSummary
		local startPage = 0

		lib.SetAuctioneerQuery() -- flag the following query as coming from Auctioneer
		SortAuctionClearSort("list")
		QueryAuctionItems(name or "", minUseLevel or "", maxUseLevel or "",
				invTypeIndex, classIndex, subclassIndex, startPage, isUsable, qualityIndex, GetAll)
		if not private.curQuery then
			-- private.curQuery will have been set if QueryAuctionItems succeeded
			-- this should never fail? we checked CanSendAuctionQuery() earlier
			_G.message("Scan failed: unable to send query")
			if private.isGetAll then
				lib.ProgressBars("GetAllProgressBar", nil, false)
				BrowseSearchButton:Show()
				_G.AucAdvanced.API.BlockUpdate(false)
				private.isGetAll = nil
			end
			return
		end
		_G.AuctionFrameBrowse.page = startPage
		if (NoSummary) then
			private.curQuery.qryinfo.nosummary = true
		end
		if GetAll then
			private.curQuery.qryinfo.getall = true
		end
		private.isNoSummary = false

		--Show the progress indicator
		private.UpdateScanProgress(true, nil, nil, nil, nil, nil, private.curQuery)
	else
		_G.message("Steady on; You'll need to talk to the auctioneer first!")
	end
end

function lib.IsScanning()
	return private.isScanning or (private.queueScan ~= nil)
end

function lib.IsPaused()
	return private.isPaused
end

function private.Unpack(item, storage)
	if not storage then storage = {} end
	storage.id = item[Const.ID]
	storage.link = item[Const.LINK]
	storage.useLevel = item[Const.ULEVEL]
	storage.itemLevel = item[Const.ILEVEL]
	storage.itemType = item[Const.ITYPE]
	storage.subType = item[Const.ISUB]
	storage.equipPos = item[Const.IEQUIP]
	storage.price = item[Const.PRICE]
	storage.timeLeft = item[Const.TLEFT]
	storage.seenTime = item[Const.TIME]
	storage.itemName = item[Const.NAME]
	storage.texture = item[Const.TEXTURE]
	storage.stackSize = item[Const.COUNT]
	storage.quality = item[Const.QUALITY]
	storage.canUse = item[Const.CANUSE]
	storage.minBid = item[Const.MINBID]
	storage.curBid = item[Const.CURBID]
	storage.increment = item[Const.MININC]
	storage.sellerName = item[Const.SELLER]
	storage.buyoutPrice = item[Const.BUYOUT]
	storage.amBidder = item[Const.AMHIGH]
	storage.dataFlag = item[Const.FLAG]
	storage.itemId = item[Const.ITEMID]
	storage.itemSuffix = item[Const.SUFFIX]
	storage.itemFactor = item[Const.FACTOR]
	storage.itemEnchant = item[Const.ENCHANT]
	storage.itemSeed = item[Const.SEED]

	return storage
end
-- Define a public accessor for the above upack function
lib.UnpackImageItem = private.Unpack

--The first parameter will be true if we want to show the process indicator, false if we want to hide it. and nil if we only want to update it.
--The second parameter will be a number that is the max number of items in the scan.
--The third parameter is the current progress of the scan.
function private.UpdateScanProgress(state, totalAuctions, scannedAuctions, elapsedTime, page, maxPages, query)
	if (lib.IsScanning() or (state == false)) then
		if (_G.nLog) then
			_G.nLog.AddMessage("Auctioneer", "Scan", _G.N_INFO, "UpdateScanProgress Called", state)
		end
		local scanCount = 0
		if (private.scanStack) then scanCount=#private.scanStack end
		_G.AucAdvanced.SendProcessorMessage("scanprogress", state, totalAuctions, scannedAuctions, elapsedTime, page, maxPages, query, scanCount)
	end
end

function private.IsIdentical(focus, compare)
	for i = 1, Const.SELLER do
		if (i ~= Const.TIME and i ~= Const.CANUSE and focus[i] ~= compare[i]) then
			return false
		end
	end
	return true
end

function private.IsSameItem(focus, compare, onlyDirt)
	if onlyDirt then
		local flag = focus[Const.FLAG]
		if not flag or bitand(flag, Const.FLAG_DIRTY) == 0 then
			return false
		end
	end
	if (focus[Const.LINK] ~= compare[Const.LINK]) then return false end
	if (focus[Const.COUNT] ~= compare[Const.COUNT]) then return false end
	if (focus[Const.MINBID] ~= compare[Const.MINBID]) then return false end
	if (focus[Const.BUYOUT] ~= compare[Const.BUYOUT]) then return false end
	if (focus[Const.CURBID] > compare[Const.CURBID]) then return false end
	return true
end

function lib.FindItem(item, image, lut)
	local focus
	-- If we have a lookuptable, then we don't need to scan the whole lot
	if (lut) then
		local list = lut[item[Const.LINK]]
		if not list then return false
		elseif type(list) == "number" then
			if (private.IsSameItem(image[list], item, true)) then return list end
		else
			local pos
			for i=1, #list do
				pos = list[i]
				if (private.IsSameItem(image[pos], item, true)) then return pos end
			end
		end
	else
		-- We need to scan the whole thing cause there's no lookup table
		for i = 1, #image do
			if (private.IsSameItem(image[i], item, true)) then return i end
		end
	end
end


local function processBeginEndStats(processors, operation, querySizeInfo, TempcurScanStats)
	if (not processors) then return end
	local po = processors[operation]
	if (po) then
		for i=1,#po do
			local x = po[i]
			local f = x.Func
			local pOK, errormsg = pcall(f, operation, querySizeInfo, TempcurScanStats)
			if (not pOK) then
				if (_G.nLog) then _G.nLog.AddMessage("Auctioneer", "Scan", _G.N_WARNING, "ScanProcessor Error", ("ScanProcessor %s Returned Error %s"):format(x and x.Name or "??", errormsg)) end
			end
		end
	end
	return true
end

local statItem = { }
local statItemOld = { }

local function processStats(processors, operation, curItem, oldItem)
	local filtered = false
	if (not processors) then return end
	if (curItem) then private.Unpack(curItem, statItem) end
	if (oldItem) then private.Unpack(oldItem, statItemOld) end
	if (operation == "create" and processors.Filter) then
		--[[
			Filtering out happens here so we only have to do Unpack once.
			Only filter on create because once its in the system, dropping it can give the wrong impression to other mods.
			(it could think it was sold, for instance)
		]]
		local pf = processors.Filter
		for i=1,#pf do
			local x = pf[i]
			local f = x.Func
			local pOK, result=pcall(f, operation, statItem)
			if (pOK) then
				if (result) then
					curItem[Const.FLAG] = bitor(curItem[Const.FLAG] or 0, Const.FLAG_FILTER)
					filtered = true
					break
				end
			else
				if (_G.nLog) then
					_G.nLog.AddMessage("Auctioneer", "Scan", _G.N_WARNING, "AuctionFilter Error", ("AuctionFilter %s Returned Error %s"):format(x and x.Name or "??", result or "??"))
				end
			end
		end
	elseif curItem and bitand(curItem[Const.FLAG] or 0, Const.FLAG_FILTER) == Const.FLAG_FILTER then
		-- This item is a filtered item
		filtered = true
	end
	if filtered then
		return false
	end

	local po = processors[operation]
	if (po) then
		for i=1,#po do
			local x = po[i]
			local f = x.Func
			local pOK, errormsg = pcall(f, operation, statItem, oldItem and statItemOld or nil)
			--if (oldItem) then
			--	pOK, errormsg = pcall(func,operation, statItem, statItemOld)
			--else
			--	pOK, errormsg = pcall(func,operation, statItem)
			--end
			if (not pOK) then
				if (_G.nLog) then _G.nLog.AddMessage("Auctioneer", "Scan", _G.N_WARNING, "ScanProcessor Error", ("ScanProcessor %s Returned Error %s"):format(x and x.Name or "??", errormsg)) end
			end
		end
	end
	return true
end

function private.IsInQuery(curQuery, data)
	if 	(not curQuery.class or curQuery.class == data[Const.ITYPE])
			and (not curQuery.subclass or (curQuery.subclass == data[Const.ISUB]))
			and (not curQuery.minUseLevel or (data[Const.ULEVEL] >= curQuery.minUseLevel))
			and (not curQuery.maxUseLevel or (data[Const.ULEVEL] <= curQuery.maxUseLevel))
			and (not curQuery.name or (data[Const.NAME] and data[Const.NAME]:lower():find(curQuery.name, 1, true))) -- curQuery.name is already lowercased
			and (not curQuery.isUsable or (private.CanUse(data[Const.LINK])))
			and (not curQuery.invType or (EquipCodeToInvIndex[data[Const.IEQUIP]] == curQuery.invType)) -- must convert iEquip code to invTypeIndex for comparison
			and (not curQuery.quality or (data[Const.QUALITY] >= curQuery.quality))
			then
		return true
	end
	return false
end

local idLists = {}
function private.BuildIDList(scandata, serverKey)
	local idList = idLists[serverKey]
	if idList then return idList end
	idList = {0} -- dummy entry ensures that list is never empty and that counting starts from 1
	idLists[serverKey] = idList
	local image = scandata.image
	for i = 1, #image do
		tinsert(idList, image[i][Const.ID])
	end
	table.sort(idList)
	return idList
end

function private.GetNextID(idList)
	local nextId = idList[1] + 1
	local second = idList[2]
	while second == nextId do
		nextId = second + 1
		tremove(idList, 1)
		second = idList[2]
	end
	idList[1] = nextId
	return nextId
end

function lib.GetScanStats(serverKey)
	local scandata = private.GetScanData(serverKey or GetFaction())
	if scandata then
		return scandata.scanstats
	end
end

function lib.GetImageCopy(serverKey)
	-- Create a fully independent copy of the image - intended for use by coroutines
	local scandata = private.GetScanData(serverKey or GetFaction())
	if scandata then
		local image = scandata.image
		local size = Const.LASTENTRY
		local copy = {}
		for i = 1, #image do
			tinsert(copy, {unpack(image[i], 1, size)})
		end
		return copy
	end
end

function lib.GetImageSize(serverKey)
	local scandata = private.GetScanData(serverKey or GetFaction())
	if scandata then
		return #scandata.image
	end
end

function lib.GetImageItem(index, serverKey, reserved)
	-- reserved flag for possible future expansion
	local scandata = private.GetScanData(serverKey or GetFaction())
	if scandata then
		local item = scandata.image[index]
		if item then return {unpack(item, 1, Const.LASTENTRY)} end
	end
end


private.scandataIndex = {}
private.prevQuery = {}
-- private.queryResults is nil initially
-- private.prevQueryServerKey is nil initially

function private.clearImageCaches(event, scanstats)
	if event == "factionselect" then
		-- if cache for home serverKey exists at this point it is a weak table - just dump the cache and let it rebuild
		private.scandataIndex[Resources.ServerKeyHome] = nil
	else
		local serverKey = scanstats and scanstats.serverKey
		if serverKey then
			local cache = private.scandataIndex[serverKey]
			if cache then
				wipe(cache)
			end
		else -- no serverKey provided: affects multiple serverKeys (or unknown source), dump all caches
			wipe(private.scandataIndex)
		end
	end

	private.prevQueryServerKey = nil
	private.queryResults = nil -- not required but frees some memory
end

local weaktablemeta = {__mode="kv"}
function private.SubImageCache(itemId, serverKey)
	local indexResults = private.scandataIndex[serverKey]
	if not indexResults then
		if not _G.AucAdvanced.SplitServerKey(serverKey) then return end -- valid serverKey format?
		indexResults = {}
		if serverKey ~= Resources.ServerKeyHome and serverKey ~= Resources.ServerKeyNeutral then
			-- use weak tables for other serverKeys
			indexResults = setmetatable(indexResults, weaktablemeta)
		end
		private.scandataIndex[serverKey] = indexResults
	end

	local itemResults = indexResults[itemId]
	if not itemResults then
		local scandata = private.GetScanData(serverKey)
		if not scandata then return end
		itemResults = {}
		for pos, data in ipairs(scandata.image) do
			if data[Const.ITEMID] == itemId then
				tinsert(itemResults, data)
			end
		end
		indexResults[itemId] = itemResults
	end

	return itemResults
end

function lib.QueryImage(query, serverKey, reserved, ...)
	serverKey = serverKey or GetFaction()
	local prevQuery = private.prevQuery
	local queryResults = private.queryResults

	-- is this the same query as last time?
	if serverKey == private.prevQueryServerKey then
		local samequery = true
		for k,v in pairs(prevQuery) do
			if v ~= query[k] then
				samequery = false
				break
			end
		end
		if samequery then
			for k,v in pairs(query) do
				if v ~= prevQuery[k] then
					samequery = false
					break
				end
			end
			if samequery then
				return queryResults
			end
		end
	end

	-- reset results and save a copy of query
	queryResults = {} -- cannot use wipe; needs to be a new table here {ADV-534}
	private.queryResults = queryResults
	wipe(prevQuery)
	for k, v in pairs(query) do prevQuery[k] = v end
	private.prevQueryServerKey = serverKey

	-- get image to search - may be the whole snapshot or a subset
	local itemId = tonumber(query.itemId)
	local stringSpeciesID
	if query.speciesID then
		-- looking for a battlepet
		-- we will need to split the link for each data item, resulting in a _string contaning the speciesID_
		-- make sure the test value is also a string
		stringSpeciesID = tostring(query.speciesID)
		-- also, all battlepets have the same itemId
		if not itemId then
			itemId = 82800
		elseif itemId ~= 82800 then
			-- wrong itemId! return empty results table
			return queryResults
		end
	end
	local saneQueryLink
	if query.link then
		saneQueryLink = SanitizeLink(query.link)
		if not itemId then
			-- it should be more efficient to extract itemId from the link
			-- so we can use SubImageCache
			local header, id = strsplit(":", saneQueryLink)
			itemId = tonumber(id)
		end
	end
	local image
	if itemId then
		image = private.SubImageCache(itemId, serverKey)
	else
		local scandata = private.GetScanData(serverKey)
		if scandata then
			image = scandata.image
		end
	end
	if not image then return queryResults end -- return empty results table

	local lowerName
	if query.name then
		lowerName = query.name:lower()
	end

	-- scan image to build a table of auctions that match query
	local ptr, finish = 1, #image
	while ptr <= finish do
		repeat
			local data = image[ptr]
			ptr = ptr + 1
			if not data then break end
			if bitand(data[Const.FLAG] or 0, Const.FLAG_UNSEEN) == Const.FLAG_UNSEEN then break end
			if query.filter and query.filter(data, ...) then break end
			if saneQueryLink and data[Const.LINK] ~= saneQueryLink then break end
			if query.suffix and data[Const.SUFFIX] ~= query.suffix then break end
			if query.factor and data[Const.FACTOR] ~= query.factor then break end
			if query.minUseLevel and data[Const.ULEVEL] < query.minUseLevel then break end
			if query.maxUseLevel and data[Const.ULEVEL] > query.maxUseLevel then break end
			if query.minItemLevel and data[Const.ILEVEL] < query.minItemLevel then break end
			if query.maxItemLevel and data[Const.ILEVEL] > query.maxItemLevel then break end
			if query.class and data[Const.ITYPE] ~= query.class then break end
			if query.subclass and data[Const.ISUB] ~= query.subclass then break end
			if query.quality and data[Const.QUALITY] ~= query.quality then break end
			if query.invType and data[Const.IEQUIP] ~= query.invType then break end
			if query.seller and data[Const.SELLER] ~= query.seller then break end
			if lowerName then
				local name = data[Const.NAME]
				if not (name and name:lower():find(lowerName, 1, true)) then break end
			end
			if stringSpeciesID then
				local _, id = strsplit(":", data[Const.LINK])
				if id ~= stringSpeciesID then
					break
				end
			end

			local stack = data[Const.COUNT]
			local nextBid = data[Const.PRICE]
			local buyout = data[Const.BUYOUT]
			if query.perItem and stack > 1 then
				nextBid = ceil(nextBid / stack)
				buyout = ceil(buyout / stack)
			end
			if query.minStack and stack < query.minStack then break end
			if query.maxStack and stack > query.maxStack then break end
			if query.minBid and nextBid < query.minBid then break end
			if query.maxBid and nextBid > query.maxBid then break end
			if query.minBuyout and buyout < query.minBuyout then break end
			if query.maxBuyout and buyout > query.maxBuyout then break end

			-- If we're still here, then we've got a winner
			tinsert(queryResults, data)
		until true
	end

	return queryResults
end


private.CommitQueue = {}

local CommitRunning = false
local Commitfunction = function()
	local commitStarted = GetTime()
	--local totalProcessingTime = 0 -- temp disabled, going to take some work to thread this back in with the broken GetTime / time changes

	-- coroutine speed limiter using debugprofilestop
	-- time in milliseconds: 1000/FPS * 0.8 (80% rough adjustment to allow for other stuff happening during the frame)
	local processingTime = 800 / get("scancommit.targetFPS")
	local debugprofilestop = debugprofilestop
	local nextPause -- gets set before each processing loop, and after each yield within the loop
	-- backup timer, in case debugprofilestop fails - can occur under (currently unknown) circumstances - only used in the merge and cleanup loops {ADV-637}
	local time = time
	local lastTime

	local inscount, delcount = 0, 0
	if #private.CommitQueue == 0 then CommitRunning = false return end
	CommitRunning = true

	--grab the first item in the commit queue, and bump everything else down
	local TempcurCommit = tremove(private.CommitQueue)
	-- setup various locals for later use
	local TempcurScan = TempcurCommit.Scan
	local TempcurQuery = TempcurCommit.Query

	local wasIncomplete = TempcurCommit.wasIncomplete
	local wasEarlyTerm = TempcurCommit.wasEarlyTerm
	local wasEndPagesOnly = TempcurCommit.wasEndPagesOnly

	local wasGetAll = TempcurCommit.wasGetAll
	local scanStarted = TempcurCommit.scanStarted
	local scanStartTime = TempcurCommit.scanStartTime
	local totalPaused = TempcurCommit.totalPaused
	local scanCommitTime = TempcurCommit.scanCommitTime
	local scanStoreTime = scanCommitTime - scanStarted - totalPaused
	local storeTime = TempcurCommit.storeTime
	local wasOnePage = wasGetAll or (TempcurQuery.qryinfo.page == 0) -- retrieved all records in single pull (only one page scanned or was GetAll)
	local wasUnrestricted = not (TempcurQuery.class or TempcurQuery.subclass or TempcurQuery.minUseLevel
		or TempcurQuery.name or TempcurQuery.isUsable or TempcurQuery.invType or TempcurQuery.quality) -- no restrictions, potentially a full scan


	local serverKey = TempcurQuery.qryinfo.serverKey or GetFaction()
	local scandata = private.GetScanData(serverKey)
	assert(scandata, "Critical error: scandata does not exist for serverKey "..serverKey)
	local idList = private.BuildIDList(scandata, serverKey)
	local now = time()
	if get("scancommit.progressbar") then
		lib.ProgressBars("CommitProgressBar", 0, true)
	end
	local unresolvedCount = 0
	local hadGetError = false
	local oldCount = #scandata.image
	local scanCount = #TempcurScan

	local progresscounter = 0
	local progresstotal = 3*oldCount + 6*scanCount

	local filterDeleteCount,filterOldCount, filterNewCount, updateCount, sameCount, newCount, updateRecoveredCount, sameRecoveredCount, missedCount, earlyDeleteCount, expiredDeleteCount = 0,0,0,0,0,0,0,0,0,0,0


	--[[ *** Stage 1 : pre-process the new scan ]]--
	lib.ProgressBars("CommitProgressBar", 100*progresscounter/progresstotal, true, "Auctioneer: Processing Stage 1")
	coroutine.yield() -- yield here to allow the bar to display, and help the frame rate a little
	nextPause = debugprofilestop() + processingTime
	local missingData = false
	local pos=#TempcurScan
	while (pos > 0) do
		if debugprofilestop() > nextPause then
			lib.ProgressBars("CommitProgressBar", 100*progresscounter/progresstotal, true, "Auctioneer: Processing Stage 1")
			coroutine.yield()
			nextPause = debugprofilestop() + processingTime
		end

		local data = TempcurScan[pos]
		local entryUnresolved = false
		local entryUnusable = false
		progresscounter = progresscounter + 1
		if (not data[Const.SELLER] or data[Const.SELLER]=="") then data[Const.SELLER], entryUnresolved = "", true end

		if data[Const.ITEMID] and not (data[Const.ILEVEL] and data[Const.ITYPE] and data[Const.ISUB]) then
			if data[Const.ITEMID] == 82800 then -- Pet Cage
				local cType, cSubtypeLookup, cUseLevel = private.GetPetCageInfo()
				if cType then
					data[Const.ITYPE] = cType
					data[Const.IEQUIP] = nil
					data[Const.ULEVEL] = cUseLevel
					local _, speciesID, level = strsplit(":", data[Const.LINK])
					speciesID, level = tonumber(speciesID), tonumber(level)
					data[Const.ILEVEL] = data[Const.ILEVEL] or level -- should have been obtained from GetAuctionItemInfo anyway
					local _, _, petType = C_PetJournal.GetPetInfoBySpeciesID(speciesID)
					if petType then
						data[Const.ISUB] = cSubtypeLookup[petType]
					end
				end
			else
				local itemInfo = private.GetItemInfoCache(data[Const.ITEMID]) -- {iType, iSubtype, Const.EquipEncode[equipLoc], iLevel, uLevel}
				if itemInfo then
					data[Const.ITYPE] = data[Const.ITYPE] or itemInfo[1]
					data[Const.ISUB] = data[Const.ISUB] or itemInfo[2]
					data[Const.IEQUIP] = data[Const.IEQUIP] or itemInfo[3]
					data[Const.ILEVEL] = data[Const.ILEVEL] or itemInfo[4]
					data[Const.ULEVEL] = data[Const.ULEVEL] or itemInfo[5]
				end
			end
		end
		for i = 1, Const.LASTENTRY, 1 do
			if (i ~= Const.MININC and i ~= Const.BUYOUT and i ~= Const.CURBID and i ~= Const.IEQUIP and i ~= Const.AMHIGH and i ~= Const.CANUSE and i ~= Const.FLAG) then
				if ((not data[i]) or data[i]=="") then
					missingData = true
					entryUnresolved = true
					if (i ~= Const.SELLER) then
						entryUnusable = true
						break
					end
				end
			end
		end


		if entryUnusable then
			if _G.nLog then
				-- Yes this is a mess.  However, it gives enough information to let us resolve problems in the future when blizzard breaks in a new way.
				_G.nLog.AddMessage("Auctioneer", "Scan", _G.N_WARNING, "Incomplete Auction Seen",
					(("%s%s%s%s%s%s"):format(
					"Page %d, Index %d -- %s\n %s -- %d of %s sold by %s\n",
					"Level %d, Quality %s, Item Level %s\n",
					"Item Type %s, Sub Type %s, Equipment Position %s\n",
					"Price %s, Bid %s, NextBid %s, MinInc %s, Buyout %s\n Time Left %s, Time %s\n",
					"High Bidder %s  Can Use: %s  ID %s  Item ID %s  Suffix %s  Factor %s  Enchant %s  Seed %s\n",
					"Texture: %s")):format(
					data.PAGE, data.PAGEINDEX, "too broken, can not use at all",
					data[Const.LINK] or "(nil)", data[Const.COUNT] or -1, data[Const.NAME] or "(nil)", data[Const.SELLER] or "(UNKNOWN)",
					data[Const.ULEVEL] or -1, data[Const.QUALITY] or -1, data[Const.ILEVEL] or -1,data[Const.ITYPE] or "(UNKNOWN)", data[Const.ISUB] or "(UNKNOWN)", data[Const.IEQUIP] or '(n/a)',
					data[Const.PRICE] or -1, data[Const.CURBID] or -1, data[Const.MINBID] or -1, data[Const.MININC] or -1, data[Const.BUYOUT] or -1,
					data[Const.TLEFT] or -1, data[Const.TIME] or "(nil)", data[Const.AMHIGH] and "Yes" or "No",
					(data[Const.CANUSE]==false and "Yes") or (data[Const.CANUSE] and "No" or "(nil)"), data[Const.ID] or '(nil)', data[Const.ITEMID] or '(nil)',
					data[Const.SUFFIX] or '(nil)', data[Const.FACTOR] or '(nil)', data[Const.ENCHANT] or '(nil)', data[Const.SEED] or '(nil)', data[Const.TEXTURE] or '(nil)'))
			end
			tremove(TempcurScan, pos)
			unresolvedCount = unresolvedCount + 1
			progresscounter = progresscounter + 2 -- We just wiped the entry from the db, so other steps won't see it.
		end
		pos = pos -1
	end
	local tolerance = 0
	if scanCount > TOLERANCE_LOWERLIMIT then -- don't use tolerance for tiny scans
		tolerance = get("core.scan.unresolvedtolerance")
		if scanCount < TOLERANCE_TAPERLIMIT then -- taper tolerance for smaller scans
			tolerance = tolerance * scanCount / TOLERANCE_TAPERLIMIT
		end
	end
	if unresolvedCount > tolerance then
		hadGetError = true
		wasIncomplete = true
	end


	--[[ *** Stage 2 : Pre-process image table : Mark all matching auctions as DIRTY, and build a LookUpTable *** ]]--
	lib.ProgressBars("CommitProgressBar", 100*progresscounter/progresstotal, true, "Auctioneer: Processing Stage 2")
	coroutine.yield() -- yield to allow updated bar to display

	local dirtyCount = 0
	local lut = {}

	nextPause = debugprofilestop() + processingTime
	for pos, data in ipairs(scandata.image) do
		if debugprofilestop() > nextPause then
			lib.ProgressBars("CommitProgressBar", 100*progresscounter/progresstotal, true, "Auctioneer: Processing Stage 2")
			coroutine.yield()
			nextPause = debugprofilestop() + processingTime
		end
		local link = data[Const.LINK]
		progresscounter = progresscounter + 1
		if link then
			if private.IsInQuery(TempcurQuery, data) then
				-- Mark dirty
				data[Const.FLAG] = bitor(data[Const.FLAG] or 0, Const.FLAG_DIRTY)
				dirtyCount = dirtyCount+1

				-- Build lookup table
				local list = lut[link]
				if (not list) then
					lut[link] = pos
				else
					if (type(list) == "number") then
						lut[link] = {}
						tinsert(lut[link], list)
					end
					tinsert(lut[link], pos)
				end
			else
				-- Mark NOT dirty
				data[Const.FLAG] = bitand(data[Const.FLAG] or 0, bitnot(Const.FLAG_DIRTY))
			end
		end
	end


	--[[ *** Stage 3 : Merge new scan into ScanData *** ]]
	lib.ProgressBars("CommitProgressBar", 100*progresscounter/progresstotal, true, "Auctioneer: Processing Stage 3")
	coroutine.yield()

	local processors = {}
	local modules = _G.AucAdvanced.GetAllModules("AuctionFilter", "Filter")
	for pos, engineLib in ipairs(modules) do
		if (not processors.Filter) then processors.Filter = {} end
		local x = {}
		x.Name = engineLib.GetName()
		x.Func = engineLib.AuctionFilter
		tinsert(processors.Filter, x)
	end
	modules = _G.AucAdvanced.GetAllModules("ScanProcessors")
	for pos, engineLib in ipairs(modules) do
		for op, func in pairs(engineLib.ScanProcessors) do
			if (not processors[op]) then processors[op] = {} end
			local x = {}
			x.Name = engineLib.GetName()
			x.Func = func
			tinsert(processors[op], x)
		end
	end

	local printSummary, scanSize = false, ""
	scanSize = TempcurQuery.qryinfo.scanSize
	if scanSize=="Full" then
		printSummary = get("scandata.summaryonfull");
	elseif scanSize=="Partial" then
		printSummary = get("scandata.summaryonpartial")
	else -- scanSize=="Micro"
		printSummary = get("scandata.summaryonmicro")
	end
	if (wasEndPagesOnly) then
		scanSize = "TailScan-"..scanSize
		printSummary = get("scandata.summaryonpartial") -- todo: do we want a separate "summary on end pages only" option?
	elseif (TempcurQuery.qryinfo.nosummary) then
		printSummary = false
		scanSize = "NoSum-"..scanSize
	end

	local querySizeInfo = { }
	querySizeInfo.wasIncomplete = wasIncomplete
	querySizeInfo.wasGetAll = wasGetAll
	querySizeInfo.scanStarted = scanStarted
	querySizeInfo.wasUnrestricted = wasUnrestricted
	querySizeInfo.wasEarlyTerm = wasEarlyTerm
	querySizeInfo.hadGetError = hadGetError
	querySizeInfo.wasEndPagesOnly = wasEndPagesOnly
	querySizeInfo.Query = TempcurCommit.Query
	querySizeInfo.matchCount = dirtyCount
	querySizeInfo.scanCount = scanCount
	querySizeInfo.printSummary = printSummary
	querySizeInfo.FallbackScanData = private.FallbackScanData

	local maskNotDirtyUnseen = bitnot(bitor(Const.FLAG_DIRTY, Const.FLAG_UNSEEN)) -- only calculate mask for clearing these flags once
	local messageCreate = private.FallbackScanData and "fallbackcreate" or "create"

	processBeginEndStats(processors, "begin", querySizeInfo, nil)

	coroutine.yield()
	nextPause = debugprofilestop() + processingTime
	lastTime = time()
	for index, data in ipairs(TempcurScan) do
		if debugprofilestop() > nextPause or time() > lastTime then
			lib.ProgressBars("CommitProgressBar", 100*progresscounter/progresstotal, true, "Auctioneer: Processing Stage 3")
			coroutine.yield()
			nextPause = debugprofilestop() + processingTime
			lastTime = time()
		end
		local itemPos = lib.FindItem(data, scandata.image, lut)
		progresscounter = progresscounter + 4

		if (itemPos) then
			local oldItem = scandata.image[itemPos]
			data[Const.ID] = oldItem[Const.ID]
			data[Const.FLAG] = bitand(oldItem[Const.FLAG], maskNotDirtyUnseen)
			if data[Const.SELLER] == "" then -- unknown seller name in new data; copy the old name if it exists
				data[Const.SELLER] = oldItem[Const.SELLER]
			end
			if (bitand(data[Const.FLAG], Const.FLAG_FILTER)==Const.FLAG_FILTER) then
				filterOldCount = filterOldCount + 1
			else
				if not private.IsIdentical(oldItem, data) then
					if processStats(processors, "update", data, oldItem) then
						updateCount = updateCount + 1
					end
					if bitand(oldItem[Const.FLAG] or 0, Const.FLAG_UNSEEN) == Const.FLAG_UNSEEN then
						updateRecoveredCount = updateRecoveredCount + 1
					end
				else
					if processStats(processors, "leave", data) then
						sameCount = sameCount + 1
					end
					if bitand(oldItem[Const.FLAG] or 0, Const.FLAG_UNSEEN) == Const.FLAG_UNSEEN then
						sameRecoveredCount = sameRecoveredCount + 1
					end
				end
			end
			scandata.image[itemPos] = replicate(data)
		else
			if (processStats(processors, messageCreate, data)) then
				newCount = newCount + 1
			else -- processStats(processors, "create"...) filtered the auction: flag it
				data[Const.FLAG] = bitor(data[Const.FLAG] or 0, Const.FLAG_FILTER)
				filterNewCount = filterNewCount + 1
			end
			data[Const.ID] = private.GetNextID(idList)
			data[Const.FLAG] = bitand(data[Const.FLAG], maskNotDirtyUnseen)
			tinsert(scandata.image, replicate(data))
		end
	end


	--[[ *** Stage 4 : Cleanup deleted auctions *** ]]
	lib.ProgressBars("CommitProgressBar", 100*progresscounter/progresstotal, true, "Auctioneer: Processing Stage 4")
	coroutine.yield() -- as above
	local progressstep = 1
	if #scandata.image > 0 then -- (avoid potential div0)
		-- #scandata.image is probably now larger than when we originally calculated progresstotal -- adjust the step size to compensate
		progressstep = (progresstotal - progresscounter) / #scandata.image
	end
	nextPause = debugprofilestop() + processingTime
	lastTime = time()
	for pos = #scandata.image, 1, -1 do
		if debugprofilestop() > nextPause or time() > lastTime then
			lib.ProgressBars("CommitProgressBar", 100*progresscounter/progresstotal, true, "Auctioneer: Processing Stage 4")
			coroutine.yield()
			nextPause = debugprofilestop() + processingTime
			lastTime = time()
		end
		local data = scandata.image[pos]
		progresscounter = progresscounter + progressstep
		if (bitand(data[Const.FLAG] or 0, Const.FLAG_DIRTY) == Const.FLAG_DIRTY) then
			local auctionmaxtime = Const.AucMaxTimes[data[Const.TLEFT]] or 172800
			local dodelete = false

			if data[Const.TIME] and (now - data[Const.TIME] > auctionmaxtime) then
				-- delete items that have passed their expiry time - even if scan was incomplete
				dodelete = true
				if bitand(data[Const.FLAG] or 0, Const.FLAG_FILTER) == Const.FLAG_FILTER then
					filterDeleteCount = filterDeleteCount + 1
				else
					expiredDeleteCount = expiredDeleteCount + 1
				end
			elseif wasIncomplete then
				missedCount = missedCount + 1
			elseif wasOnePage then
				-- a *completed* one-page scan should not have missed any auctions
				dodelete = true
				if bitand(data[Const.FLAG] or 0, Const.FLAG_FILTER) == Const.FLAG_FILTER then
					filterDeleteCount = filterDeleteCount + 1
				else
					earlyDeleteCount = earlyDeleteCount + 1
				end
			else
				if bitand(data[Const.FLAG] or 0, Const.FLAG_UNSEEN) == Const.FLAG_UNSEEN then
					dodelete = true
					if bitand(data[Const.FLAG] or 0, Const.FLAG_FILTER) == Const.FLAG_FILTER then
						filterDeleteCount = filterDeleteCount + 1
					else
						earlyDeleteCount = earlyDeleteCount + 1
					end
				else
					data[Const.FLAG] = bitor(data[Const.FLAG] or 0, Const.FLAG_UNSEEN)
					missedCount = missedCount + 1
				end
			end
			if dodelete then
				if not (bitand(data[Const.FLAG] or 0, Const.FLAG_FILTER) == Const.FLAG_FILTER) then
					processStats(processors, "delete", data)
				end
				tremove(scandata.image, pos)
			end
		end
	end


	--[[ *** Stage 5 : Reports *** ]]
	lib.ProgressBars("CommitProgressBar", 100, true, "Auctioneer: Processing Finished")
	coroutine.yield() -- final yield to update GetTime for the stats
	-- (though we should be aware that whatever else happens during this yield gets added to our final time, we can't get an update of GetTime *without* yielding here!)

	local currentCount = #scandata.image
	if (updateCount + sameCount + newCount + filterNewCount + filterOldCount + unresolvedCount ~= scanCount) then
		if _G.nLog then
			_G.nLog.AddMessage("Auctioneer", "Scan", _G.N_WARNING, "Scan Count Discrepency Seen",
				("%d updated + %d same + %d new + %d filtered + %d unresolved != %d scanned"):format(updateCount, sameCount,
					newCount, filterOldCount+filterNewCount, unresolvedCount, scanCount))
		end
	end

	-- image contains filtered items now.  Need to account for new entries that are flagged as filtered (not shown to stats modules)
	if (oldCount - earlyDeleteCount - expiredDeleteCount + newCount + filterNewCount - filterDeleteCount ~= currentCount) then
		if _G.nLog then
			_G.nLog.AddMessage("Auctioneer", "Scan", _G.N_WARNING, "Current Count Discrepency Seen",
				("%d - %d - %d + %d + %d - %d != %d"):format(oldCount, earlyDeleteCount, expiredDeleteCount,
					newCount, filterNewCount, filterDeleteCount, currentCount))
		end
	end

	local endTimeStamp = time()
	local scanTimeSecs, scanTimeMins, scanTimeHours = GetTime() - scanStarted - totalPaused, 0, 0
	if scanTimeSecs < 1 then
		scanTimeSecs = floor(scanTimeSecs*10)/10
	else
		scanTimeSecs = floor(scanTimeSecs)
		scanTimeMins = floor(scanTimeSecs / 60)
		scanTimeSecs =  mod(scanTimeSecs, 60)
		scanTimeHours = floor(scanTimeMins / 60)
		scanTimeMins = mod(scanTimeMins, 60)
	end

	--Hides the end of scan summary if user is not interested
	if (_G.nLog or printSummary) then

		local scanTime = " "
		local summaryLine
		local summary

		if scanTimeHours ~= 0 then
			scanTime = scanTime..scanTimeHours.._TRANS("PSS_Hours")
		end
		if scanTimeMins ~= 0 then
			scanTime = scanTime..scanTimeMins.._TRANS("PSS_Minutes")
		end
		if scanTimeSecs ~= 0 or (scanTimeHours == 0 and scanTimeMins == 0) then
			scanTime = scanTime..scanTimeSecs.._TRANS("PSS_Seconds")
		end

		if (wasEndPagesOnly) then
			summaryLine = (_TRANS("PSS_TailScan")):format(scanCount, scanTime)
		elseif (wasEarlyTerm) then
			summaryLine = (_TRANS("PSS_Incomplete")):format(scanCount, scanTime) --Auctioneer finished scanning {{%d}} auctions over {{%s}} before being stopped
		elseif (hadGetError) then
			summaryLine = (_TRANS("PSS_GetError")):format(scanCount, scanTime) --Auctioneer finished scanning {{%d}} auctions over {{%s}} but was not able to retrieve some auctions
		elseif wasIncomplete then -- any other incomplete (unknown reason)
			summaryLine = (_TRANS("PSS_Incomplete")):format(scanCount, scanTime) --Auctioneer finished scanning {{%d}} auctions over {{%s}} before being stopped
		else
			summaryLine = (_TRANS("PSS_Complete")):format(scanCount, scanTime) --Auctioneer finished scanning {{%d}} auctions over {{%s}}
		end
		if (printSummary) then _print(summaryLine) end
		summary = summaryLine

		summaryLine = "  {{"..oldCount.."}} ".._TRANS("PSS_StartItems").."{{"..dirtyCount.."}} ".._TRANS("PSS_MatchedItems").." {{"..currentCount.."}} ".._TRANS("PSS_AtEnd")
		if (printSummary) then _print(summaryLine) end
		summary = summary.."\n"..summaryLine

		if (sameCount > 0) then
			if (sameRecoveredCount > 0) then
				summaryLine = "  {{"..sameCount.."}} ".._TRANS("PSS_Unchanged_Missed")..sameRecoveredCount.._TRANS("PSS_Missed")
			else
				summaryLine = "  {{"..sameCount.."}} ".._TRANS("PSS_Unchanged_NoMissed")
			end
			if (printSummary) then _print(summaryLine) end
			summary = summary.."\n"..summaryLine
		end
		if (updateCount > 0) then
			if (updateRecoveredCount > 0) then
				summaryLine = "  {{"..updateCount.."}} ".._TRANS("PSS_Updated_Missed")..updateRecoveredCount.._TRANS("PSS_Missed")
			else
				summaryLine = "  {{"..updateCount.."}} ".._TRANS("PSS_Updated_NoMissed")
			end
			if (printSummary) then _print(summaryLine) end
			summary = summary.."\n"..summaryLine
		end
		if (newCount > 0) then
			summaryLine = "  {{"..newCount.."}} ".._TRANS("PSS_NewItems")
			if (printSummary) then _print(summaryLine) end
			summary = summary.."\n"..summaryLine
		end
		if (earlyDeleteCount+expiredDeleteCount > 0) then
			if expiredDeleteCount > 0 then
				summaryLine = "  {{"..earlyDeleteCount+expiredDeleteCount.."}} ".._TRANS("PSS_Removed_Expired").." {{"..expiredDeleteCount.."}} ".._TRANS("PSS_Expired")
			else
				summaryLine = "  {{"..earlyDeleteCount+expiredDeleteCount.."}} ".._TRANS("PSS_Removed_NoExpired")
			end
			if (printSummary) then _print(summaryLine) end
			summary = summary.."\n"..summaryLine
		end
		if (filterNewCount+filterOldCount > 0) then
			summaryLine = "  {{"..filterNewCount+filterOldCount.."}} ".._TRANS("PSS_Filtered")
			if (printSummary) then _print(summaryLine) end
			summary = summary.."\n"..summaryLine
		end
		if (filterDeleteCount > 0) then
			summaryLine = "  {{"..filterDeleteCount.."}} ".._TRANS("PSS_Filtered_Removed")
			if (printSummary) then _print(summaryLine) end
			summary = summary.."\n"..summaryLine
		end
		if (missedCount > 0 and not wasEndPagesOnly) then
			if wasIncomplete then
				summaryLine = "  ".._TRANS("PSS_Incomplete_Missed_1").." "..missedCount.."}} ".._TRANS("PSS_Incomplete_Missed_2")
			else
				summaryLine = "  {{"..missedCount.."}} ".._TRANS("PSS_MissedItems")
			end
			if (printSummary) then _print(summaryLine) end
			summary = summary.."\n"..summaryLine
		end



		if (_G.nLog) then
			local eTime = GetTime()
			_G.nLog.AddMessage("Auctioneer", "Scan", _G.N_INFO,
			"Scan "..TempcurQuery.qryinfo.id.."("..TempcurQuery.qryinfo.sig..") Committed",
			--("%s\nTotal Time: %f\nPaused Time: %f\nData Storage Time: %f\nData Store Time (our processing): %f\nTotal Commit Coroutine Execution Time: %f\nTotal Commit Coroutine Execution Time (excluding yields): %f"):format(summary, eTime-scanStarted, totalPaused, scanStoreTime, storeTime, GetTime()-commitStarted, totalProcessingTime))
			-- temporarily removed totalProcessingTime until other fixes go in and we can calculate it again
			("%s\nTotal Time: %f\nPaused Time: %f\nData Storage Time: %f\nData Store Time (our processing): %f\nTotal Commit Coroutine Execution Time: %f"):format(summary, eTime-scanStarted, totalPaused, scanStoreTime, storeTime, GetTime()-commitStarted))
		end
	end


	local TempcurScanStats = {
		source = "scan",
		serverKey = serverKey,
		scanCount = scanCount,
		oldCount = oldCount,
		sameCount = sameCount,
		newCount = newCount,
		updateCount = updateCount,
		matchedCount = dirtyCount,
		earlyDeleteCount = earlyDeleteCount,
		expiredDeleteCount = expiredDeleteCount,
		currentCount = currentCount,
		missedCount = missedCount,
		filteredCount = filterNewCount+filterOldCount,
		wasIncomplete = wasIncomplete or false,
		wasGetAll = wasGetAll or false,
		startTime = scanStartTime,
		endTime = endTimeStamp,
		started = scanStarted,
		paused = totalPaused,
		ended = GetTime(),
		elapsed = GetTime() - scanStarted - totalPaused,
		query = TempcurQuery,
		scanStoreTime = scanStoreTime,
		storeTime = storeTime
	}

	local scanstats = scandata.scanstats
	if not scanstats then
		scanstats = {}
		scandata.scanstats = scanstats
	end

	scanstats.LastScan = endTimeStamp
	if oldCount ~= currentCount or scanCount > 0 or dirtyCount > 0 then
		scanstats.ImageUpdated = endTimeStamp
	end
	if wasUnrestricted and not wasIncomplete then scanstats.LastFullScan = endTimeStamp end

	-- keep 2 old copies for compatibility
	scanstats[2] = scandata.scanstats[1]
	scanstats[1] = scandata.scanstats[0]
	scanstats[0] = TempcurScanStats

	-- Tell everyone that our stats are updated
	TempcurQuery.qryinfo.finished = true

	processBeginEndStats(processors, "complete", querySizeInfo, TempcurScanStats)

	_G.AucAdvanced.SendProcessorMessage("scanstats", TempcurScanStats)

	--Hide the progress indicator
	lib.ProgressBars("CommitProgressBar", nil, false)
	private.UpdateScanProgress(false, nil, nil, nil, nil, nil, TempcurQuery)
	lib.PopScan()
	CommitRunning = false
	if not private.curQuery then
		private.ResetAll()
	end
	_G.AucAdvanced.SendProcessorMessage("scanfinish", scanSize, TempcurQuery.qryinfo.sig, TempcurQuery.qryinfo, not wasIncomplete, TempcurQuery, TempcurScanStats)
end

local CoCommit, CoStore

local function CoroutineResume(...)
	local status, result = coroutine.resume(...)
	if not status and result then
		local msg = "Error occurred in coroutine: "..result
		if Swatter then
			Swatter.OnError(msg, nil, debugstack((...)))
		else
			geterrorhandler()(msg)
		end
	end
	return status, result
end

function private.Commit(wasEarlyTerm, wasEndPagesOnly, wasGetAll)
	private.StopStorePage()
	local curScan, curQuery, storeTime = private.curScan, private.curQuery, private.storeTime
	local scanStarted, scanStartTime, totalPaused = private.scanStarted, private.scanStartTime, private.totalPaused
	private.curQuery = nil
	private.curScan = nil
	private.isScanning = false
	if not (curQuery and curScan) then return end

	tinsert(private.CommitQueue, {
		Query = curQuery,
		Scan = curScan,
		wasIncomplete = wasEarlyTerm or wasEndPagesOnly,
		wasEarlyTerm = wasEarlyTerm,
		wasEndPagesOnly = wasEndPagesOnly,
		wasGetAll = wasGetAll,
		scanStarted = scanStarted,
		scanStartTime = scanStartTime,
		totalPaused = totalPaused,
		scanCommitTime = GetTime(),
		storeTime = storeTime
	})

	if not CoCommit or coroutine.status(CoCommit) == "dead" then
		CoCommit = coroutine.create(Commitfunction)
	end
	-- wait for the next update to resume CoCommit
end

function private.QuerySent(query, isSearch, ...)
	-- Tell everyone that our stats are updated
	_G.AucAdvanced.SendProcessorMessage("querysent", query, isSearch, ...)
	return ...
end

function private.FinishedPage(nextPage)
	-- Tell everyone that our stats are updated
	local modules = _G.AucAdvanced.GetAllModules("FinishedPage")
	for pos, engineLib in ipairs(modules) do
		local pOK, finished = pcall(engineLib.FinishedPage,nextPage)
		if (pOK) then
			if (finished~=nil) and (finished==false) then
				return false
			end
		else
			if (_G.nLog) then
				_G.nLog.AddMessage("Auctioneer", "Scan", _G.N_WARNING, ("FinishedPage %s Returned Error %s"):format(engineLib.GetName(), finished))
			end
		end
	end
	return true
end

function private.ScanPage(nextPage, really)
	if (private.isScanning) then
		local CanQuery, CanQueryAll = CanSendAuctionQuery()
		if not (CanQuery and private.FinishedPage(nextPage) and really) then
			private.scanNext = GetTime()
			private.scanNextPage = nextPage
			return
		end
		private.sentQuery = true
		private.queryStarted = GetTime()
		private.auctionItemListUpdated = false
		SortAuctionClearSort("list")
		private.Hook.QueryAuctionItems(private.curQuery.name or "",
			private.curQuery.minUseLevel or "", private.curQuery.maxUseLevel or "",
			private.curQuery.invType, private.curQuery.classIndex, private.curQuery.subclassIndex, nextPage,
			private.curQuery.isUsable, private.curQuery.quality)

		_G.AuctionFrameBrowse.page = nextPage

		private.verifyStart = nil
	end
end

do
	local ItemInfoCache = {}
	function private.ResetItemInfoCache()
		wipe(ItemInfoCache)
	end
	function private.GetItemInfoCache(itemId, itemLinksTried)
		-- we use itemId instead of itemLink - this reduces the number of entries in the cache
		local data = ItemInfoCache[itemId]
		if data then
			return data
		end
		if itemLinksTried and itemLinksTried[itemId] then
			-- if GetItemInfo previously failed for this itemId in this scanning pass (itemLinksTried is reset each pass)
			return
		end
		local _,_,rarity,iLevel,uLevel,iType,iSubtype,stack,equipLoc = GetItemInfo(itemId)
		if not iType then
			if itemLinksTried then
				itemLinksTried[itemId] = true
			end
			return
		end
		-- not all values are used; only store the ones we want
		data = {iType, iSubtype, Const.EquipEncode[equipLoc], iLevel, uLevel or 0}
		ItemInfoCache[itemId] = data
		return data
	end

	local cageType, cageSubtypeLookup, cageUseLevel
	function private.GetPetCageInfo()
		-- returns generic info for the Pet Cage item 82800 - info that is the same for every pet
		-- info for a specific pet will need to be extracted from the battlepet link
		-- cageSubtypeLookup can be used to convert numeric subtype to localized string for ISUB
		if cageType then
			return cageType, cageSubtypeLookup, cageUseLevel
		end
		local _,_,_,_,uLevel, iType = GetItemInfo(82800)
		if iType and uLevel then
			cageSubtypeLookup = Const.SUBCLASSES[Const.CLASSESREV[iType]]
			if cageSubtypeLookup then
				cageType = iType
				cageUseLevel = uLevel -- always 0, but we check here in case Blizzard changes it
				return cageType, cageSubtypeLookup, cageUseLevel
			end
		end
	end
end

--[[ private.GetAuctionItem(list, page, index, itemLinksTried, itemData)
	Returns itemData, with entries filled in from the GetAuctionItemX & GetItemInfo functions, plus some additional processing
	If page is provided, requires the same itemData table as was used for the same page/index combination previously in the current scan
		This is used during scanning, when retrying an auction entry - also enables some error checking
	If page is not provided, itemData may be an empty table (if reusing a table, wipe it first)

	When checking itemData for completeness, check the following entries:
	Const.LINK : if this is missing, most other entries will be missing too. Auction is unresolvable, but may be possible to resolve after a delay
		if it is present, it is likely that most other entries will be present too
	Const.ITEMID : if present, most useful entries should be present, particularly all prices
	Const.TLEFT : is one of the last entries to get resolved - only happens if no failures were detected

	Const.ITYPE : if missing then GetItemInfo failed for this itemId - may work if retried after a delay

	Const.SEED : if missing then other DecodeLink entries will be missing - indicates an unexpected link type, probably won't work if retried
		For battlepets will be 0, as DecodeLink doesn't work on battlepet links

	Const.SELLER : often missing, particularly during GetAll scans - may be resolvable after a delay, but may require a very long delay
		Note: this function does not replace a missing seller with ""
--]]
function private.GetAuctionItem(list, page, index, itemLinksTried, itemData)
	if not itemData then
		itemData = {}
	elseif itemData.NORETRY then
		return itemData
	end
	itemData[Const.FLAG] = itemData[Const.FLAG] or 0
	itemData[Const.ID] = itemData[Const.ID] or -1

	local isLogging = nLog and page and list == "list"
	if isLogging then
		if not itemData.PAGE then
			itemData.PAGE = page
			itemData.PAGEINDEX = index
		elseif itemData.PAGE ~= page or itemData.PAGEINDEX ~= index then
			-- We messed up the indexing - if we used the page parameter we should have used the same itemData table as before
			local msg = ("Page new=%d old=%d\nIndex new=%d old=%d"):format(page, itemData.PAGE, index, itemData.PAGEINDEX)
			nLog.AddMessage("Auctioneer", "Scan", N_ERROR, "GetAuctionItem called with invalid page/index",
				msg)
			geterrorhandler()("GetAuctionItem called with invalid page/index\n"..msg)
			return itemData
		end
	end

	local itemLink = GetAuctionItemLink(list, index)
	if itemLink then
		itemLink = AucAdvanced.SanitizeLink(itemLink)
		if itemData[Const.LINK] and itemData[Const.LINK] ~= itemLink then
			-- Not the same auction as was at this position in the scan before!
			-- Log and abort so we don't corrupt it
			if isLogging then
				nLog.AddMessage("Auctioneer", "Scan", N_ERROR, "GetAuctionItem ItemLink does not match link found previously at this index",
					("Page %d, Index %d\nOld link %s\nNew link %s\nOld ITEMID %s, MINBID %s, TLEFT %s, SELLER %s"):format(page, index, itemData[Const.LINK], itemLink,
						tostringall(itemData[Const.ITEMID], itemData[Const.MINBID], itemData[Const.TLEFT], itemData[Const.SELLER]))) -- one of these must be missing for us to need to retry
			end
			itemData.NORETRY = "Link changed"
			return itemData
		end
		itemData[Const.LINK] = itemLink
	else
		return itemData
	end

	local name, texture, count, quality, canUse, level, levelColHeader, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner, saleStatus, itemId = GetAuctionItemInfo(list, index)
	-- Check critical values (if we got those, assume we got the rest as well - except possibly owner)
	if not (itemId and minBid) then
		return itemData
	end
	if itemData[Const.MINBID] and itemData[Const.MINBID] ~= minBid then
		-- similar to itemLink changing, this means the auction is not the same one as was at this position before
		if isLogging then
			nLog.AddMessage("Auctioneer", "Scan", N_ERROR, "GetAuctionItem minBid does not match minBid found previously at this index",
				("Page %d, Index %d\nLink %s\nminBid old %s, new %s\nAll returns from GetAuctionItemInfo:\n%s"):format(page, index, itemLink, itemData[Const.MINBID], minBid,
				strjoin(",", tostringall(name, texture, count, quality, canUse, level, levelColHeader, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner, saleStatus, itemId))))
		end
		itemData.NORETRY = "MinBid changed"
		return itemData
	end

	itemData[Const.ITEMID] = itemId
	itemData[Const.MINBID] = minBid

	itemData[Const.NAME] = name
	itemData[Const.TEXTURE] = texture
	itemData[Const.QUALITY] = quality
	itemData[Const.CANUSE] = canUse
	itemData[Const.AMHIGH] = highBidder and true or false
	itemData[Const.MININC] = minIncrement
	itemData[Const.SELLER] = owner -- if this is nil, it will get set to "" at a later time

	if not count or (count == 0 and (list ~= "owner" or saleStatus ~= 1)) then -- the only time count may be 0 is for a sold auction on the "owner" list
		count = 1
	end
	itemData[Const.COUNT] = count

	bidAmount = bidAmount or 0
	itemData[Const.CURBID] = bidAmount
	buyoutPrice = buyoutPrice or 0
	itemData[Const.BUYOUT] = buyoutPrice
	local nextBid
	if bidAmount > 0 then
		nextBid = bidAmount + minIncrement
		if buyoutPrice > 0 and nextBid > buyoutPrice then
			nextBid = buyoutPrice
		end
	elseif minBid > 0 then
		nextBid = minBid
	else
		nextBid = 1
	end
	itemData[Const.PRICE] = nextBid

	local iLevel, uLevel
	-- use the iLevel or uLevel data from GetAuctionItemInfo, if available
	if level then
		if levelColHeader == "REQ_LEVEL_ABBR" then
			uLevel = level
		elseif levelColHeader == "ITEM_LEVEL_ABBR"  then
			iLevel = level
		end
		-- todo: handle other possible values for levelColHeader
	end

	if itemId == 82800 then -- "Pet Cage"
		-- requires special handling: the link will be a battlepet link, not an item link
		local cType, cSubtypeLookup, cUseLevel = private.GetPetCageInfo()
		if cType then
			itemData[Const.ITYPE] = cType -- string, localized to client
			itemData[Const.IEQUIP] = nil -- always nil for Pet Cages
			uLevel = uLevel or cUseLevel
			-- get the proper subtype
			local header, speciesID = strsplit(":", itemLink)
			if header:sub(-4) == "item" then
				-- extra special handling for certain bugged pet cages on the Beta, that have an "item" link type
				-- these are all Pet Cages for pets that cannot be caged! (created before Blizzard decided to make some pets non-tradeable)
				-- ### this section of code to be removed when the beta ends ###
				itemData[Const.ISUB] = "BattlePet"
			else
				speciesID = tonumber(speciesID)
				local _, _, petType = C_PetJournal.GetPetInfoBySpeciesID(speciesID)
				if petType then
					itemData[Const.ISUB] = cSubtypeLookup[petType]
				end
			end
			-- we should get the real iLevel from GetAuctionItemInfo (could be extracted from link, if required though)
		end
		-- Cannot use DecodeLink on a battlepet link, but entries should all be 0 anyway
		-- (note: there must be a hidden unique seed, but I can't find a way to access it)
		itemData[Const.SUFFIX] = 0
		itemData[Const.FACTOR] = 0
		itemData[Const.ENCHANT] = 0
		itemData[Const.SEED] = 0
	else

		local itemInfo = private.GetItemInfoCache(itemId, itemLinksTried) -- {iType, iSubtype, Const.EquipEncode[equipLoc], iLevel, uLevel}
		if itemInfo then
			itemData[Const.ITYPE] = itemInfo[1]
			itemData[Const.ISUB] = itemInfo[2]
			itemData[Const.IEQUIP] = itemInfo[3]
			-- use iLevel and/or uLevel from GetItemInfo, if not provided by GetAuctionItemInfo
			-- because we used itemId, it is possible for values from GetAuctionItemInfo to be different from those provided by GetItemInfo
			iLevel = iLevel or itemInfo[4]
			uLevel = uLevel or itemInfo[5]
		end

		if not itemData[Const.SEED] then
			local linkType, id, suffix, factor, enchant, seed = AucAdvanced.DecodeLink(itemLink)
			if linkType == "item" and id == itemId then
				itemData[Const.SUFFIX] = suffix
				itemData[Const.FACTOR] = factor
				itemData[Const.ENCHANT] = enchant
				itemData[Const.SEED] = seed
			else
				-- unrecognised link type - if this is happening then we'll need to investigate the link type
				-- and install a special exception for it (similar to battlepet links, as above)
				if isLogging then
					nLog.AddMessage("Auctioneer", "Scan", N_WARNING, "GetAuctionItem could not decode link",
						("Page %d, Index %d\nLink %s, itemId %d (from GetAuctionItemInfo)\ntype %s, id %s, suffix %s, factor %s, enchant %s, seed %s (from Decode)"):format(
							page, index, itemLink, itemId, tostringall(linkType, id, suffix, factor, enchant, seed)))
				end
				-- Note: SEED is still set to nil - scanner will discard this auction as Unresolved
			end
		end
	end

	itemData[Const.ULEVEL] = uLevel
	itemData[Const.ILEVEL] = iLevel

	--[[
		Returns Integer giving range of time left for query
		1 -- short time (Less than 30 mins)
		2 -- medium time (30 mins to 2 hours)
		3 -- long time (2 hours to 8 hours)
		4 -- very long time (8 hours+)
	]]
	itemData[Const.TLEFT] = GetAuctionItemTimeLeft(list, index)
	itemData[Const.TIME] = time()

	return itemData
end

function lib.GetAuctionItem(list, index, fillTable)
	if type(fillTable) == "table" then
		wipe(fillTable)
	else
		fillTable = nil
	end
	local itemData = private.GetAuctionItem(list, nil, index, nil, fillTable)
	if not itemData[Const.TLEFT] then
		-- missing TLEFT indicates a failure was detected for one of the GetAuctionItemX functions
		return
	end
	if not itemData[Const.SELLER] then
		itemData[Const.SELLER] = ""
	end
	-- for this function we will fill certain (less important) missing entries with 0 or ""
	if not itemData[Const.SEED] then
		itemData[Const.SUFFIX] = itemData[Const.SUFFIX] or 0
		itemData[Const.FACTOR] = itemData[Const.FACTOR] or 0
		itemData[Const.ENCHANT] = itemData[Const.ENCHANT] or 0
		itemData[Const.SEED] = 0
	end
	if not itemData[Const.ITYPE] then
		itemData[Const.ITYPE] = ""
		itemData[Const.ISUB] = ""
		itemData[Const.ULEVEL] = itemData[Const.ULEVEL] or 0
		itemData[Const.ILEVEL] = itemData[Const.ILEVEL] or 0
	end

	return itemData
end

function lib.GetAuctionSellItem(minBid, buyoutPrice, runTime)
	local itemLink = private.auctionItem
	local name, texture, count, quality, canUse, price = GetAuctionSellItemInfo();

	if name and itemLink then
		local linkType, itemId, itemSuffix, itemFactor, itemEnchant, itemSeed = _G.AucAdvanced.DecodeLink(itemLink)
		if linkType == "item" then
			itemLink = _G.AucAdvanced.SanitizeLink(itemLink)
			local _,_,_,itemLevel,level,itemType,itemSubType,_,itemEquipLoc = GetItemInfo(itemLink)
			local timeLeft = 4
			if runTime <= 12*60 then timeLeft = 3 end
			local curTime = time()

			return {
				itemLink, itemLevel, itemType, itemSubType, nil, minBid,
				timeLeft, curTime, name, texture, count, quality, canUse, level,
				minBid, 0, buyoutPrice, 0, nil, Const.PlayerName,
				0, -1, itemId, itemSuffix, itemFactor, itemEnchant, itemSeed
			}, price
		end
	end
end

--[[ Used to decide if we should retry scanning this auction
	returns: IsResolved, IsResolvedExceptSeller
	notes: assumes that if certain entries are present then auction is resolved (see notes for GetAuctionItem)
		ignores Const.ITYPE, as if that is missing it might be resolved by CommitFunction (i.e. don't need to retry during scanning)
		ignores Const.SEED, as if that is missing it will probably not be resolved by retrying (CommitFunction will decide if the entry is useable anyway)
--]]
function private.isComplete(itemData)
	local resolved = itemData and itemData[Const.TLEFT]
	return itemData[Const.SELLER] and resolved, resolved
end

local StorePageFunction = function()
	if (not private.curQuery) or (private.curQuery.name == "empty page") then
		return
	end

	if (not private.scanStarted) then private.scanStarted = GetTime() end
	local queryStarted = private.scanStarted
	local retrievalStarted = GetTime()

	--local RunTime = 0 -- todo: reinstate RunTime calculations
	private.sentQuery = false
	local page = _G.AuctionFrameBrowse.page
	if not private.curScan then
		private.curScan = {}
	end
	if not private.curPages then
		private.curPages = {}
	end

	if (_G.nLog) then
		_G.nLog.AddMessage("Auctioneer", "Scan", _G.N_INFO, ("StorePage For Page %d Started %fs after Query Start"):format(page, retrievalStarted - queryStarted), ("StorePage (Page %d) Called\n%f seconds have elapsed since scan start"):format(page, retrievalStarted - queryStarted))
	end

	if private.isGetAll then
		--[[
			pre-store delay before starting to store a getall query to give the client a bit of time to sort itself out
			we want to call it before GetNumAuctionItems, so we must use private.isGetAll for detection
		--]]
		coroutine.yield()
		if private.warningCanSendBug and CanSendAuctionQuery() then -- check it again after delay
			private.warningCanSendBug = nil
		end
	end

	local curQuery, curScan, curPages = private.curQuery, private.curScan, private.curPages
	local qryinfo = curQuery.qryinfo

	local EventFramesRegistered = {}
	local numBatchAuctions, totalAuctions = GetNumAuctionItems("list")
	local maxPages = ceil(totalAuctions / NUM_AUCTION_ITEMS_PER_PAGE)
	local isGetAll = false
	local isGetAllFail = false -- used to handle Blizzard bug {ADV-595}
	local hybridStartScanPage
	if (numBatchAuctions > NUM_AUCTION_ITEMS_PER_PAGE) then
		isGetAll = true
		maxPages = 1
		if totalAuctions ~= numBatchAuctions then
			-- Blizzard bug - these should be the same for a GetAll scan {ADV-595}
			if get("core.scan.hybridscans") and not private.warningCanSendBug then
				qryinfo.hybrid = true
				hybridStartScanPage = floor(numBatchAuctions / NUM_AUCTION_ITEMS_PER_PAGE) -- where to start paged part of hybrid scan from
				local wholePageAuctions = hybridStartScanPage * NUM_AUCTION_ITEMS_PER_PAGE -- where to end scanning GetAll to match up with paged part (this may be less than numBatchAuctions)
				if nLog then
					nLog.AddMessage("Auctioneer", "Scan", N_INFO, "StorePage commencing Hybrid scan",
						format("Batch size %d\nHybrid start page %d\nGetAll limit %d\nReported total auctions %d",
						numBatchAuctions, hybridStartScanPage, wholePageAuctions, totalAuctions))
				end

				numBatchAuctions = wholePageAuctions
				totalAuctions = numBatchAuctions
				_print("|cffff7f3fThe Server has not sent all data for this GetAll scan.|r")
				_print("Auctioneer will use Hybrid scanning to retrieve the missing auctions.")
			else
				isGetAllFail = true
				if nLog then
					nLog.AddMessage("Auctioneer", "Scan", N_INFO, "StorePage incomplete GetAll",
						format("Batch size %d\nReported total auctions %d",
						numBatchAuctions, totalAuctions))
				end
				totalAuctions = numBatchAuctions
				_print("|cffff7f3fThe Server has not sent all data for this GetAll scan. The scan will be incomplete.|r")
				_print("It may not be possible to complete a GetAll scan on this server at this time.")
			end
		end
		EventFramesRegistered = {GetFramesRegisteredForEvent("AUCTION_ITEM_LIST_UPDATE")}
		for _, frame in pairs(EventFramesRegistered) do
			frame:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE")
		end
		private.verifyStart = 1
		coroutine.yield()
	end

	--Update the progress indicator
	local elapsed = GetTime() - private.scanStarted - private.totalPaused
	--store queued scans to pass along on the callback, used by scanbutton and searchUI etc to display how many scans are still queued

	--page, maxpages, name  lets a module know when a "scan" they have queued is actually in progress. scansQueued lets a module know how may scans are left to go
	private.UpdateScanProgress(nil, totalAuctions, #curScan, elapsed, page+1, maxPages, curQuery) --page starts at 0 so we need to add +1

	-- coroutine speed limiter using debugprofilestop
	-- time in milliseconds: 1000/FPS * 0.8 (80% rough adjustment to allow for other stuff happening during the frame)
	local processingTime = 800 / get("scancommit.targetFPS")
	local debugprofilestop = debugprofilestop
	local nextPause = debugprofilestop() + processingTime
	local time = time
	local lastTime = time()

	local storecount = 0
	local sellerOnly = true

	local missedCounts, remissedCounts, switchCounts, mc = {}, {}, nil, nil
	for i = 1, Const.LASTENTRY do
		missedCounts[i] = 0
	end
	local resolvedCounts = {}
	for i = 1, Const.LASTENTRY do
		remissedCounts[i] = 0
	end

	if not private.breakStorePage and (page > qryinfo.page) then
		local itemLinksTried = {}
		local retries = { }
		for i = 1, numBatchAuctions do
			if isGetAll then -- only yield for GetAll scans
				if debugprofilestop() > nextPause or time() > lastTime then
					lib.ProgressBars("GetAllProgressBar", 100*storecount/numBatchAuctions, true)
					coroutine.yield()
					if private.breakStorePage then
						break
					end
					nextPause = debugprofilestop() + processingTime
					lastTime = time()
				end
			end

			local itemData = private.GetAuctionItem("list", page, i, itemLinksTried)

			if (itemData) then
				local isComplete, completeMinusSeller = private.isComplete(itemData)
				if (isComplete) then
					tinsert(curScan, itemData)
					storecount = storecount + 1
				else
					for mc = 1, Const.LASTENTRY do
						missedCounts[mc] = missedCounts[mc] + ((itemData[mc] and 0) or 1)
					end
					sellerOnly = sellerOnly and completeMinusSeller
					tinsert(retries, { i, itemData })
				end
			else
				for mc = 1, Const.LASTENTRY do
					missedCounts[mc] = missedCounts[mc] + 1
				end
				sellerOnly = false
				tinsert(retries, { i, nil })
			end
		end
		local maxTries = get('scancommit.ttl')
		local tryCount = 0
		if _G.nLog and (#retries > 0) then
			_G.nLog.AddMessage("Auctioneer", "Scan", _G.N_INFO, ("StorePage Requires Retries Page %d"):format(page),
				("Page: %d\nRetries Setting: %d\nUnresolved Entries:%d\nPage Elapsed Time: %.2fs"):format(page, maxTries, #retries, GetTime() - retrievalStarted))
		end

		local newRetries = { }
		local readCount = 1
		local needsRetries = #retries > 0
		while (needsRetries and tryCount < maxTries and ((not sellerOnly) or get("core.scan.sellernamedelay")) and not private.breakStorePage) do
			needsRetries = false
			sellerOnly = true
			itemLinksTried = {}
			tryCount = tryCount + 1
			-- must use GetTime to time this pause, as debugprofilestop is unsafe across yields
			local nextWait = GetTime() + 1
			while GetTime() < nextWait do
				coroutine.yield() -- yielding updates GetTime, so this loop will still work
				if private.breakStorePage then break end
			end
			if private.breakStorePage then break end

			nextPause = debugprofilestop() + processingTime
			lastTime = time()
			for _, i in ipairs(retries) do
				if isGetAll then
					if debugprofilestop() > nextPause or time() > lastTime then
						lib.ProgressBars("GetAllProgressBar", 100*storecount/numBatchAuctions, true)
						coroutine.yield()
						if private.breakStorePage then break end
						nextPause = debugprofilestop() + processingTime
						lastTime = time()
					end
				end

				readCount = readCount + 1

				local itemData = private.GetAuctionItem("list", page, i[1], itemLinksTried, i[2])

				if (itemData) then
					local isComplete, completeMinusSeller = private.isComplete(itemData)
					if (isComplete) then
						tinsert(curScan, itemData)
						storecount = storecount + 1
					else
						for mc = 1, Const.LASTENTRY do
							remissedCounts[mc] = remissedCounts[mc] + ((itemData[mc] and 0) or 1)
						end
						sellerOnly = sellerOnly and completeMinusSeller
						if not itemData.NORETRY then
							needsRetries = true
						end
						tinsert(newRetries, { i[1], itemData })
					end
				else
					for mc = 1, Const.LASTENTRY do
						remissedCounts[mc] = remissedCounts[mc] + ((itemData[mc] and 0) or 1)
					end
					sellerOnly = false
					tinsert(newRetries, i)
				end
			end

			if (#retries ~= #newRetries) then
				if _G.nLog then
					local resolvedMap = ""
					local missingMap = ""
					resolvedMap = ("%d"):format(missedCounts[1]-remissedCounts[1])
					missingMap = ("%d"):format(remissedCounts[1])
					for mc = 2, Const.LASTENTRY do
						resolvedMap = ("%s,%d"):format(resolvedMap,missedCounts[mc]-remissedCounts[mc])
						missingMap = ("%s,%d"):format(missingMap,remissedCounts[mc])
						if mc==Const.SELLER then
							resolvedMap = resolvedMap.."*"
							missingMap = missingMap.."*"
						elseif mc==Const.IEQUIP then
							resolvedMap = resolvedMap.."-"
							missingMap = missingMap.."-"
						end
					end

					_G.nLog.AddMessage("Auctioneer", "Scan", _G.N_INFO,
						("StorePage Retry Successful Page %d"):format(page),
						("Page: %d\nRetry Count: %d\nRecords Returned: %d\nRecords Left: %d\nPage Elapsed Time: %.2fs\nResolved:\n %s\nRemaining Unresolved:\n %s\nSeller Only Remaining: %s,   Wait on Only Seller: %s"):format(page, tryCount,
							#retries - #newRetries, #newRetries, GetTime() - retrievalStarted, resolvedMap, missingMap, sellerOnly and "True" or "False", get("core.scan.sellernamedelay") and "True" or "False"))
				end
				-- Found at least one.  Reset retry delay.
				tryCount = 0
			end
			for mc = 1, Const.LASTENTRY do
				missedCounts[mc]=remissedCounts[mc]
				remissedCounts[mc]=0
			end
			retries = newRetries
			newRetries = { }
		end


		local names_missed, all_missed, ld_and_names_missed, links_missed, link_data_missed = 0,0,0,0,0
		nextPause = debugprofilestop() + processingTime
		for _, i in ipairs(retries) do
			if isGetAll then
				if debugprofilestop() > nextPause then
					lib.ProgressBars("GetAllProgressBar", 100*storecount/numBatchAuctions, true)
					coroutine.yield()
					if private.breakStorePage then break end
					nextPause = debugprofilestop() + processingTime
				end
			end
			readCount = readCount + 1
			-- Put it to scan and let the commit routine deal with it.
			if (not i[2][Const.SELLER] and not i[2][Const.LINK]) then
				i[2][Const.SELLER] = ""
				all_missed = all_missed + 1
			elseif (not i[2][Const.SELLER] and not i[2][Const.ITEMID]) then
				i[2][Const.SELLER] = ""
				ld_and_names_missed = ld_and_names_missed + 1
			elseif (not i[2][Const.SELLER]) then
				i[2][Const.SELLER] = ""
				names_missed = names_missed + 1
			elseif (not i[2][Const.LINK]) then
				links_missed = links_missed + 1
			elseif (not i[2][Const.ITEMID]) then
				link_data_missed = link_data_missed + 1
			end
			tinsert(curScan, i[2])
		end

		if _G.nLog and #retries > 0 then
			_G.nLog.AddMessage("Auctioneer", "Scan", _G.N_INFO, ("StorePage Incomplete Resolution of Page %d"):format(page),
				("Page: %d\nRetries Setting: %d\nUnresolved Entries: %d\nMissing Everything: %d, Just Names: %d, Just Links (and link data): %d, Names and Link Data: %d, Link Data: %d"):format(page,
				maxTries, #retries, all_missed, names_missed, links_missed, ld_and_names_missed, link_data_missed ))
		end

		if (storecount > 0) then
			qryinfo.page = page
			curPages[page] = true -- we have pulled this page
		end

		if #retries > 0 then
			-- for info only; CommitFunction does its own 'incomplete' detection
			qryinfo.unresolved = (qryinfo.unresolved or 0) + all_missed + links_missed + link_data_missed + ld_and_names_missed
		end
	end


	if isGetAll then
		for _, frame in pairs(EventFramesRegistered) do
			frame:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
			local eventscript = frame:GetScript("OnEvent")
			if eventscript then
				pcall(eventscript, frame, "AUCTION_ITEM_LIST_UPDATE")
			end
		end
		EventFramesRegistered=nil
	end

	--Send a Processor event to modules letting them know we are done with the page
	_G.AucAdvanced.SendProcessorMessage("pagefinished", page)

	-- Clear GetAll changes made by StartScan
	if private.isGetAll then -- in theory private.isGetAll should be true iff (local) isGetAll is true -- unless total auctions <=50 (e.g. on PTR)
		lib.ProgressBars("GetAllProgressBar", 100, false)
		BrowseSearchButton:Show()
		_G.AucAdvanced.API.BlockUpdate(false)
		private.isGetAll = nil
	end

	coroutine.yield() -- update GetTime
	local endTime = GetTime()
	if not private.breakStorePage then
		-- Send the next page query or finish scanning
		if qryinfo.hybrid then
			if hybridStartScanPage then
				-- we've just done the GetAll part of the hybrid; start the paged part
				private.ScanPage(hybridStartScanPage)
			else
				if (page+1 < maxPages) then
					private.ScanPage(page + 1)
				else
					elapsed = endTime - private.scanStarted - private.totalPaused
					private.UpdateScanProgress(nil, totalAuctions, #curScan, elapsed, page+2, maxPages, curQuery)
					private.Commit(false, false, false)
				end
			end
		elseif isGetAll then
				elapsed = endTime - private.scanStarted - private.totalPaused
				private.UpdateScanProgress(nil, totalAuctions, #curScan, elapsed, page+2, maxPages, curQuery) -- page+2 signals that scan is done
				private.Commit(isGetAllFail, false, true)
				-- Clear the getall output. We don't want to create a new query so use the hook
				private.queryStarted = GetTime()
				private.Hook.QueryAuctionItems("empty page", "", "", nil, nil, nil, nil, nil, nil)
		elseif private.isScanning then
			if (page+1 < maxPages) then
				private.ScanPage(page + 1)
			else
				elapsed = endTime - private.scanStarted - private.totalPaused
				private.UpdateScanProgress(nil, totalAuctions, #curScan, elapsed, page+2, maxPages, curQuery)
				private.Commit(false, false, false)
			end
		elseif (maxPages == page+1) then
			local incomplete = false
			for i = 0, maxPages-1 do
				if not curPages[i] then
					incomplete = true
					break
				end
			end
			local wasEndOnly = false
			if incomplete and curPages[maxPages-1] then
				wasEndOnly = true
				for i = 1, maxPages-3 do
					if curPages[i] then
						wasEndOnly = false
						break
					end
				end
			end
			elapsed = endTime - private.scanStarted - private.totalPaused
			private.UpdateScanProgress(nil, totalAuctions, #curScan, elapsed, page+2, maxPages, curQuery)
			private.Commit(incomplete, wasEndOnly, false)
		elseif maxPages == 0 and page == 0 and numBatchAuctions == 0 then
			-- manual search, no auctions returned
			elapsed = endTime - private.scanStarted - private.totalPaused
			private.UpdateScanProgress(nil, totalAuctions, #curScan, elapsed, page+2, maxPages, curQuery)
			private.Commit(false, false, false)
		end
	end
	private.storeTime = endTime-retrievalStarted -- temp hack as RunTime calculation is broken - this will include paused and other non-processing time!
	if (_G.nLog) then
		_G.nLog.AddMessage("Auctioneer", "Scan", _G.N_INFO, ("StorePage Page %d Complete"):format(page),
--		("Query Elapsed: %fs\nThis Page Store Elapsed: %fs\nThis Page Code Execution Time: %fs"):format(endTime-queryStarted, endTime-retrievalStarted, RunTime))
		("Query Elapsed: %fs\nThis Page Store Elapsed: %fs"):format(endTime-queryStarted, endTime-retrievalStarted))
	end

	-- Report warning for Blizzard bug {ADV-595}
	-- (we wait til we're finished storing as much as we can, before asking the user to close the AH)
	if private.warningCanSendBug then
		private.warningCanSendBug = nil
		if not CanSendAuctionQuery() then
			_G.message("The Server is not responding correctly.\nClosing and reopening the Auctionhouse may fix this problem.")
		end
	end
end

function private.StopStorePage(silent)
	if not CoStore or coroutine.status(CoStore) ~= "suspended" then return end
	local isGetAll = private.isGetAll
	-- flag to break out of the loop, or prevent the loop being entered, within the coroutine
	private.breakStorePage = true
	while coroutine.status(CoStore) == "suspended" do
		CoroutineResume(CoStore)
	end
	private.breakStorePage = nil
	if isGetAll and not silent then
		_G.message("Warning: GetAll scan is incomplete because it was interrupted")
	end
end

function lib.StorePage()
	if not CoStore or coroutine.status(CoStore) == "dead" then
		CoStore = coroutine.create(StorePageFunction)
		CoroutineResume(CoStore)
	elseif coroutine.status(CoStore) == "suspended" then
		CoroutineResume(CoStore)
	end
end

--[[ _G.AucAdvanced.Scan.QuerySafeName(name)
	Library function to convert a name to the 'normalized' form used by scan querys
	Note: performs truncation on names over 63 bytes as QueryAuctionItems cannot handle longer strings
--]]
function lib.QuerySafeName(name)
	if type(name) == "string" and #name > 0 then
		if #name > 63 then
			if name:byte(63) >= 192 then -- UTF-8 multibyte first byte
				name = name:sub(1, 62)
			elseif name:byte(62) >= 224 then -- UTF-8 triplebyte first byte
				name = name:sub(1, 61)
			else
				name = name:sub(1, 63)
			end
		end
		return name:lower()
	end
end

--[[ _G.AucAdvanced.Scan.CreateQuerySig(name, minLevel, maxLevel, invTypeIndex, classIndex, subclassIndex, isUsable, qualityIndex)
	Library function to allow other modules to obtain a query sig
	Returns the sig that would be used in a scan with the specified parameters
--]]
function lib.CreateQuerySig(...)
	return private.CreateQuerySig(private.QueryScrubParameters(...))
end

function private.QueryScrubParameters(name, minLevel, maxLevel, invTypeIndex, classIndex, subclassIndex, isUsable, qualityIndex)
	-- Converts the parameters that we will store in our scanQuery table into a consistent format:
	-- converts each parameter to correct type;
	-- converts all strings to lowercase;
	-- converts all "" and 0 to nil;
	-- converts any invalid parameters to nil.
	name = lib.QuerySafeName(name)
	minLevel = tonumber(minLevel)
	if minLevel and minLevel < 1 then minLevel = nil end
	maxLevel = tonumber(maxLevel)
	if maxLevel and maxLevel < 1 then maxLevel = nil end
	classIndex = tonumber(classIndex)
	if classIndex and classIndex < 1 then classIndex = nil end
	if classIndex then
		subclassIndex = tonumber(subclassIndex)
		if subclassIndex and subclassIndex < 1 then subclassIndex = nil end
	else
		subclassIndex = nil -- subclassIndex is only valid if we have a classIndex
	end
	invTypeIndex = tonumber(invTypeIndex) or Const.EquipLocToInvIndex[invTypeIndex] -- accepts "INVTYPE_*" strings
	if invTypeIndex and invTypeIndex < 1 then invTypeIndex = nil end
	if isUsable and isUsable ~= 0 then
		isUsable = 1
	else
		isUsable = nil
	end
	qualityIndex = tonumber(qualityIndex)
	if qualityIndex and qualityIndex < 1 then qualityIndex = nil end

	return name, minLevel, maxLevel, invTypeIndex, classIndex, subclassIndex, isUsable, qualityIndex
end

function private.CreateQuerySig(name, minLevel, maxLevel, invTypeIndex, classIndex, subclassIndex, isUsable, qualityIndex)
	return strjoin("#",
		name or "",
		minLevel or "",
		maxLevel or "",
		invTypeIndex or "",
		classIndex or "",
		subclassIndex or "",
		isUsable or "",
		qualityIndex or ""
	) -- can use strsplit("#", sig) to extract params
end

function private.QueryCompareParameters(query, name, minLevel, maxLevel, invTypeIndex, classIndex, subclassIndex, isUsable, qualityIndex)
	-- Returns true if the parameters are identical to the values stored in the specified scanQuery table
	-- Use this function to avoid creating a duplicate scanQuery table
	-- Parameters must have been scrubbed first
	-- Note: to compare two scanQuery tables for equality, just compare the sigs
	if query.name == name -- note: both already converted to lowercase when scrubbed
	and query.minUseLevel == minLevel
	and query.maxUseLevel == maxLevel
	and query.classIndex == classIndex
	and query.subclassIndex == subclassIndex
	and query.quality == qualityIndex
	and query.invType == invTypeIndex
	and query.isUsable == isUsable
	then
		return true
	end
end

private.querycount = 0

function private.NewQueryTable(name, minLevel, maxLevel, invTypeIndex, classIndex, subclassIndex, isUsable, qualityIndex)
	-- Assumes the parameters have already been scrubbed
	local class, subclass
	local query, qryinfo = {}, {}
	query.qryinfo = qryinfo
	qryinfo.query = query

	query.name = name
	query.minUseLevel = minLevel
	query.maxUseLevel = maxLevel
	query.invType = invTypeIndex
	if classIndex then
		class = Const.CLASSES[classIndex]
		query.class = class
		query.classIndex = classIndex
	end
	if subclassIndex then
		subclass = Const.SUBCLASSES[classIndex][subclassIndex]
		query.subclass = subclass
		query.subclassIndex = subclassIndex
	end
	query.isUsable = isUsable
	query.quality = qualityIndex

	qryinfo.page = -1 -- use this to store highest page seen by query, and we haven't seen any yet.
	qryinfo.id = private.querycount
	private.querycount = private.querycount+1
	qryinfo.sig = private.CreateQuerySig(name, minLevel, maxLevel, invTypeIndex, classIndex, subclassIndex, isUsable, qualityIndex)

	-- the return value from GetFaction() can change when the Auctionhouse closes
	-- (Neutral Auctionhouse and "Always Home Faction" option enabled - this is on by default)
	-- store the current return value - this will be used throughout processing to avoid problems
	qryinfo.serverKey = GetFaction()

	local scanSize = false, ""
	if ((not query.class) and (not query.subclass) and (not query.minUseLevel)
			and (not query.maxUseLevel)
			and (not query.name) and (not query.isUsable)
			and (not query.invType) and (not query.quality)) then
		qryinfo.scanSize = "Full"
	elseif (query.name and query.class and query.subclass and query.quality) then
		qryinfo.scanSize = "Micro"
	else
		qryinfo.scanSize = "Partial"
	end
	query.pageIncomplete = false
	return query
end

private.Hook = {}
private.Hook.PlaceAuctionBid = PlaceAuctionBid
function PlaceAuctionBid(type, index, bid, ...)
	local itemData = lib.GetAuctionItem(type, index)
	if itemData then
		private.Unpack(itemData, statItem)
		local modules = _G.AucAdvanced.GetAllModules("ScanProcessors")
		for pos, engineLib in ipairs(modules) do
			if engineLib.ScanProcessors["placebid"] then
				pcall(engineLib.ScanProcessors["placebid"],"placebid", statItem, type, index, bid)
			end
		end
	end
	return private.Hook.PlaceAuctionBid(type, index, bid, ...)
end

private.Hook.ClickAuctionSellItemButton = ClickAuctionSellItemButton
function ClickAuctionSellItemButton(...)
	local ctype, itemID, itemLink = GetCursorInfo()
	if ctype == "item" then
		private.auctionItem = itemLink
	else
		private.auctionItem = nil
	end
	return private.Hook.ClickAuctionSellItemButton(...)
end

private.Hook.StartAuction = StartAuction
function StartAuction(minBid, buyoutPrice, runTime, ...)
	local itemData, price = lib.GetAuctionSellItem(minBid, buyoutPrice, runTime)
	if itemData then
		private.Unpack(itemData, statItem)
		local modules = _G.AucAdvanced.GetAllModules("ScanProcessors")
		for pos, engineLib in ipairs(modules) do
			if engineLib.ScanProcessors["newauc"] then
				pcall(engineLib.ScanProcessors["newauc"],"newauc", statItem, minBid, buyoutPrice, runTime, price)
			end
		end
	end
	return private.Hook.StartAuction(minBid, buyoutPrice, runTime, ...)
end

private.Hook.TakeInboxMoney = TakeInboxMoney
function TakeInboxMoney(index, ...)
	local invoiceType, itemName, playerName, bid, buyout, deposit, consignment = GetInboxInvoiceInfo(index)
	if invoiceType then
		local modules = _G.AucAdvanced.GetAllModules("ScanProcessors")
		local _,_, sender = GetInboxHeaderInfo(index)

		local faction = "Neutral"
		if sender:find(FACTION_ALLIANCE) then
			faction = "Alliance"
		elseif sender:find(FACTION_HORDE) then
			faction = "Horde"
		end

		for pos, engineLib in ipairs(modules) do
			if engineLib.ScanProcessors["aucsold"] then
				pcall(engineLib.ScanProcessors["aucsold"],"aucsold", faction, itemName, playerName, bid, buyout, deposit, consignment)
			end
		end
	end
	return private.Hook.TakeInboxMoney(index, ...)
end

private.Hook.QueryAuctionItems = QueryAuctionItems

local isSecure, taint = issecurevariable("CanSendAuctionQuery")
if not isSecure then
	private.warnTaint = taint
end
private.CanSend = CanSendAuctionQuery

function QueryAuctionItems(name, minLevel, maxLevel, invTypeIndex, classIndex, subclassIndex, page, isUsable, qualityIndex, GetAll, ...)
	if not private.isAuctioneerQuery and not get("core.scan.scanallqueries")then
		-- Optional bypass to handle compatibility problems with other AddOns
		return private.Hook.QueryAuctionItems(name, minLevel, maxLevel, invTypeIndex, classIndex, subclassIndex, page, isUsable, qualityIndex, GetAll, ...)
	end

	private.isAuctioneerQuery = nil
	if private.warnTaint then
		_print("\nAuctioneer:\n  WARNING, The CanSendAuctionQuery() function was tainted by the addon: {{"..private.warnTaint.."}}.\n  This may cause minor inconsistencies with scanning.\n  If possible, adjust the load order to get me to load first.\n ")
		private.warnTaint = nil
	end
	if not private.CanSend() then
		_print("Can't send query just at the moment")
		return
	end

	local isSearch = (BrowseSearchButton:GetButtonState() == "PUSHED")

	-- If we're getting called after we've sent a query, but before it's been stored, take this chance to save it.
	if private.sentQuery then
		lib.StorePage()
	end

	name, minLevel, maxLevel, invTypeIndex, classIndex, subclassIndex, isUsable, qualityIndex = private.QueryScrubParameters(
		name, minLevel, maxLevel, invTypeIndex, classIndex, subclassIndex, isUsable, qualityIndex)

	local query
	if private.curQuery then
		if not GetAll and not private.isGetAll
		and private.QueryCompareParameters(private.curQuery, name, minLevel, maxLevel, invTypeIndex, classIndex, subclassIndex, isUsable, qualityIndex) then
			private.StopStorePage()
			query = private.curQuery
			if (_G.nLog) then
				_G.nLog.AddMessage("Auctioneer", "Scan", _G.N_INFO, ("Sending existing query %d (%s)"):format(query.qryinfo.id, query.qryinfo.sig))
			end
		else
			private.Commit(true, false, false)
		end
	end
	if not query then
		query = private.NewQueryTable(name, minLevel, maxLevel, invTypeIndex, classIndex, subclassIndex, isUsable, qualityIndex)
		private.scanStartTime = time()
		private.scanStarted = GetTime()
		private.totalPaused = 0
		private.storeTime = 0
		private.curQuery = query
	end

	page = tonumber(page) or 0
	if (page==0) then
		local scanSize = query.qryinfo.scanSize
		if (query.qryinfo.NoSummary) then
			scanSize = "NoSum-"..scanSize
		end
		if (_G.nLog) then
			local queryType = "standard"
			if (GetAll) then queryType = "get all" end
			_G.nLog.AddMessage("Auctioneer", "Scan", _G.N_INFO, ("Sending new %s query %d (%s)"):format(queryType, query.qryinfo.id, query.qryinfo.sig))
		end
		_G.AucAdvanced.SendProcessorMessage("scanstart", scanSize, query.qryinfo.sig, query)
	end


	private.sentQuery = true
	lib.lastReq = GetTime()

	private.queryStarted = GetTime()
	private.auctionItemListUpdated = false
	return private.QuerySent(query, isSearch,
		private.Hook.QueryAuctionItems(
			name or "", minLevel or "", maxLevel or "", invTypeIndex, classIndex, subclassIndex,
			page, isUsable, qualityIndex, GetAll, ...))
end

-- Function to indicate that the next call to QueryAuctionItems comes from Auctioneer itself.
function lib.SetAuctioneerQuery()
	private.isAuctioneerQuery = true
end

function lib.SetPaused(pause)
	if private.isGetAll then
		-- A GetAll scan cannot be Popped or Pushed
		assert(not private.isPaused)
		if pause then
			_print("Scan cannot be paused/unpaused because it is a GetAll scan")
		end
		return
	end
	if pause then
		if private.isPaused then return end
		lib.PushScan()
		private.isPaused = true
	elseif private.isPaused then
		lib.PopScan()
		private.isPaused = false
	end
end

private.unexpectedClose = false
local timeoutCanSend = 0 -- part of fix for Blizzard bug {ADV-595}

function private.OnUpdate(me, dur)
	if CoCommit then
		local costat = coroutine.status(CoCommit)
		if costat == "suspended" then
			CoroutineResume(CoCommit)
		elseif costat == "dead" then
			if #private.CommitQueue > 0 then
				CoCommit = coroutine.create(Commitfunction)
				CoroutineResume(CoCommit)
			else
				CoCommit = nil
			end
		end
	end
	local auctionFrame = _G.AuctionFrame
	if not auctionFrame then return end
	if private.isPaused then return end
	local isVisibleAucFrame = auctionFrame:IsVisible()

	if private.queueScan then
		if isVisibleAucFrame and CanSendAuctionQuery() then
			local queued = private.queueScan
			private.queueScan = nil
			lib.StartScan(unpack(queued, 1, private.queueScanParams)) -- explicit start and end points as some entries may be nil
		end
		return
	end

	if CoStore and coroutine.status(CoStore) == "suspended" and isVisibleAucFrame then
		CoroutineResume(CoStore)
	end
	if private.scanNext then
		if isVisibleAucFrame and CanSendAuctionQuery() then
			local nextPage = private.scanNextPage
			private.scanNext = nil
			private.ScanPage(nextPage, true)
		end
		return
	end

	if isVisibleAucFrame then
		if private.unexpectedClose then
			private.unexpectedClose = false
			lib.PopScan()
			return
		end

		if private.sentQuery and private.auctionItemListUpdated then
			if CanSendAuctionQuery() then
				timeoutCanSend = 0
				lib.StorePage()
			elseif timeoutCanSend > 15 then
				-- Fix for Blizzard Auctionhouse bug {ADV-595}
				-- CanSendAuctionQuery continues to return nil indefinitely. We use a timeout
				timeoutCanSend = 0
				private.warningCanSendBug = true -- further handling required by StorePageFunction
				lib.StorePage()
			else
				-- part of fix for Blizzard bug {ADV-595}
				timeoutCanSend = timeoutCanSend + dur
			end
 		end
	elseif private.curQuery then
		lib.Interrupt()
	end
end
private.updater = CreateFrame("Frame", nil, UIParent)
private.updater:SetScript("OnUpdate", private.OnUpdate)

function lib.Cancel()
	if (private.curQuery) then
		_print("Cancelling current scan")
		private.Commit(true, false, false)
	end
	private.ResetAll()
end

function lib.Interrupt()
	if private.curQuery and not _G.AuctionFrame:IsVisible() then
		if private.isGetAll then
			-- GetAll cannot be pushed/popped so we have to commit here instead
			private.Commit(true, false, true)
			private.sentQuery = false
			if private.isGetAll then
				-- If the StorePage function didn't run, we need to cleanup here instead
				lib.ProgressBars("GetAllProgressBar", nil, false)
				BrowseSearchButton:Show()
				_G.AucAdvanced.API.BlockUpdate(false)
				private.isGetAll = nil
			end
		elseif private.isScanning then
			private.unexpectedClose = true
			lib.PushScan()
		else
			private.Commit(true, false, false)
			private.sentQuery = false
		end
	end
end

function lib.Abort()
	if (private.curQuery) then
		_print("Aborting current scan")
	end
	private.ResetAll()
end

function private.ResetAll()
	private.StopStorePage(true)

	-- Fallback in case private.isGetAll and related actions were not cleared during processing
	lib.ProgressBars("GetAllProgressBar", nil, false)
	BrowseSearchButton:Show()
	_G.AucAdvanced.API.BlockUpdate(false)
	private.isGetAll = nil

	local oldquery = private.curQuery
	private.curQuery = nil
	private.curScan = nil
	private.isPaused = nil
	private.sentQuery = nil
	private.isScanning = false
	private.unexpectedClose = false

	private.UpdateScanProgress(false, nil, nil, nil, nil, nil, oldquery)
	if CommitRunning then
		return
	end
	private.scanStartTime = nil
	private.scanStarted = nil
	private.totalPaused = nil
	private.storeTime = nil
	private.curPages = nil
	private.scanStack = nil

	private.Pausing = nil
end

-- In the absence of a proper API function to do it, it's necessary to inspect an item's tooltip to
-- figure out if it's usable by the player
local ItemUsableTooltip = {
	tooltipFrame = nil,
	fontString = {},
	maxLines = 100,

	CanUse = function(this, link)
		-- quick level check first
		local minLevel = select(5, GetItemInfo(link)) or 0
		if UnitLevel("player") < minLevel then
			return false
		end

		-- set up if not done already
		if not this.tooltipFrame then
			this.tooltipFrame = CreateFrame("GameTooltip")
			this.tooltipFrame:SetOwner(UIParent, "ANCHOR_NONE")
			for i = 1, this.maxLines do
				this.fontString[i] = {}
				for j = 1, 2 do
					this.fontString[i][j] = this.tooltipFrame:CreateFontString()
					this.fontString[i][j]:SetFontObject(GameFontNormal)
				end
				this.tooltipFrame:AddFontStrings(this.fontString[i][1], this.fontString[i][2])
			end
			this.minLevelPattern = string.gsub(ITEM_MIN_LEVEL, "(%%d)", "(.+)")
		end

		-- clear tooltip
		local numLines
		numLines = math.min(this.maxLines, this.tooltipFrame:NumLines())
		for i = 1, numLines do
			for j = 1, 2 do
				this.fontString[i][j]:SetText()
				this.fontString[i][j]:SetTextColor(0, 0, 0)
			end
		end

		-- populate tooltip
		this.tooltipFrame:SetHyperlink(link)

		-- search tooltip for red text
		numLines = math.min(this.maxLines, this.tooltipFrame:NumLines())
		for i = 1, numLines do
			for j = 1, 2 do
				local r, g, b = this.fontString[i][j]:GetTextColor()
				if r > 0.8 and g < 0.2 and b < 0.2 then
					-- item is not usable, with one exception: if it doesn't have a level
					-- requirement, red "requires level xxx" text refers to some other item,
					-- e.g. that created by a recipe
					local text = string.lower(this.fontString[i][j]:GetText())
					if not (minLevel == 0 and string.find(text, this.minLevelPattern)) then
						return false
					end
				end
			end
		end

		return true
	end,
}

-- Caching wrapper for ItemUsableTooltip. Invalidates cache when certain events occur
-- (player levels up, learns a new recipe, etc.)
local ItemUsableCached = {
	eventFrame = nil,
	patterns = {},
	cache = {},
	tooltip = ItemUsableTooltip,

	OnEvent = function(this, event, arg1, ...)
		local dirty = false
		-- print("got event " .. event .. ", arg1 " .. arg1)
		if event == "CHAT_MSG_SYSTEM" or event == "CHAT_MSG_SKILL" then
			for _, pattern in pairs(this.patterns) do
				if string.find(arg1, pattern) then
					dirty = true
					break
				end
			end
		elseif event == "PLAYER_LEVEL_UP" then
			dirty = true
		end

		if dirty then
			-- print("invalidating")
			this.cache = {}
		end
	end,

	RegisterChatString = function(this, chatString)
		local pattern = chatString
		pattern = gsub(pattern, "%%s", ".+")
		pattern = gsub(pattern, "%%d", ".+")
		pattern = gsub(pattern, "%%%d+%$s", ".+")
		pattern = gsub(pattern, "%%%d+%$d", ".+")
		pattern = gsub(pattern, "|3%-%d+%(%%s%)", ".+")
		tinsert(this.patterns, pattern)
	end,

	CanUse = function(this, link)
		-- set up if not done already
		if not this.eventFrame then
			this.eventFrame = CreateFrame("Frame")

			-- forward events from frame to self
			this.eventFrame.forwardEventsTo = this
			this.eventFrame:SetScript(
				"OnEvent",
				function(eventFrame, ...)
					eventFrame.forwardEventsTo:OnEvent(...)
				end)

			-- register events and chat patterns
			this.eventFrame:RegisterEvent("CHAT_MSG_SYSTEM")
			this.eventFrame:RegisterEvent("CHAT_MSG_SKILL")
			this.eventFrame:RegisterEvent("PLAYER_LEVEL_UP")

			this:RegisterChatString(_G.ERR_LEARN_ABILITY_S)
			this:RegisterChatString(_G.ERR_LEARN_RECIPE_S)
			this:RegisterChatString(_G.ERR_LEARN_SPELL_S)
			this:RegisterChatString(_G.ERR_SPELL_UNLEARNED_S)
			this:RegisterChatString(_G.ERR_SKILL_GAINED_S)
			this:RegisterChatString(_G.ERR_SKILL_UP_SI)
		end

		local linkType, id = strsplit(":", link)
		linkType = linkType:sub(-4) -- get last 4 characters
		if linkType == "epet" then
			-- battlepet : assume anyone can use it
			-- todo: do we need to check if user has enabled battlepets?
			-- I think you can still "use" the Pet Cage to learn the pet, even if you haven't enabled battlepets yet
			-- todo: what if the user has reached the max pet limit?
			return true
		elseif linkType ~= "item" then
			return
		end
		id = tonumber(id)
		if not id then return end

		-- check cache first. failing that, do a tooltip scan
		if this.cache[id] == nil then
			-- print("miss " .. link)
			this.cache[id] = this.tooltip:CanUse(link)
		else
			-- print("hit  " .. link)
		end

		return this.cache[id]
	end,
}

private.itemUsable = ItemUsableCached
function private.CanUse(link)
	return private.itemUsable:CanUse(link)
end

function lib.GetScanCount()
	local scanCount = 0
	if (private.scanStack) then scanCount = #private.scanStack end
	if (private.isScanning) then
		scanCount = scanCount + 1
	end
	return scanCount
end

function lib.GetStackedScanCount()
	local scanCount = 0
	if (private.scanStack) then scanCount = #private.scanStack end
	return scanCount
end

function lib.AHClosed()
	lib.Interrupt()
end

function lib.Logout()
	_G.AucAdvancedData.Scandata = nil -- delete obsolete data. it's here because CoreScan doesn't have an OnLoad processor
	if (private.curQuery) then
		private.Commit(true, false, false)
	end
	if CoCommit then
		while coroutine.status(CoCommit) == "suspended" do
			CoroutineResume(CoCommit)
		end
	end
end


coremodule.Processors = {}
function coremodule.Processors.scanstats(event, scanstats)
	private.clearImageCaches(event, scanstats)
end

function coremodule.Processors.auctionclose(event)
	-- clearup memory usage when AH closed
	private.ResetItemInfoCache()
	private.clearImageCaches(event)
end

if Resources.PlayerFaction == "Neutral" then
	coremodule.Processors.factionselect = function(event)
		private.clearImageCaches(event)
	end
end


internal.Scan = {}
function internal.Scan.NotifyItemListUpdated()
	if private.scanStarted then
		private.auctionItemListUpdated = true
		--[[ commented out for now - this gets really spammy
		if (_G.nLog) then
			local startTime = GetTime()
			_G.nLog.AddMessage("Auctioneer", "Scan", _G.N_INFO, ("NotifyItemListUpdated Called %fs after Query Start"):format(startTime - private.scanStarted), ("NotifyItemListUpdated Called %f seconds from query to be called"):format(startTime - private.scanStarted))
		end
		--]]
	end
end

function internal.Scan.NotifyOwnedListUpdated()
--	if private.scanStarted then
--		if (_G.nLog) then
--			local startTime = GetTime()
--			_G.nLog.AddMessage("Auctioneer", "Scan", _G.N_INFO, ("NotifyOwnedListUpdated Called %fs after Query Start"):format(startTime - private.scanStarted), ("NotifyOwnedListUpdated Called %f seconds from query to be called"):format(startTime - private.scanStarted))
--		end
--	end
end

internal.Scan.Logout = lib.Logout
internal.Scan.AHClosed = lib.AHClosed

_G.AucAdvanced.RegisterRevision("$URL: http://svn.norganna.org/auctioneer/trunk/Auc-Advanced/CoreScan.lua $", "$Rev: 5352 $")
