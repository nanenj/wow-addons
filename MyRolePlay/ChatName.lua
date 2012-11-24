--[[
	MyRolePlay 4 (C) 2010-2011 Etarna Moonshyne <etarna@moonshyne.org>
	Licensed under GNU General Public Licence version 2 or, at your option, any later version

	ChatName.lua - Use MSP names in RP channels in chat
]]

local strsub, format, select = strsub, format, select

local RAID_CLASS_COLORS_CODE = setmetatable( {}, { __index = function( table, key )
	table[ key ] = RAID_CLASS_COLORS[ key ] and format( "|cff%02x%02x%02x", RAID_CLASS_COLORS[ key ].r * 255, RAID_CLASS_COLORS[ key ].g * 255, RAID_CLASS_COLORS[ key ].b * 255 ) or ""
	return table[ key ]
end } )

local RPEVENTS = {
	["CHAT_MSG_SAY"] = true,
	["CHAT_MSG_EMOTE"] = true,
	["CHAT_MSG_TEXT_EMOTE"] = true,
	["CHAT_MSG_YELL"] = true,
}

local function mrp_GetColoredName( event, message, sender, language, arg4, arg5, arg6, arg7, arg8, arg9, arg10, lineid, guid )
	if mrpSaved.Options.ShowRPNamesInChat and RPEVENTS[ event ] and sender and sender ~= UNKNOWN and msp.char[ sender ].supported and msp.char[ sender ].time.NA and mrp.DisplayChat.NA( msp.char[ sender ].field.NA ) ~= "" and mrp.DisplayChat.NA( msp.char[ sender ].field.NA ) ~= sender then
		if ChatTypeInfo[ strsub( event, 10 ) or "" ] and ChatTypeInfo[ strsub( event, 10 ) or "" ].colorNameByClass and guid ~= "" then
			return format( "%s%s|r", RAID_CLASS_COLORS_CODE[ ( select( 2, GetPlayerInfoByGUID( guid ) ) ) ], mrp.DisplayChat.NA( msp.char[ sender ].field.NA ) )
		else
			return mrp.DisplayChat.NA( msp.char[ sender ].field.NA )
		end
	else
		return mrp_Prehook_GetColoredName( event, message, sender, language, arg4, arg5, arg6, arg7, arg8, arg9, arg10, lineid, guid )
	end
end

function mrp:HookChatName()
	mrp_Prehook_GetColoredName = GetColoredName
	GetColoredName = mrp_GetColoredName
end

function mrp:UnhookChatName()
	GetColoredName = mrp_Prehook_GetColoredName
end