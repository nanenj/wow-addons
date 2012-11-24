--[[
	MyRolePlay 4 (C) 2010-2011 Etarna Moonshyne <etarna@moonshyne.org>
	Licensed under GNU General Public Licence version 2 or, at your option, any later version

	UI_Options.lua - The options panel
]]

local L = mrp.L

-- BUG: Cancel doesn't. Not terribly worried about this.

-- I love it when Blizzard do most of the hard work for me.
function mrp:CreateOptionsPanel()
	if not MyRolePlayOptionsPanel then 
		local c = InterfaceOptionsFramePanelContainer
		local f = CreateFrame( "Frame", "MyRolePlayOptionsPanel", c )
		mrpopts = f
		f:Hide()
		f:SetPoint( "TOPLEFT" , c, "TOPLEFT" )
		f:SetPoint( "BOTTOMRIGHT", c, "BOTTOMRIGHT" )

		f.name = "MyRolePlay"
		f.options = {
			enable = { text = L["opt_enable"], tooltip = L["opt_enable_tt"] },
			mrpbutton = { text = L["opt_mrpbutton"], tooltip = L["opt_mrpbutton_tt"] },
			ttstyle = { },
			rpchatname = { text = L["opt_rpchatname"], tooltip = L["opt_rpchatname_tt"] },
			ahunit = { },
			awunit = { },
			formac = { text = L["opt_formac"] },
			equipac = { text = L["opt_equipac"], tooltip = L["opt_equipac_tt"] },
			biog = { text = L["opt_biog"], tooltip = L["opt_biog_tt"] },
		}

		-- form auto change: Use the right tooltip for the job.
		if select( 2, UnitRace("player") ) == "Worgen" then
			if select( 2, UnitClass("player") ) == "DRUID" then
				f.options.formac.tooltip = L["opt_formac_tt_worgendruid"]
			elseif select( 2, UnitClass("player") ) == "PRIEST" then
				f.options.formac.tooltip = L["opt_formac_tt_worgenpriest"]
			elseif select( 2, UnitClass("player") ) == "WARLOCK" then
				f.options.formac.tooltip = L["opt_formac_tt_worgenwarlock"]
			else
				f.options.formac.tooltip = L["opt_formac_tt_worgen"]
			end
		else
			if select( 2, UnitClass("player") ) == "DRUID" then
				f.options.formac.tooltip = L["opt_formac_tt_druid"]
			elseif select( 2, UnitClass("player") ) == "SHAMAN" then
				f.options.formac.tooltip = L["opt_formac_tt_shaman"]
			elseif select( 2, UnitClass("player") ) == "PRIEST" then
				f.options.formac.tooltip = L["opt_formac_tt_priest"]
			elseif select( 2, UnitClass("player") ) == "WARLOCK" then
				f.options.formac.tooltip = L["opt_formac_tt_warlock"]
			else
				f.options.formac.tooltip = L["opt_formac_tt_disabled"]
			end
		end
		-- Save memory; we don't need them anymore
		L["opt_formac_tt"] = nil
		L["opt_formac_tt_druid"] = nil
		L["opt_formac_tt_shaman"] = nil
		L["opt_formac_tt_priest"] = nil
		L["opt_formac_tt_warlock"] = nil
		L["opt_formac_tt_suffix"] = nil
		L["opt_formac_tt_worgen"] = nil
		L["opt_formac_tt_worgendruid"] = nil
		L["opt_formac_tt_worgenshaman"] = nil
		L["opt_formac_tt_worgenpriest"] = nil
		L["opt_formac_tt_worgenwarlock"] = nil
		L["opt_formac_tt_worgensuffix"] = nil
		L["opt_formac_tt_disabled"] = nil
		L["opt_formac_tt_enabled1"] = nil

		f.title = f:CreateFontString( nil, "OVERLAY", "GameFontNormalLarge" )
		f.title:SetPoint( "TOPLEFT", 16, -16 )
		f.title:SetJustifyH( "LEFT" )
		f.title:SetJustifyV( "TOP" )
		f.title:SetText( "MyRolePlay" )

		f.ver = f:CreateFontString( nil, "OVERLAY", "GameFontNormalSmall" )
		f.ver:SetPoint( "TOP", f.title )
		f.ver:SetPoint( "RIGHT", f, -32, 0 )
		f.ver:SetJustifyH( "RIGHT" )
		f.ver:SetText( mrp.VerInfo )

		f.st = f:CreateFontString( nil, "OVERLAY", "GameFontHighlightSmall" )
		f.st:SetJustifyH( "LEFT" )
		f.st:SetJustifyV( "TOP" )
		f.st:SetPoint( "TOPLEFT", f.title, "BOTTOMLEFT", 0, -8 )
		f.st:SetPoint( "RIGHT", f, -32, 0 )
		f.st:SetWordWrap( true )
		f.st:SetHeight( 32 )
		f.st:SetText( L["mrp_addon_notes"] )


		f.enable = CreateFrame( "CheckButton", "MyRolePlayOptionsPanel_Enable", f, "InterfaceOptionsCheckButtonTemplate" )
		f.enable:SetPoint( "TOPLEFT", f.st, "BOTTOMLEFT", -2, -8 )
		f.enable.avoiddisabling = true
		f.enable.label = "enable"
		f.enable.type = CONTROLTYPE_CHECKBOX
		f.enable.defaultValue = mrp.DefaultOptions.Enabled and "1" or "0"
		f.enable.GetValue = function()
			return mrpSaved.Options.Enabled and "1" or "0"
		end
		f.enable.setFunc = function( setting )
			if setting == "1" then
				mrp:Enable()
				for k, v in ipairs(MyRolePlayOptionsPanel.controls) do
					v:Enable()
				end
				if mtt then f.ttstyle:Disable() end -- If MyToolTip is loaded, let the beast handle it
			else
				mrp:Disable()
				for k, v in ipairs(MyRolePlayOptionsPanel.controls) do
					if not v.avoiddisabling then
						v:Disable()
					end
				end
			end
		end
		BlizzardOptionsPanel_RegisterControl( f.enable, f )

		f.mrpbutton = CreateFrame( "CheckButton", "MyRolePlayOptionsPanel_MRPButton", f, "InterfaceOptionsCheckButtonTemplate" )
		f.mrpbutton:SetPoint( "TOPLEFT", f.enable, "TOPRIGHT", 140, 0 )
		f.mrpbutton.label = "mrpbutton"
		f.mrpbutton.type = CONTROLTYPE_CHECKBOX
		f.mrpbutton.defaultValue = mrp.DefaultOptions.ShowButton and "1" or "0"
		f.mrpbutton.GetValue = function()
			return mrpSaved.Options.ShowButton and "1" or "0"
		end
		f.mrpbutton.setFunc = function( setting )
			if setting == "1" then
				mrpSaved.Options.ShowButton = true
				mrp:TargetChanged() -- will display button if appropriate
			else
				mrpSaved.Options.ShowButton = false
				MyRolePlayButton:Hide()
			end
		end
		BlizzardOptionsPanel_RegisterControl( f.mrpbutton, f )

		f.ttstyle = CreateFrame( "Frame", "MyRolePlayOptionsPanel_TTStyle", f, "UIDropDownMenuTemplate" )
		f.ttstyle:SetPoint( "TOPLEFT", f.enable, "BOTTOMLEFT", -16, -24 )
		f.ttstyle.type = CONTROLTYPE_DROPDOWN
		f.ttstyle.isoption = "TooltipStyle"
		UIDropDownMenu_SetWidth( f.ttstyle, 210 )
		f.ttstyle:EnableMouse( true )
		f.ttstyle.label = "ttstyle"

		f.ttstyle.capt = f.ttstyle:CreateFontString( "MyRolePlayOptionsPanel_TTStyleLabel", "OVERLAY", "GameFontHighlight" )
		f.ttstyle.capt:SetJustifyH( "LEFT" )
		f.ttstyle.capt:SetJustifyV( "TOP" )
		f.ttstyle.capt:SetPoint( "BOTTOMLEFT", f.ttstyle, "TOPLEFT", 16, 3 )
		f.ttstyle.capt:SetText( L["Tooltip style:"] )

		f.ttstyle.dd = CreateFrame( "Frame", "MyRolePlayOptionsPanel_TTStyleDropDown", f, "UIDropDownListTemplate" )
		MyRolePlayOptionsPanel_TTStyleButton:SetScript( "OnClick", function( self )
			if DropDownList1:IsVisible() then
				DropDownList1:Hide()
			else
				EasyMenu( mrp.optionscomboboxfields[ "ttstyle" ], MyRolePlayOptionsPanel_TTStyleDropDown, MyRolePlayOptionsPanel_TTStyle, 0, 5 )
				UIDropDownMenu_SetSelectedValue( MyRolePlayOptionsPanel_TTStyle, mrpSaved.Options.TooltipStyle )
			end
		end )
		f.ttstyle.Disable = UIDropDownMenu_DisableDropDown
		f.ttstyle.Enable = UIDropDownMenu_EnableDropDown
		f.ttstyle.RefreshValue = function( self )
			UIDropDownMenu_SetSelectedValue( self, mrpSaved.Options.TooltipStyle )
			MyRolePlayOptionsPanel_TTStyleText:SetText( mrp.optionscomboboxfields[ "ttstyle" ][ mrpSaved.Options.TooltipStyle + 1 ].text )
		end
		MyRolePlayOptionsPanel_TTStyleText:SetText( mrp.optionscomboboxfields[ "ttstyle" ][ mrpSaved.Options.TooltipStyle + 1 ].text )
		BlizzardOptionsPanel_RegisterControl( f.ttstyle, f )
		if mtt then f.ttstyle:Disable() end -- If MyToolTip is loaded, let the beast handle it

		f.rpchatname = CreateFrame( "CheckButton", "MyRolePlayOptionsPanel_RPChatName", f, "InterfaceOptionsCheckButtonTemplate" )
		f.rpchatname:SetPoint( "TOPLEFT", f.ttstyle, "BOTTOMLEFT", 16, -8 )
		f.rpchatname.label = "rpchatname"
		f.rpchatname.type = CONTROLTYPE_CHECKBOX
		f.rpchatname.defaultValue = mrp.DefaultOptions.ShowRPNamesInChat and "1" or "0"
		f.rpchatname.GetValue = function()
			return mrpSaved.Options.ShowRPNamesInChat and "1" or "0"
		end
		f.rpchatname.setFunc = function( setting )
			mrpSaved.Options.ShowRPNamesInChat = ( setting == "1" ) and true or false
		end
		BlizzardOptionsPanel_RegisterControl( f.rpchatname, f )


		f.dh = f:CreateFontString( nil, "OVERLAY", "GameFontNormal" )
		f.dh:SetJustifyH( "LEFT" )
		f.dh:SetJustifyV( "TOP" )
		f.dh:SetPoint( "TOPLEFT", f.rpchatname, "BOTTOMLEFT", 0, -24 )
		f.dh:SetText( L["opt_disp_header"] )

		f.biog = CreateFrame( "CheckButton", "MyRolePlayOptionsPanel_Biog", f, "InterfaceOptionsCheckButtonTemplate" )
		f.biog:SetPoint( "TOPLEFT", f.dh, "BOTTOMLEFT", 0, -8 )
		f.biog.label = "biog"
		f.biog.type = CONTROLTYPE_CHECKBOX
		f.biog.defaultValue = mrp.DefaultOptions.ShowBiographyInBrowser and "1" or "0"
		f.biog.GetValue = function()
			return mrpSaved.Options.ShowBiographyInBrowser and "1" or "0"
		end
		f.biog.setFunc = function( setting )
			if setting == "1" then
				mrpSaved.Options.ShowBiographyInBrowser = true
				MyRolePlayBrowseFrameTab2:Show()
				if mrp.BFShown then
					mrp:RequestForBF()
				end
			else
				mrpSaved.Options.ShowBiographyInBrowser = false
				if mrp.BFShown and MyRolePlayBrowseFrame.Biography:IsVisible() then
					mrp:TabSwitchBF( "Appearance" )
				end
				MyRolePlayBrowseFrameTab2:Hide()
			end
		end
		BlizzardOptionsPanel_RegisterControl( f.biog, f )

		f.ahunit = CreateFrame( "Frame", "MyRolePlayOptionsPanel_HeightUnit", f, "UIDropDownMenuTemplate" )
		f.ahunit:SetPoint( "TOPLEFT", f.biog, "BOTTOMLEFT", -16, -24 )
		f.ahunit.type = CONTROLTYPE_DROPDOWN
		f.ahunit.isoption = "HeightUnit"
		UIDropDownMenu_SetWidth( f.ahunit, 160 )
		f.ahunit:EnableMouse( true )
		f.ahunit.label = "ahunit"

		f.ahunit.capt = f.ahunit:CreateFontString( "MyRolePlayOptionsPanel_HeightUnitLabel", "OVERLAY", "GameFontHighlight" )
		f.ahunit.capt:SetJustifyH( "LEFT" )
		f.ahunit.capt:SetJustifyV( "TOP" )
		f.ahunit.capt:SetPoint( "BOTTOMLEFT", f.ahunit, "TOPLEFT", 16, 3 )
		f.ahunit.capt:SetText( L["Display height in…"] )

		f.ahunit.dd = CreateFrame( "Frame", "MyRolePlayOptionsPanel_HeightUnitDropDown", f, "UIDropDownListTemplate" )
		MyRolePlayOptionsPanel_HeightUnitButton:SetScript( "OnClick", function( self )
			if DropDownList1:IsVisible() then
				DropDownList1:Hide()
			else
				EasyMenu( mrp.optionscomboboxfields[ "ahunit" ], MyRolePlayOptionsPanel_HeightUnitDropDown, MyRolePlayOptionsPanel_HeightUnit, 0, 5 )
				UIDropDownMenu_SetSelectedValue( MyRolePlayOptionsPanel_HeightUnit, mrpSaved.Options.HeightUnit )
			end
		end )
		f.ahunit.Disable = UIDropDownMenu_DisableDropDown
		f.ahunit.Enable = UIDropDownMenu_EnableDropDown
		f.ahunit.RefreshValue = function( self )
			UIDropDownMenu_SetSelectedValue( self, mrpSaved.Options.HeightUnit )
			MyRolePlayOptionsPanel_HeightUnitText:SetText( mrp.optionscomboboxfields[ "ahunit" ][ mrpSaved.Options.HeightUnit + 1 ].text )
		end
		MyRolePlayOptionsPanel_HeightUnitText:SetText( mrp.optionscomboboxfields[ "ahunit" ][ mrpSaved.Options.HeightUnit + 1 ].text )
		BlizzardOptionsPanel_RegisterControl( f.ahunit, f )

		f.awunit = CreateFrame( "Frame", "MyRolePlayOptionsPanel_WeightUnit", f, "UIDropDownMenuTemplate" )
		f.awunit:SetPoint( "TOPLEFT", f.ahunit, "TOPRIGHT", -8, 0 )
		f.awunit.type = CONTROLTYPE_DROPDOWN
		f.awunit.isoption = "WeightUnit"
		UIDropDownMenu_SetWidth( f.awunit, 160 )
		f.awunit:EnableMouse( true )
		f.awunit.label = "awunit"

		f.awunit.capt = f.awunit:CreateFontString( "MyRolePlayOptionsPanel_WeightUnitLabel", "OVERLAY", "GameFontHighlight" )
		f.awunit.capt:SetJustifyH( "LEFT" )
		f.awunit.capt:SetJustifyV( "TOP" )
		f.awunit.capt:SetPoint( "BOTTOMLEFT", f.awunit, "TOPLEFT", 16, 3 )
		f.awunit.capt:SetText( L["Display weight in…"] )

		f.awunit.dd = CreateFrame( "Frame", "MyRolePlayOptionsPanel_WeightUnitDropDown", f, "UIDropDownListTemplate" )
		MyRolePlayOptionsPanel_WeightUnitButton:SetScript( "OnClick", function( self )
			if DropDownList1:IsVisible() then
				DropDownList1:Hide()
			else
				EasyMenu( mrp.optionscomboboxfields[ "awunit" ], MyRolePlayOptionsPanel_WeightUnitDropDown, MyRolePlayOptionsPanel_WeightUnit, 0, 5 )
				UIDropDownMenu_SetSelectedValue( MyRolePlayOptionsPanel_WeightUnit, mrpSaved.Options.WeightUnit )
			end
		end )
		f.awunit.Disable = UIDropDownMenu_DisableDropDown
		f.awunit.Enable = UIDropDownMenu_EnableDropDown
		f.awunit.RefreshValue = function( self )
			UIDropDownMenu_SetSelectedValue( self, mrpSaved.Options.WeightUnit )
			MyRolePlayOptionsPanel_WeightUnitText:SetText( mrp.optionscomboboxfields[ "awunit" ][ mrpSaved.Options.WeightUnit + 1 ].text )
		end
		MyRolePlayOptionsPanel_WeightUnitText:SetText( mrp.optionscomboboxfields[ "awunit" ][ mrpSaved.Options.WeightUnit + 1 ].text )
		BlizzardOptionsPanel_RegisterControl( f.awunit, f )


		f.fch = f:CreateFontString( nil, "OVERLAY", "GameFontNormal" )
		f.fch:SetJustifyH( "LEFT" )
		f.fch:SetJustifyV( "TOP" )
		f.fch:SetPoint( "TOPLEFT", f.ahunit, "BOTTOMLEFT", 16, -24 )
		f.fch:SetText( L["opt_ac_header"] )

		f.formac = CreateFrame( "CheckButton", "MyRolePlayOptionsPanel_FormAC", f, "InterfaceOptionsCheckButtonTemplate" )
		f.formac:SetPoint( "TOPLEFT", f.fch, "BOTTOMLEFT", 0, -8 )
		f.formac.label = "formac"
		f.formac.type = CONTROLTYPE_CHECKBOX
		f.formac.defaultValue = mrp.DefaultOptions.FormAutoChange and "1" or "0"
		f.formac.GetValue = function()
			return mrpSaved.Options.FormAutoChange and "1" or "0"
		end
		f.formac.setFunc = function( setting )
			mrpSaved.Options.FormAutoChange = ( setting == "1" ) and true or false
		end
		BlizzardOptionsPanel_RegisterControl( f.formac, f )

		f.equipac = CreateFrame( "CheckButton", "MyRolePlayOptionsPanel_EquipAC", f, "InterfaceOptionsCheckButtonTemplate" )
		f.equipac:SetPoint( "TOPLEFT", f.formac, "TOPRIGHT", 140, 0 )
		f.equipac.label = "equipac"
		f.equipac.type = CONTROLTYPE_CHECKBOX
		f.equipac.defaultValue = mrp.DefaultOptions.EquipSetAutoChange and "1" or "0"
		f.equipac.GetValue = function()
			return mrpSaved.Options.EquipSetAutoChange and "1" or "0"
		end
		f.equipac.setFunc = function( setting )
			mrpSaved.Options.EquipSetAutoChange = ( setting == "1" ) and true or false
		end
		BlizzardOptionsPanel_RegisterControl( f.equipac, f )

		-- frame, okay, cancel, default, refresh
		BlizzardOptionsPanel_OnLoad( f, nil, nil, mrp.OptionsPanelDefaultFunction, nil )
		InterfaceOptions_AddCategory( f, true )

		if not mrpSaved.Options.Enabled then
			for k, v in ipairs( MyRolePlayOptionsPanel.controls ) do
				if not v.avoiddisabling then
					v:Disable()
				end
			end
		end

		mrp.CreateOptionsPanel = mrp_dummyfunction
	end
