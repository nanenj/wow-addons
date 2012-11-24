local DGV = DugisGuideViewer
if not DGV then return end
local L = DugisLocals

local Taxi = DGV:RegisterModule("Taxi")
Taxi.essential = true
local _

local B = LibStub("LibBabble-SubZone-3.0")
local BR = B:GetReverseLookupTable()
local BF = LibStub("LibBabble-Faction-3.0")
local BFR = BF:GetReverseLookupTable()
local GetSpellBookItemInfo, GetSpellInfo, IsUsableSpell, GetSpellCooldown, GetItemCount = 
	GetSpellBookItemInfo, GetSpellInfo, IsUsableSpell, GetSpellCooldown, GetItemCount

function Taxi:Initialize()
	local TaxiData = DGV.Modules.TaxiData
	
	local RouteBuilders = {
		Character = {"Character"},
		BoundTeleport = {"BoundTeleport"},
		UnboundTeleport = {"UnboundTeleport"},
		ZenPilgrimageReturn = {"ZenPilgrimageReturn"},
		StaticPortals = {"StaticPortals"},
		Boats = {"Boats"},
		FlightMaster = {"FlightMaster"},
		FlightHop = {"FlightHop"},
		LocalPortals = {"LocalPortals"}
	}
		
	local function tinsertList(t, ...)
		local n = select("#", ...)
		for i=1,n do
			t.n = n
			t[i] = (select(i, ...))
		end
	end
	
	local tablePool = {}
	local tables = {}
	local function GetCreateTable(...)
		local t = tremove(tablePool)
		if not t then
			t = {}
		end
		wipe(t)
		tinsertList(t, ...)
		tinsert(tables, t)
		return t
	end

	local function PoolTable(t)
		local val, index
		for index, val in ipairs(tables) do
			if t == val then
				tinsert(tablePool, tremove(tables, index))
				if t.n then
					return unpack(t, 1, t.n)
				else
					return unpack(t)
				end
			end
		end
	end

	local function CleanUpTables()
		DGV:DebugFormat("CleanUpTables", "#(tables)", #(tables))
		while #(tables)>0 do
			tinsert(tablePool, tremove(tables))
		end
	end
	
	local routePool = {}
	local routes = {}
	local function GetCreateRoute(builder, currentBest, parentRoute)
		local route = tremove(routePool)
		if not route then
			route = {}
		end
		wipe(route)
		tinsert(routes, route)
		route.parentRoute = parentRoute
		route.currentBest = currentBest
		route.builder = builder
		return route
	end

	local function PoolRoute(route)
		--DGV:DebugFormat("PoolRoute", "#(routes)", #(routes))
		for _, subRoute in ipairs(route) do
			if type(subRoute)=="table" and subRoute.parentRoute==route then
				PoolRoute(subRoute)
			end
		end
		local val, index
		for index, val in ipairs(routes) do
			if route == val then
				tinsert(routePool, tremove(routes, index))
				--DGV:DebugFormat("PoolRoute end", "#(routes)", #(routes))
				return
			end
		end
		--DGV:DebugFormat("PoolRoute end", "#(routes)", #(routes))
	end

	local function CleanUpRoutes()
		DGV:DebugFormat("CleanUpRoutes", "#(routes)", #(routes))
		while #(routes)>0 do
			tinsert(routePool, tremove(routes))
		end
	end

	--local upperBound = 2000
	local function IsBest(route, ...)
		local isBest = false
		if not route.currentBest then 
			isBest = true
		else
			local est = route.builder:Estimate(route)
			for i=1,select("#", ...) do
				local routeArg = select(i,...)
				est = est + routeArg.builder:Estimate(routeArg)
			end
			isBest = route.currentBest.builder:Estimate(route.currentBest)
					> est --and est<upperBound
		end
		return isBest and 
			(not route.parentRoute or 
				IsBest(route.parentRoute, route, ...))
	end
	
	local coroutinePool = {}
	local function coItFunc(cobject, control)
		--DGV:DebugFormat("coItFunc")
		local results = GetCreateTable(coroutine.resume(cobject.co, cobject, control))
		local code, control = unpack(results, 1, 2)
		if not code then
			DGV:DebugFormat("coiterator error", "message", control)
		end
		--DGV:DebugFormat("coItFunc return", "control", control)
		return select(2, PoolTable(results))
	end
	
	local function delegateFunc(cobject, control)
		while(cobject.func) do
			--DGV:DebugFormat("delegateFunc invoking new", "cobject.func", cobject.func)
			--DGV:DebugFormat("delegateFunc", "cobject.args[3]", cobject.args[3], "cobject.args[7]", cobject.args[7], "unpack(cobject.args)")
			cobject.func(control, unpack(cobject.args, 1, cobject.args.n))
			PoolTable(cobject.args)
			cobject.args = nil
			cobject.func = nil
			tinsert(coroutinePool, cobject)
			cobject, control = coroutine.yield(nil)
		end
	end
	
	local function CoroutineIterator(func, ...)
		--DGV:DebugFormat("CoroutineIterator", "func", func)
		local cobject = tremove(coroutinePool)
		if not cobject then
			--DGV:DebugFormat("CoroutineIterator creating coroutine")
			cobject = {}
			cobject.co = coroutine.create(delegateFunc)
		end
		cobject.func = func
		cobject.args = GetCreateTable(...)
		--DGV:DebugFormat("CoroutineIterator", "cobject.args[3]", cobject.args[3], "cobject.args[7]", cobject.args[7])
		return coItFunc, cobject
	end
	
	--[[local function CrossProduct(x1, y1, x2, y2)
		return x1*y2 - x2*y1
	end
	
	local function VectorAdd(x1, y1, x2, y2)
		return x1 + x2, y1 + y2
	end
	
	local function VectorSubtract(x1, y1, x2, y2)
		return VectorAdd(x1, y1, x2*-1, y2*-1)
	end
	
	local epsilon = 10e-6
	local function CheckIntersection(x1, y1, x2, y2, x3, y3, x4, y4)
		local px,py = x1, y1
		local rx,ry = VectorSubtract(x2, y2, x1, y1)
		local qx,qy = x3,y3
		local sx,sy = VectorSubtract(x4, y4, x3, y3)
		local rsCross = CrossProduct(rx, ry, sx, sy)
		if rsCross <= epsilon and rsCross >= -1 * epsilon then --parallel
			return false
		end
		
		local qMinPx,qMinPy = VectorSubtract(qx, qy, px, py)
		local t = CrossProduct(qMinPx,qMinPy,sx,sy)/rsCross
		local u = CrossProduct(qMinPx,qMinPy,rx,ry)/rsCross
		if u>0 and u<=1 and t>0 and t<=1 then
			return true
		else
			return false
		end
	end]]
	
	local function GetAngle(x1, y1, x2, y2, x3, y3)
		local ax = x1 - x2
		local ay = y1 - y2
		
		local bx = x3 - x2
		local by = y3 - y2
		
		local aLen = math.sqrt(ax^2 + ay^2)
		local bLen = math.sqrt(bx^2 + by^2)
		
		local dotProduct = ax * bx + ay * by
		return math.acos(dotProduct / (aLen * bLen))
	end
	
	local function GetSmallestAngle(m1, f1, x1, y1, mData, pointData, m2, f2, x2, y2)
		local shortestF, shortestX, shortestY, shortestDist
		local data = GetCreateTable(strsplit(":", pointData))
		for i=1,#(data),2 do
			local selectedF,selectedX,selectedY = tonumber(data[i]), 
				DGV:UnpackXY(data[i+1])
			local xTrans,yTrans  = DGV:TranslateWorldMapPosition(
				mData, selectedF, selectedX, selectedY, m1, f1)
			xTrans,yTrans = DGV.Modules.Ants:ClampLine(xTrans,yTrans,x1,y1)
			
			--DGV:DebugFormat("GetSmallestAngle", "TranslateWorldMapPosition args", {m2, f2, x2, y2, m1, f1})
			local xDest,yDest  = DGV:TranslateWorldMapPosition(
				m2, f2, x2, y2, m1, f1)
			--DGV:DebugFormat("GetSmallestAngle", "ClampLine args", {xDest,yDest,x1,y1})
			xDest,yDest = DGV.Modules.Ants:ClampLine(xDest,yDest,x1,y1)
			
			--DGV:DebugFormat("GetSmallestAngle", "GetAngle args", {xTrans, yTrans, x1, y1, xDest, yDest})
			--local dist = DGV:ComputeDistance(mData, selectedF, selectedX, selectedY, mData, selectedF, xDest, yDest)
			local angle = GetAngle(xTrans, yTrans, x1, y1, xDest, yDest)
			if angle and (not shortestDist or angle < shortestDist) then
				shortestF,shortestX,shortestY = selectedF,selectedX,selectedY
				shortestDist = angle
			end
		end
		PoolTable(data)
		--DGV:DebugFormat("GetNearest", "shortestF", shortestF,"shortestX", shortestX,"shortestY",shortestY,"shortestDist",shortestDist)
		return shortestF,shortestX,shortestY,shortestDist
	end
	
	local function ListContains(value, ...)
		for i=1,select("#", ...) do
			if select(i, ...)==value then return true end
		end
	end
	
	local function CheckRequirements(requirementsStart, ...)
		local pass = true
		for i=requirementsStart,select("#", ...),2 do
			local reqType, req = select(i, ...)
			if reqType=="lvl" then
				pass = pass and UnitLevel("player")>=tonumber(req)
			elseif reqType=="qid" then
				pass = pass and IsQuestFlaggedCompleted(tonumber(req))
			elseif reqType=="fac" then
				pass = pass and UnitFactionGroup("player")==req
			elseif reqType=="rep" then
				local standing,fac = strmatch(req, "^(%d+)%.(.*)$", 1)
				pass = false
				for j=1,GetNumFactions() do
					local name, _, standingId = GetFactionInfo(j)
					if name and standingId and 
						name==BFR[fac] and standingId>=tonumber(standing)
					then
						pass = true
						break
					end
				end
			end
		end
		if pass then return ... end
	end
	
	function DGV:CheckRequirements(...)
		if select("#", ...)==0 then return true end
		return CheckRequirements(1, ...)
	end
	
	local function QuickPathExists(contData, m1, m2, ...)
		if m1==m2 then return true end
		if not contData then return end
		if not contData[m1] then return end
		local requirements = contData[m2] and contData[m2].requirements
		if requirements and not CheckRequirements(1, strsplit(":", requirements)) 
		then 
			return 
		end
		if contData[m1][m2] then return true end
		for m in pairs(contData[m1]) do
			if m~="requirements" then
				if not ListContains(m, ...) and 
					QuickPathExists(contData, m, m2, m1, ...)
				then return true end
			end
		end
	end
	
	local function CorrectMouseOverZoneFloor(m, x, y)
		local curMap = GetCurrentMapAreaID()
		if m==curMap then
			local actualZoneName = UpdateMapHighlight(x,y)
			if actualZoneName then
				m = DGV:GetZoneIdByName(actualZoneName)
				local f = 0
				if m==321 or 504 then --orgrimmar or dalaran is the only map i know of w/0 a floor 0
					f=1
				end
				return m,f
			end
		end
	end
	
	local function sortFunc(a,b)
		return a[5]<b[5]
	end
	local function BacktrackCharacterPath(contData, m1, f1, x1, y1, mTrans, m2, f2, x2, y2, ...)
		--DGV:DebugFormat("BacktrackCharacterPath", "args", {m1, f1, x1, y1, mTrans, m2, f2, x2, y2, ...})
		--DGV:DebugFormat("BacktrackCharacterPath", "args", {contData, m1, f1, x1, y1, mTrans, m2, f2, x2, y2, ...})
		--if not mTrans then
		--	local actualZoneId,actualFloor = CorrectMouseOverZoneFloor(m2, x2, y2)
		--	if actualZoneId then
		--		if actualZoneId and contData[actualZoneId] then
		--			return BacktrackCharacterPath(contData, m1, f1, x1, y1, nil, 
		--				actualZoneId, actualFloor, 
		--				DGV:TranslateWorldMapPosition(m2, f2, x2, y2, 
		--					actualZoneId, actualFloor))
		--		end
		--	end
		--	actualZoneId,actualFloor = CorrectMouseOverZoneFloor(m1, x1, y1)
		--	if actualZoneId and contData[actualZoneId] then
		--		x1,y1 = DGV:TranslateWorldMapPosition(m1, f1, x1, y1, 
		--			actualZoneId, actualFloor)
		--		return BacktrackCharacterPath(contData, actualZoneId, actualFloor, x1, y1, nil, 
		--			m2, f2, x2, y2)
		--	end
		--end
		--DGV:DebugFormat("BacktrackCharacterPath", "args", {m1, f1, x1, y1, mTrans, m2, f2, x2, y2, ...})
		if m1==m2 or mTrans==m2 then
			return m2, f2, x2, y2
		end
		if not mTrans then mTrans = m1 end
		if not contData then return end
		if not contData[mTrans] then return end
		
		--[[if contData[mTrans] and contData[mTrans][m2] then
			local fTrans,xTrans,yTrans = GetNearest(mTrans, contData[mTrans][m2])
			return mTrans,fTrans,xTrans,yTrans,m2,f2,x2,y2
		else]]
			--DGV:DebugFormat("backtrack TranslateWorldMapPosition", "args", {m2, f2, x2, y2, m1, f1})
			--local xDest,yDest  = DGV:TranslateWorldMapPosition(m2, f2, x2, y2, m1, f1)
			--DGV:DebugFormat("backtrack ClampLine", "args", {xDest,yDest,x1,y1})
			--xDest,yDest = DGV.Modules.Ants:ClampLine(xDest,yDest,x1,y1)
			--DGV:DebugFormat("backtrack", "mTrans", mTrans, "xDest", xDest, "yDest", yDest)
			local distTable = GetCreateTable()
			for mZone,data in pairs(contData[mTrans]) do
				local destinationFound = distTable[1] and distTable[1][1]==m2
				local requirements = contData[mZone] and contData[mZone].requirements
				if mZone~="requirements" and 
					(not requirements or 
					CheckRequirements(1, strsplit(":", requirements))) 
				then
					local contains = false
					for i=1,select("#",...) do --don't include traversed zones
						if mZone==select(i,...) then
							--DGV:DebugFormat("backtrack violation", "mZone", mZone, "data", data)
							contains = true
							break
						end
					end
					if mZone==m2 and not destinationFound then --if we find destination transitions, accept no others
						while(#(distTable) > 0) do
							PoolTable(tremove(distTable))
						end
					end
					if not contains and (mZone==m2 or not destinationFound) then
						tinsert(distTable, 
							GetCreateTable(mZone, 
							GetSmallestAngle(m1, f1, x1, y1, mTrans, data, m2, f2, x2, y2)))
					end
				end
			end
			if #(distTable)==0 then
				PoolTable(distTable)
				return
			end
			table.sort(distTable,sortFunc)
			--DGV:DebugFormat("backtrack", "distTable", distTable)
			--DGV:DebugFormat("BacktrackCharacterPath", "distTable", distTable)
			--DGV:DebugFormat("BacktrackCharacterPath loop", "distTable", distTable)
			
			local recursiveResult
			local resultF,resultX,resultY
			for _,dataTbl in ipairs(distTable) do
				recursiveResult = GetCreateTable(BacktrackCharacterPath(contData, 
					mTrans, dataTbl[2], dataTbl[3], dataTbl[4], 
					dataTbl[1], m2, f2, x2, y2, m1, ...))
				if #(recursiveResult)==0 then
					PoolTable(recursiveResult)
				else
					resultF,resultX,resultY = select(2,unpack(dataTbl))
					break
				end
			end
			--DGV:DebugFormat("BacktrackCharacterPath", "recursiveResult", recursiveResult, "resultY", resultY)
			
			for _,dataTbl in ipairs(distTable) do
				PoolTable(dataTbl)
			end
			PoolTable(distTable)
			if not resultY or #(recursiveResult)<4 then
				PoolTable(recursiveResult)
				return
			end
			--DGV:DebugFormat("BacktrackCharacterPath","mTrans", mTrans,"resultF",resultF,"resultX", resultX, "recursiveResult", recursiveResult)
			return mTrans,resultF,resultX,resultY,PoolTable(recursiveResult) 
		--end
	end

	local baseSpeed = 7
	local multTravelForm = 1.4
	local multCheetahGhostWolf = 1.3
	local multMountPathfinding1 = 1.05
	local multMountUpOaPH1MountPathfinding2 = 1.1
	local multNormLand = 1.6
	local multSwiftLand = 2
	local multNormFlying = 2.5
	local multEpicFlying = 3.8
	local multMasterFlying = 4.1
	local multFootPathfinding1 = 1.04
	local multFootPathfinding2 = 1.08
	local multPoJ1 = 1.08
	local multPoJ2 = 1.15
	local multCrusaderOaPH2 = 1.2
	local spellMountUp = 78633
	local spellApprenticeRiding = 33388
	local spellJourneymanRiding = 33391
	local spellExpertRiding = 34090
	local spellArtisanRiding = 34091
	local spellMasterRiding = 90265
	local spellFlightForm = 33943
	local spellSwiftFlightForm = 40120
	local spellTravelForm = 783
	local spellCheetah = 5118
	local spellGhostWolf = 2645
	local spellPathfinding1 = 19559
	local spellPathfinding2 = 19560
	local spellOaPH1 = 51983
	local spellOaPH2 = 51986
	local spellPoJ1 = 26022
	local spellPoJ2 = 26023
	local spellCrusader = 32223
	
	local orig_GetSpellBookItemInfo = GetSpellBookItemInfo
	local function GetSpellBookItemInfo(slot)
		if slot then
			return orig_GetSpellBookItemInfo(slot)
		end
	end
	local function GetFootBonusMultiplier()
		if GetSpellBookItemInfo(GetSpellInfo(spellTravelForm)) then
			return multTravelForm
		elseif GetSpellBookItemInfo(GetSpellInfo(spellCheetah)) or
			GetSpellBookItemInfo(GetSpellInfo(spellGhostWolf))
		then
			if GetSpellBookItemInfo(GetSpellInfo(spellPathfinding2)) then
				return multCheetahGhostWolf * multFootPathfinding2
			elseif GetSpellBookItemInfo(GetSpellInfo(spellPathfinding1)) then
				return multCheetahGhostWolf * multFootPathfinding1
			end
			return multCheetahGhostWolf
		elseif GetSpellBookItemInfo(GetSpellInfo(spellPoJ2)) then
			return multPoJ2
		elseif GetSpellBookItemInfo(GetSpellInfo(spellPoJ1)) then
			return multPoJ1
		end
		return 1
	end
	local function GetMountedBonusMultiplier()
		if GetSpellBookItemInfo(GetSpellInfo(spellCrusader)) or
			GetSpellBookItemInfo(GetSpellInfo(spellOaPH2))
		then
			return multCrusaderOaPH2
		elseif GetSpellBookItemInfo(GetSpellInfo(spellPoJ2)) then
			return multPoJ2
		elseif GetSpellBookItemInfo(GetSpellInfo(spellMountUp)) or
			GetSpellBookItemInfo(GetSpellInfo(spellOaPH1)) or
			GetSpellBookItemInfo(GetSpellInfo(spellPathfinding2))
		then
			return multMountUpOaPH1MountPathfinding2
		elseif GetSpellBookItemInfo(GetSpellInfo(spellPoJ1)) then
			return multPoJ1
		elseif GetSpellBookItemInfo(GetSpellInfo(spellPathfinding1)) then
			return multMountPathfinding1
		end
		return 1
	end
	local function GetFlightMultiplier()
		local flyingMult = 0
		if GetSpellBookItemInfo(GetSpellInfo(spellMasterRiding)) then
			flyingMult = multMasterFlying
		elseif
			GetSpellBookItemInfo(GetSpellInfo(spellArtisanRiding)) or
		        GetSpellBookItemInfo(GetSpellInfo(spellSwiftFlightForm))
		then
			flyingMult = multEpicFlying
		elseif GetSpellBookItemInfo(GetSpellInfo(spellExpertRiding)) or
			GetSpellBookItemInfo(GetSpellInfo(spellFlightForm))
		then
		             flyingMult = multNormFlying
		end
		return flyingMult * GetMountedBonusMultiplier()
	end
	local function GetLandMultiplier()
		local landMult = 0
		if GetSpellBookItemInfo(GetSpellInfo(spellJourneymanRiding)) then
			landMult = multSwiftLand
		elseif GetSpellBookItemInfo(GetSpellInfo(spellApprenticeRiding)) then
			landMult = multNormLand
		end
		return landMult * GetMountedBonusMultiplier()
	end

	local kalimdor = 1
	local easternKingdoms = 2
	local outland = 3
	local northrend = 4
	local theMaelstrom = 5
	local panderia = 6
	local groundedMaps = {499, 463, 462, 480, 476, 464, 471, 708, 709}
	local spellFlightMastersLicense = 90267
	local spellColdWeatherFlying = 54197
	local spellWisdomOfTheFourWinds = 115913
	function IsFlyableMapId(mapId)
		local result = true
		local c = DGV:GetCZByMapId(mapId)
		if (c==kalimdor or c==easternKingdoms or c==theMaelstrom) and not
			GetSpellBookItemInfo(GetSpellInfo(spellFlightMastersLicense))
		then result = false
		elseif c==northrend and not GetSpellBookItemInfo(GetSpellInfo(spellColdWeatherFlying))
		then result = false
		elseif c==panderia and not GetSpellBookItemInfo(GetSpellInfo(spellWisdomOfTheFourWinds))
		then result = false end
		if tContains(groundedMaps, mapId) then result=false end
		return result
	end
	
	local movementCache = {}
	local groundedCache = {}
	local function ResetMovementCache()
		wipe(movementCache)
		wipe(groundedCache)
	end
	
	local function SetMovementCharacteristics(mapId)
		if movementCache[mapId] then
			return movementCache[mapId], groundedCache[mapId]
		else
			local grounded = true
			local movementSpeed
			local flyingMult = GetFlightMultiplier()
			local landMult = GetLandMultiplier()
			if IsFlyableMapId(mapId) and flyingMult>0 then
				grounded = nil
				movementSpeed = baseSpeed * flyingMult
			elseif landMult>0 then
				movementSpeed = baseSpeed * landMult
			else
				movementSpeed = baseSpeed * GetFootBonusMultiplier()
			end
			movementCache[mapId] = movementSpeed
			groundedCache[mapId] = grounded
			return movementSpeed, grounded
		end
	end
	
	local function CharacterIter(invariant, control)
		if control then
			PoolTable(control)
			return
		end
		local best, parentRoute, m1, f1, x1, y1, m2, f2, x2, y2 = PoolTable(invariant)
		local c1,c2 = (DGV:GetCZByMapId(m1)), DGV:GetCZByMapId(m2)
		if c1==c2 then
			local route = RouteBuilders.Character:Build(
				best, parentRoute, c1, m1, f1, x1, y1, m2, f2, x2, y2)
			if route then
				return GetCreateTable(), route
			end
		end
	end
	
	function RouteBuilders.Character:Iterate(...)
		--DGV:DebugFormat("Character:Iterate", "f2", f2, "x2", x2, "y2", y2)
		return CharacterIter, GetCreateTable(...)
	end
	
	local checkRoute = {builder = RouteBuilders.Character}
	local function DirectRouteEvaluatesBest(best, parentRoute, ...)
		checkRoute.parentRoute = parentRoute
		checkRoute.currentBest = best
		checkRoute.grounded = false
		checkRoute.estimate = 0
		for i=1, select("#", ...), 2 do
			local distance = select(i, ...)
			local speed = select(i+1, ...)
			checkRoute.estimate = checkRoute.estimate + distance / speed
		end
		return IsBest(checkRoute) and (not parentRoute or IsBest(parentRoute, checkRoute))
	end
	
	function RouteBuilders.Character:Build(best, parentRoute, c, m1, f1, x1, y1, m2, f2, x2, y2)
		--DGV:DebugFormat("Character:Build", "x2", x2, "y2", y2)
		--DGV:DebugFormat("Character:Build", "m1", m1, "m2", m2, "stack", debugstack())
		local movementSpeed,grounded = SetMovementCharacteristics(m1)
		grounded = grounded or select(2,SetMovementCharacteristics(m2))
		--DGV:DebugFormat("Character:Build ComputeDistance", "args", {m1, f1 , x1, y1, m2, f2, x2, y2})
		local dist, dx, dy= DGV:ComputeDistance(m1, f1 , x1, y1, m2, f2, x2, y2)
		if not dist or not dx or not dy then
			return
		end
		
		local contData = (TaxiDataCollection.ZoneTransData or TaxiData.ZoneTransData)[c]
		
		if not DirectRouteEvaluatesBest(best, parentRoute, dist, movementSpeed) then
			return
		end --GetCreateRoute is expensive so do this first
		
		if grounded and not QuickPathExists(contData, m1, m2) then
			return
		end
		
		local route = GetCreateRoute(self, best, parentRoute)
		route.movementSpeed,route.grounded = movementSpeed,grounded
		tinsertList(route, c, m1, f1 or 0, x1, y1, m2, f2 or 0, x2, y2)
		route.distance = dist
		
		return route
	end
	
	local function SumDistances(...)
		local sum, lastM, lastF, lastX, lastY = 0
		for i=1,select("#", ...),4 do
			local m,f,x,y = select(i, ...)
			if lastY then
				sum = sum + DGV:ComputeDistance(m, f, x, y, lastM, lastF, lastX, lastY)
			end
			lastM,lastF,lastX,lastY = m,f,x,y
		end
		return sum
	end

	function RouteBuilders.Character:Estimate(route)
		if route.estimate then return route.estimate end
		
		if route.grounded then
			local contData = (TaxiDataCollection.ZoneTransData or TaxiData.ZoneTransData)[route[1]]
			local _, m1, f1, x1, y1 = unpack(route)
			route.estimate = SumDistances(m1, f1, x1, y1,
					BacktrackCharacterPath(contData, 
						m1, f1, x1, y1, nil, select(6, unpack(route))))
				/route.movementSpeed
		else
			route.estimate = route.distance / route.movementSpeed
		end
		return route.estimate
	end
	
	local function AddCharacterPoints(description, ...)
		local point
		for i=1,select("#", ...),4 do
			local m,f,x,y = select(i, ...)
			point = DGV:AddRouteWaypoint(m, f, x, y, description)
		end
		return point
	end

	function RouteBuilders.Character:AddWaypoint(route, description)
		local contData = (TaxiDataCollection.ZoneTransData or TaxiData.ZoneTransData)[route[1]]
		if route.grounded then
			local _, m1, f1, x1, y1 = unpack(route)
			return AddCharacterPoints(description,
					BacktrackCharacterPath(contData, 
						m1, f1, x1, y1, nil, select(6, unpack(route))))
		else
			return AddCharacterPoints(description, select(6, unpack(route)))
		end
	end
	
	local baseMultFlightMaster = 4.33
	local spellRideLikeTheWind = 117983
	local multRideLikeTheWind = 1.25
	local function GetFlightPathMultiplier()
		local flyingMult = baseMultFlightMaster
		if GetSpellBookItemInfo(GetSpellInfo(spellRideLikeTheWind)) then
			flyingMult = flyingMult * multRideLikeTheWind
		end
		return flyingMult
	end

	function RouteBuilders.FlightHop:Build(continent, npc1, npc2)
		local fullData = TaxiData:GetFullData()
		local npcTbl1, npcTbl2 = fullData[continent][npc1], fullData[continent][npc2]
		local npc1x,npc1y = DGV:UnpackXY(npcTbl1.coord)
		local npc2x,npc2y = DGV:UnpackXY(npcTbl2.coord)
		local dist, dx, dy= DGV:ComputeDistance(
			npcTbl1.m, npcTbl1.f , npc1x, npc1y,
			npcTbl2.m, npcTbl2.f , npc2x, npc2y)
		if not dist or not dx or not dy then
			return
		end
		local route = GetCreateRoute(self)
		route.x2, route.y2, route.m2, route.f2 = npc2x, npc2y, npcTbl2.m, npcTbl2.f
		route.distance = dist
		route.builder = self
		route.movementSpeed = GetFlightPathMultiplier()*baseSpeed
		route.npc2 = npc2
		return route
	end

	function RouteBuilders.FlightHop:Estimate(route)
		if route.estimate then return route.estimate end
		route.estimate = route.distance/route.movementSpeed
		return route.estimate
	end

	function RouteBuilders.FlightHop:AddWaypoint(route, description)
		description = L["Fly to"].." "..description
		return DGV:AddRouteWaypoint(
			route.m2, route.f2, route.x2, route.y2, description)
	end
	
	local function tInsort(t, num)
		for i=1,#(t)+1 do
			if not t[i] or num<t[i] then
				tinsert(t, i, num)
				return
			end
		end
	end
	
	local function GetDistances(m, f, x, y, routes)
		local distances,npcLookup = GetCreateTable(), GetCreateTable()
		for id, data in pairs(routes) do
			if data.m then
				local dist = DGV:ComputeDistance(m, f, x, y, 
					data.m, data.f, DGV:UnpackXY(data.coord))
				if not dist then
					DGV:DebugFormat("GetDistances not dist", "m", m, "data.m", data.m)
				else
					npcLookup[dist] = id
					tInsort(distances, dist)
				end
			end
		end
		return distances, npcLookup
	end
	
	--[[local function OrderedPairIter(control, t)
		local lastKey
		local lastValue
		while true do
			local nextKey
			local lastValue = lastKey and t[lastKey]
			for k,v in pairs(t) do
				if not lastKey or k~=lastKey then
					if (not lastValue or v>=lastValue) and 
						(not nextKey or v<=t[nextKey]) 
					then
						nextKey = k
					end
				end
			end
			if nextKey then
				_, lastKey = coroutine.yield(nextKey, t[nextKey])
			else return end
		end
	end
	
	local function IterateOrderedDictionary(t)
		return CoroutineIterator(OrderedPairIter, t)
	end]]
	
	local function nextOrderedPair(t, lastKey)
		local nextKey
		local lastValue = lastKey and t[lastKey]
		for k,v in pairs(t) do
			if not lastKey or k~=lastKey then
				if (not lastValue or v>=lastValue) and (not nextKey or v<=t[nextKey]) then
					nextKey = k
				end
			end
		end
		return nextKey, nextKey and t[nextKey]
	end
	
	local function IterateOrderedDictionary(t)
		return nextOrderedPair, t
	end
	
	local function ValidatePath(c, isRoot, ...)
		local fullData = TaxiData:GetFullData()
		for i=1,select("#",...) do
			local id = tonumber((select(i,...)))
			--	DGV:DebugFormat("ValidatePath", "id", id, "DugisFlightmasterDataTable[c]~=nil", DugisFlightmasterDataTable[c]~=nil, "(select(i,...))", (select(i,...)))
			if not id or
				not fullData[c] or
				not fullData[c][id]
			then
				return
			end
			
			local DugisArrow = DGV.Modules.DugisArrow
			local cPlayer = DGV:GetCZByMapId(DGV.Modules.DugisArrow.map)
			if (not DugisFlightmasterDataTable or
				not DugisFlightmasterDataTable[c]) and
				(cPlayer==c or isRoot) 
			then return true end
			if not DugisFlightmasterDataTable or
				not DugisFlightmasterDataTable[c] or
				not DugisFlightmasterDataTable[c][id]
			then
				return
			end
		end
		return true
	end
	
	local allowHeadCandidates = 3
	local allowTailCandidates = 3
	local countFmIters = 0
	local function FlightMasterRouteBuildIterator(invariant, t)
		local best, parentRoute, c, m1, f1, x1, y1, m2, f2, x2, y2 = unpack(invariant, 1, invariant.n)
		if not t or not t[c] then return end
		
		local route
		--for i=1,100 do
-- 		if not best and (not parentRoute or not parentRoute.currentBest) then
  			--countFmIters = countFmIters+1
  			--DGV:DebugFormat("FlightMasterRouteBuildIterator", "countFmIters", countFmIters)
--  		end
		
		local isRoot = not parentRoute
		local fullData = TaxiData:GetFullData()
		local headDistances,headNPCs = GetDistances(m1, f1, x1, y1, t[c])
		local tailDistances,tailNPCs = GetDistances(m2, f2, x2, y2, t[c])
		--if false then
		local lastAllowedHead
		local allowedHeads = 0
		local head, tail
		local tailRoutes = GetCreateTable()
		local flightSpeed = GetFlightPathMultiplier()*baseSpeed
		for i=1,#headDistances do
			local startDist = headDistances[i]
			if allowedHeads>=allowHeadCandidates then
				break 
			end
			
			if head then 
				PoolRoute(head)
				head = nil
				tail = nil
			end
			local startId = headNPCs[startDist]
			if ValidatePath(c, isRoot, startId) then
				if lastAllowedHead~=startId then
					lastAllowedHead = startId
					allowedHeads = allowedHeads + 1
				end
				
				if DirectRouteEvaluatesBest(best, parentRoute, startDist, flightSpeed) then
					local data = t[c][startId]
					local lastAllowedTail
					local allowedTails = 0
					for j=1,#tailDistances do
						local endDist = tailDistances[j]
						if allowedTails>=allowTailCandidates then
							allowedTails = 0
							break
						end
						
						local endId = tailNPCs[endDist]
						if ValidatePath(c, isRoot, startId, endId) then
							if lastAllowedTail~=endId then
								lastAllowedTail = endId
								allowedTails = allowedTails + 1
							end
							
							local directMatch = data.direct and
									(strmatch(data.direct, format(":%d",endId)) or 
									strmatch(data.direct, format("%d:",endId)) or
									tonumber(data.direct)==endId)
							local hopTable
							if directMatch then
								hopTable = GetCreateTable(endId)
							else
								for _, hops in ipairs(data) do
									local hopMatch = strmatch(hops, format(":%d$",endId))
									if hopMatch then
										hopTable = GetCreateTable(strsplit(":", hops))
										if not ValidatePath(c, isRoot, startId, unpack(hopTable)) then
											PoolTable(hopTable)
											hopTable = nil
										end
										break
									end
								end
							end
							if hopTable then
								tail = tailRoutes[endId]
								if not tail or (not head and tail~="nilTail") then
									local mStart,fStart,xStart,yStart,
										mEnd,fEnd,xEnd,yEnd
									
									if head then
										mStart,fStart,xStart,yStart = unpack(head,6)
	-- 									if not mStart then
	-- 										DGV:DebugFormat("FlightMasterRouteBuildIterator", "head[6]", head[6], "head in pool", tContains(routePool, head))
	-- 									end
									else
										local npcTbl = fullData[c][startId]
										local npcx,npcy = DGV:UnpackXY(npcTbl.coord)
										mStart,fStart,xStart,yStart = npcTbl.m, npcTbl.f, npcx, npcy
									end
									
									if tail then
										mEnd,fEnd,xEnd,yEnd = unpack(tail,2)
									else
										local npcTbl = fullData[c][endId]
										local npcx,npcy = DGV:UnpackXY(npcTbl.coord)
										mEnd,fEnd,xEnd,yEnd = npcTbl.m, npcTbl.f, npcx, npcy
									end
									
									local abDist = DGV:ComputeDistance(
										mStart,fStart,xStart,yStart, 
										mEnd,fEnd,xEnd,yEnd)
	-- 								DGV:DebugFormat("FlightMasterRouteBuildIterator", "mStart", mStart, "mEnd", mEnd)
									if DirectRouteEvaluatesBest(best, parentRoute, 
										startDist, (SetMovementCharacteristics(mStart)),
										endDist, (SetMovementCharacteristics(mEnd)),
										abDist, flightSpeed)
									then
										if not head then
											head = RouteBuilders.Character:Build(best, nil, c, 
												m1, f1, x1, y1, 
												mStart,fStart,xStart,yStart)
										end
									
										if not tail then
											tail = RouteBuilders.Character:Build(
												best, nil, c, 
												mEnd,fEnd,xEnd,yEnd, 
												m2, f2, x2, y2)
										end
									end
								end
								if not tail then
									tailRoutes[endId] = "nilTail"
								else
									tailRoutes[endId] = tail
								end
								--DGV:DebugFormat("FlightMasterRouteBuildIterator", "tailRoutes", tailRoutes)
								--return
								if tail=="nilTail" then
									tail = nil
								end
								if not head then
									PoolTable(hopTable)
									break 
								end
								if tail then
									route = RouteBuilders.FlightMaster:Build(
										best, parentRoute, c, m1, f1, x1, y1, 
										m2, f2, x2, y2,
										head, tail, startId, unpack(hopTable))
									if route then
										--PoolRoute(route)
										--route = nil
										allowedHeads = allowHeadCandidates
										allowedTails = allowTailCandidates
										PoolTable(hopTable)
										break
									end
								end
								PoolTable(hopTable)
							end
						end
					end
				end
			end
		end
		if head and not head.parentRoute then PoolRoute(head) end
		--if tail then PoolRoute(tail) end
		for _,tr in pairs(tailRoutes) do
			if tr~="nilTail" and not tr.parentRoute then
				PoolRoute(tr)
			end
		end
		PoolTable(tailRoutes)
		--end
		PoolTable(headDistances)
		PoolTable(headNPCs)
		PoolTable(tailDistances)
		PoolTable(tailNPCs)
		--end
		return route
	end
		
	local function FlightMasterIter(invariant, control)
		if not control then
			control = GetCreateTable()
			control[1] = 1
			local route = FlightMasterRouteBuildIterator(invariant, TaxiData:GetFullData())
			if route then
				return control, route
			end
		end
		if control[1] == 1 then
			control[1] = 2
			local route = FlightMasterRouteBuildIterator(invariant, DugisFlightmasterDataTable)
			if route then
				return control, route
			end
		end
		PoolTable(invariant)
		PoolTable(control)
	end
	
	function RouteBuilders.FlightMaster:Iterate(best, parentRoute, m1, f1, x1, y1, m2, f2, x2, y2)
		local c = DGV:GetCZByMapId(m1)
		local c2 = DGV:GetCZByMapId(m2)
		if c~=c2 then return DGV.NoOp end
		
		--Quick Failure Opportunity: best is better than a direct flight betweeen points
		local dist, dx, dy= DGV:ComputeDistance(m1, f1 , x1, y1, m2, f2 , x2, y2)
		if not dist or not dx or not dy then
			return DGV.NoOp
		end
		local flightSpeed = GetFlightPathMultiplier()*baseSpeed
		if not DirectRouteEvaluatesBest(
			best, parentRoute, dist, flightSpeed)
		then
			return DGV.NoOp
		end
		
		
		return FlightMasterIter, GetCreateTable(best, parentRoute, c, m1, f1, x1, y1, m2, f2, x2, y2)
	end

	function RouteBuilders.FlightMaster:Build(best, parentRoute, c, m1, f1, x1, y1, m2, f2, x2, y2, head, tail, ...)
		--DGV:DebugFormat("FlightMaster:Build", "hasBest", best~=nil)
		--DGV:DebugFormat("FlightMaster:Build", "c", c)
		if not ValidatePath(c, not parentRoute, ...) then return end
		--DGV:DebugFormat("FlightMaster:Build", "#(routes)", #(routes))
		local fullData = TaxiData:GetFullData()
		local headId = tonumber((select(1,...)))
		
		local route = GetCreateRoute(self, best, parentRoute)
		route.headId = headId
		tinsert(route, head)
		--DGV:DebugFormat("FlightMaster:Build add head")

		route.tailId = tonumber(select(select("#",...), ...))
		npcTbl = fullData[c][route.tailId]
		tinsert(route, tail)
		--DGV:DebugFormat("FlightMaster:Build add tail")
		route.tailMap = npcTbl.m
		--DGV:DebugFormat("FlightMaster:Build", "tail", tail, "best", best)
		
		for i=2,select("#",...) do
			--DGV:DebugFormat("FlightMaster:Build add mid")
			local lastId = tonumber((select(i-1,...)))
			local id = tonumber((select(i,...)))
			local hop = RouteBuilders.FlightHop:Build(c, lastId, id)
			if hop then
				--DGV:DebugFormat("FlightMaster:Build add mid")
				hop.parentRoute = route
				tinsert(route, #(route), hop)
				route.estimate = nil
			end
			if not hop and IsBest(route) then
				PoolRoute(route)
				--DGV:DebugFormat("FlightMaster:Build mid end", "#(routes)", #(routes))
				return
			end
		end
		--DGV:DebugFormat("FlightMaster:Build success", "#(routes)", #(routes), "#(route)", #(route))
-- 		if true then
-- 			PoolRoute(route)
-- 			return
-- 		end
		head.parentRoute = route
		tail.parentRoute = route
		route.m2, route.f2, route.x2, route.y2, route.c = m2, f2, x2, y2, c
		return route
	end

	function RouteBuilders.FlightMaster:Estimate(route)
		if route.estimate then return route.estimate end
		local estimate = 0
		for _, subRoute in ipairs(route) do
			estimate = estimate + subRoute.builder:Estimate(subRoute)
		end
		route.estimate = estimate
		return estimate
	end

	function RouteBuilders.FlightMaster:AddWaypoint(route, description)
		local headRoute = route[1]
		if not DugisFlightmasterDataTable or 
			not DugisFlightmasterDataTable[route.c] 
		then
			local chDesc = format(L["Talk to %s to get flight master data."], 
				DGV:GetFlightMasterName(route.headId))
			local point = headRoute.builder:AddWaypoint(headRoute, chDesc)
			point.flightMasterID = route.headId
			local routeToRecalculate = DGV.Modules.TaxiDB.routeToRecalculate
			routeToRecalculate.m = route.m2
			routeToRecalculate.f = route.f2
			routeToRecalculate.x = route.x2
			routeToRecalculate.y = route.y2
			routeToRecalculate.c = route.c
			routeToRecalculate.desc = description
			return
		end
		
		local mapName = DGV:GetMapNameFromID(route.tailMap)
		local chDesc = format(L["Talk to %s and fly to %s"], 
			DGV:GetFlightMasterName(route.headId), mapName)
		headRoute.builder:AddWaypoint(headRoute, chDesc)
		local lastHopRoute = route[#(route)-1]
		local headRouteWaypoint = headRoute.builder:AddWaypoint(headRoute, chDesc)
		headRouteWaypoint.flightMasterID = route.tailId
		lastHopRoute.builder:AddWaypoint(lastHopRoute, string.format("%s, %s",
				DGV:GetFlightMasterName(route.tailId), mapName))
		local tailRoute = route[#(route)]
		return tailRoute.builder:AddWaypoint(tailRoute, description)
	end

	local function IterateInkeepers(invariant, control)
		local maps = DugisWorldMapTrackingPoints[UnitFactionGroup("player")]
		if not control then
			control = GetCreateTable()
		end
		for mapKey, mapValue in pairs(maps) do
			local m,f = strsplit(":",mapKey)
			for index=1,#(mapValue) do
				local tt,loc,id,sub = strsplit(":", mapValue[index])
				if tonumber(tt)==7 then
					_, control = coroutine.yield(control, tonumber(DGV:GetMapIDFromName(m)), tonumber(f), tonumber(loc), tonumber(id), sub)
				end
			end
		end
		PoolTable(control)
	end

	local cachedBindLocation = {}
	function DGV:CONFIRM_BINDER()
		wipe(cachedBindLocation)
	end
	
	local function GetUsefulBindLocation()
		if cachedBindLocation.m then
			return 
				cachedBindLocation.m, 
				cachedBindLocation.f, 
				cachedBindLocation.x, 
				cachedBindLocation.y
		end
		local rm,rf,rx,ry
		local bindLocation = GetBindLocation()
		for _, m,f,loc,id,sub in CoroutineIterator(IterateInkeepers) do
			if not rm and sub==BR[bindLocation] then
				local x,y = DGV:UnpackXY(loc)
				cachedBindLocation.m = m
				cachedBindLocation.f = f
				cachedBindLocation.x = x
				cachedBindLocation.y = y
				rm,rf,rx,ry = m,f,x,y --do not short circuit CoroutineIterator
			end
		end
		return rm,rf,rx,ry
	end
	
	local function GetUsableItem(itemId)
		return GetItemCount(itemId)~=0 and
			GetItemCooldown(itemId)==0 and
			itemId
	end
	
	local function BoundTeleportIter(invariant, control)
		if control then
			PoolTable(control)
			return 
		end
		local best, parentRoute, m1, f1, x1, y1, m2, f2, x2, y2 = PoolTable(invariant)
		local route = RouteBuilders.BoundTeleport:Build(
			best, parentRoute, m1, f1, x1, y1, m2, f2, x2, y2)
		if route then
			return route, route
		end
	end
	
	function RouteBuilders.BoundTeleport:Iterate(...)
		return BoundTeleportIter, GetCreateTable(...)
	end

	local itemHearthstone = 6948
	local itemSoR1 = 37118
	local itemSoR2 = 44314
	local itemSoR3 = 44315
	local itemInnkeepersDaughter = 64488
	local itemRubySlippers = 28585
	local itemEtherealPortal = 54452
	local spellAstralRecall = 556
	function RouteBuilders.BoundTeleport:Build(best, parentRoute, m1, f1, x1, y1, m2, f2, x2, y2)
		--DGV:DebugFormat("BoundTeleport:Build", "m1", m1, "f1", f1,"x1", x1, "y1", y1, "m2", m2, "f2", f2, "x2",  x2, "y2", y2)
		local mBound,fBound,xBound,yBound = GetUsefulBindLocation()
		if not mBound then return end
		local route = GetCreateRoute(self, best, parentRoute)
		route.builder = self
		route.m, route.f, route.x, route.y = mBound,fBound,xBound,yBound
		if 
			GetSpellBookItemInfo(GetSpellInfo(spellAstralRecall)) and
			GetSpellCooldown(spellAstralRecall)==0
		then
			route.spell = spellAstralRecall
		else
			route.item = GetUsableItem(itemInnkeepersDaughter) or
					GetUsableItem(itemEtherealPortal) or
					GetUsableItem(itemHearthstone) or
					(UnitLevel("player") <= 40 and GetUsableItem(itemSoR1)) or
					(UnitLevel("player") <= 70 and GetUsableItem(itemSoR2)) or
					(UnitLevel("player") <= 80 and GetUsableItem(itemSoR3))
		end
		if not route.spell and not route.item then
			PoolRoute(route)
			return
		end
		route.tail = Taxi:GetBestRoute(route,
				mBound,fBound,xBound,yBound, m2, f2, x2, y2, 
				RouteBuilders.UnboundTeleport,
				RouteBuilders.BoundTeleport,
				RouteBuilders.ZenPilgrimageReturn,
				RouteBuilders.StaticPortals,
				RouteBuilders.Boats)
		if not route.tail then
			PoolRoute(route)
			return
		else
			tinsert(route, route.tail)
		end
		return route
	end
	
	local hearthCast = 10
	local innkeepersDaughterCast = 3
	local loadConstant = 15
	local penaltyConstant = 20
	function RouteBuilders.BoundTeleport:Estimate(route)
		local cast = (route.item == itemInnkeepersDaughter and innkeepersDaughterCast) or 
			hearthCast
		local tailEst = (route.tail and route.tail.builder:Estimate(route.tail)) or 0
		return tailEst + cast + loadConstant + penaltyConstant
	end

	function RouteBuilders.BoundTeleport:AddWaypoint(route, description)
		local descriptionHead = L["Hearth to"]
		if route.item then
			if route.item~=itemHearthstone then
				descriptionHead = L["Use"].." "..select(2, GetItemInfo(route.item))
			end
			DGV:AddRouteWaypointWithItem(
				route.m, route.f, route.x, route.y, 
				descriptionHead.." "..GetBindLocation(),
				route.item)
		elseif route.spell then
			descriptionHead = L["Use"].." "..(GetSpellLink(route.spell))
			DGV:AddRouteWaypointWithSpell(
				route.m, route.f, route.x, route.y, 
				descriptionHead.." "..GetBindLocation(),
				route.spell)
		end
		return route.tail.builder:AddWaypoint(route.tail, description)
	end
	
	local function UnboundTeleportIter(control, prevBest, parentRoute, m1, f1, x1, y1, m2, f2, x2, y2)
		local c2 = DGV:GetCZByMapId(m2)
		if not control then
			control = GetCreateTable()
		end
		control.best = prevBest
		for teleport,data in pairs(TaxiData.UnboundTeleportData[c2]) do
			local telBuild = RouteBuilders.UnboundTeleport:Build(
				control.best, parentRoute,
				m1, f1, x1, y1, m2, f2, x2, y2, teleport, data)
			if telBuild then
				_, control = coroutine.yield(control, telBuild)
			end
		end
		PoolTable(control)
	end
	
	function RouteBuilders.UnboundTeleport:Iterate(...)
		return CoroutineIterator(UnboundTeleportIter, ...)
	end
		
	function RouteBuilders.UnboundTeleport:Build(best, parentRoute, m1, f1, x1, y1, m2, f2, x2, y2, portId, data)
		local spellIdString,mapIdString,floorString,locString = CheckRequirements(5, strsplit(":", data))
		if not locString then return end
		local mPort,fPort,xPort,yPort = tonumber(mapIdString), tonumber(floorString), 
			DGV:UnpackXY(locString)
		
		local route = GetCreateRoute(self, best, parentRoute)
		route.builder = self
		route.m, route.f, route.x, route.y = mPort,fPort,xPort,yPort
		local spellId = tonumber(spellIdString)
		if portId==spellId then
			if not GetSpellBookItemInfo(GetSpellInfo(portId)) or GetSpellCooldown(portId)~=0 then
				PoolRoute(route)
				return
			end
			route.spell = portId
		else
			if GetItemCount(portId)==0 or GetItemCooldown(portId)~=0 then
				PoolRoute(route)
				return
			end
			route.item = portId
		end
		
		route.tail = Taxi:GetBestRoute(route,
			mPort,fPort,xPort,yPort, m2, f2, x2, y2, 
			RouteBuilders.UnboundTeleport,
			RouteBuilders.BoundTeleport,
			RouteBuilders.ZenPilgrimageReturn,
			RouteBuilders.StaticPortals,
			RouteBuilders.Boats)
		if not route.tail then
			PoolRoute(route)
			return
		else
			tinsert(route, route.tail)
		end
		return route
	end
	
	function RouteBuilders.UnboundTeleport:Estimate(route)
		--DGV:DebugFormat("UnboundTeleport:Estimate ORG", "route.spell", route.spell)
		local est = route.estimate
		if not est then
			local tailEst = (route.tail and route.tail.builder:Estimate(route.tail)) or 0
			est = tailEst + 10 + loadConstant + penaltyConstant
			if tailEst~=0 then
				route.estimate = est
			end
		end
		return est
	end

	function RouteBuilders.UnboundTeleport:AddWaypoint(route, description)
		local useDescription
		if route.item then
			useDescription = L["Use"].." "..select(2, GetItemInfo(route.item))
			DGV:AddRouteWaypointWithItem(
				route.m, route.f, route.x, route.y, useDescription,
				route.item)
		elseif route.spell then
			useDescription = L["Use"].." "..(GetSpellLink(route.spell))
			DGV:AddRouteWaypointWithSpell(
				route.m, route.f, route.x, route.y, useDescription,
				route.spell)
		end
		return route.tail.builder:AddWaypoint(route.tail, description)
	end
	
	function DGV:UNIT_SPELLCAST_START(event, unit, spellName, spellRank, lineIdCounter, spellId)
		if unit=="player" and spellId==126892 then
			if not DugisGuideUser.ZenPilgrimageReturnPoint then DugisGuideUser.ZenPilgrimageReturnPoint = {} end
			pt = DugisGuideUser.ZenPilgrimageReturnPoint
			pt.m, pt.f, pt.x, pt.y = DGV:GetPlayerMapPositionDisruptive()
		end
	end
	
	local function ZenPilgrimageReturnIter(invariant, control)
		if control then
			PoolTable(control)
			return 
		end
		local best, parentRoute, m1, f1, x1, y1, m2, f2, x2, y2 = PoolTable(invariant)
		local route = RouteBuilders.ZenPilgrimageReturn:Build(
			best, parentRoute, m1, f1, x1, y1, m2, f2, x2, y2)
		if route then
			return route, route
		end
	end
	
	function RouteBuilders.ZenPilgrimageReturn:Iterate(...)
		return ZenPilgrimageReturnIter, GetCreateTable(...)
	end
	
	function RouteBuilders.ZenPilgrimageReturn:Build(best, parentRoute, m1, f1, x1, y1, m2, f2, x2, y2)
		if not UnitBuff("player", GetSpellInfo(126895)) 
			or not DugisGuideUser.ZenPilgrimageReturnPoint 
			or not DugisGuideUser.ZenPilgrimageReturnPoint.m 
		then return end
		
		local route = GetCreateRoute(self, best, parentRoute)
		route.builder = self
		local pt = DugisGuideUser.ZenPilgrimageReturnPoint
		route.m, route.f, route.x, route.y = pt.m, pt.f, pt.x, pt.y
		route.spell = 126895
		
		
		route.tail = Taxi:GetBestRoute(route,
			pt.m, pt.f, pt.x, pt.y, m2, f2, x2, y2, 
			RouteBuilders.UnboundTeleport,
			RouteBuilders.BoundTeleport,
			RouteBuilders.ZenPilgrimageReturn,
			RouteBuilders.StaticPortals,
			RouteBuilders.Boats)
		if not route.tail then
			PoolRoute(route)
			return
		else
			tinsert(route, route.tail)
		end
		return route
	end
	RouteBuilders.ZenPilgrimageReturn.Estimate = RouteBuilders.UnboundTeleport.Estimate
	RouteBuilders.ZenPilgrimageReturn.AddWaypoint = RouteBuilders.UnboundTeleport.AddWaypoint
		
	local routeStackLimit = 6
	local function CheckStackLoop(parentRoute, mPort, hop)
		if not hop then hop=1 end
	  --if(parentRoute) then
	  --DGV:DebugFormat("CheckStackLoop", "parentRoute", parentRoute~=nil, "mPort", mPort, "hop", hop, "parentRoute.mPort", parentRoute and parentRoute.mPort)
	  --end
		if hop>routeStackLimit then return true end
		if not parentRoute then return end
		if parentRoute.mPort==mPort then
			return true
		end
		if not parentRoute.parentRoute then return end
		return CheckStackLoop(parentRoute.parentRoute, mPort, hop+1)
	end
	
	local function ReturnAllParentRoutes(route)
		if not route.parentRoute then return end
		return route.parentRoute, ReturnAllParentRoutes(route.parentRoute)
	end
	
	local function StaticPortalIter(invariant, control)
		local dataTable, prevBest, parentRoute, c1, m1, f1, x1, y1, c2, m2, f2, x2, y2 = unpack(invariant, 1, invariant.n)
		control[1] = control[1] + 1
		local data = dataTable[c2] and dataTable[c2][control[1]]
		if not data or (control[2]==RouteBuilders.LocalPortals and c1~=c2) then
			PoolTable(invariant)
			PoolTable(control)
			return
		end
		local portBuild = control[2]:Build(
			control.best or prevBest, parentRoute, 
			m1, f1, x1, y1, c2, m2, f2, x2, y2, data)
		if portBuild then 
			return control, portBuild
			--PoolRoute(portBuild) end
		else
			return StaticPortalIter(invariant, control)
		end
	end
	
	function RouteBuilders.StaticPortals:Iterate(prevBest, parentRoute, m1, f1, x1, y1, m2, f2, x2, y2)
		--DGV:DebugFormat(self[1]..":Iterate")
		return StaticPortalIter, 
			GetCreateTable(
				(self==RouteBuilders.StaticPortals and TaxiData.StaticPortalData) or 
					TaxiData.LocalPortalData,
				prevBest, parentRoute, 
					(DGV:GetCZByMapId(m1)), m1, f1, x1, y1, 
					(DGV:GetCZByMapId(m2)), m2, f2, x2, y2), 
			GetCreateTable(0, self)
	end
	RouteBuilders.LocalPortals.Iterate = RouteBuilders.StaticPortals.Iterate
	
	function RouteBuilders.StaticPortals:Build(best, parentRoute, m1, f1, x1, y1, c2, m2, f2, x2, y2, data)
		local sourceMapIdString,sourceFloorString,sourceLocString,
			destMapIdString,destFloorString,destLocString = 
				CheckRequirements(7, strsplit(":", data))
		if not destLocString then return end
		
		local mPort = tonumber(destMapIdString)
		if CheckStackLoop(parentRoute, mPort) then return end
		
		local mSource,fSource,xSouce,ySource =
			tonumber(sourceMapIdString), tonumber(sourceFloorString),
			DGV:UnpackXY(sourceLocString)
			
		local cSource = DGV:GetCZByMapId(mSource)
		if self==RouteBuilders.StaticPortals and cSource==c2 then return end
		--DGV:DebugFormat(self[1]..":Build", "best", best~=nil)
			
		local fPort,xPort,yPort = 
			tonumber(destFloorString), 
			DGV:UnpackXY(destLocString)
			
		--if true then return end
		--local dist = DGV:ComputeDistance(mData, selectedF, selectedX, selectedY, mData, selectedF, xDest, yDest)
		
		local route = GetCreateRoute(self, best, parentRoute)
		route.builder = self
		route.mSource, route.fSource, route.xSouce, route.ySource,
			route.mPort, route.fPort, route.xPort, route.yPort = 
			mSource, fSource, xSouce, ySource,
			mPort, fPort, xPort, yPort
			
-- 		DGV:DebugFormat("StaticPortals:Build GetBestRoute", "mPort", mPort, "fPort", fPort, "route.mSource", route.mSource, "route.fSource", route.fSource)
-- 		if true then
-- 			PoolRoute(route)
-- 			return
-- 		end
--DGV:DebugFormat(self[1]..":Build")
		if self==RouteBuilders.LocalPortals then
			route.tail = Taxi:GetBestRoute(route,
				mPort,fPort,xPort,yPort, m2, f2, x2, y2,
				RouteBuilders.UnboundTeleport,
				RouteBuilders.BoundTeleport,
				RouteBuilders.ZenPilgrimageReturn,
				RouteBuilders.LocalPortals,
				RouteBuilders.StaticPortals,
				RouteBuilders.Boats)
		else
			route.tail = Taxi:GetBestRoute(route,
				mPort,fPort,xPort,yPort, m2, f2, x2, y2,
				RouteBuilders.UnboundTeleport,
				RouteBuilders.BoundTeleport,
				RouteBuilders.ZenPilgrimageReturn,
				RouteBuilders.StaticPortals,
				RouteBuilders.Boats)
		end

		if route.tail then
			tinsert(route, route.tail)
		end
		if not route.tail
			--(best and (best.builder:Estimate(best)<
			--route.tail.builder:Estimate(route.tail)+loadConstant))
			or not IsBest(route)
		then
			PoolRoute(route)
			return
		end
		
-- 		if true then
-- 			PoolRoute(route)
-- 			return
-- 		end
		--DGV:DebugFormat("StaticPortals:Build", "tail est", route.tail.builder:Estimate(route.tail), "best est", best.builder:Estimate(best))
		
		if self==RouteBuilders.LocalPortals then
			route.head = Taxi:GetBestRoute(route,
				m1, f1, x1, y1, mSource, fSource, xSouce, ySource,
				RouteBuilders.UnboundTeleport,
				RouteBuilders.BoundTeleport,
				RouteBuilders.ZenPilgrimageReturn,
				RouteBuilders.StaticPortals,
				RouteBuilders.Boats,
				RouteBuilders.LocalPortals)
		else
			route.head = Taxi:GetBestRoute(route,
				m1, f1, x1, y1, mSource, fSource, xSouce, ySource)
		end

		if not route.head then
			PoolRoute(route)
			return
		else
			tinsert(route, route.head)
		end
		
		return route
	end
	RouteBuilders.LocalPortals.Build = RouteBuilders.StaticPortals.Build
	
	function RouteBuilders.StaticPortals:Estimate(route)
		local est = route.estimate
		if not est then
			local headEst = (route.head and route.head.builder:Estimate(route.head)) or 0
			local tailEst = (route.tail and route.tail.builder:Estimate(route.tail)) or 0
			est = headEst + tailEst + loadConstant
			if headEst~=0 and tailEst~=0 then
				route.estimate = est
			end
		end
		return est
	end
	RouteBuilders.LocalPortals.Estimate = RouteBuilders.StaticPortals.Estimate
	
	function RouteBuilders.StaticPortals:AddWaypoint(route, description)
		local portDesc = string.format(
			L["The %s Portal in %s"], 
			DGV:GetMapNameFromID(route.mPort),
			DGV:GetMapNameFromID(route.mSource))
		route.head.builder:AddWaypoint(route.head, portDesc)
		
		DGV:AddRouteWaypointWithDestinationTrigger(route.mSource, route.fSource,
			route.xSouce, route.ySource,
			L["Use"].." "..portDesc, route.mPort)
		return route.tail.builder:AddWaypoint(route.tail, description)
	end
	RouteBuilders.LocalPortals.AddWaypoint = RouteBuilders.StaticPortals.AddWaypoint
	
-- 	function TestCallPortals(...)
-- 		local best
-- 		local tbl1 = GetCreateTable(...)
-- 		for r1 in RouteBuilders.StaticPortals:Iterate(nil, nil, 464, 0, .42, .63, 30, 0, .42, .63) do
-- 			local tbl2 = GetCreateTable(...)
-- 			for r2 in RouteBuilders.StaticPortals:Iterate(nil, nil, 464, 0, .42, .63, 30, 0, .42, .63) do
-- 				local tbl3 = GetCreateTable(...)
-- 				for r3 in RouteBuilders.StaticPortals:Iterate(nil, nil, 464, 0, .42, .63, 30, 0, .42, .63) do
-- 					local tbl4 = GetCreateTable(...)
-- 					for r4 in RouteBuilders.StaticPortals:Iterate(nil, nil, 464, 0, .42, .63, 30, 0, .42, .63) do
-- -- 						type(r4)
-- -- 						r4.currentBest = best
-- -- 						if not best then best = route
-- -- 						elseif IsBest(r4) then
-- -- 							PoolRoute(best)
-- -- 							best = r4
-- -- 						else
-- -- 							PoolRoute(r4)
-- -- 						end
-- 						PoolRoute(r4)
-- 					end
-- -- 					type(r3)
-- -- 					r3.currentBest = best
-- -- 					if not best then best = route
-- -- 					elseif IsBest(r3) then
-- -- 						PoolRoute(best)
-- -- 						best = r3
-- -- 					else
-- -- 						PoolRoute(r3)
-- -- 					end
-- 					PoolRoute(r3)
-- 					PoolTable(tbl4)
-- 				end
-- 				PoolRoute(r2)
-- 				PoolTable(tbl3)
-- 			end
-- 			PoolRoute(r1)
-- 			PoolTable(tbl2)
-- 		end
-- 		PoolTable(tbl1)
-- 	end
	
-- 	function TestGBR()
-- 		Taxi:GetBestRoute(nil, 464, 0, .42, .63, 30, 0, .42, .63)
-- 	end
	
	local function BoatIter(invariant, control)
		local prevBest, parentRoute, c1, m1, f1, x1, y1, c2, m2, f2, x2, y2 = 
			unpack(invariant, 1, invariant.n)
		control[1] = control[1]+1
		local data = TaxiData.BoatData[c2][control[1]]
		local continentZoom = control[2]
		
		if not data then
			if continentZoom==0 then
				control[1] = 0
				control[2] = 1
				return BoatIter(invariant, control)
			else
				PoolTable(invariant)
				PoolTable(control)
				return
			end
		end
		
		local sourceMapId = tonumber(strmatch(data, "^%d:"))
		local cSource = DGV:GetCZByMapId(sourceMapId)
		if (continentZoom==0 and cSource==c1) or (continentZoom==1 and cSource~=c1) then
			local portBuild = RouteBuilders.Boats:Build(
				control.best or prevBest, parentRoute, 
				c1, m1, f1, x1, y1, m2, f2, x2, y2, data)
			if portBuild then
				return control, portBuild
			end
		end
		return BoatIter(invariant, control)
	end
	
	function RouteBuilders.Boats:Iterate(prevBest, parentRoute, m1, f1, x1, y1, m2, f2, x2, y2)
		local c1,c2 = DGV:GetCZByMapId(m1), DGV:GetCZByMapId(m2)
		if c1==0 or c2==0 then return DGV.NoOp end
		return BoatIter, 
			GetCreateTable(prevBest, parentRoute, c1, m1, f1, x1, y1, c2, m2, f2, x2, y2),
			GetCreateTable(0, 0)
	end
	
	function RouteBuilders.Boats:Build(best, parentRoute, c1, m1, f1, x1, y1, m2, f2, x2, y2, data)
		local sourceMapIdString,sourceFloorString,sourceLocString,
			destMapIdString,destFloorString,destLocString,waitString,engVehicle = 
			CheckRequirements(9, strsplit(":", data))
		if not engVehicle then return end
		
		local mPort = tonumber(destMapIdString)
		--if CheckStackLoop(parentRoute, mPort) then return end
		
		local mSource,fSource,xSouce,ySource =
			tonumber(sourceMapIdString), tonumber(sourceFloorString),
			DGV:UnpackXY(sourceLocString)
		local cSource =  DGV:GetCZByMapId(mSource)
		if cSource==DGV:GetCZByMapId(mPort) and (cSource~=c1 or cSource~=DGV:GetCZByMapId(m2)) then return end
		--if cSource~=c1 then return end
		local fPort,xPort,yPort = 
			tonumber(destFloorString), 
			DGV:UnpackXY(destLocString)
		
-- 		if best then
-- 			local bestEst = (parentRoute and 
-- 						parentRoute.currentBest and 
-- 						parentRoute.currentBest.builder:Estimate(parentRoute.currentBest)) or 0
-- 			bestEst = bestEst + best.builder:Estimate(best)
-- 			local est = (parentRoute and
-- 					parentRoute.builder:Estimate(parentRoute)) or 0
-- 			est = est + tonumber(waitString)
-- 			if best and bestEst < est then return end
-- 		end
		
		if CheckStackLoop(parentRoute, mPort) then return end
		
		local route = GetCreateRoute(self, best, parentRoute)
		route.builder = self
		route.engVehicle = engVehicle
		route.wait = tonumber(waitString)
		route.mSource, route.fSource, route.xSouce, route.ySource,
			route.mPort, route.fPort, route.xPort, route.yPort = 
			mSource, fSource, xSouce, ySource,
			mPort, fPort, xPort, yPort
			
		if not IsBest(route) then
			--DGV:DebugFormat("Boats:Build eliminated")
			PoolRoute(route)
			return
		end
			
		route.tail = Taxi:GetBestRoute(route,
			mPort,fPort,xPort,yPort, m2, f2, x2, y2,
			RouteBuilders.UnboundTeleport,
			RouteBuilders.BoundTeleport,
			RouteBuilders.ZenPilgrimageReturn,
			RouteBuilders.StaticPortals,
			RouteBuilders.Boats)
		if route.tail then
			tinsert(route, route.tail)
		end
		if not route.tail
			or not IsBest(route)
		then
			PoolRoute(route)
			return
		end

		route.head = Taxi:GetBestRoute(route,
			m1, f1, x1, y1, mSource, fSource, xSouce, ySource)
		if not route.head then
			PoolRoute(route)
			return
		else
			tinsert(route, route.head)
		end
		
		return route
	end
	
	function RouteBuilders.Boats:Estimate(route)
		local est = route.estimate
		if not est then
			local headEst = (route.head and route.head.builder:Estimate(route.head)) or 0
			local tailEst = (route.tail and route.tail.builder:Estimate(route.tail)) or 0
			est = headEst + tailEst + route.wait
			if headEst~=0 and tailEst~=0 then
				route.estimate = est
			end
		end
		return est
	end

	function RouteBuilders.Boats:AddWaypoint(route, description)
		local locVehicle = L[route.engVehicle]
		local boatDesc = string.format(
			L["The %s %s in %s"], 
			DGV:GetMapNameFromID(route.mPort),
			locVehicle,
			DGV:GetMapNameFromID(route.mSource))
		route.head.builder:AddWaypoint(route.head, boatDesc)
		
		DGV:AddRouteWaypointWithDestinationTrigger(route.mSource, route.fSource,
			route.xSouce, route.ySource, 
			L["Take"].." "..boatDesc, route.mPort)
		return route.tail.builder:AddWaypoint(route.tail, description)
	end
	
	local order = {
		"Character",
		"FlightMaster",
		"LocalPortals",
		"BoundTeleport",
		"UnboundTeleport",
		"ZenPilgrimageReturn",
		"StaticPortals",
		"Boats",
	}
	
	--local gbrCount = 0
	function Taxi:GetBestRoute(parentRoute, m1, f1, x1, y1, m2, f2, x2, y2, ...)
		--gbrCount = gbrCount +1
		--DGV:DebugFormat("GetBestRoute", "gbrCount", gbrCount, "stack", debugstack())
		--DGV:DebugFormat("GetBestRoute", "parentRoute.currentBest", (parentRoute and parentRoute.currentBest)~=nil)
		local best
		local dontIterate = GetCreateTable(...)
		local builder =  nil
		for _,builderKey in ipairs(order) do
			builder = RouteBuilders[builderKey]
			if builder.Iterate and not tContains(dontIterate, builder) then
-- 				if builder==RouteBuilders.FlightMaster then
-- 					DGV:DebugFormat("GetBestRoute", "parentRoute", (parentRoute and parentRoute.currentBest)~=nil)
-- 				end
				for control, route in builder:Iterate(best, parentRoute, m1, f1, x1, y1, m2, f2, x2, y2) do
					if not route or type(route)=="string" then
						DGV:DebugFormat("GetBestRoute", "route", route, "stack", debugstack())
						PoolTable(dontIterate)
						return
					end
					
		-- 			if route.builder==RouteBuilders.Boats then
		-- 				IsBest(route)
		-- 				PoolRoute(route)
		-- 			else
					--local prebest = best
						route.currentBest = best
						if not best then best = route
						elseif IsBest(route) then
							PoolRoute(best)
							best = route
						else
							PoolRoute(route)
						end
		-- 			end
-- 					if best~=prebest then
-- 						DGV:DebugFormat("GetBestRoute", "best", best)
-- 					end
					control.best = best
				end
			end
		end
		PoolTable(dontIterate)
		return best
	end
	
	local encapsulatedZones = 
	{
-- 		[864] = 30,
-- 		[866] = 27,
-- 		[888] = 41,
-- 		[889] = 4,
-- 		[890] = 9,
-- 		[891] = 4,
-- 		[892] = 20,
-- 		[893] = 462,
-- 		[894] = 464,
-- 		[895] = 27,
		[27] = "866:895",
		[30] = 864,
		[41] = 888,
		[4] = "889:891",
		[20] = 892,
		[462] = 893,
		[464] = 894,
		[9] = 890,
	}
		
	local function CheckBoundsOfTranslation(m1, f1, x1, y1, m2, f2)
		local chkX, chkY = DGV:TranslateWorldMapPosition(m1, f1, x1, y1, m2, f2)
		if chkX and chkY and 
			chkX>=0 and chkX<=1 and 
			chkY>=0 and chkY <=1 
		then return m2, f2, chkX, chkY
		else return end
	end
	
	local function CheckEncapsulatedZones(playerM, m, f, x, y)
		if f~=0 then return m, f, x, y end
		local encMs = encapsulatedZones[m]
		local encM = tonumber(encMs)
		if encM then
			if encM==playerM then
				local chkM, chkF, chkX, chkY = CheckBoundsOfTranslation(m, f, x, y, encM, 0)
				if chkM then return chkM, chkF, chkX, chkY end
			end
		elseif encMs then
			local encs = GetCreateTable(strsplit(":", encMs))
			for _, encM in ipairs(encs) do
				local m2, f2, x2, y2 = tonumber(encM)
				if m2==playerM then
					m2, f2, x2, y2 =  CheckBoundsOfTranslation(m, f, x, y, m2, 0)
					if m2 then
						m, f, x, y = m2, f2, x2, y2
						break
					end
				end
			end
			PoolTable(encs)
		end
		return m, f, x, y
	end

	function DGV:SetSmartWaypoint(mapID, mapFloor, x, y, desc)
		--DGV:DebugFormat("SetSmartWaypoint", "args", {mapID, mapFloor, x, y, desc})
		if not mapID then mapID = GetCurrentMapAreaID() end
		if not mapFloor then
			mapFloor = (mapID==321 and 1) or (mapID==504 and 1) or 0 --again with Orgrimmar or Dalaran
		end
		local m1, f1, x1, y1 =  DGV:GetPlayerMapPositionDisruptive()
		if not m1 then return end
		--DGV:DebugFormat("SetSmartWaypoint LocalCoordinate", "args", {m1, f1, x1, y1})
		--m1, f1, x1, y1 = DugisArrow:LocalCoordinate(m1, f1, x1, y1)
		--m1, f1, x1, y1 = CheckEncapsulatedZones(m1, f1, x1, y1)
		mapID, mapFloor, x, y = CheckEncapsulatedZones(m1, mapID, mapFloor, x/100, y/100)
		local route = Taxi:GetBestRoute(nil, 
				m1, f1, x1, y1, mapID, mapFloor, x, y)
		if not route then
			--DGV:DebugFormat("SetSmartWaypoint", "route", route)
			return
		end
		local point = route.builder:AddWaypoint(route, desc)
		PoolRoute(route)
		CleanUpRoutes()
		CleanUpTables()
		return point
	end
	
	function DGV:SPELLS_CHANGED()
		ResetMovementCache()
	end

	function Taxi:Load()
		DGV:RegisterEvent("SPELLS_CHANGED")
		DGV:RegisterEvent("CONFIRM_BINDER")
		DGV:RegisterEvent("UNIT_SPELLCAST_START")
	end
	
	function Taxi:Unload()
		DGV:UnregisterEvent("SPELLS_CHANGED")
		DGV:UnregisterEvent("CONFIRM_BINDER")
		DGV:UnregisterEvent("UNIT_SPELLCAST_START")
	end
end
