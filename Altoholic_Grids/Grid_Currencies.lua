local addonName = "Altoholic"
local addon = _G[addonName]

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local WHITE		= "|cFFFFFFFF"
local GREEN		= "|cFF00FF00"

local view
local isViewValid

local currentTokenType
local currentDDMText

local function HashToSortedArray(hash)
	local array = {}		-- order them
	for k, _ in pairs(hash) do
		table.insert(array, k)
	end
	table.sort(array)
	return array
end

local function GetUsedHeaders()
	local realm, account = addon.Tabs.Grids:GetRealm()
	
	local usedHeaders = {}
	local isHeader, name, num

	for _, character in pairs(DataStore:GetCharacters(realm, account)) do	-- all alts on this realm
		num = DataStore:GetNumCurrencies(character) or 0
		
		for i = 1, num do
			isHeader, name = DataStore:GetCurrencyInfo(character, i)	-- save ech header found in the table
			if isHeader then
				usedHeaders[name] = true
			end
		end
	end
	
	return HashToSortedArray(usedHeaders)
end

local function GetUsedTokens(header)
	-- get the list of tokens found under a specific header, across all alts

	local realm, account = addon.Tabs.Grids:GetRealm()
	
	local tokens = {}
	local useData				-- use data for a specific header or not

	for _, character in pairs(DataStore:GetCharacters(realm, account)) do	-- all alts on this realm
		local num = DataStore:GetNumCurrencies(character) or 0
		for i = 1, num do
			local isHeader, name = DataStore:GetCurrencyInfo(character, i)
			
			if isHeader then
				if header and name ~= header then -- if a specific header (filter) was set, and it's not the one we chose, skip
					useData = nil
				else
					useData = true		-- we'll use data in this category
				end
			else
				if useData then		-- mark it as used
					tokens[name] = true
				end
			end
		end
	end
	
	return HashToSortedArray(tokens)
end

local function BuildView()
	view = GetUsedTokens(currentTokenType)
	isViewValid = true
end

local DDM_Add = addon.Helpers.DDM_AddWithArgs
local DDM_AddCloseMenu = addon.Helpers.DDM_AddCloseMenu

local function OnTokenChange(self, header)
	currentTokenType = header
	currentDDMText = currentTokenType
	addon.Tabs.Grids:SetViewDDMText(currentDDMText)

	isViewValid = nil
	addon.Tabs.Grids:Update()
end

local function OnTokensAllInOne(self)
	currentTokenType = nil
	currentDDMText = L["All-in-one"]
	addon.Tabs.Grids:SetViewDDMText(currentDDMText)

	isViewValid = nil
	addon.Tabs.Grids:Update()
end

local function DropDown_Initialize()
	for _, header in ipairs(GetUsedHeaders()) do		-- and add them to the DDM
		DDM_Add(header, nil, OnTokenChange, header)
	end
	DDM_Add(L["All-in-one"], nil, OnTokensAllInOne)
	DDM_AddCloseMenu()
end

local callbacks = {
	OnUpdate = function() 
			if not isViewValid then
				BuildView()
			end
		end,
	GetSize = function() return #view end,
	RowSetup = function(self, entry, row, dataRowID)
			local token = view[dataRowID]

			if token then
				local rowName = entry .. row
				_G[rowName.."Name"]:SetText(WHITE .. token)
				_G[rowName.."Name"]:SetJustifyH("LEFT")
				_G[rowName.."Name"]:SetPoint("TOPLEFT", 15, 0)
			end
		end,
	ColumnSetup = function(self, entry, row, column, dataRowID, character)
			local itemName = entry.. row .. "Item" .. column;
			local itemTexture = _G[itemName .. "_Background"]
			local itemButton = _G[itemName]
			local itemText = _G[itemName .. "Name"]
			
			itemText:SetFontObject("NumberFontNormalSmall")
			itemText:SetJustifyH("CENTER")
			itemText:SetPoint("BOTTOMRIGHT", 5, 0)
			itemTexture:SetDesaturated(0)
			itemTexture:SetTexCoord(0, 1, 0, 1)

			local token = view[dataRowID]
			local _, _, count, icon = DataStore:GetCurrencyInfoByName(character, token)
			itemButton.count = count
		
			if count then 
				itemTexture:SetTexture(icon)
				itemTexture:SetVertexColor(0.5, 0.5, 0.5);	-- greyed out
				itemButton.key = character
				
				if count >= 100000 then
					count = format("%2.1fM", count/1000000)
				elseif count >= 10000 then
					count = format("%2.0fk", count/1000)
				elseif count >= 1000 then
					count = format("%2.1fk", count/1000)
				end
				
				itemText:SetText(GREEN..count)
				itemButton:SetID(dataRowID)
				itemButton:Show()
			else
				itemButton.key = nil
				itemButton:SetID(0)
				itemButton:Hide()
			end
		end,
	OnEnter = function(frame) 
			local character = frame.key
			if not character then return end
			
			AltoTooltip:SetOwner(frame, "ANCHOR_LEFT")
			AltoTooltip:ClearLines()
			AltoTooltip:AddLine(DataStore:GetColoredCharacterName(character))
			-- AltoTooltip:AddLine(view[frame:GetParent():GetID()], 1, 1, 1)
			AltoTooltip:AddLine(view[frame:GetID()], 1, 1, 1)
			AltoTooltip:AddLine(GREEN..frame.count)
			AltoTooltip:Show()
		end,
	OnClick = nil,
	OnLeave = function(frame)
			AltoTooltip:Hide() 
		end,
	InitViewDDM = function(frame, title) 
			frame:Show()
			title:Show()

			currentDDMText = currentDDMText or currentTokenType
			
			UIDropDownMenu_SetWidth(frame, 100) 
			UIDropDownMenu_SetButtonWidth(frame, 20)
			UIDropDownMenu_SetText(frame, currentDDMText)
			addon:DDM_Initialize(frame, DropDown_Initialize)
		end,
}

local headers = GetUsedHeaders()
currentTokenType = headers[1]

addon.Tabs.Grids:RegisterGrid(3, callbacks)
