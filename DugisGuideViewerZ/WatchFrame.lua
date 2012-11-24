local DGV = DugisGuideViewer
if not DGV then return end

local WF = DGV:RegisterModule("DugisWatchFrame")
WF.essential = true

local function OnDragStart(frame)
	if not WF:ShouldModWatchFrame() then return end
	frame:StartMoving();
	frame.isMoving = true;
end

local function OnDragStop(self)
	if not WF:ShouldModWatchFrame() then return end
	self:StopMovingOrSizing();
	DGV.chardb.WatchFrameSnapped = false
	self.isMoving = false;
end

local function IncompatibleAddonLoaded()
	return DGV.carboniteloaded or DGV.sexymaploaded or DGV.nuiloaded or DGV.elvuiloaded or DGV.tukuiloaded or DGV.shestakuiloaded
end

local shouldInterceptWatchFramePoints = false
local function ShouldInterceptWatchFramePoints()
	if not DGV.db then return true end
	if IncompatibleAddonLoaded() then return false end
	return shouldInterceptWatchFramePoints;
end

local orig_WatchFrame_SetPoint = WatchFrame.SetPoint
local orig_WatchFrame_ClearAllPoints = WatchFrame.ClearAllPoints
local function SetMovable()
	if not WatchFrame:IsMovable() then
		WatchFrame:RegisterForDrag("LeftButton")
		WatchFrame:SetMovable(true)
		WatchFrame:SetResizable(true)
		WatchFrame:SetMinResize(WatchFrame:GetWidth(),80)
		WatchFrame:EnableMouse(true)
		WatchFrame:SetScript("OnDragStart", function(frame) OnDragStart(frame) end)
		WatchFrame:SetScript("OnDragStop", function(frame) OnDragStop(frame) end)
		WatchFrame:SetClampedToScreen()
		WatchFrame.SetPoint = function(...)
			if not ShouldInterceptWatchFramePoints() then
				orig_WatchFrame_SetPoint(...)
			end
		end
		WatchFrame.ClearAllPoints = function(...)
			if not ShouldInterceptWatchFramePoints() then
				orig_WatchFrame_ClearAllPoints(...)
			end
		end
		shouldInterceptWatchFramePoints = true
	end
end

SetMovable()
WatchFrame:SetUserPlaced(true)

