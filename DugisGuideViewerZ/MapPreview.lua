local DGV = DugisGuideViewer
local MP = DGV:RegisterModule("MapPreview")
MP.essential = true
local L = DugisLocals

function MP:Initialize()
	DGV.MapPreview = MP

	local function IterateNonPreviewElements(delegate, unconditional)
		delegate(WorldMapFrameTitle, 1)
		delegate(WorldMapFrameMiniBorderLeft, 2)
		delegate(WorldMapFrameMiniBorderRight, 3)
		delegate(WorldMapFrameSizeUpButton, 4)
		delegate(WorldMapFrameSizeDownButton, 5)
		delegate(WorldMapFrameCloseButton, 6)
		delegate(WorldMapQuestShowObjectives, 7)
		delegate(WorldMapShowDigSites, 8)
		delegate(WorldMapFrameAreaLabel, 9)
		delegate(WorldMapFrameAreaDescription, 10)
		if DGV.CoordsFrame then
			delegate(DGV.CoordsFrame, 11)
		end
		delegate(WorldMapTrackQuest, 12)
		--delegate(WorldMapArchaeologyDigSites, 13)
		local numDetails = GetNumberOfDetailTiles()
		if unconditional or (GetCurrentMapZone() > 0 and DGV:MapHasOverlays()) then
			for i=1, numDetails do
				delegate(_G["WorldMapDetailTile"..i], 12+i)
			end
		end
		local levels = GetNumDungeonMapLevels()
		if levels and levels > 0 then
			delegate(WorldMapLevelDropDown, 12+numDetails+1)
		end
	end

	local nonPreviewElementsShown = {}
	local function RestoreNonPreviewElements()
		IterateNonPreviewElements(function(frame, index)
			if nonPreviewElementsShown[index] then
				frame:Show()
			end
		end, true)
	end

	local function HideNonPreviewElements()
		if not DugisGuideViewer:GetDB(DGV_MAPPREVIEWHIDEBORDER) then
			return
		end
		RestoreNonPreviewElements()
		IterateNonPreviewElements(function(frame, index)
			nonPreviewElementsShown[index] = frame:IsShown()
		end, true)
		IterateNonPreviewElements(function(frame, index)
			frame:Hide()
		end)
	end

	local function SupressNonPreviewElements()
		if not DugisGuideViewer:GetDB(DGV_MAPPREVIEWHIDEBORDER) then
			return
		end
		IterateNonPreviewElements(function(frame, index)
			frame:Hide()
		end)
	end

	local function IteratePreviewElements(delegate, unconditional)
		local numDetail = GetNumberOfDetailTiles()
		--[[if unconditional or GetCurrentMapZone() == 0 or not DGV:MapHasOverlays() then
			for i=1, numDetail do
				delegate(_G["WorldMapDetailTile"..i], i)
			end
		end]]
		--if DGV.CoordsFrame then
		--	delegate(DGV.CoordsFrame, numDetail+1)
		--end
		if DGV.DugisArrow.map_overlay then
			delegate(DGV.DugisArrow.map_overlay, numDetail+1)
		end
		if DGV.DugisArrow.waypoints and #DGV.DugisArrow.waypoints>0 then
			delegate(DGV.DugisArrow.waypoints[1].worldmap, numDetail+2)
		end
		delegate(WorldMapDetailFrame, numDetail+3)
		delegate(WorldMapBlobFrame, numDetail+4)
		delegate(WorldMapArchaeologyDigSites, numDetail+5)

		if unconditional or not DugisGuideViewer:GetDB(DGV_MAPPREVIEWHIDEBORDER) then
			IterateNonPreviewElements(function(frame, index)
				delegate(frame, index + numDetail+5)
			end)
		end
	end

	--[[local orig_PlaySound = PlaySound
	local function OverridePlaySound(sound)
		--DGV:DebugFormat("PlaySound", "sound", sound, "MP.DisableMapSound", MP.DisableMapSound, "stack", debugstack(2, 20))
		if (sound=="igQuestLogOpen" or sound=="igQuestLogClose") then return
		else
			orig_PlaySound(sound)
		end
	end

	function MP:SetAnimationHooks()
		if not InCombatLockdown() then
			DGV:DebugFormat("SetAnimationHooks")
			PlaySound = OverridePlaySound
		end
	end

	function MP:ResetAnimationHooks()
		DGV:DebugFormat("ResetAnimationHooks")
		PlaySound = orig_PlaySound
	end]]

	local orig_WorldMapBlobFrameShow = nil
	local orig_WorldMapArchaeologyDigSites = nil
	local no_op = function()end
	function MP:SetCombatHooks()
		if orig_WorldMapBlobFrameShow==nil and WorldMapBlobFrame then
			orig_WorldMapBlobFrameShow = WorldMapBlobFrame.Show
			--WorldMapFrameSizeUpButton:Disable()
		end
		if orig_WorldMapArchaeologyDigSites==nil and WorldMapArchaeologyDigSites then
			orig_WorldMapArchaeologyDigSites = WorldMapArchaeologyDigSites.Show
		end
		WorldMapBlobFrame.Show = no_op
		WorldMapArchaeologyDigSites.Show = no_op
	end

	function MP:ResetCombatHooks()
		if orig_WorldMapBlobFrameShow~=nil then
			WorldMapBlobFrame.Show = orig_WorldMapBlobFrameShow
			--WorldMapFrameSizeUpButton:Enable()
		end
		if orig_WorldMapArchaeologyDigSites~=nil then
			WorldMapArchaeologyDigSites.Show = orig_WorldMapArchaeologyDigSites
		end
	end

	--local resetWindowToggle = false
	local previewElementAlphas = {}
	local function ResetMapFade(noResize)
		if MP.IsAnimating and MP:IsAnimating() then
			DGV:DebugFormat("ResetMapFade IsAnimating")
			MP.FadeInAnimationGroup:Stop()
			MP.FadeOutAnimationGroup:Stop()
			RestoreNonPreviewElements()
			WorldMapFrame:SetAlpha(1)
			WorldMapBlobFrame_OnLoad(WorldMapBlobFrame)
			WorldMapArchaeologyDigSites:GetScript("OnLoad")(WorldMapArchaeologyDigSites)
			WorldMapArchaeologyDigSites:SetBorderAlpha(192)
			if MP.WaypointMapPing then MP.WaypointMapPing:Hide() end

			IteratePreviewElements(function(frame, index)
				frame:SetAlpha(previewElementAlphas[index] or 1)
			end, true)
			wipe(previewElementAlphas)
			DGV:SafeMapUpdate()
		end
		--MP:ResetAnimationHooks()
		DGV.DugisArrow:EnableMapClicks()
	end

	function DGV:PLAYER_REGEN_DISABLED ()
		MP:SetCombatHooks()
		if MP:IsAnimating() then
			--ResetMapFade();
			--WorldMapFrame_ToggleWindowSize()
			--resetWindowToggle = false
			HideUIPanel(WorldMapFrame)
		end
	end

	function DGV:PLAYER_REGEN_ENABLED ()
		MP:ResetCombatHooks()
	end

	local function HideNonWaypointPOIs()
		if DGV.DugisArrow.waypoints and #DGV.DugisArrow.waypoints>0 and
			DugisGuideViewer:GetDB(DGV_MAPPREVIEWPOIS)~="All Available Quests"
		then
			local hidePoiFunc = function(poi)
				local id = poi.questId or (poi.quest and poi.quest.questId)
				--DGV:DebugFormat("FadeInMap hide non waypoint pois", "waypoint qid", DGV.DugisArrow.waypoints[1].questId, "id", id)
				if DugisGuideViewer:GetDB(DGV_MAPPREVIEWPOIS)=="All Tracked Quests" then
					if not IsQuestWatched(GetQuestLogIndexByID(id)) then
						poi:Hide()
					end
				else
					if id~=DGV.DugisArrow.waypoints[1].questId then
						poi:Hide()
					end
				end
			end
			DGV:IterateQuestPOIs(hidePoiFunc, "WorldMapPOIFrame", QUEST_POI_NUMERIC)
			DGV:IterateQuestPOIs(hidePoiFunc, "WorldMapPOIFrame", QUEST_POI_COMPLETE_IN)
			DGV:IterateQuestPOIs(hidePoiFunc, "WorldMapPOIFrame", QUEST_POI_COMPLETE_OUT)
			DGV:IterateQuestPOIs(hidePoiFunc, "WorldMapPOIFrame", QUEST_POI_COMPLETE_SWAP)
		end
	end

	function MP:ConfigChanged()
		if MP.FadeInAnimationGroup then
			WorldMapFrame:Hide()
			ResetMapFade()
			MP.WaitAnimation:SetDuration(DugisGuideViewer:GetDB(DGV_MAPPREVIEWDURATION))
		end
		MP:FadeInMap()
	end

	function MP:IsAnimating()
		return (MP.FadeInAnimationGroup and MP.FadeInAnimationGroup:IsPlaying()) or
			(MP.FadeOutAnimationGroup and MP.FadeOutAnimationGroup:IsPlaying())
	end

	local WorldMapFrame = WorldMapFrame
	MP.ForceMapPreview = false
	MP.SupressToggleMap = false
	local fadingMap = nil
	function MP:FadeInMap()
		if (WorldMapFrame:IsShown() and not MP:IsAnimating() and not MP.ForceMapPreview)
			or DGV:GetDB(DGV_MAPPREVIEWDURATION)==0
			or DGV.carboniteloaded
			or WORLDMAP_SETTINGS.size ~= WORLDMAP_WINDOWED_SIZE
			or QuestFrame:IsShown()
			or GossipFrame:IsShown()
			or MerchantFrame:IsShown()
			or TaxiFrame:IsShown()
			or QuestLogFrame:IsShown()
			or SpellBookFrame:IsShown()
			or CharacterFrame:IsShown()			
			then return end
		local fadeMapId = DGV.DugisArrow.waypoints 
			and #DGV.DugisArrow.waypoints>0 
			and DGV.DugisArrow.waypoints[1].map
		--DGV:DebugFormat("FadeInMap", "fadeMapId", fadeMapId)
		if fadingMap~=fadeMapId then
			--DGV:DebugFormat("FadeInMap Resetting")
			ResetMapFade()
		end
		fadingMap = fadeMapId
		MP.ForceMapPreview = false
		--MP:SetAnimationHooks()
