--[[ 
===============================================================
Dugi's Guides Viewer Addon License Agreement

Copyright (c) 2010 Brevoort Internet Marketing LTD
All rights reserved.

File Source: http://www.ultimatewowguide.com 
Author Name: Fransisco Brevoort
Email: fbrevoort@xtra.co.nz 

The contents of this addon, excluding third-party resources, are
copyrighted to its author with all rights reserved, under United
States copyright law and various international treaties.

In particular, please note that you may not distribute this addon in
any form, with or without modifications, including as part of a
compilation, without prior written permission from its author.

The author of this addon hereby grants you the following rights:

1. You may use this addon for private use only.

2. You may make modifications to this addon for private use only.

All rights not explicitly addressed in this license are reserved by
the copyright holder.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

local _
DugisGuideViewer = {
	events = {},
	eventFrame = CreateFrame("Frame"),
	RegisterEvent = function(self, event, method)
		self.eventFrame:RegisterEvent(event)
		self.events[event] = method or event
	end,
	UnregisterEvent = function(self, event)
		self.eventFrame:UnregisterEvent(event)
		self.events[event] = nil
	end,
	version = GetAddOnMetadata("DugisGuideViewer", "Version")
}

DugisGuideViewer.eventFrame:SetScript("OnEvent", function(self, event, ...)
	local method = DugisGuideViewer.events[event]
	--DebugPrint("###OnEvent() event ="..event)
	if method and DugisGuideViewer[method] then
		--DebugPrint("###OnEvent() event ="..event)
		--DebugPrint("###OnEvent() method found event ="..event)
		DugisGuideViewer[method](DugisGuideViewer, event, ...)
	end
end)

DugisGuideViewer:RegisterEvent("ADDON_LOADED")

DugisGuideUser = {
	QuestState = {}, --Tristate either skipped (x), finished (check) or neither (empty)
	turnedinquests = {},
	toskip = {},
	Debug = {},
}

local FirstTime = 1
local L = DugisLocals

if GetLocale() == "enUS" then
	DugisGuideViewer.Localize = 0
else
	DugisGuideViewer.Localize = 1
	
end

--local LastGuideNumRows = 0
local Debug = 0--Print Debug Messages
local Localize = 0	--Print Localization Error messages
local DebugFramesON = 1
local SettingsRevision = 4

DugisGuideViewer.Debug = Debug
DugisGuideViewer.ARTWORK_PATH = "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\"
DugisGuideViewer.BACKGRND_PATH = "Interface\\DialogFrame\\UI-DialogBox-Background"
DugisGuideViewer.EDGE_PATH = "Interface\\DialogFrame\\UI-DialogBox-Border"

function LocalizePrint(message)
	if Localize == 1 then
		print(message)
	end
end

function DebugPrint(message)
	if Debug == 1 then
		print(message)
	end
end

local function LoadSettings()
	local self = DugisGuideViewer
	--Settings Page Checkboxes
	DGV_QUESTLEVELON = 1
	DGV_LOCKSMALLFRAME = 2
	DGV_LOCKLARGEFRAME = 3
	DGV_WAYPOINTSON = 4
	DGV_ITEMBUTTONON = 5
	DGV_ENABLEQW = 6
	DGV_DUGIARROW = 7
	DGV_SHOWCORPSEARROW = 8
	DGV_CLASSICARROW = 9
	DGV_CARBONITEARROW = 10
	DGV_TOMTOMARROW = 11
	DGV_SHOWANTS = 12
	DGV_AUTOQUESTACCEPT = 13
	DGV_DISPLAYCOORDINATES = 14
	DGV_GUIDESUGGESTMODE = 15
	DGV_AUTOSELL = 16
	DGV_REMOVEMAPFOG = 17
	DGV_SMALLFRAMEBORDER = 18
	DGV_TARGETBUTTON = 19
	DGV_TARGETBUTTONSHOW = 20
	DGV_SHOWONOFF = 21
	DGV_STICKYFRAME = 22
	DGV_SHOWSMALLFRAME = 23
	--DGV_AUTOSTICK = 24
	DGV_DISPLAYMAPCOORDINATES = 24
	DGV_ENABLEMODELDB = 25
	DGV_ENABLENPCNAMEDB = 26
	DGV_ENABLEQUESTLEVELDB = 27
	DGV_ANCHOREDSMALLFRAME = 28
	DGV_QUESTCOLORON = 29
	DGV_MAPPREVIEWHIDEBORDER = 30
	DGV_UNLOADMODULES = 31
	DGV_LOCKWATCHFRAME = 32
	DGV_WATCHFRAMEBORDER = 33
	DGV_WORLDMAPTRACKING = 34
	DGV_AUTOQUESTITEMLOOT = 35
	
	--Sliders
	DGV_MINIBLOBQUALITY = 200
	DGV_SHOWTOOLTIP = 201
	DGV_RECORDSIZE = 202
	DGV_MAPPREVIEWDURATION = 203
	
	--Dropdowns
	DGV_GUIDEDIFFICULTY = 100
	DGV_SMALLFRAMETRANSITION = 101
	DGV_LARGEFRAMEBORDER = 102
	DGV_STEPCOMPLETESOUND = 103
	DGV_ANTCOLOR = 104
		
	--DGV_MINIBLOBS = 104
	DGV_TOOLTIPANCHOR = 105
	DGV_MAPPREVIEWPOIS = 106
	DGV_QUESTCOMPLETESOUND = 107
	
	--Custom
	DGV_TARGETBUTTONCUSTOM = 300

	local defaults = {
		char = {
			settings = {
				QuestRecordTable = {},
				QuestRecordEnabled = true,
				ModelViewer = {	pos_x = 300, pos_y = 45, relativePoint="CENTER"},
				StickyFrame = {	pos_x = 485, pos_y = 130, relativePoint="CENTER"},
				FirstTime = true,
				CurrentQuestIndex = 1,
				EssentialsMode = 0,
				SettingsRevision = 0,
				CharacterGUID = nil,
				WatchFrameSnapped = true,
				sz = 35, --Num check boxes
				[DGV_QUESTLEVELON] 		= { category = "Other",	text = "Display Quest Level", 	checked = false,	tooltip = "Show the quest level on the large and small frames", module = "Guides"},
				[DGV_QUESTCOLORON] 		= { category = "Other",	text = "Color Code Quest", 	checked = true,		tooltip = "Color code quest against your character's level", module = "Guides"},
				[DGV_LOCKSMALLFRAME] 		= { category = "Frames",	text = "Lock Small Frame", 	checked = false,	tooltip = "Lock small frame into place", module = "SmallFrame"},
				[DGV_LOCKWATCHFRAME] 		= { category = "Frames",	text = "Lock Watch Frame", 	checked = false,	tooltip = "Lock watch frame into place", module = "DugisWatchFrame"},
				[DGV_ANCHOREDSMALLFRAME] 	= { category = "Frames",	text = "Anchored Small Frame", 	checked = false,	tooltip = "Allow a fixed Anchored Small Frame that will integrate with the Objective Tracker", module = "SmallFrame"},
				[DGV_LOCKLARGEFRAME] 		= { category = "Frames",	text = "Lock Large Frame", 	checked = false,	tooltip = "Lock large frame into place", module = "Guides"},
				[DGV_WAYPOINTSON] 		= { category = "Waypoints",	text = "Automatic Waypoints", 	checked = true,		tooltip = "Map each destination",},
				[DGV_ITEMBUTTONON] 		= { category = "Questing",	text = "Item Button",		checked = true,		tooltip = "Shows a small window to click when an item is needed for a quest",},
				[DGV_ENABLEQW] 			= { category = "Questing",	text = "Automatic Quest Watch", checked = true,		tooltip = "", module = "Guides"},
				[DGV_DUGIARROW] 		= { category = "Waypoints",	text = "Show Dugi Arrow",	checked = true,		tooltip = "Show Dugis waypoint arrow",},
				[DGV_SHOWCORPSEARROW]		= { category = "Waypoints",	text = "Show Corpse Arrow",	checked = true,		tooltip = "Show the corpse arrow to direct you to your body", indent = true,},
				[DGV_CLASSICARROW] 		= { category = "Waypoints",	text = "Classic Arrow",		checked = true,		tooltip = "Switch between modern and classic arrow icons", indent = true,},
				[DGV_CARBONITEARROW] 		= { category = "Waypoints",	text = "Use Carbonite Arrow",	checked = false,	tooltip = "Use the Carbonite arrow instead of the built in arrow", },
				[DGV_TOMTOMARROW] 		= { category = "Waypoints",	text = "Use TomTom Arrow", 	checked = false,	tooltip = "Use the TomTom arrow instead of the built in arrow",},
				[DGV_SHOWANTS] 			= { category = "Waypoints",	text = "Show Ant Trail",	checked = true,		tooltip = "Display ant trail between waypoints on the world map",},
				[DGV_AUTOQUESTACCEPT] 		= { category = "Questing",	text = "Auto Quest Accept",	checked = false,	tooltip = "Automatically accept and turn in quests from NPCs. Disable with shift",},
				[DGV_AUTOSELL]         		= { category = "Other",		text = "Auto Sell Greys",    	checked = true,    	tooltip = "Automatically sell grey quality items to merchant NPCs",},
				[DGV_GUIDESUGGESTMODE] 		= { category = "Questing",	text = "Guide Suggest Mode",	checked = true,		tooltip = "Suggest guides for your player on level up", module = "Guides"},
				[DGV_SMALLFRAMEBORDER] 		= { category = "Borders",	text = "Small Frame Border",	checked = true,		tooltip = "Use the same border that is selected for the large frame", module = "SmallFrame"},
				[DGV_WATCHFRAMEBORDER] 		= { category = "Borders",	text = "Watch Frame Border",	checked = true,		tooltip = "Use the same border that is selected for the large frame", module = "DugisWatchFrame"},
				[DGV_REMOVEMAPFOG]     		= { category = "Maps",		text = "Remove Map Fog",  	checked = true,    	tooltip = "View undiscovered areas of the world map, type /reload in your chat box after change of settings",},
				[DGV_DISPLAYCOORDINATES]	= { category = "Tooltip",	text = "Tooltip Coordinates",	checked = false,	tooltip = "Show destination coordinates in the status frame tooltip", module = "Guides"},
				[DGV_TARGETBUTTON] 		= { category = "Target",	text = "Target Button",		checked = true,		tooltip = "Target the NPC needed for the quest step", module = "Target"},
				[DGV_TARGETBUTTONSHOW]		= { category = "Target",	text = "Show Target Button",	checked = true,		tooltip = "Show target button frame", indent = "true", module = "Target"},
				[DGV_SHOWONOFF]			= { category = "Frames",	text = "Show On/Off Button",	checked = true,		tooltip = "Show the On/Off button which enables or disables the guide", },
				[DGV_STICKYFRAME]		= { category = "Frames",	text = "Enable Sticky Frame",	checked = true,		tooltip = "Shift click a quest step to track in the frame", module = "StickyFrame" },
				[DGV_SHOWSMALLFRAME] 		= { category = "Frames",	text = "Show Small Frame", 	checked = true,		tooltip = "", module = "SmallFrame"},
				--[DGV_AUTOSTICK] 		= { category = "Other",		text = "Auto Stick", 		checked = true,		tooltip = "This feature will automatically add 'as you go...' step into sticky frame",},
				[DGV_DISPLAYMAPCOORDINATES] 	= { category = "Maps",		text = "Map Coordinates",  	checked = true,    	tooltip = "Show Player and Mouse coordinates at the bottom of the map.",},
				[DGV_WORLDMAPTRACKING] 		= { category = "Maps",		text = "World Map Tracking",  	checked = true,    	tooltip = "Add minimap tracking icons on the world map.",},
				[DGV_ENABLEMODELDB]		= { category = "Memory",	text = "Model Database",	checked = true,		tooltip = "Allows model viewer to function", module = "NpcsT"},
				[DGV_ENABLENPCNAMEDB]		= { category = "Memory",	text = "NPC Name Database",	checked = true,		tooltip = "Provides localized NPC names. Required for target button.", module = "NPC"},
				[DGV_ENABLEQUESTLEVELDB]	= { category = "Memory",	text = "Quest Level Database",	checked = true,		tooltip = "Shows minimum level required for quests", module = "ReqLevel"},
				[DGV_UNLOADMODULES]		= { category = "Memory",	text = "Unload Modules",	checked = false,	tooltip = "Unloading modules will allow the addon to run on low memory setting in Essential Mode  but will require a UI reload to return back to normal. ", module = "Guides"},
				[DGV_MAPPREVIEWHIDEBORDER]	= { category = "Map Preview",	text = "Hide Border",		checked = true,		tooltip = "Hides the minimized map border when map preview is on.",},
				[DGV_AUTOQUESTITEMLOOT]		= { category = "Questing",	text = "Auto Quest Item Loot",	checked = true,		tooltip = "Automatically loot quest items.",},
				
				[DGV_TARGETBUTTONCUSTOM]	= { category = "Target",	text = "Customize Macro",		checked = false,	tooltip = "Customize Target Macro", module = "Target", indent = true, editBox = "",},


				[DGV_GUIDEDIFFICULTY]		= { category = "Questing",	text = "Leveling Mode",			checked = "Normal", module = "Guides",
					options = {
						{	text = "Easy", colorCode = GREEN_FONT_COLOR_CODE, },
						{	text = "Normal", colorCode = YELLOW_FONT_COLOR_CODE, },
						{	text = "Hard", colorCode = ORANGE_FONT_COLOR_CODE, },
					}
				},
				[DGV_SMALLFRAMETRANSITION] 	= { category = "Borders",		text = "Small Frame Effect",	checked = "Flash", module = "SmallFrame",
					options = {
						{	text = "Flash", },
						{	text = "Scroll", },
					}
				},
				[DGV_LARGEFRAMEBORDER] 		= { category = "Borders",		text = "Borders",	checked = "Metal",
					options = {
						{	text = "Default", },
						{	text = "BlackGold", },
						{	text = "Bronze", },
						{	text = "DarkWood", },
						{	text = "ElvUI", },
						{	text = "Eternium", },
						{	text = "Gold", },
						{	text = "Metal", },
						{	text = "MetalRust", },
						{	text = "OnePixel", },
						{	text = "Stone", },
						{	text = "StonePattern", },
						{	text = "Thin", },
						{	text = "Wood", },
					}
				},
				[DGV_STEPCOMPLETESOUND]		= { category = "Questing",	text = "Step Complete Sound", checked = "Sound\\Interface\\MapPing.wav", module = "Guides",
					options = {
						{	text = "None", 			value	= nil },
						{	text = "Map Ping", 		value = [[Sound\Interface\MapPing.wav]]},
						{	text = "Window Close", 		value = [[Sound\Interface\AuctionWindowClose.wav]]},
						{	text = "Window Open", 		value = [[Sound\Interface\AuctionWindowOpen.wav]]},
						{	text = "Boat Docked", 		value = [[Sound\Doodad\BoatDockedWarning.wav]]},
						{	text = "Bell Toll Alliance", 	value = [[Sound\Doodad\BellTollAlliance.wav]]},
						{	text = "Bell Toll Horde",	value = [[Sound\Doodad\BellTollHorde.wav]]},
						{	text = "Explosion",		value = [[Sound\Doodad\Hellfire_Raid_FX_Explosion05.wav]]},
						{	text = "Shing!",		value = [[Sound\Doodad\PortcullisActive_Closed.wav]]},
						{	text = "Wham!",			value = [[Sound\Doodad\PVP_Lordaeron_Door_Open.wav]]},
						{	text = "Simon Chime",		value = [[Sound\Doodad\SimonGame_LargeBlueTree.wav]]},
						{	text = "War Drums",		value = [[Sound\Event Sounds\Event_wardrum_ogre.wav]]},
						{	text = "Humm",			value = [[Sound\Spells\SimonGame_Visual_GameStart.wav]]},
						{	text = "Short Circuit",		value = [[Sound\Spells\SimonGame_Visual_BadPress.wav]]},
					}
				},
				[DGV_ANTCOLOR]		= { category = "Waypoints",	text = "Ant Trail Color", checked = "Interface\\COMMON\\Indicator-Green",
					options = {
						{	text = "Gray", colorCode = GRAY_FONT_COLOR_CODE,	value	= [[Interface\COMMON\Indicator-Gray]] },
						{	text = "Green",  colorCode = GREEN_FONT_COLOR_CODE,	value = [[Interface\COMMON\Indicator-Green]]},
						{	text = "Red", colorCode = RED_FONT_COLOR_CODE,	value = [[Interface\COMMON\Indicator-Red]]},
						{	text = "Yellow", colorCode = YELLOW_FONT_COLOR_CODE,	value = [[Interface\COMMON\Indicator-Yellow]]},
					}
				},				
				[DGV_QUESTCOMPLETESOUND]		= { category = "Questing",	text = "Quest Complete Sound", checked = "Sound\\Creature\\Peon\\PeonBuildingComplete1.wav", module = "DugisWatchFrame",
					options = {
						{	text = "None", 			value	= nil },
						{	text = "Default", 		value = [[Sound\Creature\Peon\PeonBuildingComplete1.wav]]},
						{	text = "Troll Male", 		value = [[Sound\Character\Troll\TrollVocalMale\TrollMaleCongratulations01.wav]]},
						{	text = "Troll Female",		value = [[Sound\Character\Troll\TrollVocalFemale\TrollFemaleCongratulations01.wav]]},
						{	text = "Tauren Male",		value = [[Sound\Creature\Tauren\TaurenYes3.wav]]},
						{	text = "Tauren Female",		value = [[Sound\Character\Tauren\TaurenVocalFemale\TaurenFemaleCongratulations01.wav]]},
						{	text = "Undead Male",		value = [[Sound\Character\Scourge\ScourgeVocalMale\UndeadMaleCongratulations02.wav]]},
						{	text = "Undead Female",		value = [[Sound\Character\Scourge\ScourgeVocalFemale\UndeadFemaleCongratulations01.wav]]},
						{	text = "Orc Male",		value = [[Sound\Character\Orc\OrcVocalMale\OrcMaleCongratulations02.wav]]},
						{	text = "Orc Female",		value = [[Sound\Character\Orc\OrcVocalFemale\OrcFemaleCongratulations01.wav]]},
						{	text = "NightElf Female",	value = [[Sound\Character\NightElf\NightElfVocalFemale\NightElfFemaleCongratulations02.wav]]},
						{	text = "NightElf Male",		value = [[Sound\Character\NightElf\NightElfVocalMale\NightElfMaleCongratulations01.wav]]},
						{	text = "Human Female",		value = [[Sound\Character\Human\HumanVocalFemale\HumanFemaleCongratulations01.wav]]},
						{	text = "Human Male",		value = [[Sound\Character\Human\HumanVocalMale\HumanMaleCongratulations01.wav]]},
						{	text = "Gnome Male",		value = [[Sound\Character\Gnome\GnomeVocalMale\GnomeMaleCongratulations03.wav]]},
						{	text = "Gnome Female",		value = [[Sound\Character\Gnome\GnomeVocalFemale\GnomeFemaleCongratulations01.wav]]},
						{	text = "Dwarf Male",		value = [[Sound\Character\Dwarf\DwarfVocalMale\DwarfMaleCongratulations04.wav]]},
						{	text = "Dwarf Female",		value = [[Sound\Character\Dwarf\DwarfVocalFemale\DwarfFemaleCongratulations01.wav]]},
						{	text = "Draenei Male",		value = [[Sound\Character\Draenei\DraeneiMaleCongratulations02.wav]]},
						{	text = "Draenei Female",	value = [[Sound\Character\Draenei\DraeneiFemaleCongratulations03.wav]]},
						{	text = "BloodElf Female",	value = [[Sound\Character\BloodElf\BloodElfFemaleCongratulations03.wav]]},
						{	text = "BloodElf Male",		value = [[Sound\Character\BloodElf\BloodElfMaleCongratulations02.wav]]},
						{	text = "Worgen Male",		value = [[Sound\Character\PCWorgenMale\VO_PCWorgenMale_Congratulations01.wav]]},
						{	text = "Worgen Female",		value = [[Sound\Character\PCWorgenFemale\VO_PCWorgenFemale_Congratulations01.wav]]},
						{	text = "Goblin Male",		value = [[Sound\Character\PCGoblinMale\VO_PCGoblinMale_Congratulations01.wav]]},
						{	text = "Goblin Female",		value = [[Sound\Character\PCGoblinFemale\VO_PCGoblinFemale_Congratulations01.wav]]},
					}
				},
				[DGV_TOOLTIPANCHOR]			= {category = "Tooltip",	text = "Tooltip Anchor", checked = "Default", module = "SmallFrame",
					options = {
						{	text = "Default", },
						{	text = "Bottom", },
						{	text = "Top", },
						{	text = "Left", },
						{	text = "Right", },
						{	text = "Bottom Left", },
						{	text = "Bottom Right", },
						{	text = "Top Left", },
						{	text = "Top Right", },
					}
				},
				[DGV_MAPPREVIEWPOIS]			= {category = "Map Preview",	text = "Quest Objectives", checked = "Single Quest",
					options = {
						{	text = "All Available Quests", },
						{	text = "All Tracked Quests", },
						{	text = "Single Quest", },
					}
				},
				[DGV_MINIBLOBQUALITY]		= { category = "Maps",	text = "Minimap Blob Quality",	checked = 0 },
				[DGV_SHOWTOOLTIP]			= { category = "Tooltip",	text = "Show Tooltip", checked = 5, module = "SmallFrame", tooltip ="Amount of time the Tooltip will remain in view from the last mouse over on small frame" },
				[DGV_MAPPREVIEWDURATION]	= {	category = "Map Preview",	text = "Duration (Seconds)", checked = 5, tooltip = "Amount of time the Map Preview should remain in view (zero to disable).  Enabling this feature will automatically set the world map to windowed mode on reload." },
				[DGV_RECORDSIZE]			= { checked = 50 },
			},
		},
	}
	self.db 		= LibStub("AceDB-3.0"):New("DugisGuideViewerDB", defaults)
	self.chardb		= self.db.char.settings
end

local function Dugi_Fix()
	DugisGuideViewer:ClearScreen()
	CurrentTitle = nil
	DugisGuideViewer.CurrentTitle = nil
	CurrentQuestIndex = nil
	DugisGuideViewer.CurrentQuestIndex = nil
	CurrentQuestName = nil
	DugisGuideUser = {
		["toskip"] = {},
		["QuestState"] = {},
		["turnedinquests"] = {},
	}
	DugisGuideViewerDB = nil
end

local function ResetDB()
	local essentials = DugisGuideViewer.chardb.EssentialsMode
	local rev = DugisGuideViewer.chardb.SettingsRevision
	local guid = DugisGuideViewer.chardb.CharacterGUID
	Dugi_Fix()
	LoadSettings()
	DugisGuideViewer.chardb.CharacterGUID = UnitGUID("player") or guid or "PRIOR_RESET"
	DugisGuideViewer.chardb.SettingsRevision = SettingsRevision
	DugisGuideViewer.chardb.EssentialsMode = essentials
end

function DugisGuideViewer:OnInitialize()
	self:RegisterEvent("PLAYER_LOGIN");
	self:RegisterEvent("ZONE_CHANGED");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	self:RegisterEvent("CHAT_MSG_SYSTEM");
	self:RegisterEvent("QUEST_LOG_UPDATE")
	self:RegisterEvent("QUEST_AUTOCOMPLETE")
	self:RegisterEvent("QUEST_DETAIL")
	self:RegisterEvent("QUEST_COMPLETE")	
	self:RegisterEvent("UI_INFO_MESSAGE")
	--self:RegisterEvent("QUEST_QUERY_COMPLETE")
	self:RegisterEvent("ZONE_CHANGED_INDOORS")
	self:RegisterEvent("CHAT_MSG_LOOT")
	self:RegisterEvent("ACHIEVEMENT_EARNED")
	self:RegisterEvent("CRITERIA_UPDATE")
	self:RegisterEvent("TRADE_SKILL_UPDATE")
	self:RegisterEvent("PLAYER_LEVEL_UP")
	self:RegisterEvent("PLAYER_LOGOUT")
	self:RegisterEvent("PET_BATTLE_OPENING_START")
	
	CATEGORY_TREE = { 
		{ value = "Questing", 	text = L["Questing"], 	icon = nil },
		{ value = "Waypoints", 	text = L["Waypoints"], icon = nil },
		{ value = "Frames", 	text = L["Frames"], 	icon = nil },
		{ value = "Borders", 	text = L["Borders"], 	icon = nil },
		{ value = "Maps", 		text = L["Maps"], 		icon = nil },
		{ value = "Map Preview",text = L["Map Preview"],icon = nil },
		{ value = "Target",		text = L["Target Button"],	icon = nil },
		{ value = "Tooltip", 	text = L["Tooltip"], 	icon = nil },
		{ value = "Memory", 	text = L["Memory"], 	icon = nil },
		{ value = "Other", 		text = L["Other"], 	icon = nil },
	}

	if not DugisGuideViewer:IsModuleRegistered("Guides") then tremove(CATEGORY_TREE, 9) end --Memory will be empty
	if not DugisGuideViewer:IsModuleRegistered("Guides") then tremove(CATEGORY_TREE, 8) end --Tooltip
	if not DugisGuideViewer:IsModuleRegistered("Target") then tremove(CATEGORY_TREE, 7) end --Target
	
	LoadSettings()
	if self.db.char.settings.SettingsRevision~=SettingsRevision then
		DugisGuideViewer:DebugFormat("resetting self.db.char.settings.SettingsRevision", "revision", self.db.char.settings.SettingsRevision)
		ResetDB()
		self.db.char.settings.SettingsRevision=SettingsRevision;
	end
	if not DugisGuideViewer:IsModuleRegistered("Guides") then
		self.db.char.settings.EssentialsMode = 1
	end
	--self:InitMapping( )
	DugisGuideViewer:UpdateMainFrame()
	DugisGuideViewer:initAnts()
end

function DugisGuideViewer:initAnts()
	local addon
	for addon=1, GetNumAddOns() do
		local name, _, _, _, loadable  = GetAddOnInfo(addon)
		if name == "Carbonite" and loadable == 1 then DugisGuideViewer.carboniteloaded = true 
		elseif name == "TomTom" and loadable == 1 then DugisGuideViewer.tomtomloaded = true
		elseif name == "SexyMap" and loadable == 1 then DugisGuideViewer.sexymaploaded = false		
		elseif name == "nUI" and loadable == 1 then DugisGuideViewer.nuiloaded = true
		elseif name == "Tukui" and loadable == 1 then DugisGuideViewer.tukuiloaded = true
		elseif name == "ElvUI" and loadable == 1 then DugisGuideViewer.elvuiloaded = false
		elseif name == "ShestakUI" and loadable == 1 then DugisGuideViewer.shestakuiloaded = true
		elseif name == "Mapster" and loadable == 1 then DugisGuideViewer.mapsterloaded = true end
	end
	
	--if DugisGuideViewer.tomtomloaded then TomTom.profile.persistence.cleardistance = 0 end
	if DugisGuideViewer.carboniteloaded then 
		DugisGuideViewer:SetDB(false, DGV_SHOWANTS) 
	elseif DugisGuideViewer:UserSetting(DGV_CARBONITEARROW) then 
		DugisGuideViewer:SetDB(false, DGV_CARBONITEARROW)
	end
	if not DugisGuideViewer.tomtomloaded and DugisGuideViewer:UserSetting(DGV_TOMTOMARROW) then 
		DugisGuideViewer:SetDB(false, DGV_TOMTOMARROW) 
	end
end

function DugisGuideViewer:GetFontWidth(text, fonttype)
	local font = fonttype or "GameFontNormal"

	if not DugisFW then CreateFrame( "GameTooltip", "DugisFW" ) end
	local frame = DugisFW
	local fontstring = frame:CreateFontString("tmpfontstr","ARTWORK", font)
	fontstring:SetText(text)
	local fontwidth = fontstring:GetStringWidth()
	return fontwidth
end

function DugisGuideViewer:PrintTable( tbl )
	local key, val, val2
	
	DebugPrint("Table Contents:")
	
	if not tbl then DebugPrint("Table Empty") return end
	
	for key, val in pairs(tbl) do
		if type(val) == "table" then
			for _, val2 in pairs(val) do
				self:PrintBoolTbl(key,val2)
			end
		else
			self:PrintBoolTbl(key,val)
		end
	end
end

function DugisGuideViewer:PrintBoolTbl(key, val)
	local printstr = "key: "
	if type(key) == "boolean" then
		if key == true then printstr = printstr.."true" else printstr = printstr.."false" end
	else
		printstr = printstr..key
	end
	
	printstr = printstr.." val: "
	if type(val) == "boolean" then
		if val == true then printstr = printstr.."true" else printstr = printstr.."false" end
	else
		printstr = printstr..val
	end
	
	DebugPrint(printstr)
end

function DugisGuideViewer:OnLoad()
	--DugisGuideViewer.Target:Init( )
	DugisGuideViewer.GuideOn = true
	--DugisGuideViewer.StickyFrame:Init( )
	DugisGuideViewer.AutoQuestAccept:Enable( )
	
	DugisGuideViewer:SettingFrameChkOnClick()
	self:SetAllBorders()
	DugisGuideViewer:SetMemoryOptions()

	DugisGuideViewer:SetEssentialsOnCancelReload()
	DugisGuideViewer.GuideOn = DugisGuideViewer:ReloadModules()
	DugisGuideViewer:SettingFrameChkOnClick()
	
	if (DugisGuideViewer.carboniteloaded or DugisGuideViewer.sexymaploaded or DugisGuideViewer.nuiloaded or DugisGuideViewer.elvuiloaded or DugisGuideViewer.tukuiloaded or DugisGuideViewer.shestakuiloaded) then 
		DugisGuideViewer:SetDB(false, DGV_ANCHOREDSMALLFRAME)
		DugisGuideViewer:SetDB(false, DGV_WATCHFRAMEBORDER)
		DugisGuideViewer:SetDB(false, DGV_LOCKWATCHFRAME)
		DugisGuideViewer:UpdateCompletionVisuals()
	end
	
	if Debug == 1 and DebugFramesON == 1 then
		DGV_TestFrame:Show()
	end	
	collectgarbage()
	DugisGuideViewer:UpdateIconStatus()
	if DugisGuideViewer.GuideOn and DugisGuideViewer.db.char.settings.EssentialsMode ~= 1 then DelayandMoveToNextQuest(5) end
end

function DugisGuideViewer:SetMemoryOptions()
	--[[if not DugisGuideViewer:UserSetting(DGV_ENABLEMODELDB) then 
		--table.wipe(self.ModelViewer.npcDB)
		--table.wipe(self.ModelViewer.objDB)
		--self.ModelViewer.npcDB = {}
		--self.ModelViewer.objDB = {}
		--DebugPrint("#Wipe Objects")
		DugisGuideViewer.UnloadModule("NpcsF")
		DugisGuideViewer.UnloadModule("ObjectsF")
		DugisGuideViewer.UnloadModule("NpcsT")
		DugisGuideViewer.UnloadModule("ObjectsT")
		DugisGuideViewer.UnloadModule("ModelViewer")
	elseif DugisGuideViewer.GuideOn then
		DugisGuideViewer:LoadModule("ModelViewer")
		DugisGuideViewer.LoadModule("NpcsF")
		DugisGuideViewer.LoadModule("ObjectsF")
		DugisGuideViewer.LoadModule("NpcsT")
		DugisGuideViewer.LoadModule("ObjectsT")
	end
	
	if not DugisGuideViewer:UserSetting(DGV_ENABLENPCNAMEDB) then 
		--table.wipe(DugisNPCs)
		DugisNPCs = {}
		DebugPrint("#Wipe NPC table")
	end
	
	if not DugisGuideViewer:UserSetting(DGV_ENABLEQUESTLEVELDB) then
		--table.wipe(self.ReqLevel)
		self.ReqLevel = {}
		DebugPrint("#Wipe ReqLevel table")
	end]]
	
	collectgarbage()
end

function DugisGuideViewer:Test()
	
	--DugisGuideViewer:PreloadButtonOnClick()
	--thread = coroutine.create(preLoad)
	--DugisGuideViewer.startPreload = true
	--preLoad()
	--[[
	collectgarbage()
	local mem = GetAddOnMemoryUsage("DugisGuideViewerZ");
	DebugPrint("mem1="..mem)
	DugisGuideViewer:SetMemoryOptions()
	collectgarbage()
	mem = GetAddOnMemoryUsage("DugisGuideViewerZ");
	DebugPrint("mem2="..mem)
	--]]
	if DugisGuideViewer.Modules.SmallFrame then
		DugisGuideViewer.Modules.SmallFrame:PlayFlashAnimation( )
	end
end

local function Disable(frame)
	if frame then 
		--DebugPrint("frame type:"..frame:GetObjectType())
		if frame:GetObjectType() == "CheckButton" then
			frame:SetChecked(0)
			frame.Text:SetTextColor(0.5, 0.5, 0.5)
		end
		frame:Disable() 
	end
end

local function Enable(frame)
	if frame then
		if frame:GetObjectType() == "CheckButton" then
			frame.Text:SetTextColor(1, 1, 1) 
		end
		frame:Enable() 
	end
end

local AceGUI = LibStub("AceGUI-3.0")
local function GetSettingsCategoryFrame(category, parent)
	local self = DugisGuideViewer
	local frameName = string.format("DGV_%sCategoryFrame", category)
	local frame = _G[frameName]
	if not frame then
		frame =  CreateFrame("Frame", frameName, parent)
		frame:SetAllPoints(parent)
	
		local fontstring = frame:CreateFontString(nil,"ARTWORK", "GameFontNormalLarge")
		fontstring:SetText(L[category])
		fontstring:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -16)
	end
	
	local SettingsDB = 	DugisGuideViewer.db.char.settings
	local top = -40
	for SettingNum = 1, SettingsDB.sz do
		if SettingsDB[SettingNum].category==category
			and(not DugisGuideViewer:GetDB(SettingNum, "module") 
			or DugisGuideViewer:IsModuleRegistered(DugisGuideViewer:GetDB(SettingNum, "module")))
		then
			local chkBoxName = "DGV.ChkBox"..SettingNum
			local chkBox = _G[chkBoxName]
			if not chkBox then
				chkBox = CreateFrame("CheckButton", chkBoxName, frame, "InterfaceOptionsCheckButtonTemplate")
				if SettingsDB[SettingNum].indent then
					chkBox:SetPoint("TOPLEFT", frame, "TOPLEFT", 40, top)
				else
					chkBox:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, top)
				end
				chkBox.Text:SetText(L[SettingsDB[SettingNum].text])
				chkBox:SetHitRectInsets(0, 0, 0, 0)
				chkBox:RegisterForClicks("LeftButtonDown")
				chkBox:SetScript("OnClick", function() DugisGuideViewer:SettingFrameChkOnClick (chkBox) 	   end)
				chkBox:SetScript("OnEnter", function() DugisGuideViewer:SettingsTooltip_OnEnter(chkBox, event) end)
				chkBox:SetScript("OnLeave", function() DugisGuideViewer:SettingsTooltip_OnLeave(chkBox, event) end)
				top = top - chkBox:GetHeight()
			end
			chkBox:SetChecked(SettingsDB[SettingNum].checked)
		end
	end
	
	--Customize macro edit box
	if SettingsDB[DGV_TARGETBUTTONCUSTOM].category==category
		and(not DugisGuideViewer:GetDB(DGV_TARGETBUTTONCUSTOM, "module")
		or DugisGuideViewer:IsModuleRegistered(DugisGuideViewer:GetDB(DGV_TARGETBUTTONCUSTOM, "module")))
	then
		local macroFrame = _G["DGV.MacroFrame"]
		local textBox =  _G["DGV.InputBox"..DGV_TARGETBUTTONCUSTOM]
		local chkBox =  _G["DGV.ChkBox"..DGV_TARGETBUTTONCUSTOM]
		if not macroFrame then
			macroFrame = CreateFrame("Frame", "DGV.MacroFrame", frame)
			textBox = CreateFrame("EditBox", "DGV.InputBox"..DGV_TARGETBUTTONCUSTOM,  macroFrame, "InputBoxTemplate")
			chkBox = CreateFrame("CheckButton", "DGV.ChkBox"..DGV_TARGETBUTTONCUSTOM, frame, "InterfaceOptionsCheckButtonTemplate")
			if SettingsDB[DGV_TARGETBUTTONCUSTOM].indent then
				chkBox:SetPoint("TOPLEFT", frame, "TOPLEFT", 40, top)
			else
				chkBox:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, top)
			end
			chkBox.Text:SetText(L[SettingsDB[DGV_TARGETBUTTONCUSTOM].text])
			chkBox:SetHitRectInsets(0, -200, 0, 0)
			chkBox:RegisterForClicks("LeftButtonDown")
			chkBox:SetScript("OnClick", function() DugisGuideViewer:SettingFrameChkOnClick (chkBox)	   end)
			chkBox:SetScript("OnEnter", function() DugisGuideViewer:SettingsTooltip_OnEnter(chkBox, event) end)
			chkBox:SetScript("OnLeave", function() DugisGuideViewer:SettingsTooltip_OnLeave(chkBox, event) end)

			top = top - chkBox:GetHeight()

			macroFrame:SetSize(260, 90)
			macroFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 40, top)
			DugisGuideViewer:SetFrameBackdrop(macroFrame, "Interface\\Tooltips\\UI-Tooltip-Background", "Interface\\Tooltips\\UI-Tooltip-Border", 5, 5, 5, 5)
			macroFrame:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
			macroFrame:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);

			textBox:SetMultiLine(true)
			textBox:SetSize(260, 90)
			textBox:SetAutoFocus(false)
			textBox:ClearAllPoints( )
			textBox:SetPoint("TOPLEFT", macroFrame, "TOPLEFT", 10, -10)
			textBox:SetPoint("BOTTOMRIGHT", macroFrame, "BOTTOMRIGHT", -10, -10)
			textBox:SetMaxLetters(215)
			textBox:SetFont("Fonts\\FRIZQT__.TTF", 11)
			_G[textBox:GetName().."Left"]:SetTexture(nil)
			_G[textBox:GetName().."Middle"]:SetTexture(nil)
			_G[textBox:GetName().."Right"]:SetTexture(nil)
			
			textBox:Show()
			
			top = top - macroFrame:GetHeight()
			
			local button = DugisGuideViewer:CreateButton("DGV_ApplyMacroButton", frame, "Apply", function() DugisGuideViewer.Modules.Target:CustomizeMacro() end)
			button:SetPoint("TOPLEFT", frame, "TOPLEFT", 40, top-3)
			local right = button:GetWidth()
			
			button = DugisGuideViewer:CreateButton("DGV_ResetMacroButton", frame, "Default", function() DugisGuideViewer.Modules.Target:ResetMacro() end)
			button:SetPoint("TOPLEFT", frame, "TOPLEFT", 40 + right, top-3)
			local right2 = button:GetWidth()
			
			button = DugisGuideViewer:CreateButton("DGV_ClearMacroButton", frame, "Clear", function() DugisGuideViewer.Modules.Target:ClearMacro() end)
			button:SetPoint("TOPLEFT", frame, "TOPLEFT", 40 + right + right2, top-3)
			
			top = top-3-button:GetHeight()
		end
		
		chkBox:SetChecked(SettingsDB[DGV_TARGETBUTTONCUSTOM].checked)
		textBox:SetText(self.db.char.settings[DGV_TARGETBUTTONCUSTOM].editBox)
	end
	
	--Disable Ant Trail option
	if DugisGuideViewer.carboniteloaded and SettingsDB[DGV_SHOWANTS].category==category then
		local ChkBox = _G["DGV.ChkBox"..DGV_SHOWANTS]

		ChkBox:SetChecked(0)
		ChkBox:Disable()
		ChkBox.Text:SetTextColor(0.5, 0.5, 0.5)
	
	elseif SettingsDB[DGV_CARBONITEARROW].category==category then
		local ChkBox = _G["DGV.ChkBox"..DGV_CARBONITEARROW]

		ChkBox:SetChecked(0)
		ChkBox:Disable()
		ChkBox.Text:SetTextColor(0.5, 0.5, 0.5) 	
	end
	
	if not DugisGuideViewer.tomtomloaded and SettingsDB[DGV_TOMTOMARROW].category==category  then
		local ChkBox = _G["DGV.ChkBox"..DGV_TOMTOMARROW]		

		ChkBox:SetChecked(0)
		ChkBox:Disable() 
		ChkBox.Text:SetTextColor(0.5, 0.5, 0.5) 		
	end
	
	if (DugisGuideViewer.tomtomloaded or DugisGuideViewer.carboniteloaded or DugisGuideViewer.mapsterloaded) and SettingsDB[DGV_DISPLAYMAPCOORDINATES].category==category  then
		local ChkBox = _G["DGV.ChkBox"..DGV_DISPLAYMAPCOORDINATES]		

		ChkBox:SetChecked(0)
		ChkBox:Disable() 
		ChkBox.Text:SetTextColor(0.5, 0.5, 0.5) 		
	end

	if (DugisGuideViewer.carboniteloaded or DugisGuideViewer.sexymaploaded or DugisGuideViewer.nuiloaded or DugisGuideViewer.elvuiloaded or DugisGuideViewer.tukuiloaded or DugisGuideViewer.shestakuiloaded) and SettingsDB[DGV_LOCKWATCHFRAME].category==category  then
		local ChkBox = _G["DGV.ChkBox"..DGV_LOCKWATCHFRAME]		

		ChkBox:SetChecked(0)
		ChkBox:Disable() 
		ChkBox.Text:SetTextColor(0.5, 0.5, 0.5) 		
	end
	
	if (DugisGuideViewer.carboniteloaded or DugisGuideViewer.sexymaploaded or DugisGuideViewer.nuiloaded or DugisGuideViewer.elvuiloaded or DugisGuideViewer.tukuiloaded or DugisGuideViewer.shestakuiloaded) and SettingsDB[DGV_WATCHFRAMEBORDER].category==category  then
		local ChkBox = _G["DGV.ChkBox"..DGV_WATCHFRAMEBORDER]		

		ChkBox:SetChecked(0)
		ChkBox:Disable() 
		ChkBox.Text:SetTextColor(0.5, 0.5, 0.5) 		
	end		
	
	if SettingsDB[DGV_ANCHOREDSMALLFRAME].category==category then
		local ChkBox = _G["DGV.ChkBox"..DGV_ANCHOREDSMALLFRAME]
		if DugisGuideViewer:UserSetting(DGV_SHOWSMALLFRAME) and
			not (DugisGuideViewer.carboniteloaded or DugisGuideViewer.sexymaploaded or DugisGuideViewer.nuiloaded or DugisGuideViewer.elvuiloaded or DugisGuideViewer.tukuiloaded or DugisGuideViewer.shestakuiloaded)
		then
			Enable(ChkBox)
		elseif not (DugisGuideViewer.carboniteloaded or DugisGuideViewer.sexymaploaded or DugisGuideViewer.nuiloaded or DugisGuideViewer.elvuiloaded or DugisGuideViewer.tukuiloaded or DugisGuideViewer.shestakuiloaded) then
			Disable(ChkBox)
		else
			ChkBox:SetChecked(0)
			ChkBox:Disable()
			ChkBox.Text:SetTextColor(0.5, 0.5, 0.5)
		end
	end
	
	--Reset Frames Position Button
	if category=="Frames" and not DGV_ResetFramesButton then
		local button = CreateFrame("Button", "DGV_ResetFramesButton", frame, "UIPanelButtonTemplate")
		local buttext = L["Reset Frames Position"]
		local fontwidth = DugisGuideViewer:GetFontWidth(buttext, "GameFontHighlight")
		button:SetText(buttext)
		button:SetWidth(fontwidth + 30)
		button:SetHeight(22)
		button:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, top-3)
		top = top-3-button:GetHeight()
		--button:SetPoint("TOPLEFT", "DGV.ChkBox6", "BOTTOMLEFT", "0", "-3")
		button:RegisterForClicks("LeftButtonUP")
		button:SetScript("OnClick", function() DugisGuideViewer:InitFramePositions() end)
	end
	
	--Memory settings Apply button
	if category=="Memory" and not DGV_MemoryApplyButton then
		local button = CreateFrame("Button", "DGV_MemoryApplyButton", frame, "UIPanelButtonTemplate")
		local buttext = L["Apply Memory Settings"]
		local fontwidth = DugisGuideViewer:GetFontWidth(buttext, "GameFontHighlight")
		button:SetText(buttext)
		button:SetWidth(fontwidth + 30)
		button:SetHeight(22)
		button:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, top-3)
		top = top-3-button:GetHeight()
		button:RegisterForClicks("LeftButtonUP")
		button:SetScript("OnClick", function() DugisGuideViewer:ReloadModules() end)
	end
	
	--[[--Memory settings Garbage Collect
	if category=="Memory" then
		local button = CreateFrame("Button", "DGV_CollectGarbageButton", frame, "UIPanelButtonTemplate")
		local buttext = L["Collect Garbage"]
		local fontwidth = DugisGuideViewer:GetFontWidth(buttext, "GameFontHighlight")
		button:SetText(buttext)
		button:SetWidth(fontwidth + 30)
		button:SetHeight(22)
		button:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, top-3)
		top = top-3-button:GetHeight()
		button:RegisterForClicks("LeftButtonUP")
		button:SetScript("OnClick", function() collectgarbage() end)
	end]]

	top = top - 24
	--Guide Suggest Difficulty Dropdown
	if SettingsDB[DGV_GUIDEDIFFICULTY].category==category
		and(not DugisGuideViewer:GetDB(DGV_GUIDEDIFFICULTY, "module")
		or DugisGuideViewer:IsModuleRegistered(DugisGuideViewer:GetDB(DGV_GUIDEDIFFICULTY, "module")))
		and not DGV_GuideSuggestDropdown
	then
		local dropdown = self:CreateDropdown("DGV_GuideSuggestDropdown", frame, "Leveling Mode", DGV_GUIDEDIFFICULTY, self.GuideSuggestDropDown_OnClick)
		dropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", 3, top)
		--top = top-22-dropdown:GetHeight()
	end
	
	--Status Frame Effect Dropdown
	if SettingsDB[DGV_SMALLFRAMETRANSITION].category==category 
		and(not DugisGuideViewer:GetDB(DGV_SMALLFRAMETRANSITION, "module") 
		or DugisGuideViewer:IsModuleRegistered(DugisGuideViewer:GetDB(DGV_SMALLFRAMETRANSITION, "module")))
		and not DGV_StatusFrameEffectDropdown
	then
		local dropdown = self:CreateDropdown("DGV_StatusFrameEffectDropdown", frame, "Small Frame Effect", DGV_SMALLFRAMETRANSITION, self.StatusFrameEffectDropDown_OnClick)
		dropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", 3, top)
	end

	--Large Frame Border  Dropdown
	if SettingsDB[DGV_LARGEFRAMEBORDER].category==category  and not DGV_LargeFrameBorderDropdown then
		local dropdown = self:CreateDropdown("DGV_LargeFrameBorderDropdown", frame, "Borders", DGV_LARGEFRAMEBORDER, self.LargeFrameBorderDropdown_OnClick)
		local left = 3
		if DGV_StatusFrameEffectDropdownTitle then left = DGV_StatusFrameEffectDropdownTitle:GetWidth() + 20 end
		dropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", left, top)
		top = top-22-dropdown:GetHeight()
	end
	
	--Step Complete Sound Dropdown
	if SettingsDB[DGV_STEPCOMPLETESOUND].category==category
		and(not DugisGuideViewer:GetDB(DGV_STEPCOMPLETESOUND, "module")
		or DugisGuideViewer:IsModuleRegistered(DugisGuideViewer:GetDB(DGV_STEPCOMPLETESOUND, "module")))
		and not DGV_StepCompleteSoundDropdown
	then
		local dropdown = self:CreateDropdown("DGV_StepCompleteSoundDropdown", frame, "Step Complete Sound", DGV_STEPCOMPLETESOUND, self.StepCompleteSoundDropdown_OnClick)
		local left = 3
		if DGV_GuideSuggestDropdownTitle then left = DGV_GuideSuggestDropdownTitle:GetWidth() + 20 end
		dropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", left, top)
		top = top-22-dropdown:GetHeight()
	elseif SettingsDB[DGV_STEPCOMPLETESOUND].category==category and DGV_GuideSuggestDropdown then
		top = top-22-DGV_GuideSuggestDropdown:GetHeight()
	end

	--Ant Trail Color Dropdown
	if SettingsDB[DGV_ANTCOLOR].category==category and not DGV_AntColorDropdown then
		local dropdown = self:CreateDropdown("DGV_AntColorDropdown", frame, "Ant Trail Color", DGV_ANTCOLOR, self.AntColorDropdown_OnClick)
		dropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", 3, top)
		top = top-22-dropdown:GetHeight()
	end		

	--Quest Complete Sound Dropdown
	if SettingsDB[DGV_QUESTCOMPLETESOUND].category==category
		and(not DugisGuideViewer:GetDB(DGV_QUESTCOMPLETESOUND, "module")
		or DugisGuideViewer:IsModuleRegistered(DugisGuideViewer:GetDB(DGV_QUESTCOMPLETESOUND, "module")))
		and not DGV_QuestCompleteSoundDropdown
	then
		local dropdown = self:CreateDropdown("DGV_QuestCompleteSoundDropdown", frame, "Quest Complete Sound", DGV_QUESTCOMPLETESOUND, self.QuestCompleteSoundDropdown_OnClick)
		dropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", 3, top)
		top = top-22-dropdown:GetHeight()
	end
	
	--Tooltip Anchor
	if SettingsDB[DGV_TOOLTIPANCHOR].category==category  and not DGV_TooltipAnchorDropdown then
		local dropdown = self:CreateDropdown("DGV_TooltipAnchorDropdown", frame, "Tooltip Anchor", DGV_TOOLTIPANCHOR, self.TooltipAnchorDropdown_OnClick)
		dropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", 3, top)
		top = top-22-dropdown:GetHeight()
	end
	
	--Map Preview POIs
	if SettingsDB[DGV_MAPPREVIEWPOIS].category==category and not DGV_MapPreviewPOIsDropdown then
		local dropdown = self:CreateDropdown("DGV_MapPreviewPOIsDropdown", frame, "Preview Quest Objectives", DGV_MAPPREVIEWPOIS, self.MapPreviewPOIsDropdown_OnClick)
		dropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", 3, top)
		top = top-22-dropdown:GetHeight()
	end
	
	--Mini Blob Quality Slider
	--[[if SettingsDB[DGV_MINIBLOBQUALITY].category==category then
		local slider = self:CreateSlider("DGV_MiniBlobQualitySlider", frame, "Minimap Blob Quality", 
			DGV_MINIBLOBQUALITY, 0, 1, 8/30, 1, "Low", "High", function() DugisGuideViewer:UpdateMiniBlobs() end)
		slider:SetPoint("TOPLEFT", frame, "TOPLEFT", 23, top)
		if DugisGuideViewer.carboniteloaded or  GetCVarBool( "rotateMinimap" ) then
			_G[slider:GetName() .. 'Text']:SetTextColor(0.5, 0.5, 0.5)
			_G[slider:GetName() .. 'Low']:SetTextColor(0.5, 0.5, 0.5)
			_G[slider:GetName() .. 'High']:SetTextColor(0.5, 0.5, 0.5)
			slider:Disable()
		end
		top = top-30-slider:GetHeight()
	end--]]
	
	--Show Tooltip Slider
	if SettingsDB[DGV_SHOWTOOLTIP].category==category and not DGV_ShowTooltipSlider then
		local slider = self:CreateSlider("DGV_ShowTooltipSlider", frame, "Auto Tooltip (Seconds)", 
			DGV_SHOWTOOLTIP, 0, 120, 1, 5, "0", "120", function() DugisGuideViewer:ShowAutoTooltip() end)
		slider:SetPoint("TOPLEFT", frame, "TOPLEFT", 23, top)
		top = top-30-slider:GetHeight()
	end
	
	--Map Preview Slider
	if SettingsDB[DGV_MAPPREVIEWDURATION].category==category and not DGV_MapPreviewSlider then
		local slider = self:CreateSlider("DGV_MapPreviewSlider", frame, "Duration (Seconds)", 
			DGV_MAPPREVIEWDURATION, 0, 120, 1, 10, "0", "120")
		slider:HookScript("OnMouseUp", function()
			if DugisGuideViewer:IsModuleLoaded("MapPreview") then
				DugisGuideViewer.MapPreview:ConfigChanged()
			end
		end)
		slider:SetPoint("TOPLEFT", frame, "TOPLEFT", 23, top)
		if DugisGuideViewer.carboniteloaded then
			_G[slider:GetName() .. 'Text']:SetTextColor(0.5, 0.5, 0.5)
			_G[slider:GetName() .. 'Low']:SetTextColor(0.5, 0.5, 0.5)
			_G[slider:GetName() .. 'High']:SetTextColor(0.5, 0.5, 0.5)
			slider:Disable()
		end
		top = top-30-slider:GetHeight()
	end
	
	return frame
