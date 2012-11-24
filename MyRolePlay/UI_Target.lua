--[[
	MyRolePlay 4 (C) 2010-2011 Etarna Moonshyne <etarna@moonshyne.org>
	Licensed under GNU General Public Licence version 2 or, at your option, any later version

	UI_Target.lua - Hook target functions & MSP receive handler to show/hide the MRP button
]]

function mrp:TargetChanged()
	if not mrpSaved.Options.Enabled or not mrpSaved.Options.ShowButton then
		MyRolePlayButton:Hide()
		return
	end
	if UnitIsUnit( "player", "target" ) then
		MyRolePlayButton:Show()
	elseif UnitIsPlayer( "target" ) and UnitIsFriend( "player", "target" ) then
		if msp.char[ mrp:UnitNameWithRealm( "target" ) ].supported then
			MyRolePlayButton:Show()
		else
			MyRolePlayButton:Hide()
		end
	else
		MyRolePlayButton:Hide()
	end
end

local function mrp_TargetEvent( this, event, addon )
	if event == "PLAYER_TARGET_CHANGED" then
		mrp:TargetChanged()
	end
end

function mrp_MSPButtonCallback( player )
	if UnitIsPlayer( "target" ) and UnitIsFriend( "player", "target" ) and mrp:UnitNameWithRealm( "target" ) == player then
		MyRolePlayButton:Show()
	end
end

local df = MyRolePlayDummyTargetFrame or CreateFrame( "Frame", "MyRolePlayDummyTargetFrame" )
df:SetScript( "OnEvent", mrp_TargetEvent )

function mrp:HookTarget()
	MyRolePlayDummyTargetFrame:RegisterEvent( "PLAYER_TARGET_CHANGED" )
end

function mrp:UnhookTarget()
	MyRolePlayDummyTargetFrame:UnregisterEvent( "PLAYER_TARGET_CHANGED" )
end