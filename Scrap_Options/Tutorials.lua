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

local Tutorials = LibStub('CustomTutorials-2.1')
local L = Scrap_Locals

Tutorials.RegisterTutorials('Scrap', {
	savedvariable = 'Scrap_Tut',
	title = 'Scrap',
	
	{
		text = L.Tutorial_Welcome,
		image = 'Interface\\Addons\\Scrap\\Art\\Enabled Icon',
		point = 'Center',
		height = 150,
	},
	{
		text = L.Tutorial_Button,
		image = 'Interface\\Addons\\Scrap\\Art\\Tutorial-Button',
		shineTop = 5, shineBottom = -5,
		shineRight = 5, shineLeft = -5,
		shine = Scrap,
		anchor = MerchantFrame,
		point = 'TopLeft', relPoint = 'TopRight',
		y = -16,
	},
	{
		text = L.Tutorial_Drag,
		image = 'Interface\\Addons\\Scrap\\Art\\Tutorial-Drag',
		shine = MainMenuBarBackpackButton,
		shineTop = 6, shineBottom = -6,
		shineRight = 6, shineLeft = -6,
		point = 'TOPRIGHT',
		x = -5, y = -50
	},
	{
		text = L.Tutorial_Visualizer,
		image = 'Interface\\Addons\\Scrap\\Art\\Tutorial-Visualizer',
		shineRight = -2, shineLeft = 2, shineTop = 6,
		shine = Scrap.tab,
		anchor = MerchantFrame,
		point = 'TopLeft', relPoint = 'TopRight',
		y = -16,
	},
	{
		text = L.Tutorial_Bye,
		image = 'Interface\\Addons\\Scrap\\Art\\Enabled Icon',
		point = 'Center',
		height = 150,
	},
})


function Scrap:BlastTutorials()
	Tutorials.TriggerTutorial('Scrap', 5)
end