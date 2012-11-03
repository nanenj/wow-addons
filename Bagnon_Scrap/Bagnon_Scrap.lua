--[[
Copyright 2008-2012 João Cardoso
Bagnon Scrap is distributed under the terms of the GNU General Public License (or the Lesser GPL).
This file is part of Bagnon Scrap.

Bagnon Scrap is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Bagnon Scrap is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Bagnon Scrap. If not, see <http://www.gnu.org/licenses/>.
--]]

-- Glow and Icon
local Addon = Bagnon
local ItemSlot = Addon.ItemSlot
local SetQuality = ItemSlot.SetBorderQuality
local r, g, b  = GetItemQualityColor(0)

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

function ItemSlot:SetBorderQuality(...)
	local link = select(7, self:GetInfo())
	local icon = self.scrapIcon or CreateIcon(self)
	local isJunk

	if link then
		local id = tonumber(strmatch(link, 'item:(%d+)'))
		local bag, slot
		
		if not self:IsCached() then
			bag, slot = self:GetBag(), self:GetID()
		end
		
		isJunk = Scrap:IsJunk(id, bag, slot)
	end
	
	SetShown(self.border, isJunk and Scrap_Glow)
	SetShown(icon, isJunk and Scrap_Icons)
	
	if isJunk then
		self.questBorder:Hide()
		self.border:SetVertexColor(r, g, b, self:GetHighlightAlpha())
		return
	end
	
	SetQuality(self, ...)
end


-- Update Bags
local function UpdateBags()
	Addon:UpdateFrames()
end

hooksecurefunc(Scrap, 'SettingsUpdated', UpdateBags)
hooksecurefunc(Scrap, 'ToggleJunk', UpdateBags)
Scrap.HasSpotlight = true