--[[
	MyRolePlay 4 (C) 2010-2011 Etarna Moonshyne <etarna@moonshyne.org>
	Licensed under GNU General Public Licence version 2 or, at your option, any later version

	Predictive.lua - Predictively request tooltip data for players in proximity
]]

local GetTime = GetTime
local random = math.random

local nextupdate = 0

-- Fastest queue implementation in Lua: local integer-indexed incrementing table.

local namequeue = { }
local startqueue = 1
local endqueue = 1

local function mrp_PredictiveUpdate( )
	if GetTime() < nextupdate or not namequeue[ startqueue ] then return end
	if msp.char[ namequeue[ startqueue ] ].supported == nil then
		msp:Request( namequeue[ startqueue ] )
	end
	namequeue[ startqueue ] = nil
	startqueue = startqueue + 1
	if namequeue[ startqueue ] then 
		nextupdate = GetTime() + ( random( 500, 2000 ) / 1000 )
	else
		MyRolePlayDummyPredictiveUpdateFrame:SetScript( "OnUpdate", nil )
	end
end

local function mrp_PredictiveEvent( this, event, message, sender )
	if sender and sender ~= "" and msp.char[ sender ].supported == nil then
		if not namequeue[ startqueue ] then
			nextupdate = GetTime() + ( random( 100, 2000 ) / 1000 )
			MyRolePlayDummyPredictiveUpdateFrame:SetScript( "OnUpdate", mrp_PredictiveUpdate )
		end
		namequeue[ endqueue ] = sender
		endqueue = endqueue + 1
	end
end

local df = MyRolePlayDummyPredictiveFrame or CreateFrame( "Frame", "MyRolePlayDummyPredictiveFrame" )
df:SetScript( "OnEvent", mrp_PredictiveEvent )

local df2 = MyRolePlayDummyPredictiveUpdateFrame or CreateFrame( "Frame", "MyRolePlayDummyPredictiveUpdateFrame" )

function mrp:HookPredictive()
	local f = MyRolePlayDummyPredictiveFrame
	f:RegisterEvent( "CHAT_MSG_SAY" )
	f:RegisterEvent( "CHAT_MSG_EMOTE" )
	f:RegisterEvent( "CHAT_MSG_TEXT_EMOTE" )
	f:RegisterEvent( "CHAT_MSG_YELL" )
end

function mrp:UnhookPredictive()
	local f = MyRolePlayDummyPredictiveFrame
	f:UnregisterEvent( "CHAT_MSG_SAY" )
	f:UnregisterEvent( "CHAT_MSG_EMOTE" )
	f:UnregisterEvent( "CHAT_MSG_TEXT_EMOTE" )
	f:UnregisterEvent( "CHAT_MSG_YELL" )
end