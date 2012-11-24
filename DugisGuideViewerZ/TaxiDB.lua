local DGV = DugisGuideViewer
if not DGV then return end
local L = DugisLocals
local _

local TaxiDB = DGV:RegisterModule("TaxiDB")
TaxiDB.essential = true

--DugisFlightmasterLookupTable
--DugisFlightmasterDataTable
--TaxiDataCollection

local authorMode = false

function TaxiDB:Initialize()
	function DGV:GuidToNpcId(guid)
		if not guid then return nil end
		return tonumber( guid:sub( 6, 10 ), 16 )
	end

	function DGV:PackXY(x, y)
		local factor = 2^16
		return floor(x*factor)*factor + floor(y*factor)
	end

	function PackStrings(...)
		local value
		for i=1,select("#", ...) do
			local ith = tostring((select(i, ...)))
			if not value then value = ith
			else value = value..":"..ith end
		end
		return value
	end

	local function UpdateLookupTable(cont, x, y)
		DGV.Modules.TaxiData:GetLookupTable()[cont][DGV:PackXY(x,y)] = DGV:GuidToNpcId(UnitGUID("npc"))
	end

	local function GetCoord()
		local x,y = select(3, DGV:GetPlayerPosition())
		if y then return DGV:PackXY(x,y) end
	end
	
	local function GetPointerCoord()
		local x,y = DGV:GetCurrentCursorPosition(DugisMapOverlayFrame)
		if y then return DGV:PackXY(x,y) end
	end
	
	local function HighlightFlightmasterDestination()
		if DGV.Modules.DugisArrow.waypoints then
			for _, waypoint in pairs(DGV.Modules.DugisArrow.waypoints) do
				if waypoint.flightMasterID then
					for i=1,NumTaxiNodes() do
						local x,y = TaxiNodePosition(i)
						local cont = GetCurrentMapContinent()
						local loopNPC = DGV.Modules.TaxiData:GetLookupTable()[cont][DGV:PackXY(x,y)]
						if loopNPC and waypoint.flightMasterID==loopNPC then
							local btn = _G["TaxiButton"..i]
							if btn and btn:GetNormalTexture() then
								btn:GetNormalTexture():SetTexture("Interface\\TaxiFrame\\UI-Taxi-Icon-Red")
							end
						end
					end
				end
			end
		end
	end
	
	TaxiDB.routeToRecalculate = {}
	function DGV:TAXIMAP_OPENED()
		HighlightFlightmasterDestination()
		SetMapToCurrentZone()
		local cont = GetCurrentMapContinent()
		local recalulateRoute = false
		if not DugisFlightmasterDataTable then 
			DugisFlightmasterDataTable = {}
		end
		if not DugisFlightmasterDataTable[cont] then 
			DugisFlightmasterDataTable[cont] = {}
			if TaxiDB.routeToRecalculate.desc then
				recalulateRoute = true
			end
		end

		local key = DGV:GuidToNpcId(UnitGUID("npc"))
		if not key then return end
		local direct = {}
		local indirect = {}
		for i=1,NumTaxiNodes() do
			local x,y = TaxiNodePosition(i)
			local npc = DGV.Modules.TaxiData:GetLookupTable()[cont][DGV:PackXY(x,y)]
			if npc and not DugisFlightmasterDataTable[cont][npc] then
				DugisFlightmasterDataTable[cont][npc] = {}
			end
			
			local nodeType = TaxiNodeGetType(i)
			if nodeType=="CURRENT" then
				UpdateLookupTable(cont, x, y)
			elseif nodeType=="REACHABLE" and GetNumRoutes(i)==1 then
				UpdateLookupTable(cont, TaxiGetSrcX(i, 1), TaxiGetSrcY(i, 1))
				local dx, dy = TaxiGetDestX(i, 1), TaxiGetDestY(i, 1)
				local directNpc = DGV.Modules.TaxiData:GetLookupTable()[cont][DGV:PackXY(dx,dy)]
				tinsert(direct, directNpc or "XY-"..DGV:PackXY(dx,dy))
			elseif nodeType=="REACHABLE" then
				UpdateLookupTable(cont, TaxiGetSrcX(i, 1), TaxiGetSrcY(i, 1))
				local path = {}
				for j=1, GetNumRoutes(i) do
					local dx, dy = TaxiGetDestX(i, j), TaxiGetDestY(i, j)
					local indirectNpc = DGV.Modules.TaxiData:GetLookupTable()[cont][DGV:PackXY(dx,dy)]
					tinsert(path, indirectNpc or "XY-"..DGV:PackXY(dx,dy))
				end
				tinsert(indirect, PackStrings(unpack(path)))
			end
		end

		local fullData = DGV.Modules.TaxiData:GetFullData()
		local globalData = fullData[cont] and fullData[cont][key]
		if not DugisFlightmasterDataTable[cont][key] or
			not DugisFlightmasterDataTable[cont][key].m
		then
			DugisFlightmasterDataTable[cont][key] =
			{
				m = (globalData and globalData.m) or GetCurrentMapAreaID(),
				f = (globalData and globalData.f) or GetCurrentMapDungeonLevel(),
				coord = (globalData and globalData.coord) or GetCoord(),
			}
		end
		local newDirect = PackStrings(unpack(direct))
		if not globalData or globalData.direct~=newDirect then
			DugisFlightmasterDataTable[cont][key].direct = newDirect
		end
		for _, rt in ipairs(indirect) do
			if (not globalData or not tContains(globalData, rt)) and
				not tContains(DugisFlightmasterDataTable[cont][key], rt)
			then
				tinsert(DugisFlightmasterDataTable[cont][key], rt)
			end
		end
		
		if recalulateRoute then
			DGV.Modules.DugisArrow:VisitFlightmaster(key)
			DGV:SetSmartWaypoint(
				TaxiDB.routeToRecalculate.m, 
				TaxiDB.routeToRecalculate.f, 
				TaxiDB.routeToRecalculate.x, 
				TaxiDB.routeToRecalculate.y, 
				TaxiDB.routeToRecalculate.desc)
		end
	end
	
	-- function TaxiDB:UpdateQueryQuests()
		-- --DGV:DebugFormat("UpdateQueryQuests", "DGV.queryquests", DGV.queryquests)
		-- if not DGV.queryquests then
			-- QueryQuestsCompleted()
		-- else
			-- for _, staticPortalContinent in ipairs(DGV.Modules.TaxiData.StaticPortalData) do
				-- for _,data in ipairs(staticPortalContinent) do
					-- local reqType,req = select(7, strsplit(":", data)) 
					-- local qid = tonumber(req)
					-- if reqType=="qid" and qid then
						-- TaxiDataCollection.PortalQuestCompletion[qid] = DGV.queryquests[qid] and true
					-- end
				-- end
			-- end
		-- end
	-- end
	
	--/run DugisGuideViewer.Modules.TaxiDB:ShowLocation()
	function TaxiDB:ShowLocation(forceMapZone, forceLevel)
		local mapId,level = GetCurrentMapAreaID(), GetCurrentMapDungeonLevel()
		local coord = GetCoord()
		if coord then
			DGV:DebugFormat("ShowLocation", "player location", PackStrings(mapId, level, coord))
		end
		coord = GetPointerCoord()
		if coord then
			local x,y = DGV:UnpackXY(coord)
			if forceMapZone then
				coord = DGV:PackXY(DGV:TranslateWorldMapPosition(
					mapId, level, x, y, forceMapZone, level))
				mapId = forceMapZone
			end
			DGV:DebugFormat("ShowLocation", "pointer location", PackStrings(mapId, level, coord))
			local zoneName = UpdateMapHighlight(x,y)
			if zoneName then
				local zoneId = DGV:GetZoneIdByName(zoneName)
				DGV:DebugFormat("ShowLocation", "pointer map trans", zoneId)
				DGV:DebugFormat("ShowLocation", "pointer map trans relative", 
						PackStrings(level, DGV:PackXY(DGV:TranslateWorldMapPosition(
							mapId, level, x, y, zoneId, level))))
			end
		end
	end
	
	--/run DugisGuideViewer.Modules.TaxiDB:StartWatch()
	local watchVal
	function TaxiDB:StartWatch()
		watchVal = GetTime()
		DGV:DebugFormat("StartWatch")
		TaxiDB:ShowLocation()
	end
	
	--/run DugisGuideViewer.Modules.TaxiDB:StopWatch()
	function TaxiDB:StopWatch()
		if watchVal then
			local stopVal = GetTime()
			DGV:DebugFormat("StopWatch", "elapsed", stopVal-watchVal)
			TaxiDB:ShowLocation()
		end
	end
	
	--[[local function StoreZoneDataPostTeleport()
		local currentMapId = GetCurrentMapAreaID()
		local currentLevel = GetCurrentMapDungeonLevel()
		DGV:DebugFormat("OnZoneChanged", "currentMapId", currentMapId, "lastCast", DugisUnboundTeleports.lastCast)
		for portId,data in pairs(DGV.Modules.TaxiData.UnboundTeleportData) do
			local spellId,_,_,loc = strsplit(":", data)
			if not loc and DugisUnboundTeleports.lastCast==tonumber(spellId) then
				DugisUnboundTeleports[portId] = 
					PackStrings(spellId, currentMapId, currentLevel, GetCoord())
			end
		end
		DugisUnboundTeleports.lastCast = nil
	end]]
	
	function DGV:UNIT_SPELLCAST_SUCCEEDED(event, unit, spellName, spellRank, lineIdCounter, spellId)
		DGV:DebugFormat("UNIT_SPELLCAST_SUCCEEDED", "unit", unit, "spellName", spellName, "spellId", spellId)
		--[[if unit=="player" then
			for portId,data in pairs(DGV.Modules.TaxiData.UnboundTeleportData) do
				local spid = strsplit(":", data)
				if tonumber(spid)==spellId then
					DugisUnboundTeleports.lastCast = spellId
				end
			end
		end]]
	end
	
	local function OnZoneChanged()
		
	end
	
	function TaxiDB:OnZoneChanged()
		local mapId = GetCurrentMapAreaID()
		if not TaxiDataCollection then
			TaxiDataCollection = {}
		end
		if TaxiDataCollection.lastMapId~=mapId then
			OnZoneChanged()
		end
		TaxiDataCollection.lastMapId = mapId
	end
	
	function TaxiDB:OnModulesLoaded()
		if authorMode then
			hooksecurefunc("TaxiNodeOnButtonEnter", function(event)
				local cont = GetCurrentMapContinent()
				--if ( event == "TAXIMAP_OPENED" ) then
					for i=1,NumTaxiNodes() do
						local btn = _G["TaxiButton"..i]
						if btn and btn:GetNormalTexture() then
							local xyKey = DGV:PackXY(TaxiNodePosition(i))
							local lookup = DGV.Modules.TaxiData:GetLookupTable()[cont][xyKey]
							if not lookup then
								btn:GetNormalTexture():SetTexture(1,0,0)
							elseif not DugisFlightmasterDataTable[cont][lookup] or not DugisFlightmasterDataTable[cont][lookup].m then
								btn:GetNormalTexture():SetTexture(0,0,1)
							end
						end
					end
				--end
			end)
			
			if not TaxiDataCollection then
				TaxiDataCollection = {}
			end
			if not TaxiDataCollection.ZoneTransData then 
				TaxiDataCollection.ZoneTransData = DGV.Modules.TaxiData.ZoneTransData
			end
			local previewPointPool = {}
			local previewPoints = {}
			local function GetCreatePreviewPoint()
				local ppt = tremove(previewPointPool)
				if not ppt then
					ppt = CreateFrame("Button", nil, DugisMapOverlayFrame)
					ppt:RegisterForClicks("RightButtonUp")
					ppt:SetScript("OnClick", 
						function()
							if IsControlKeyDown() then
								ppt:RemoveMe()
							end
						end)
					ppt.icon = ppt:CreateTexture("ARTWORK")
					ppt.icon:SetAllPoints()
					ppt.icon:Show()
					ppt.icon:SetTexture("Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\circular")
					ppt:SetHeight(32)
					ppt:SetWidth(32)
				end
				ppt.icon:SetVertexColor(0, 1, 0)
				ppt:Show()
				tinsert(previewPoints, ppt)
				return ppt
			end
			
			local function RemoveValue(contData, mTrans, mDest)-- level, coord)
				--[[local newVal = PackStrings(level, coord)
				
				local existing = contData[mTrans][mDest]
				DGV:DebugFormat("RemoveValue", "existing", existing, "newVal", newVal, "strfind", {strfind(existing, newVal)})
				local start,finish = strfind(existing, newVal)
				existing = strtrim(strsub(existing, 1, start-1), ":")..strtrim(strsub(existing, finish+1), ":")
				DGV:DebugFormat("RemoveValue", "existing", existing)
				if strlen(existing)==0 then existing=nil end

				contData[mTrans][mDest] = existing]]
				contData[mTrans][mDest] = nil
			end
		
			hooksecurefunc("WorldMapFrame_UpdateMap", function()
				if not WorldMapFrame:IsShown() then return end
				while #(previewPoints)>0 do
					local ppt = tremove(previewPoints)
					ppt:Hide()
					tinsert(previewPointPool, ppt)
				end
				local mapId = GetCurrentMapAreaID()
				local c = DGV:GetCZByMapId(mapId)
				local contData = TaxiDataCollection.ZoneTransData[c]
				if contData and contData[mapId] then
					for mDest,data in pairs(contData[mapId]) do
						if mDest~="requirements" then
							local dataTbl = {strsplit(":", data)}
							for i=1,#(dataTbl),2 do
								local ppt = GetCreatePreviewPoint()
								local requirements = contData[mDest] and contData[mDest].requirements
								--DGV:DebugFormat("UpdateMap", "mDest", mDest, "contData[mDest]",contData[mDest], "requirements", requirements)
								if requirements then
									if strmatch(requirements, "Alliance") then
										ppt.icon:SetVertexColor(0, 0, 1)
									elseif strmatch(requirements, "Horde") then
										ppt.icon:SetVertexColor(1, 0, 0)
									end
								end
								ppt.RemoveMe = function()
									RemoveValue(
										contData, 
										mapId,
										mDest)
									RemoveValue(
										contData,
										mDest, 
										mapId)
									ppt:Hide()
								end
								DGV:PlaceIconOnWorldMap(
									WorldMapButton, 
									ppt, 
									mapId, 
									tonumber(dataTbl[i]), 
									DGV:UnpackXY(dataTbl[i+1]))
							end
						end
					end
				end
			end)
			
			local function AddValue(contData, mTrans, mDest, level, coord)
				local newVal = PackStrings(level, coord)
				if not contData[mTrans] then contData[mTrans] = {} end
				local existing = contData[mTrans][mDest]
				if existing then
					newVal = PackStrings(existing, newVal)
				end
				contData[mTrans][mDest] = newVal
			end
			
			--/run DugisGuideViewer.Modules.TaxiDB:SetZoneTransition()
			function TaxiDB:SetZoneTransition()
				local mapId,level = GetCurrentMapAreaID(), GetCurrentMapDungeonLevel()
				local c = DGV:GetCZByMapId(mapId)
				local allContData = TaxiDataCollection.ZoneTransData
				if not allContData[c] then allContData[c] = {} end
				local contData = allContData[c]
				local coord = GetPointerCoord()
				if coord then
					local x,y = DGV:UnpackXY(coord)
					local zoneName = UpdateMapHighlight(x,y)
					if zoneName then
						local zoneId = DGV:GetZoneIdByName(zoneName)
						if zoneId then
							AddValue(contData, mapId, zoneId, level, coord)
							AddValue(contData, zoneId, mapId, level, 
									DGV:PackXY(DGV:TranslateWorldMapPosition(
										mapId, level, x, y, zoneId, level)))
						end
					end
				end
				DGV:SafeMapUpdate()
			end
			
			--/run DugisGuideViewer.Modules.TaxiDB:ResetCollectedData()
			function TaxiDB:ResetCollectedData()
				TaxiDataCollection.ZoneTransData = nil
				DugisFlightmasterLookupTable = nil
			end
		else
			if TaxiDataCollection then
				TaxiDataCollection.ZoneTransData = nil
			end
			DugisFlightmasterLookupTable = nil
		end
	end
	
