--[[
	MyRolePlay 4 (C) 2010-2011 Etarna Moonshyne <etarna@moonshyne.org>
	Licensed under GNU General Public Licence version 2 or, at your option, any later version

	Options.lua - Functions for handling base options, and version conversion
]]

local L = mrp.L
local strtrim = strtrim

local function emptynil( x ) return x ~= "" and x or nil end

mrp.DefaultOptions = {
	Enabled = true,
	ShowButton = true,
	ShowBiographyInBrowser = true,
	HeightUnit = L["option_HeightUnit"],
	WeightUnit = L["option_WeightUnit"],
	FormAutoChange = true,
	EquipSetAutoChange = true,
	TooltipStyle = 2,
	ShowRPNamesInChat = true,
}

function mrp:UpgradeSaved( build )
	build = build or 0
	if build < 51 then
		-- Kill old temp unused options
		mrpSaved.Options.ImperialHeight = nil
		mrpSaved.Options.ImperialWeight = nil
		mrpSaved.Options.ShowInCombat = nil
		mrpSaved.Options.DisableInCombat = nil
		mrpSaved.Options.ShowInInstance = nil
		mrpSaved.Options.DisableInInstance = nil
		mrpSaved.Options.RelativeLevels = nil
		-- Set the new options to defaults
		mrpSaved.Options.Enabled = mrp.DefaultOptions.Enabled
		mrpSaved.Options.HeightUnit = mrp.DefaultOptions.HeightUnit
		mrpSaved.Options.WeightUnit = mrp.DefaultOptions.WeightUnit
	end
	if build < 52 then
		for name, profile in pairs( mrpSaved.Profiles ) do
			-- Strip spaces
			for field, contents in pairs( profile ) do
				profile[ field ] = strtrim( contents )
			end
 			-- Deal with people who put 01 in FR or FC
			if tonumber( profile.FR ) then
				profile.FR = tostring( tonumber( profile.FR ) )
			end
			if tonumber( profile.FC ) then
				profile.FC = tostring( tonumber( profile.FC ) )
			end
			-- RA should be blank if you aren't overriding, otherwise it messes up your race's localisation for other players
			if profile.RA == UnitRace("player") or profile.RA == select( 2, UnitRace("player") ) then
				profile.RA = ""
			end
		end
	end
	if build < 58 then
		mrpSaved.Options.FormAutoChange = mrp.DefaultOptions.FormAutoChange
	end
	if build < 59 then
		mrpSaved.Options.EquipSetAutoChange = mrp.DefaultOptions.EquipSetAutoChange
	end
	if build < 70 then
		mrpSaved.PreviousProfileAuto = nil
		mrpSaved.HumanForm = nil
	end
	if build < 73 then
		mrpSaved.Options.MRPButtonMoved = nil
		mrpSaved.Positions = {}
	end
	if build < 82 then
		if mrpSaved.Options.ShowTooltip then
			mrpSaved.Options.TooltipStyle = 2
		else
			mrpSaved.Options.TooltipStyle = 0
		end
		mrpSaved.Options.ShowTooltip = nil
	end
	if build < 86 then
		mrpSaved.Options.ShowRPNamesInChat = mrp.DefaultOptions.ShowRPNamesInChat
	end
end

