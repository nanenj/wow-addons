--[[
	MyRolePlay 4 (C) 2010-2011 Etarna Moonshyne <etarna@moonshyne.org>
	Licensed under GNU General Public Licence version 2 or, at your option, any later version

	UI_Browser.lua - MyRolePlayBrowseFrame (the profile browser), and support functions
]]

local L = mrp.L

local function emptynil( x ) return x ~= "" and x or nil end

function mrp:CreateBrowseFrame()
	if not MyRolePlayBrowseFrame then
		-- make local when done dev
		local bf = CreateFrame( "Frame", "MyRolePlayBrowseFrame", UIParent, "ButtonFrameTemplate" )
		bf:Hide()
		bf:SetScript("OnShow", function(self)
			PlaySound("igSpellBookOpen")
		end	)
		bf:SetScript("OnHide", function(self)
			mrp.BFShown = nil
			PlaySound("PutDownBook")
		end	)

		bf:ClearAllPoints()
		if mrpSaved.Positions.Browser then
			bf:SetPoint( mrpSaved.Positions.Browser[1], nil, mrpSaved.Positions.Browser[1], mrpSaved.Positions.Browser[2], mrpSaved.Positions.Browser[3] )
			bf:SetSize( mrpSaved.Positions.Browser[4] or 338, mrpSaved.Positions.Browser[5] or 424 )
		else
			bf:SetPoint( "CENTER", UIParent, "CENTER", 0, 0 )
		end
		bf:SetFrameStrata( "HIGH" )
		bf:SetToplevel( true )

		MyRolePlayBrowseFrameTitleText:SetText( "MyRolePlay Profile Browser" )
		SetPortraitToTexture( "MyRolePlayBrowseFramePortrait", "Interface\\Icons\\INV_Misc_Book_06" )

		bf:EnableMouse()
		bf:SetMovable( true )
		bf:SetResizable( true )
		bf:SetClampedToScreen( true )
		bf:RegisterForDrag("LeftButton")
		bf:SetScript("OnDragStart", function(self)
			self:StartMoving()
		end	)
		bf:SetScript("OnDragStop", function(self)
			self:StopMovingOrSizing()
			mrpSaved.Positions.Browser = { select( 3, MyRolePlayBrowseFrame:GetPoint() ) }
			mrpSaved.Positions.Browser[4] = MyRolePlayBrowseFrame:GetWidth()
			mrpSaved.Positions.Browser[5] = MyRolePlayBrowseFrame:GetHeight()
		end	)
		ButtonFrameTemplate_ShowButtonBar( bf )

		bf:SetMinResize( 338, 424 ) -- from UIPanelTemplates.xml > ButtonFrameTemplate > PortraitFrameTemplate

		-- Swipe CharacterFrameTabButtonTemplate, and mould it to our purposes
		bf.tab1 = CreateFrame( "Button", "MyRolePlayBrowseFrameTab1", bf, "CharacterFrameTabButtonTemplate", 1 )
		bf.tab1:SetPoint( "TOPLEFT", bf, "BOTTOMLEFT", 11, 2 )
		bf.tab1:SetText( L["Appearance"] )
		bf.tab1:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["Descriptions of the character’s appearance."], 1.0, 1.0, 1.0 )
		end )
		bf.tab1:SetScript( "OnLeave", GameTooltip_Hide )
		-- Due to our purloining the tab template from the CharacterFrame, we must override OnClick and OnShow as they have CharacterFrame-specific code
		bf.tab1:SetScript( "OnClick", function(self)
			mrp:TabSwitchBF( "Appearance" )
		end )
		-- CharacterFrameTabButtonTemplate has a bounds check in here too, but since we only have 2 tabs, there's no need to shoehorn them in, there's plenty of room
		bf.tab1:SetScript( "OnShow", function(self)
			PanelTemplates_TabResize( self, 0 )
		end )

		bf.tab2 = CreateFrame( "Button", "MyRolePlayBrowseFrameTab2", bf, "CharacterFrameTabButtonTemplate", 2 )
		bf.tab2:SetPoint( "LEFT", bf.tab1, "RIGHT", -15, 0 )
		bf.tab2:SetText( L["Biography"] )
		bf.tab2:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["Biographical and historical information."], 1.0, 1.0, 1.0 )
		end )
		bf.tab2:SetScript( "OnLeave", GameTooltip_Hide )
		bf.tab2:SetScript( "OnClick", function(self)
			mrp:TabSwitchBF( "Biography" )
		end )
		bf.tab2:SetScript( "OnShow", function(self)
			PanelTemplates_TabResize( self, 0 )
		end )

		-- Appearance + Biography, makes two
		bf.numTabs = 2
		PanelTemplates_TabResize( bf.tab1, 0 )
		PanelTemplates_TabResize( bf.tab2, 0 )
		PanelTemplates_SetTab( bf, 1 )


		bf:EnableDrawLayer( "OVERLAY" )

		bf.ver = bf:CreateFontString( nil, "OVERLAY", "MyRolePlayLittleFont" )
		bf.ver:SetJustifyH( "LEFT" )
		bf.ver:SetPoint( "BOTTOMLEFT", 8, 10 )
		bf.ver:SetAlpha( 0.5 )
		bf.ver:SetSize( bf:GetWidth()-8, 10 )

		bf.nickname = bf:CreateFontString( nil, "OVERLAY", "GameFontNormalSmall" )
		bf.nickname:SetPoint( "TOP", 0, -25 )
		bf.nickname:SetSize( bf:GetWidth()-16, 10 )

		bf.house = bf:CreateFontString( nil, "OVERLAY", "GameFontNormalSmall" )
		bf.house:SetPoint( "TOP", 0, -36 )
		bf.house:SetSize( bf:GetWidth()-16, 10 )

		bf.title = bf:CreateFontString( nil, "OVERLAY", "GameFontHighlightSmall" )
		bf.title:SetPoint( "TOP", 0, -48 )
		bf.title:SetSize( bf:GetWidth()-16, 10 )


		bf.inset = MyRolePlayBrowseFrameInset
		bf.inset:SetPoint( "TOPLEFT", bf, "TOPLEFT", 4, -60 )
		bf.inset:SetPoint( "BOTTOMRIGHT", bf, "BOTTOMRIGHT", -6, 25 )


		bf.Appearance = CreateFrame( "Frame", nil, bf.inset, nil, 1 )
		bfa = bf.Appearance
		bfa:SetPoint( "TOPLEFT", 3, -3 )
		bfa:SetPoint( "BOTTOMRIGHT", -3, 3 )
		bfa:SetFrameLevel( bf.inset:GetFrameLevel()+2 )

		local x = bfa:GetWidth()
		local y

		bfa.fields = { }

		bfa:EnableDrawLayer( "OVERLAY" )

		y = (x - 6) / 2
 		
		mrp:CreateBFpfield( bfa, 'FR', L["FR"], 23, y, nil )
		mrp:CreateBFpfield( bfa, 'FC', L["FC"], 23, y, bfa.fields.FR )

		y = (x - 18) / 8

 		mrp:CreateBFpfield( bfa, 'AE', L["AE"], 23, -(y*2.5), bfa.fields.FR )
 		mrp:CreateBFpfield( bfa, 'RA', L["RA"], 23, y*2.5, bfa.fields.AE )
		mrp:CreateBFpfield( bfa, 'AH', L["AH"], 23, y*1.5, bfa.fields.RA )
		mrp:CreateBFpfield( bfa, 'AW', L["AW"], 23, y*1.5, bfa.fields.AH )

		mrp:CreateBFpfield( bfa, 'CU', L["CU"], 23, -x, bfa.fields.AE )

		mrp:CreateBFpfield( bfa, 'DE', L["DE"], nil, -x, bfa.fields.CU, true )

		bfa.sf = CreateFrame( "ScrollFrame", "MyRolePlayBrowseFrameAScrollFrame", bfa, "UIPanelScrollFrameTemplate" )
		bfa.sf:SetPoint( "TOPLEFT", bfa.fields.DE.h, "BOTTOMLEFT", 0, 0 )
		bfa.sf:SetPoint( "BOTTOMRIGHT", bf.inset, "BOTTOMRIGHT", -26, 3 )

		bfa.sf:EnableMouse(true)
		bfa.sf.scrollbarHideable = false

		ScrollBar_AdjustAnchors( MyRolePlayBrowseFrameAScrollFrameScrollBar, -1, -1, 1)

		bfa.sf.editbox = CreateFrame( "EditBox", nil, bfa.sf )
		bfa.sf.editbox.cursorOffset = 0
		bfa.sf.editbox:SetPoint( "TOPLEFT" )
		bfa.sf.editbox:SetPoint( "BOTTOMLEFT" )

		bfa.sf.editbox:SetWidth( x-24 )
		bfa.sf.editbox:SetSpacing( 1 )
		bfa.sf.editbox:SetTextInsets( 3, 3, 4, 4 )
		bfa.sf.editbox:EnableMouse(false)
		bfa.sf.editbox:EnableKeyboard(false)
		bfa.sf.editbox:SetAutoFocus(false)
		bfa.sf.editbox:SetMultiLine(true)
		bfa.sf.editbox:SetFontObject( "GameFontHighlight" )
		bfa.sf:SetScrollChild( bfa.sf.editbox )


		bfa.sf.editbox:SetScript( "OnEscapePressed", EditBox_ClearFocus )
		bfa.sf.editbox:SetScript( "OnEditFocusLost", EditBox_ClearHighlight )
		bfa.sf.editbox:SetScript( "OnEditFocusGained", EditBox_HighlightText )

		bfa.sf.editbox:SetScript( "OnTextChanged", function(self)
			ScrollingEdit_OnTextChanged(self, self:GetParent())
		end	)
		bfa.sf.editbox:SetScript( "OnCursorChanged", function(self, x, y, w, h)
			ScrollingEdit_OnCursorChanged(self, x, y-10, w, h)
		end )
		bfa.sf.editbox:SetScript( "OnUpdate", function(self, elapsed)
			ScrollingEdit_OnUpdate(self, elapsed, self:GetParent())
		end	)

		ScrollFrame_OnScrollRangeChanged(MyRolePlayBrowseFrameAScrollFrame)


		bf.Biography = CreateFrame( "Frame", nil, bf.inset, nil, 2 )
		bfb = bf.Biography
		bfb:SetPoint( "TOPLEFT", 3, -3 )
		bfb:SetPoint( "BOTTOMRIGHT", -3, 3 )
		bfb:SetFrameLevel( bf.inset:GetFrameLevel()+2 )
		bfb:Hide()

		x = bfb:GetWidth()

		bfb.fields = { }

		bfb:EnableDrawLayer( "OVERLAY" )

		y = (x - 12) / 5
 		
		mrp:CreateBFpfield( bfb, 'AG', L["AG"], 30, y, nil )
		mrp:CreateBFpfield( bfb, 'HH', L["HH"], 30, y*2, bfb.fields.AG )
		mrp:CreateBFpfield( bfb, 'HB', L["HB"], 30, y*2, bfb.fields.HH )

		mrp:CreateBFpfield( bfb, 'MO', L["MO"], 30, -x, bfb.fields.AG )

		mrp:CreateBFpfield( bfb, 'HI', L["HI"], nil, -x, bfb.fields.MO, true )

		bfb.sf = CreateFrame( "ScrollFrame", "MyRolePlayBrowseFrameBScrollFrame", bfb, "UIPanelScrollFrameTemplate" )
		bfb.sf:SetPoint( "TOPLEFT", bfb.fields.HI.h, "BOTTOMLEFT", 0, 0 )
		bfb.sf:SetPoint( "BOTTOMRIGHT", bf.inset, "BOTTOMRIGHT", -26, 3 )

		bfb.sf:EnableMouse(true)
		bfb.sf.scrollbarHideable = false

		ScrollBar_AdjustAnchors( MyRolePlayBrowseFrameBScrollFrameScrollBar, -1, -1, 1)

		bfb.sf.editbox = CreateFrame( "EditBox", nil, bfb.sf )
		bfb.sf.editbox.cursorOffset = 0
		bfb.sf.editbox:SetPoint( "TOPLEFT" )
		bfb.sf.editbox:SetPoint( "BOTTOMLEFT" )

		bfb.sf.editbox:SetWidth( x-24 )
		bfb.sf.editbox:SetSpacing( 1 )
		bfb.sf.editbox:SetTextInsets( 3, 3, 4, 4 )
		bfb.sf.editbox:EnableMouse(false)
		bfb.sf.editbox:EnableKeyboard(false)
		bfb.sf.editbox:SetAutoFocus(false)
		bfb.sf.editbox:SetMultiLine(true)
		bfb.sf.editbox:SetFontObject( "GameFontHighlight" )
		bfb.sf:SetScrollChild( bfb.sf.editbox )


		bfb.sf.editbox:SetScript( "OnEscapePressed", EditBox_ClearFocus )
		bfb.sf.editbox:SetScript( "OnEditFocusLost", EditBox_ClearHighlight )
		bfb.sf.editbox:SetScript( "OnEditFocusGained", EditBox_HighlightText )

		bfb.sf.editbox:SetScript( "OnTextChanged", function(self)
			ScrollingEdit_OnTextChanged(self, self:GetParent())
		end	)
		bfb.sf.editbox:SetScript( "OnCursorChanged", function(self, x, y, w, h)
			ScrollingEdit_OnCursorChanged(self, x, y-10, w, h)
		end )
		bfb.sf.editbox:SetScript( "OnUpdate", function(self, elapsed)
			ScrollingEdit_OnUpdate(self, elapsed, self:GetParent())
		end	)

		ScrollFrame_OnScrollRangeChanged(MyRolePlayBrowseFrameBScrollFrame)

		bf.sizer = CreateFrame( "Button", "MyRolePlayBrowseFrameSizer", bf )
		bf.sizer:SetNormalTexture( [[Interface\ChatFrame\UI-ChatIM-SizeGrabber-Up]] )
		bf.sizer:SetHighlightTexture( [[Interface\ChatFrame\UI-ChatIM-SizeGrabber-Highlight]] )
		bf.sizer:SetPushedTexture( [[Interface\ChatFrame\UI-ChatIM-SizeGrabber-Down]] )
		bf.sizer:RegisterForDrag( "LeftButton" )
		bf.sizer:SetSize( 16, 16 )
		bf.sizer:SetPoint( "BOTTOMRIGHT", bf, "BOTTOMRIGHT", -5, 3 )
		bf.sizer:SetScript("OnDragStart", function(self)
			MyRolePlayBrowseFrame:StartSizing()
		end	)
		bf.sizer:SetScript("OnDragStop", function(self)
			MyRolePlayBrowseFrame:StopMovingOrSizing()
			mrp_BrowseFrameSizeUpdate( MyRolePlayBrowseFrame, MyRolePlayBrowseFrame:GetWidth(), MyRolePlayBrowseFrame:GetHeight() )
			mrpSaved.Positions.Browser = { select( 3, MyRolePlayBrowseFrame:GetPoint() ) }
			mrpSaved.Positions.Browser[4] = MyRolePlayBrowseFrame:GetWidth()
			mrpSaved.Positions.Browser[5] = MyRolePlayBrowseFrame:GetHeight()
		end	)

		bf:SetScript( "OnSizeChanged", mrp_BrowseFrameSizeUpdate )

		-- Garbage-collect functions we only need once
		mrp.CreateBrowseFrame = mrp_dummyfunction
		mrp.CreateBFpfield = mrp_dummyfunction
	end