-- 		local wmbUpdate = WorldMapButton:GetScript("OnUpdate")
-- 		if wmbUpdate~=MP.WorldMapButton_OnUpdate then
-- 			DGV:DebugFormat("FadeInMap", "wmbUpdate", wmbUpdate)
-- 			orig_WorldMapButton_OnUpdate = wmbUpdate
-- 			WorldMapButton:SetScript("OnUpdate", MP.WorldMapButton_OnUpdate)
-- 		end
		--DGV:DebugFormat("FadeInMap")
		if not MP.FadeInAnimationGroup then
			ShowUIPanel(WorldMapFrame)
			--prevents error on early load
			if not WorldMapFrame:GetPoint(1) then
				--MP:ResetAnimationHooks()
				return
			end
			--DGV:DebugFormat("Debug FadeInMap: create MP.FadeInAnimationGroup","stack", debugstack())
			--[[DugisMapOverlayFrame:HookScript("OnEnter", function()
				ResetMapFade(true)
			end)]]

			MP.FadeInAnimationGroup = WorldMapButton:CreateAnimationGroup()
			MP.FadeInAnimationGroup:SetLooping("NONE")
			local fadeInAnimation = MP.FadeInAnimationGroup:CreateAnimation("DGV_FadeInMap")
			fadeInAnimation:SetDuration(.1)
			fadeInAnimation:SetOrder(1)
			fadeInAnimation:SetSmoothing("IN")
			fadeInAnimation:SetScript("OnPlay", function()
				IteratePreviewElements(function(frame, index)
					if not previewElementAlphas[index] then
						previewElementAlphas[index] = frame:GetAlpha()
					end
				end)
				--DGV:DebugFormat("Debug FadeInMap: playing")
				WorldMapFrame:SetAlpha(.01)
				WorldMapBlobFrame:SetBorderAlpha(.01)
				WorldMapBlobFrame:SetFillAlpha(.01)
				WorldMapArchaeologyDigSites:SetBorderAlpha(.01)
				WorldMapArchaeologyDigSites:SetFillAlpha(.01)
				if DGV.DugisArrow.waypoints and #DGV.DugisArrow.waypoints>0 then
					SetMapByID(DGV.DugisArrow.waypoints[1].map)
				end
				HideNonPreviewElements()
			end)
			fadeInAnimation:SetScript("OnFinished", function()
				--WorldMapFrame:SetAlpha(1)
				MP.FadeOutAnimationGroup:Play()
			end)
			fadeInAnimation:SetScript("OnUpdate", function(self)
				SupressNonPreviewElements()
				local progress = self:GetSmoothProgress()
				--DebugPrint("Debug FadeInMap: progress="..tostring(progress))
				WorldMapFrame:SetAlpha(progress*0.5)
				WorldMapBlobFrame:SetBorderAlpha(progress*0.5*192)
				WorldMapBlobFrame:SetFillAlpha(progress*0.5*128)
				WorldMapArchaeologyDigSites:SetBorderAlpha(progress*0.5*192)
				WorldMapArchaeologyDigSites:SetFillAlpha(progress*0.5*128)
			end)

			MP.FadeOutAnimationGroup = WorldMapButton:CreateAnimationGroup()
			MP.WaitAnimation = MP.FadeOutAnimationGroup:CreateAnimation("DGV_FadeInMapWait")
			MP.WaitAnimation:SetDuration(DugisGuideViewer:GetDB(DGV_MAPPREVIEWDURATION))
			MP.WaitAnimation:SetOrder(1)
			MP.WaitAnimation:SetScript("OnPlay", function(self)
				WorldMapFrame:SetAlpha(1)
				if not MP.WaypointMapPing then
					--prevents error on early load
					if not WorldMapButton:GetLeft() then
						MP.FadeOutAnimationGroup:Stop()
						HideUIPanel(WorldMapFrame)
						return
					end
					MP.WaypointMapPing = CreateFrame("Model", nil, WorldMapButton)
					MP.WaypointMapPing:SetModel([[Interface\MiniMap\Ping\MinimapPing.mdx]])
					MP.WaypointMapPing:SetWidth(100)
					MP.WaypointMapPing:SetHeight(100)
					--MP.WaypointMapPing:SetModelScale(.4)
					MP.WaypointMapPing:SetPoint("CENTER", WorldMapButton)
					local scale = UIParent:GetEffectiveScale();
					local hypotenuse = ( ( GetScreenWidth() * scale ) ^ 2 + ( GetScreenHeight() * scale ) ^ 2 ) ^ 0.5;
					--DGV:DebugFormat("Debug FadeInMap: create MP.WaypointMapPing","WorldMapDetailFrame:GetLeft()", WorldMapDetailFrame:GetLeft())
					local coordRight = ( MP.WaypointMapPing:GetRight() - MP.WaypointMapPing:GetLeft() ) / hypotenuse; -- X
					local coordTop = ( MP.WaypointMapPing:GetTop() - MP.WaypointMapPing:GetBottom() ) / hypotenuse; -- Y
					MP.WaypointMapPing:SetPosition(coordRight/2, coordTop/2, 255)
					MP.WaypointMapPing:SetSequence(0)
				end
				--WorldMapFrame_UpdateMap()
				IteratePreviewElements(function(frame, index)
					if not previewElementAlphas[index] then
						previewElementAlphas[index] = frame:GetAlpha()
					end
				end)
				IteratePreviewElements(function(frame, index)
					frame:SetAlpha(.5)
					if frame.SetBorderAlpha then
						frame:SetBorderAlpha(.5*255)
					end
					if frame.SetFillAlpha then
						frame:SetFillAlpha(.5*255)
					end
				end)
				if DGV.DugisArrow.waypoints and #DGV.DugisArrow.waypoints>0 then
					--DGV:DebugFormat("FadeInMap waitAnimation OnPlay", "x", DGV.DugisArrow.waypoints[1].x, "y", DGV.DugisArrow.waypoints[1].y)
					local wpx, wpy = DGV.DugisArrow.waypoints[1].x/100, DGV.DugisArrow.waypoints[1].y/100
					wpx = wpx * DugisMapOverlayFrame:GetWidth();
					wpy = -wpy * DugisMapOverlayFrame:GetHeight();
					MP.WaypointMapPing:SetPoint("CENTER", DugisMapOverlayFrame, "TOPLEFT", wpx, wpy)
					MP.WaypointMapPing:Show()
					DGV.DugisArrow.waypoints[1].worldmap:SetAlpha(1)
					SetMapByID(DGV.DugisArrow.waypoints[1].map)
				end
				MP.WaypointMapPing:SetAlpha(255)
				--[[if DGV.CoordsFrame then
					DGV.CoordsFrame:SetAlpha(1)
				end]]
				if DGV.DugisArrow.map_overlay then
					DGV.DugisArrow.map_overlay:SetAlpha(1)
				end
				--PlaySound("MapPing");
				--MP.WaypointMapPing.timer = 1;
			end)
			MP.WaitAnimation:SetScript("OnUpdate", function(self)
				SupressNonPreviewElements()
			end)
			MP.WaitAnimation:SetScript("OnFinished", function()
				MP.WaypointMapPing:Hide()
			end)

			local fadeOutAnimation = MP.FadeOutAnimationGroup:CreateAnimation("DGV_FadeOutMap")
			fadeOutAnimation:SetDuration(.1)
			fadeOutAnimation:SetOrder(2)
			fadeOutAnimation:SetSmoothing("OUT")
			fadeOutAnimation:SetScript("OnFinished", function()
				--DGV:DebugFormat("FadeInMap fadeOutAnimation OnFinished")
				HideUIPanel(WorldMapFrame)
			end)
			fadeOutAnimation:SetScript("OnUpdate", function(self)
				SupressNonPreviewElements()
				local progress = self:GetSmoothProgress()
				WorldMapFrame:SetAlpha((1-progress)*0.5)
				WorldMapBlobFrame:SetBorderAlpha((1-progress)*0.5*192)
				WorldMapBlobFrame:SetFillAlpha((1-progress)*0.5*128)
				WorldMapArchaeologyDigSites:SetBorderAlpha((1-progress)*0.5*192)
				WorldMapArchaeologyDigSites:SetFillAlpha((1-progress)*0.5*128)
			end)
		else
			--WorldMapFrame:Hide()
			--MP:SetAnimationHooks()
		end
		MP.SupressToggleMap = true
		--avoid closing guide frame when WorldMapFrame.Show won't cause taint
		if not InCombatLockdown() then
			WorldMapFrame:Show()
		else
			ShowUIPanel(WorldMapFrame)
		end

		MP.SupressToggleMap = false

		if MP:IsAnimating() then
			MP.FadeInAnimationGroup:Stop()
			MP.FadeOutAnimationGroup:Stop()
			MP.FadeOutAnimationGroup:Play()
		else
			MP.FadeInAnimationGroup:Play()
		end
		DGV.DugisArrow:DisableMapClicks()
	end

	--WorldMapFrame:HookScript("OnHide", function() ResetMapFade() end)

	hooksecurefunc("HideUIPanel", function(frame)
		if frame==WorldMapFrame then
			DGV:DebugFormat("HideUIPanel WorldMapFrame", "stack", debugstack(2, 20))
		end
		if frame==WorldMapFrame then
			ResetMapFade()
		end
	end)

	hooksecurefunc("WorldMapFrame_UpdateMap", function()
		if MP.IsAnimating and MP:IsAnimating() then
			HideNonWaypointPOIs()
		end
	end)

	function MP:Load()
		DGV:RegisterEvent("PLAYER_REGEN_DISABLED" );
		DGV:RegisterEvent("PLAYER_REGEN_ENABLED" );
	end

	function MP:Unload()
		DGV:UnregisterEvent("PLAYER_REGEN_DISABLED")
		DGV:UnregisterEvent("PLAYER_REGEN_ENABLED")
		
		ResetMapFade()
		MP:ResetCombatHooks()

-- 		if orig_WorldMapButton_OnUpdate then
-- 			WorldMapButton:SetScript("OnUpdate", orig_WorldMapButton_OnUpdate)
-- 		end
	end
end
