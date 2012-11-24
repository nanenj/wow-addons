--[[
	MyRolePlay 4 (C) 2010-2011 Etarna Moonshyne <etarna@moonshyne.org>
	Licensed under GNU General Public Licence version 2 or, at your option, any later version

	Exchange.lua - Predictively request tooltip data for players who query us first, if we don't know them
]]

-- VP (protocol version) used as sentinel for this; checking time means even empty replies count

local GetTime = GetTime
local random = math.random

local nextupdate = 0

local namequeue = { }
local startqueue = 1
local endqueue = 1

local df = MyRolePlayDummyExchangeUpdateFrame or CreateFrame( "Frame", "MyRolePlayDummyExchangeUpdateFrame" )

local function mrp_ExchangeUpdate( )
	if GetTime() < nextupdate or not namequeue[ startqueue ] then return end
	if not msp.char[ namequeue[ startqueue ] ].time.VP then
		msp:Request( namequeue[ startqueue ] )
	end
	namequeue[ startqueue ] = nil
	startqueue = startqueue + 1
	if namequeue[ startqueue ] then 
		nextupdate = GetTime() + ( random( 500, 2000 ) / 1000 )
	else
		MyRolePlayDummyExchangeUpdateFrame:SetScript( "OnUpdate", nil )
	end
end

function mrp_MSPExchangeCallback( player )
	if not msp.char[ player ].time.VP then
		if not namequeue[ startqueue ] then
			nextupdate = GetTime() + ( random( 300, 600 ) / 1000 )
			MyRolePlayDummyExchangeUpdateFrame:SetScript( "OnUpdate", mrp_ExchangeUpdate )
		end
		namequeue[ endqueue ] = player
		endqueue = endqueue + 1
	end
end