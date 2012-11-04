local addonName = "Altoholic"
local addon = _G[addonName]

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local BI = LibStub("LibBabble-Inventory-3.0"):GetLookupTable()

local INFO_REALM_LINE = 0
local INFO_CHARACTER_LINE = 1
local INFO_TOTAL_LINE = 2

local SKILL_CAP = 600

local WHITE		= "|cFFFFFFFF"
local TEAL		= "|cFF00FF9A"
local RED		= "|cFFFF0000"
local ORANGE	= "|cFFFF7F00"
local YELLOW	= "|cFFFFFF00"
local GREEN		= "|cFF00FF00"

local RECIPE_GREY		= "|cFF808080"
local RECIPE_GREEN	= "|cFF40C040"
local RECIPE_ORANGE	= "|cFFFF8040"

local ICON_FACTION_HORDE = "Interface\\Icons\\INV_BannerPVP_01"
local ICON_FACTION_ALLIANCE = "Interface\\Icons\\INV_BannerPVP_02"

local ns = addon.TradeSkills		-- ns = namespace
local Characters = addon.Characters

local function DisplaySecondarySkillLevel(frame, field, spellID, line)
	local icon = addon:TextureToFontstring(addon:GetSpellIcon(spellID), 18, 18) .. " "
	local value = Characters:GetField(line, field)
	
	value = value or 0
	frame:SetText(icon .. ns:GetColor(value) .. value)
end

function ns:Update()
	local VisibleLines = 14
	local frame = "AltoholicFrameSkills"
	local entry = frame.."Entry"
	
	
	local DS = DataStore
	
	local offset = FauxScrollFrame_GetOffset( _G[ frame.."ScrollFrame" ] );
	local DisplayedCount = 0
	local VisibleCount = 0
	local DrawRealm
	local i=1
	
	for _, line in pairs(Characters:GetView()) do
		local lineType = Characters:GetLineType(line)
		
		if (offset > 0) or (DisplayedCount >= VisibleLines) then		-- if the line will not be visible
			if lineType == INFO_REALM_LINE then								-- then keep track of counters
				if Characters:GetField(line, "isCollapsed") == false then
					DrawRealm = true
				else
					DrawRealm = false
				end
				VisibleCount = VisibleCount + 1
				offset = offset - 1		-- no further control, nevermind if it goes negative
			elseif DrawRealm then
				VisibleCount = VisibleCount + 1
				offset = offset - 1		-- no further control, nevermind if it goes negative
			end
		else		-- line will be displayed
			if lineType == INFO_REALM_LINE then
				local _, realm, account = Characters:GetInfo(line)
				
				if Characters:GetField(line, "isCollapsed") == false then
					_G[ entry..i.."Collapse" ]:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up"); 
					DrawRealm = true
				else
					_G[ entry..i.."Collapse" ]:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
					DrawRealm = false
				end
				_G[entry..i.."Collapse"]:Show()
				_G[entry..i.."Name"]:SetWidth(300)
				_G[entry..i.."Name"]:SetPoint("TOPLEFT", 25, 0)
				_G[entry..i.."NameNormalText"]:SetWidth(300)
				if account == "Default" then	-- saved as default, display as localized.
					_G[entry..i.."NameNormalText"]:SetText(format("%s (%s".. L["Account"]..": %s%s|r)", realm, WHITE, GREEN, L["Default"]))
				else
					local last = addon:GetLastAccountSharingInfo(realm, account)
					_G[entry..i.."NameNormalText"]:SetText(format("%s (%s".. L["Account"]..": %s%s %s%s|r)", realm, WHITE, GREEN, account, YELLOW, last or ""))
				end
				_G[entry..i.."Level"]:SetText("")
				_G[entry..i.."Skill1NormalText"]:SetText("")
				_G[entry..i.."Skill2NormalText"]:SetText("")
				_G[entry..i.."CookingNormalText"]:SetText("")
				_G[entry..i.."FirstAidNormalText"]:SetText("")
				_G[entry..i.."FishingNormalText"]:SetText("")
				_G[entry..i.."RidingNormalText"]:SetText("")
				
				_G[ entry..i ]:SetID(line)
				_G[ entry..i ]:Show()
				i = i + 1
				VisibleCount = VisibleCount + 1
				DisplayedCount = DisplayedCount + 1
			elseif DrawRealm then
				if (lineType == INFO_CHARACTER_LINE) then
					local character = DS:GetCharacter( Characters:GetInfo(line) )
					
					local icon
					if DS:GetCharacterFaction(character) == "Alliance" then
						icon = addon:TextureToFontstring(ICON_FACTION_ALLIANCE, 18, 18) .. " "
					else
						icon = addon:TextureToFontstring(ICON_FACTION_HORDE, 18, 18) .. " "
					end
					
					_G[entry..i.."Collapse"]:Hide()
					_G[entry..i.."Name"]:SetWidth(170)
					_G[entry..i.."Name"]:SetPoint("TOPLEFT", 10, 0)
					_G[entry..i.."NameNormalText"]:SetWidth(170)
					_G[entry..i.."NameNormalText"]:SetText(icon .. format("%s (%s)", DS:GetColoredCharacterName(character), DS:GetCharacterClass(character)))
					_G[entry..i.."Level"]:SetText(GREEN .. DS:GetCharacterLevel(character))

					-- profession 1
					local field = Characters:GetField(line, "spellID1")
					if field then
						icon = addon:TextureToFontstring(addon:GetSpellIcon(field), 18, 18) .. " "
					else
						icon = ""
					end
					field = Characters:GetField(line, "skillRank1")
					if field then
						_G[entry..i.."Skill1NormalText"]:SetText(icon .. ns:GetColor(field) .. field)
					else
						_G[entry..i.."Skill1NormalText"]:SetText("")
					end
					
					-- profession 2
					field = Characters:GetField(line, "spellID2")
					if field then
						icon = addon:TextureToFontstring(addon:GetSpellIcon(field), 18, 18) .. " "
					else
						icon = ""
					end
					field = Characters:GetField(line, "skillRank2")
					if field then
						_G[entry..i.."Skill2NormalText"]:SetText(icon .. ns:GetColor(field) .. field)
					else
						_G[entry..i.."Skill2NormalText"]:SetText("")
					end
					
					DisplaySecondarySkillLevel(_G[entry..i.."CookingNormalText"], "cooking", 2550, line)
					DisplaySecondarySkillLevel(_G[entry..i.."FirstAidNormalText"], "firstaid", 3273, line)
					DisplaySecondarySkillLevel(_G[entry..i.."FishingNormalText"], "fishing", 131474, line)
					DisplaySecondarySkillLevel(_G[entry..i.."RidingNormalText"], "archa", 78670, line)

					
				elseif (lineType == INFO_TOTAL_LINE) then
					_G[entry..i.."Collapse"]:Hide()
					_G[entry..i.."Name"]:SetWidth(200)
					_G[entry..i.."Name"]:SetPoint("TOPLEFT", 15, 0)
					_G[entry..i.."NameNormalText"]:SetWidth(200)
					_G[entry..i.."NameNormalText"]:SetText(L["Totals"])
					_G[entry..i.."Level"]:SetText(Characters:GetField(line, "level"))
					_G[entry..i.."Skill1NormalText"]:SetText("")
					_G[entry..i.."Skill2NormalText"]:SetText("")
					_G[entry..i.."CookingNormalText"]:SetText("")
					_G[entry..i.."FirstAidNormalText"]:SetText("")
					_G[entry..i.."FishingNormalText"]:SetText("")
					_G[entry..i.."RidingNormalText"]:SetText("")
				end
				_G[ entry..i ]:SetID(line)
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

	FauxScrollFrame_Update( _G[ frame.."ScrollFrame" ], VisibleCount, VisibleLines, 18);
