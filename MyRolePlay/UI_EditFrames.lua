--[[
	MyRolePlay 4 (C) 2010-2011 Etarna Moonshyne <etarna@moonshyne.org>
	Licensed under GNU General Public Licence version 2 or, at your option, any later version

	UI_EditFrames.lua - Supporting EditFrames for the MyRolePlayCharacterFrame
]]

local L = mrp.L

local function emptynil( x ) return x ~= "" and x or nil end

local uipbt = mrp.WoWTOC >= 50001 and "UIPanelButtonTemplate" or "UIPanelButtonTemplate2"

-- Create the EditFrames to sit alongside MyRolePlayCharacterFrame
function mrp:CreateEditFrames()
	-- MyRolePlayMultiEditFrame
	if not MyRolePlayMultiEditFrame then
		local mef = CreateFrame( "Frame", "MyRolePlayMultiEditFrame", MyRolePlayCharacterFrame, "InsetFrameTemplate" )
		mef:Hide()
		mef:SetPoint( "TOPLEFT", MyRolePlayCharacterFrame, "TOPLEFT", 332, -61 )
		mef:SetPoint( "BOTTOM", CharacterFrameInset, "BOTTOM", 0, 30 )
		mef:SetPoint( "RIGHT", CharacterFrame, "RIGHT", -8, 0 )
		mef:EnableDrawLayer("ARTWORK")

		mef:SetScript("OnShow", function(self)
			CharacterFrame:SetWidth( 700 )
			CharacterFrame.Expanded = true
			UpdateUIPanelPositions(CharacterFrame)
			MyRolePlayMultiEditFrame.sf.editbox:SetFocus()
		end	)
		mef:SetScript("OnHide", function(self)
			CharacterFrame:SetWidth( PANEL_DEFAULT_WIDTH )
			CharacterFrame.Expanded = false
			UpdateUIPanelPositions(CharacterFrame)
		end	)
		mef.title = mef:CreateFontString( nil, "ARTWORK", "GameFontNormal" )
		mef.title:SetPoint( "TOP", mef, "TOP", 0, 27 )

		mef:EnableDrawLayer("OVERLAY")
		mef.sf = CreateFrame( "ScrollFrame", "MyRolePlayMultiEditFrameScrollFrame", mef, "UIPanelScrollFrameTemplate2" )
		mef.sf:SetPoint( "TOPLEFT", 8, -6 )
		mef.sf:SetPoint( "BOTTOMRIGHT", -28, 6 )
		mef.sf:SetSize( 325, 325 )

		mef.sf.scrollBarHideable = false

		mef.sf.editbox = CreateFrame( "EditBox", nil, mef.sf )
		mef.sf.editbox:SetPoint( "TOPLEFT" )
		mef.sf.editbox:SetPoint( "BOTTOMLEFT" )
		mef.sf.editbox:SetHeight( 325 )
		mef.sf.editbox:SetWidth( 325 )
		mef.sf.editbox:SetSpacing( 1 )
		mef.sf.editbox:SetTextInsets( 5, 5, 3, 3 )
		mef.sf.editbox:EnableMouse(true)
		mef.sf.editbox:SetAutoFocus(false)
		mef.sf.editbox:SetMultiLine(true)
		mef.sf.editbox:SetFontObject( "GameFontHighlight" )
		mef.sf:SetScrollChild( mef.sf.editbox )


		mef.sf.editbox:SetScript( "OnEscapePressed", EditBox_ClearFocus )

		mef.sf.editbox:SetScript( "OnTextChanged", function(self)
			ScrollingEdit_OnTextChanged(self, self:GetParent())
		end	)
		mef.sf.editbox:SetScript( "OnCursorChanged", function(self, x, y, w, h)
			ScrollingEdit_OnCursorChanged(self, x, y-10, w, h)
		end )
		mef.sf.editbox:SetScript( "OnUpdate", function(self, elapsed)
			ScrollingEdit_OnUpdate(self, elapsed, self:GetParent())
		end	)


		ScrollFrame_OnScrollRangeChanged(MyRolePlayMultiEditFrameScrollFrame)

		mef.ok = CreateFrame( "Button", "MyRolePlayMultiEditFrameOK", mef, uipbt )
		mef.ok:SetPoint( "BOTTOMRIGHT", CharacterFrame, "BOTTOMRIGHT", -8, 7 )
		mef.ok:SetText( L["Save"] )
		mef.ok:SetWidth( 90 )
		mef.ok:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["Save the changes you’ve made back to the profile."], 1.0, 1.0, 1.0 )
		end )
		mef.ok:SetScript( "OnLeave", GameTooltip_Hide )
		mef.ok:SetScript("OnClick", function (self)
			local field = MyRolePlayMultiEditFrame.field
			local newtext = MyRolePlayMultiEditFrame.sf.editbox:GetText()
			mrp:SaveField( field, newtext )
			MyRolePlayMultiEditFrame:Hide()
		end )

		mef.cancel = CreateFrame( "Button", "MyRolePlayMultiEditFrameCancel", mef, uipbt )
		mef.cancel:SetPoint( "RIGHT", mef.ok, "LEFT", -16, 0 )
		mef.cancel:SetText( L["Cancel"] )
		mef.cancel:SetWidth( 90 )
		mef.cancel:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["Cancel any changes and return to the way it was."], 1.0, 1.0, 1.0 )
		end )
		mef.cancel:SetScript( "OnLeave", GameTooltip_Hide )
		mef.cancel:SetScript("OnClick", function (self)
			-- we, uh, don't need to do anything
			MyRolePlayMultiEditFrame:Hide()
		end )

		mef.inherit = CreateFrame( "Button", "MyRolePlayMultiEditFrameInherit", mef, uipbt )
		mef.inherit:SetPoint( "LEFT", mef )
		mef.inherit:SetPoint( "TOP", mef.ok )
		mef.inherit:SetText( L["Inherit"] )
		mef.inherit:SetWidth( 90 )
		mef.inherit:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["Cancel any changes, and use the same contents as the Default profile."], 1.0, 1.0, 1.0 )
		end )
		mef.inherit:SetScript( "OnLeave", GameTooltip_Hide )
		mef.inherit:SetScript("OnClick", function (self)
			local field = MyRolePlayMultiEditFrame.field
			mrp:SaveField( field, nil )
			MyRolePlayMultiEditFrame:Hide()
		end )
		mef.inherit:Hide()

		mef.inherited = mef:CreateFontString( nil, "ARTWORK", "GameFontHighlightSmall" )
		mef.inherited:SetJustifyH( "LEFT" )
		mef.inherited:SetPoint( "LEFT", mef, "LEFT", 16, 0 )
		mef.inherited:SetPoint( "BOTTOMLEFT", mef, "BOTTOM", 0, -22 )
		mef.inherited:SetText( L["Inherited from Default."] )
		mef.inherited:Hide()
	end

	-- MyRolePlayEditFrame
	if not MyRolePlayEditFrame then
		local mef = CreateFrame( "Frame", "MyRolePlayEditFrame", MyRolePlayCharacterFrame )
		mef:Hide()
		mef:SetPoint( "TOPLEFT", MyRolePlayCharacterFrame, "TOPLEFT", 332, -61 )
		mef:SetPoint( "BOTTOM", CharacterFrameInset, "BOTTOM", 0, 30 )
		mef:SetPoint( "RIGHT", CharacterFrame, "RIGHT", -8, 0 )
		mef:EnableDrawLayer("ARTWORK")

		mef:SetScript("OnShow", function(self)
			CharacterFrame:SetWidth( 700 )
			CharacterFrame.Expanded = true
			UpdateUIPanelPositions(CharacterFrame)
			MyRolePlayEditFrame.editbox:SetFocus()
		end	)
		mef:SetScript("OnHide", function(self)
			CharacterFrame:SetWidth( PANEL_DEFAULT_WIDTH )
			CharacterFrame.Expanded = false
			UpdateUIPanelPositions(CharacterFrame)
		end	)
		mef.title = mef:CreateFontString( nil, "ARTWORK", "GameFontNormal" )
		mef.title:SetPoint( "TOP", mef, "TOP", 0, 27 )

		mef.desc = mef:CreateFontString( nil, "ARTWORK", "GameFontHighlightSmall" )
		mef.desc:SetWordWrap(true)
		mef.desc:SetJustifyH( "LEFT" )
		mef.desc:SetJustifyV( "TOP" )
		mef.desc:SetPoint( "TOP", mef, "TOP", 0, -10 )


		mef:EnableDrawLayer("OVERLAY")

		mef.editbox = CreateFrame( "EditBox", nil, mef )
		mef.editbox:SetBackdrop(	{
				bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
				edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
				tile = true,
				tileSize = 32,
				edgeSize = 32,
				insets = { left = 11, right = 12, top = 12, bottom = 11	},
		} )
		mef.editbox:SetPoint( "CENTER" )
		mef.editbox:SetPoint( "LEFT", 5 )
		mef.editbox:SetPoint( "RIGHT", 5 )
		mef.editbox:SetHeight( 40 )
		mef.editbox:SetWidth( 325 )
		mef.editbox:SetTextInsets( 12, 12, 3, 3 )
		mef.editbox:EnableMouse(true)
		mef.editbox:SetAutoFocus(false)
		mef.editbox:SetMultiLine(false)
		mef.editbox:SetFontObject( "GameFontHighlight" )

		mef.editbox:SetScript( "OnEscapePressed", EditBox_ClearFocus )

		mef.ok = CreateFrame( "Button", "MyRolePlayEditFrameOK", mef, uipbt )
		mef.ok:SetPoint( "BOTTOMRIGHT", CharacterFrame, "BOTTOMRIGHT", -8, 7 )
		mef.ok:SetText( "Save" )
		mef.ok:SetWidth( 90 )
		mef.ok:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( "Save changes.", 1.0, 1.0, 1.0 )
		end )
		mef.ok:SetScript( "OnLeave", GameTooltip_Hide )
		mef.ok:SetScript("OnClick", function (self)
			local field = MyRolePlayEditFrame.field
			local newtext = MyRolePlayEditFrame.editbox:GetText()
			mrp:SaveField( field, newtext )
			MyRolePlayEditFrame:Hide()
		end )

		mef.cancel = CreateFrame( "Button", "MyRolePlayEditFrameCancel", mef, uipbt )
		mef.cancel:SetPoint( "RIGHT", mef.ok, "LEFT", -16, 0 )
		mef.cancel:SetText( "Cancel" )
		mef.cancel:SetWidth( 90 )
		mef.cancel:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( "Cancel changes and return to the way it was.", 1.0, 1.0, 1.0 )
		end )
		mef.cancel:SetScript( "OnLeave", GameTooltip_Hide )
		mef.cancel:SetScript("OnClick", function (self)
			-- we, uh, don't need to do anything
			MyRolePlayEditFrame:Hide()
		end )

		mef.inherit = CreateFrame( "Button", "MyRolePlayEditFrameInherit", mef, uipbt )
		mef.inherit:SetPoint( "LEFT", mef )
		mef.inherit:SetPoint( "TOP", mef.ok )
		mef.inherit:SetText( "Inherit" )
		mef.inherit:SetWidth( 90 )
		mef.inherit:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( "Use the same contents as the Default profile has.", 1.0, 1.0, 1.0 )
		end )
		mef.inherit:SetScript( "OnLeave", GameTooltip_Hide )
		mef.inherit:SetScript("OnClick", function (self)
			local field = MyRolePlayEditFrame.field
			mrp:SaveField( field, nil )
			MyRolePlayEditFrame:Hide()
		end )
		mef.inherit:Hide()

		mef.inherited = mef:CreateFontString( nil, "ARTWORK", "GameFontHighlightSmall" )
		mef.inherited:SetJustifyH( "LEFT" )
		mef.inherited:SetPoint( "LEFT", mef, "LEFT", 16, 0 )
		mef.inherited:SetPoint( "BOTTOMLEFT", mef, "BOTTOM", 0, -22 )
		mef.inherited:SetText( L["Inherited from Default."] )
		mef.inherited:Hide()
	end

	-- MyRolePlayComboEditFrame
	if not MyRolePlayComboEditFrame then
		local mef = CreateFrame( "Frame", "MyRolePlayComboEditFrame", MyRolePlayCharacterFrame )
		mef:Hide()
		mef:SetPoint( "TOPLEFT", MyRolePlayCharacterFrame, "TOPLEFT", 332, -61 )
		mef:SetPoint( "BOTTOM", CharacterFrameInset, "BOTTOM", 0, 30 )
		mef:SetPoint( "RIGHT", CharacterFrame, "RIGHT", -8, 0 )
		mef:EnableDrawLayer("ARTWORK")

		mef:SetScript("OnShow", function(self)
			CharacterFrame:SetWidth( 700 )
			CharacterFrame.Expanded = true
			UpdateUIPanelPositions(CharacterFrame)
			MyRolePlayComboEditFrame.editbox:SetFocus()
		end	)
		mef:SetScript("OnHide", function(self)
			CharacterFrame:SetWidth( PANEL_DEFAULT_WIDTH )
			CharacterFrame.Expanded = false
			UpdateUIPanelPositions(CharacterFrame)
		end	)
		mef.title = mef:CreateFontString( nil, "ARTWORK", "GameFontNormal" )
		mef.title:SetPoint( "TOP", mef, "TOP", 0, 27 )

		mef.desc = mef:CreateFontString( nil, "ARTWORK", "GameFontHighlightSmall" )
		mef.desc:SetWordWrap(true)
		mef.desc:SetJustifyH( "LEFT" )
		mef.desc:SetJustifyV( "TOP" )
		mef.desc:SetPoint( "TOP", mef, "TOP", 0, -10 )

		mef:EnableDrawLayer("OVERLAY")

		mef.cb = CreateFrame( "Frame", "MyRolePlayComboEditFrameComboBox", mef, "UIDropDownMenuTemplate" )
		mef.cb:SetPoint( "CENTER", 0, 50 )
		UIDropDownMenu_SetWidth( mef.cb, 205 )

		mef.cb.dd = CreateFrame( "Frame", "MyRolePlayComboEditFrameComboBoxDropDown", mef, "UIDropDownListTemplate" )

		MyRolePlayComboEditFrameComboBoxButton:SetScript( "OnClick", function( self )
			if DropDownList1:IsVisible() then
				DropDownList1:Hide()
			else
				EasyMenu( mrp.comboboxfields[ MyRolePlayComboEditFrame.field ], MyRolePlayComboEditFrame.cb.dd, MyRolePlayComboEditFrame.cb, 0, 5 )
				mrp.CFComboBoxUpdate( MyRolePlayComboEditFrame, true )
			end
		end )

		mef.editbox = CreateFrame( "EditBox", nil, mef )
		mef.editbox:SetBackdrop( {
				bgFile = [[Interface\DialogFrame\UI-DialogBox-Background]],
				edgeFile = [[Interface\DialogFrame\UI-DialogBox-Border]],
				tile = true,
				tileSize = 32,
				edgeSize = 32,
				insets = { left = 11, right = 12, top = 12, bottom = 11	},
		} )
		mef.editbox:SetPoint( "BOTTOM", mef, "BOTTOM", 0, 30 )
		mef.editbox:SetHeight( 40 )
		mef.editbox:SetWidth( 205 )
		mef.editbox:SetMaxLetters( 35 )

		mef.editbox:SetTextInsets( 12, 12, 3, 3 )
		mef.editbox:EnableMouse(true)
		mef.editbox:SetAutoFocus(false)
		mef.editbox:SetMultiLine(false)
		mef.editbox:SetFontObject( "GameFontHighlight" )

		mef.editbox:SetScript( "OnEscapePressed", EditBox_ClearFocus )

		mef.ok = CreateFrame( "Button", "MyRolePlayComboEditFrameOK", mef, uipbt )
		mef.ok:SetPoint( "BOTTOMRIGHT", CharacterFrame, "BOTTOMRIGHT", -8, 7 )
		mef.ok:SetText( "Save" )
		mef.ok:SetWidth( 90 )
		mef.ok:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( "Save changes.", 1.0, 1.0, 1.0 )
		end )
		mef.ok:SetScript( "OnLeave", GameTooltip_Hide )
		mef.ok:SetScript("OnClick", function (self)
			if type( MyRolePlayComboEditFrame.value ) == "string" then
				MyRolePlayComboEditFrame.value = strtrim( MyRolePlayComboEditFrame.editbox:GetText() )
				if strtrim( MyRolePlayComboEditFrame.value ) == "" then 
					MyRolePlayComboEditFrame:Hide()
					return
				else
					local e = strlower( MyRolePlayComboEditFrame.value )
					for i = 0, 4 do 
						if e == strlower( L[ MyRolePlayComboEditFrame.field .. tostring( i ) ] ) then
							MyRolePlayComboEditFrame.value = i
							break
						end
					end 
				end
			end
			mrp:SaveField( MyRolePlayComboEditFrame.field, tostring( MyRolePlayComboEditFrame.value ) )
			MyRolePlayComboEditFrame:Hide()
		end )

		mef.cancel = CreateFrame( "Button", "MyRolePlayComboEditFrameCancel", mef, uipbt )
		mef.cancel:SetPoint( "RIGHT", mef.ok, "LEFT", -16, 0 )
		mef.cancel:SetText( "Cancel" )
		mef.cancel:SetWidth( 90 )
		mef.cancel:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( "Cancel changes and return to the way it was.", 1.0, 1.0, 1.0 )
		end )
		mef.cancel:SetScript( "OnLeave", GameTooltip_Hide )
		mef.cancel:SetScript("OnClick", function (self)
			-- we, uh, don't need to do anything
			MyRolePlayComboEditFrame:Hide()
		end )

		mef.inherit = CreateFrame( "Button", "MyRolePlayComboEditFrameInherit", mef, uipbt )
		mef.inherit:SetPoint( "LEFT", mef )
		mef.inherit:SetPoint( "TOP", mef.ok )
		mef.inherit:SetText( "Inherit" )
		mef.inherit:SetWidth( 90 )
		mef.inherit:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( "Use the same contents as the Default profile has.", 1.0, 1.0, 1.0 )
		end )
		mef.inherit:SetScript( "OnLeave", GameTooltip_Hide )
		mef.inherit:SetScript("OnClick", function (self)
			local field = MyRolePlayComboEditFrame.field
			mrp:SaveField( field, nil )
			MyRolePlayComboEditFrame:Hide()
		end )
		mef.inherit:Hide()

		mef.inherited = mef:CreateFontString( nil, "ARTWORK", "GameFontHighlightSmall" )
		mef.inherited:SetJustifyH( "LEFT" )
		mef.inherited:SetPoint( "LEFT", mef, "LEFT", 16, 0 )
		mef.inherited:SetPoint( "BOTTOMLEFT", mef, "BOTTOM", 0, -22 )
		mef.inherited:SetText( L["Inherited from Default."] )
		mef.inherited:Hide()
	end
	-- Garbage-collect functions we only need once
	mrp.CreateEditFrames = mrp_dummyfunction
