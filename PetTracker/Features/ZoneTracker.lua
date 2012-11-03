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
local JounralInfo = C_PetJournal
local Journal = LibStub('LibPetJournal-2.0')
local Tracker = CreateFrame('Frame')

local BEST_QUALITY = ITEM_QUALITY_LEGENDARY + 1
local HEADER_OFFSET = WATCHFRAME_QUEST_OFFSET
local MAX_LINES = 5

local BAR_FORMAT = PLAYERS_FOUND_OUT_OF_MAX
local BAR_OFF = 4


--[[ Startup ]]--

function Tracker:Startup()
	self.bar = CreateFrame('StatusBar', ADDON..'TrackerBar', UIParent, ADDON..'ProgressBar')
	self.lines = {self.bar}
	self.bar:Hide()
	
	self:RegisterEvent('MINIMAP_UPDATE_TRACKING')
	self:SetScript('OnEvent', function()
		WatchFrame_Update()
	end)
	
	WatchFrame_AddObjectiveHandler(function(parent, anchor, maxHeight, maxWidth)
		local progress = self:GetCurrentProgress()
		local missing = progress[0]
		self.lines[-1] = anchor
		
		if #missing > 0 and Addon:TrackingPets() then
			self.parent = parent
			self.lastLine = min(#missing, MAX_LINES) + 1

			self:SetupLine(0, 'Wild Pets')
			self:SetupBar(progress)
			self:SetupPets(missing)
			
			if #missing > MAX_LINES then
				self:SetupLine(self.lastLine, '...')
			end
			
			self:UpdateFocus()
			self:LayoutLines()
			
			return self.lines[self.lastLine], maxWidth, self.lastLine - 1, 0
		end
		
		self.lastLine = -1
		self:LayoutLines()
		return anchor, maxWidth, 0,0
	end)
	
	Journal.RegisterCallback(self, 'PetListUpdated', function()
		WatchFrame_Update()
	end)
end


--[[ Setup ]]--

function Tracker:SetupBar(progress)
	self.bar.text:SetFormattedText(BAR_FORMAT, progress.owned, progress.total)
	self.bar:SetMinMaxValues(0, progress.total)
	self.bar:SetValue(progress.owned)
end
	
function Tracker:SetupPets(pets)
	for i = 1, self.lastLine do
		self:SetupLine(i+1, pets[i], true)
	end
end

function Tracker:SetupLine(i, text, dash)
	local line = self:GetLine(i)
	line.dash:SetText(dash and QUEST_DASH or '')
	line.text:SetText(text)
end
	

--[[ Lines ]]--

function Tracker:LayoutLines()
	for i = 0, self.lastLine do
		local line = self.lines[i]
		local previous = self.lines[i-1]
		local off = line.isHeader and HEADER_OFFSET or i < 3 and BAR_OFF or 0
		
		if not previous then
			line:SetPoint('TOP', self.parent, 'TOP', 0, -off + 10)
		else
			line:SetPoint('TOP', previous, 'BOTTOM', 0, -off)
		end
		
		line:SetPoint('RIGHT', self.parent, 'RIGHT')
		line:SetPoint('LEFT', self.parent, 'LEFT')
		line:SetParent(self.parent)
		line:Show()
	end
	
	for i = self.lastLine + 1, #self.lines do
		local line = self:GetLine(i)
		line:Hide()
	end
end

function Tracker:UpdateFocus()
	local header = self.lines[0]
	if self.focus then
		header.text:SetTextColor(1, 0.82, 0)
	else
		header.text:SetTextColor(0.75, 0.61, 0)
	end
	
	for i, line in ipairs(self.lines) do
		if self.focus then
			line.text:SetTextColor(1, 1, 1)
		else
			line.text:SetTextColor(.8, .8, .8)
		end
	end
end

function Tracker:GetLine(i)
	return self.lines[i] or self:CreateLine(i)
end

function Tracker:CreateLine(i)
	local line = CreateFrame('Frame', nil, nil, 'WatchFrameLineTemplate')
	line.text:SetPoint('Left', line.dash, 'Right')
	line.text:SetHeight(WATCHFRAME_LINEHEIGHT)
	line.isHeader = i == 0
	
	if line.isHeader then
		line:SetScript('OnEnter', function() self:OnEnter() end)
		line:SetScript('OnLeave', function() self:OnLeave() end)
	end
		
	self.lines[i] = line
	return line
end


--[[ Tooltip ]]--

function Tracker:OnEnter()
	self.focus = true
	self:ShowTooltip()
	self:UpdateFocus()
end

function Tracker:ShowTooltip()
	local progress, zone = self:GetCurrentProgress()
	local missing = progress[0]
	
	GameTooltip:SetOwner(self.lines[0], 'ANCHOR_BOTTOMLEFT', -5, 5)
	GameTooltip:SetText(zone)
	
	for quality = BEST_QUALITY, 1, -1 do
		local pets = progress[quality]
		if #pets > 0 then
			GameTooltip:AddLine(Addon:GetQualityName(quality), Addon:GetQualityColor(quality))
			Tracker:ListPets(pets)
			GameTooltip:AddLine(' ')
		end
	end
	
	if #missing > 0 then
		GameTooltip:AddLine('Missing', 1, .1, .1)
		Tracker:ListPets(missing)
	end

	GameTooltip:Show()
end

function Tracker:ListPets(pets)
	for i, name in ipairs(pets) do
		GameTooltip:AddLine("- " .. name, 1,1,1)
	end
end

function Tracker:OnLeave()
	self.focus = nil
	self:UpdateFocus()
	GameTooltip:Hide()
end


--[[ API ]]--

function Tracker:GetCurrentProgress()
	local zone = self:GetCurrentZone()
	return self:GetProgress(zone), zone
end

function Tracker:GetProgress(zone)
	local progress = {total = 0}
	for i = 0, ITEM_QUALITY_LEGENDARY + 1 do
		progress[i] = {}
	end
	
	if zone then
		local owned = self:GetOwnedPets(zone)
		
		for _, specie in Journal:IterateSpeciesIDs() do
			local name, _,_,_, source = JounralInfo.GetPetInfoBySpeciesID(specie)
			
			if strfind(source, zone) then
				local ownedState = owned[specie] or 0
				
				progress.total = progress.total + 1
				tinsert(progress[ownedState], name)
			end
		end
	end
	
	progress.owned = progress.total - #progress[0]
	return progress
end

function Tracker:GetOwnedPets(zone)
	local owned = {}
	
	for _, pet in Journal:IteratePetIDs() do
		local specie = JounralInfo.GetPetInfoByPetID(pet)
		if specie then
			local source = select(5, JounralInfo.GetPetInfoBySpeciesID(specie))
		
			if strfind(source, zone) then
				local quality = select(5, JounralInfo.GetPetStats(pet))
				owned[specie] = max(quality, owned[specie] or 0)
			end
		end
	end
	
	return owned
end

function Tracker:GetCurrentZone()
	local continent = GetCurrentMapContinent()
	local zones = {GetMapZones(continent)}
	
	return zones[GetCurrentMapZone()]
end

Addon:NewModule('ZoneTracker', Tracker)