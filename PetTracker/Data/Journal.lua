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
local Journal = Addon:NewModule('Journal')

local Cache = LibStub('LibPetJournal-2.0')
local Server = C_PetJournal


--[[ Qualities ]]--

function Journal:GetBestOwned(specie)
	local bestQuality = 0
	
	for _, pet in Cache:IteratePetIDs() do
		local petSpecie = Server.GetPetInfoByPetID(pet)
		if petSpecie == specie then
			bestQuality = max(bestQuality, self:GetPetQuality(pet))
		end
	end
	
	-- owned = Server.GetOwnedBattlePetString(speciesID)
	-- Patch 5.1
	
	return bestQuality
end

function Journal:GetPetQuality(pet)
	return select(5, Server.GetPetStats(pet))
end


--[[ Zone Species ]]--

function Journal:GetCurrentSpecies()
	return self:GetSpeciesIn(GetCurrentMapAreaID())
end

function Journal:GetSpeciesIn(zone)
	return PetTracker_Spots[zone] or {}
end