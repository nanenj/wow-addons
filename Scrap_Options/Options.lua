--[[
Copyright 2008-2012 João Cardoso
Scrap is distributed under the terms of the GNU General Public License (or the Lesser GPL).
This file is part of Scrap.

Scrap is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Scrap is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Scrap. If not, see <http://www.gnu.org/licenses/>.
--]]

local NoVisuals = not Scrap.HasSpotlight
local HasPawn = IsAddOnLoaded('Pawn_Scrap')
local Options = SushiMagicGroup(ScrapOptions)

Options:SetAddon('Scrap')
Options:SetFooter('Copyright 2008-2012 João Cardoso')
Options:SetChildren(function(self)
	self:CreateHeader('Behaviour', 'GameFontHighlight', true)
	self:Create('CheckButton', 'AutoSell')
	self:Create('CheckButton', 'SafeMode', 'Safe')
	self:Create('CheckButton', 'Learn')
	
	self:CreateHeader('Filters', 'GameFontHighlight', true)
	self:Create('CheckButton', 'LowEquip', nil, HasPawn)
	self:Create('CheckButton', 'LowConsume')
	
	self:CreateHeader('Visuals', NoVisuals and 'GameFontNormalLeftGrey' or 'GameFontHighlight', true)
	self:Create('CheckButton', 'Glow', nil, NoVisuals)
	self:Create('CheckButton', 'Icons', nil, NoVisuals)
	
	Scrap:SettingsUpdated()
end)