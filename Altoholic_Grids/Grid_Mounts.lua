local addonName = "Altoholic"
local addon = _G[addonName]

local BI = LibStub("LibBabble-Inventory-3.0"):GetLookupTable()
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local WHITE		= "|cFFFFFFFF"

local ICON_NOTREADY = "\124TInterface\\RaidFrame\\ReadyCheck-NotReady:14\124t"
local ICON_READY = "\124TInterface\\RaidFrame\\ReadyCheck-Ready:14\124t"

local spellList
local currentSpellID
local currentPetTexture

local function SortPets(a, b)
	local textA = GetSpellInfo(a) or ""
	local textB = GetSpellInfo(b) or ""
	return textA < textB
end

if DataStore_Pets then
	table.sort(DataStore:GetMountList(), SortPets)
	table.sort(DataStore:GetCompanionList(), SortPets)
end

local DDM_Add = addon.Helpers.DDM_Add
local DDM_AddTitle = addon.Helpers.DDM_AddTitle
local DDM_AddCloseMenu = addon.Helpers.DDM_AddCloseMenu

local function CompanionOnClick(frame, button)
	if frame.id and ( button == "LeftButton" ) and ( IsShiftKeyDown() ) then
		local chat = ChatEdit_GetLastActiveWindow()
		if chat:IsShown() then
			local link = DataStore:GetCompanionLink(frame.id)
			if link then
				chat:Insert(link)
			end
		end
	end
end

-- *** PETS ***

local petList = {
	{	-- "Classic"
		4055, 10673, 10674, 10675, 10676, 10677, 10678, 10679, 10680, 10682,
		10683, 10684, 10685, 10688, 10695, 10696, 10697, 10698, 10703, 10704, 
		10706, 10707, 10709, 10711, 10714, 10716, 10717, 12243, 13548, 15048, 
		15049, 15067, 15999, 17707, 17708, 17709, 19772, 23811, 24696, 24988, 
		25162, 26010, 26045, 26529, 26533, 26541, 27241, 27570, 28505, 28738, 
		28739, 28740, 28871, 35239, 
	},
	{	-- "The Burning Crusade"
		40990, 33050, 43697, 43698, 46425, 46426, 42609, 45890, 54187, 40613, 
		40614, 40634, 44369, 36034, 43918, 46599, 39181, 39709, 45082, 51716, 
		35156, 35909, 36031, 36027, 36028, 36029, 35907, 35910, 35911, 48406, 
		48408, 51851, 32298, 40405, 53082, 40549, 45125, 45127, 30156, 49964, 
	},
	{	-- "Wrath of the Lich King"
		69452, 69539, 66520, 67527, 23530, 23531, 45174, 61773, 61472, 61991, 
		70613, 59250, 62561, 61725, 71840, 74932, 65382, 65381, 67413, 67414, 
		67415, 67416, 67418, 67419, 67420, 62491, 62508, 62510, 62513, 62516, 
		62542, 62562, 62564, 62674, 63712, 61348, 61349, 61350, 61351, 61357, 
		53316, 67417, 75134, 65358, 10713, 61855, 63318, 69002, 55068, 52615, 
		78381, 66030, 94070, 65682, 68767, 68810, 69677, 69541, 69535, 69536, 
		75906, 95787, 66096, 62609, 95786, 66096, 62746, 95909, 
	},
	{	-- "Cataclysm"
		16450, 65046, 75613, 78683, 78685, 81937, 82173, 84263, 84492, 84752, 
		87344, 89039, 89472, 89670, 90523, 90637, 91343, 92395, 92396, 92397, 
		92398, 93624, 93739, 93813, 93817, 93823, 93836, 93837, 93838, 96571, 
		96817, 96819, 97638, 97779, 98079, 98571, 98587, 98736, 99578, 99663, 
		99668, 100330,100576,100684,100970,101424,101493,101606,101733,101986,
		101989,102317,103074,103076,103125,103544,103549,103588,104047,104049,
		105122,
	},
}

for _, list in pairs(petList) do
	table.sort(list, SortPets)
end

local currentXPack = 1					-- default to wow classic