end

function mrp_BrowseFrameSizeUpdate( bf, width, height )
	local x = bf.Appearance:GetWidth()
	local f = bf.Appearance.fields
	local y

	y = (x - 6) / 2
	f.FR:SetWidth( y )
	f.FC:SetWidth( y )

	y = (x - 18) / 8
	f.AE:SetWidth( y * 2.5 )
	f.RA:SetWidth( y * 2.5 )
	f.AH:SetWidth( y * 1.5 )
	f.AW:SetWidth( y * 1.5 )

	f.CU:SetWidth( x )

	f.DE:SetWidth( x )
	f.DE.h:SetWidth( x )
	bf.Appearance.sf.editbox:SetWidth( x-24 )

	ScrollFrame_OnScrollRangeChanged( MyRolePlayBrowseFrameAScrollFrame )

	x = bf.Biography:GetWidth()
	f = bf.Biography.fields

	y = (x - 12) / 5

	f.AG:SetWidth( y )
	f.HH:SetWidth( y * 2 )
	f.HB:SetWidth( y * 2 )

	f.MO:SetWidth( x )
	f.HI:SetWidth( x )
	f.HI.h:SetWidth( x )
	bf.Biography.sf.editbox:SetWidth( x-24 )

	ScrollFrame_OnScrollRangeChanged( MyRolePlayBrowseFrameBScrollFrame )