end

local function IterateReturns(...)
		local i, tbl = 0, {...}
		return function ()
			i = i + 1
			if i <= #(tbl) then return tbl[i] end
		end
	end

function DugisGuideViewer:CreateSettingsTree(parent)
	if DugisGuideViewer.SettingsTree then
		DugisGuideViewer.SettingsTree.frame:ClearAllPoints()
		AceGUI:Release(DugisGuideViewer.SettingsTree)
	end
	local treeGroup = AceGUI:Create("TreeGroup")
	treeGroup:SetTree(CATEGORY_TREE)		
	treeGroup:EnableButtonTooltips(false)
	--treeGroup.frame:SetBackdrop(nil);
	treeGroup.frame:SetParent(parent)
	treeGroup.treeframe:SetBackdropColor(0,0,0,0);
	treeGroup.border:SetBackdropColor(0,0,0,0);
	treeGroup.frame:SetPoint("TOPLEFT", parent, "TOPLEFT", "20", "0")
	treeGroup.frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", "-50", "50")
				
	treeGroup:SetCallback("OnGroupSelected", function(group, event, value)
		for child in IterateReturns(treeGroup.border:GetChildren()) do
			child:Hide()
		end
		GetSettingsCategoryFrame(value, treeGroup.border):Show()

	end)
	treeGroup:SelectByValue(CATEGORY_TREE[1].value)
	treeGroup.frame:Show()
	DugisGuideViewer.SettingsTree = treeGroup;
