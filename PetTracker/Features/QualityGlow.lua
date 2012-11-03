--[[
Copyright 2012 João Cardoso
PetTracker is distributed under the terms of the GNU General Public License (Version 3).
As a special exception, the copyright holders of this addon do not give permission to
redistribute and/or modify it.

This addon is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with the addon. If not, see <http://www.gnu.org/licenses/gpl-3.0.txt>.

This file is part of PetTracker.
--]]

local _, Addon = ...
local Quality = Addon:NewModule('QualityGlow')
local Battle = Addon.Battle

hooksecurefunc('PetBattleUnitFrame_UpdateDisplay', function(self)
	local pet = Battle:Get(self.petOwner, self.petIndex)
	Quality.Show(self, pet)
end)


--[[ Methods ]]--

function Quality:Show(pet)
	local quality = pet:GetQuality()
	local r, g, b = Addon:GetQualityColor(quality)

	if self.Name then
		self.Name:SetVertexColor(r,g,b)
	end
	
	if self.Level then
		self.Level:SetVertexColor(r,g,b)
	end
	
	if self.BorderAlive then
		self.BorderAlive:SetVertexColor(r,g,b)
		self.ActualHealthBar:SetVertexColor(r,g,b)
	end
	
	if self.Icon then
		local glow = self.petTrackerGlow or Quality.CreateGlow(self)
		glow:SetVertexColor(r,g,b)
	end
end

function Quality:CreateGlow()
	local glow = self:CreateTexture(nil, 'ARTWORK', nil, 2)
	glow:SetTexture('Interface/Buttons/UI-ActionButton-Border')
	glow:SetSize(self.Icon:GetWidth() * 1.7, self.Icon:GetHeight() * 1.7)
	glow:SetPoint('CENTER', self.Icon, 1, 1)
	glow:SetBlendMode('ADD')
	glow:SetAlpha(.7)
	
	self.petTrackerGlow = glow
	return glow
end
