--[[
	MyRolePlay 4 (C) 2010-2011 Etarna Moonshyne <etarna@moonshyne.org>
	Licensed under GNU General Public Licence version 2 or, at your option, any later version

	UI_Editor.lua - MyRolePlayCharacterFrame (the profile editor)
]]

local L = mrp.L

local wipe = wipe

local function emptynil( x ) return x ~= "" and x or nil end

local uipbt = mrp.WoWTOC >= 50001 and "UIPanelButtonTemplate" or "UIPanelButtonTemplate2"

function mrp:CreateCharacterFrame()
	if not MyRolePlayCharacterFrame then

		local cf = CreateFrame( "Frame", "MyRolePlayCharacterFrame", CharacterFrame, nil, 5)
		cf:SetScript("OnShow", function(self)
			CharacterStatsPane:Hide()
			CharacterFrameInsetRight:Hide()
			if mrp.CharacterPanelExpanded then
				CharacterFrame:SetWidth( 700 )
				CharacterFrame.Expanded = true
			else
				CharacterFrame:SetWidth( PANEL_DEFAULT_WIDTH )
				CharacterFrame.Expanded = false
			end
			UpdateUIPanelPositions( CharacterFrame )
			CharacterFramePortrait:SetTexCoord( 0, 1, 0, 1 )
			SetPortraitTexture( CharacterFramePortrait, "player" )
			CharacterFrameTitleText:SetText( msp.my.NA or UnitName("player") )
		end	)
		cf:SetScript("OnHide", function(self)
			HideDropDownMenu( 1 )
			MyRolePlayCharacterFrame.pdd:Hide()
			MyRolePlayMultiEditFrame:Hide()
			MyRolePlayComboEditFrame:Hide()
			MyRolePlayEditFrame:Hide()
			if PaperDollFrame:IsVisible() or ( HasPetUI() and PetPaperDollFrame:IsVisible() ) then
				if GetCVar( "characterFrameCollapsed" ) == "1" then
					CharacterFrame_Collapse()
				else
					CharacterFrame_Expand()
				end
			end
			CharacterFrame_UpdatePortrait()
		end	)

		cf:SetAllPoints()
		cf:SetFrameLevel( CharacterFrame:GetFrameLevel()+2 )

		-- Version
		cf.ver = cf:CreateFontString( nil, "OVERLAY", "GameFontNormalSmall" )
		cf.ver:SetPoint( "TOP", CharacterFrameInset, "TOP", 0, 34 )
		cf.ver:SetText( mrp.VerText )

		-- Profile Combo Box
		cf.pcb = CreateFrame( "Frame", "MyRolePlayCharacterFrame_ProfileComboBox", cf )
		cf.pcb:SetPoint( "TOP", CharacterFrameInset, "TOP", 0, 18 )
		cf.pcb:SetSize( 210, 32 )

		cf.pcb.tl = cf.pcb:CreateTexture( ) -- Left
		cf.pcb.tl:SetPoint( "TOPLEFT", cf.pcb, "TOPLEFT", 0, 17 )
		cf.pcb.tl:SetSize( 25, 50 )
		cf.pcb.tl:SetTexture( "Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame" )
		cf.pcb.tl:SetTexCoord( 0, 0.1953125, 0, 1 )
		cf.pcb.tm = cf.pcb:CreateTexture( ) -- Middle
		cf.pcb.tm:SetPoint( "LEFT", cf.pcb.tl, "RIGHT" )
		cf.pcb.tm:SetSize( 160, 50 )
		cf.pcb.tm:SetTexture( "Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame" )
		cf.pcb.tm:SetTexCoord( 0.1953125, 0.8046875, 0, 1 )
		cf.pcb.tr = cf.pcb:CreateTexture( ) -- Right
		cf.pcb.tr:SetPoint( "LEFT", cf.pcb.tm, "RIGHT" )
		cf.pcb.tr:SetSize( 25, 50 )
		cf.pcb.tr:SetTexture( "Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame" )
		cf.pcb.tr:SetTexCoord( 0.8046875, 1, 0, 1 )
		cf.pcb.button = CreateFrame( "Button", "MyRolePlayCharacterFrame_ProfileComboBox_Button", cf.pcb )
		cf.pcb.button:SetPoint( "TOPRIGHT", cf.pcb.tr, "TOPRIGHT", -16, -12 )
		cf.pcb.button:SetSize( 24, 24 )
		cf.pcb.button:SetScript("OnClick", function() 
			ToggleDropDownMenu( 1, nil, MyRolePlayCharacterFrame.pdd, MyRolePlayCharacterFrame.pcb )
		end )
		cf.pcb.button:SetNormalTexture( "Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up" )
		cf.pcb.button:SetPushedTexture( "Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down" )
		cf.pcb.button:SetHighlightTexture( "Interface\\Buttons\\UI-Common-MouseHilight", "ADD" )

		cf.pcb.text = cf.pcb:CreateFontString( nil, "OVERLAY", "GameFontHighlightSmall" )
		cf.pcb.text:SetPoint( "LEFT", cf.pcb, "LEFT", 27, 10 )
		cf.pcb.text:SetSize( 140, 10 )
		cf.pcb.text:SetJustifyH( "LEFT" )
		cf.pcb.text:SetText( mrpSaved.SelectedProfile or "" )

		cf.pdd = CreateFrame( "Frame", "MyRolePlayCharacterFrame_Profile_Dropdown", cf, "UIDropDownMenuTemplate" )
		cf.pdd.initialize = MyRolePlayCharacterFrame_Profile_Dropdown_Init

		-- [+]
		cf.npb = CreateFrame( "Button", "MyRolePlayCharacterFrame_NewProfileButton", cf, uipbt )
		cf.npb:SetPoint( "LEFT", cf.pcb.button, "RIGHT", 1, 0 )
		cf.npb:SetText( L["+"] )
		cf.npb:SetWidth( 24 )
		cf.npb:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["Create a new profile."], 1.0, 1.0, 1.0 )
		end )
		cf.npb:SetScript( "OnLeave", GameTooltip_Hide )
		cf.npb:SetScript("OnClick", function (self)
			StaticPopup_Show("MRP_NEW_PROFILE")
		end )

		-- [R]
		cf.rpb = CreateFrame( "Button", "MyRolePlayCharacterFrame_RenProfileButton", cf, uipbt )
		cf.rpb:SetPoint( "LEFT", cf.npb, "RIGHT", 1, 0 )
		cf.rpb:SetText( L["R"] )
		cf.rpb:SetWidth( 24 )
		cf.rpb:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			if mrpSaved.SelectedProfile == "Default" then
				GameTooltip:SetText( L["Change the name of this profile. (The default profile can't be renamed.)"], 1.0, 1.0, 1.0 )
			else
				GameTooltip:SetText( L["Change the name of this profile."], 1.0, 1.0, 1.0 )
			end
		end )
		cf.rpb:SetScript( "OnLeave", GameTooltip_Hide )
		cf.rpb:SetScript("OnClick", function (self)
			if mrpSaved.SelectedProfile == "Default" then
				mrp:Print( L["Can’t rename the default profile."] )
			else
				StaticPopup_Show("MRP_RENAME_PROFILE")
			end
		end )

		-- [-]
		cf.dpb = CreateFrame( "Button", "MyRolePlayCharacterFrame_DelProfileButton", cf, uipbt )
		cf.dpb:SetPoint( "LEFT", cf.rpb, "RIGHT", 1, 0 )
		cf.dpb:SetText( L["-"] )
		cf.dpb:SetWidth( 24 )
		cf.dpb:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			if mrpSaved.SelectedProfile == "Default" then
				GameTooltip:SetText( L["Destroy all of your profiles, returning them to the defaults."], 1.0, 1.0, 1.0 )
			else
				GameTooltip:SetText( L["Delete this profile, destroying all its contents."], 1.0, 1.0, 1.0 )
			end
		end )
		cf.dpb:SetScript( "OnLeave", GameTooltip_Hide )
		cf.dpb:SetScript("OnClick", function (self)
			if mrpSaved.SelectedProfile == "Default" then
				StaticPopup_Show("MRP_CLEAR_PROFILE")
			else
				StaticPopup_Show("MRP_DELETE_PROFILE")
			end
		end )

		local mrplfont = CreateFont("MyRolePlayLittleFont")
		mrplfont:SetFont( "Fonts\\FRIZQT__.TTF", 9, "" )
		mrplfont:SetTextColor( 1.0, 1.0, 1.0, 0.85 )
		mrplfont:SetShadowColor( 0, 0, 0, 0 )
		mrplfont:SetJustifyH( "LEFT" )
		mrplfont:SetJustifyV( "TOP" )

		-- A subframe to contain the fields in the profile.
		cf.f = CreateFrame( "Frame", "MyRolePlayCharacterFrame_Fields", cf )
		cf.f:SetPoint( "TOPLEFT", CharacterFrameInset, "TOPLEFT", 5, -6 )
		cf.f:SetPoint( "TOPRIGHT", CharacterFrameInset, "TOPRIGHT", -5, -6 )
		cf.f:SetPoint( "BOTTOMLEFT", CharacterFrameInset, "BOTTOMLEFT", 5, 6 )
		cf.f:SetPoint( "BOTTOMRIGHT", CharacterFrameInset, "BOTTOMRIGHT", -5, 6 )
		cf.f:EnableDrawLayer( "BORDER" )
		cf.f.fields={}

		mrp:CreateCFpfield( cf.f, 'NA', L["NA"], 17, 218, nil, mrp.CFEditField, L["efNA"] )
		mrp:CreateCFpfield( cf.f, 'NI', L["NI"], 17, 96, cf.f.fields['NA'], mrp.CFEditField, L["efNI"] )
		mrp:CreateCFpfield( cf.f, 'NT', L["NT"], 17, -197, cf.f.fields['NA'], mrp.CFEditField, L["efNT"] )
		mrp:CreateCFpfield( cf.f, 'NH', L["NH"], 17, 117, cf.f.fields['NT'], mrp.CFEditField, L["efNH"] )
		mrp:CreateCFpfield( cf.f, 'AE', L["AE"], 17, -81, cf.f.fields['NT'], mrp.CFEditField, L["efAE"] )
		mrp:CreateCFpfield( cf.f, 'RA', L["RA"], 17, 68, cf.f.fields['AE'], mrp.CFEditField, L["efRA"] )
		mrp:CreateCFpfield( cf.f, 'AH', L["AH"], 17, 51, cf.f.fields['RA'], mrp.CFEditField, L["efAH"] )
		mrp:CreateCFpfield( cf.f, 'AW', L["AW"], 17, 51, cf.f.fields['AH'], mrp.CFEditField, L["efAW"] )
		mrp:CreateCFpfield( cf.f, 'AG', L["AG"], 17, 50, cf.f.fields['AW'], mrp.CFEditField, L["efAG"] )
		mrp:CreateCFpfield( cf.f, 'CU', L["CU"], 17, -318, cf.f.fields['AE'], mrp.CFEditField, L["efCU"] )
		mrp:CreateCFpfield( cf.f, 'DE', L["DE"], 88, -318, cf.f.fields['CU'], mrp.CFEditField, L["efDE"] )
		mrp:CreateCFpfield( cf.f, 'HH', L["HH"], 17, -103, cf.f.fields['DE'], mrp.CFEditField, L["efHH"] )
		mrp:CreateCFpfield( cf.f, 'HB', L["HB"], 17, 103, cf.f.fields['HH'], mrp.CFEditField, L["efHB"] )
		mrp:CreateCFpfield( cf.f, 'MO', L["MO"], 17, 104, cf.f.fields['HB'], mrp.CFEditField, L["efMO"] )
		mrp:CreateCFpfield( cf.f, 'HI', L["HI"], 70, -318, cf.f.fields['HH'], mrp.CFEditField, L["efHI"] )
		mrp:CreateCFpfield( cf.f, 'FR', L["FR"], 17, -157, cf.f.fields['HI'], mrp.CFEditField, L["efFR"] )
		mrp:CreateCFpfield( cf.f, 'FC', L["FC"], 17, 157, cf.f.fields['FR'], mrp.CFEditField, L["efFC"] )

		mrp:CreateEditFrames()

		mrp:UpdateCharacterFrame()

		-- Garbage-collect functions we only need once
		mrp.CreateCharacterFrame = mrp_dummyfunction
		mrp.CreateCFpfield = mrp_dummyfunction
	end