end

function mrp.OptionsPanelDefaultFunction()
	for k, v in ipairs( MyRolePlayOptionsPanel.controls ) do
		if type( v.setFunc ) == "function" then
			v.setFunc( v.defaultValue )
		elseif type( v.RefreshValue ) == "function" then
			mrpSaved.Options[ v.isoption ] = mrp.DefaultOptions[ v.isoption ]
			v:RefreshValue()
		end
	end
end

function mrp.AHUnitCBClick( self )
	mrp:DebugSpam("ahunitcbclick: %s", self.value or "<nil>")
	mrpSaved.Options.HeightUnit = self.value
	UIDropDownMenu_SetSelectedValue( MyRolePlayOptionsPanel_HeightUnit, self.value )
	if mrp.BFShown then
		mrp:UpdateBrowseFrame()
	end
end

function mrp.AWUnitCBClick( self )
	mrp:DebugSpam("awunitcbclick: %s", self.value or "<nil>")
	mrpSaved.Options.WeightUnit = self.value
	UIDropDownMenu_SetSelectedValue( MyRolePlayOptionsPanel_WeightUnit, self.value )
	if mrp.BFShown then
		mrp:UpdateBrowseFrame()
	end
end

function mrp.TTStyleCBClick( self )
	mrp:DebugSpam("ttstylecbclick: %s", self.value or "<nil>")
	mrpSaved.Options.TooltipStyle = self.value
	UIDropDownMenu_SetSelectedValue( MyRolePlayOptionsPanel_TTStyle, self.value )
	if mrp.TTShown then
		mrp:UpdateTooltip( mrp.TTShown )
	end