end

--Guide Suggest Dropdown
function DugisGuideViewer.GuideSuggestDropDown_OnClick(button)
	--UIDropDownMenu_SetSelectedID(DGV_GuideSuggestDropdown, button:GetID() )
	UIDropDownMenu_SetSelectedValue(DGV_GuideSuggestDropdown, button.value )
	
	DugisGuideViewer:SetDB(button.value, DGV_GUIDEDIFFICULTY)
	DebugPrint("button.value"..button.value.."button.id"..button:GetID())
	DugisGuideViewer:TabTextRefresh()
end

--Status Frame Effect dropdown
function DugisGuideViewer.StatusFrameEffectDropDown_OnClick(button)
	UIDropDownMenu_SetSelectedID(DGV_StatusFrameEffectDropdown, button:GetID() )
	DugisGuideViewer:SetDB(button.value, DGV_SMALLFRAMETRANSITION)
	
	local options = DugisGuideViewer:GetDB(DGV_SMALLFRAMETRANSITION, "options")
	if button.value == options[1].text then
		--UIFrameFadeIn(DugisSmallFrame, 0.8, 0, 1)
		DugisGuideViewer.Modules.SmallFrame:PlayFlashAnimation( )
		DugisGuideViewer.Modules.DugisWatchFrame:PlayFlashAnimation( )
	elseif button.value == options[2].text then
		DugisGuideViewer.Modules.SmallFrame:StartFrameTransition( )
	end