end

function mrp:CreateCFpfield( c, field, name, height, width, anchor, onclick, desc )
	local yoffs = 0
	local xoffs = 0
	local anchorpointl = "TOPLEFT"
	local anchorpointr = "TOPRIGHT"
	local sep
	if not anchor then 
		anchor = c
	elseif width then
		if width < 0 then
			width = -width
			yoffs = 12
			anchorpointl = "BOTTOMLEFT"
		else
			sep = true
			yoffs = 0
			xoffs = 4
			anchorpointl = "TOPRIGHT"
		end
	else
		xoffs = 0
		yoffs = 12
		anchorpointl = "BOTTOMLEFT"
		anchorpointr = "BOTTOMRIGHT"
	end
	c.fields[field] = CreateFrame( "Frame", nil, c )
	local f = c.fields[field]
	f:SetPoint( "TOPLEFT", anchor, anchorpointl, xoffs, -yoffs )
	if width then
		f:SetWidth( width )
	else
		f:SetPoint( "TOPRIGHT", anchor, anchorpointr, xoffs, -yoffs )
	end
	f:SetHeight( height )
	f.h = CreateFrame( "Frame", nil, f )
	f.h:SetPoint( "TOPLEFT", anchor, anchorpointl, xoffs, -yoffs )
	f.h:SetHeight( 12 )
	if width then
		f.h:SetWidth( width )
	else
		f.h:SetPoint( "TOPRIGHT", anchor, anchorpointr, xoffs, -yoffs )
	end
	if sep then
		f.sep = CreateFrame( "Frame", nil, f )
		f.sep:SetSize( 4, 12 )
		f.sep:SetPoint( "TOPRIGHT", f.h, "TOPLEFT", -1 )
		f.sep:SetBackdrop( {
			bgFile = [[Interface\AddOns\MyRolePlay\Artwork\FieldSep.blp]],
			tile = false,
		} )
	end
	f.h.fs = f.h:CreateFontString( nil, "ARTWORK", "GameFontNormalSmall" )
	f.h.fs:SetJustifyH( "LEFT" )
	f.h.fs:SetText( "   "..name )
	f.h.fs:SetParent( f.h )
	f.h.fs:SetShadowColor( 0, 0, 0, 0.1 )
	f.h.fs:SetAllPoints()
	f.h.fs:SetPoint("TOPLEFT", f.h, "TOPLEFT", 0, 3 )

	f.h:SetBackdrop( {
			bgFile = [[Interface\AddOns\MyRolePlay\Artwork\HeaderBackground.blp]],
			tile = false,
	} )
	f.t = f:CreateFontString( nil, "ARTWORK", "MyRolePlayLittleFont" )
	f.t:SetWordWrap(true)
	f.t:SetNonSpaceWrap(false)
	f.t:SetParent( f )
	f.t:SetPoint( "TOPLEFT", f.h, "BOTTOMLEFT", 0, -1 )
	f.t:SetPoint( "TOPRIGHT", f.h, "BOTTOMRIGHT", 0, -1 )
	f.t:SetHeight( height - 12 )
	if onclick then 
		f.field = field
		f.fieldname = name
		f.desc = desc
		f.click = onclick
		f:EnableMouse(true)
		f:SetScript( "OnEnter", function(self)
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( name, 0.9, 0.65, 0.35 )
			GameTooltip:AddLine( " " )
			GameTooltip:AddLine( desc, 1.0, 1.0, 1.0 )
			GameTooltip:AddLine( " " )
			GameTooltip:AddLine( "|cff4466eeClick|cffcccccc to edit.|r" )
			GameTooltip:Show()
			if self.lowlight then
				self.t:SetTextColor( 1.0, 1.0, 1.0, 0.6 )
				self.h.fs:SetTextColor( 0.8, 0.62, 0.3, 1.0 )
				self.h:SetBackdrop( {
						bgFile = [[Interface\AddOns\MyRolePlay\Artwork\HeaderBackground-Highlight-Disabled.blp]],
						tile = false,
				} )
			else
				self.t:SetTextColor( 1.0, 1.0, 1.0, 1.0 )
				self.h.fs:SetTextColor( 1.0, 0.92, 0.4, 1 )
				self.h:SetBackdrop( {
						bgFile = [[Interface\AddOns\MyRolePlay\Artwork\HeaderBackground-Highlight.blp]],
						tile = false,
				} )
			end
		end )
		f:SetScript( "OnLeave", function(self)
			if self.lowlight then
				self.t:SetTextColor( 1.0, 1.0, 1.0, 0.4 )
				self.h.fs:SetTextColor( 0.7, 0.52, 0.2, 0.85 )
				self.h:SetBackdrop( {
						bgFile = [[Interface\AddOns\MyRolePlay\Artwork\HeaderBackground-Disabled.blp]],
						tile = false,
				} )
			else
				self.t:SetTextColor( 1.0, 1.0, 1.0, 0.85 )
				self.h.fs:SetTextColor( 1.0, 0.82, 0, 1 )
				self.h:SetBackdrop( {
						bgFile = [[Interface\AddOns\MyRolePlay\Artwork\HeaderBackground.blp]],
						tile = false,
				} )
			end
			GameTooltip:Hide()
		end )
		f:SetScript( "OnMouseUp", function(self)
			self.click( self.field, self.fieldname, self.desc )
		end )
	end
