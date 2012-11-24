--[[
	MyRolePlay 4 (C) 2010-2011 Etarna Moonshyne <etarna@moonshyne.org>
	Licensed under GNU General Public Licence version 2 or, at your option, any later version

	Locale.lua - Localisation setup
]]

-- Unless a string has been overridden by a localised string, return default locale (which is enGB, not enUS!).
mrp.L = setmetatable({}, {
	__index = function( table, key )
		return key
	end,
})