local MOD = DugisGuideViewer
local MiniBlobs = MOD:RegisterModule("MiniBlobs")
MiniBlobs.essential = true

function MiniBlobs:Initialize()
	function MiniBlobs:Load()
		function MOD:UpdateMiniBlobs()
			local qid = MOD.DugisArrow:GetFirstWaypointQuestId()
			if MOD:GetPOIByQID(qid) then
				WorldMapFrame_SelectQuestById(qid)
			end
		end

		function MOD:IsPlayerAtBlizzardDestination()
			local posX, posY = GetPlayerMapPosition("player");
			if posX then
				--Determine if the player is inside the destination, using the method the map uses to decide whether to pop a tooltip
				local questLogIndex, numObjectives = WorldMapBlobFrame:UpdateMouseOverTooltip(posX, posY);
				if questLogIndex and questLogIndex==MOD:GetQuestLogIndexByQID(MOD.DugisArrow:GetFirstWaypointQuestId()) then
					return true
				end
			end
			return false
		end
	end
		
	function MiniBlobs:Unload()
	end
end
