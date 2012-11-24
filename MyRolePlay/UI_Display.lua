--[[
	MyRolePlay 4 (C) 2010-2011 Etarna Moonshyne <etarna@moonshyne.org>
	Licensed under GNU General Public Licence version 2 or, at your option, any later version

	UI_Display.lua - Functions to format fields for display
]]

local L = mrp.L

local MSP_FR = { ["0"] = L["FR0"], ["1"] = L["FR1"], ["2"] = L["FR2"], ["3"] = L["FR3"], ["4"] = L["FR4"] }
local MSP_FC = { ["0"] = L["FC0"], ["1"] = L["FC1"], ["2"] = L["FC2"], ["3"] = L["FC3"], ["4"] = L["FC4"] }

local tonumber, floor, modf = tonumber, math.floor, math.modf
local strgsub, strsub, strfind = string.gsub, strsub, strfind
local tconcat, tinsert = tconcat, tinsert
local format = format

local function emptynil( x ) return x ~= "" and x or nil end

local function clean( x )
	return strtrim( ( strgsub( x, "|", "||" ) ) )
end

mrp.Display = setmetatable( {
	["MO"] = function( contents )
		if emptynil( contents ) then
			return format( L['mo_format'], clean( contents ) )
		else
			return ""
		end
	end,
	["NI"] = function( contents )
		if emptynil( contents ) then
			return format( L['ni_format'], clean( contents ) )
		else
			return ""
		end
	end,
	["NH"] = function( contents )
		if emptynil( contents ) then
			return format( L['nh_format'], clean( contents ) )
		else
			return ""
		end
	end,
	["FR"] = function( contents )
		if emptynil( contents ) then
			return MSP_FR[ contents ] or clean( contents )
		else
			return MSP_FR[ "0" ]
		end
	end,
	["FC"] = function( contents )
		if emptynil( contents ) then
			return MSP_FC[ contents ] or clean( contents )
		else
			return MSP_FC[ "0" ]
		end
	end,
	["VA"] = function( contents )
		if emptynil( contents ) then
			return strgsub( clean( contents ), ";", ", " )
		else
			return ""
		end
	end,
	["AH"] = function( contents )
		if emptynil( contents ) then
			if (tonumber(contents) or -1) > 0 then
				if mrpSaved.Options.HeightUnit == 1 then
					return format( L[ "m_format" ], tonumber(contents) / 100 )
				elseif mrpSaved.Options.HeightUnit == 2 then
					local cm = tonumber(contents)
					local ft, inches = modf( cm / 30.48 )
					local inches = floor( inches * 12 )
					return format( L[ "ftin_format" ], ft, inches )
				else
					return format( L[ "cm_format" ], floor(tonumber(contents)) )
				end
			else
				return clean( contents )
			end
		else
			return ""
		end
	end,
	["AW"] = function( contents )
		if emptynil( contents ) then
			if (tonumber(contents) or -1) > 0 then
				if mrpSaved.Options.WeightUnit == 1 then
					return format( L[ "lb_format" ], floor( tonumber(contents) * 2.20462262 ) )
				elseif mrpSaved.Options.WeightUnit == 2 then
					local st, lb = modf( tonumber(contents) / 6.35029318 )
					local lb = floor( lb * 14 )
					return format( L[ "stlb_format" ], st, lb )
				else
					return format( L[ "kg_format" ], tonumber(contents) )
				end
			else
				return clean( contents )
			end
		else
			return ""
		end
	end,
}, {
	__index = function( table, key )
		table[key] = function( contents )
			return clean( contents or "" )
		end
	    return table[key]
	end
} )

mrp.DisplayBrowser = setmetatable( {
	["VA"] = function( contents )
		return emptynil( mrp.Display.VA( contents ) ) or L["Sending request, please wait…"]
	end,
}, {
	__index = function( table, key )
		table[key] = mrp.Display[ key ]
	    return table[key]
	end
} )

mrp.DisplayTooltip = setmetatable( {
	["VA"] = function( contents )
		if emptynil( contents ) then
			local s = {}
			local tinsert = tinsert
			if strfind( contents, "MyRolePlay/", 1, true ) then
				tinsert(s, "MRP")
			end
			if strfind( contents, "flagRSP2/", 1, true ) then
				tinsert(s, "RSP2")
			end
			if strfind( contents, "flagRSP/", 1, true ) then
				tinsert(s, "RSP")
			end
			if strfind( contents, "ImmersionRP/", 1, true ) then
				tinsert(s, "IRP")
			end
			if strfind( contents, "TotalRP2/", 1, true ) then
				tinsert(s, "TRP2")
			end
			if strfind( contents, "GHI/", 1, true ) then
				tinsert(s, "GHI")
			end
			if strfind( contents, "Tongues/", 1, true ) then
				tinsert(s, "T")
			end
			if strfind( contents, "Lore/", 1, true ) then
				tinsert(s, "L")
			end
			return clean( emptynil( table.concat(s, ", ") ) or "MSP" )
		else
			return "MSP"
		end
	end,
	["CU"] = function( contents )
		local t = mrp.Display.CU( contents )
		if t and #t > 60 then
			t = clean( strsub( t, 1, 57 ) ) .. "…"
		end
		return t or ""
	end
}, {
	__index = function( table, key )
		table[key] = function( contents ) 
			local t = mrp.Display[ key ]( contents )
			if t and #t > 80 then
				t = clean( strsub( t, 1, 77 ) ) .. "…"
			end
			return t or ""
		end
	    return table[key]
	end
} )

mrp.DisplayChat = setmetatable( {}, {
	__index = function( table, key )
		table[key] = function( contents ) 
			local t = mrp.Display[ key ]( contents )
			if t and #t > 80 then
				t = clean( strsub( t, 1, 77 ) ) .. "…"
			end
			return t or ""
		end
	    return table[key]
	end
} )