--[[
	MyRolePlay 4 (C) 2010-2011 Etarna Moonshyne <etarna@moonshyne.org>
	Licensed under GNU General Public Licence version 2 or, at your option, any later version

	MyRolePlay.lua - Base functions to initialise the mrp table and a couple of frequently-used utility functions
]]

-- MyRolePlay: Detect any other MSP AddOn, and bail out in case of imminent conflict

mrp = {}

mrp.Version = GetAddOnMetadata( "MyRolePlay", "Version" )
mrp.Build = tonumber( strmatch( mrp.Version, "%d+%.%d+%.%d+%.(%d+)" ) )
mrp.VersionString = "MyRolePlay/"..mrp.Version
mrp.Alpha = GetAddOnMetadata( "MyRolePlay", "X-Test" ) == "Alpha"
mrp.Beta = GetAddOnMetadata( "MyRolePlay", "X-Test" ) == "Beta"
mrp.Release = not GetAddOnMetadata( "MyRolePlay", "X-Test" )
mrp.Debug = false
mrp.DebugMSP = false
mrp.VerInfo = format( "%s%s", 
	mrp.Alpha and "|cffff7722Alpha|r " or mrp.Beta and "|cff77eeaaBeta|r " or 
	IsGMClient() and "|cff00b3ff<GM>|r " or "" , mrp.Version )
mrp.VerText = "MyRolePlay " .. mrp.VerInfo
mrp.WoWVer = format( "%s.%s", GetBuildInfo() )
if GetCVar("portal") == "public-test" then mrp.WoWVer = mrp.WoWVer .. " (PTR)" end
mrp.WoWBuild = tonumber((select(2, GetBuildInfo())))
mrp.WoWTOC = tonumber((select(4, GetBuildInfo())))

if _G.msp_RPAddOn then
	mrp.AbortLoad = true
	StaticPopupDialogs[ "MRP_MSP_CONFLICT" ] = {
		text = format( "ERROR: You can only use one MSP AddOn at once, but you have both MyRolePlay and %s loaded.\n\nAll MSP AddOns can communicate with each other, but please do not try to use more than one at once as conflicts will arise.", tostring(_G.msp_RPAddOn) or "another MSP AddOn" ),
		button1 = OKAY or "OK",
		whileDead = true,
		timeout = 0,
	}
	StaticPopup_Show( "MRP_MSP_CONFLICT" )
end 
_G.msp_RPAddOn = "MyRolePlay"

function mrp_dummyfunction()
end

function mrp:Print( ... )
	DEFAULT_CHAT_FRAME:AddMessage( "|cffA050D0MyRolePlay: |r" .. format(...) )
end

function mrp:DebugSpam( ... )
	if not mrp.Debug then return end
	DEFAULT_CHAT_FRAME:AddMessage( "|cff403850MRPDebug: |cffa070d0" .. format(...) )
end

function mrp:UnitNameWithRealm( unit )
	local name, realm = UnitName(unit)
	if realm and realm ~= "" then
		return name.."-"..realm
	else
		return name
	end
end