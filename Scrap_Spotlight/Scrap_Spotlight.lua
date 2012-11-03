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

if IsAddOnLoaded('Bagnon_Scrap') or IsAddOnLoaded('Combuctor_Scrap') or IsAddOnLoaded('Baggins_Scrap') then
	return DisableAddOn('Scrap_Spotlight')
end

local r, g, b  = GetItemQualityColor(0)
local function CreateGlow(slot)
	local glow = slot:CreateTexture(nil, 'OVERLAY')
	glow:SetSize(67, 67)
  	glow:SetPoint('CENTER')
  	glow:SetTexture([[Interface\Buttons\UI-ActionButton-Border]])
  	glow:SetVertexColor(r, g, b, .7)
  	glow:SetBlendMode('ADD')

  	slot.scrapGlow = glow
	return glow
end

local function CreateIcon(slot)
	local icon = slot:CreateTexture(nil, 'OVERLAY')
	icon:SetTexture('Interface\\Buttons\\UI-GroupLoot-Coin-Up')
	icon:SetPoint('TOPLEFT', 2, -2)
	icon:SetSize(15, 15)

  	slot.scrapIcon = icon
	return icon
end

local function SetShown(element, shown)
	if shown then
		element:Show()
	else
		element:Hide()
	end
end

hooksecurefunc('ContainerFrame_Update', function(self)
  local bag = self:GetID()
  local name = self:GetName()
  local size = self.size

	for i = 1, size do
		local slot = size - i + 1
	    local button = _G[name .. 'Item' .. slot]
		local id = GetContainerItemID(bag, i)
		
		local isJunk = id and Scrap:IsJunk(id, bag, slot)
		local glow = button.scrapGlow or CreateGlow(button)
		local icon = button.scrapIcon or CreateIcon(button)

		SetShown(glow, isJunk and Scrap_Glow)
		SetShown(icon, isJunk and Scrap_Icons)
	end
end)

hooksecurefunc(Scrap, 'ToggleJunk', function()
	local i = 1
	local frame = _G['ContainerFrame'..i]
	
	while frame do
		if frame:IsShown() then
			ContainerFrame_Update(frame)
		end
		
		i = i + 1
		frame = _G['ContainerFrame'..i]
	end
end)

Scrap.HasSpotlight = true