local xPacks = {
	EXPANSION_NAME0,	-- "Classic"
	EXPANSION_NAME1,	-- "The Burning Crusade"
	EXPANSION_NAME2,	-- "Wrath of the Lich King"
	EXPANSION_NAME3,	-- "Cataclysm"
	-- EXPANSION_NAME4,	-- "Mists of Pandaria"
}

local function OnXPackChange(self)
	currentXPack = self.value
	currentDDMText = (currentXPack <= #xPacks) and xPacks[currentXPack] or L["All-in-one"]
	addon.Tabs.Grids:SetViewDDMText(currentDDMText)
	addon.Tabs.Grids:Update()
end

local function PetDropDown_Initialize()
	for i, xpack in pairs(xPacks) do
		DDM_Add(xpack, i, OnXPackChange, nil, (i==currentXPack))
	end
	DDM_Add(L["All-in-one"], 5, OnXPackChange, nil, (currentXPack==5))
	
	DDM_AddCloseMenu()
end

local companionsCallbacks = {
	OnUpdate = function() 
			spellList = (currentXPack <= #xPacks) and petList[currentXPack] or DataStore:GetCompanionList()
		end,
	GetSize = function() return #spellList end,
	RowSetup = function(self, entry, row, dataRowID)
			currentSpellID = spellList[dataRowID]
			local petName, _
			petName, _, currentPetTexture = GetSpellInfo(currentSpellID)
			
			if petName then
				local rowName = entry .. row
				_G[rowName.."Name"]:SetText(WHITE .. petName)
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
			itemTexture:SetTexture(currentPetTexture)
			
			if DataStore:IsPetKnown(character, "CRITTER", currentSpellID) then
				itemTexture:SetVertexColor(1.0, 1.0, 1.0);
				itemText:SetText(ICON_READY)
			else
				itemTexture:SetVertexColor(0.4, 0.4, 0.4);
				itemText:SetText(ICON_NOTREADY)
			end
			itemButton.id = currentSpellID
		end,
	OnEnter = function(frame) 
			local id = frame.id
			if id then 
				AltoTooltip:SetOwner(frame, "ANCHOR_LEFT");
				AltoTooltip:ClearLines();
				AltoTooltip:SetHyperlink("spell:" ..id);
				AltoTooltip:Show();
			end
			
		end,
	OnClick = CompanionOnClick,
	OnLeave = function(self)
			AltoTooltip:Hide() 
		end,
		
	InitViewDDM = function(frame, title) 
			frame:Show()
			title:Show()
			
			currentDDMText = currentDDMText or xPacks[1]
			
			UIDropDownMenu_SetWidth(frame, 100) 
			UIDropDownMenu_SetButtonWidth(frame, 20)
			UIDropDownMenu_SetText(frame, currentDDMText)
			addon:DDM_Initialize(frame, PetDropDown_Initialize)
		end,
}


-- *** MOUNTS ***

local ICON_FACTION_ALLIANCE = "Interface\\Icons\\INV_BannerPVP_02"
local ICON_FACTION_HORDE = "Interface\\Icons\\INV_BannerPVP_01"

local iconAlliance = addon:TextureToFontstring(ICON_FACTION_ALLIANCE, 18, 18)		-- alliance only
local iconHorde = addon:TextureToFontstring(ICON_FACTION_HORDE, 18, 18)				-- horde only
local iconBoth = iconAlliance .. " " .. iconHorde											-- both only

local currentFaction = (UnitFactionGroup("player") == "Alliance") and 1 or 2

local factionLabels = {	
	FACTION_ALLIANCE,	
	FACTION_HORDE,	
	L["Both factions"],
	FACTION_ALLIANCE .. " & " .. L["Both factions"],
	FACTION_HORDE .. " & " .. L["Both factions"],
	ALL,
}

local factionIcons = {
	iconAlliance,
	iconHorde,
	iconBoth,
	iconAlliance .. " + " .. iconBoth,
	iconHorde .. " + " .. iconBoth,
	iconAlliance .. " + " .. iconHorde .. " + " .. iconBoth,
}

-- ** faction filter for mounts **
local allianceOnly = {
	[458] = true, 
	[470] = true, 
	[472] = true, 
	[6648] = true, 
	[6777] = true, 
	[6898] = true, 
	[6899] = true, 
	[8394] = true,
	[10789] = true, 
	[10793] = true, 
	[10873] = true, 
	[10969] = true, 
	[13819] = true, 
	[15779] = true, 
	[16055] = true, 
	[16056] = true, 
	[16082] = true, 
	[16083] = true, 
	[17229] = true, 
	[17453] = true, 
	[17454] = true, 
	[17459] = true, 
	[17460] = true, 
	[17461] = true, 
	[22717] = true, 
	[22719] = true, 
	[22720] = true, 
	[22723] = true, 
	[23214] = true, 
	[23219] = true, 
	[23221] = true, 
	[23222] = true, 
	[23223] = true, 
	[23225] = true, 
	[23227] = true, 
	[23228] = true, 
	[23229] = true, 
	[23238] = true, 
	[23239] = true, 
	[23240] = true, 
	[23338] = true, 
	[23510] = true, 
	[32235] = true, 
	[32239] = true, 
	[32240] = true, 
	[32242] = true, 
	[32289] = true, 
	[32290] = true, 
	[32292] = true, 
	[34406] = true, 
	[35710] = true, 
	[35711] = true, 
	[35712] = true, 
	[35713] = true, 
	[35714] = true, 
	[48027] = true, 
	[59785] = true, 
	[59791] = true, 
	[59799] = true, 
	[60114] = true, 
	[60118] = true, 
	[60424] = true, 
	[61229] = true, 
	[61425] = true, 
	[61465] = true, 
	[61470] = true, 
	[61996] = true, 
	[63232] = true, 
	[63636] = true, 
	[63637] = true, 
	[63638] = true, 
	[63639] = true, 
	[65637] = true, 
	[65638] = true, 
	[65640] = true, 
	[65642] = true, 
	[65643] = true, 
	[66087] = true, 
	[66090] = true, 
	[66847] = true, 
	[68057] = true, 
	[68187] = true, 
	[73629] = true, 
	[73630] = true, 
	[90621] = true, 
	[92231] = true, 
	[100332] = true,
	[103195] = true,
	[103196] = true,
	[107516] = true,

}

local hordeOnly = {
	[580] = true, 
	[6653] = true, 
	[6654] = true, 
	[8395] = true, 
	[10796] = true, 
	[10799] = true, 
	[16080] = true, 
	[16081] = true, 
	[16084] = true, 
	[17450] = true, 
	[17462] = true, 
	[17463] = true, 
	[17464] = true, 
	[17465] = true, 
	[18989] = true, 
	[18990] = true, 
	[18991] = true, 
	[18992] = true, 
	[22718] = true, 
	[22721] = true, 
	[22722] = true, 
	[22724] = true, 
	[23241] = true, 
	[23242] = true, 
	[23243] = true, 
	[23246] = true, 
	[23247] = true, 
	[23248] = true, 
	[23249] = true, 
	[23250] = true, 
	[23251] = true, 
	[23252] = true, 
	[23509] = true, 
	[32243] = true, 
	[32244] = true, 
	[32245] = true, 
	[32246] = true, 
	[32295] = true, 
	[32296] = true, 
	[32297] = true, 
	[33660] = true, 
	[34767] = true, 
	[34769] = true, 
	[34795] = true, 
	[35018] = true, 
	[35020] = true, 
	[35022] = true, 
	[35025] = true, 
	[35027] = true, 
	[35028] = true, 
	[55531] = true, 
	[59788] = true, 
	[59793] = true, 
	[59797] = true, 
	[60116] = true, 
	[60119] = true, 
	[61230] = true, 
	[61447] = true, 
	[61467] = true, 
	[61469] = true, 
	[61997] = true, 
	[63635] = true, 
	[63640] = true, 
	[63641] = true, 
	[63642] = true, 
	[63643] = true, 
	[64657] = true, 
	[64658] = true, 
	[64659] = true, 
	[64977] = true, 
	[65639] = true, 
	[65641] = true, 
	[65644] = true, 
	[65645] = true, 
	[65646] = true, 
	[66088] = true, 
	[66091] = true, 
	[66846] = true, 
	[68056] = true, 
	[68188] = true, 
	[69820] = true, 
	[69826] = true, 
	[87090] = true, 
	[87091] = true, 
	[92232] = true, 
	[93644] = true, 
	[100333] = true,
	[107517] = true,
}

local function RefreshMountList()
	if currentFaction == 6 then
		spellList = DataStore:GetMountList()
		return
	end
	
	spellList = {}
	
	if currentFaction == 1 then
		for spellID, _ in pairs(allianceOnly) do
			table.insert(spellList, spellID)
		end
		
	elseif currentFaction == 2 then
		for spellID, _ in pairs(hordeOnly) do
			table.insert(spellList, spellID)
		end

	elseif currentFaction == 3 then
		for _, spellID in pairs(DataStore:GetMountList()) do
			if not allianceOnly[spellID] and not hordeOnly[spellID] then		-- mount is not alliance or horde only ? add it
				table.insert(spellList, spellID)
			end
		end
		
	elseif currentFaction == 4 then
		for _, spellID in pairs(DataStore:GetMountList()) do
			if not hordeOnly[spellID] then		-- mount is not horde only ? add it
				table.insert(spellList, spellID)
			end
		end
		
	elseif currentFaction == 5 then
		for _, spellID in pairs(DataStore:GetMountList()) do
			if not allianceOnly[spellID] then		-- mount is not alliance only ? add it
				table.insert(spellList, spellID)
			end
		end
	end
	
	table.sort(spellList, SortPets)
end

local function OnFactionChange(self)
	currentFaction = self.value
	RefreshMountList()
	addon.Tabs.Grids:SetViewDDMText(factionLabels[currentFaction])
	addon.Tabs.Grids:Update()
end

local function MountDropDown_Initialize(self)
	DDM_AddTitle(FACTION)
	for index, label in ipairs(factionLabels) do
		DDM_Add(format("%s (%s)", WHITE..label, factionIcons[index]), index, OnFactionChange, nil, (index==currentFaction))
	end
	DDM_AddCloseMenu()
end

local mountsCallbacks = {
	OnUpdate = function() end,
	GetSize = function() return #spellList end,
	RowSetup = function(self, entry, row, dataRowID)
			currentSpellID = spellList[dataRowID]
			local petName, _
			petName, _, currentPetTexture = GetSpellInfo(currentSpellID)
			
			if petName then
				local icon
			
				if allianceOnly[currentSpellID] then
					icon = iconAlliance
				elseif hordeOnly[currentSpellID] then
					icon = iconHorde
				else
					icon = iconBoth
				end
			
				local rowName = entry .. row
				_G[rowName.."Name"]:SetText(WHITE .. petName .. "\n" .. icon)
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
			itemTexture:SetTexture(currentPetTexture)
			
			if DataStore:IsPetKnown(character, "MOUNT", currentSpellID) then
				itemTexture:SetVertexColor(1.0, 1.0, 1.0);
				itemText:SetText(ICON_READY)
			else
				itemTexture:SetVertexColor(0.4, 0.4, 0.4);
				itemText:SetText(ICON_NOTREADY)
			end
			itemButton.id = currentSpellID
		end,
	OnEnter = function(frame) 
			local id = frame.id
			if id then 
				AltoTooltip:SetOwner(frame, "ANCHOR_LEFT");
				AltoTooltip:ClearLines();
				AltoTooltip:SetHyperlink("spell:" ..id);
				AltoTooltip:Show();
			end
			
		end,
	OnClick = CompanionOnClick,
	OnLeave = function(self)
			AltoTooltip:Hide() 
		end,
		
	InitViewDDM = function(frame, title) 
			frame:Show()
			title:Show()

			currentFaction = currentFaction or ((UnitFactionGroup("player") == "Alliance") and 1 or 2)
			
			UIDropDownMenu_SetWidth(frame, 100) 
			UIDropDownMenu_SetButtonWidth(frame, 20)
			UIDropDownMenu_SetText(frame, factionLabels[currentFaction])
			addon:DDM_Initialize(frame, MountDropDown_Initialize)
			RefreshMountList()
		end,
}

local tab = addon.Tabs.Grids

tab:RegisterGrid(5, companionsCallbacks)
tab:RegisterGrid(6, mountsCallbacks)