end

function DugisGuideViewer:SetFrameBackdrop(frame, bgFile, edgeFile, left, right, top, bottom, edgeSize)
	if not frame then return end
	if not bgFile and not edgeFile then
		frame:SetBackdrop(nil)
	else
		frame:SetBackdrop( { 
			bgFile = bgFile, 
			edgeFile = edgeFile, tile = true, tileSize = 32, edgeSize = edgeSize or 32, 
			insets = { left = left, right = right, top = top, bottom = bottom }
		})
	end
end

function DugisGuideViewer:GetBorderPath()
	return self.ARTWORK_PATH.."Border-"..DugisGuideViewer:UserSetting(DGV_LARGEFRAMEBORDER)
end

function DugisGuideViewer:SetAllBorders( )
	self:SetSmallFrameBorder( )
	self:SetFrameBackdrop(DugisMainframe, self.BACKGRND_PATH, self:GetBorderPath(), 10, 5, 11, 7)
	if DugisGuideViewer:IsModuleLoaded("ModelViewer") then
		self:SetFrameBackdrop(self.Modules.ModelViewer.Frame, self.BACKGRND_PATH, self:GetBorderPath(), 10, 4, 12, 5)
	end
	self:SetFrameBackdrop(DugisGuideSuggestFrame,  self.BACKGRND_PATH, self:GetBorderPath(), 10, 4, 12, 5)
	if DugisGuideViewer:IsModuleLoaded("StickyFrame") then
		self:SetFrameBackdrop(self.Modules.StickyFrame.Frame, "Interface\\DialogFrame\\UI-DialogBox-Gold-Background", self:GetBorderPath(), 10, 4, 12, 5)
	end
