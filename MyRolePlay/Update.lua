--[[
	MyRolePlay 4 (C) 2010-2011 Etarna Moonshyne <etarna@moonshyne.org>
	Licensed under GNU General Public Licence version 2 or, at your option, any later version

	Update.lua - Notify the player (only once per session) if someone else has a later release build of MyRolePlay

	Dislike the update notifications? Simply delete this file.
]]

local L = mrp.L
local strmatch, tonumber = strmatch, tonumber

function mrp_MSPUpdateCallback( player )
	if not mrp.UpdateNotificationShown and tonumber( strmatch( msp.char[ player ].field.VA, "MyRolePlay/%d+%.%d+%.%d+%.(%d+)" ) or "-1" ) > mrp.Build then
		local testbuild = strmatch( msp.char[ player ].field.VA, "MyRolePlay/%d+%.%d+%.%d+%.%d+([ab])" )
		if not testbuild then
			mrp:Print( L["Your version of MyRolePlay is out of date. Please visit your favourite UI AddOn site to update to the latest version, |cffc878e0%s|r."],
				strmatch( msp.char[ player ].field.VA, "MyRolePlay/(%d+%.%d+%.%d+%.%d+)" ) )
			mrp.UpdateNotificationShown = true
		end
	end
end