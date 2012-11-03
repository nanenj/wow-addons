--[[
	Auctioneer - AH-WindowControl
	Version: 5.15.5365 (LikeableLyrebird)
	Revision: $Id: Auc-Util-AHWindowControl.lua 5347 2012-09-06 06:26:15Z Esamynn $
	URL: http://auctioneeraddon.com/

	This is an addon for World of Warcraft that adds the abilty to drag and reposition the Auction House Frame.
	Protect the Auction Frame from being closed or moved by Escape or Blizzard frames.
	It also adds limited Font and Frame Scaling of the Auction House/CompactUI

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
if not AucAdvanced then return end

local libType, libName = "Util", "AHWindowControl"
local lib, parent, private = AucAdvanced.NewModule(libType, libName)
local SetUIPanelAttribute = SetUIPanelAttribute or function (frame,name,value)
	local info = UIPanelWindows[frame:GetName()]
	if ( not info ) then
		return;
	end
	
	if ( not frame:GetAttribute("UIPanelLayout-defined") ) then
		frame:SetAttribute("UIPanelLayout-defined", true);
		for name,value in pairs(info) do
			frame:SetAttribute("UIPanelLayout-"..name, value);
		end
	end
	
	frame:SetAttribute("UIPanelLayout-"..name, value);
end	

local GetUIPanelAttribute = GetUIPanelAttribute or function (frame,name)
	local info = UIPanelWindows[frame:GetName()]
	if ( not info ) then
		return;
	end
	if (not frame:GetAttribute("UIPanelLayout-defined") ) then
		return
	end
	local value = frame:GetAttribute("UIPanelLayout-"..name)
	return value
end

if not lib then return end

local print,decode,_,_,replicate,empty,get,set,default,debugPrint,fill, _TRANS = AucAdvanced.GetModuleLocals()

lib.Private = private

function lib.GetName()
	return libName
end

local debug = false
local function debugPrint(...)
	if debug  then
		print(...)
	end
end

function lib.Processor(callbackType, ...)
	if callbackType == "auctionui" then
		private.auctionHook() ---When AuctionHouse loads hook the auction function we need
		private.MoveFrame() --Set position back to previous session if options set
	elseif callbackType == "configchanged" then
		private.MoveFrame()
		private.AdjustProtection()
	elseif callbackType == "config" then
		private.SetupConfigGui(...)
	end
end

lib.Processors = {}
function lib.Processors.auctionui(callbackType, ...)
	private.auctionHook() ---When AuctionHouse loads hook the auction function we need
	private.MoveFrame() --Set position back to previous session if options set
end

function lib.Processors.configchanged(callbackType, ...)
	private.MoveFrame()
	private.AdjustProtection()
end

function lib.Processors.config(callbackType, ...)
	private.SetupConfigGui(...)
end



function lib.OnLoad(addon)
	default("util.mover.activated", true)
	default("util.mover.rememberlastpos", true)
	default("util.mover.anchors", {"TOPLEFT", UIParent, "TOPLEFT", 0, -104})
	default("util.protectwindow.protectwindow", 1)
	default("util.ahwindowcontrol.auctionscale", 1) --This is the scale of AuctionFrame 1 == default
	default("util.ahwindowcontrol.compactuiscale", 0) --This is the increase of compactUI scale
	default("util.ahwindowcontrol.searchuiscale", 1) --This is the default SearchUI scale
end

--after Auction House Loads Hook the Window Display event
function private.auctionHook()
	hooksecurefunc("AuctionFrame_Show", private.setupWindowFunctions)
end

function private.SetupConfigGui(gui)
	-- The defaults for the following settings are set in the lib.OnLoad function
	local id, last
	--Setup Tab for Mover functions
	id = gui:AddTab(libName)
	gui:MakeScrollable(id)
	gui:AddControl(id, "Header",     0,    _TRANS('AHWC_Interface_WindowMovementOptions') ) --"Window Movement Options"
	gui:AddControl(id, "Checkbox",   0, 1,  "util.mover.activated",  _TRANS('AHWC_Interface_AllowMovable') ) --"Allow the auction frame to be movable?"
	gui:AddTip(id, _TRANS('AHWC_HelpTooltip_AllowMovable') ) --"Ticking this box will enable the ability to relocate the auction frame"
	gui:AddHelp(id, "what is AHWindowControl",
		_TRANS('AHWC_Help_whatisthis'),--"What is this utility?"
		_TRANS'AHWC_Help_whatisthisAnswer')--This utility allows you to drag and relocate the auction frame for this play session. Just click and move where you desire. It also alows you to protect the Auction House from closing when opening certain Blizzard windows."
	gui:AddControl(id, "Checkbox",   0, 1,  "util.mover.rememberlastpos", _TRANS('AHWC_Interface_RemberLastPosition') ) --"Remember last known window position?"
	gui:AddTip(id, _TRANS('AHWC_HelpToolTip_RemberLastPosition') ) --"If this box is checked, the auction frame will reopen in the last location it was moved to."
	gui:AddHelp(id, "what is remeberpos",
		_TRANS('AHWC_Help_RemberLastPosition'), --"Remember last known window position?"
		_TRANS('AHWC_Help_RemberLastPositionAnswer') ) --"This will remember the auction frame's last position and re-apply it each session."

	--Window Protection
	gui:AddControl(id, "Header", 0,	_TRANS("AHWC_Interface_WindowProtectionOptions") ) --WindowProtectionOptions
	gui:AddControl(id, "Subhead", 0, _TRANS("AHWC_Interface_ProtectAuctionWindow") ) --Protect the Auction House window:
	--Note the function reference in the place of the setting name.  See changes in getter, setter, and getDefault to accomodate this.
	gui:AddControl(id, "Selectbox", 0, 1, {
		{1, _TRANS("AHWC_Interface_Never") }, --Never
		{2, _TRANS("AHWC_Interface_Always") }, --Always
	}, "util.protectwindow.protectwindow" ) --"Prevent other windows from closing the Auction House window."
	gui:AddTip(id, _TRANS("AHWC_HelpToolTip_PreventClosingAuctionHouse") ) --This will prevent other windows from closing the Auction House window when you open them, according to your settings.
	gui:AddHelp(id, "What is ProtectWindow",
		_TRANS("AHWC_Help_ProtectWindow"), --What does Protecting the AH Window do?
		_TRANS("AHWC_Help_ProtectWindowAnswer") )
		--The Auction House window is normally closed when you open other windows, such as the Social window, the Quest Log, or your profession windows.  This option allows it to remain open, behind those other windows.
	--AuctionFrame Scale
	gui:AddControl(id, "Header", 0, "") --Spacer for options
	gui:AddControl(id, "Header", 0,	_TRANS("AHWC_Interface_WindowSizeOptions") ) --Window Size Options
	gui:AddControl(id, "NumeriSlider", 0, 1, "util.ahwindowcontrol.auctionscale",    0.5, 2, 0.1, _TRANS("AHWC_Interface_AuctionHouseScale") ) --Auction House Scale
	gui:AddTip(id, _TRANS("AHWC_HelpToolTip_AuctionHouseScale") ) --This option allows you to adjust the overall size of the Auction House window. Default is 1.
	gui:AddHelp(id, "what is Auction House Scale",
			_TRANS("AHWC_Help_AuctionHouseScale"), --Auction House Scale?
			_TRANS("AHWC_Help_AuctionHouseScaleAnswer") )--The Auction House scale slider adjusts the overall size of the entire Auction House window. The default size is 1.
	--CompactUI
	gui:AddControl(id, "NumeriSlider", 0, 1, "util.ahwindowcontrol.compactuiscale",    -5, 5, 0.2, _TRANS("AHWC_Interface_CompactUIFontScale") ) --CompactUI Font Scale
	gui:AddTip(id, _TRANS("AHWC_HelpTooltip_CompactUIFontScale") ) --This option allows you to adjust the text size of the CompactUI on the Browse tab. The default size is 0.
	gui:AddHelp(id, "what is CompactUI Font Scale",
			_TRANS("AHWC_Help_CompactUIFontScale"), --CompactUI Font Scale?
			_TRANS("AHWC_Help_CompactUIFontScaleAnswer") ) --The CompactUI Font Scale slider adjusts the text size displayed in AucAdvance CompactUI option in the Browse Tab. The default size is 0.
	--SearchUI
	gui:AddControl(id, "NumeriSlider", 0, 1, "util.ahwindowcontrol.searchuiscale",     0.5, 2, 0.1, _TRANS("AHWC_Interface_SearchUIScale") ) --SearchUI Scale
	gui:AddTip(id, _TRANS("AHWC_HelpTooltip_SearchUIScale") ) --This option allows you to adjust the overall size of the non auction house SearchUI window. The default size is 1.
	gui:AddHelp(id, "what is SearchUI Scale",
			_TRANS("AHWC_Help_SearchUIScale"), --SearchUI Scale?
			_TRANS("AHWC_Help_SearchUIScaleAnswer") ) --The SearchUI scale slider adjusts the overall size of the non auction house SearchUI window. The default size is 1.
end


--[[ Local functions ]]--

--Hooks AH show function. This is fired after all Auction Frame methods have been set by Blizzard
--We can now override with our settings
local runonce=true
function private.setupWindowFunctions()
	private.recallLastPos()
	if runonce then
		private.AdjustProtection()
		runonce=nil
	end
end

--Enable or Disable the move scripts
function private.MoveFrame()
	--AH needs to exist
	if AuctionFrame then
		if get("util.mover.activated") then
			AuctionFrame:SetMovable(true)
			AuctionFrame:SetClampedToScreen(true)
			AuctionFrame:SetScript("OnMouseDown", function()  AuctionFrame:StartMoving() end)
			AuctionFrame:SetScript("OnMouseUp", function() AuctionFrame:StopMovingOrSizing()
			set("util.mover.anchors", {AuctionFrame:GetPoint()}) --store the current anchor points
			end)
		else
			AuctionFrame:SetMovable(false)
			AuctionFrame:SetScript("OnMouseDown", function() end)
			AuctionFrame:SetScript("OnMouseUp", function() end)
		end
		if get("util.ahwindowcontrol.auctionscale") then
			AuctionFrame:SetScale(get("util.ahwindowcontrol.auctionscale"))
		end
		if get("util.compactui.activated") then
			for i = 1,14 do
				local button = _G["BrowseButton"..i]
				local increase = get('util.ahwindowcontrol.compactuiscale') or 0
				if not button.Count then return end -- we get called before compactUI has built the frame
				button.Count:SetFont(STANDARD_TEXT_FONT, 11 + increase)
				button.Name:SetFont(STANDARD_TEXT_FONT, 10 + increase)
				button.rLevel:SetFont(STANDARD_TEXT_FONT, 11 + increase)
				button.iLevel:SetFont(STANDARD_TEXT_FONT, 11 + increase)
				button.tLeft:SetFont(STANDARD_TEXT_FONT, 11 + increase)
				button.Owner:SetFont(STANDARD_TEXT_FONT, 10 + increase)
				button.Value:SetFont(STANDARD_TEXT_FONT, 11 + increase)
			end
		end
	end
	--searchUi needs to exist
	if AucAdvanced.Modules.Util.SearchUI and AucAdvanced.Modules.Util.SearchUI.Private.gui then
		if get("util.ahwindowcontrol.searchuiscale") then
			AucAdvanced.Modules.Util.SearchUI.Private.gui:SetScale(get("util.ahwindowcontrol.searchuiscale"))
		end
	end
end

--Restore previous sessions Window position
function private.recallLastPos()
	if get("util.mover.rememberlastpos") then
		local anchors = get("util.mover.anchors")
		if #anchors ~= 5 then anchors = {"TOPLEFT", UIParent, "TOPLEFT", 0, -104} end
		AuctionFrame:ClearAllPoints()
		AuctionFrame:SetPoint(anchors[1], anchors[2], anchors[3], anchors[4], anchors[5])
	end
end

--This will turn the protection of the AuctionFrame on or off,
--as appropriate.
function private.AdjustProtection ()
 	--If the auction frame hasn't been opened yet, we can't do anything.	 
	if not UIPanelWindows["AuctionFrame"] then
		debugPrint("AuctionFrame doesn't exist yet.")
		return
	--Else, if we're set never to protect the AuctionFrame, 
	--but UIPanelLayout-enabled is nil (it's protected) adjust
	elseif (get("util.protectwindow.protectwindow") == 1) and not GetUIPanelAttribute(AuctionFrame,"area") then	
		debugPrint("Enabling Standard Frame Handler for Auction Frame because protectwindow ="..get("util.protectwindow.protectwindow"))
		--Enable the standard FrameHandler
		SetUIPanelAttribute(AuctionFrame,"area","doublewide")
		--We can't adjust this with the AuctionFrame visible
		if AuctionFrame:IsVisible() then
			--Set AuctionFrame.IsShown to an empty 
			--function so it appears to be hidden.
			AuctionFrame.IsShown = function() end
			--Tell the game to "show" the frame, 
			--making the client aware of our 
			--adjusted setting.
			ShowUIPanel(AuctionFrame, 1)
			--AuctionFrame.IsShown is stored in the 
			--meta-table, restore it by nil-ing it.
			AuctionFrame.IsShown = nil
		end
	--Else, if we're set to always protect the AuctionFrame, 
	--but UIPanelLayout-enabled is true (not protected) adjust
	elseif (get("util.protectwindow.protectwindow") == 2) and GetUIPanelAttribute(AuctionFrame,"area") then
		debugPrint("Disabling Standard Frame Handler for Auction Frame because protectwindow ="..get("util.protectwindow.protectwindow"))
		--We can't adjust with the AuctionFrame visible
		if AuctionFrame:IsVisible() then
			--We need the game to think it's hidden 
			--the Auction Frame, so Hide to an empty 
			--function.
			AuctionFrame.Hide = function() end
			--Tell the game to hide the frame
			HideUIPanel(AuctionFrame)
			--Restore the original function from the 
			--meta-table by nil-ing it.
			AuctionFrame.Hide = nil
		end
		--Disable the standard frame handler. We don't 
		--need to re-show the Auction frame, because the 
		--game doesn't think it's shown right now, anyway.
		SetUIPanelAttribute(AuctionFrame,"area",nil)
	--If we have an invalid setting, set it to never protect,
	--and record the appropriate configuration.
	elseif get("util.protectwindow.protectwindow") ~= 1 and get("util.protectwindow.protectwindow") ~=2 then
		local protectvalue = get("util.protectwidow.protectwindow")
		protectvalue = tostring(protectvalue)
		debugPrint("util.protectwindow.protectwindow="..protectvalue.." an invalid value")
		set("util.protectwindow.protectwindow", 1)
		--If the standard frame handler is disabled, re-enable it.
		if not GetUIPanelAttribute(AuctionFrame,"area") then
			SetUIPanelAttribute(AuctionFrame,"area","doublewide")
			--We need to get the client to re-read the configuration
			if AuctionFrame:IsVisible() then
				--Set IsShown to an empty function, fooling the
				--client.
				AuctionFrame.IsShown = function() end
				--Tell the client to Show the frame.
				ShowUIPanel(AuctionFrame, 1)
				--Restore the original IsShown from the meta-table
				--by nil-ing it.
				AuctionFrame.IsShown = nil
			end
		end
	--If none of the above are true (I'm not sure how that would happen at this
	--point), print some errors so we can figure out something's wrong here.
	else
		debugPrint("No case matched.")
		debugPrint("util.protectwindow.protectwindow="..get("util.protectwindow.protectwindow"))
		debugPrint("UIPanelLayout-area="..tostring(GetUIPanelAttribute(AuctionFrame,"area")))
	end
end

function lib.ToggleDebug()
	if debug  then
		debug = false
		print("Turned debugging text off.")
	else
		debug = true
		print("Turned debugging text on.")
	end
end

AucAdvanced.RegisterRevision("$URL: http://svn.norganna.org/auctioneer/trunk/Auc-Util-AHWindowControl/Auc-Util-AHWindowControl.lua $", "$Rev: 5347 $")
