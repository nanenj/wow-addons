--[[
	MyRolePlay 4 (C) 2010-2011 Etarna Moonshyne <etarna@moonshyne.org>
	Licensed under GNU General Public Licence version 2 or, at your option, any later version

	UI_Tooltip.lua - Functions to handle the MRP tooltips
]]

local L = mrp.L

local strsub, format, ceil = strsub, format, math.ceil

local blankline = " "

local function emptynil( x ) return x ~= "" and x or nil end

local function mrp_MouseoverEvent( this, event, addon )
	if event == "UPDATE_MOUSEOVER_UNIT" then
		if not mrpSaved.Options.Enabled or ( mrpSaved.Options.TooltipStyle == 0 ) then
			return true
		end
		if UnitIsUnit( "player", "mouseover" ) then
			mrp:UpdateTooltip( UnitName("player"), "player" )
		elseif UnitIsPlayer("mouseover") then
			if UnitIsFriend("player", "mouseover") then
				msp:Request( mrp:UnitNameWithRealm("mouseover") )
				mrp:UpdateTooltip( mrp:UnitNameWithRealm("mouseover"), "mouseover" )
			else
				mrp:UpdateTooltip( mrp:UnitNameWithRealm("mouseover"), "mouseover" )
			end
		else
			mrp.TTShown = nil
		end
		return true
	end
end

local df = MyRolePlayDummyTooltipFrame or CreateFrame( "Frame", "MyRolePlayDummyTooltipFrame" )
df:SetScript( "OnEvent", mrp_MouseoverEvent )

function mrp:HookTooltip()
	MyRolePlayDummyTooltipFrame:RegisterEvent( "UPDATE_MOUSEOVER_UNIT" )
	-- also hook GameTooltip:SetUnit()
end

function mrp:UnhookTooltip()
	MyRolePlayDummyTooltipFrame:UnregisterEvent( "UPDATE_MOUSEOVER_UNIT" )
	-- also unhook GameTooltip:SetUnit()
end

--[[
	EPIC KLUDGE!
	Special local functions to overwrite and add the current tooltip.
]]
-- Single string
local function gtal( n, r, g, b )
	local l = GameTooltip.mrpLines + 1
	GameTooltip.mrpLines = l

	r, g, b = (r or 1.0), (g or 1.0), (b or 1.0)

	--if GameTooltip.mrpLines <= GameTooltip.orgLines then
		-- Replace original line with ours, or add a new one if not there
		if _G["GameTooltipTextLeft"..tostring(l)] then
			if _G["GameTooltipTextLeft"..tostring(l)]:IsVisible() then
				if _G["GameTooltipTextRight"..tostring(l)] then
					_G["GameTooltipTextRight"..tostring(l)]:Hide()
				end
				_G["GameTooltipTextLeft"..tostring(l)]:SetText( n )
				_G["GameTooltipTextLeft"..tostring(l)]:SetTextColor( r, g, b )
			else
				GameTooltip:AddLine( n, r, g, b )
			end
		else
			GameTooltip:AddLine( n, r, g, b )
		end 
	--else
		-- Insert our line into the tooltip, either at the end or before any other addons' additions
		-- If we're that advanced, that is: this could get horribly complex and dangerous and could easily go horribly wrong, so commented out for now as will need MUCH more testing
		--GameTooltip:AddLine( n, r, g, b )
	--end

end
-- Double string
local function gtadl( n, t, r1, g1, b1, r2, g2, b2 )
	local l = GameTooltip.mrpLines + 1
	GameTooltip.mrpLines = l

	r1, g1, b1 = (r1 or 1.0), (g1 or 1.0), (b1 or 1.0)
	r2, g2, b2 = (r2 or 1.0), (g2 or 1.0), (b2 or 1.0)

	if _G["GameTooltipTextLeft"..tostring(l)] then
		if _G["GameTooltipTextLeft"..tostring(l)]:IsVisible() then
			if _G["GameTooltipTextRight"..tostring(l)] then
				_G["GameTooltipTextRight"..tostring(l)]:Show()
			end
			_G["GameTooltipTextLeft"..tostring(l)]:SetText( n )
			_G["GameTooltipTextLeft"..tostring(l)]:SetTextColor( r1, g1, b1 )
			_G["GameTooltipTextRight"..tostring(l)]:SetText( t )
			_G["GameTooltipTextRight"..tostring(l)]:SetTextColor( r2, g2, b2 )
		else
			GameTooltip:AddDoubleLine( n, t, r1, g1, b1, r2, g2, b2 )
		end
	else
		GameTooltip:AddDoubleLine( n, t, r1, g1, b1, r2, g2, b2 )
	end 
