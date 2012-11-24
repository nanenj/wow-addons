--[[
	MyRolePlay 4 (C) 2010-2011 Etarna Moonshyne <etarna@moonshyne.org>
	Licensed under GNU General Public Licence version 2 or, at your option, any later version

	FormChange.lua - Automatic profile changing when you change form
]]

local L = mrp.L

local type, select, ipairs = type, select, ipairs
local strtrim, strfind, strsplit = strtrim, strfind, strsplit

local profilestotry

--[[
	Forms supported by autochange, and their possible names (in English).
	We also check localised versions of each of these.
	If we change form, we change profile to a profile named after the form (if any).
]]
local forms = {
	[(CAT_FORM or 1)] = { "Cat" },
	[2] = { "Tree" },
	[3] = { "Travel", "Cheetah" },
	[4] = { "Aquatic", "Sealion", "Seal" },
	[(BEAR_FORM or 5)] = { "Bear" },
	[16] = { "Wolf", "Ghost Wolf" },
	[22] = { "Demon" },
	[27] = { "Flight", "Bird" },
	[28] = { "Shadow" },
	[29] = { "Flight", "Bird" },
	[(MOONKIN_FORM or 31)] = { "Moonkin", "Owlkin" },
}

local formbreakstransform = { 
	[(CAT_FORM or 1)]=true, [2]=true, [3]=true, [4]=true, 
	[(BEAR_FORM or 5)]=true, [22]=true, [27]=true, [28]=false, [(MOONKIN_FORM or 31)]=true,
}

--[[ WoW 4.1 unfortunately removed the CanTransform() API function.
Fake it: we can't transform if we're in combat, on a taxi, charmed, dead, a ghost, or have the Darkflight aura.
]]
local function CanTransform()
	if ( not UnitAffectingCombat("player") ) and ( not UnitIsDeadOrGhost("player") ) and ( not UnitIsCharmed("player") ) and ( not UnitOnTaxi("player") ) then
		for i = 1, 40 do
			if ( select( 11, UnitBuff( "player", i ) ) ) == 68992 then
				return nil
			end
		end
		return 1
	else
		return nil
	end
end

function mrp:AutoChangeProfileForm( names, unform )
	if not mrpSaved.Options.FormAutoChange then return end
	local base, back, w
	if mrpSaved.PreviousProfileManual and mrpSaved.PreviousProfileManual ~= "Default" then
		-- First, check if the user has simply manually selected what would normally be an auto profile.
		-- If they have, then we should regard it as auto.
		local p = select( -1, strsplit( ":", mrpSaved.PreviousProfileManual ) ) -- suffix if necessary
		local isautoform

		if p == (select( 2, UnitRace("player") )) or p == UnitRace("player") then
			isautoform = true
		elseif p == "Human" or p == L["Human"] then
			isautoform = true
		else
			for formid, t in pairs( forms ) do
				for k, v in ipairs( t ) do
					if p == v or p == L[ v ] then
						isautoform = true
						mrp:DebugSpam( "isautoform" )
					end
				end
			end
		end

		if isautoform then
			back = strmatch( mrpSaved.PreviousProfileManual, "(.*):" )
			mrp:DebugSpam("strmatch result: “%s”", back or "")
			if back then
				base = back .. ":"
			else
				back = "Default"
				base = ""
			end
		else
			back = mrpSaved.PreviousProfileManual
			base = mrpSaved.PreviousProfileManual .. ":"
		end
	else
		back = "Default"
		base = ""
	end
	mrp:DebugSpam( "back=“%s”, base=“%s”", back, base )
	local found = false
	for k, v in ipairs( names ) do
		if type(mrpSaved.Profiles[strtrim(base..v)]) == "table" then
			w = strtrim(base..v)
		elseif type(mrpSaved.Profiles[L[strtrim(base..v)]]) == "table" then
			w = L[strtrim(base..v)]
		end
	end
	if w then
		if w == mrpSaved.SelectedProfile then
			mrp:DebugSpam( "formac: “%s” already selected for some reason, nothing to do (previous manual: “%s”)", w, back )
		else
			mrp:DebugSpam( "formac: autochange: “%s” -> “%s” (previous manual: “%s”)", mrpSaved.SelectedProfile, w, back )
			mrp:SetCurrentProfile( w, true )
		end
	else
		if unform then
			if mrpSaved.SelectedProfile == back then
				mrp:DebugSpam( "formac: not found, and previous manual (“%s”) is already selected", back )
			else
				mrp:DebugSpam( "formac: not found, changing back from “%s” to previous manual, “%s”", mrpSaved.SelectedProfile, back )
				mrp:SetCurrentProfile( back, true )
			end
		else
			mrp:DebugSpam( "formac: not found, staying with “%s” (previous manual: “%s”)", mrpSaved.SelectedProfile, back )
		end
	end