end

function mrp:TabSwitchBF( tab )
	if tab == "Appearance" then
		PanelTemplates_SetTab( MyRolePlayBrowseFrame, 1 )
		MyRolePlayBrowseFrame.Biography:Hide()
		MyRolePlayBrowseFrame.Appearance:Show()
	elseif tab == "Biography" then
		PanelTemplates_SetTab( MyRolePlayBrowseFrame, 2 )
		MyRolePlayBrowseFrame.Appearance:Hide()
		MyRolePlayBrowseFrame.Biography:Show()
	end
	PlaySound("igAbiliityPageTurn") -- Yes, two Is. Blizzard's typo, not mine. Don't fix.
end

-- Patterned off of CreateCFpfield, with some removals and amendments
-- c = container
function mrp:CreateBFpfield( c, field, name, height, width, anchor, complex )
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
			yoffs = 14
			anchorpointl = "BOTTOMLEFT"
		else
			sep = true
			yoffs = 0
			xoffs = 6
			anchorpointl = "TOPRIGHT"
		end
	else
		xoffs = 0
		yoffs = 14
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
	if height then
		f:SetHeight( height )
	end
	f.h = CreateFrame( "Frame", nil, f )
	f.h:SetPoint( "TOPLEFT", anchor, anchorpointl, xoffs, -yoffs )
	f.h:SetHeight( 14 )
	if width then
		if complex then
			f.h:SetWidth( width )
		else
			f.h:SetWidth( width )
			f.h:SetPoint( "TOPRIGHT", f )
		end
	else
		f.h:SetPoint( "TOPRIGHT", anchor, anchorpointr, xoffs, -yoffs )
	end
	if sep then
		f.sep = CreateFrame( "Frame", nil, f )
		f.sep:SetSize( 6, 14 )
		f.sep:SetPoint( "TOPRIGHT", f.h, "TOPLEFT", -1 )
		f.sep:SetBackdrop( {
			bgFile = [[Interface\AddOns\MyRolePlay\Artwork\FieldSep.blp]],
			tile = false,
		} )
	end
	f.h.fs = f.h:CreateFontString( nil, "ARTWORK", "GameFontNormalSmall" )
	f.h.fs:SetJustifyH( "LEFT" )
	f.h.fs:SetText( "    "..name )
	f.h.fs:SetParent( f.h )
	f.h.fs:SetShadowColor( 0, 0, 0, 0.1 )
	f.h.fs:SetAllPoints()
	f.h.fs:SetPoint("TOPLEFT", f.h, "TOPLEFT", 0, 3 )

	f.h:SetBackdrop( {
			bgFile = [[Interface\AddOns\MyRolePlay\Artwork\HeaderBackground.blp]],
			tile = false,
	} )
	if not complex then
		f.t = f:CreateFontString( nil, "ARTWORK", "GameFontHighlightSmall" )
		f.t:SetJustifyH( "LEFT" )
		f.t:SetJustifyV( "TOP" )
		f.t:SetWordWrap(true)
		f.t:SetNonSpaceWrap(false)
		f.t:SetSpacing( 1 )
		f.t:SetParent( f )
		f.t:SetPoint( "TOPLEFT", f.h, "BOTTOMLEFT", 3, -4 )
		f.t:SetPoint( "TOPRIGHT", f.h, "BOTTOMRIGHT", -3, -4 )
		if height then
			f.t:SetHeight( height - 14 )
		else
			f.t:SetHeight( 0 )
		end
	end
