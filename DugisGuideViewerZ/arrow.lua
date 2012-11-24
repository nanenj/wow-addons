local DGV = DugisGuideViewer
if not DGV then return end

local DugisArrow = DGV:RegisterModule("DugisArrow")
DugisArrow.essential = true
local _

local function CreateArrowFrame()
	if not DugisArrowFrame then
		CreateFrame("Button", "DugisArrowFrame", UIParent)
		DugisArrowFrame:EnableMouse(true)
		DugisArrowFrame:SetMovable(true)
		DugisArrowFrame:SetUserPlaced(true)
		DugisArrowFrame.arrow = DugisArrowFrame:CreateTexture("BACKGROUND")
		DugisArrowFrame.arrow:SetTexture(0,0,0,1);
		DugisArrowFrame.button = CreateFrame("Button", "DugisArrowActionButton", UIParent, "SecureActionButtonTemplate")
		DugisArrowFrame.button:SetFrameStrata("TOOLTIP")
		DugisArrowFrame.button:SetNormalTexture("Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\IconBorder")
		DugisArrowFrame.button:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
		DugisArrowFrame.button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
		DugisArrowFrame.button.texture = DugisArrowFrame.button:CreateTexture(nil, "ARTWORK")
		DugisArrowFrame.button.texture:SetTexture("Interface\\Icons\\INV_Misc_Bag_08")
		DugisArrowFrame.button.texture:SetAllPoints(DugisArrowFrame.button)
		DugisArrowFrame.button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		--DugisArrowFrame.button:SetPoint("CENTER", 0, 35)
		DugisArrowFrame.button:Hide()
		DugisArrowFrame:Hide()
	end
	return DugisArrowFrame
end
CreateArrowFrame()