end

function mrp:FormChanged( istransform )
	local form = GetShapeshiftFormID()-- returns nil if default
	if not istransform and mrp.oldform == form then 
		mrp:DebugSpam( "form:%d->%d (no change)", (oldform or 0), (form or 0) )
		return 
	end
	local oldform = mrp.oldform
	mrp.oldform = form
	
	local unform

	local class = select( 2, UnitClass("player") )
	local race = select( 2, UnitRace("player") )

	if race == "Worgen" then
		--[[
			Note: Until Blizz implement GetTransformID() or thereabouts, we'll have to guess if our worgen is in human form!
			This complicates the matter somewhat, and may not be 100% accurate. Let's try to do the best we can.
		]]
		if formbreakstransform[ form or 0 ] and not istransform then
			mrpSaved.HumanForm = false
		end
		if forms[ form or 0 ] then
			if form == 28 then
				-- Shadowform. We can be in shadow AND worgen, or shadow AND human. Pick accordingly if possible.
				if mrpSaved.HumanForm == true then
					profilestotry = { "Human:Shadow", "Shadow:Human", "Shadow" }
				elseif mrpSaved.HumanForm == false then
					profilestotry = { "Worgen:Shadow", "Shadow:Worgen", "Shadow" }
				else
					profilestotry = { "Shadow" } -- we really don't know which
				end
			else
				profilestotry = forms[ form or 0 ]
			end
			mrp:DebugSpam( "form:%d->%d%s, xf:%s->%s%s, newform:%s", (oldform or 0), (form or 0), istransform and " (transform)" or "", mrp.oldtransformid==nil and "?" or mrp.oldtransformid and "H" or "W", mrpSaved.HumanForm==nil and "?" or mrpSaved.HumanForm and "H" or "W", formbreakstransform[ form or 0 ] and " (forces W)" or "", table.concat( profilestotry, "," ) )
			mrp.oldtransformid = mrpSaved.HumanForm
		else
			unform = true
			if mrpSaved.HumanForm == true then
				profilestotry = { "Human" }
			elseif mrpSaved.HumanForm == false then
				profilestotry = { "Worgen" }
			else
				profilestotry = {}
			end
			mrp:DebugSpam( "form:%d->%d%s, xf:%s->%s%s, newform:%s%s", (oldform or 0), (form or 0), istransform and " (transform)" or "", mrp.oldtransformid==nil and "?" or mrp.oldtransformid and "H" or "W", mrpSaved.HumanForm==nil and "?" or mrpSaved.HumanForm and "H" or "W", formbreakstransform[ form or 0 ] and " (forces W)" or "", table.concat( profilestotry, "," ), unform and " (back)" or "" )
			mrp.oldtransformid = mrpSaved.HumanForm
		end
	else
		if forms[ form or 0 ] then
			profilestotry = forms[ form or 0 ]
		else
			unform = true
			profilestotry = { UnitRace("player") }
		end
		mrp:DebugSpam( "form:%d->%d%s, newform:%s%s", (oldform or 0), (form or 0), istransform and " (transform?!)" or "", table.concat( profilestotry, "," ), unform and " (back)" or "" )
	end

	mrp:AutoChangeProfileForm( profilestotry, unform )
end

local function mrp_FormChangeEvent( this, event, ... )
	if event == "UPDATE_SHAPESHIFT_FORM" then
		mrp:FormChanged()
	end
end

