local L = DugisLocals

local eventFrame = CreateFrame("Frame")

eventFrame:RegisterEvent("PLAYER_ALIVE")
eventFrame:RegisterEvent("PLAYER_DEAD")
eventFrame:RegisterEvent("PLAYER_UNGHOST")
eventFrame:Hide()

eventFrame:SetScript("OnEvent", function(self, event, arg1, ...)

	if DugisGuideViewer.carboniteloaded or DugisGuideViewer.tomtomloaded or (not DugisGuideViewer.GuideOn) then return end

	if DugisGuideViewer:UserSetting(DGV_SHOWCORPSEARROW) then
		if event == "PLAYER_ALIVE" then
			DebugPrint("PLAYER_ALIVE")
			DugisGuideViewer.DugisArrow:Show()
			local corpseX, corpseY = GetCorpseMapPosition()
			DebugPrint("corpseX:"..corpseX.." corpseY:"..corpseY)
		
		elseif event == "PLAYER_DEAD" then
			DebugPrint("PLAYER_DEAD")
			DugisGuideViewer:RemoveAllWaypoints()
			
			local desc = L["My Corpse"]
			local m, f, x, y = DugisGuideViewer:GetPlayerPosition()
			DebugPrint("corpse position:".."M:"..m.." f:"..f.." x"..x.." y"..y)

			DugisGuideViewer.DugisArrow:AddWaypoint( m, f, x*100, y*100, desc)
			DugisGuideViewer.DugisArrow:setArrow( m, f, x*100, y*100, desc )
		
		elseif event == "PLAYER_UNGHOST" then
			DebugPrint("PLAYER_UNGHOST")
			DugisGuideViewer:RemoveAllWaypoints()
			if DugisGuideViewer.db.char.settings.EssentialsMode ~= 1 then 
				DugisGuideViewer:MapCurrentObjective()
			end 
		end
	end
end)