-- A blast from the past: 3.x -> 4.x conversion
function mrp:Convert3ProfileTo4()
	if not mdbSaved or type(mdbSaved) ~= "table" or type(mdbSaved.MyRolePlayCharacter) ~= "table" or type(mdbSaved.MyRolePlayCharacter.Tables) ~= "table" then
		mrp:Print( L["Convert3ProfileTo4(): mdbSaved not present or corrupted"] )
		return false
	end

	local profiles = mdbSaved.MyRolePlayCharacter.Tables.Identification.Columns[1].values

	for id, profile in ipairs( profiles ) do
		-- Make our table, if we haven't got it (we will have Default already)
		if type( mrpSaved.Profiles[ profile ] ) ~= "table" then
			mrpSaved.Profiles[ profile ] = { }
		end

		local prefix = emptynil( strtrim( mdbSaved.MyRolePlayCharacter.Tables.Identification.Columns[2].values[id] or "" ) )
		local firstname = emptynil( strtrim( mdbSaved.MyRolePlayCharacter.Tables.Identification.Columns[3].values[id] or "" ) )
		local middlename = emptynil( strtrim( mdbSaved.MyRolePlayCharacter.Tables.Identification.Columns[4].values[id] or "" ) )
		local surname = emptynil( strtrim( mdbSaved.MyRolePlayCharacter.Tables.Identification.Columns[5].values[id] or "" ) )

		local name = ""
		if prefix then 
			name = prefix
		end
		if firstname then
			name = strtrim( name ) .. " " .. firstname
		end
		if middlename then
			name = strtrim( name ) .. " " .. middlename
		end
		if surname then
			name = strtrim( name ) .. " " .. surname
		end
		name = strtrim( name ) -- just in case :)
		if name == "" then
			name = UnitName( "player" )
		end

		mrpSaved.Profiles[ profile ]['NA'] = name or ""
		mrpSaved.Versions['NA'] = ( mrpSaved.Versions['NA'] or 1 )

		mrpSaved.Profiles[ profile ]['NT'] = emptynil( strtrim( mdbSaved.MyRolePlayCharacter.Tables.Identification.Columns[7].values[id] or "" ) ) or ""
		mrpSaved.Versions['NT'] = ( mrpSaved.Versions['NT'] or 1 )

		mrpSaved.Profiles[ profile ]['NH'] = emptynil( strtrim( mdbSaved.MyRolePlayCharacter.Tables.Identification.Columns[9].values[id] or "" ) ) or ""
		mrpSaved.Versions['NH'] = ( mrpSaved.Versions['NH'] or 1 )

		mrpSaved.Profiles[ profile ]['NI'] = emptynil( strtrim( mdbSaved.MyRolePlayCharacter.Tables.Identification.Columns[8].values[id] or "" ) ) or ""
		mrpSaved.Versions['NI'] = ( mrpSaved.Versions['NI'] or 1 )

		mrpSaved.Profiles[ profile ]['AE'] = emptynil( strtrim( mdbSaved.MyRolePlayCharacter.Tables.Appearance.Columns[2].values[id] or "" ) ) or ""
		mrpSaved.Versions['AE'] = ( mrpSaved.Versions['AE'] or 1 )

		mrpSaved.Profiles[ profile ]['AH'] = emptynil( strtrim( mdbSaved.MyRolePlayCharacter.Tables.Appearance.Columns[3].values[id] or "" ) ) or ""
		mrpSaved.Versions['AH'] = ( mrpSaved.Versions['AH'] or 1 )

		mrpSaved.Profiles[ profile ]['AW'] = emptynil( strtrim( mdbSaved.MyRolePlayCharacter.Tables.Appearance.Columns[4].values[id] or "" ) ) or ""
		mrpSaved.Versions['AW'] = ( mrpSaved.Versions['AW'] or 1 )

		mrpSaved.Profiles[ profile ]['DE'] = emptynil( strtrim( mdbSaved.MyRolePlayCharacter.Tables.Appearance.Columns[7].values[id] or "" ) ) or ""
		mrpSaved.Versions['AE'] = ( mrpSaved.Versions['AE'] or 1 )

		mrpSaved.Profiles[ profile ]['HH'] = emptynil( strtrim( mdbSaved.MyRolePlayCharacter.Tables.Lore.Columns[2].values[id] or "" ) ) or ""
		mrpSaved.Versions['HH'] = ( mrpSaved.Versions['HH'] or 1 )

		mrpSaved.Profiles[ profile ]['HB'] = emptynil( strtrim( mdbSaved.MyRolePlayCharacter.Tables.Lore.Columns[3].values[id] or "" ) ) or ""
		mrpSaved.Versions['HB'] = ( mrpSaved.Versions['HB'] or 1 )

		mrpSaved.Profiles[ profile ]['MO'] = emptynil( strtrim( mdbSaved.MyRolePlayCharacter.Tables.Lore.Columns[4].values[id] or "" ) ) or ""
		mrpSaved.Versions['MO'] = ( mrpSaved.Versions['MO'] or 1 )

		mrpSaved.Profiles[ profile ]['HI'] = emptynil( strtrim( mdbSaved.MyRolePlayCharacter.Tables.Lore.Columns[5].values[id] or "" ) ) or ""
		mrpSaved.Versions['HI'] = ( mrpSaved.Versions['HI'] or 1 )

		local rp = emptynil( strtrim( mdbSaved.MyRolePlayCharacter.Tables.Status.Columns[2].values[id] ) )
		if not rp or rp == "RP0" then
			rp = "0"
		elseif rp == "RP1" then
			rp = "1"
		elseif rp == "RP2" then
			rp = "2"
		elseif rp == "RP3" then
			rp = "3"
		elseif rp == "RP4" then
			rp = "4"
		else
			rp = "0"
		end
		mrpSaved.Profiles[ profile ]['FR'] = rp
		mrpSaved.Versions['FR'] = ( mrpSaved.Versions['FR'] or 1 )

		local cs = emptynil( strtrim( mdbSaved.MyRolePlayCharacter.Tables.Status.Columns[3].values[id] ) )
		if not cs or cs == "CS0" then
			cs = "0"
		elseif cs == "CS1" then
			cs = "1"
		elseif cs == "CS2" then
			cs = "2"
		elseif cs == "CS3" then
			cs = "3"
		elseif cs == "CS4" then
			cs = "4"
		else
			cs = "0"
		end
		mrpSaved.Profiles[ profile ]['FC'] = cs
		mrpSaved.Versions['FC'] = ( mrpSaved.Versions['FC'] or 1 )

	end

	mrpSaved.SelectedProfile = emptynil( strtrim( mdbSaved.MyRolePlayCharacter.Tables.CurProfile.Columns[1].values[1] ) ) or "Default"

	-- OK, that's basic conversion.
	-- Yeah, it's OK if version doesn't start at 1. In fact, as long as it doesn't go backwards within someone else's session, we're cool.

	local count = 0
	-- Go through non-default profiles, and if the values match the default one, nil them out so they fall through.
	for id, profile in pairs( mrpSaved.Profiles ) do
		count = count + 1
		if id ~= "Default" then
			for field, value in pairs( mrpSaved.Profiles[id] ) do
				if mrpSaved.Profiles.Default[field] and mrpSaved.Profiles.Default[field]==value then
					mrpSaved.Profiles[id][field] = nil
				end
			end
		end
	end

	-- And we're done! (Hopefully.) Destroy the old data with extreme prejudice!

	wipe( mdbSaved )
	mdbSaved = nil

	mrp:Print( L["Imported %d |4profile:profiles; from MyRolePlay 3.x."], count )

	return true
end