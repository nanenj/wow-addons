local addonName = "Altoholic"
local addon = _G[addonName]

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local BI = LibStub("LibBabble-Inventory-3.0"):GetLookupTable()

local WHITE				= "|cFFFFFFFF"
local TEAL				= "|cFF00FF9A"
local YELLOW			= "|cFFFFFF00"
local GREEN				= "|cFF00FF00"
local RECIPE_GREY		= "|cFF808080"
local RECIPE_GREEN	= "|cFF40C040"
local RECIPE_ORANGE	= "|cFFFF8040"

local ICON_PLUS = "Interface\\Buttons\\UI-PlusButton-Up"
local ICON_MINUS = "Interface\\Buttons\\UI-MinusButton-Up"

local SKILL_GREY = 0
local SKILL_GREEN = 1
local SKILL_YELLOW = 2
local SKILL_ORANGE = 3
local SKILL_ANY = 4

local RecipeColors = { 
	[SKILL_GREY] = RECIPE_GREY,
	[SKILL_GREEN] = RECIPE_GREEN, 
	[SKILL_YELLOW] = YELLOW, 
	[SKILL_ORANGE] = RECIPE_ORANGE, 
}
local RecipeColorNames = { 
	[SKILL_GREY] = L["Grey"],
	[SKILL_GREEN] = BI["Green"], 
	[SKILL_YELLOW] = BI["Yellow"], 
	[SKILL_ORANGE] = BI["Orange"], 
}

local parent = "AltoholicFrameRecipes"
local view
local isViewValid
local currentProfession
local currentColor = SKILL_ANY
local currentSlots = ALL_INVENTORY_SLOTS
local currentSubClass = ALL_SUBCLASSES

local ns = addon.TradeSkills.Recipes		-- ns = namespace

-- *** Utility functions ***
local function GetCurrentProfessionTable()
	local character = addon.Tabs.Characters:GetAltKey()
	return DataStore:GetProfession(character, currentProfession)
end

local function GetLinkByLine(index)
	local profession = GetCurrentProfessionTable()
	local _, _, spellID = DataStore:GetCraftLineInfo(profession, index)
	
	return addon:GetRecipeLink(spellID, currentProfession)
end

function ns:GetRecipeColor(index)
	return RecipeColors[index]
end

function ns:GetRecipeColorName(index)
	return RecipeColors[index]..RecipeColorNames[index]
end

