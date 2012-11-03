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

local ADDON, Addon = ...
local BlipParent, MapFrame, Tooltip = WorldMapButton, WorldMapDetailFrame, WorldMapTooltip

local Map = CreateFrame('CheckButton', ADDON..'MapButton', BlipParent, 'PetTrackerMapButton')
local Drop = CreateFrame('Frame', ADDON..'MapDrop', nil, 'UIDropDownMenuTemplate')

local Journal = Addon.Journal
local JounralInfo = C_PetJournal

local NumberMatch = '(%d+%.?%d*)'
local SpotMatch = NumberMatch .. '|' .. NumberMatch
local BestQuality = ITEM_QUALITY_RARE + 1
local SecondQuality = BestQuality - 1


--[[ Startup ]]--

function Map:Startup()
	self:RegisterEvent('MINIMAP_UPDATE_TRACKING')
	self.Flyout:SetScript('OnClick', self.ToggleDrop)
	self:SetScript('OnClick', self.Toggle)
	self:SetScript('OnEvent', self.Update)
	
	self.maxQuality = BestQuality
	self:SetPoint('TOPRIGHT', -6, -10)
	self:SetChecked(true)
	self:SetScale(.8)
	self.blips = {}
	
	Drop.relativePoint = 'BOTTOM'
	Drop.point = 'TOP'
	
	hooksecurefunc('WorldMapFrame_Update', function()
		self:Update()
	end)
end

function Map:Update()
	local index = 0
	
	if self:IsEnabled() then
		local width, height = MapFrame:GetSize()
		local species = Journal:GetCurrentSpecies()
		
		for specie, spots in pairs(species) do
			local best = Journal:GetBestOwned(specie)
			
			if best <= self.maxQuality then
				local type = select(3, JounralInfo.GetPetInfoBySpeciesID(specie))
				local icon = 'Interface/PetBattles/PetIcon-' .. PET_TYPE_SUFFIX[type]
	
				for x, y in gmatch(spots, '(%w+):(%w+)') do
					x, y = self:ParseCoords(x, y)
					index = index + 1
					
					local blip = self:GetBlip(index)
					blip:SetPoint('CENTER', MapFrame, 'TOPLEFT', x * width, -y * height)
					blip.icon:SetTexture(icon)
					blip.specie = specie
					blip:Show()
				end
			end
		end
	end
	
	for i = index + 1, #self.blips do
		self.blips[i]:Hide()
	end
end


--[[ Toggle ]]--

function Map:Toggle()
	local disabled = not self:IsEnabled()
	self.Icon:SetDesaturated(disabled)
	self.Flyout:GetNormalTexture():SetDesaturated(disabled)
	self.Flyout:GetHighlightTexture():SetDesaturated(disabled)
	self:Update()
end

function Map:ToggleDrop()
	local info = {
		{
			text = 'Pets',
			notCheckable = 1,
			isTitle = 1
    	}
	}
	
	local function addLine(name, quality)
		tinsert(info, {
			text = name,
			func = function()
				Map.maxQuality = quality
				Map:Update() 
			end
    	})
	end
	
	addLine('All', BestQuality)
	addLine('Not Maximized', SecondQuality)
	addLine('Missing', 0)

	EasyMenu(info, Drop, self, 0, 0)
end

function Map:IsEnabled()
	return self:GetChecked()
end


--[[ Blips ]]--

function Map:GetBlip(i)
	return self.blips[i] or self:CreateBlip(i)
end

function Map:CreateBlip(i)
	local blip = CreateFrame('Button', nil, BlipParent, 'WorldMapUnitTemplate')
	blip.icon:SetTexCoord(0.79687500, 0.49218750, 0.50390625, 0.65625000)
	blip:SetScript('OnClick', self.OnClick)
	blip:SetScript('OnEnter', self.OnEnter)
	blip:SetScript('OnLeave', self.OnLeave)
	blip:SetSize(13, 13)
	
	self.blips[i] = blip
	return blip
end

function Map:OnClick()
	PetJournal_LoadUI()
	HideUIPanel(WorldMapFrame)
	ShowUIPanel(PetJournalParent)

	PetJournalParent_SetTab(PetJournalParent, 2)
	PetJournal_SelectSpecies(PetJournal, self.specie)
end

function Map:OnEnter()
	local anchorLeft = self:GetCenter() > BlipParent:GetCenter()
	local name, icon, _,_, source = JounralInfo.GetPetInfoBySpeciesID(self.specie)
	
	local title = Map:ToString(icon) .. name
	local text = Map:KeepShort(source)
	
	WorldMapPOIFrame.allowBlobTooltip = false
	Tooltip:SetOwner(self, 'ANCHOR_' .. (anchorLeft and 'LEFT' or 'RIGHT'))
	Tooltip:SetText(title, 1,1,1)
	Tooltip:AddLine(text, 1,1,1, true)
	Tooltip:Show()
end

function Map:OnLeave()
	WorldMapPOIFrame.allowBlobTooltip = true
	Tooltip:Hide()
end


--[[ Data Formatting ]]--

function Map:ToString(icon)
	return '|T' .. icon .. ':20:20:0:0|t'
end

function Map:KeepShort(text)
	if not text:find('|n') and strlen(text) > 120 then
		return text:sub(0, 117) .. '...'
	end
	
	return text
end

function Map:ParseCoords(x, y)
	--local x, y = spot:match(SpotMatch)
	return tonumber(x, 16) / 1000, tonumber(y, 16) / 1000
end

Addon:NewModule('WorldMap', Map)