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
local ActionBar = PetBattleFrame.BottomFrame
local Actions = CreateFrame('CheckButton', nil, ActionBar)

local Ability = Addon.AbilityAction
local Pets = Addon.Battle

local NumAbilities = NUM_BATTLE_PET_ABILITIES
local Enemy = LE_BATTLE_PET_ENEMY
local Player = LE_BATTLE_PET_ALLY


--[[ Startup ]]--

function Actions:Startup()
	self:SetPoint('BOTTOM', ActionBar, 'TOP')
	self:SetSize(300, 100)
	self:SetScale(.8)
	
	self:SetScript('OnEvent', self.Update)
	self:RegisterEvent('PET_BATTLE_PET_CHANGED')
	self:RegisterEvent('PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE')
	
	self:SetScript('OnShow', self.Update)
	self:SetHook('PetBattlePetSelectionFrame_Hide', self.Show)
	self:SetHook('PetBattlePetSelectionFrame_Show', self.Hide)
	
	for i = 1, NumAbilities do
		self:CreateButton(i)
	end
end

function Actions:SetHook(target, hook)
	hooksecurefunc(target, function()
		hook(self)
	end)
end

function Actions:CreateButton(i)
	local button = Ability(self)
	button:SetPoint('LEFT', (button:GetWidth() + 5) * i, 10)
	button:SetHighlightTexture(nil)
	button:SetPushedTexture(nil)
	button:UnregisterAllEvents()
	
	self[i] = button
end


--[[ Update ]]--

function Actions:Update()
	local enemy = Pets:GetCurrent(Enemy)
	local target = Pets:GetCurrent(Player)
	
	for i = 1, NumAbilities do
		local ability = enemy:GetAbility(i)
		self[i]:Display(ability, target)
	end
end

Addon:NewModule('EnemyActions', Actions)