end

-- Update the text and so forth in the BrowseFrame
function mrp:UpdateBrowseFrame( player )
	player = player or mrp.BFShown or nil
	if not player or player == "" then
		return false
	end
	mrp.BFShown = player
	
	local f = msp.char[ player ].field
	local bf = MyRolePlayBrowseFrame

	MyRolePlayBrowseFrameTitleText:SetText( mrp.DisplayBrowser.NA( emptynil(f.NA) or player ) )

	bf.ver:SetText( mrp.DisplayBrowser.VA( f.VA ) )
	bf.nickname:SetText( mrp.DisplayBrowser.NI( f.NI ) )
	bf.house:SetText( mrp.DisplayBrowser.NH( f.NH ) )
	bf.title:SetText( mrp.DisplayBrowser.NT( f.NT ) )

	bfa = bf.Appearance

	bfa.fields.FR.t:SetText( mrp.DisplayBrowser.FR( f.FR ) )
	bfa.fields.FC.t:SetText( mrp.DisplayBrowser.FC( f.FC ) )

	bfa.fields.RA.t:SetText( emptynil( mrp.DisplayBrowser.RA( f.RA ) ) or L[ mrp.DisplayBrowser.GR( f.GR ) ] )

	bfa.fields.AE.t:SetText( mrp.DisplayBrowser.AE( f.AE ) )
	bfa.fields.AH.t:SetText( mrp.DisplayBrowser.AH( f.AH ) )
	bfa.fields.AW.t:SetText( mrp.DisplayBrowser.AW( f.AW ) )

	bfa.fields.CU.t:SetText( mrp.DisplayBrowser.CU( f.CU ) )

	local t = mrp.DisplayBrowser.DE( f.DE )
	if bfa.sf.editbox:GetText() ~= t then
		bfa.sf.editbox:SetText( t )
		bfa.sf.editbox:SetCursorPosition( 0 )
		ScrollFrame_OnScrollRangeChanged(MyRolePlayBrowseFrameAScrollFrame)
	end

	bfb = bf.Biography

	bfb.fields.AG.t:SetText( mrp.DisplayBrowser.AG( f.AG ) )
	bfb.fields.HH.t:SetText( mrp.DisplayBrowser.HH( f.HH ) )
	bfb.fields.HB.t:SetText( mrp.DisplayBrowser.HB( f.HB ) )
	bfb.fields.MO.t:SetText( mrp.DisplayBrowser.MO( f.MO ) )

	t = mrp.DisplayBrowser.HI( f.HI )
	if bfb.sf.editbox:GetText() ~= t then
		bfb.sf.editbox:SetText( t )
		bfb.sf.editbox:SetCursorPosition( 0 )
		ScrollFrame_OnScrollRangeChanged(MyRolePlayBrowseFrameBScrollFrame)
	end

	bf:Show()
