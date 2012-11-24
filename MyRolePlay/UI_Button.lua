--[[
	MyRolePlay 4 (C) 2010-2011 Etarna Moonshyne <etarna@moonshyne.org>
	Licensed under GNU General Public Licence version 2 or, at your option, any later version

	UI_Button.lua - The MRP button (shown/hidden by UI_Target.lua)
]]

local L = mrp.L

function mrp:CreateMRPButton()
	if not MyRolePlayButton then 
		local f
		f = CreateFrame( "Button", "MyRolePlayButton", UIParent )
		f:Hide()
		f:EnableMouse( true )
		f:SetMovable( true )
		f:SetSize( 28, 28 )
		f:SetClampedToScreen( true )
		if mrpSaved.Positions.Button then
			f:ClearAllPoints()
			f:SetPoint( mrpSaved.Positions.Button[1], nil, mrpSaved.Positions.Button[1], mrpSaved.Positions.Button[2], mrpSaved.Positions.Button[3] )
		else
			mrp:ResetMRPButtonPosition()
		end
		f:SetFrameStrata( "MEDIUM" )
		f:SetNormalTexture( "Interface\\AddOns\\MyRolePlay\\Artwork\\MRPInfoBoxButton_Up.blp" )
		f:SetPushedTexture( "Interface\\AddOns\\MyRolePlay\\Artwork\\MRPInfoBoxButton_Down.blp" )
		f:SetHighlightTexture( "Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight", "ADD" )
		f:RegisterForDrag( "LeftButton" )
		f:RegisterForClicks( "LeftButtonUp", "RightButtonUp" )

		f:SetScript("OnShow", function(self) -- first time only
			if not mrp.ButtonAnchored then
				if mrpSaved.Positions.Button then
					MyRolePlayButton:ClearAllPoints()
					MyRolePlayButton:SetPoint( mrpSaved.Positions.Button[1], nil, mrpSaved.Positions.Button[1], mrpSaved.Positions.Button[2], mrpSaved.Positions.Button[3] )
				else
					mrp:ResetMRPButtonPosition()
				end
				mrp.ButtonAnchored = true
			end
		end	)
		f:SetScript("OnDragStart", function(self)
			if mrp.ButtonMovable then
				self:StartMoving()
			end
		end	)
		f:SetScript("OnDragStop", function(self)
			self:StopMovingOrSizing()
			if not select( 2, MyRolePlayButton:GetPoint() ) then
				mrpSaved.Positions.Button = { select( 3, MyRolePlayButton:GetPoint() ) }
			end
		end	)
		f:SetScript("OnClick", function(self, button)
			if button == "LeftButton" then
				mrp:Show( mrp:UnitNameWithRealm("target") )
			elseif button == "RightButton" then
				mrp.ButtonMovable = not mrp.ButtonMovable
				if mrp.ButtonMovable then
					mrp:Print( L["MRP Button unlocked, and can now be moved around as you wish. Right-click again to lock it in position."] )
					self:LockHighlight()
				else
					mrp:Print( L["MRP Button locked in position."] )
					self:UnlockHighlight()
				end
				MyRolePlayButton:GetScript("OnEnter")(self) -- i.e. update the tooltip
			end
		end	)
		f:SetScript( "OnEnter", function(self) 
			mrp:UpdateTooltip( )
			GameTooltip:AddLine( " " )
			GameTooltip:AddLine( L["|cffaabbccLeft-click|r to show roleplaying profile."], 1.0, 1.0, 1.0 )
			if mrp.ButtonMovable then
				GameTooltip:AddLine( L["|cffaabbccRight-click|r to lock this button in place."], 1.0, 1.0, 1.0 )
			else
				GameTooltip:AddLine( L["|cffaabbccRight-click|r to unlock this button to move it."], 1.0, 1.0, 1.0 )
			end
			GameTooltip:Show()
		end )
		f:SetScript( "OnLeave", GameTooltip_Hide )
	end
end

function mrp:ResetMRPButtonPosition()
	--[[
		Edit me to add support for floating the button alongside replacement unit frames.

		Out of all tested unit frames, only Perl Classic and XPerl completely nuke the TargetFrame.
		All other tested unit frames put the button somewhere about right, and of course it can be moved.
	]]
	mrpSaved.Positions.Button = nil
	MyRolePlayButton:ClearAllPoints()
	if XPerl_Target then
		MyRolePlayButton:SetPoint( "TOPLEFT", XPerl_Target, "BOTTOMRIGHT", -8, 0 )
	elseif Perl_Target_StatsFrame then
		MyRolePlayButton:SetPoint( "TOPLEFT", Perl_Target_StatsFrame, "BOTTOMRIGHT", -8, 0 )
	elseif SUFUnittarget then
		MyRolePlayButton:SetPoint( "TOPLEFT", SUFUnittarget, "BOTTOMRIGHT", -8, 0 )
	else
		MyRolePlayButton:SetPoint( "TOPLEFT", TargetFrame, "BOTTOMRIGHT", -55, 24 )
	end
end