end

function mrp.CFComboBoxClick( self, iscustom )
	if iscustom then
		if MyRolePlayComboEditFrame.value == 0 then
			MyRolePlayComboEditFrame.value = ""
		else
			MyRolePlayComboEditFrame.value = emptynil( strtrim( MyRolePlayComboEditFrame.editbox:GetText() ) ) or mrp.Display[ MyRolePlayComboEditFrame.field ]( MyRolePlayComboEditFrame.value )
		end
	else
		MyRolePlayComboEditFrame.value = self.value
	end
	mrp.CFComboBoxUpdate( MyRolePlayComboEditFrame, true )
end

function mrp.CFComboBoxUpdate( mef, doset )
	if type( mef.value ) == "number" then
		if doset then UIDropDownMenu_SetSelectedID( MyRolePlayComboEditFrame.cb, MyRolePlayComboEditFrame.value + 1 ) end
		if mef.value == 0 then 
			mef.editbox:SetText( "" )
			mef.editbox:SetCursorPosition( 0 )
		else
			mef.editbox:SetText( mrp.comboboxfields[ mef.field ][ mef.value + 1 ].text )
			mef.editbox:SetCursorPosition( #mrp.comboboxfields[ mef.field ][ mef.value + 1 ].text )
		end
		mef.editbox:Hide()
	else
		if doset then UIDropDownMenu_SetSelectedID( MyRolePlayComboEditFrame.cb, 6 ) end
		mef.editbox:SetCursorPosition( 0 )
		mef.editbox:SetText( mef.value )
		mef.editbox:SetCursorPosition( #mef.value )
		mef.editbox:Show()
		mef.editbox:SetFocus()
	end
end

mrp.comboboxfields = {
	['FR'] = {
		{ text = L["FR0"], colorCode = "|cff808080", tooltipTitle = L["FR0t"], tooltipText = L["FR0d"], tooltipOnButton = 1, value = 0, func = mrp.CFComboBoxClick },
		{ text = L["FR1"], colorCode = "|cff66b380", tooltipTitle = L["FR1t"], tooltipText = L["FR1d"], tooltipOnButton = 1, value = 1, func = mrp.CFComboBoxClick },
		{ text = L["FR2"], colorCode = "|cff99b3cc", tooltipTitle = L["FR2t"], tooltipText = L["FR2d"], tooltipOnButton = 1, value = 2, func = mrp.CFComboBoxClick },
		{ text = L["FR3"], colorCode = "|cffe6ccb3", tooltipTitle = L["FR3t"], tooltipText = L["FR3d"], tooltipOnButton = 1, value = 3, func = mrp.CFComboBoxClick },
		{ text = L["FR4"], colorCode = "|cff99664d", tooltipTitle = L["FR4t"], tooltipText = L["FR4d"], tooltipOnButton = 1, value = 4, func = mrp.CFComboBoxClick },
		{ text = L["FRc"], tooltipTitle = L["FRct"], tooltipText = L["FRcd"], tooltipOnButton = 1, arg1 = true, func = mrp.CFComboBoxClick },
	},
	['FC'] = {
		{ text = L["FC0"], colorCode = "|cff808080", tooltipTitle = L["FC0t"], tooltipText = L["FC0d"], tooltipOnButton = 1, value = 0, func = mrp.CFComboBoxClick },
		{ text = L["FC1"], colorCode = "|cff99664d", tooltipTitle = L["FC1t"], tooltipText = L["FC1d"], tooltipOnButton = 1, value = 1, func = mrp.CFComboBoxClick },
		{ text = L["FC2"], colorCode = "|cff66b380", tooltipTitle = L["FC2t"], tooltipText = L["FC2d"], tooltipOnButton = 1, value = 2, func = mrp.CFComboBoxClick },
		{ text = L["FC3"], colorCode = "|cff99b3cc", tooltipTitle = L["FC3t"], tooltipText = L["FC3d"], tooltipOnButton = 1, value = 3, func = mrp.CFComboBoxClick },
		{ text = L["FC4"], colorCode = "|cffe6ccb3", tooltipTitle = L["FC4t"], tooltipText = L["FC4d"], tooltipOnButton = 1, value = 4, func = mrp.CFComboBoxClick },
		{ text = L["FCc"], tooltipTitle = L["FCct"], tooltipText = L["FCcd"], tooltipOnButton = 1, arg1 = true, func = mrp.CFComboBoxClick },
	},
}

-- When you click on a field: display and set up the appropriate edit frame
function mrp.CFEditField( field, fieldname, fielddesc )
	if field == 'DE' or field == 'HI' then
		-- Multiple lines, we want MyRolePlayMultiEditFrame
		MyRolePlayComboEditFrame:Hide()
		MyRolePlayEditFrame:Hide()
		local mef = MyRolePlayMultiEditFrame
		mef.field = field
		mef.fieldname = fieldname
		mef.fielddesc = fielddesc
		mef.title:SetText( fieldname )

		mef.sf.editbox:SetCursorPosition(0)
		ScrollFrame_OnScrollRangeChanged(MyRolePlayMultiEditFrameScrollFrame)

		local text = msp.my[field] or ""

		mef.sf.editbox:EnableKeyboard(true)

		if msp.my[field] == mrpSaved.Profiles.Default[field] and mrpSaved.SelectedProfile ~= "Default" then
			mef.sf.editbox:SetTextColor( 1.0, 1.0, 1.0, 0.4 )
			mef.inherit:Hide()
			mef.inherited:Show()
		else
			mef.sf.editbox:SetTextColor( 1.0, 1.0, 1.0, 1.0 )
			mef.inherited:Hide()
			if mrpSaved.SelectedProfile == "Default" then
				mef.inherit:Hide()
			else
				mef.inherit:Show()
			end
		end

		mef.sf.editbox:SetText( text )
		mef.sf.editbox:SetCursorPosition( #text )
		ScrollFrame_OnScrollRangeChanged(MyRolePlayMultiEditFrameScrollFrame)

		mef:Hide()
		mef:Show()
	elseif field == 'FR' or field == 'FC' then
		-- Combo box + custom text, we want MyRolePlayComboEditFrame
		MyRolePlayMultiEditFrame:Hide()
		MyRolePlayEditFrame:Hide()
		local mef = MyRolePlayComboEditFrame
		mef.field = field
		mef.fieldname = fieldname
		mef.fielddesc = fielddesc
		mef.title:SetText( fieldname )
		mef.desc:SetText( fielddesc )

		mef.editbox:SetCursorPosition(0)

		local text = emptynil( msp.my[field] ) or "0"

		if text == "0" or text == "1" or text == "2" or text == "3" or text == "4" then
			mef.value = tonumber( text )
			MyRolePlayComboEditFrameComboBoxText:SetText( (mrp.comboboxfields[field][ tonumber( text ) + 1 ].colorCode or "") .. mrp.comboboxfields[field][ tonumber( text ) + 1 ].text )
			if text == "0" then
				mef.editbox:SetText( "" )
				mef.editbox:SetCursorPosition( 0 )
			else
				mef.editbox:SetText( mrp.comboboxfields[field][ tonumber( text ) + 1 ].text )
				mef.editbox:SetCursorPosition( #mrp.comboboxfields[field][ tonumber( text ) + 1 ].text )
			end
		else
			mef.value = text
			MyRolePlayComboEditFrameComboBoxText:SetText( mrp.comboboxfields[field][ 6 ].text )
			mef.editbox:SetText( text ) 
			mef.editbox:SetCursorPosition( #text )
		end

		mef.editbox:EnableKeyboard(true)

		if msp.my[field] == mrpSaved.Profiles.Default[field] and mrpSaved.SelectedProfile ~= "Default" then
			mef.editbox:SetTextColor( 1.0, 1.0, 1.0, 0.4 )
			mef.inherit:Hide()
			mef.inherited:Show()
		else
			mef.editbox:SetTextColor( 1.0, 1.0, 1.0, 1.0 )
			mef.inherited:Hide()
			if mrpSaved.SelectedProfile == "Default" then
				mef.inherit:Hide()
			else
				mef.inherit:Show()
			end
		end

		mrp.CFComboBoxUpdate( mef, false )

		mef:Hide()
		mef:Show()
	else
		-- Single line, we want MyRolePlayEditFrame
		MyRolePlayMultiEditFrame:Hide()
		MyRolePlayComboEditFrame:Hide()

		local mef = MyRolePlayEditFrame
		mef.field = field
		mef.fieldname = fieldname
		mef.fielddesc = fielddesc
		mef.title:SetText( fieldname )
		mef.desc:SetText( fielddesc )

		mef.editbox:SetCursorPosition(0)

		local text = msp.my[field] or ""

		mef.editbox:EnableKeyboard(true)

		if msp.my[field] == mrpSaved.Profiles.Default[field] and mrpSaved.SelectedProfile ~= "Default" then
			mef.editbox:SetTextColor( 1.0, 1.0, 1.0, 0.4 )
			mef.inherit:Hide()
			mef.inherited:Show()
		else
			mef.editbox:SetTextColor( 1.0, 1.0, 1.0, 1.0 )
			mef.inherited:Hide()
			if mrpSaved.SelectedProfile == "Default" then
				mef.inherit:Hide()
			else
				mef.inherit:Show()
			end
		end

		mef.editbox:SetText( text )
		mef.editbox:SetCursorPosition( #text )

		mef:Hide()
		mef:Show()
	end
end