function WF:Initialize()
	local oldWatchFrameHeight, newWatchFrameHeight = nil, nil
	local flashGroup, flash
	local L = DugisLocals
	
	function WF:ShouldModWatchFrame(forceLoaded)
		return not IncompatibleAddonLoaded() and (WF.loaded or forceLoaded)
	end

	local function UnsnapWatchFrame()
		if WF:ShouldModWatchFrame() then
			local point, relativeTo, relativePoint, xOfs, yOfs = WatchFrame:GetPoint(1)
			local left, right, center
			local top = WatchFrame:GetTop()
			left = WatchFrame:GetLeft()
			right = WatchFrame:GetRight()-UIParent:GetRight()
			center = left+(WatchFrame:GetRight()-left)/2-UIParent:GetWidth()/2

			orig_WatchFrame_ClearAllPoints(WatchFrame)

			if point and point:match(".*LEFT") then
				orig_WatchFrame_SetPoint(WatchFrame, "TOPLEFT", UIParent, "TOPLEFT", left, top-UIParent:GetHeight())
			elseif point and point:match(".*RIGHT") then
				orig_WatchFrame_SetPoint(WatchFrame, "TOPRIGHT", UIParent, "TOPRIGHT", right, top-UIParent:GetHeight())
			elseif top then
				orig_WatchFrame_SetPoint(WatchFrame, "TOP", UIParent, "TOP", center, top-UIParent:GetHeight())
			end
			
			SetMovable()
			if DGV:UserSetting(DGV_LOCKWATCHFRAME) then
				WatchFrame:SetMovable(false)
				WatchFrame:EnableMouse(false)
			end
		end
	end

	local function SnapWatchFrame(forceLoaded)
		if WF:ShouldModWatchFrame(forceLoaded) then
			shouldInterceptWatchFramePoints = false
			WatchFrame:ClearAllPoints()
			WatchFrame:SetPoint("TOPRIGHT", MinimapCluster, "BOTTOMRIGHT")
			WatchFrame:SetUserPlaced(false)
			UIParent_ManageFramePositions()
			WatchFrame:SetMovable(false)
			DGV.chardb.WatchFrameSnapped = true
		end
	end

	function WF:Reset()
		if WF:ShouldModWatchFrame() then
			SnapWatchFrame()
			UnsnapWatchFrame()
		end
	end

	local orig_WatchFrame_Collapse = WatchFrame_Collapse
	function WatchFrame_Collapse (self)
		UnsnapWatchFrame()
		orig_WatchFrame_Collapse(self)
	end
	
	local orig_WatchFrame_OnSizeChanged = WatchFrame_OnSizeChanged
	function WatchFrame_OnSizeChanged (self)
		WatchFrame_ClearDisplay();
		WatchFrame_Update(self)
	end

	local suspendCustomWatchFrameUpdate = false
	function WF:OnWatchFrame_Update()
		if suspendCustomWatchFrameUpdate or not WF.loaded then
			return
		end
		--if DGV.chardb.WatchFrameSnapped then SnapWatchFrame() end
		suspendCustomWatchFrameUpdate = true
		--[[if not WatchFrame.ResizeButton then
		WatchFrame.ResizeButton = CreateFrame("Button", nil, WatchFrame)
		WatchFrame.ResizeButton:SetPoint("BOTTOMRIGHT", WatchFrame, "BOTTOMRIGHT", -12, 6)
		WatchFrame.ResizeButton:SetWidth(16)
		WatchFrame.ResizeButton:SetHeight(16)
		WatchFrame.ResizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
		WatchFrame.ResizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
		WatchFrame.ResizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
		WatchFrame.ResizeButton:SetScript("OnMouseDown", function(self)
		WatchFrame:StartSizing("BOTTOM");
	end)
		WatchFrame.ResizeButton:SetScript("OnMouseUp", function(self)
		WatchFrame:StopMovingOrSizing();
		FCF_SavePositionAndDimensions(WatchFrame);
	end)
		WatchFrame.ResizeButton:Show()
	end]]
		DGV:OnWatchFrameUpdate()
		oldWatchFrameHeight = WatchFrame:GetHeight()
		if not oldWatchFrameHeight and WatchFrame:GetTop() and WatchFrame:GetBottom() then
			oldWatchFrameHeight = WatchFrame:GetTop() - WatchFrame:GetBottom()
		end
		UnsnapWatchFrame()
		
		if WF:ShouldModWatchFrame()
			and DugisGuideViewer:UserSetting(DGV_WATCHFRAMEBORDER)
			and not WatchFrame.collapsed
		then
			WF.WatchBackground:SetFrameStrata("BACKGROUND")
			--[[SmallFrame.WatchBackground:SetBackdrop( {
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
			edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
			tile = false, tileSize = 32, edgeSize = 32,
			insets = { left = 11, right = 12, top = 12, bottom = 11 }
		})]]
			DugisGuideViewer:SetFrameBackdrop(WF.WatchBackground,
			DugisGuideViewer.BACKGRND_PATH, DugisGuideViewer:GetBorderPath(), 10, 4, 12, 7)
			WF.WatchBackground:SetBackdropColor(0,0,0,1)
			WF.WatchBackground:SetPoint("TOPLEFT", -40, 8)
			WF.WatchBackground:SetPoint("BOTTOMRIGHT", 0, -8)
			WF.WatchBackground:Show()
		else
			WF.WatchBackground:Hide()
		end
		
		if WF:ShouldModWatchFrame() then
			local nextAnchor = nil;
			--WatchFrame_ResetLinkButtons();
			WatchFrame:SetHeight(math.huge)
			WatchFrame:GetTop()  --prevents movement of the WatchFrame as we calculate the height
			WatchFrame_Update()
			--DebugPrint("Debug OnWatchFrame_Update: #WATCHFRAME_OBJECTIVEHANDLERS="..tostring(#WATCHFRAME_OBJECTIVEHANDLERS))
			for i = 1, #WATCHFRAME_OBJECTIVEHANDLERS do
				nextAnchor = WATCHFRAME_OBJECTIVEHANDLERS[i](WatchFrameLines, nextAnchor, math.huge, WATCHFRAME_MAXLINEWIDTH);
				--DebugPrint("Debug watchframe loop i="..tostring(i).." nextAnchor="..tostring(nextAnchor))
			end
			local anchorBottom
			if nextAnchor then
				anchorBottom = nextAnchor:GetBottom()
			else
				WF.WatchBackground:Hide()
			end
			if nextAnchor and anchorBottom then
				newWatchFrameHeight = math.min(UIParent:GetTop()-anchorBottom+8,
					(UIParent:GetTop()-UIParent:GetBottom()-16))
				--DebugPrint("Debug OnWatchFrame_Update: newWatchFrameHeight="..tostring(newWatchFrameHeight))
			end
			WatchFrame:SetHeight(oldWatchFrameHeight)
			--[[if DGV:UserSetting(DGV_SMALLFRAMETRANSITION) == L["Scroll"] then
				UnsnapWatchFrame()
				SmallFrame:StartWatchFrameTransition()
			else]]
				if newWatchFrameHeight then
					WatchFrame:SetHeight(newWatchFrameHeight)
				end
				WatchFrame_Update()
				UnsnapWatchFrame()
			--end
		else
			WatchFrame_Update()
		end
		suspendCustomWatchFrameUpdate = false
	end
	
	hooksecurefunc("WatchFrame_Update", WF.OnWatchFrame_Update);

	function WF:RemoveObjectiveHandler(handler)
		local index
		for k, v in ipairs(WATCHFRAME_OBJECTIVEHANDLERS) do
			if v==handler then
				index = k
				break
			end
		end
		if index then tremove(WATCHFRAME_OBJECTIVEHANDLERS, index) end
	end

	function WF:AddObjectiveHandler(handler)
		local index
		for k, v in ipairs(WATCHFRAME_OBJECTIVEHANDLERS) do
			if v==handler then
				index = k
				break
			end
		end
		if not index then tinsert(WATCHFRAME_OBJECTIVEHANDLERS, 1,  handler) end
	end

	local orig_GetAchievementCriteriaInfo = GetAchievementCriteriaInfo;
	function WF:Load()
		-- Tracking achievement list with a high number of criteria can be computationally expensive
		-- The following code will optimize calls to GetAchievementCriteriaInfo by caching the data
		-- on the first call of a tracked achievement.
		local achievementCriteriaCache = {}
		local function GetAchievementCriteriaTable(id)
			--DGV:DebugFormat("GetAchievementCriteriaTable")
			local tbl = nil
			local i
			for i=1,GetAchievementNumCriteria(id) do
				if not tbl then tbl={} end
				tinsert(tbl, i, {orig_GetAchievementCriteriaInfo(id, i)})
			end
			return tbl
		end
		local lastFound;
		local lastFoundID
		function DGV:WatchFrame_CRITERIA_UPDATE()
			wipe(achievementCriteriaCache)
			lastFound = nil
			lastFoundID = nil
		end
		function GetAchievementCriteriaInfo(criteriaOrAchievementID, criteriaNum)
			if not criteriaNum then
				return orig_GetAchievementCriteriaInfo(criteriaOrAchievementID, criteriaNum)
			end
			local found = nil
			if lastFoundID==criteriaOrAchievementID then
				found = lastFound
			else
				local tracked = {GetTrackedAchievements()}
				if not tContains(tracked, criteriaOrAchievementID) then
					--DGV:DebugFormat("GetAchievementCriteriaInfo untracked.  Calling orig_GetAchievementCriteriaInfo")
					return orig_GetAchievementCriteriaInfo(criteriaOrAchievementID, criteriaNum)
				end
				local id, achieve
				for id, achieve in pairs(achievementCriteriaCache) do
					if not tContains(tracked, id) then
						tremove(achievementCriteriaCache, id)
					end
					if id == criteriaOrAchievementID then found = achieve end
				end
				if not found then
					found = GetAchievementCriteriaTable(criteriaOrAchievementID)
					achievementCriteriaCache[criteriaOrAchievementID] = found
				end
			end
			lastFoundID = criteriaOrAchievementID
			lastFound = found
			if not found then
				return
			end
			return unpack(found[criteriaNum])
		end

		if DGV.chardb.WatchFrameSnapped then SnapWatchFrame(true) end
		if DugisWatchBackground then 
			WF.WatchBackground = DugisWatchBackground 
			WF.WatchBackground:Show()
		else
			WF.WatchBackground = CreateFrame("Frame", "DugisWatchBackground", WatchFrame)
			WF.WatchBackground:SetClampedToScreen()
		end

		function WF:PlayFlashAnimation()
			if not WF.FlashFrame then
				flashGroup, flash, WF.FlashFrame = DGV:CreateFlashFrame(DugisWatchBackground)
			end
			
			if WF:ShouldModWatchFrame() and DGV:UserSetting(DGV_WATCHFRAMEBORDER)
				and DGV:UserSetting(DGV_SMALLFRAMETRANSITION) == L["Flash"]
			then
				--DGV:DebugFormat("PlayFlashAnimation showing", "flashGroup", flashGroup)
				WF.FlashFrame:Show()
				WF.FlashFrame:SetWidth(WF.WatchBackground:GetWidth() - 14)
				WF.FlashFrame:SetHeight(WF.WatchBackground:GetHeight() - 17)
				flashGroup:Play()
			else
				WF.FlashFrame:Hide()
			end
		end
	end

	function WF:Unload()
		GetAchievementCriteriaInfo = orig_GetAchievementCriteriaInfo
		if WF.FlashFrame then WF.FlashFrame:Hide() end
		--SnapWatchFrame()
		if WF.WatchBackground then
			WF.WatchBackground:Hide()
			WF.WatchBackground = nil
		end
	end
end
