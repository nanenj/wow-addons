--[[
	Auctioneer - Standard Deviation Statistics module
	Version: 5.15.5365 (LikeableLyrebird)
	Revision: $Id: StatStdDev.lua 5360 2012-09-21 09:53:20Z brykrys $
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
if not AucAdvanced then return end

local libType, libName = "Stat", "StdDev"
local lib,parent,private = AucAdvanced.NewModule(libType, libName)
if not lib then return end

local aucPrint,decode,_,_,replicate,empty,get,set,default,debugPrint,fill, _TRANS = AucAdvanced.GetModuleLocals()
local Resources = AucAdvanced.Resources
local AucGetStoreKeyFromLink = AucAdvanced.API.GetStoreKeyFromLink

local PET_BAND = 5
local MAX_DATAPOINTS = 100

local tonumber,strsplit,select,pairs=tonumber,strsplit,select,pairs
local setmetatable=setmetatable
local wipe=wipe
local floor,ceil,abs=floor,ceil,abs
local concat=table.concat
local tinsert,tremove=table.insert,table.remove
-- GLOBALS: AucAdvancedStatStdDevData


local SSDRealmData

local cache = {}

local ZValues = {.063, .126, .189, .253, .319, .385, .454, .525, .598, .675, .756, .842, .935, 1.037, 1.151, 1.282, 1.441, 1.646, 1.962, 20, 20000}

-- Wrapper around AucAdvanced.API.GetStoreKeyFromLink to customize it for Stat-StdDev
local GetStoreKey = function(link)
	local id, property, linktype = AucGetStoreKeyFromLink(link, PET_BAND)
	if linktype == "item" then
		-- use number here so we don't need to convert older database
		return tonumber(id), property
	elseif linktype == "battlepet" then
		-- add "P" marker to battlepet ID
		return "P"..id, property
	end
end

function lib.CommandHandler(command, ...)
	local serverKey = Resources.ServerKeyCurrent
	local _,_,keyText = AucAdvanced.SplitServerKey(serverKey)
	if (command == "help") then
		aucPrint(_TRANS('SDEV_Help_SlashHelp1') )--Help for Auctioneer - StdDev
		local line = AucAdvanced.Config.GetCommandLead(libType, libName)
		aucPrint(line, "help}} - ".._TRANS('SDEV_Help_SlashHelp2') ) --this StdDev help
		aucPrint(line, "clear}} - ".._TRANS('SDEV_Help_SlashHelp3'):format(keyText) ) --clear current %s StdDev price database
	elseif (command == "clear") then
		lib.ClearData(serverKey)
	end
end

lib.Processors = {}
function lib.Processors.itemtooltip(callbackType, ...)
	lib.ProcessTooltip(...)
end
lib.Processors.battlepettooltip = lib.Processors.itemtooltip
function lib.Processors.config(callbackType, ...)
	--Called when you should build your Configator tab.
	private.SetupConfigGui(...)
end
function lib.Processors.scanstats(callbackType, ...)
	wipe(cache)
end

lib.ScanProcessors = {}
function lib.ScanProcessors.create(operation, itemData, oldData)
	if not get("stat.stddev.enable") then return end

	-- We're only interested in items with buyouts.
	local buyout = itemData.buyoutPrice
	if not buyout or buyout == 0 then return end
	if (itemData.stackSize > 1) then
		buyout = buyout.."/"..itemData.stackSize
	else
		buyout = tostring(buyout)
	end

	-- Get the key for this item and find it's stats.
	local keyId, property = GetStoreKey(itemData.link)
	if not keyId then return end
	local serverKey = Resources.ServerKeyCurrent
	if not SSDRealmData[serverKey] then SSDRealmData[serverKey] = {} end
	local stats = private.UnpackStats(SSDRealmData[serverKey][keyId])
	if not stats[property] then stats[property] = {} end

	if #stats[property] >= MAX_DATAPOINTS then
		tremove(stats[property], 1)
	end
	tinsert(stats[property], buyout)
	SSDRealmData[serverKey][keyId] = private.PackStats(stats)
end

local BellCurve = AucAdvanced.API.GenerateBellCurve()
-----------------------------------------------------------------------------------
-- The PDF for standard deviation data, standard bell curve
-----------------------------------------------------------------------------------
function lib.GetItemPDF(hyperlink, serverKey)
	if not get("stat.stddev.enable") then return end
	-- Get the data
	local average, mean, _, stddev, variance, count, confidence = lib.GetPrice(hyperlink, serverKey)

	if not (average and stddev) or average == 0 or stddev == 0 then
		return nil;                 -- No data, cannot determine pricing
	end

	local lower, upper = average - 3 * stddev, average + 3 * stddev;

	-- Build the PDF based on standard deviation & average
	BellCurve:SetParameters(average, stddev);
	return BellCurve, lower, upper;   -- This has a __call metamethod so it's ok
end

-----------------------------------------------------------------------------------

function private.GetCfromZ(Z)
	--C = 0.05*i
	if (not Z) then
		return .05
	end
	if (Z > 10) then
		return .99
	end
	local i = 1
	while Z > ZValues[i] do
		i = i + 1
	end
	if i == 1 then
		return .05
	else
		i = i - 1 + ((Z - ZValues[i-1]) / (ZValues[i] - ZValues[i-1]))
		return i*0.05
	end
end

local datapoints_price = {}	-- used temporarily in .GetPrice() to avoid unpacking strings multiple times
local datapoints_stack = {}

function lib.GetPrice(hyperlink, serverKey)
	if not get("stat.stddev.enable") then return end

	local keyId, property = GetStoreKey(hyperlink)
	if not keyId then return end

	if not serverKey then serverKey = Resources.ServerKeyCurrent end

	if not SSDRealmData[serverKey] then return end
	if not SSDRealmData[serverKey][keyId] then return end

	local cacheKey = serverKey ..":"..keyId..":"..property
	if cache[cacheKey] then
		return unpack(cache[cacheKey], 1, 7)
	end

	local stats = private.UnpackStats(SSDRealmData[serverKey][keyId])
	if not stats[property] then return end

	local count = #stats[property]
	if (count < 1) then return end

	local total, number = 0, 0
	for i = 1, count do
		local price, stack = strsplit("/", stats[property][i])
		price = tonumber(price) or 0
		stack = tonumber(stack) or 1
		if (stack < 1) then stack = 1 end
		datapoints_price[i] = price		-- cache these for further processing below (so they don't need to strsplit etc)
		datapoints_stack[i] = stack
		total = total + price
		number = number + stack
	end
	local mean = total / number

	if (count < 2) then
		return nil, mean, false, 0, 0, count, 0
	end

	local variance = 0
	for i = 1, count do
		variance = variance + ((mean - datapoints_price[i]/datapoints_stack[i]) ^ 2);
	end

	variance = variance / count;
	local stdev = variance ^ 0.5

	local deviation = 1.5 * stdev

	total = 0	-- recompute them from entries inside the allowed deviation
	number = 0

	for i = 1, count do
		local price,stack = datapoints_price[i], datapoints_stack[i]
		if abs((price/stack) - mean) < deviation then
			total = total + price
			number = number + stack
		end
	end

	local confidence = .01
	local average
	if (number > 0) then	-- number<1  will happen if we have e.g. two big clusters: one at 1g and one at 10g
		average = total / number
		confidence = (.15*average)*(number^0.5)/(stdev)
		confidence = private.GetCfromZ(confidence)
	end

	cache[cacheKey] = { average, mean, false, stdev, variance, count, confidence }
	return average, mean, false, stdev, variance, count, confidence
end

function lib.GetPriceColumns()
	return "Average", "Mean", false, "Std Deviation", "Variance", "Count", "Confidence"
end

local array = {}
function lib.GetPriceArray(hyperlink, serverKey)
	if not get("stat.stddev.enable") then return end
	-- Clean out the old array
	wipe(array)

	-- Get our statistics
	local average, mean, _, stdev, variance, count, confidence = lib.GetPrice(hyperlink, serverKey)

	-- These 3 are the ones that most algorithms will look for
	array.price = average or mean
	array.seen = count
	array.confidence = confidence
	-- This is additional data
	array.normalized = average
	array.mean = mean
	array.deviation = stdev
	array.variance = variance

	-- Return a temporary array. Data in this array is
	-- only valid until this function is called again.
	return array
end

function private.SetupConfigGui(gui)
	local id = gui:AddTab(lib.libName, lib.libType.." Modules")
	--gui:MakeScrollable(id)

	gui:AddHelp(id, "what stddev stats",
		_TRANS('SDEV_Help_StdDevStats') ,--What are StdDev stats?
		_TRANS('SDEV_Help_StdDevStatsAnswer') --StdDev stats are the numbers that are generated by the StdDev module consisting of a filtered Standard Deviation calculation of item cost.
		)

	--all options in here will be duplicated in the tooltip frame
	function private.addTooltipControls(id)
		gui:AddHelp(id, "filtered stddev",
			_TRANS('SDEV_Help_Filtered') ,--What do you mean filtered?
			_TRANS('SDEV_Help_FilteredAnswer') --Items outside a (1.5*Standard) variance are ignored and assumed to be wrongly priced when calculating the deviation.
			)

		gui:AddHelp(id, "what standard deviation",
			_TRANS('SDEV_Help_StandardDeviationCalculation') ,--What is a Standard Deviation calculation?
			_TRANS('SDEV_Help_StandardDeviationCalculationAnswer') --In short terms, it is a distance to mean average calculation.
			)

		gui:AddHelp(id, "what normalized",
			_TRANS('SDEV_Help_Normalized') ,--What is the Normalized calculation?
			_TRANS('SDEV_Help_NormalizedAnswer') --In short terms again, it is the average of those values determined within the standard deviation variance calculation.
			)

		gui:AddHelp(id, "what confidence",
			_TRANS('SDEV_Help_Confidence') ,--What does confidence mean?
			_TRANS('SDEV_Help_ConfidenceAnswer') --Confidence is a value between 0 and 1 that determines the strength of the calculations (higher the better).
			)

		gui:AddHelp(id, "why multiply stack size stddev",
			_TRANS('SDEV_Help_WhyMultiplyStack') ,--Why have the option to multiply by stack size?
			_TRANS('SDEV_Help_WhyMultiplyStackAnswer') --The original Stat-StdDev multiplied by the stack size of the item, but some like dealing on a per-item basis.
			)

		gui:AddControl(id, "Header",     0,   _TRANS('SDEV_Interface_StdDevOptions') )--StdDev options
		gui:AddControl(id, "Note",       0, 1, nil, nil, " ")
		gui:AddControl(id, "Checkbox",   0, 1, "stat.stddev.enable", _TRANS('SDEV_Interface_EnableStdDevStats') )--Enable StdDev Stats
		gui:AddTip(id, _TRANS('SDEV_HelpTooltip_EnableStdDevStats') )--Allow StdDev to gather and return price data
		gui:AddControl(id, "Note",       0, 1, nil, nil, " ")

		gui:AddControl(id, "Checkbox",   0, 4, "stat.stddev.tooltip", _TRANS('SDEV_Interface_Show') )--Show stddev stats in the tooltips?
		gui:AddTip(id, _TRANS('SDEV_HelpTooltip_Show') )--Toggle display of stats from the StdDev module on or off
		gui:AddControl(id, "Checkbox",   0, 6, "stat.stddev.mean", _TRANS('SDEV_Interface_DisplayMean') )--Display Mean
		gui:AddTip(id, _TRANS('SDEV_HelpTooltip_DisplayMean') )--Toggle display of 'Mean' calculation in tooltips on or off
		gui:AddControl(id, "Checkbox",   0, 6, "stat.stddev.normal", _TRANS('SDEV_Interface_DisplayNormalized') )--Display Normalized
		gui:AddTip(id, _TRANS('SDEV_HelpTooltip_DisplayNormalized') )--Toggle display of 'Normalized' calculation in tooltips on or off'
		gui:AddControl(id, "Checkbox",   0, 6, "stat.stddev.stdev", _TRANS('SDEV_Interface_DisplayStandardDeviation') )--Display Standard Deviation
		gui:AddTip(id,_TRANS('SDEV_HelpTooltip_DisplayStandardDeviation') )--Toggle display of 'Standard Deviation' calculation in tooltips on or off
		gui:AddControl(id, "Checkbox",   0, 6, "stat.stddev.confid", _TRANS('SDEV_Interface_DisplayConfidence') )--Display Confidence
		gui:AddTip(id,_TRANS('SDEV_HelpTooltip_DisplayConfidence') )--Toggle display of 'Confidence' calculation in tooltips on or off
		gui:AddControl(id, "Note",       0, 1, nil, nil, " ")
		gui:AddControl(id, "Checkbox",   0, 4, "stat.stddev.quantmul", _TRANS('SDEV_Interface_MultiplyStack') )--Multiply by Stack Size
		gui:AddTip(id,_TRANS('SDEV_HelpTooltip_MultiplyStack') )--Multiplies by current stack size if on
		gui:AddControl(id, "Note",       0, 1, nil, nil, " ")
	end
	--This is the Tooltip tab provided by aucadvnced so all tooltip configuration is in one place
	local tooltipID = AucAdvanced.Settings.Gui.tooltipID

	--now we create a duplicate of these in the tooltip frame
	private.addTooltipControls(id)
	if tooltipID then private.addTooltipControls(tooltipID) end
end

function lib.ProcessTooltip(tooltip, hyperlink, serverKey, quantity, decoded, additional, order)
	-- In this function, you are afforded the opportunity to add data to the tooltip should you so
	-- desire. You are passed a hyperlink, and it's up to you to determine whether or what you should
	-- display in the tooltip.

	if not get("stat.stddev.tooltip") then return end

	if not quantity or quantity < 1 then quantity = 1 end
	if not get("stat.stddev.quantmul") then quantity = 1 end
	local average, mean, _, stdev, var, count, confidence = lib.GetPrice(hyperlink, serverKey)

	if (mean and mean > 0) then
		tooltip:AddLine(_TRANS('SDEV_Tooltip_PricesPoints'):format(count) )--StdDev prices %d points:

		if get("stat.stddev.mean") then
			tooltip:AddLine("  ".._TRANS('SDEV_Tooltip_MeanPrice'), mean*quantity)-- Mean price
		end
		if (average and average > 0) then
			if get("stat.stddev.normal") then
				tooltip:AddLine("  ".._TRANS('SDEV_Tooltip_Normalized'), average*quantity)--  Normalized
				if (quantity > 1) then
					tooltip:AddLine("  ".._TRANS('SDEV_Tooltip_Individually'), average)--  (or individually)
				end
			end
			if get("stat.stddev.stdev") then
				tooltip:AddLine("  ".._TRANS('SDEV_Tooltip_StdDeviation'), stdev*quantity)--  Std Deviation
                if (quantity > 1) then
                    tooltip:AddLine("  ".._TRANS('SDEV_Tooltip_Individually'), stdev)--  (or individually)
                end

			end
			if get("stat.stddev.confid") then
				tooltip:AddLine("  ".._TRANS('SDEV_Tooltip_Confidence')..(floor(confidence*1000))/1000)-- Confidence:
			end
		end
	end
end

function lib.OnLoad(addon)
	if SSDRealmData then return end

	default("stat.stddev.tooltip", false)
	default("stat.stddev.mean", false)
	default("stat.stddev.normal", false)
	default("stat.stddev.stdev", true)
	default("stat.stddev.confid", true)
	default("stat.stddev.quantmul", true)
	default("stat.stddev.enable", true)

	private.InitData()
end

function lib.ClearItem(hyperlink, serverKey)
	local keyId, property = GetStoreKey(hyperlink)
	if not keyId then return end

	if not serverKey then serverKey = Resources.ServerKeyCurrent end
	if SSDRealmData[serverKey] and SSDRealmData[serverKey][keyId] then
		local stats = private.UnpackStats(SSDRealmData[serverKey][keyId])
		if stats[property] then
			stats[property] = nil
			SSDRealmData[serverKey][keyId] = private.PackStats(stats)
			wipe(cache)
			local _, _, keyText = AucAdvanced.SplitServerKey(serverKey)
			aucPrint(libType.._TRANS('SDEV_Interface_ClearingData'):format(hyperlink, keyText))--- StdDev: clearing data for %s for {{%s}}
		end
	end
end

function lib.ClearData(serverKey)
	serverKey = serverKey or Resources.ServerKeyCurrent
	wipe(cache)
	if AucAdvanced.API.IsKeyword(serverKey, "ALL") then
		wipe(SSDRealmData)
		aucPrint(_TRANS('SDEV_Help_SlashHelp4').." {{".._TRANS("ADV_Interface_AllRealms").."}}") --Clearing StdDev stats for // All realms
	elseif SSDRealmData[serverKey] then
		SSDRealmData[serverKey] = nil
		local _, _, keyText = AucAdvanced.SplitServerKey(serverKey)
		aucPrint(_TRANS('SDEV_Help_SlashHelp4').." {{"..keyText.."}}") --Clearing StdDev stats for
	end
end

--[[ Private functions ]]--

function private.UnpackStatIter(data, ...)
	local c = select("#", ...)
	local v
	for i = 1, c do
		v = select(i, ...)
		local property, info = strsplit(":", v)
		if (property and info) then
			data[property] = {strsplit(";", info)}
			-- don't tonumber the entries in this table yet
		end
	end
end
function private.UnpackStats(dataItem)
	local data = {}
	if (dataItem) then
		private.UnpackStatIter(data, strsplit(",", dataItem))
	end
	return data
end

local tmp={}
function private.PackStats(data)
	local n=0
	for property, info in pairs(data) do
		n=n+1
		tmp[n]=property..":"..concat(info, ";")
	end
	return concat(tmp,",",1,n)
end

function private.InitData()
	private.InitData = nil

	-- Do any database upgrades here
	if not AucAdvancedStatStdDevData then AucAdvancedStatStdDevData = {} end

	SSDRealmData = AucAdvancedStatStdDevData

	-- Do any regular database maintenance here
end


AucAdvanced.RegisterRevision("$URL: http://svn.norganna.org/auctioneer/trunk/Auc-Stat-StdDev/StatStdDev.lua $", "$Rev: 5360 $")