local function mrp_FormChangeEvent2( this, event, ... )
	if event ~= "COMBAT_LOG_EVENT_UNFILTERED" then return end
	-- TODO: REMOVE CONDITIONAL WHEN 4.2 IS LIVE
	local eventtype, guid, spellid, spellname, _
	if mrp.WoWBuild > 14102 then
		eventtype, _, guid, _, _, _, _, _, _, _, spellid, spellname = select( 2, ... ) -- >= WoW 4.2.0.14103: added sourceRaidFlags [6] & destRaidFlags [10]
	else
		eventtype, _, guid, _, _, _, _, _, spellid, spellname = select(2, ...) -- WoW 4.1.0.14007: added hideCaster [2]
	end
	if guid ~= UnitGUID("player") then return end
	if eventtype == "SPELL_CAST_SUCCESS" then
		mrp:DebugSpam("spell %d, %s", spellid, spellname)
		if spellid == 68996 then -- Two Forms - but which are we in now?! Argh. nil = don't know
			-- Success at casting does NOT mean success at transformation.
			if not CanTransform() then return end
			-- Ironically, this can still fail. Argh.
			mrp.oldtransformid = mrpSaved.HumanForm
			if mrpSaved.HumanForm == true then
				mrpSaved.HumanForm = false
			elseif mrpSaved.HumanForm == false then
				mrpSaved.HumanForm = true
			end
			mrp:FormChanged(true)
		elseif spellid == 68992 then -- Darkflight
			mrp.oldtransformid = mrpSaved.HumanForm
			mrpSaved.HumanForm = false
			mrp:FormChanged(true)
		end
	elseif eventtype == "SPELL_AURA_APPLIED" then
		if spellid == 87840 then -- Running Wild
			mrp.oldtransformid = mrpSaved.HumanForm
			mrpSaved.HumanForm = false
			mrp:FormChanged(true)
		end
	end
end

local function mrp_FormChangeEvent3( this, event, ... )
	if event == "PLAYER_REGEN_DISABLED" then
		mrp.oldtransformid = mrpSaved.HumanForm
		mrpSaved.HumanForm = false
		mrp:FormChanged(true)
	end
end

local df = MyRolePlayDummyFormChangeFrame or CreateFrame( "Frame", "MyRolePlayDummyFormChangeFrame" )
df:SetScript( "OnEvent", mrp_FormChangeEvent )

local df2 = MyRolePlayDummyFormChange2Frame or CreateFrame( "Frame", "MyRolePlayDummyFormChange2Frame" )
df2:SetScript( "OnEvent", mrp_FormChangeEvent2 )

local df3 = MyRolePlayDummyFormChange3Frame or CreateFrame( "Frame", "MyRolePlayDummyFormChange3Frame" )
df3:SetScript( "OnEvent", mrp_FormChangeEvent3 )

function mrp:HookFormChange()
	if select( 2, UnitRace("player") ) == "Worgen" or 
		select( 2, UnitClass("player") ) == "DRUID" or 
		select( 2, UnitClass("player") ) == "SHAMAN" or 
		select( 2, UnitClass("player") ) == "PRIEST" or 
		select( 2, UnitClass("player") ) == "WARLOCK" then
		mrp.formchangehooked = true
		mrp.oldform = GetShapeshiftFormID()
		mrp.oldtransformid = mrpSaved.HumanForm
		MyRolePlayDummyFormChangeFrame:RegisterEvent( "UPDATE_SHAPESHIFT_FORM" )
		if select( 2, UnitRace("player") ) == "Worgen" then
			MyRolePlayDummyFormChange2Frame:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED" )
			MyRolePlayDummyFormChange3Frame:RegisterEvent( "PLAYER_REGEN_DISABLED" )
		end
	end
end

function mrp:UnhookFormChange()
	if mrp.formchangehooked then
		MyRolePlayDummyFormChangeFrame:UnregisterEvent( "UPDATE_SHAPESHIFT_FORM" )
		if mrp.OldTransform then
			MyRolePlayDummyFormChange2Frame:UnregisterEvent( "COMBAT_LOG_EVENT_UNFILTERED" )
			MyRolePlayDummyFormChange3Frame:UnregisterEvent( "PLAYER_REGEN_DISABLED" )
			mrpSaved.HumanForm = nil -- We don't know anymore
		end
	end
end