end

-- Add a blank line to the tooltip (if this isn't a compact style)
local function gtabl( )
	if mrpSaved.Options.TooltipStyle ~= 4 and mrpSaved.Options.TooltipStyle ~= 5 then
		gtal( blankline )
	end
end

-- Alternate "Light" mode tooltip embedding. Well, lightER anyway.
-- Actually GameTooltip: AddLines, but with a secret sauce sentinel colour value (overridden in text) to hopefully uniquely identify OUR text line and replace if already present
-- Embed \n to use multiple lines, because this technique limits us to ONE (1) fontstring
local function gtcal( text )
	local t, r, g, b
	for t = 1, GameTooltip:NumLines() do
		local r, g, b = _G["GameTooltipTextLeft"..tostring( t )]:GetTextColor()
		--mrp:DebugSpam( "gtc%s[%s,%s,%s]", t, ceil(r*255), ceil(g*255), ceil(b*255) )
		if ceil(r*255) == 60 and ceil(g*255) == 109 and ceil(b*255) == 144 then
			-- This is ours! Don't add a new one, replace this one
			_G["GameTooltipTextLeft"..tostring( t )]:SetText( text )
			return
		end
	end
	GameTooltip:AddLine( text, 0.2353, 0.4274, 0.5647, false ) -- magic values, match the if statement above
end

-- Tooltip updating
function mrp:UpdateTooltip( player, unit )
	player = player or mrp.TTShown or nil
	local t, r, g, b, n, e, m
	if not player or player == "" or ( mrpSaved.Options.TooltipStyle == 0 ) then
		return false
	end
	if not unit and ( mrp:UnitNameWithRealm("mouseover") == player ) or ( UnitName("mouseover") == player ) then
		unit = "mouseover"
	elseif ( player == UnitName("player") ) then
		unit = "player"
	end
	if not unit then
		return false
	end

	mrp.TTShown = player

	if player == "Unknown" then
		return false
	end

	local name, otherrealm = UnitName( unit )
	local realm = otherrealm or GetRealmName()
	local guid = UnitGUID( unit )
	local guild, guildrank, guildrankindex = GetGuildInfo( unit )
	local factionunloc, faction = UnitFactionGroup( unit )
	local namewithtitle = UnitPVPName( unit ) or UnitName( unit )
	local afk = UnitIsAFK( unit )
	local dnd = UnitIsDND( unit )
	local level = UnitLevel( unit )
	local class, classunloc = UnitClassBase( unit )
	local race = UnitRace( unit )
	local connected = UnitIsConnected( unit )
	local inphase = UnitInPhase( unit )
	local gm = (strsub(name,1,4)=="<GM>")
	local dev = (strsub(name,1,5)=="<DEV>")
	local mspsupported = msp.char[player].supported
	local f
	if mspsupported then
		f = msp.char[player].field
	end

	faction = faction or "Unknown"

	GameTooltip.mrpLines = 0
	GameTooltip.orgLines = 2 + ( guild and 1 or 0 ) + ( UnitIsPVP( unit ) and 1 or 0 ) -- *Should* be the number of lines in the default Blizz player tooltip...?

	-- OK, time to draw the tooltip. Which style to draw it in?
	if mrpSaved.Options.TooltipStyle == 1 then 
		-- Light
		t = ""
		if mspsupported then
			GameTooltipTextLeft1:SetText( emptynil( mrp.DisplayTooltip.NA( f.NA ) ) or namewithtitle )
			if emptynil( f.NT ) then
				t = format( "%s|cffcec185“|cfffef1b5%s|cffcec185”\n", t, mrp.DisplayTooltip.NT( f.NT ) )
			end
			if ( f.FR and f.FR ~= "" and f.FR ~= "0" ) and ( f.FC and f.FC ~= "" and f.FC ~= "0" ) then
				t = format( "%s|cffcc9933<|cffeebb55%s|cffcc9933, |cffddaa44%s|cffcc9933> |cff44aaaa[|cff66dddd%s|cff44aaaa]\n", t, mrp.DisplayTooltip.FR( f.FR ), mrp.DisplayTooltip.FC( f.FC ), mrp.DisplayTooltip.VA( f.VA ) )
			elseif ( f.FR and f.FR ~= "" and f.FR ~= "0" ) then
				t = format( "%s|cffcc9933<|cffeebb55%s|cffcc9933> |cff44aaaa[|cff66dddd%s|cff44aaaa]\n", t, mrp.DisplayTooltip.FR( f.FR ), mrp.DisplayTooltip.VA( f.VA ) )
			elseif ( f.FC and f.FC ~= "" and f.FC ~= "0" ) then
				t = format( "%s|cffcc9933<|cffeebb55%s|cffcc9933> |cff44aaaa[|cff66dddd%s|cff44aaaa]\n", t, mrp.DisplayTooltip.FC( f.FC ), mrp.DisplayTooltip.VA( f.VA ) )
			else
				t = format( "%s|cff44aaaa[|cff66dddd%s|cff44aaaa]\n", t, mrp.DisplayTooltip.VA( f.VA ) )
			end
		end
		r, g, b = mrp:UnitColour( unit )
		GameTooltipTextLeft1:SetTextColor( r, g, b )
		if mrp.id[guid] then
			if mrp.id[guid][1] == realm..(GetCVar("locale")=="enUS" and "-US" or "-EU") then
				t = format( "%s|cffffe680%s", t, mrp.id[guid][2] )
			end
		end
		t = strtrim( t )
		if emptynil( t ) then
			gtcal( strtrim(t) )
			GameTooltip:Show()
		end
	elseif mrpSaved.Options.TooltipStyle == 6 then
		-- RSPish
		t = ""
		if mspsupported then
			GameTooltipTextLeft1:SetText( emptynil( mrp.DisplayTooltip.NA( f.NA ) ) or namewithtitle )
			if emptynil( f.NT ) then
				t = format( "%s|cffcec185“|cfffef1b5%s|cffcec185”\n", t, mrp.DisplayTooltip.NT( f.NT ) )
			end
			if ( f.FR and f.FR ~= "" and f.FR ~= "0" ) and ( f.FC and f.FC ~= "" and f.FC ~= "0" ) then
				t = format( "%s|cffcc9933<|cffeebb55%s|cffcc9933, |cffddaa44%s|cffcc9933>\n", t, mrp.DisplayTooltip.FR( f.FR ), mrp.DisplayTooltip.FC( f.FC ), mrp.DisplayTooltip.VA( f.VA ) )
			elseif ( f.FR and f.FR ~= "" and f.FR ~= "0" ) then
				t = format( "%s|cffcc9933<|cffeebb55%s|cffcc9933>\n", t, mrp.DisplayTooltip.FR( f.FR ), mrp.DisplayTooltip.VA( f.VA ) )
			elseif ( f.FC and f.FC ~= "" and f.FC ~= "0" ) then
				t = format( "%s|cffcc9933<|cffeebb55%s|cffcc9933>\n", t, mrp.DisplayTooltip.FC( f.FC ), mrp.DisplayTooltip.VA( f.VA ) )
			end
		end
		r, g, b = mrp:UnitColour( unit )
		GameTooltipTextLeft1:SetTextColor( r, g, b )
		if mrp.id[guid] then
			if mrp.id[guid][1] == realm..(GetCVar("locale")=="enUS" and "-US" or "-EU") then
				t = format( "%s|cffffe680%s", t, mrp.id[guid][2] )
			end
		end
		t = strtrim( t )
		if emptynil( t ) then
			gtcal( strtrim(t) )
			GameTooltip:Show()
		end
	else 
		-- Enhanced or compact (either with or without guild ranks)
		if mspsupported then
			r, g, b = mrp:UnitColour( unit )
			if afk then
				m = L[" |cff99994d<Away>|r"]
			elseif dnd then
				m = L[" |cff994d4d<Busy>|r"]
			else
				m = ""
			end
			gtal( (emptynil(mrp.DisplayTooltip.NA( f.NA )) or name) .. m, r, g, b )
			local line = false
			if f.NT and f.NT ~= "" then 
				gtal( mrp.DisplayTooltip.NT( f.NT ) , 1.0, 1.0, 1.0 )
				line = true
			end
			if f.NI and f.NI ~= "" then 
				gtal( format( L["|cff6070a0Nickname:|r %s"], mrp.DisplayTooltip.NI( f.NI ) ), 0.6, 0.7, 0.9 )
				line = true
			end
			if f.NH and f.NH ~= "" then 
				gtal( mrp.DisplayTooltip.NH( f.NH ), 0.4, 0.6, 0.7 )
				line = true
			end
		else
			r, g, b = mrp:UnitColour( unit )

			gtal( name, r, g, b )
		end

		if guild and guild ~= "" then
			if mrpSaved.Options.TooltipStyle ~= 3 and mrpSaved.Options.TooltipStyle ~= 5 then
				if guildrankindex == 0 then
					m = format( "|cffffeeaa%s|r", guildrank )
				else
					m = guildrank
				end
				gtal( format( L["%s of <%s>"], m, guild ), 1, 1, 1 )
			else
				-- Show Guild rank disabled (but colour it gold if they're guildmaster)
				gtal( format( "%s<%s>", ( guildrankindex == 0 ) and "|cffffeeaa" or "", guild ), 1, 1, 1 )
			end
			gtabl()
		end

		if not factionunloc then
			r, g, b = 0.4, 0.9, 0.4
		elseif factionunloc == "Alliance" then
			r, g, b = 0.4, 0.5, 0.9
		elseif factionunloc == "Horde" then
			r, g, b = 0.8, 0.3, 0.3
		else
			r, g, b = 1.0, 1.0, 1.0
		end

		if mspsupported then
			if otherrealm and otherrealm ~= "" then
				gtadl( format(L["%s (%s) [%s]"], namewithtitle, faction, otherrealm), format( "%s", mrp.DisplayTooltip.VA( f.VA ) ), r, g, b, 0.7, 0.7, 0.6 )
			else
				gtadl( format(L["%s (%s)"], namewithtitle, faction), format( "%s", mrp.DisplayTooltip.VA( f.VA ) ), r, g, b, 0.7, 0.7, 0.6 )
			end
		else
			if otherrealm and otherrealm ~= "" then
				gtal( format(L["%s (%s) [%s]"], namewithtitle, faction, otherrealm), r, g, b )
			else
				gtal( format(L["%s (%s)"], namewithtitle, faction), r, g, b )
			end
		end

		gtabl()

		r, g, b = RAID_CLASS_COLORS[ classunloc ].r, RAID_CLASS_COLORS[ classunloc ].g, RAID_CLASS_COLORS[ classunloc ].b
		if level ~= nil and level < 0 then
			e = L["|cffffffff(Boss)"]
		else 
			e = format( L["|cffffffffLevel %d"], level )
		end

		if mspsupported then
			gtal( format( L["%s %s |r%s|cffffffff (Player)"], e, emptynil( mrp.DisplayTooltip.RA( f.RA ) ) or race, class), r, g, b )
			r, g, b = 1.0, 1.0, 1.0
			n = nil
			t = nil
			if f.FR and f.FR ~= "" and f.FR ~= "0" then
				n = mrp.DisplayTooltip.FR( f.FR ) .. "  "
			end
			if f.FC and f.FC ~= "" and f.FC ~= "0" then
				t = mrp.DisplayTooltip.FC( f.FC )
				if f.FC == "0" then
					r, g, b = 0.5, 0.5, 0.5
				elseif f.FC == "1" then -- OOC
					r, g, b = 0.6, 0.4, 0.3
				elseif f.FC == "2" then -- IC
					r, g, b = 0.4, 0.7, 0.5
				elseif f.FC == "3" then -- LFC
					r, g, b = 0.6, 0.7, 0.8
				elseif f.FC == "4" then -- Storyteller
					r, g, b = 0.9, 0.8, 0.7
				end	
			end
			if f.CU and f.CU ~= "" then
				gtabl()
				gtal( format( L["|cffa08050Currently:|r %s"], mrp.DisplayTooltip.CU( f.CU ) ), 0.9, 0.7, 0.6 )
				-- Unfortunately, word wrap seems to cause serious problems...
			end
			if n or t then
				n = n or " "
				t = t or " "
				gtabl()
				gtadl( n, t, r, g, b, r, g, b )
			end
		else
			gtal( format( L["%s %s |r%s|cffffffff (Player)"], e, race, class), r, g, b )
		end

		if mrp.Debug or mrp.ShowGUID then
			gtabl()
			gtal( format( L["GUID: %s"], guid ), 0.4, 0.5, 0.6 )
		end

		if not inphase then
			gtabl()
			gtal( L["<Out of Phase>"], 0.5, 0.7, 0.7 )
		end

		if mrp.id[guid] then
			if mrp.id[guid][1] == realm..(GetCVar("locale")=="enUS" and "-US" or "-EU") then
				gtabl()
				gtal( mrp.id[guid][2], 1.0, 0.9, 0.5 )
			end
		end

		if gm then -- a <GM>!
			gtabl()
			gtal( L["<Game Master>"], 0.0, 0.7, 1.0 )
		elseif dev then -- even rarer, a <DEV>!
			gtabl()
			gtal( L["<Blizzard Developer>"], 0.0, 0.7, 1.0 )
		end

		GameTooltip:Show()
	end

	return true
end

-- As found in GameTooltip.lua, but collapsed, and we want a bit more nuance.
function mrp:UnitColour(unit)
	if ( UnitPlayerControlled(unit) ) then
		if ( (strsub( UnitName(unit),1,4 )=="<GM>" ) ) then
			-- Woah, it's a <GM>!
			return 0.0, 0.7, 1.0
		elseif ( UnitCanAttack(unit, "player") ) then
			-- Hostile players are red
			if ( not UnitCanAttack("player", unit) ) then
				return 1.0, 1.0, 1.0
			else
				return FACTION_BAR_COLORS[2].r, FACTION_BAR_COLORS[2].g, FACTION_BAR_COLORS[2].b
			end
		elseif ( UnitCanAttack("player", unit) ) then
			-- Players we can attack but which are not hostile are yellow
			return FACTION_BAR_COLORS[4].r, FACTION_BAR_COLORS[4].g, FACTION_BAR_COLORS[4].b
		elseif ( IsReferAFriendLinked(unit) ) then
			return FACTION_BAR_COLORS[8].r, FACTION_BAR_COLORS[8].g, FACTION_BAR_COLORS[8].b
		elseif ( UnitIsInMyGuild(unit) ) then
			return FACTION_BAR_COLORS[7].r, FACTION_BAR_COLORS[7].g, FACTION_BAR_COLORS[7].b
		elseif ( UnitIsPVP(unit) ) then
			-- Players we can assist but are PvP flagged are green
			return FACTION_BAR_COLORS[6].r, FACTION_BAR_COLORS[6].g, FACTION_BAR_COLORS[6].b
		else
			-- All other players are blue (the usual state on the "blue" server)
			return 0.5, 0.5, 1.0
		end
	else
		local reaction = UnitReaction(unit, "player");
		if ( reaction ) then
			return FACTION_BAR_COLORS[reaction].r, FACTION_BAR_COLORS[reaction].g, FACTION_BAR_COLORS[reaction].b
		else
			return 1.0, 1.0, 1.0
		end
	end
end

function mrp_MSPTooltipCallback( player )
	if player == mrp.TTShown then
		mrp:UpdateTooltip( player )
	end
end