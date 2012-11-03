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

function Addon:NewModule(name, object)
	object = object or {}
	if object.Startup then
		object:Startup()
	end
	
	self[name] = object
	return object
end

function Addon:GetQualityName(quality)
	return _G['BATTLE_PET_BREED_QUALITY' .. quality]
end

function Addon:GetQualityColor(quality)
	return GetItemQualityColor(quality - 1)
end

function Addon:TrackingPets()
	return select(3 , GetTrackingInfo(1))
end