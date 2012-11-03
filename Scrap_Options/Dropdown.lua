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
local Dropdown = CreateFrame('Frame', 'ScrapDropdown', nil, 'UIDropDownMenuTemplate')
local L = Scrap_Locals

function Dropdown:Toggle(anchor)
	local info = {
		{
			text = 'Scrap',
			notCheckable = 1,
			isTitle = 1
    	},
    	{
			text = L.AdvancedOptions,
			notCheckable = 1,
			func = function()
				InterfaceOptionsFrame_OpenToCategory(ScrapOptions)
			end
    	},
    	{
 			text = L.ShowTutorials,
			notCheckable = 1,
			func = function()
		    	LibStub('CustomTutorials-2.1').ResetTutorials('Scrap')
				Scrap:BlastTutorials()
			end
    	}
	}

	EasyMenu(info, self, anchor or 'Scrap', 0, 0, 'MENU')
end