end	

function ns:OnEnter(frame)
	local line = frame:GetParent():GetID()
	local lineType = Characters:GetLineType(line)
	if lineType ~= INFO_CHARACTER_LINE then		
		return
	end
	
	local id = frame:GetID()
	local skillName, rank, suggestion
	
	if id == 1 then
		skillName = Characters:GetField(line, "skillName1")
	elseif id == 2 then
		skillName = Characters:GetField(line, "skillName2")
	elseif id == 3 then
		skillName = GetSpellInfo(2550)		-- cooking
	elseif id == 4 then
		skillName = GetSpellInfo(3273)		-- First Aid
	elseif id == 5 then
		skillName = GetSpellInfo(131474)		-- Fishing
	elseif id == 6 then
		skillName = GetSpellInfo(78670)		-- Archaeology
	end

	local DS = DataStore
	local character = DS:GetCharacter(Characters:GetInfo(line))
	local last = DataStore:GetModuleLastUpdateByKey("DataStore_Crafts", character)
	if not last then return end
	
	local curRank, maxRank = DS:GetProfessionInfo(DS:GetProfession(character, skillName))
	local profession = DS:GetProfession(character, skillName)
	
	if (id >= 1) and (id <= 6) then
		rank = ns:GetColor(curRank) .. curRank .. "/" .. maxRank
		suggestion = addon:GetSuggestion(skillName, curRank)
	elseif id == 7 then	-- class
		-- until we find out what happens with lockpicking, exit
		return
	end
	
	AltoTooltip:ClearLines();
	AltoTooltip:SetOwner(frame, "ANCHOR_RIGHT");
	AltoTooltip:AddLine(skillName,1,1,1);
	AltoTooltip:AddLine(GREEN..rank,1,1,1);
	
	if id <= 4 then	-- all skills except fishing & riding
		if DataStore:GetProfessionSpellID(skillName) ~= 2366 and skillName ~= GetSpellInfo(8613) then		-- no display for herbalism & skinning
			AltoTooltip:AddLine(" ");
			
			if not profession then
				AltoTooltip:AddLine(L["No data"]);
				AltoTooltip:Show();
				return
			end
		
			if DS:GetNumCraftLines(profession) == 0 then
				AltoTooltip:AddLine(L["No data"].. ": 0 " .. TRADESKILL_SERVICE_LEARN,1,1,1);
			else
				local orange, yellow, green, grey = DS:GetNumRecipesByColor(profession)
				
				AltoTooltip:AddLine(orange+yellow+green+grey .. " " .. TRADESKILL_SERVICE_LEARN,1,1,1);
				AltoTooltip:AddLine(format(WHITE .. "%d " .. RECIPE_GREEN .. "Green|r /" 
					..	WHITE .. " %d " .. YELLOW .. "Yellow|r /" 
					..	WHITE .. " %d " .. RECIPE_ORANGE .. "Orange", 
					green, yellow, orange))
			end
		end
	end
	
	AltoTooltip:AddLine(" ");
	AltoTooltip:AddLine(RECIPE_GREY .. L["Grey"] .. "|r " .. L["up to"] .. " " .. (floor(SKILL_CAP*0.25)-1),1,1,1);
	AltoTooltip:AddLine(RED .. RED_GEM .. "|r " .. L["up to"] .. " " .. (floor(SKILL_CAP*0.50)-1),1,1,1);
	AltoTooltip:AddLine(ORANGE .. BI["Orange"] .. "|r " .. L["up to"] .. " " .. (floor(SKILL_CAP*0.75)-1),1,1,1);
	AltoTooltip:AddLine(YELLOW .. YELLOW_GEM .. "|r " .. L["up to"] .. " " .. (SKILL_CAP-1),1,1,1);
	AltoTooltip:AddLine(GREEN .. BI["Green"] .. "|r " .. L["at"] .. " "..SKILL_CAP.." " .. L["and above"],1,1,1);

	if suggestion then
		AltoTooltip:AddLine(" ",1,1,1);
		AltoTooltip:AddLine(L["Suggestion"] .. ": ",1,1,1);
		AltoTooltip:AddLine(TEAL .. suggestion,1,1,1);
	end
	
	-- parse profession cooldowns
	if id ~= 7 and profession then
		DS:ClearExpiredCooldowns(profession)
		local numCooldows = DS:GetNumActiveCooldowns(profession)
		
		if numCooldows == 0 then
			AltoTooltip:AddLine(" ",1,1,1);
			AltoTooltip:AddLine(L["All cooldowns are up"],1,1,1);
		else
			AltoTooltip:AddLine(" ",1,1,1);
			for i = 1, numCooldows do
				local craftName, expiresIn = DS:GetCraftCooldownInfo(profession, i)
				AltoTooltip:AddDoubleLine(craftName, addon:GetTimeString(expiresIn));
			end
		end
	end
	
	AltoTooltip:Show();