function DugisArrow:Initialize()
	DGV.DugisArrow = DugisArrow

	DGV.WaypointsShown = true

	DugisArrow.CLASSIC_UP 	= "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\ArrowsC"
	DugisArrow.CLASSIC_DOWN = "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\ArrowsC-Down"
	DugisArrow.MODERN_UP 	= "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\Arrows"
	DugisArrow.MODERN_DOWN 	= "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\Arrows-Down"
	DugisArrow.STAIRS	= "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\stair"

	local DADEFAULT = {}
	DADEFAULT["arrow"]			= true
	DADEFAULT["arrow_pos_x"]	= 0
	DADEFAULT["arrow_pos_y"]	= 300
	DADEFAULT["arrow_locked"]	= false
	DADEFAULT["arrow_size"]		= 1
	DADEFAULT["arrow_textsize"]	= 1
	DADEFAULT["update_interval"] = 0.15

	local OnUpdate

	local pool = {}

	local index, waypoint

	local function ColorGradient(perc, ...)
		local num = select("#", ...)
		local hexes = type(select(1, ...)) == "string"

		if perc == 1 then
			return select(num-2, ...), select(num-1, ...), select(num, ...)
		end

		num = num / 3

		local segment, relperc = math.modf(perc*(num-1))
		local r1, g1, b1, r2, g2, b2
		r1, g1, b1 = select((segment*3)+1, ...), select((segment*3)+2, ...), select((segment*3)+3, ...)
		r2, g2, b2 = select((segment*3)+4, ...), select((segment*3)+5, ...), select((segment*3)+6, ...)

		if not r2 or not g2 or not b2 then
			return r1, g1, b1
		else
			return r1 + (r2-r1)*relperc,
			g1 + (g2-g1)*relperc,
			b1 + (b2-b1)*relperc
		end
	end

	local wayframe = CreateArrowFrame()

	local titleframe = DugisArrowTitleFrame
	if not titleframe then
		titleframe = CreateFrame("Frame", "DugisArrowTitleFrame", wayframe)
		wayframe.title = titleframe:CreateFontString("OVERLAY", nil, "GameFontHighlightSmall")
		wayframe.status = titleframe:CreateFontString("OVERLAY", nil, "GameFontNormalSmall")
		wayframe.tta = titleframe:CreateFontString("OVERLAY", nil, "GameFontNormalSmall")
		wayframe.title:SetPoint("TOP", wayframe, "BOTTOM", 0, 0)
		wayframe.status:SetPoint("TOP", wayframe.title, "BOTTOM", 0, 0)
		wayframe.tta:SetPoint("TOP", wayframe.status, "BOTTOM", 0, 0)
	end

	local default_font_name, default_font_size, default_font_flags = wayframe.title:GetFont()

	local function OnDragStart(self, button)
		if not DugisArrow:GetSetting("arrow_locked") then
			wayframe.moving = true
			self:StartMoving()
		end
	end

	local function OnDragStop(self, button)
		self:StopMovingOrSizing()
		local point, relativeTo, relativePoint, xOfs, yOfs = wayframe:GetPoint()
		DugisArrow:SetSetting("arrow_pos_x", xOfs)
		DugisArrow:SetSetting("arrow_pos_y", yOfs)
		wayframe.moving = false
	end
	
	local function OnActionButtonDragStart()
		if not InCombatLockdown() then
			OnDragStart(wayframe)
		end
	end
	
	local function OnActionButtonDragStop()
		if not InCombatLockdown() then
			OnDragStop(wayframe)
		end
	end

	wayframe:SetScript("OnDragStart", OnDragStart)
	wayframe:SetScript("OnDragStop", OnDragStop)
	wayframe:RegisterForDrag("LeftButton")
	wayframe.button:SetScript("OnDragStart", OnActionButtonDragStart)
	wayframe.button:SetScript("OnDragStop", OnActionButtonDragStop)
	wayframe.button:RegisterForDrag("LeftButton")
	wayframe.arrow = wayframe:CreateTexture("OVERLAY")
	wayframe.arrow:SetAllPoints()
	local status = wayframe.status
	local tta = wayframe.tta
	local arrow = wayframe.arrow

	local active_point, arrive_distance, showDownArrow, point_title
	active_point = {}
	
	local function UseTomTomArrow()
		return DGV:UserSetting(DGV_TOMTOMARROW) and DGV.tomtomloaded
	end
	
	local function UseCarboniteArrow()
		return DGV:UserSetting(DGV_CARBONITEARROW) and DGV.carboniteloaded
	end

	function DugisArrow:Show()
		wayframe:SetClampedToScreen(true);
		if not wayframe.moving then
			wayframe:SetPoint("CENTER",  DugisArrow:GetSetting("arrow_pos_x"), DugisArrow:GetSetting("arrow_pos_y"))
		end

		if DugisGuideViewer:UserSetting(DGV_DUGIARROW) and not UseTomTomArrow() and not UseCarboniteArrow() then
			wayframe:Show()
		end
	end

	function DugisArrow:Hide()
		wayframe:Hide()
		if not InCombatLockdown() then
			wayframe.button:Hide()
		end
	end

	function DugisArrow:setArrowTexture( )
		local setTexture

		if DugisGuideViewer.WrongInstanceFloor then
			setTexture = DugisArrow.STAIRS
			arrow:SetTexCoord(0,1,0,1)
			arrow:SetVertexColor(1,1,1,1)
		else
			if DugisGuideViewer:UserSetting(DGV_CLASSICARROW) then
				DugisArrow.arrowTexture = DugisArrow.CLASSIC_UP
				DugisArrow.arrowDownTexture = DugisArrow.CLASSIC_DOWN
			else
				DugisArrow.arrowTexture = DugisArrow.MODERN_UP
				DugisArrow.arrowDownTexture = DugisArrow.MODERN_DOWN
			end

			if showDownArrow then setTexture = DugisArrow.arrowDownTexture else setTexture = DugisArrow.arrowTexture end
		end

		if setTexture ~= DugisArrow.currentTexture then
			arrow:SetTexture(setTexture)
			DugisArrow.currentTexture = setTexture
		end

	end
	
	--Go backwards mapid -> cz for carbonite
	czLookup = {}
	local c, z
	for c in pairs( {GetMapContinents()} ) do
		local zones = { GetMapZones(c) }
		SetMapZoom(c, 0)
		zones[0] = GetCurrentMapAreaID()
		for z, name in ipairs(zones) do
			SetMapZoom(c, z)
			local mapId = GetCurrentMapAreaID()
			zones[z] = mapId
			czLookup[mapId] = {c, z, name}
		end
	end
	
	function DugisGuideViewer:GetZoneIdByName(name)
		if type(name)~="string" then return nil end
		name = name:lower():trim()
		for id, tbl in pairs(czLookup) do
			if tbl[3]:lower():trim()==name then
				return id
			end
		end
	end
	
	local function getCZ(mapId)
		local c, z 
		if czLookup[mapId] then 
			c, z = unpack(czLookup[mapId])
		end
		return c or 0, z or 0
	end

	function DugisGuideViewer:GetCZByMapId(mapId)
		return getCZ(mapId)
	end

	--Waypoint 1
	local DESCRIPTION_FORMAT = DugisLocals["Waypoint %d"]
	local DESCRIPTION_PATTERN = DugisLocals["Waypoint (%d+)"]
	local function GetNextManualWaypointDescription()
		local highest = 0
		if DugisArrow.waypoints then
			for k, v in ipairs(DugisArrow.waypoints) do
				local match = v.desc:match(DESCRIPTION_PATTERN)
				if match then
					local num = tonumber(match)
					highest = math.max(highest, num)
				end
			end
		end
		return string.format(DESCRIPTION_FORMAT, highest+1)
	end
	
	local function point_OnClick(self, button)
		local point = self.point
		local menu = DugisGuideViewer.ArrowMenu:CreateMenu()
		DugisGuideViewer.ArrowMenu:CreateMenuTitle(menu, point.desc)
		local remove = DugisGuideViewer.ArrowMenu:CreateMenuItem(menu, "Remove Waypoint")
		remove:SetFunction(function () DugisArrow:SetNextWaypoint(point)  end)
		local removeAll = DugisGuideViewer.ArrowMenu:CreateMenuItem(menu, "Remove All Waypoints")
		removeAll:SetFunction(function () DugisGuideViewer:RemoveAllWaypoints()  end)
		menu:ShowAtCursor()
	end

	do
		if not DugisArrowTooltip then
			local tooltip = CreateFrame("GameTooltip", "DugisArrowTooltip", UIParent, "GameTooltipTemplate")
			tooltip:SetFrameStrata("TOOLTIP")
		end
	end

	local function arrow_OnEnter(self, button)
		if DugisGuideViewer.WrongInstanceFloor then
			DugisArrowTooltip:SetParent(self)
			DugisArrowTooltip:SetOwner(self, "ANCHOR_CURSOR")
			DugisArrowTooltip:AddLine("Waypoint is on a different floor")
			DugisArrowTooltip:Show()
		end
	end

	local function arrow_OnLeave(self, button)
		DugisArrowTooltip:Hide()
	end

	do
		local tooltip = CreateFrame("GameTooltip", "DugisWaypointTooltip", UIParent, "GameTooltipTemplate")
		tooltip:SetFrameStrata("TOOLTIP")
	end

	local function point_OnEnter(self, button)
		if UIParent:IsVisible() then
			DugisWaypointTooltip:SetParent(UIParent)
		else
			DugisWaypointTooltip:SetParent(self)
		end

		DugisWaypointTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
		DugisWaypointTooltip:AddLine(string.format("%s (%.2f, %.2f)", self.point.desc, self.point.x, self.point.y))
		DugisWaypointTooltip:Show()
	end

	local function point_OnLeave(self, button)
		DugisWaypointTooltip:Hide()
	end
	
	local function createPoint( mapID, mapFloor, x, y, waypointHidden, blobType)

		local worldpoint = CreateFrame("Button", nil, DugisMapOverlayFrame)
		worldpoint:RegisterForClicks("RightButtonUp")
		worldpoint:SetScript("OnClick", point_OnClick)
		worldpoint:SetScript("OnEnter", point_OnEnter)
		worldpoint:SetScript("OnLeave", point_OnLeave)
		worldpoint.icon = worldpoint:CreateTexture("ARTWORK")
		worldpoint.icon:SetAllPoints()
		worldpoint.icon:Show()

		return worldpoint
	end

	local function createMinimapPoint( mapID, mapFloor, x, y )

		local minipoint = CreateFrame("Button", nil, DugisMinimapOverlayFrame)
		minipoint:RegisterForClicks("RightButtonUp")
		minipoint:SetScript("OnClick", point_OnClick)
		minipoint:SetScript("OnUpdate", DugisArrow.Minimap_OnUpdate)
		minipoint:SetScript("OnEnter", point_OnEnter)
		minipoint:SetScript("OnLeave", point_OnLeave)

		minipoint.icon = minipoint:CreateTexture("ARTWORK")
		minipoint.icon:SetAllPoints()

		minipoint.arrow = minipoint:CreateTexture("BACKGROUND")
		minipoint.arrow:SetTexture("Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\TrackingArrow")
		minipoint.arrow:SetPoint("CENTER", 0 ,0)
		minipoint.arrow:SetHeight(40)
		minipoint.arrow:SetWidth(40)
		minipoint.arrow:Hide()

		minipoint.icon:Show()

		return minipoint
	end
	
	local function AddWaypoint(mapID, mapFloor, x, y, desc)
		local point = table.remove(pool)
		--DGV:DebugFormat("AddWaypoint", "point", point)

		if not point then
			point = {}

			local worldmap = createPoint( mapID, mapFloor, x, y, wayPointHidden )
			local minimap = createMinimapPoint( mapID, mapFloor, x, y )
			point.worldmap = worldmap
			point.minimap = minimap
		else
			local worldmap = point.worldmap
			local minimap = point.minimap
			wipe(point)
			point.worldmap = worldmap
			point.minimap = minimap
		end

		if not DugisArrow.waypoints then
			DugisArrow.waypoints = {}
		end

		point.desc = desc
		point.map = mapID
		point.floor = mapFloor
		point.x = x
		point.y = y
		point.isRouteWaypoint = nil
		point.flightMasterID = nil
		point.destID = nil
		point.itemID = nil
		point.spellID = nil

		point.minimap.point = point
		point.worldmap.point = point

		local texture, worldmapSize, minimapSize
		if DugisGuideViewer:ReturnTag("W") and DugisArrow:getNumWaypoints() < 1 then
			texture = "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\circular"
			worldmapSize = 32
			minimapSize = 32
		else
			texture = "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\GoldGreenDot"
			worldmapSize = 12
			minimapSize = 10
		end
		point.worldmap.icon:SetTexture(texture)
		point.worldmap:Show()
		point.worldmap:SetHeight(worldmapSize)
		point.worldmap:SetWidth(worldmapSize)

		point.minimap.icon:SetTexture(texture)

		point.minimap:SetHeight(minimapSize)
		point.minimap:SetWidth(minimapSize)

		table.insert(DugisArrow.waypoints, point)

		--DebugPrint("Point placed at x:"..x.."y:"..y.."mapID"..mapID)
		if DugisGuideViewer.WaypointsShown then
			DugisGuideViewer:PlaceIconOnWorldMap( WorldMapButton, point.worldmap, mapID, mapFloor, x/100, y/100 )
			DugisGuideViewer:PlaceIconOnMinimap( point.minimap, mapID, mapFloor, x/100, y/100 )
		end
		
		if UseCarboniteArrow() then
			local c, z = getCZ(mapID)
			if czLookup[mapID] then
				point.tomtom = TomTom:AddZWaypoint(c, z, x, y, desc)
			else
				point.tomtom = TomTom:AddWaypoint(x, y, desc)
			end
		elseif UseTomTomArrow() then
			local opts = {}
			opts.title = desc
			point.tomtom = TomTom:AddMFWaypoint(mapID, mapFloor, x/100, y/100, opts)
		end
		
		
		if UseTomTomArrow() or UseCarboniteArrow() then
			local first = DugisArrow:getFirstWaypoint()
			TomTom:SetCrazyArrow(  first.tomtom, 5, first.desc )
		elseif DugisArrow:getNumWaypoints() == 1 then
			DugisArrow:setArrow( point.map, point.floor, point.x, point.y, point.desc, point )
		end

		DugisArrow:WaypointsChanged()
		return point
	end
	
	function DGV:AddRouteWaypoint(mapID, mapFloor, x, y, desc)
		local point = AddWaypoint(mapID, mapFloor, x*100, y*100, desc)
		point.isRouteWaypoint = true
		return point
	end
	
	function DGV:AddRouteWaypointWithDestinationTrigger(mapID, mapFloor, x, y, desc, destID)
		local point = DGV:AddRouteWaypoint(mapID, mapFloor, x, y, desc)
		point.destID = destID
		return point
	end
	
	function DGV:AddRouteWaypointWithItem(mapID, mapFloor, x, y, desc, itemID)
		local point = DGV:AddRouteWaypoint(mapID, mapFloor, x, y, desc)
		point.itemID = itemID
		return point
	end
	
	function DGV:AddRouteWaypointWithSpell(mapID, mapFloor, x, y, desc, spellID)
		local point = DGV:AddRouteWaypoint(mapID, mapFloor, x, y, desc)
		point.spellID = spellID
		return point
	end

	function DGV:AddCustomWaypoint(x, y, desc, zoneNameOrId, mapFloor, qid)
		local m,f = GetCurrentMapAreaID(), GetCurrentMapDungeonLevel()
		if m==-1 then m=0 end
		if zoneNameOrId then
			local id = DugisGuideViewer:GetZoneIdByName(zoneNameOrId)
			if id then m=id
			else
				m=zoneNameOrId
			end
		end
		if mapFloor then f=mapFloor end
		--DGV:DebugFormat("AddCustomWaypoint AddWaypoint", "args", {m, f, x*100, y*100, desc, nil, nil, qid})
		DugisArrow:AddWaypoint( m, f, x*100, y*100, desc, nil, qid)
		--if DugisArrow:getNumWaypoints() == 1 then
		--	DugisGuideViewer.DugisArrow:setArrow( m, f, x*100, y*100, desc)
		--end
	end

	function DGV:AddManualWaypoint(x, y, zoneNameOrId, mapFloor)
		if zoneNameOrId and not tonumber(zoneNameOrId) then
			zoneNameOrId = DGV:GetZoneIdByName(zoneNameOrId)
		end
		DGV:AddCustomWaypoint(x, y, GetNextManualWaypointDescription(), zoneNameOrId, mapFloor)
	end
	
	function DugisArrow:LocalCoordinate(m, f, x, y)
		--DGV:DebugFormat("LocalCoordinate", "args", {m, f, x, y})
		if m==-1 then return end
		local currentId,currentFloor = GetCurrentMapAreaID(), GetCurrentMapDungeonLevel()
		if currentId~=m then
			SetMapByID(m)
			SetDungeonMapLevel(f)
		end
		local actualMapName = UpdateMapHighlight(x,y)
		if currentId~=m then
			SetMapByID(currentId)
			SetDungeonMapLevel(currentFloor)
		end
		if actualMapName then
			local altId = DGV:GetZoneIdByName(actualMapName)
			if altId then
				local altFloor = f
				if altId==321 and f==0 then --orgrimmar is the only map i know of w/0 a floor 0
					altFloor=1
				end
				x,y = DGV:TranslateWorldMapPosition(
					m, f, 
					x, y, 
					altId, 
					altFloor)
				m = altId
				f = altFloor
			end
		end
		--DGV:DebugFormat("LocalCoordinate", "actualMapName", actualMapName,  "return", {m, f, x, y})
		return m, f, x, y
	end

	local function DugisMapOverlayFrame_OnMouseUp(self, ...)
		
		local mouseButton, button = ...
		if not DugisGuideViewer.tomtomloaded
			and not DugisGuideViewer.carboniteloaded
			and (IsControlKeyDown() or IsShiftKeyDown())
		then
			if mouseButton == "RightButton" then
				local cX, cY = DugisGuideViewer:GetCurrentCursorPosition(DugisMapOverlayFrame)
				if IsControlKeyDown() then DugisGuideViewer:RemoveAllWaypoints() end
				local f = GetCurrentMapDungeonLevel()
				local actualID = GetCurrentMapAreaID()
				actualID, f, cX, cY = DugisArrow:LocalCoordinate(actualID, f, cX, cY)
				if not cY then return end
				DGV:AddManualWaypoint(cX, cY, actualID, f)
			elseif mouseButton == "LeftButton" then
				--[[if DGV.Modules.WorldMapTracking:ShowMenu(DugisMapOverlayFrame) then
					return
				end]]
				WorldMapButton_OnClick(WorldMapButton, ...)
			end
		else
			WorldMapButton_OnClick(WorldMapButton, ...)
		end
	end

	hooksecurefunc("QuestPOI_DisplayButton", function(parentName, buttonType, buttonIndex, questId)
		local poiButton = _G["poi"..tostring(parentName)..tostring(buttonType).."_"..tostring(buttonIndex)];
		local swapButton = _G["poi" .. parentName .. "_Swap"]

		if poiButton then poiButton:RegisterForClicks("AnyUp") end
		if swapButton then swapButton:RegisterForClicks("AnyUp") end
	end)


	hooksecurefunc("QuestPOI_SelectButton", function(poiButton)
		if ( not WorldMapFrame:IsShown() and (poiButton.type ~= QUEST_POI_COMPLETE_OUT) and DugisGuideViewer.GuideOn == true ) then
			poiButton.selectionGlow:Show();
		end
	end)
	
	function DugisArrow:VisitFlightmaster(npc)
		if npc and DugisArrow.waypoints then
			for _, waypoint in pairs(DugisArrow.waypoints) do
				if waypoint.flightMasterID and 
					waypoint.flightMasterID==npc
				then 
					DGV.DugisArrow:SetNextWaypoint(waypoint)
					return
				end
			end
		end
	end
	
	hooksecurefunc("TakeTaxiNode", function(id)
		if DugisArrow.loaded then
			local x,y = TaxiNodePosition(id)
			local cont = GetCurrentMapContinent()
			local destNpc = DGV.Modules.TaxiData:GetLookupTable()[cont][DGV:PackXY(x,y)]
			DugisArrow:VisitFlightmaster(destNpc)
		end
	end)

	local function GetPOIWaypointDescription(poiButton)
		--DGV:DebugFormat("GetPOIWaypointDescription", "poiButton", poiButton)
		local questId = poiButton.questId or (poiButton.quest and poiButton.quest.questId)
		local logIndex = GetQuestLogIndexByID(questId)
		local guideIndex = DugisGuideViewer:GetUnfinishedGuideIndexByQID(questId)
		local desc = GetQuestLogTitle(logIndex);
		if guideIndex then
			desc = DugisGuideViewer:GetQuestDescription(guideIndex)
		elseif poiButton and poiButton.type == QUEST_POI_COMPLETE_SWAP then
			desc = GetQuestLogCompletionText(logIndex)
		elseif poiButton then
			desc = GetQuestLogTitle(logIndex)
		end
		return desc
	end

	function DugisArrow:QuestPOIWaypoint(poiButton, reset)
		--DGV:DebugFormat("QuestPOIWaypoint", "WorldMapFrame:IsShown() ", WorldMapFrame:IsShown() )
		if 
			not UseTomTomArrow() and 
			not DugisGuideViewer.carboniteloaded
		then
			local questId = poiButton.questId or (poiButton.quest and poiButton.quest.questId)
			local m,f = GetCurrentMapAreaID()
			local desc = GetPOIWaypointDescription(poiButton)
			local _, posX, posY, objective = QuestPOIGetIconInfo(questId)
			if reset then DugisGuideViewer:RemoveAllWaypoints() end
			if posX then
				DGV:AddCustomWaypoint(posX, posY, desc, m, f, questId)
			end
		end
	end

	function DugisArrow:OnQuestLogChanged()
		local wp = DugisArrow:getFirstWaypoint()
		if not wp or wp.guideIndex or not wp.questId then return end
		for i=1,GetNumQuestLogEntries() do
			local link = GetQuestLink(i)
			local qid = link and tonumber(link:match("|Hquest:(%d+):"))
			if qid==wp.questId  then
				return
			end
		end
		DugisArrow:SetNextWaypoint(wp)
	end
	
	function DugisArrow:DisableMapClicks()
		if not (DugisGuideViewer.carboniteloaded or DugisGuideViewer.tomtomloaded) then
			DugisMapOverlayFrame:SetScript("OnMouseUp", DGV.NoOp)
		end
	end
	
	function DugisArrow:EnableMapClicks()
		if not (DugisGuideViewer.carboniteloaded or DugisGuideViewer.tomtomloaded) then
			DugisMapOverlayFrame:SetScript("OnMouseUp", DugisMapOverlayFrame_OnMouseUp)
		end
	end

	function DugisArrow:initArrow()
		if not DugisMapOverlayFrame then
			DugisArrow.map_overlay = CreateFrame("FRAME", "DugisMapOverlayFrame", WorldMapButton)
			DugisArrow.map_overlay:SetAllPoints()
			DugisArrow.map_overlay:SetScript("OnUpdate", self.OnMapOverlayUpdate)
		end

		if not DugisMinimapOverlayFrame then
			DugisArrow.minimap_overlay = CreateFrame("FRAME", "DugisMinimapOverlayFrame", Minimap)
			DugisArrow.minimap_overlay:SetAllPoints()
		end
		DugisArrow:EnableMapClicks()
		wayframe.arrow:SetTexture(DugisArrow.CLASSIC_UP)

		if not DugisArrowDb then DugisArrow:LoadDefaultSettings() end

		-- Player Position Variables
		DugisArrow.continent = 0;
		DugisArrow.zone = 0;
		DugisArrow.pos_x = 0;
		DugisArrow.pos_y = 0;
		DugisArrow.map = 0

		-- Update Variables
		DugisArrow.updatestart = 0;
		DugisArrow.updateend = 0;
		DugisArrow.updatelast = 0;
		DugisArrow.updatetime = 0;

		DugisMapOverlayFrame:Show()
		DugisMinimapOverlayFrame:Show()
		DugisArrow:UpdatePosition()

	end

	function DugisArrow:ResetPosition()
		wayframe:ClearAllPoints()
		wayframe:SetPoint("CENTER", DADEFAULT["arrow_pos_x"], DADEFAULT["arrow_pos_y"])
		DugisArrow:SetSetting("arrow_pos_x", DADEFAULT["arrow_pos_x"])
		DugisArrow:SetSetting("arrow_pos_y", DADEFAULT["arrow_pos_y"])
		DugisArrow:SetSetting("arrow_locked", false)
		DugisArrow:SetSetting("arrow_size", DADEFAULT["arrow_size"])
		DugisArrow:SetSetting("arrow_textsize", DADEFAULT["arrow_textsize"])
		DugisArrow:Show()
	end

	function DugisArrow:SetScale(scale)
		if scale then
			DugisArrow:SetSetting("arrow_size", scale)
		else
			scale = DugisArrow:GetSetting("arrow_size")
		end

		if not showDownArrow then
			wayframe:SetHeight(60 * scale)
			wayframe:SetWidth(80 * scale)
		else
			scale = 0.85 * scale
			wayframe:SetHeight(92 * scale)
			wayframe:SetWidth(70 * scale)
		end
		if not InCombatLockdown() then
			wayframe.button:SetHeight(50 * scale)
			wayframe.button:SetWidth(50 * scale)
		end
	end

	function DugisArrow:SetTextScale(scale)
		if scale then
			DugisArrow:SetSetting("arrow_textsize", scale)
		else
			scale = DugisArrow:GetSetting("arrow_textsize")
		end

		wayframe.title:SetFont(default_font_name, default_font_size * scale, default_font_flags)
		wayframe.status:SetFont(default_font_name, default_font_size * scale, default_font_flags)
		wayframe.tta:SetFont(default_font_name, default_font_size * scale, default_font_flags)

	end

	function DugisArrow:setArrow(m, f, x, y, desc, waypoint)
		active_point.m, active_point.f, active_point.x, active_point.y = m, f, x/100, y/100
		active_point.waypoint = waypoint
		wayframe.title:SetText(desc)
		DugisArrow:Show()
	end

	function DugisArrow:PrintStatus()
		DebugPrint("Player Status:")

		self:PrintBool("map", DugisArrow.map)
		self:PrintBool("floor", DugisArrow.floor)
		self:PrintBool("pos_x", DugisArrow.pos_x)
		self:PrintBool("pos_y", DugisArrow.pos_y)

		DebugPrint("Waypoint Status:")
		self:PrintBool("map", active_point.m)
		self:PrintBool("floor", active_point.f)
		self:PrintBool("pos_x", active_point.x)
		self:PrintBool("pos_y", active_point.y)
	end



	function DugisArrow:DebugZ()
		local k, v
		DebugPrint("---------DugisArrow.waypoints:")
		if DugisArrow.waypoints then
			for k, v in ipairs(DugisArrow.waypoints) do
				DebugPrint("Index:"..k.." x coord:"..v.x.." y coord:"..v.y.." map:"..v.map.." floor:"..(v.floor or 0))
			end
		else
			DebugPrint("Empty")
		end

		self:PrintBool("WrongInstanceFloor", DugisGuideViewer.WrongInstanceFloor)
		DebugPrint("---------")
	end

	function DugisArrow:PrintBool(name, data)
		if type(data) == "boolean" then
			if data == true then DebugPrint(name.." == true")
			elseif data == false then DebugPrint(name.." == false")
			elseif data == nil then DebugPrint(name.." == nil") end
		else
			if data then DebugPrint(name.." == "..data) else DebugPrint(name.." == nil") end
		end
	end

	local last_distance = 0
	local tta_throttle = 0
	local speed = 0
	local speed_count = 0
	local function OnUpdate(self, elapsed)
		if not DugisArrow.waypoints or #DugisArrow.waypoints<1 then
			wayframe:Hide()
			if not InCombatLockdown() then wayframe.button:Hide() end
		end
		
		local center = wayframe:GetCenter()
		local top = wayframe:GetTop()
		local width = wayframe.button:GetWidth()
		if not InCombatLockdown() and center and top and width then
			wayframe.button:SetPoint("TOPLEFT", UIParent, 
				center-(width/2), top-UIParent:GetHeight())
		end
		
		if active_point.waypoint and 
			active_point.waypoint.itemID 
		then
			wayframe.arrow:Hide()
			wayframe.button.texture:SetTexture(
				GetItemIcon(active_point.waypoint.itemID))
			if not InCombatLockdown() then
				wayframe.button:SetAttribute("type1", "item")
				wayframe.button:SetAttribute("item1", 
					"item:"..active_point.waypoint.itemID)
				if wayframe:IsShown() then
					wayframe.button:Show()
				end
			end
		elseif active_point.waypoint and 
				active_point.waypoint.spellID
		then
			wayframe.arrow:Hide()
			wayframe.button.texture:SetTexture(
				select(3,
					GetSpellInfo(active_point.waypoint.spellID)))
			if not InCombatLockdown() then
				wayframe.button:SetAttribute("type1", "spell")
				wayframe.button:SetAttribute("spell1", 
					GetSpellInfo(active_point.waypoint.spellID))
				if wayframe:IsShown() then
					wayframe.button:Show()
				end
			end
		else
			wayframe.arrow:Show()
			if not InCombatLockdown() then
				wayframe.button:Hide()
			end
		end

		local text = ""
		--print("Map="..DugisArrow.map.."Floor="..DugisArrow.floor.."xpos="..DugisArrow.pos_x.."ypos="..DugisArrow.pos_y.."map="..active_point.m.."floor="..active_point.f.."ap_x="..active_point.x.."ap_y"..active_point.y)

		local dist, dx, dy = DugisGuideViewer:ComputeDistance(DugisArrow.map, DugisArrow.floor, DugisArrow.pos_x, DugisArrow.pos_y, active_point.m, active_point.f, active_point.x, active_point.y)

		--if not DugisArrow.pos_x or not DugisArrow.pos_y or not DugisArrow:GetSetting("arrow") then
		if dist and dx and dy then

			local mdist = dist * 0.9144
			if GetLocale() == "enUS" then
				if dist > 9999 then
					text = math.floor(0.5 + dist/1760).." mil"
				else
					text = math.floor(0.5 + dist).." yd"
				end
			else
				if mdist > 9999 then
					text = math.floor(0.5 + mdist/1000).." km"
				else
					text = math.floor(0.5 + mdist).." m"
				end
			end

			status:SetText(text)

			tta_throttle = tta_throttle + elapsed

			if tta_throttle >= 1 then
				--print("dist="..dist.."Map="..DugisArrow.map.."Floor="..DugisArrow.floor.."xpos="..DugisArrow.pos_x.."ypos="..DugisArrow.pos_y.."map="..active_point.m.."floor="..active_point.f.."ap_x="..active_point.x.."ap_y"..active_point.y)
				-- Calculate the speed in yards per sec at which we're moving
				local current_speed = (last_distance - dist) / tta_throttle

				if last_distance == 0 then
				current_speed = 0
				end

				--DebugPrint("last_distance"..last_distance.."dist"..dist.."current_speed"..current_speed)
				if speed_count < 2 then
					speed = (speed + current_speed) / 2
					speed_count = speed_count + 1
				else
					speed_count = 0
					speed = current_speed
				end

				if speed > 0 then
					local eta = math.abs(dist / speed)
					if eta > 2^52 then
						tta:SetText("***")
					elseif eta > 3600 then
						wayframe.status:SetPoint("TOP", wayframe.title, "BOTTOM", -24, 0)
						wayframe.tta:SetPoint("TOP", wayframe.title, "BOTTOM", 24, 0)
						tta:SetFormattedText("%01d:%02d:%02d", eta / 3600, eta % 24, eta %60)
					else
						wayframe.status:SetPoint("TOP", wayframe.title, "BOTTOM", -21, 0)
						wayframe.tta:SetPoint("TOP", wayframe.title, "BOTTOM", 21, 0)
						tta:SetFormattedText("%01d:%02d", eta / 60, eta % 60)
					end
					wayframe.status:SetPoint("TOP", wayframe.title, "BOTTOM", -21, 0)
					wayframe.tta:SetPoint("TOP", wayframe.title, "BOTTOM", 21, 0)
				else
					tta:SetText("***")
				end

				last_distance = dist
				tta_throttle = 0
			end

			if DugisGuideViewer.WrongInstanceFloor then

				DugisArrow:setArrowTexture( )
			elseif (dist and dist <= 30 and DugisGuideViewer:ReturnTag("W")) or (dist and dist <= 5) then
				if not showDownArrow then
					showDownArrow = true

				DugisArrow:SetScale()
					DugisArrow:setArrowTexture( )
					arrow:SetVertexColor(1, 0.85, 0)
				end

				local cell = math.floor(mod(GetTime() * 60, 55))

				local column = cell % 9
				local row = floor(cell / 9)

				local xstart = (column * 53) / 512
				local ystart = (row * 70) / 512
				local xend = ((column + 1) * 53) / 512
				local yend = ((row + 1) * 70) / 512
				arrow:SetTexCoord(xstart,xend,ystart,yend)

				if DugisGuideViewer:IsPlayerAtBlizzardDestination() then
					arrow:SetVertexColor(0,.6,0)
				end
			else
				if showDownArrow then
					showDownArrow = false
				DugisArrow:SetScale()
					DugisArrow:setArrowTexture( )
				end

				local angle = atan2(-dx, -dy) / 360 * (math.pi * 2)
				local player = GetPlayerFacing()
				angle = angle - player

				local perc = math.abs((math.pi - math.abs(angle)) / math.pi)
				if perc > 1 then perc = 2 - perc end

				local gr,gg,gb = 1, 0.8, 0
				local mr,mg,mb = 1, 0.8, 0
				local br,bg,bb = 1, 0, 0
				local r,g,b = ColorGradient(perc, br, bg, bb, mr, mg, mb, gr, gg, gb)
				arrow:SetVertexColor(r,g,b)

				if DugisGuideViewer:IsPlayerAtBlizzardDestination() then
					arrow:SetVertexColor(0,.6,0)
					--angle = 0
				end

				local cell = floor(angle / (math.pi * 2) * 108 + 0.5) % 108
				local column = cell % 9
				local row = floor(cell / 9)

				local xstart = (column * 56) / 512
				local ystart = (row * 42) / 512
				local xend = ((column + 1) * 56) / 512
				local yend = ((row + 1) * 42) / 512
				arrow:SetTexCoord(xstart,xend,ystart,yend)
			end
		else
			wayframe.arrow:Hide()
		end
	end

	hooksecurefunc("WorldMapLevelDropDown_Update", function()
		DGV:OnMapChangeUpdateArrow( )
	end)

	--[[function DugisGuideViewer:GetPlayerPosition()
		--DugisGuideViewer.astrolabe:GetCurrentPlayerPosition()--astrolabe initialization workaround
		return DugisArrow.map, DugisArrow.floor, DugisArrow.pos_x, DugisArrow.pos_y
	end]]

	function DugisArrow:UpdatePosition()

		DugisArrow.prev_map, DugisArrow.prev_floor = DugisArrow.map, DugisArrow.floor

		if not WorldMapFrame:IsVisible() and not 
			(DugisGuideViewer.carboniteloaded and NxMap1 and NxMap1:IsVisible())
		then --NxMap1 is the Carbonite map
			DugisArrow.map, DugisArrow.floor, DugisArrow.pos_x, DugisArrow.pos_y = DugisGuideViewer:GetPlayerPosition()

		else --World Map Minimized
			local x, y = GetPlayerMapPosition("player")
			local floor, floors, map = GetCurrentMapDungeonLevel(), GetNumDungeonMapLevels(), GetCurrentMapAreaID()
			if (x and y) and (x > 0 and x < 1) and (y > 0 and y < 1) and (floors == 0 or floor > 0) and map ~= - 1 then
				DugisArrow.pos_x, DugisArrow.pos_y = x, y
				DugisArrow.map, DugisArrow.floor = GetCurrentMapAreaID(), GetCurrentMapDungeonLevel()
			end
		end

		DugisArrow.IsInInstance = IsInInstance()

		--hack to prevent astrolabe from lagging out in GetUnitPosition when floor changing or zone changing
		GetCurrentMapAreaID()
		if DugisArrow.IsInInstance and (DugisArrow.map ~= DugisArrow.prev_map or DugisArrow.floor ~= DugisArrow.prev_floor) then
			DebugPrint("Map Change Detected")
			SetMapToCurrentZone()
		end


	end

	function DugisGuideViewer:CheckForArrowChange()

	if DugisArrow.IsInInstance and DugisArrow.map == active_point.m and
		(DugisArrow.floor ~= active_point.f or (WorldMapFrame:IsVisible() and GetCurrentMapDungeonLevel() ~= active_point.f) ) then
		self.WrongInstanceFloor = true
	else
		self.WrongInstanceFloor = nil
	end

	end

	local function AlwaysUpdateFunc(elapsed)
		DugisArrow.updatelast = DugisArrow.updatelast + elapsed
		if (DugisArrow.updatelast > DugisArrow:GetSetting("update_interval")) then
			DugisArrow:UPDATE()
			DugisArrow.updatelast = 0
			DugisArrow.updatetime = 0
		end
		DugisGuideViewer.Ants:UpdateAntTrail(elapsed)
		--DugisGuideViewer:UpdateTravelToLocation()
	end
	local AlwaysUpdate = AlwaysUpdateFunc

	UIParent:HookScript("OnUpdate", function(self, elapsed)
		AlwaysUpdate(elapsed)
	end)

	function DugisArrow:OnMapOverlayUpdate(elapsed)
		-- When full screen map is visible
		if not UIParent:IsVisible() then
			AlwaysUpdate(elapsed)
		end
	end


	function DugisArrow:UPDATE(event, elapsed, ...)

		-- Update Player Position
		DugisArrow:UpdatePosition()

		-- Update Arrow
		DugisArrow:SetScale()
		DugisArrow:SetTextScale()
		DugisArrow:setArrowTexture( )

		DugisGuideViewer:CheckForFloorChange()
		DugisGuideViewer:CheckForArrowChange()
	end

	function DugisArrow:GetSetting(variable)

		if variable and DugisArrowDb then
			return DugisArrowDb[variable]
		end
	end

	function DugisArrow:SetSetting(variable, value)

		if DugisArrowDb and variable then
			if not value then DugisArrowDb[variable] = false
			else DugisArrowDb[variable] = value end
		end
	end

	function DugisArrow:ResetSettings()
		DugisArrowDb = {}
	end

	function DugisArrow:LoadDefaultSettings()
		DugisArrowDb = DADEFAULT
	end

	local function WayFrame_OnClick(self, button)
		local menu = DugisGuideViewer.ArrowMenu:CreateMenu()
		DugisGuideViewer.ArrowMenu:CreateMenuTitle(menu, "Dugi Arrow")

		DugisArrow:PopulateMenu(menu)

		menu:ShowAtCursor()
	end

	local function spacer()
		local htex = DugisGuideViewer.ArrowMenu:CreateIconTexture(item, 10)
		htex:SetVertexColor(1, 1, 1, 0)
		return htex
	end

	function DugisArrow:PopulateMenu(menu)
		local remove = DugisGuideViewer.ArrowMenu:CreateMenuItem(menu, "Remove Waypoint")
		remove:SetFunction(function () DugisArrow:ClearArrow() end)

		local removeAll = DugisGuideViewer.ArrowMenu:CreateMenuItem(menu, "Remove All Waypoints")
		removeAll:SetFunction(function () DugisGuideViewer:RemoveAllWaypoints()  end)

		local lock = DugisGuideViewer.ArrowMenu:CreateMenuItem(menu, not DugisArrow:GetSetting("arrow_locked") and "Lock Arrow" or "Unlock Arrow")
		local ltex = DugisGuideViewer.ArrowMenu:CreateIconTexture(item, 10)
		lock:SetFunction(function () local arrow_locked = not DugisArrow:GetSetting("arrow_locked"); DugisArrow:SetSetting("arrow_locked", arrow_locked); end)
		lock:AddTexture(ltex, true)
		lock:AddTexture(spacer(), false)
		ltex:SetVertexColor(1, 1, 1, DugisArrow:GetSetting("arrow_locked") and 1 or 0)

		local scale = DugisGuideViewer.ArrowMenu:CreateMenuItem(menu, "Arrow Scale")
		local scale_menu = DugisGuideViewer.ArrowMenu:CreateMenu()
		scale:SetSubmenu(scale_menu)
		scale:AddTexture(spacer(), true)
		for i = 5, 15 do
			local it = DugisGuideViewer.ArrowMenu:CreateMenuItem(scale_menu, string.format("%d%%", i * 10))
			local ix = i
			it:SetFunction(function () DugisArrow:SetScale(ix / 10) end)
			local icon = DugisGuideViewer.ArrowMenu:CreateIconTexture(item, 10)
			if DugisArrow:GetSetting("arrow_size") == ix / 10 then
				icon:SetVertexColor(1, 1, 1, 1)
			else
				icon:SetVertexColor(1, 1, 1, 0)
			end
			it:AddTexture(icon)
		end

		local tscale = DugisGuideViewer.ArrowMenu:CreateMenuItem(menu, "Text Scale")
		local tscale_menu = DugisGuideViewer.ArrowMenu:CreateMenu()
		tscale:SetSubmenu(tscale_menu)
		tscale:AddTexture(spacer(), true)
		for i = 5, 15 do
			local it = DugisGuideViewer.ArrowMenu:CreateMenuItem(tscale_menu, string.format("%d%%", i * 10))
			local ix = i
			it:SetFunction(function () DugisArrow:SetTextScale(ix / 10) end)
			local icon = DugisGuideViewer.ArrowMenu:CreateIconTexture(item, 10)
			if DugisArrow:GetSetting("arrow_textsize") == ix / 10 then
				icon:SetVertexColor(1, 1, 1, 1)
			else
				icon:SetVertexColor(1, 1, 1, 0)
			end
			it:AddTexture(icon)
		end

	end

	wayframe:RegisterForClicks("RightButtonUp")
	wayframe:SetScript("OnClick", WayFrame_OnClick)
	wayframe.button:HookScript("OnClick", 
		function(self, button)
			if button=="RightButton" then
				WayFrame_OnClick(self, button)
			end
		end)
	wayframe:SetScript("OnEnter", arrow_OnEnter)
	wayframe:SetScript("OnLeave", arrow_OnLeave)

	-------------Waypoint functions
	local function GetWaypointsCopy()
		local wps = {}
		local val
		if DugisArrow.waypoints then
			for _, val in ipairs(DugisArrow.waypoints) do
				table.insert(wps, val)
			end
		end
		return wps
	end

	--[[
	hooksecurefunc("WorldMapLevelDropDown_Update", function()
		DebugPrint("WorldMapLevelDropDown_Update")
		DugisArrow:onMapChangeUpdateArrow( )
	end)
	--]]
	
	local UID = 0
	function DugisArrow:AddWaypoint( mapID, mapFloor, x, y, desc, guideIndex, questId)
		local isWTag = nil
		if DugisGuideViewer:IsModuleLoaded("Guides") and DugisGuideViewer.tags[CurrentQuestIndex] then
			isWTag = DugisGuideViewer.tags[CurrentQuestIndex]:match("(|W|)")~=nil
		end
		
		local point
		if DugisArrow:getNumWaypoints()>0 then
			point = AddWaypoint(mapID, mapFloor, x, y, desc)
		else
			point = DGV:SetSmartWaypoint(mapID, mapFloor, x, y, desc)
			if not point then
				DGV:DebugFormat("DugisArrow:AddWaypoint No route found")
				point = AddWaypoint(mapID, mapFloor, x, y, desc)
			end
			point.isRouteWaypoint = nil
		end
		point.guideIndex = guideIndex
		point.questId = questId or (DGV.qid and DGV.qid[guideIndex])
		point.isWTag = isWTag
		
		UID = UID + 1
		
		point.uid = UID
		DugisArrow:WaypointsChanged()
		return UID
	end

	function DugisArrow:getNumWaypoints( )
		return (DugisArrow.waypoints and #DugisArrow.waypoints) or 0
	end

	function DugisArrow:getFirstWaypoint()
		if DugisArrow.waypoints then
			return DugisArrow.waypoints[1]
		end
	end

	function DugisArrow:SetNextWaypoint(removeMe)
		local waypoint

		--DebugPrint("SetNextWaypoint stack:"..debugstack())
		--DebugPrint("SetNextWaypoint removeMe:"..tostring(removeMe).." getNumWaypoints:"..getNumWaypoints())
		if DugisArrow:getNumWaypoints() > 1 or removeMe then
			waypoint = DugisArrow:DidPlayerReachWaypoint()
			waypoint = removeMe or ((waypoint.isWTag or waypoint.isRouteWaypoint) and waypoint) or DugisArrow:getFirstWaypoint()
			DugisArrow:RemoveWaypoint(waypoint)
			if waypoint.isWTag then
				DugisArrow:AddWaypoint(waypoint.map, waypoint.floor, waypoint.x, waypoint.y, waypoint.desc, waypoint.guideIndex, waypoint.questId)
			end

			waypoint = DugisArrow:getFirstWaypoint()

			if waypoint then
				if UseTomTomArrow() or UseCarboniteArrow() then
					TomTom:SetCrazyArrow( waypoint.tomtom, 5, waypoint.desc )
				else
					DugisArrow:setArrow( waypoint.map, waypoint.floor, waypoint.x, waypoint.y, waypoint.desc, waypoint )
				end
				PlaySoundFile("sound\\interface\\magicclick.wav")
				UIErrorsFrame:AddMessage("Waypoint reached",1,1,1,1)
			end
		end
	end

	function DugisArrow:DidPlayerReachWaypoint()
		local dist

		for _, waypoint in pairs(DugisArrow.waypoints) do
			dist = DugisGuideViewer:GetDistanceFromPlayer(waypoint.map, waypoint.floor, waypoint.x, waypoint.y)
			--if dist then DebugPrint("dist="..dist) end
			if dist and dist < 15 and 
				not waypoint.flightMasterID and 
				not waypoint.destID 
			then
				return waypoint
			end
			if waypoint.destID and 
				waypoint.destID==DugisArrow.map
			then
				return waypoint
			end
		end

	end

	function DugisArrow:GetDistanceToWaypoint(waypoint)
		return DugisGuideViewer.astrolabe:GetDistanceToIcon(waypoint.minimap)
	end

	function DugisGuideViewer:PrintCoords()
		for _, waypoint in pairs(DugisArrow.waypoints) do
			DebugPrint("waypoints uid:"..waypoint.uid.." M:"..waypoint.map.." F:"..waypoint.floor.." X:"..waypoint.x.." Y:"..waypoint.y.." desc:"..waypoint.desc)
		end
	end

	function DugisGuideViewer:RemoveAllWaypoints()
		if DugisArrow.waypoints then
			local wps = GetWaypointsCopy()
			for _, waypoint in ipairs(wps) do
				DugisArrow:RemoveWaypoint(waypoint, true)
			end
			wps = nil
			DugisArrow.waypoints = nil
		end
		DugisArrow:Hide()
		DugisArrow:WaypointsChanged()
	end

	function DugisArrow:ClearArrow( )
		DugisArrow:SetNextWaypoint(DugisArrow:getFirstWaypoint())
	end
	
	function RemoveWaypointAt(index)
		local waypoint = table.remove(DugisArrow.waypoints, index)
		if waypoint.tomtom then DugisArrow:RemoveTomTomWaypoint(waypoint.tomtom) end
		DugisGuideViewer:RemoveMinimapIcon(waypoint.minimap)
		waypoint.worldmap.icon:Hide()
		waypoint.worldmap:Hide()
		table.insert(pool, waypoint)
		if DugisArrow:getNumWaypoints() == 0 then 
			DugisArrow:Hide()
		end
		return
	end

	function DugisArrow:RemoveWaypoint(waypoint, suppressChangedEvent)
		--DebugPrint("Try to delete waypoint:"..waypoint.x..","..waypoint.y)
		local index = 1
		while index<=#(DugisArrow.waypoints) do
			local val = DugisArrow.waypoints[index]
			if val == val then
				RemoveWaypointAt(index)
				break
			elseif val.isRouteWaypoint then
				RemoveWaypointAt(index)
			else
				index = index+1
			end
		end
		if not suppressChangedEvent then
			DugisArrow:WaypointsChanged()
		end
	end

	function DugisGuideViewer:RemoveMinimapIcon(point)
		DugisGuideViewer.astrolabe:RemoveIconFromMinimap(point)
	end

	local minimap_count = 0
	local rad_135 = math.rad(135)
	local square_half = math.sqrt(0.5)
	function DugisArrow.Minimap_OnUpdate(self, elapsed)

		local dist,x,y = DugisGuideViewer.astrolabe:GetDistanceToIcon(self)
		if not dist then
			self:Hide()
			return
		end

		minimap_count = minimap_count + elapsed

		if minimap_count < 0.1 then return end
		minimap_count = 0

		local edge = DugisGuideViewer.astrolabe:IsIconOnEdge(self)

		if DugisGuideViewer.WrongInstanceFloor then
			self.icon:Hide()
			self.arrow:Hide()
		elseif edge then
			self.icon:Hide()
			self.arrow:Show()

			local angle = DugisGuideViewer.astrolabe:GetDirectionToIcon(self)

			angle = angle + rad_135
			if GetCVar("rotateMinimap") == "1" then
				local cring = GetPlayerFacing()
				angle = angle - cring
			end

			local sin,cos = math.sin(angle) * square_half, math.cos(angle) * square_half
			self.arrow:SetTexCoord(0.5-sin, 0.5+cos, 0.5+cos, 0.5+sin, 0.5-cos, 0.5-sin, 0.5+sin, 0.5-cos)
		else
			self.icon:Show()
			self.arrow:Hide()
		end

	end

	function DugisArrow:RemoveTomTomWaypoint(waypoint)
		DugisArrow.CallingRemoveWaypoint = true
		TomTom:RemoveWaypoint(waypoint)
		DugisArrow.CallingRemoveWaypoint = nil
	end

	--[[local function IsValidCurrentWaypoint(posX, posY, desc)
		local waypoints = DugisGuideViewer.DugisArrow.waypoints
		if waypoints then
			for _, waypoint in pairs(waypoints) do
				--DebugPrint(string.format("Debug IsValidCurrentWaypoint: waypoint.desc=%s desc=%s waypoint.x=%s posX=%s waypoint.y=%s posY=%s",waypoint.desc, desc, waypoint.x, posX, waypoint.y,posY))
				if waypoint.desc == desc and waypoint.x == posX and waypoint.y == posY then
					return true
				end
			end
		end
		return false
	end

	function DugisArrow:GuideIndexHasWaypoint(index)
		local desc = DugisGuideViewer:GetQuestDescription(index)
		local XYVals = DugisGuideViewer:getCoords(index)
		local waypoints = DugisGuideViewer.DugisArrow.waypoints
		if waypoints and XYVals and #XYVals>0 and desc then
			for _, coord in ipairs(XYVals) do
				local x, y = unpack(coord)
					if IsValidCurrentWaypoint(x, y, desc) then return 1 end
			end
		end
		return false
	end

	function DugisArrow:QuestPOIHasWaypoint(qid)
		local _, posX, posY = QuestPOIGetIconInfo(qid)
		local numEntries = QuestMapUpdateAllQuests()
		if poiWorldMapPOIFrame_Swap and
			poiWorldMapPOIFrame_Swap.quest and
			poiWorldMapPOIFrame_Swap.quest.questId==qid
		then
			if IsValidCurrentWaypoint(posX*100, posY*100, GetPOIWaypointDescription(poiWorldMapPOIFrame_Swap)) then
				return true
			end
		end

		local questCount = 0
		local numCompletedQuests = 0
		for i = 1, numEntries do
			local questId, questLogIndex = QuestPOIGetQuestIDByVisibleIndex(i);
		if ( questLogIndex and questLogIndex > 0 ) then
				questCount = questCount + 1;
				local isComplete = select(7, GetQuestLogTitle(questLogIndex))
				if ( isComplete ) then
					numCompletedQuests = numCompletedQuests + 1;
				end
				local poiButton = _G["poiWorldMapPOIFrame"..tostring(QUEST_POI_NUMERIC).."_"..tostring(questCount - numCompletedQuests)];
				if poiButton and poiButton.questId==qid then
					--DebugPrint("Debug QuestPOIHasWaypoint: qid="..tostring(qid))
					if IsValidCurrentWaypoint(posX*100, posY*100, GetPOIWaypointDescription(poiButton)) then
						--DebugPrint("Debug QuestPOIHasWaypoint: valid")
						return true
					end
				end
			end
		end
		return false
	end]]

	function DugisArrow:GetFirstWaypointGuideIndex()
		local waypoints = DugisGuideViewer.DugisArrow.waypoints
		if waypoints then
			for _, waypoint in pairs(waypoints) do
				if waypoint.guideIndex then return waypoint.guideIndex end
			end
		end
		return nil
	end

	function DugisArrow:GetFirstWaypointQuestId()
		local waypoints = DugisGuideViewer.DugisArrow.waypoints
		if waypoints then
			for _, waypoint in pairs(waypoints) do
				if waypoint.questId then return waypoint.questId end
			end
		end
		return nil
	end


	function DugisArrow:WaypointsChanged()
		--DebugPrint("Debug WaypointsChanged: SmallFrame.Frame.Waypoint="..tostring(SmallFrame.Frame.Waypoint))
		local guideIndex = DugisArrow:GetFirstWaypointGuideIndex()
		local dist = DugisGuideViewer:ComputeDistance(DugisArrow.map, DugisArrow.floor, DugisArrow.pos_x, DugisArrow.pos_y, active_point.m, active_point.f, active_point.x, active_point.y)
		if DGV:IsModuleLoaded("SmallFrame") then
			if DGV.CurrentQuestIndex
				and guideIndex==DGV.CurrentQuestIndex and dist
			then
				DGV.Modules.SmallFrame.Frame.Waypoint:SetNormalTexture("Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\waypoint_selected.tga")
			else
				DGV.Modules.SmallFrame.Frame.Waypoint:SetNormalTexture("Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\waypoint.tga")
			end
		end

		if DGV:IsModuleLoaded("StickyFrame") then
			if DGV.Modules.StickyFrame.StickyQuests then
				for stickyIndex, questIndex in ipairs(DGV.Modules.StickyFrame.StickyQuests) do
					local sticky = _G["DGV_SFRow"..stickyIndex]
					if sticky and sticky.Waypoint and guideIndex==questIndex and dist then
						sticky.Waypoint:SetNormalTexture("Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\waypoint_selected.tga")
					elseif sticky then
						sticky.Waypoint:SetNormalTexture("Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\waypoint.tga")
					end
				end
			end
		end

		if DGV:IsModuleLoaded("Guides") then
			local visualRows = DGV.visualRows
			if visualRows then
				for index, row in ipairs(visualRows) do
					if row.WayPoint and guideIndex==index and dist then
						row.WayPoint:SetNormalTexture("Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\waypoint_selected.tga")
					else
						row.WayPoint:SetNormalTexture("Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\waypoint.tga")
					end
				end
			end
		end
		local questId = DugisArrow:GetFirstWaypointQuestId()
		DGV:SetUseItemByQID(questId)
		if guideIndex then
			DGV:SetTarget(guideIndex)
			if DGV:IsModelDataOn() then
				DGV:ShowModel(guideIndex)
			end
			if dist and dist > 15 then
				DGV.MapPreview:FadeInMap()
			end
		elseif questId then
			local questPOI = DGV:IterateQuestPOIs(function(poi)
				local id = poi.questId or (poi.quest and poi.quest.questId)
				if id==questId then return poi end
			end)
			if questPOI then
				DGV:WipeModels()
				DGV:WipeTargetNPCs()
				DGV:IterateGuideIndicesWithQID(questId, function(index)
					local action = DGV.actions[index]
					if questPOI.type==QUEST_POI_NUMERIC then
						if action=="C" or action=="N" or action=="K" then
							DGV.Modules.ModelViewer:AddIndexModels(index)
							DGV.Modules.Target:AddIndexNPCs(index)
						elseif action=="T" then
							return true
						end
					else
						if action=="T" then
							DGV.Modules.ModelViewer:AddIndexModels(index)
							DGV.Modules.Target:AddIndexNPCs(index)
							return true
						end
					end
				end)
				if DGV:IsModelDataOn() then
					DGV.Modules.ModelViewer:Finalize()
				end
				DGV:FinalizeTarget()
			end
			if dist and dist > 15 then
				DGV.MapPreview:FadeInMap()
			end
		end
		DGV:UpdateMiniBlobs()
	end

	--Notify us when TomTom removes waypoints, so we can delete our ant trail
	if TomTom then
		local function hook_RemoveWayPoint(self, tomtomway)
			if DugisArrow.waypoints and not DugisArrow.CallingRemoveWaypoint then
				for index, waypoint in ipairs(DugisArrow.waypoints) do
					if tomtomway[3]*100 == waypoint.x and tomtomway[4]*100 == waypoint.y then
						DugisArrow:SetNextWaypoint(waypoint)
					end
				end
			end
		end
		hooksecurefunc(TomTom, "RemoveWaypoint", hook_RemoveWayPoint)
	end

	if DugisGuideViewer.tomtomloaded then
		local function hook_RemoveAllWaypoints(self)
			DugisGuideViewer:RemoveAllWaypoints()
		end
		hooksecurefunc(StaticPopupDialogs["TOMTOM_REMOVE_ALL_CONFIRM"], "OnAccept", hook_RemoveAllWaypoints)
	end

	--local orig_WorldMapQuestPOI_OnClick = WorldMapQuestPOI_OnClick
	function DugisArrow:Load()
		DugisArrow:initArrow()
		
		function DugisArrow:WorldMapQuestPOI_OnClick(self, button, down)
			if button == "RightButton" and (IsControlKeyDown() or IsShiftKeyDown()) then
				DugisArrow:QuestPOIWaypoint(self, IsControlKeyDown())
			end
		end

		wayframe:SetScript("OnUpdate", OnUpdate)
		DugisArrow:Show()

		function DGV:OnMapChangeUpdateArrow( )
			--DebugPrint("##################onMapChangeUpdateArrow")
			if DugisArrow.waypoints then
				for index, waypoint in pairs(DugisArrow.waypoints) do
					--DGV:DebugFormat("onMapChangeUpdateArrow", "WorldMapButton:GetWidth()", WorldMapButton:GetWidth())
					DugisGuideViewer:PlaceIconOnWorldMap( WorldMapButton, waypoint.worldmap, waypoint.map, waypoint.floor, waypoint.x/100, waypoint.y/100 )
					DugisGuideViewer:PlaceIconOnMinimap( waypoint.minimap, waypoint.map, waypoint.floor, waypoint.x/100, waypoint.y/100 )
				end
			end
		end

		AlwaysUpdate = AlwaysUpdateFunc
	end

	function DugisArrow:Unload()
		DGV.WaypointsShown = false
		DugisArrow:Hide()
		DugisMapOverlayFrame:Hide()
		DugisMinimapOverlayFrame:Hide()
		--WorldMapQuestPOI_OnClick = orig_WorldMapQuestPOI_OnClick

		wayframe:SetScript("OnUpdate", nil)
		DugisGuideViewer.Ants:ClearAntTrail()
		DugisGuideViewer:RemoveAllWaypoints()
		DugisArrow:Hide()
		AlwaysUpdate = DGV.NoOp
	end
	
	hooksecurefunc("WorldMapFrame_Update", function()
			if GetCurrentMapContinent() == WORLDMAP_COSMIC_ID 
				and GetCurrentMapAreaID() == WORLDMAP_COSMIC_ID
				and not select(4,GetMapInfo()) --mini dungeons falsely resolving WORLDMAP_COSMIC_ID
			then
				DugisMapOverlayFrame:Hide()
			else
				DugisMapOverlayFrame:Show()
			end
		end)
end