local mapdata = LibStub("LibMapData-1.0-Dugi")
local astrolabe = DongleStub("Astrolabe-1.0-Dugi")
DugisGuideViewer.astrolabe = astrolabe

--/run DugisGuideViewer:ShowMapData(mapId, ...)
function DugisGuideViewer:ShowMapData(mapId, ...)
	local tbl = {}
	local mapData = {}
	tbl[mapId] = mapData
	local numFloors = select("#", ...)
	SetMapByID(mapId)
	local _, TLx, TLy, BRx, BRy = GetCurrentMapZone();
	if ( TLx and TLy and BRx and BRy ) then
		if not ( TLx < BRx ) then
			TLx = -TLx;
			BRx = -BRx;
		end
		if not ( TLy < BRy) then
			TLy = -TLy;
			BRy = -BRy;
		end
		mapData.width = BRx - TLx
		mapData.height = BRy - TLy
		mapData.xOffset = TLx
		mapData.yOffset = TLy
	end
	if ( numFloors > 0 ) then
		for i = 1, numFloors do
			local f = select(i, ...)
			SetDungeonMapLevel(f);
			local _, TLx, TLy, BRx, BRy = GetCurrentMapDungeonLevel();
			if ( TLx and TLy and BRx and BRy ) then
				mapData[f] = {};
				if not ( TLx < BRx ) then
					TLx = -TLx;
					BRx = -BRx;
				end
				if not ( TLy < BRy) then
					TLy = -TLy;
					BRy = -BRy;
				end
				mapData[f].width = BRx - TLx
				mapData[f].height = BRy - TLy
				mapData[f].xOffset = TLx
				mapData[f].yOffset = TLy
			end
		end
	end
	DugisGuideViewer:DebugFormat("ShowMapData", "tbl", tbl)
end

function DugisGuideViewer:GetMapNameFromID(mapId)
	return mapdata:MapLocalize(mapId)
end

function DugisGuideViewer:GetMapIDFromName(mapName)
	return mapdata:MapAreaId(mapName)
end

--[[function DugisGuideViewer:InitMapping( )
	DugisGuideViewer:initAnts()
	DugisGuideViewer.DugisArrow:initArrow()
end]]

function DugisGuideViewer:TranslateWorldMapPosition(map, floor, x, y, M, F)
	return astrolabe:TranslateWorldMapPosition(map, floor, x, y, M, F)
end

function DugisGuideViewer:PlaceIconOnMinimap( icon, mapID, mapFloor, x, y)
	if x and y and mapID then
		astrolabe:PlaceIconOnMinimap(icon, mapID, mapFloor, x, y)
	else
		DebugPrint("Error: unable to place icon")
	end
end

function DugisGuideViewer:GetMapID(ContToUse, ZoneToUse)
	return astrolabe:GetMapID(ContToUse, ZoneToUse)
end

function DugisGuideViewer:PlaceIconOnWorldMap( frame, icon, mapID, mapFloor, x, y )		
	if x and y and mapID then
		astrolabe:PlaceIconOnWorldMap(frame, icon, mapID, mapFloor, x, y )
	else
		DebugPrint("Error: unable to place waypoint ")
	end
	
	DugisGuideViewer:CheckForArrowChange()
	
	if DugisGuideViewer.WrongInstanceFloor --[[or not DugisGuideViewer.WaypointsShown]] then
		DebugPrint("####Hide icon: WrongInstanceFloor")
		icon.icon:Hide()
	else
		icon.icon:Show()
	end
end

function DugisGuideViewer:ComputeDistance( m1, f1, x1, y1, m2, f2, x2, y2 )
	
	return astrolabe:ComputeDistance( m1, f1, x1, y1, m2, f2, x2, y2 )
end

function DugisGuideViewer:IsValidDistance( m, f, x, y )
	local dist, dx, dy = DugisGuideViewer:GetDistanceFromPlayer(m, f, x, y)
	if dist and dx and dy then
		return true
	end
end

function DugisGuideViewer:GetDistanceFromPlayer(m, f, x, y)
	local pmap, pfloor, px, py = DugisGuideViewer:GetPlayerPosition()
	return astrolabe:ComputeDistance(pmap, pfloor, px, py, m, f, x/100, y/100) 
end

function DugisGuideViewer:WorldMapFrameOnShow()
	DugisGuideViewer:OnMapChangeUpdateArrow( )
end
WorldMapFrame:HookScript( "OnShow", DugisGuideViewer.WorldMapFrameOnShow )


function DugisGuideViewer:GetUnitPosition( unit, noMapChange )
	return astrolabe:GetUnitPosition( unit, noMapChange )
end


function DugisGuideViewer:GetPlayerPosition()

    local x, y = GetPlayerMapPosition("player")
    if x and y and x > 0 and y > 0 then
	local map, floor = GetCurrentMapAreaID(), GetCurrentMapDungeonLevel();
        floor = floor or self:GetDefaultFloor(map)
        return map, floor, x, y
    end

    if WorldMapFrame:IsVisible() then
        return
    end

    SetMapToCurrentZone()
    local x, y = GetPlayerMapPosition("player")

    if x <= 0 and y <= 0 then
        return
    end

    local map, floor = GetCurrentMapAreaID(), GetCurrentMapDungeonLevel();
    floor = floor or self:GetDefaultFloor(map)
    return map, floor, x, y
end

function DugisGuideViewer:GetPlayerMapPositionDisruptive()
	local orig_mapId, orig_level = GetCurrentMapAreaID(), GetCurrentMapDungeonLevel()
	SetMapToCurrentZone()
	local DugisArrow = DugisGuideViewer.Modules.DugisArrow
	local m1, f1, x1, y1 =  DugisGuideViewer.astrolabe:GetUnitPosition("player")
	if not m1 or m1==0 then
		m1, f1, x1, y1 = 
			DugisArrow.map, DugisArrow.floor,
			DugisArrow.pos_x, DugisArrow.pos_y
	end
	if orig_mapId~=m1 or orig_level~=f1 then
		SetMapByID(orig_mapId)
		SetDungeonMapLevel(orig_level)
	end
	return m1, f1, x1, y1
end


function DugisGuideViewer:GetDefaultFloor(map)
    local floors = astrolabe:GetNumFloors(map) == 0 and 0 or 1
    return floors == 0 and 0 or 1
end