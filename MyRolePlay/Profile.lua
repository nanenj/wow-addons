--[[
	MyRolePlay 4 (C) 2010-2011 Etarna Moonshyne <etarna@moonshyne.org>
	Licensed under GNU General Public Licence version 2 or, at your option, any later version

	Profile.lua - Profile management functions
]]

local wipe, format, strtrim = wipe, format, strtrim

function mrp:AddToVAString( addon )
	if not select( 4, GetAddOnInfo( addon ) ) then return end
	msp.my['VA'] = strtrim( format( "%s;%s/%s%s", (msp.my['VA'] or ""), addon, 
		( GetAddOnMetadata( addon, "Version" ) or "" ), 
		(	(GetAddOnMetadata( addon, "X-Test" )=="Alpha" and "a") or 
			(GetAddOnMetadata( addon, "X-Test" )=="Beta" and "b") or "" ) ), "; " )
end

-- Set the current profile, and update everything as necessary
function mrp:SetCurrentProfile( profile, isauto )
	profile = profile or mrpSaved.SelectedProfile or "Default"
	local playername = UnitName("player")

	-- Safety net in case the current profile no longer exists
	if type(mrpSaved.Profiles[profile]) ~= "table" then
		mrpSaved.SelectedProfile = "Default"
		if type(mrpSaved.Profiles[profile]) ~= "table" then
			return false
		end
	else
		mrpSaved.SelectedProfile = profile
	end

	wipe( msp.my )
	wipe( msp.char[ playername ].field )

	for field, value in pairs( mrpSaved.Profiles.Default ) do
		msp.my[ field ] = mrpSaved.Profiles.Default[ field ]
	end

	if profile ~= "Default" then
		for field, value in pairs( mrpSaved.Profiles[ profile ] ) do
			msp.my[ field ] = value
		end
	end

	-- Fields not set by the user
	msp.my['VP'] = tostring( msp.protocolversion )
	msp.my['VA'] = ""
	mrp:AddToVAString( "MyRolePlay" )
	mrp:AddToVAString( "flagRSP2" )
	mrp:AddToVAString( "GHI" )
	mrp:AddToVAString( "Lore" )
	mrp:AddToVAString( "Tongues" )

	msp.my['GU'] = UnitGUID("player")
	msp.my['GS'] = tostring( UnitSex("player") )
	msp.my['GC'] = select( 2, UnitClass("player") )
	msp.my['GR'] = select( 2, UnitRace("player") )

	msp:Update()

	for field, ver in pairs( msp.myver ) do
		mrpSaved.Versions[ field ] = ver
		msp.char[ playername ].ver[ field ] = ver
		msp.char[ playername ].field[ field ] = msp.my[ field ]
		msp.char[ playername ].time[ field ] = 999999999
	end

	msp.char[ playername ].supported = true

	mrp:UpdateCharacterFrame()
	
	if mrp.TTShown == playername then
		mrp:UpdateTooltip( playername )
	end

	if mrp.BFShown == playername then
		mrp:UpdateBrowseFrame( playername )
	end

	if not isauto then
		mrpSaved.PreviousProfileManual = profile
	end

	return true
end

-- Save a (possibly, but not NECESSARILY changed) field back to the current profile, and update stuff accordingly
function mrp:SaveField( field, newtext )
	-- Just in case we get stuck somehow
	local profile = mrpSaved.SelectedProfile
	if type(mrpSaved.Profiles[profile]) ~= "table" then
		return false
	end
	if newtext then 
		newtext = strtrim( newtext )
	end

	if mrpSaved.Profiles.Default[ field ] and mrpSaved.Profiles.Default[ field ] == newtext then
		if mrpSaved.SelectedProfile ~= "Default" then
			mrpSaved.Profiles[ profile ][ field ] = nil -- if identical to what's in Default, then fall through to it
		end
	else
		mrpSaved.Profiles[ profile ][ field ] = newtext
	end

	mrp:SetCurrentProfile( )
end