end

function DugisGuideViewer:SetSmallFrameBorder( )
	--Use same border as large frame
	if DugisGuideViewer:UserSetting(DGV_SMALLFRAMEBORDER) 
	then
		self:SetFrameBackdrop(DugisSmallFrame, self.BACKGRND_PATH, self:GetBorderPath(), 10, 4, 12, 5)
	else
		self:SetFrameBackdrop(DugisSmallFrame, nil)
	end
end

--Large Frame Border Dropdown
function DugisGuideViewer.LargeFrameBorderDropdown_OnClick(button)
	UIDropDownMenu_SetSelectedID(DGV_LargeFrameBorderDropdown, button:GetID() )
	DugisGuideViewer:SetDB(button.value, DGV_LARGEFRAMEBORDER)
	DugisGuideViewer:SetAllBorders( )
	WatchFrame_Update()
end

--Step Complete Sound Dropdown
function DugisGuideViewer.StepCompleteSoundDropdown_OnClick(button)
	UIDropDownMenu_SetSelectedID(DGV_StepCompleteSoundDropdown, button:GetID() )
	DebugPrint("Debug StepCompleteSoundDropdown_OnClick: button.text="..button.value)
	DugisGuideViewer:SetDB(button.value, DGV_STEPCOMPLETESOUND)
	--DugisGuideViewer:SetDB(button.value, DGV_STEPCOMPLETESOUND, "value")
	DebugPrint("Debug StepCompleteSoundDropdown_OnClick: DugisGuideViewer:GetDB(DGV_STEPCOMPLETESOUND)="..DugisGuideViewer:GetDB(DGV_STEPCOMPLETESOUND))
	PlaySoundFile(DugisGuideViewer:GetDB(DGV_STEPCOMPLETESOUND))
