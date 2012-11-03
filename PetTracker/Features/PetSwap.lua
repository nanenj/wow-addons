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
local Swap = CreateFrame('Frame', ADDON..'Switch', PetBattleFrame, 'ButtonFrameTemplate')

local NumPets = NUM_BATTLE_PETS_IN_BATTLE
local NumAbilities = NUM_BATTLE_PET_ABILITIES
local Enemy = LE_BATTLE_PET_ENEMY
local Player = LE_BATTLE_PET_ALLY

local Slot = Addon.SlotFrame
local Pets = Addon.Battle


--[[ Startup ]]--

function Swap:Startup()
	self:RegisterEvent('PET_BATTLE_ACTION_SELECTED')
	self:SetScript('OnEvent', self.Hide)
	self:Hide()
	
	SetPortraitToTexture(self.portrait:GetName(), 'Interface/Icons/INV_Pet_SwapPet')
	PetBattleFrame.BottomFrame.PetSelectionFrame = self
	PetBattlePetSelectionFrame_Show = function()
		self:Initialize()
		self:Update()
		self:Show()
	end
end

function Swap:Initialize()
	self:CreateSlotLine(Enemy, 'Enemy Pets', 'TOPRIGHT', -10)
	self:CreateSlotLine(Player, 'Player Pets', 'TOPLEFT', 10)
	self.TitleText:SetText(SWITCH_PET)
	self:SetPoint('CENTER')
	self:SetSize(840, 424)
	
	self.CreateSlotLine, self.CreateSlot = nil
	self.Initialize = function() end
end


--[[ Create Slots ]]--

function Swap:CreateSlotLine(owner, title, ...)
	for i = 1, NumPets do
		self[owner..i] = self:CreateSlot(i, ...)
	end
	
	local border = 	CreateFrame('Frame', nil, self, ADDON..'SlotBorder')
	border:SetPoint('TOP', self[owner..1], 0, 5)
	--border.Title:SetText(title)
end

function Swap:CreateSlot(i, point, off)
	local slot = Slot(self.Inset)
	slot:SetPoint(point, off, 98 - 108 * i)
	slot:SetScript('OnClick', function()
		self:OnClick(slot)
	end)
	
	return slot
end


--[[ Update ]]--

function Swap:Update()
	self:UpdateFor(Player, Enemy)
	self:UpdateFor(Enemy, Player)
	
	local close = _G[self:GetName() .. 'CloseButton']
	if Pets:IsPvE() then
		close:Enable()
	else
		close:Disable()
	end
end

function Swap:UpdateFor(owner, target)
	target = Pets:GetCurrent(target)
	
	for i = 1, NumPets do
		local pet = Pets:Get(owner, i)
		local slot = self[owner .. i]

		slot:Display(pet, target)
		slot.pet = pet
	end	
end


--[[ Frame Events ]]--

function Swap:OnClick(slot)
	if slot.pet:Swap() then
		self:Hide()
	end
end

Addon:NewModule('PetSwap', Swap)