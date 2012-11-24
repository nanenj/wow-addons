local DGV = DugisGuideViewer
local BBW = DGV:RegisterModule("BossButtonWorkaround")
BBW.essential = true

function BBW:Initialize()
	hooksecurefunc("SetMapByID", function(id)
		local cont = DGV:GetCZByMapId(id)
		if cont==0 then
			cont = GetCurrentMapContinent()
			if cont==-1 then 
				SetMapToCurrentZone()
				return 
			end --prevent TheWanderingIsles issue
		end
		SetMapZoom(cont, GetCurrentMapZone()) --prevent green map in mini dungeons
	end)
	
	hooksecurefunc("SetDungeonMapLevel", function(f) --doesn't work for world minidungeons
		if f==GetCurrentMapDungeonLevel() then return end
		local m = GetCurrentMapAreaID()
		SetMapToCurrentZone()
		local playerMap,playerFloor = GetCurrentMapAreaID(), GetCurrentMapDungeonLevel()
		if playerMap==m and playerFloor==f then return end
		SetMapByID(m)
	end)
	
	function DGV:SafeMapUpdate()
		RefreshWorldMap()
	end
	
	function DGV:SafeSetMapQuestId(qid)
		WORLDMAP_SETTINGS.selectedQuestId = qid
		DGV:SafeMapUpdate()
	end
	
	function BBW:Load()
	end
	
	function BBW:Unload()
	end
end