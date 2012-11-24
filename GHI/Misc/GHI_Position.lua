--===================================================
--									
--								GHI Position
--								GHI_Position.lua
--
--			Information about position of the user
--	
-- 						(c)2012 The Gryphonheart Team
--								All rights reserved
--===================================================

local class
function GHI_Position()
	if class then
		return class
	end
	class = GHClass("GHI_Position")

	--local variables
	local continent
	local currentContinent
	local x
	local y
	local zoneIndex
	local areaID

	local Round = function(num,decimals)
		if decimals then
			local n = math.floor(num*decimals*10);
			return n/(decimals*10);
		end
		return num;
	end

	local ConvertMopToCata = function(x_mop,y_mop)
		local x_cata = 1.243338591 * x_mop - 2822.734638;
		local y_cata = 1.243339374 * y_mop - 409.9540594;
		return x_cata,y_cata;
	end

	local IsMopClient = function()
		local _, _, _, tocVersion = GetBuildInfo()
		return tocVersion >= 50000;
	end

	--Class functions
	class.GetCoor = function(unit,decimals)
		if not (unit) then unit = "player" end

		zoneIndex = GetCurrentMapZone()
		continent = GetCurrentMapContinent()
		areaID = GetCurrentMapAreaID()
		SetMapToCurrentZone()
		currentContinent = GetCurrentMapContinent()
		if currentContinent < 0 or currentContinent > 4 then
			SetMapByID(areaID)
			--SetMapZoom(continent,zoneIndex)
			return 0.0, 0.0, 0
		end

		if currentContinent == 3 then
			SetMapZoom(3)
		else
			SetMapZoom(0)
		end

		local x, y = GetPlayerMapPosition(unit)

		if currentContinent == 3 then
			x = x * 2228.61382 -- scale for Outland
			y = y * 1485.74255
			SetMapByID(areaID)
			return Round(x,decimals), Round(y,decimals), 2
		else
			x = x * 11698.9534 -- scale for Azeroth
			y = y * 7799.30229
			SetMapByID(areaID)
			--SetMapZoom(continent,zoneIndex)

			if IsMopClient() then
				x,y = ConvertMopToCata(x,y);
			end

			return Round(x,decimals), Round(y,decimals), 1
		end
	end

	class.GetPlayerPos = function(decimals)
		local x, y, world = class.GetCoor("player",decimals);
		return {
			x = x,
			y = y,
			world = world
		};
	end

	class.IsPosWithinRange = function(position, range)
		GHCheck("GHI_Position.IsPosWithinRange", { "Table", "Number" }, { position, range })
		local playerPos = class.GetPlayerPos();
		position.world = position.world or position.continent;

		if not (playerPos.world == position.world) then
			return false;
		end

		local xDiff = position.x - playerPos.x;
		local yDiff = position.y - playerPos.y;
		return math.abs(math.sqrt(xDiff * xDiff + yDiff * yDiff)) <= range
	end

	return class
end