end

-- Update the text in the editor
function mrp:UpdateCharacterFrame()
	local cf = MyRolePlayCharacterFrame
	if not cf then
		return
	end
	cf.pcb.text:SetText( mrpSaved.SelectedProfile or "" )
	-- Can't rename the default profile, so if this is it, disable that button
	-- We can 'delete' the default profile however, it clears it to defaults
	if mrpSaved.SelectedProfile == "Default" then
		cf.rpb:Disable()
	else
		cf.rpb:Enable()
	end
	if cf:IsShown() then 
		CharacterFrameTitleText:SetText( emptynil( msp.my['NA'] ) or UnitName("player") )
	end

	for index, field in pairs( cf.f.fields ) do
		field.t:SetText( mrp.Display[ index ]( msp.my[ index ] ) )
		-- visually lowlight the field if it's templated from the default
		if msp.my[index] == mrpSaved.Profiles.Default[index] and mrpSaved.SelectedProfile ~= "Default" then
			field.lowlight = true
			field.t:SetTextColor( 1.0, 1.0, 1.0, 0.4 )
			field.h.fs:SetTextColor( 0.7, 0.52, 0.2, 0.85 )
			field.h:SetBackdrop( {
					bgFile = [[Interface\AddOns\MyRolePlay\Artwork\HeaderBackground-Disabled.blp]],
					tile = false,
			} )
		else
			field.lowlight = false
			field.t:SetTextColor( 1.0, 1.0, 1.0, 0.85 )
			field.h.fs:SetTextColor( 1.0, 0.82, 0, 1 )
			field.h:SetBackdrop( {
					bgFile = [[Interface\AddOns\MyRolePlay\Artwork\HeaderBackground.blp]],
					tile = false,
			} )	
		end
	end