end

-- A list of the fields which appear in the browse frame.
local bffields_full = { 'VP', 'VA', 'NA', 'NH', 'NI', 'NT', 'GR', 'RA', 'FR', 'FC', 'AG', 'AE', 'AH', 'AW', 'HH', 'HB', 'MO', 'CU', 'DE', 'HI' }
-- Same but without 'biographical' fields, as some users like the surprise
local bffields_nobiog = { 'VP', 'VA', 'NA', 'NH', 'NI', 'NT', 'GR', 'RA', 'FR', 'FC', 'AE', 'AH', 'AW', 'CU', 'DE' }

-- Make the request to another player to get all of the fields in the browse frame.
function mrp:RequestForBF( player )
	player = player or mrp.BFShown or nil
	if not player or player == "" or player == "Unknown" then
		return false
	end
	if mrpSaved.Options.ShowBiographyInBrowser == false then
		msp:Request( player, bffields_nobiog )
	else
		msp:Request( player, bffields_full )
	end
	mrp:UpdateBrowseFrame( player )
end

function mrp:Show( player )
	if not player or player == "" then
		if UnitIsUnit("player", "target") then
			--mrp:RequestForBF( UnitName("player") )
			mrp:UpdateBrowseFrame( player )
		elseif UnitIsPlayer("target") and UnitIsFriend("player", "target") then
			if msp.char[ mrp:UnitNameWithRealm("target") ].supported == false then
				mrp:Print( L["%s doesn’t appear to have an addon which supports MSP."], mrp:UnitNameWithRealm("target") )
			else
				mrp:RequestForBF( mrp:UnitNameWithRealm("target") )
			end
		else
			mrp:Print( L["Who do I show?"] )
		end
	else
		if msp.char[ player ].supported == false then
			mrp:Print( L["%s doesn’t appear to have an addon which supports MSP."], player )
		else
			mrp:RequestForBF( player )
		end
	end
end

function mrp_MSPBrowserCallback( player )
	if player == mrp.BFShown then
		mrp:UpdateBrowseFrame( player )
	end
end