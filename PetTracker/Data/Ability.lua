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
local Ability = Addon:NewModule('Ability')
Ability.__index = Ability


--[[ Constructor ]]--

function Ability:New(pet, index)
	local usable, level, cooldown, onCooldown	
	local id, _, icon = pet:GetAbilityInfo(index)
	local type = pet:GetAbilityType(index)

	if id then
		usable, cooldown = pet:GetAbilityState(index)
		onCooldown = cooldown and cooldown > 0
		usable = usable and not onCooldown
	else 
		id, level, name, icon = self:FindInJournal(pet, index)
	end
	
	local ability = {
		id = id,
		pet = pet,
		index = index,
		
		name = name,
		icon = icon,
		level = level,
		type = type,
		
		onCooldown = onCooldown,
		cooldown = cooldown,
		usable = usable
	}
	
	return setmetatable(ability, self)
end

function Ability:FindInJournal(pet, index)
	local ids, levels = C_PetJournal.GetPetAbilityList(pet:GetSpecie())
	local id = ids[index]

	return id, levels[index], C_PetJournal.GetPetAbilityInfo(id)
end


--[[ API ]]--

function Ability:GetIdentifiers()
	return self.pet.owner, self.pet.index, self.id
end

function Ability:GetIcon()
	return self.icon, self.usable
end

function Ability:GetCooldown()
	return self.cooldown, self.onCooldown
end

function Ability:GetModifierFor(target)
	return target:GetModifier(self.type)
end