end

--Ant Trail Color Dropdown
function DugisGuideViewer.AntColorDropdown_OnClick(button)
	UIDropDownMenu_SetSelectedID(DGV_AntColorDropdown, button:GetID() )
	DugisGuideViewer:SetDB(button.value, DGV_ANTCOLOR)
	DugisGuideViewer.Ants:UpdateAntTrailDot(10)
end

--Quest Complete Sound Dropdown
function DugisGuideViewer.QuestCompleteSoundDropdown_OnClick(button)
	UIDropDownMenu_SetSelectedID(DGV_QuestCompleteSoundDropdown, button:GetID() )
	DebugPrint("Debug QuestCompleteSoundDropdown_OnClick: button.text="..button.value)
	DugisGuideViewer:SetDB(button.value, DGV_QUESTCOMPLETESOUND)
	--DugisGuideViewer:SetDB(button.value, DGV_STEPCOMPLETESOUND, "value")
	DebugPrint("Debug QuestCompleteSoundDropdown_OnClick: DugisGuideViewer:GetDB(DGV_QUESTCOMPLETESOUND)="..DugisGuideViewer:GetDB(DGV_QUESTCOMPLETESOUND))
	PlaySoundFile(DugisGuideViewer:GetDB(DGV_QUESTCOMPLETESOUND))
end

function DugisGuideViewer.TooltipAnchorDropdown_OnClick(button)
	UIDropDownMenu_SetSelectedID(DGV_TooltipAnchorDropdown, button:GetID() )
	DugisGuideViewer:SetDB(button.value, DGV_TOOLTIPANCHOR)
	DugisGuideViewer:UpdateCompletionVisuals()
end

function DugisGuideViewer.MapPreviewPOIsDropdown_OnClick(button)
	UIDropDownMenu_SetSelectedID(DGV_MapPreviewPOIsDropdown, button:GetID() )
	DugisGuideViewer:SetDB(button.value, DGV_MAPPREVIEWPOIS)
	DugisGuideViewer.MapPreview:ConfigChanged()
end

-- 
-- Database
--
function DugisGuideViewer:GetDB(key, field)
	if not DugisGuideViewer.chardb[key] then
		DebugPrint("key:"..key.." does not exist in database")
		return
	end
	
	if field then
		local func = loadstring("return DugisGuideViewer.chardb["..tostring(key).."]."..field)
		return func()
	else
		return DugisGuideViewer.chardb[key].checked
	end
end

function DugisGuideViewer:SetDB(value, key, field)
	if not DugisGuideViewer.chardb[key] then
		DebugPrint("key:"..key.." does not exist in database")
		return
	end
	
	if field then 
		local func = loadstring("DugisGuideViewer.chardb["..tostring(key).."]."..field.."="..tostring(value))
		--DebugPrint("func="..func)
		func()
	else
		--DebugPrint("DugisGuideViewer.chardb["..key.."].checked ="..value)
		DugisGuideViewer.chardb[key].checked = value
	end
end

function DugisGuideViewer:UserSetting(name)

	local settings = self.chardb
	
	if not settings[name] then 
		DebugPrint("Error: UserSetting"..name.." not found")
	end

	return self:GetDB(name)--settings[name].checked
end

function DugisGuideViewer:SettingFrameChkOnClick(box)
	local i, boxindex
	--local DGVsettings = self.db.char.settings
	
	if box then
		_, _, boxindex = box:GetName():find("DGV.ChkBox([%d]*)")
		boxindex = tonumber(boxindex)
	end
	
	--Save to DB
	for i = 1, self.db.char.settings.sz do
		if _G["DGV.ChkBox"..i] then
		if _G["DGV.ChkBox"..i]:GetChecked() then self.db.char.settings[i].checked = true else self.db.char.settings[i].checked = false end
		end
	end
	if _G["DGV.ChkBox"..DGV_TARGETBUTTONCUSTOM] then
		if _G["DGV.ChkBox"..DGV_TARGETBUTTONCUSTOM]:GetChecked() then 
			self.db.char.settings[DGV_TARGETBUTTONCUSTOM].checked = true 
		else 
			self.db.char.settings[DGV_TARGETBUTTONCUSTOM].checked = false 
		end
	end
	
	if not DugisGuideViewer:UserSetting(DGV_ENABLEQUESTLEVELDB) then
		DugisGuideViewer:SetDB(false, DGV_QUESTLEVELON)
		local Chk = _G["DGV.ChkBox"..DGV_QUESTLEVELON]
		Disable(Chk)
	else
		local Chk = _G["DGV.ChkBox"..DGV_QUESTLEVELON]
		Enable(Chk)
	end
	
	--Quest Level On
	if boxindex == DGV_QUESTLEVELON then
		if DugisGuideViewer:UserSetting(DGV_QUESTLEVELON) and DugisGuideViewer.GuideOn and DugisGuideViewer.db.char.settings.EssentialsMode ~= 1 then
			DugisGuideViewer:ViewFrameUpdate()
			DugisGuideViewer:UpdateSmallFrame()
		elseif DugisGuideViewer.GuideOn and DugisGuideViewer.db.char.settings.EssentialsMode ~= 1 then
			DugisGuideViewer:ViewFrameUpdate()
			DugisGuideViewer:UpdateSmallFrame()
		end
	end
	
	--Color Code On
	if boxindex == DGV_QUESTCOLORON then
		if DugisGuideViewer:UserSetting(DGV_QUESTCOLORON) and DugisGuideViewer.GuideOn and DugisGuideViewer.db.char.settings.EssentialsMode ~= 1 then
			DugisGuideViewer:ViewFrameUpdate()
			DugisGuideViewer:UpdateSmallFrame()
		elseif DugisGuideViewer.GuideOn and DugisGuideViewer.db.char.settings.EssentialsMode ~= 1 then
			DugisGuideViewer:ViewFrameUpdate()
			DugisGuideViewer:UpdateSmallFrame()
		end
	end
		
	--Large Frame Lock
	if DugisGuideViewer:UserSetting(DGV_LOCKLARGEFRAME) then 
		DugisMainframe:EnableMouse(false)
		DugisMainframe:SetMovable(false)
	else
		DugisMainframe:EnableMouse(true)
		DugisMainframe:SetMovable(true)
	end
	
	if DugisGuideViewer:UserSetting(DGV_ITEMBUTTONON) then
		self:SetUseItem(CurrentQuestIndex)
	else
		DugisGuideViewerActionItemFrame:Hide()		
		DugisGuideViewerQuestItemFrame:Hide()
	end
	
	if boxindex == DGV_ENABLEMODELDB then
		DugisGuideViewer:UpdateSmallFrame()
	end
	
	if not self:UserSetting(DGV_ENABLENPCNAMEDB) then
		DugisGuideViewer:SetDB(false, DGV_TARGETBUTTON)
		--self.Target:Disable()
		local ChkBox = _G["DGV.ChkBox"..DGV_TARGETBUTTON]
		Disable(ChkBox)
	else
		local ChkBox = _G["DGV.ChkBox"..DGV_TARGETBUTTON]
		Enable(ChkBox)
	end

	
	if DugisGuideViewer:UserSetting(DGV_TARGETBUTTON) then
		DugisGuideViewer:SetTarget(CurrentQuestIndex)
		
		local ChkBox = _G["DGV.ChkBox"..DGV_TARGETBUTTONSHOW]
		local ChkBox2 = _G["DGV.ChkBox"..DGV_TARGETBUTTONCUSTOM]
		Enable(ChkBox)
		Enable(ChkBox2)
	else
		local ChkBox = _G["DGV.ChkBox"..DGV_TARGETBUTTONSHOW]
		local ChkBox2 = _G["DGV.ChkBox"..DGV_TARGETBUTTONCUSTOM]
		Disable(ChkBox)
		Disable(ChkBox2)
	end

	if DugisGuideViewer:IsModuleLoaded("Target") then
-- 		if DugisGuideViewer:UserSetting(DGV_TARGETBUTTONSHOW) then
-- 			DugisGuideViewer.Modules.Target.Frame:Show()
-- 		else
-- 			DugisGuideViewer.Modules.Target.Frame:Hide()
-- 		end
		DugisGuideViewer:FinalizeTarget()
	end
	
	if self:UserSetting(DGV_TARGETBUTTONCUSTOM) then
		local inputBox = _G["DGV.InputBox"..DGV_TARGETBUTTONCUSTOM]
		Enable(inputBox)
	else
		local inputBox = _G["DGV.InputBox"..DGV_TARGETBUTTONCUSTOM]
		Disable(inputBox)
	end
	
	if self:UserSetting(DGV_SHOWONOFF) then
		DugisOnOffButton:Show()
	else
		DugisOnOffButton:Hide()
	end

	if DugisGuideViewer:IsModuleLoaded("DugisArrow") then
		if self:UserSetting(DGV_DUGIARROW) then
			self.DugisArrow:Show()
			Enable(_G["DGV.ChkBox"..DGV_SHOWCORPSEARROW])
			Enable(_G["DGV.ChkBox"..DGV_CLASSICARROW])
		else
			Disable(_G["DGV.ChkBox"..DGV_SHOWCORPSEARROW])
			Disable(_G["DGV.ChkBox"..DGV_CLASSICARROW])
			self.DugisArrow:Hide()

		end
		DugisGuideViewer.DugisArrow:setArrowTexture( )
	end
	
	if DugisGuideViewer:IsModuleLoaded("SmallFrame") then
		if DugisGuideViewer:UserSetting(DGV_SHOWSMALLFRAME)
		then
			DugisGuideViewer:UpdateSmallFrame()
			if not(DugisGuideViewer.carboniteloaded or DugisGuideViewer.sexymaploaded or DugisGuideViewer.nuiloaded or DugisGuideViewer.elvuiloaded or DugisGuideViewer.tukuiloaded or DugisGuideViewer.shestakuiloaded) then
			Enable(_G["DGV.ChkBox"..DGV_ANCHOREDSMALLFRAME])
			end
		else
			DugisGuideViewer.Modules.SmallFrame.Frame:Hide()
			if not (DugisGuideViewer.carboniteloaded or DugisGuideViewer.sexymaploaded or DugisGuideViewer.nuiloaded or DugisGuideViewer.elvuiloaded or DugisGuideViewer.tukuiloaded or DugisGuideViewer.shestakuiloaded) then
			Disable(_G["DGV.ChkBox"..DGV_ANCHOREDSMALLFRAME])
			end
		end
	end
	
	if boxindex == DGV_TOMTOMARROW or boxindex == DGV_CARBONITEARROW then
		DebugPrint("Switch arrow type")
		self:RemoveAllWaypoints()
		if DugisGuideViewer.GuideOn and DugisGuideViewer.db.char.settings.EssentialsMode ~= 1 then
			self:MapCurrentObjective()
		end
	end

	DugisGuideViewer:UpdateStickyFrame( )
	if DugisGuideViewer:IsModuleLoaded("SmallFrame")  then
		DugisGuideViewer:SetSmallFrameBorder( )
		DugisGuideViewer.Modules.SmallFrame:ResetFloating()
		DugisGuideViewer:ShowAutoTooltip()
	end

	DugisGuideViewer.Modules.WorldMapTracking:UpdateTrackingMap()
	RefreshWorldMap()