local function BuildView()
	view = view or {}
	wipe(view)

	local character = addon.Tabs.Characters:GetAltKey()
	local profession = DataStore:GetProfession(character, currentProfession)
	if not profession then return end
	
	local hideCategory		-- hide or show the current header ?
	local hideLine			-- hide or show the current line ?
	
	for index = 1, DataStore:GetNumCraftLines(profession) do
		local isHeader, color, info = DataStore:GetCraftLineInfo(profession, index)

		if isHeader then
			hideCategory = false
			if currentSubClass ~= ALL_SUBCLASSES and currentSubClass ~= info then
				hideCategory = true	-- hide if a specific subclass is selected AND we're not on it
			end

			if not hideCategory then
				table.insert(view, { id = index, isCollapsed = false } )
			end
		else		-- data line
			if not hideCategory then
				hideLine = false
				if currentColor ~= SKILL_ANY and currentColor ~= color then
					hideLine = true
				elseif currentSlots ~= ALL_INVENTORY_SLOTS then
					if info then	-- on a data line, info contains the itemID and is numeric
						local itemID = DataStore:GetCraftInfo(info)
						if itemID then
							local _, _, _, _, _, itemType, _, _, itemEquipLoc = GetItemInfo(itemID)

							if itemType == BI["Armor"] or itemType == BI["Weapon"] then
								if itemEquipLoc and strlen(itemEquipLoc) > 0 then
									if currentSlots ~= itemEquipLoc then
										hideLine = true
									end
								end
							else	-- not a weapon or armor ? then test if it's a generic "Created item"
								if currentSlots ~= NONEQUIPSLOT then
									hideLine = true
								end
							end
						else		-- enchants, like socket bracker, might not have an item id, so hide the line
							hideLine = true
						end
					else
						if currentSlots ~= NONEQUIPSLOT then
							hideLine = true
						end
					end
				end
				
				if not hideLine then
					table.insert(view, index)
				end
			end
		end
	end

	-- going from last to first, if two headers follow one another, it means that the smallest index is an empty category, so delete it
	for i = (#view - 1), 1, -1 do
		if type(view[i]) == "table" and type(view[i+1]) == "table" then
			table.remove(view, i)
		end
	end
	
	-- to avoid testing for exceptions in the previous loop, deal with the only shortcoming here (if the last entry is a table, it's an empty category, delete it)
	if type(view[#view]) == "table" then
		table.remove(view)
	end
	
	isViewValid = true
end

function ns:Update()
	if not isViewValid then
		BuildView()
	end

	local VisibleLines = 14
	local entry = parent.."Entry"
	
	local character = addon.Tabs.Characters:GetAltKey()
	local profession = DataStore:GetProfession(character, currentProfession)
	
	_G[parent .. "Info"]:Show()

	local curRank, maxRank = DataStore:GetProfessionInfo(DataStore:GetProfession(character, currentProfession))
	
	local offset = FauxScrollFrame_GetOffset( _G[ parent.."ScrollFrame" ] );
	local DisplayedCount = 0
	local VisibleCount = 0
	local DrawGroup = true
	local i=1
	
	local isHeader
	local isCollapsed
	
	for index, s in pairs(view) do
		if type(s) == "table" then
			isHeader = true
			isCollapsed = s.isCollapsed
		else
			isHeader = nil
		end
		
		if (offset > 0) or (DisplayedCount >= VisibleLines) then		-- if the line will not be visible
			if isHeader then													-- then keep track of counters
				if isCollapsed == false then
					DrawGroup = true
				else
					DrawGroup = false
				end
				VisibleCount = VisibleCount + 1
				offset = offset - 1		-- no further control, nevermind if it goes negative
			elseif DrawGroup then
				VisibleCount = VisibleCount + 1
				offset = offset - 1		-- no further control, nevermind if it goes negative
			end
		else		-- line will be displayed
			if isHeader then
				if isCollapsed == false then
					_G[ entry..i.."Collapse" ]:SetNormalTexture(ICON_MINUS)
					DrawGroup = true
				else
					_G[ entry..i.."Collapse" ]:SetNormalTexture(ICON_PLUS)
					DrawGroup = false
				end
				_G[entry..i.."Collapse"]:Show()
				_G[entry..i.."Craft"]:Hide()
				
				local _, _, name = DataStore:GetCraftLineInfo(profession, s.id)
				_G[entry..i.."RecipeLinkNormalText"]:SetText(TEAL .. name)
				_G[entry..i.."RecipeLink"]:SetID(0)
				_G[entry..i.."RecipeLink"]:SetPoint("TOPLEFT", 25, 0)

				for j=1, 8 do
					_G[ entry..i .. "Item" .. j ]:Hide()
				end
				
				_G[ entry..i ]:SetID(index)
				_G[ entry..i ]:Show()
				i = i + 1
				VisibleCount = VisibleCount + 1
				DisplayedCount = DisplayedCount + 1
				
			elseif DrawGroup then
				_G[entry..i.."Collapse"]:Hide()

				local _, color, spellID = DataStore:GetCraftLineInfo(profession, s)
				local itemID, reagents = DataStore:GetCraftInfo(spellID)
				
				if itemID then
					Altoholic:SetItemButtonTexture(entry..i.."Craft", GetItemIcon(itemID), 18, 18);
					_G[entry..i.."Craft"]:SetID(itemID)
					_G[entry..i.."Craft"]:Show()
				else
					_G[entry..i.."Craft"]:Hide()
				end
				
				if spellID then
					_G[entry..i.."RecipeLinkNormalText"]:SetText(addon:GetRecipeLink(spellID, currentProfession, RecipeColors[color]))
				else
					-- this should NEVER happen, like NEVER-EVER-ER !!
					_G[entry..i.."RecipeLinkNormalText"]:SetText(L["N/A"])
				end
				_G[entry..i.."RecipeLink"]:SetID(s)
				_G[entry..i.."RecipeLink"]:SetPoint("TOPLEFT", 32, 0)

				local j = 1
				
				if reagents then
					-- "2996x2;2318x1;2320x1"
					for reagent in reagents:gmatch("([^;]+)") do
						local itemName = entry..i .. "Item" .. j;
						local reagentID, reagentCount = strsplit("x", reagent)
						reagentID = tonumber(reagentID)
						
						if reagentID then
							reagentCount = tonumber(reagentCount)
							
							_G[itemName]:SetID(reagentID)
							Altoholic:SetItemButtonTexture(itemName, GetItemIcon(reagentID), 18, 18);

							local itemCount = _G[itemName .. "Count"]
							itemCount:SetText(reagentCount);
							itemCount:Show();
						
							_G[ itemName ]:Show()
							j = j + 1
						else
							_G[ itemName ]:Hide()
						end				
					end
				end
				
				while j <= 8 do
					_G[ entry..i .. "Item" .. j ]:Hide()
					j = j + 1
				end
					
				_G[ entry..i ]:SetID(index)
				_G[ entry..i ]:Show()
				i = i + 1
				VisibleCount = VisibleCount + 1
				DisplayedCount = DisplayedCount + 1
			end
		end
	end 

	while i <= VisibleLines do
		_G[ entry..i ]:SetID(0)
		_G[ entry..i ]:Hide()
		i = i + 1
	end
	
	local status = format("%s|r / %s", DataStore:GetColoredCharacterName(character), currentProfession)
	if VisibleCount == 0 then
		status = format("%s : %s", status, L["No data"])
	end
	AltoholicTabCharactersStatus:SetText(status)
	
	_G[parent]:Show()
	
	FauxScrollFrame_Update( _G[ parent.."ScrollFrame" ], VisibleCount, VisibleLines, 18);
end

function ns:SetCurrentProfession(prof)
	currentProfession = prof
end

function ns:SetCurrentColor(color)
	currentColor = color
end

function ns:GetCurrentColor()
	return currentColor
end

function ns:SetCurrentSlots(slot)
	currentSlots = slot
end

function ns:GetCurrentSlots()
	return currentSlots
end

function ns:SetCurrentSubClass(class)
	currentSubClass = class
end

function ns:GetCurrentSubClass()
	return currentSubClass
end

function ns:InvalidateView()
	isViewValid = nil
	if AltoholicFrameRecipes:IsVisible() then
		ns:Update()
	end
end


-- ** widgets **
function ns:ToggleAll(frame)
	-- expand or collapse all sections of the currently displayed alt /tradeskill
	if not frame.isCollapsed then
		frame.isCollapsed = true
		frame:SetNormalTexture(ICON_PLUS);
	else
		frame.isCollapsed = nil
		frame:SetNormalTexture(ICON_MINUS); 
	end
	
	for _, s in pairs(view) do
		if type(s) == "table" then		-- it's a header
			s.isCollapsed = (frame.isCollapsed) or false
		end
	end
	
	ns:Update()
end

function ns:RecipeLink_OnEnter(frame)
	local id = frame:GetID()
	if id == 0 then return end

	local link = GetLinkByLine(id)
	
	if link then
		GameTooltip:ClearLines();
		GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
		GameTooltip:SetHyperlink(link);
		GameTooltip:AddLine(" ",1,1,1);
		GameTooltip:Show();
	end
end

function ns:RecipeLink_OnClick(frame, button)
	if ( button == "LeftButton" ) and ( IsShiftKeyDown() ) then
		local chat = ChatEdit_GetLastActiveWindow()
		if chat:IsShown() then
			local id = frame:GetID()
			if id == 0 then return end

			local link = GetLinkByLine(id)
			if link then
				chat:Insert(link)
			end
		end
	end
end

function ns:Collapse_OnClick(frame, button)
	local id = frame:GetParent():GetID()
	if id ~= 0 then
		local s = view[id]
		if s.isCollapsed ~= nil then
			if s.isCollapsed == true then
				s.isCollapsed = false
			else
				s.isCollapsed = true
			end
		end
	end
	ns:Update()
end

function ns:Link_OnClick(frame, button)
	if ( button ~= "LeftButton" ) then
		return
	end
	
	if addon.Tabs.Characters:GetRealm() ~= GetRealmName() then
		addon:Print(L["Cannot link another realm's tradeskill"])
		return
	end

	local character = addon.Tabs.Characters:GetAltKey()
	local profession = DataStore:GetProfession(character, currentProfession)
	local link = profession.FullLink

	if not link then
		addon:Print(L["Invalid tradeskill link"])
		return
	end
	
	local chat = ChatEdit_GetLastActiveWindow()
	if chat:IsShown() then
		chat:Insert(addon.Tabs.Characters:GetAlt() .. ": " .. link);
	end
end
