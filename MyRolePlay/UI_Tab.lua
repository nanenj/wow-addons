--[[
	MyRolePlay 4 (C) 2010-2011 Etarna Moonshyne <etarna@moonshyne.org>
	Licensed under GNU General Public Licence version 2 or, at your option, any later version

	UI_Tab.lua - Functions to add the MyRolePlay tab to the CharacterFrame
]]

local L = mrp.L

local tinsert = tinsert

function mrp:AddMRPTab()
	if not mrp.Tabname then
		-- Create the button for the tab
		-- Do NOT change the frame name, it's magic, see FrameXML/UIPanelTemplates.lua
		mrp.oldNumTabs = CharacterFrame.numTabs
		mrp.Tabname = "CharacterFrameTab"..CharacterFrame.numTabs+1 
		local tab = CreateFrame( "Button", mrp.Tabname, CharacterFrame, "CharacterFrameTabButtonTemplate", CharacterFrame.numTabs+1 )
		tab:SetText( L["tabtitle"] )
		tab:SetPoint( "LEFT", "CharacterFrameTab"..CharacterFrame.numTabs, "RIGHT", -15, 0 )
		tab:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["Edit your roleplaying profiles."], 1.0, 1.0, 1.0 )
		end )
		tab:SetScript( "OnLeave", GameTooltip_Hide )
		tab:SetScript( "OnClick", function(self)
			ToggleCharacter( "MyRolePlayCharacterFrame" )
			PlaySound("igCharacterInfoTab") -- I have no idea *why* it does this twice, but it does sound louder when you do
		end )

		-- Add our subframe to the list of frames
		tinsert( CHARACTERFRAME_SUBFRAMES, "MyRolePlayCharacterFrame" )

		-- Increase the number of tabs to match
		PanelTemplates_SetNumTabs( CharacterFrame, CharacterFrame.numTabs+1 )

		-- Nudge the positioning/resizing so the game (hopefully) fits the tabs under the window again
		PanelTemplates_TabResize( _G[mrp.Tabname], 0 )
		CharacterFrame_TabBoundsCheck( _G[mrp.Tabname] )
	else
		_G[mrp.Tabname]:Show()
	end
end

function mrp:RemoveMRPTab()
	if mrp.Tabname then
		_G[mrp.Tabname]:Hide()
	end
end

-- Tab size/location fixing function to re-anchor the tabs and fit them under the window
-- Fixed for 4.3: updated from Blizzard's CharacterFrame.lua (theirs is still hardcoded).
CharacterFrame_TabBoundsCheck = nil -- Kill and garbage-collect Blizzard's FrameXML version

local function CompareFrameSize(frame1, frame2)
	return frame1:GetWidth() > frame2:GetWidth();
end

local CharTabtable = {};

function CharacterFrame_TabBoundsCheck(self)
	if ( string.sub(self:GetName(), 1, 17) ~= "CharacterFrameTab" ) then
		return;
	end
	
	local totalSize = 60
	local previouslyshowntab = CharacterFrameTab1
	for i=1, CharacterFrame.numTabs do
		_G["CharacterFrameTab"..i.."Text"]:SetWidth(0)
		PanelTemplates_TabResize(_G["CharacterFrameTab"..i], 0)
		if i>1 then
			_G["CharacterFrameTab"..i]:SetPoint( "LEFT", previouslyshowntab, "RIGHT", -15, 0 )
		end
		if _G["CharacterFrameTab"..i]:IsShown() then
			previouslyshowntab =  _G["CharacterFrameTab"..i]
			totalSize = totalSize + previouslyshowntab:GetWidth()
		end
	end

	if mrp.Tabname then
		if not CharacterFrameTab4:IsShown() then
			if not CharacterFrameTab3:IsShown() then
				if not CharacterFrameTab2:IsShown() then
					_G[mrp.Tabname]:SetPoint( "LEFT", "CharacterFrameTab1", "RIGHT", -15, 0 )
				else
					_G[mrp.Tabname]:SetPoint( "LEFT", "CharacterFrameTab2", "RIGHT", -15, 0 )
				end
			else
				_G[mrp.Tabname]:SetPoint( "LEFT", "CharacterFrameTab3", "RIGHT", -15, 0 )
			end
		else
			_G[mrp.Tabname]:SetPoint( "LEFT", "CharacterFrameTab4", "RIGHT", -15, 0 )
		end
	end
	
	local threshold = 435
	local diff = totalSize - threshold
	
	if ( totalSize > threshold ) then
		--Find the biggest tab
		for i=1, CharacterFrame.numTabs do
			CharTabtable[i]=_G["CharacterFrameTab"..i];
		end
		table.sort(CharTabtable, CompareFrameSize);
		
		local i=1;
		while ( diff > 0 and i <= CharacterFrame.numTabs) do
			local tabText = _G[CharTabtable[i]:GetName().."Text"]
			local change = min(10, diff);
			tabText:SetWidth(tabText:GetWidth() - change);
			diff = diff - change;
			PanelTemplates_TabResize(CharTabtable[i], -change, nil, 8-change, 88);
			i = i+1;
		end
	end
end