end

local VIEW_MOUNTS = 8
local VIEW_PROFESSION = 12

function ns:OnClick(frame, button)
	local line = frame:GetParent():GetID()
	local lineType = Characters:GetLineType(line)
	if lineType ~= INFO_CHARACTER_LINE then		
		return
	end
	
	local id = frame:GetID()
	if id >= 5 then return end		-- fishing or archaeology ? do nothing
	
	local skillName
	if id == 1 then
		skillName = Characters:GetField(line, "skillName1")
	elseif id == 2 then
		skillName = Characters:GetField(line, "skillName2")
	elseif id == 3 then
		skillName = GetSpellInfo(2550)		-- cooking
	elseif id == 4 then
		skillName = GetSpellInfo(3273)		-- First Aid
	end

	local DS = DataStore
	local character = DS:GetCharacter(Characters:GetInfo(line))
	local last = DataStore:GetModuleLastUpdateByKey("DataStore_Crafts", character)
	if not last then return end
	
	local profession = DS:GetProfession(character, skillName)
	
	if skillName then
		if not profession or DS:GetNumCraftLines(profession) == 0 then		-- if profession hasn't been scanned (or scan failed), exit
			return
		end
	end
	
	local charName, realm, account = Characters:GetInfo(line)
	local chat = ChatEdit_GetLastActiveWindow()
	
	if chat:IsShown() and IsShiftKeyDown() and realm == GetRealmName() and id ~= 6 then
		-- if shift-click, then display the profession link and exit
		local link = profession.FullLink	
		if link and link:match("trade:") then
			chat:Insert(link);
		end
		return
	end

	addon.Tabs:OnClick("Characters")
	addon.Tabs.Characters:SetAlt(charName, realm, account)
	addon.Tabs.Characters:MenuItem_OnClick(AltoholicTabCharacters_Characters, "LeftButton")
	addon.Tabs.Characters:SetCurrentProfession(skillName)
end

local skillColors = { RECIPE_GREY, RED, ORANGE, YELLOW, GREEN }

function ns:GetColor(rank, skillCap)
	skillCap = skillCap or SKILL_CAP
	return skillColors[ floor(rank / (skillCap/4)) + 1 ]
end
