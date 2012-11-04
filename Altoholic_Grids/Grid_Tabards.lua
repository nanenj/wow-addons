local addonName = "Altoholic"
local addon = _G[addonName]

local WHITE		= "|cFFFFFFFF"

local ICON_NOTREADY = "\124TInterface\\RaidFrame\\ReadyCheck-NotReady:14\124t"
local ICON_READY = "\124TInterface\\RaidFrame\\ReadyCheck-Ready:14\124t"

local tabardList
local currentItemID

local function BuildTabardList()
	tabardList = {}
	
	local tabardNames = {}	-- temp table, used to sort the list faster
	local criteriaID
	
	local TABARDS_ACHIEVEMENT_ID = 621
	local NUM_TABARDS = 89
	
	-- do not use GetAchievementNumCriteria(621) as it returns 1
	for i = 1, NUM_TABARDS do
		local _, _, _, _, _, _, _, _, _, criteriaID = GetAchievementCriteriaInfo(TABARDS_ACHIEVEMENT_ID, i)
		tabardNames[criteriaID] = GetAchievementCriteriaInfoByID(TABARDS_ACHIEVEMENT_ID, criteriaID)
		table.insert(tabardList, criteriaID)
	end
	
	-- sort on tabard name
	table.sort(tabardList, function(a,b) 
		return tabardNames[a] < tabardNames[b]
	end)
	
end

local function RefreshTabards()
	local tabardSlot = GetInventorySlotInfo("TabardSlot")
	local link = GetInventoryItemLink("player", tabardSlot)
	
	if link then
		addon.Tabs.Grids:Update()
	end
end

local callbacks = {
	OnUpdate = function() 
			if not tabardList then
				BuildTabardList()
				addon:RegisterEvent("UNIT_INVENTORY_CHANGED", RefreshTabards)
			end
		end,
	GetSize = function() return #tabardList end,
	RowSetup = function(self, entry, row, dataRowID)
			local tabardName, _
			tabardName, _, _, _, _, _, _, currentItemID = GetAchievementCriteriaInfoByID(621, tabardList[dataRowID] )
			
			if tabardName then
				local rowName = entry .. row
				_G[rowName.."Name"]:SetText(WHITE .. tabardName)
				_G[rowName.."Name"]:SetJustifyH("LEFT")
				_G[rowName.."Name"]:SetPoint("TOPLEFT", 15, 0)
			end
		end,
	ColumnSetup = function(self, entry, row, column, dataRowID, character)
			local itemName = entry.. row .. "Item" .. column;
			local itemTexture = _G[itemName .. "_Background"]
			local itemButton = _G[itemName]
			local itemText = _G[itemName .. "Name"]
			
			itemText:SetFontObject("GameFontNormalSmall")
			itemText:SetJustifyH("CENTER")
			itemText:SetPoint("BOTTOMRIGHT", 5, 0)
			itemTexture:SetDesaturated(0)
			itemTexture:SetTexCoord(0, 1, 0, 1)
			itemTexture:SetTexture(GetItemIcon(currentItemID))
			
			local criteriaID = tabardList[dataRowID]
			if DataStore:IsTabardKnown(character, criteriaID) then
				itemTexture:SetVertexColor(1.0, 1.0, 1.0);
				itemText:SetText(ICON_READY)
			else
				itemTexture:SetVertexColor(0.4, 0.4, 0.4);
				itemText:SetText(ICON_NOTREADY)
			end
			itemButton.id = currentItemID
		end,
	OnEnter = function(self) 
			self.link = nil
			addon:Item_OnEnter(self) 
		end,
	OnClick = function(self, button)
			self.link = nil
			addon:Item_OnClick(self, button)
		end,
	OnLeave = function(self)
			GameTooltip:Hide() 
		end,
		
	InitViewDDM = function(frame, title) 
			frame:Hide()
			title:Hide()
		end,
}

addon.Tabs.Grids:RegisterGrid(4, callbacks)