end

function DugisGuideViewer:SettingsTooltip_OnEnter(chk, event)
	local _, _, boxindex = chk:GetName():find("DGV.ChkBox([%d]*)")
	boxindex = tonumber(boxindex)
	
	local DGVsettings = self.db.char.settings
		
	if DGVsettings[boxindex].tooltip ~= "\"\"" then
		GameTooltip:SetOwner( chk, "ANCHOR_BOTTOMLEFT")
		GameTooltip:AddLine(L[DGVsettings[boxindex].tooltip], 1, 1, 1, 1, true)
		GameTooltip:Show()
		GameTooltip:ClearAllPoints()
		GameTooltip:SetPoint("BOTTOMLEFT", chk, "TOPLEFT", 25, 0)
	end
end

function DugisGuideViewer:SettingsTooltip_OnLeave(self, event)
	GameTooltip:Hide()
end

local function ToggleConfig()
	if DugisMainframe:IsVisible() == 1 then
		DugisGuideViewer:HideLargeWindow()
	else
		--UIFrameFadeIn(DugisMainframe, 0.5, 0, 1)
		--UIFrameFadeIn(Dugis, 0.5, 0, 1)
		DugisGuideViewer:ShowLargeWindow()
	end
end

SLASH_DG1 = "/dugi"
SlashCmdList["DG"] = function(msg)	
	if msg == "" then 				-- "/dg" command
		print("|cff11ff11/dugi way xx xx - |rPlace waypoint in current zone.")
		print("|cff11ff11/dugi fix - |rReset all Saved Variable setting.")
		print("|cff11ff11/dugi reset - |rReset all frame position.")
		print("|cff11ff11/dugi on - |rEnable Dugi Addon.")
		print("|cff11ff11/dugi off - |rDisable Dugi Addon.")
		print("|cff11ff11/dugi config - |rDisplay settings menu.")
	elseif msg  == "on" then
		DugisGuideViewer:TurnOn()
	elseif msg  == "off" then
		DugisGuideViewer:TurnOff()
	elseif msg  == "config" then
		ToggleConfig()
	elseif msg  == "reset" then 	--"/dg reset" command
		print("|cff11ff11" .. "Dugis Frame Reset" )
		DugisGuideViewer:InitFramePositions()
	elseif msg == "fix" then
		print("|cff11ff11" .. "Dugis Clear Variables" )
		ResetDB()
		--DugisGuideViewer:ReloadModules()
	elseif msg == "dgr" then
		DugisGuideViewer:ShowRecord()
	elseif msg == "dgr limit" then
		DugisGuideViewer:ToggleRecordLimit()
	elseif string.find(msg, "dgr ")==1 then
		DugisGuideViewer:RecordNote(string.sub(msg, 5))	
	elseif string.find(msg, "way ")==1 then
		 local x,y,zone = string.sub(msg, 5):match("%s*(%d+)[,%s]+(%d+)%s*(.*)")
		 if x and y then
			DugisGuideViewer:AddManualWaypoint(tonumber(x)/100, tonumber(y)/100, zone)
		end
	end
end

function DugisGuideViewer:RemoveParen(text)
	if text then
		local _, _, noparen = text:find("([^%(]*)")
		noparen = noparen:trim()
		
		return noparen
	end
end

function DugisGuideViewer:OnOff_OnClick(self, event)
	if event == "LeftButton" then
		DugisGuideViewer:ToggleOnOff()
	elseif event == "RightButton" then
		ToggleConfig()
	end
end

function DugisGuideViewer:ToggleOnOff()
	if InCombatLockdown() then return end
	if DugisGuideViewer.GuideOn and DugisGuideViewer.db.char.settings.EssentialsMode == 0 then
		DugisGuideViewer:TurnOnEssentials()
	elseif DugisGuideViewer.GuideOn then
		DugisGuideViewer:TurnOff()
	else
		DugisGuideViewer.db.char.settings.EssentialsMode = 0
		DugisGuideViewer:TurnOn()
		--DugisGuideViewer:SettingFrameChkOnClick()
	end
	DugisGuideViewer:UpdateIconStatus()
end

function DugisGuideViewer:TurnOnEssentials()
	DugisGuideViewer.GuideOn = true
	DugisGuideViewer.db.char.settings.EssentialsMode = 1
	DugisGuideViewer:ReloadModules()
	DugisGuideViewer:SettingFrameChkOnClick()
	DugisGuideViewer:UpdateIconStatus()
end

function DugisGuideViewer:TurnOff()
	print("|cff11ff11" .. "Dugi Guides Off" )
	DugisGuideViewer.GuideOn = nil
	DugisGuideViewer.eventFrame:UnregisterAllEvents()
	DugisGuideViewer:HideLargeWindow()
	-- if DugisGuideViewer.ModelViewer.Frame then  --not created when memory setting is restricted
	--	DugisGuideViewer.ModelViewer.Frame:Hide()
	-- end
	--DugisSmallFrameLogo:Hide()
	--DugisGuideViewer.Canvas:Hide()
	--DugisGuideViewer.DugisArrow:Disable()
	DugisGuideViewer.AutoQuestAccept:Disable( )
	--DugisGuideViewer.Target:Disable( )
	--DugisGuideViewer.StickyFrame:Disable()
	--DugisGuideViewer.SmallFrame:Disable()
	DugisGuideViewer:ReloadModules()
end

function DugisGuideViewer:TurnOn()
	if WorldMapFrame:IsShown() then HideUIPanel(WorldMapFrame) end
	print("|cff11ff11" .. "Dugi Guides On" )
	if not DugisGuideViewer:IsModuleRegistered("Guides") then
		DugisGuideViewer.db.char.settings.EssentialsMode = 1
	end
	DugisGuideViewer.GuideOn = true
	DugisGuideViewer:OnInitialize()	
	--DugisGuideViewer.ModelViewer:ShowCurrentModel()
	--DugisSmallFrameLogo:Show()
	--DugisGuideViewer.Canvas:Show()
	--DugisGuideViewer.DugisArrow:Enable()
	DugisGuideViewer.AutoQuestAccept:Enable( )
	--DugisGuideViewer.Target:Enable( )
	--DugisGuideViewer.StickyFrame:Enable()
	--DugisGuideViewer.SmallFrame:Enable()
	DugisGuideViewer:SetEssentialsOnCancelReload()
	DugisGuideViewer.GuideOn = DugisGuideViewer:ReloadModules()
	if DugisGuideViewer.GuideOn and DugisGuideViewer.db.char.settings.EssentialsMode ~= 1 then DugisGuideViewer:MoveToNextQuest() end
	--DugisGuideViewer:ShowLargeWindow()
end

if not DugisGuideViewerDelayFrame then
	DugisGuideViewerDelayFrame = CreateFrame("Frame")
	DugisGuideViewerDelayFrame:Hide()
end

function DelayandMoveToNextQuest(delay, func)
	DugisGuideViewerDelayFrame.func = func
	DugisGuideViewerDelayFrame.delay = delay
	DugisGuideViewerDelayFrame:Show()
end

DugisGuideViewerDelayFrame:SetScript("OnUpdate", function(self, elapsed)
	self.delay = self.delay - elapsed
	if self.delay <= 0 then
		self:Hide()
		DugisGuideViewer:MoveToNextQuest()
	end
end)

function DugisGuideViewer:IsQuestObjectiveComplete(qi, questtext)
	for i=1,GetNumQuestLeaderBoards(qi) do 
		if GetQuestLogLeaderBoard(i, qi) == questtext then 
			return true 
		end 
	end
end

local orig = AbandonQuest
function AbandonQuest(...)
	local i = GetQuestLogSelection()
	AbandonQID = select(9, GetQuestLogTitle(i))
	DebugPrint("Clicked abandon on"..AbandonQID)
	return orig(...)
end