-- 	WorldFrame:HookScript("OnMouseUp",function(...)
-- 		DGV:DebugFormat("WorldFrame.OnMouseUp", 
-- 			"GetCursorInfo", {GetCursorInfo()},
-- 			"changed", SetCursor("Interface\\Cursor\\Interact.blp"))
-- 		ResetCursor()
-- 	end)

	function TaxiDB:Load()
		DGV:RegisterEvent("TAXIMAP_OPENED")
		DGV:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")

		if not TaxiDataCollection then
			TaxiDataCollection = {}
		end
		if not TaxiDataCollection.PortalQuestCompletion then
			TaxiDataCollection.PortalQuestCompletion = {}
		end
		--DGV:DebugFormat("TaxiDB:Load", "DugisFlightmasterDataTable", DugisFlightmasterDataTable)
		if DugisFlightmasterDataTable then
			for cont, tbl in pairs(DugisFlightmasterDataTable) do
				--DGV:DebugFormat("TaxiDB:Load", "cont", cont)
				for id,data in pairs(tbl) do
					--DGV:DebugFormat("TaxiDB:Load", "data.direct", data.direct)
					local direct = {}
					if data.direct then
						for _, val in ipairs({strsplit(":", data.direct)}) do
							if strsub(val, 1, 3)=="XY-" then
								local loc = strsub(val, 4)
								local lookup =  DGV.Modules.TaxiData:GetLookupTable()[cont][tonumber(loc)]
								tinsert(direct, lookup or val)
							else
								tinsert(direct, val)
							end
						end
					end
					data.direct = PackStrings(unpack(direct))
					local indirect = {}
					local newData = {}
					while #data>0 do
						wipe(indirect)
						local hops = data[1]
						for _, val in ipairs({strsplit(":", hops)}) do
							if strsub(val, 1, 3)=="XY-" then
								local loc = strsub(val, 4)
								local lookup =  DGV.Modules.TaxiData:GetLookupTable()[cont][tonumber(loc)]
								--DGV:DebugFormat("TaxiDB:Load", "lookup", lookup )
								tinsert(indirect, lookup or val)
							else
								tinsert(indirect, val)
							end
						end
						local packt = PackStrings(unpack(indirect))
						if not tContains(newData, packt) then
							tinsert(newData, packt)
						end
						tremove(data, 1)
					end
					for _, val in ipairs(newData) do
						tinsert(data, val)
					end
				end
			end
		end
	end
	
	function TaxiDB:Unload()
		DGV:UnregisterEvent("TAXIMAP_OPENED")
		DGV:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	end
end
