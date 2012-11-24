local DGV = DugisGuideViewer
local CurrentAction = CurrentAction
local texture, item

local questItemFrame = CreateFrame("Button", "DugisGuideViewerQuestItemFrame", UIParent, "WatchFrameItemButtonTemplate")
local actionFrame = CreateFrame("Button", "DugisGuideViewerActionItemFrame", UIParent, "SecureActionButtonTemplate")
actionFrame:SetNormalTexture("Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\IconBorder")
actionFrame:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
actionFrame:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
local cooldown = CreateFrame("Cooldown", nil, actionFrame)
cooldown:SetAllPoints(actionFrame)
cooldown:Hide()
local function RefreshCooldown()
	if not item or not actionFrame:IsVisible() then return end
	local start, duration, enabled = GetItemCooldown(item)
	if enabled then
		cooldown:Show()
		cooldown:SetCooldown(start, duration)
	else cooldown:Hide() end
end
cooldown:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
cooldown:SetScript("OnEvent", RefreshCooldown)
actionFrame:SetScript("OnShow", RefreshCooldown)
local itemicon = actionFrame:CreateTexture(nil, "ARTWORK")
itemicon:SetWidth(28) itemicon:SetHeight(28)
itemicon:SetTexture("Interface\\Icons\\INV_Misc_Bag_08")
itemicon:SetAllPoints(actionFrame)
actionFrame:RegisterForClicks("anyUp")

local function OnClick()
	--DebugPrint("GetItemIcon(DugisGuideViewer.useitem[CurrentQuestIndex]) ="..GetItemIcon(DugisGuideViewer.useitem[CurrentQuestIndex]) .."itemicon:GetTexture()="..itemicon:GetTexture().."CurrentAction="..DugisGuideViewer.actions[CurrentQuestIndex])
	if DGV.actions and  DGV.actions[CurrentQuestIndex] == "U" then
		DebugPrint("Detected use item")
		DGV:SetChkToComplete(CurrentQuestIndex)
		DGV:MoveToNextQuest()	
	end
end

local function InitFrame(frame, other)
	frame:SetClampedToScreen(true);
	frame:SetHeight(28)
	frame:SetWidth(28)
	frame:SetPoint("CENTER", 0, 35)
	frame:Hide()
	frame:HookScript("OnClick", OnClick)
	frame:RegisterForDrag("LeftButton")
	frame:SetMovable(true)
	frame:SetUserPlaced(true)
	frame:SetClampedToScreen(true)
	frame:SetScript("OnDragStart", function(self)
		if not InCombatLockdown() then
			self.IsMoving = true
			self:StartMoving()
		end
	end)
	frame:SetScript("OnDragStop", function(self)
		self.IsMoving = false
		self:StopMovingOrSizing()
	end)
	frame:HookScript("OnUpdate", function(self)
		if not InCombatLockdown() and self.IsMoving then
			other:ClearAllPoints()
			other:SetPoint("LEFT", self)
			if DugisGuideViewer:IsModuleLoaded("Target") then
				DugisGuideViewer_TargetFrame:ClearAllPoints()
				DugisGuideViewer_TargetFrame:SetPoint("LEFT", self, "RIGHT", "5", "0")
			end
		end
	end)
end
InitFrame(questItemFrame, actionFrame)
InitFrame(actionFrame, questItemFrame)

local function OnEvent(self, event)
	if event == "PLAYER_REGEN_ENABLED" then
		questItemFrame:Hide()
		if texture and DGV:UserSetting(DGV_ITEMBUTTONON) then
			itemicon:SetTexture(texture)
			actionFrame:SetAttribute("type1", "item")
			actionFrame:SetAttribute("item1", "item:"..item)
			actionFrame:Show()
			texture = nil
		else
			actionFrame:SetAttribute("item1", nil)
			actionFrame:Hide()
		end
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	elseif event == "PLAYER_REGEN_DISABLED" then
		actionFrame:StopMovingOrSizing()
		questItemFrame:StopMovingOrSizing()
		questItemFrame.IsMoving = false
		questItemFrame.IsMoving = false
	end
end
actionFrame:SetScript("OnEvent", OnEvent)
actionFrame:RegisterEvent("PLAYER_REGEN_DISABLED")

--frame:SetFrameStrata("LOW")

local function SetQuestItemFrame(logIndex, icon, charges)
	if DGV:UserSetting(DGV_ITEMBUTTONON) then
		if InCombatLockdown() then 
			questItemFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
			questItemFrame:SetScript("OnEvent", function(self, event)
				if event == "PLAYER_REGEN_ENABLED" then
					SetQuestItemFrame(logIndex, icon, charges)
					self:UnregisterEvent("PLAYER_REGEN_ENABLED")
				end
			end)
		else
			DGV.ItemButton = questItemFrame
			questItemFrame:Show()
			questItemFrame:SetID(logIndex)
			SetItemButtonTexture(questItemFrame, icon);
			SetItemButtonCount(questItemFrame, charges);
			questItemFrame.charges = charges;
			--WatchFrameItem_UpdateCooldown(questItemFrame);
			questItemFrame.rangeTimer = -1;
			item, texture = nil, nil
			actionFrame:Hide()
		end
	end 
end

local function SetActionFrame(useitem)
	DGV.ItemButton = actionFrame
	item, texture = useitem, useitem and GetItemIcon(useitem)
	if InCombatLockdown() then actionFrame:RegisterEvent("PLAYER_REGEN_ENABLED") else OnEvent(actionFrame, "PLAYER_REGEN_ENABLED") end
end

function DGV:SetUseItem(index)
	--DGV:DebugFormat("SetUseItem", "stack", debugstack())
	if DGV:IsModuleLoaded("Guides") then
		local useitem = DGV.useitem[index]
		local logIndex = DGV:GetQuestLogIndexByQID(DGV.qid[index])
		local link, icon, charges, showItemWhenComplete, isComplete
		if logIndex then
			isComplete = select(7, GetQuestLogTitle(logIndex))
			link, icon, charges, showItemWhenComplete = GetQuestLogSpecialItemInfo(logIndex);
			--DebugPrint("Debug SetUseItem: logIndex="..tostring(logIndex).." DugisGuideViewer:GetItemIdFromLink(link)="..DugisGuideViewer:GetItemIdFromLink(link).." useitem="..useitem)
		end
		if not logIndex or not link or (logIndex and isComplete and not showItemWhenComplete) or 
			(useitem and DGV:GetItemIdFromLink(link)~=tonumber(useitem)) then
			SetActionFrame(useitem)
		else
			SetQuestItemFrame(logIndex, icon, charges)
		end
	end
end

function DGV:SetUseItemByQID(qid)
	if not DGV:IsModuleLoaded("Guides") then
		local logIndex = DGV:GetQuestLogIndexByQID(qid)
		local link, icon, charges, showItemWhenComplete, isComplete, useitem
		if logIndex then
			isComplete = select(7, GetQuestLogTitle(logIndex))
			link, icon, charges, showItemWhenComplete = GetQuestLogSpecialItemInfo(logIndex);
			if link then
				useitem = DGV:GetItemIdFromLink(link)
			end
		end
		if not logIndex or not link or (logIndex and isComplete and not showItemWhenComplete) or not useitem then
			SetActionFrame(useitem)
		else
			SetQuestItemFrame(logIndex, icon, charges)
		end
	end
end