end


function mrp:UpdateCFProfileScrollFrame()
	HideDropDownMenu( 1 )
end

function MyRolePlayCharacterFrame_Profile_Dropdown_Click( self, profile )
	mrp:SetCurrentProfile( profile )
	MyRolePlayCharacterFrame.pdd:Hide()
	MyRolePlayComboEditFrame:Hide()
	MyRolePlayMultiEditFrame:Hide()
	MyRolePlayEditFrame:Hide()
	mrp:UpdateCharacterFrame()
end

local profiletitles = { }

function MyRolePlayCharacterFrame_Profile_Dropdown_Init( self )
	for k, v in pairs( mrpSaved.Profiles ) do
		if k ~= "Default" then
			tinsert( profiletitles, k )
		end
	end
	table.sort( profiletitles )
	tinsert( profiletitles, 1, "Default" )
	for i = 1, #profiletitles do
		local info = UIDropDownMenu_CreateInfo()
		info.text = profiletitles[ i ]
		info.arg1 = profiletitles[ i ]
		if profiletitles[ i ] == "Default" then 
			info.colorCode = "|cff80f0a0"
		end
		info.func = MyRolePlayCharacterFrame_Profile_Dropdown_Click
		info.owner = MyRolePlayCharacterFrame.pcb.button
		UIDropDownMenu_AddButton( info )
	end
	wipe( profiletitles )
	UIDropDownMenu_SetSelectedValue( MyRolePlayCharacterFrame_Profile_Dropdown, mrpSaved.SelectedProfile or "Default" )