--Occurs BEFORE QuestFrameCompleteQuestButton OnClick (works with questguru, doesn't work with carbonite)
function Dugis_RewardComplete_Click()
	DebugPrint("QuestRewardCompleteButton_OnClick")
	if IsAddOnLoaded("QuestGuru") and DugisGuideViewer:isValidGuide(CurrentTitle) == true then
		DugisGuideViewer:CompleteQuest()
	end
end
hooksecurefunc("QuestRewardCompleteButton_OnClick", Dugis_RewardComplete_Click);

--Occurs AFTER QuestFrameCompleteQuestButton OnClick (doesn't work with questguru, works with carbonite)
QuestFrameCompleteQuestButton:HookScript("OnClick", function(...)
	DebugPrint("QuestFrameCompleteQuestButton")
	if (IsAddOnLoaded("QuestGuru") == nil) and DugisGuideViewer:isValidGuide(CurrentTitle) == true then
		DugisGuideViewer:CompleteQuest()
	end
end)

function DugisGuideViewer:OnDragStart(frame)
  if not self:UserSetting(DGV_LOCKSMALLFRAME) then
    frame:StartMoving();
    frame.isMoving = true;
  end
end

function DugisGuideViewer:OnDragStop(self)
  self:StopMovingOrSizing();
  self.isMoving = false;
end

function DugisGuideViewer:WayPoint_OnClick(self)
	local rowNum
	if self:GetName() == "DugisSmallFrameWayPoint" then
		rowNum = DugisGuideViewer.CurrentQuestIndex
	else
		_, _, rowNum = self:GetName():find("DGVRow([^ ]*)WayPoint")
		rowNum = tonumber(rowNum)
	end
	DugisGuideViewer:MapCurrentObjective(rowNum)
	DugisGuideViewer:ShowAutoTooltip()
	DugisGuideViewer:SafeSetMapQuestId(DugisGuideViewer.qid[rowNum]);
	DugisGuideViewer.MapPreview:FadeInMap()
end

function DugisGuideViewer:HideLargeWindow()	
	DugisMainframe:Hide()
	Dugis:Hide()
	PlaySound("igCharacterInfoClose")
end

function DugisGuideViewer_Close_ButtonClick()
	DugisGuideViewer:HideLargeWindow()
	--DugisSmallFrameLogo:Hide()
end

--[[
function DugisGuideViewer:MinimizeDungeonMap()
	DGV_DungeonFrame:Hide()
	DugisSmallFrameMaximize:Show()
end
--]]
-- 
-- Events
--



function DugisGuideViewer:PLAYER_LOGIN()
	local guid = UnitGUID("player")
	if self.chardb.CharacterGUID == "PRIOR_RESET" then self.chardb.CharacterGUID = guid end
	if self.chardb.CharacterGUID~=guid then
		print("|cff11ff11Dugi Guides: |rNew character detected. Wiping settings.")
		ResetDB()
		self.chardb.EssentialsMode = 1
		self:ReloadModules()
		self:SettingFrameChkOnClick()
	end
	
	--QueryQuestsCompleted()
	DugisGuideViewer:InitializeMapOverlays()
	DugisGuideViewer:InitializeQuestPOI()
end

function DugisGuideViewer:PLAYER_LOGOUT( )
	self.db.char.settings.CurrentQuestIndex = self.CurrentQuestIndex 
end

function DugisGuideViewer:ZONE_CHANGED()
	self:Zone_OnEvent()
end

function DugisGuideViewer:ZONE_CHANGED_NEW_AREA()
	self:Zone_OnEvent()
	
		
	DugisGuideViewer.OnMapChangeUpdateArrow()
	--DugisGuideViewer.DugisArrow:Show()
	
end

function DugisGuideViewer:ZONE_CHANGED_INDOORS()
	self:Zone_OnEvent()
end

function DugisGuideViewer:QUEST_DETAIL()
	DugisGuideViewer:OnQuestDetail()
end

function DugisGuideViewer:QUEST_AUTOCOMPLETE(...)
	DugisGuideViewer:OnAutoComplete(...)
	DugisGuideViewer:UpdateCompletionVisuals()
end

function DugisGuideViewer:QUEST_COMPLETE()
	DugisGuideViewer:OnQuestComplete()
	DugisGuideViewer:UpdateCompletionVisuals()
end

local function OnQuestObjectivesComplete()
	DugisGuideViewer:PlayCompletionSound(DGV_QUESTCOMPLETESOUND)
	DugisGuideViewer:UpdateCompletionVisuals()
end

local completedLogQuests,lastCompletedLogQuests = nil, {}
function DugisGuideViewer:QUEST_LOG_UPDATE()
	DugisGuideViewer:UpdateRecord()
	--PATCH: If I call OnLoad from PLAYER_LOGIN, 
	--GetNumQuestLogEntries == 0 when it is not.
	--Value seems to be stable after initial QLU event
	if FirstTime then  
		FirstTime = nil
		DugisGuideViewer:OnLoad()
	else
		DugisGuideViewer:UpdateMainFrame()
		local i
		lastCompletedLogQuests, completedLogQuests = completedLogQuests, lastCompletedLogQuests
		wipe(completedLogQuests)
		for i=1,GetNumQuestLogEntries() do
			local link = GetQuestLink(i)
			local qid = link and tonumber(link:match("|Hquest:(%d+):"))
			if qid then
				local title, _, _, _, _, _, questFinished = GetQuestLogTitle(i)
				local n = GetNumQuestLeaderBoards(i)
				if n>1 then
					for j=1,n do
						local text, objtype, finished = GetQuestLogLeaderBoard(j, i)
						if not finished then
							questFinished = false
						end
					end
				end
				--DugisGuideViewer:DebugFormat("QUEST_LOG_UPDATE", "qid", qid, "title", title, "questFinished", questFinished, "lastCompletedLogQuests", lastCompletedLogQuests)
				if lastCompletedLogQuests and questFinished and not tContains(lastCompletedLogQuests, qid) then
					OnQuestObjectivesComplete()
					tinsert(completedLogQuests, qid)
				elseif questFinished then
					tinsert(completedLogQuests, qid)
				end
			end
		end
		if not lastCompletedLogQuests then lastCompletedLogQuests = {} end
	end

	DugisGuideViewer.DugisArrow:OnQuestLogChanged()
end

function DugisGuideViewer:TRADE_SKILL_UPDATE()
	DugisGuideViewer:UpdateProfessions()
end

function DugisGuideViewer:ACHIEVEMENT_EARNED()
	DugisGuideViewer:UpdateAchieveFrame()
end

function DugisGuideViewer:ADDON_LOADED(event, addon)
	if addon == "DugisGuideViewerZ" then
		self:UnregisterEvent("ADDON_LOADED")
		DugisGuideViewer:OnInitialize()
		if DugisGuideViewer:GetDB(DGV_MAPPREVIEWDURATION) > 0 then
			SetCVar("miniWorldMap", 1)
		end
	end
end

function DugisGuideViewer:UpdateIconStatus()
	local icon = DugisGuideViewer.ARTWORK_PATH.."iconbutton"
	if DugisGuideViewer.GuideOn and DugisGuideViewer.db.char.settings.EssentialsMode == 1 then
		icon = DugisGuideViewer.ARTWORK_PATH.."iconbutton_s"
	elseif not DugisGuideViewer.GuideOn then
		icon = DugisGuideViewer.ARTWORK_PATH.."iconbutton_c"
	end
	DugisOnOffButton:SetNormalTexture(icon)
	if DugisGuideViewer.LDB then
		DugisGuideViewer.LDB:SetIconStatus(icon)
	end
end

function DugisGuideViewer:GetQuestLogIndexByQID(qid)
	local i
	for i=1,50 do
		local qid2 = select(9, GetQuestLogTitle(i))
		if qid2 == qid then return i end
	end
end

function DugisGuideViewer:GetItemIdFromLink(link)
	--|cff9d9d9d|Hitem:7073:0:0:0:0:0:0:0:80:0|h[Broken Fang]|h|r
	return tonumber(link:match(".+|Hitem:([^:]+):.+"))
end

function DugisGuideViewer:InitFramePositions()
	if DugisGuideViewer:IsModuleLoaded("StickyFrame") then
		self.Modules.StickyFrame.Frame:ClearAllPoints()
		self.Modules.StickyFrame.Frame:SetPoint("CENTER", 225, 180)
	end

	DugisMainframe:ClearAllPoints()
	DugisMainframe:SetPoint("CENTER", 0, 0)

	DugisGuideViewerActionItemFrame:ClearAllPoints()
	DugisGuideViewerQuestItemFrame:ClearAllPoints()
	DugisOnOffButton:ClearAllPoints()
	if DugisGuideViewer:IsModuleLoaded("SmallFrame") then
		DugisGuideViewer.Modules.SmallFrame:Reset()
		DugisGuideViewerActionItemFrame:SetPoint("RIGHT", "DugisSmallFrame", "LEFT", -34, -15)
		DugisGuideViewerQuestItemFrame:SetPoint("RIGHT", "DugisSmallFrame", "LEFT", -34, -15)
		DugisOnOffButton:SetPoint("RIGHT", "DugisSmallFrame", "LEFT", 0, 15 )
	else
		DugisGuideViewerActionItemFrame:SetPoint("RIGHT", "DugisMainframe", "LEFT", -34, -15)
		DugisGuideViewerQuestItemFrame:SetPoint("RIGHT", "DugisMainframe", "LEFT", -34, -15)
		DugisOnOffButton:SetPoint("RIGHT", "DugisMainframe", "LEFT", 0, 15 )
	end
	local actionShown = DugisGuideViewerActionItemFrame:IsShown()
	local questShown = DugisGuideViewerQuestItemFrame:IsShown()
	DugisGuideViewerActionItemFrame:Show()
	DugisGuideViewerQuestItemFrame:Show()
	DugisGuideViewerActionItemFrame:ClearAllPoints()
	DugisGuideViewerQuestItemFrame:ClearAllPoints()
	if not actionShown then
		DugisGuideViewerActionItemFrame:Hide()
	end
	if not questShown then
		DugisGuideViewerQuestItemFrame:Hide()
	end

	if DugisGuideViewer:IsModuleLoaded("ModelViewer") then
		DugisGuideViewer.Modules.ModelViewer.Frame:ClearAllPoints()
		DugisGuideViewer.Modules.ModelViewer.Frame:SetPoint("TOPRIGHT", "WatchFrame", "TOPLEFT", -40, 8)
	end

	if DugisGuideViewer:IsModuleLoaded("Target") then
		self.Modules.Target.Frame:ClearAllPoints()
		self.Modules.Target.Frame:SetPoint("LEFT", "DugisGuideViewerActionItemFrame", "RIGHT", "5", "0")
		self.Modules.Target.Frame:SetPoint("LEFT", "DugisGuideViewerQuestItemFrame", "RIGHT", "5", "0")
	end

	if DugisGuideViewer:IsModuleLoaded("DugisArrow") then
		DugisGuideViewer.DugisArrow:ResetPosition()
	end

	if DugisGuideViewer:IsModuleLoaded("DugisWatchFrame") then
		DugisGuideViewer.Modules.DugisWatchFrame:Reset()
	end
end

function getQuestIndexByQuestName(name)
	local i
	local numq, _ = GetNumQuestLogEntries()
	for i=1,numq do
		local title, _, _, _, isHeader = GetQuestLogTitle(i)
		if not isHeader then
			if name == title then
				return i
			end
		end
	end
end

function DugisGuideViewer:GetQIDFromQuestName(name)
	local logindx = getQuestIndexByQuestName(name)
	local qid
	if logindx then
		qid = select(9, GetQuestLogTitle(logindx))
	end
	return qid
end

function DugisGuideViewer:CreateFlashFrame(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:Hide()
	local texture = frame:CreateTexture()
	texture:SetAllPoints(frame)
	texture:SetTexture(1, 1, 1, 0.5)
	frame:SetBackdrop( { bgFile = nil, edgeFile = DugisGuideViewer.ARTWORK_PATH.."Border-Flash.tga", tile = true, tileSize = 32, edgeSize = 10, insets = { 0, 0, 0, 0 } })
	
	local flashGroup = parent:CreateAnimationGroup()
	local flash = flashGroup:CreateAnimation("Alpha")

	--SmallFrame:ResetFloating()

	flash:SetDuration(0.5)
	flash:SetSmoothing("OUT")
	flash:SetScript("OnUpdate", function(self)
		local back = frame
		--DebugPrint("progress="..progress)
		local progress = 1 - self:GetSmoothProgress()
		back:SetAlpha(progress)

		if progress == 0 then
			--if progress >= 0.25 then
			flash:Stop()
		end

		if flash:IsPlaying() then
			back:Show()
		elseif flash:IsStopped() then
			back:Hide()
		end
	end)

	frame:ClearAllPoints()
	frame:SetPoint("CENTER", parent, 1, -1)
	return flashGroup, flash, frame
end

function DugisGuideViewer:UpdateCompletionVisuals()
	DugisGuideViewer:UpdateSmallFrame()
	DugisGuideViewer.Modules.DugisWatchFrame:PlayFlashAnimation()
end

local lastTime = GetTime()
function DugisGuideViewer:PlayCompletionSound(soundSetting)
	local now = GetTime()
	--DugisGuideViewer:DebugFormat("PlayCompletionSound", "lastTime", lastTime, "now", now, "sound", DugisGuideViewer:GetDB(soundSetting))
	if now-lastTime > 2 then
		PlaySoundFile(DugisGuideViewer:GetDB(soundSetting))
	end
	lastTime = now
end

function DugisGuideViewer:CRITERIA_UPDATE()
	DugisGuideViewer:Guide_CRITERIA_UPDATE()
	DugisGuideViewer:WatchFrame_CRITERIA_UPDATE()
end

function DugisGuideViewer.TableAppend(t, ...)
	local n = select("#", ...)
	for i=1,n do
		tinsert(t, (select(i, ...)))
	end
end

function DugisGuideViewer:PET_BATTLE_OPENING_START()
	DugisGuideViewer:TurnOff()
	if self:UserSetting(DGV_SHOWONOFF) == true then	DugisOnOffButton:Hide() end
	DugisGuideViewer:UpdateIconStatus()
	DugisGuideViewer:RegisterEvent("PET_BATTLE_OVER")
end

function DugisGuideViewer:PET_BATTLE_OVER()
	DugisGuideViewer:TurnOn()
	if self:UserSetting(DGV_SHOWONOFF) then	DugisOnOffButton:Show() end
	DugisGuideViewer:UpdateIconStatus()
	DugisGuideViewer:UnregisterEvent("PET_BATTLE_OVER")
end