end

mrp.optionscomboboxfields = {
	["ahunit"] = {
		{ text = L["cm_format_name"], value = 0, func = mrp.AHUnitCBClick },
		{ text = L["m_format_name"], value = 1, func = mrp.AHUnitCBClick },
		{ text = L["ftin_format_name"], value = 2, func = mrp.AHUnitCBClick },
	},
	["awunit"] = {
		{ text = L["kg_format_name"], value = 0, func = mrp.AWUnitCBClick },
		{ text = L["lb_format_name"], value = 1, func = mrp.AWUnitCBClick },
		{ text = L["stlb_format_name"], value = 2, func = mrp.AWUnitCBClick },
	},
	["ttstyle"] = {
		{ text = L["ttstyle_0_name"], value = 0, func = mrp.TTStyleCBClick },
		{ text = L["ttstyle_1_name"], value = 1, func = mrp.TTStyleCBClick },
		{ text = L["ttstyle_2_name"], value = 2, func = mrp.TTStyleCBClick },
		{ text = L["ttstyle_3_name"], value = 3, func = mrp.TTStyleCBClick },
		{ text = L["ttstyle_4_name"], value = 4, func = mrp.TTStyleCBClick },
		{ text = L["ttstyle_5_name"], value = 5, func = mrp.TTStyleCBClick },
		{ text = L["ttstyle_6_name"], value = 6, func = mrp.TTStyleCBClick },
	},	
}