end


StaticPopupDialogs[ "MRP_DELETE_PROFILE" ] = { 
	text = "Are you absolutely certain you want to delete this profile, destroying all the information in it?",
	button1 = YES,
	button2 = NO,
	OnAccept = function ()
		mrpSaved.Profiles[ mrpSaved.SelectedProfile ] = nil
		mrp:SetCurrentProfile( "Default" )
		mrp:UpdateCFProfileScrollFrame()
	end,
	OnCancel = function() end,
	showAlert = 1,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1,
	whileDead = 1,
}
StaticPopupDialogs[ "MRP_CLEAR_PROFILE" ] = { 
	text = "Are you absolutely certain you want to destroy ALL the data in your MyRolePlay profiles and go entirely back to the defaults? There is no going back!",
	button1 = YES,
	button2 = NO,
	OnAccept = function ()
		mrpSaved.Profiles = nil
		mrp:HardResetProfiles()
		mrp:SetCurrentProfile( "Default" )
		mrp:UpdateCFProfileScrollFrame()
	end,
	OnCancel = function() end,
	showAlert = 1,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1,
	whileDead = 1,
}
StaticPopupDialogs["MRP_NEW_PROFILE"] = {
	text = "Please enter the name for the new profile:",
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 40,
	OnAccept = function(self)
		local text = self.editBox:GetText()
		if text and text ~= "" then
			if type(mrpSaved.Profiles[text]) ~= "table" then
				mrpSaved.Profiles[ text ] = { }
			end
			mrp:SetCurrentProfile( text )
			mrp:UpdateCFProfileScrollFrame()
		end
	end,
	EditBoxOnEnterPressed = function(self)
		local text = self:GetParent().editBox:GetText();
		if text and text ~= "" then
			if type(mrpSaved.Profiles[text]) ~= "table" then
				mrpSaved.Profiles[ text ] = { }
			end
			mrp:SetCurrentProfile( text )
			mrp:UpdateCFProfileScrollFrame()
		end
		self:GetParent():Hide()
	end,
	OnShow = function(self)
		self.editBox:SetFocus()
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow()
		self.editBox:SetText("")
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1,
}
StaticPopupDialogs["MRP_RENAME_PROFILE"] = {
	text = "Please enter a new name for this profile:",
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 40,
	OnAccept = function(self)
		local text = self.editBox:GetText()
		if text and text ~= "" then
			if text ~= mrpSaved.SelectedProfile and type(mrpSaved.Profiles[text]) ~= "table" then
				mrpSaved.Profiles[ text ] = mrpSaved.Profiles[ mrpSaved.SelectedProfile ]
				mrpSaved.Profiles[ mrpSaved.SelectedProfile ] = nil
			end
			mrp:SetCurrentProfile( text )
			mrp:UpdateCFProfileScrollFrame()
		end
	end,
	EditBoxOnEnterPressed = function(self)
		local text = self:GetParent().editBox:GetText();
		if text and text ~= "" then
			if text ~= mrpSaved.SelectedProfile and type(mrpSaved.Profiles[text]) ~= "table" then
				mrpSaved.Profiles[ text ] = mrpSaved.Profiles[ mrpSaved.SelectedProfile ]
				mrpSaved.Profiles[ mrpSaved.SelectedProfile ] = nil
			end
			mrp:SetCurrentProfile( text )
			mrp:UpdateCFProfileScrollFrame()
		end
		self:GetParent():Hide();
	end,
	OnShow = function(self)
		self.editBox:SetText( mrpSaved.SelectedProfile or "" )
		self.editBox:SetFocus()
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow()
		self.editBox:SetText("")
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1,
}