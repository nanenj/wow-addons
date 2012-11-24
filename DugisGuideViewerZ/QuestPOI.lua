local DGV = DugisGuideViewer
local QuestPOI = DGV:RegisterModule("QuestPOI")
QuestPOI.essential = true

local QuestPOIFrame

function QuestPOI:Initialize()
	
	function DGV:InitializeQuestPOI()
		--DebugPrint("Debug: InitializeMiniQuestPOI");
		--Auto Select the current quest when the world map is opened
		--[[WorldMapFrame:HookScript("OnShow",
			function(arg)
				if _G["WorldMapQuestFrame1"]~=nil then
					DebugPrint("Debug WorldMapFrame_SelectQuestById")
					WorldMapFrame_SelectQuestById(DugisGuideViewer.qid[CurrentQuestIndex])
				end
			end);]]

		DGV:UpdateMiniBlobs()
	end

	function DGV:GetPOIByQID(qid)
		return DGV:IterateQuestPOIs(function(poi)
			local id = poi.questId or (poi.quest and poi.quest.questId)
			if id==qid then return poi end
		end, "WorldMapPOIFrame")
	end

	--WatchFrameLines
	--WorldMapPOIFrame
	function DGV:IterateQuestPOIs(delegate, parentName, numericPoiType)
		if not parentName then parentName="WorldMapPOIFrame" end
		if not numericPoiType then numericPoiType=QUEST_POI_NUMERIC end
		local numEntries = QuestMapUpdateAllQuests()
		local numEntries = QuestMapUpdateAllQuests()
		local breakVal = false
		if _G["poi"..parentName.."_Swap"] then
			breakVal = delegate(_G["poi"..parentName.."_Swap"])
		end
		if breakVal then return breakVal end
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
				local poiButton = _G["poi"..parentName..tostring(numericPoiType).."_"..tostring(questCount - numCompletedQuests)];
				if poiButton then
					breakVal = delegate(poiButton)
					if breakVal then return breakVal end
				end
			end
		end
		return false
	end
	
	local function OnClick(self, button)
		if QuestPOI.loaded then
			local qid = self.questId
			DGV.MapPreview.ForceMapPreview =
				(not WorldMapFrame:IsShown() or DGV.MapPreview:IsAnimating())
				and DGV:GetDB(DGV_MAPPREVIEWDURATION)~=0 and not DGV.carboniteloaded
			--DGV:DebugFormat("WatchFrameQuestPOI_OnClick", "forceMapPreview", DGV.MapPreview.ForceMapPreview)

			--local poi = DGV:GetPOIByQID(qid)
			--DGV:DebugFormat("OnClick", "QuestPOI.loaded", QuestPOI.loaded, "poi", poi, "qid", qid, "self", self);
			if self then
				DGV.DugisArrow:QuestPOIWaypoint(self, true)
			end
		end
	end
	
	local existingButtons = {}
	local function SetOnClick(parentName, buttonType, buttonIndex, questId)
		local buttonName = "poi"..parentName..buttonType.."_"..buttonIndex;
		if tContains(existingButtons, buttonName) then return end
		tinsert(existingButtons, buttonName)
		local poiButton = _G[buttonName];
		local swapButton;
		
		if poiButton then
			if parentName == "WatchFrameLines" then
				poiButton:HookScript("OnClick", OnClick)
			elseif parentName == "WorldMapPOIFrame" then
				poiButton:HookScript("OnClick", function(...) 
					DGV.Modules.DugisArrow:WorldMapQuestPOI_OnClick(...)
				end)
			end
		end
	end
	
	hooksecurefunc("QuestPOI_DisplayButton", SetOnClick)
	
	function QuestPOI:Load()
		DGV:InitializeQuestPOI()
	end

	function QuestPOI:Unload()
	end
end