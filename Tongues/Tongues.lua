----------------------------------------------------------------------------------------------------------
	Tongues.Version = GetAddOnMetadata("Tongues", "Version");								--
--	Note: This is completely inspired by the Lore 7.5.7 AddOn					--
--	I decided to take a different approach, and as I got more into it I started having		--
--	problems doing further modification (mostly with the XML,) it just seemed better to		--
--	start over!											--
----------------------------------------------------------------------------------------------------------
--  I prefer to use the table structure form for the functions so that we can instantiate the whole     --
--  thing 												--
----------------------------------------------------------------------------------------------------------
TONGUES_MAX_MSG_LEN = 247;
local ldbt = LibStub:GetLibrary("LibDataBroker-1.1");
local BRAC = LibStub("LibBabble-Race-3.0"):GetLookupTable()
local BFAC = LibStub("LibBabble-Faction-3.0"):GetLookupTable()
local BCT = LibStub("LibBabble-CreatureType-3.0"):GetLookupTable()
local _,Tclass,_ = UnitClass("player")

local Tclasses = {}
FillLocalizedClassList(Tclasses, true)

local BlizzLangs = {"Darnassian", "Pandaren","Zandali","Thalassian","Goblin","Gnomish","Taurahe","Forsaken","Dwarvish","Draenei",}


--===============================================MAIN===================================================--
function countLangauge()
local count = 0;
for k,v in pairs(Tongues.Settings.Character.Fluency) do
		count = count+1;
end;
return count
end

function GetSpeaking()
  local language =  Tongues.Settings.Character.Language
  
  local numLanguages = GetNumLanguages();
  local i;
  local langfound = false;
  for i = 1, numLanguages, 1 do
    local getlanguage, getlanguageID = GetLanguageByIndex(i);
    if (language == getlanguage) then
      languageID = getlanguageID;
      langfound = true;
    end
  end
  
  if langfound == false then 
    local getlanguage2, getlanguageID2
    if UnitRace("player") == "Human" or UnitRace("player") == "Worgen" or UnitRace("player") == "Orc" or UnitRace("player") == "Pandaren" or UnitRace("player") == "Troll"then
      getlanguage2, getlanguageID2 = GetLanguageByIndex(1)
      languageID = getlanguageID2
    --elseif UnitRace("player") == "Pandaren" then
	  --getlanguage, getlanguageID2 = GetLanguageByIndex(1)
     -- languageID = getlanguageID2
	else
      getlanguage, getlanguageID2 = GetLanguageByIndex(2)
      languageID = getlanguageID2
    end
  end
 
  return languageID,language
end


Tongues = Class:inherits(Tongues,{
	Hooks = {
		Send = SendChatMessage;
		Receive = ChatFrame_MessageEventHandler;
		--FCF = FCF_Tab_OnClick;
	};
	PreviousSentMsg = "";
	Colors = {};
	Settings = {
		Character = {					-- Player settings get applied only the the current player
			Language = nil;
			Fluency = {};
			--LD = {};

			Dialect  = "<None>";

			Affect	 = "<None>";
			AffectFrequency = 100;

			Filter   = "<None>";

			Faction = "";
			Race    = "";
			Class   = "";

			Debugging 		= false;
			DialectDrift		= false;
			LanguageLearning	= true;
			ShapeshiftLanguage	= true;
			LoreCompatibility	= true;

			MMH=false;
			
			Translations = {
				Self = false;
				Targetted = false;
				Party = false;
				Guild = false;
				Officer = false;
				Raid = false;
				RaidAlert = false;
				Battleground = false;
			};

			Translators = {};

			Screen = {
				Self = false;
				Targetted = false;
				Party = true;
				Guild = true;
				Officer = true;
				Raid = true;
				RaidAlert = true;
				Battleground = true;
			};
			UI = {
				MainMenu = {
					point = "CENTER", 
					relativeTo = UIParent, 
					relativePoint = "CENTER",
					xOfs = 0;
					yOfs = 0;
				};
				MiniMenu = {
					point = "CENTER", 
					relativeTo = UIParent, 
					relativePoint = "CENTER",
					xOfs = 0;
					yOfs = 0;
				};
			}
		};
	};
	----------------------------------------------------------------------------------------
	dialectcmd = function(msg)---dialect selection slash command
		local param = {};
		msg = string.gsub(msg,"([%a0-9]+)", function(a)
				table.insert(param,#param + 1,a);
		end);

		if param ~= nil then
			self.Settings.Character.Dialect = param[1];
		else
		self.Settings.Character.Dialect = "<None>";
		end;
	end;
	
	
	Command = function(msg)
		local param = {};
		msg = string.gsub(msg,"([%a0-9]+)", function(a)
				table.insert(param,#param + 1,a);
		end);

		local i,k,v
		if param ~= nil then
			if param[1] ~= nil and string.lower(param[1]) == "help" then
				for i=1,NUM_CHAT_WINDOWS do
					_G["ChatFrame" .. i ]:AddMessage("Tongues Commands: "			,1,1,0)
					_G["ChatFrame" .. i ]:AddMessage("   <language>"				,1,1,0)
					--getglobal("ChatFrame" .. i ):AddMessage("   Language <language>"		,1,1,0)
					--getglobal("ChatFrame" .. i ):AddMessage("   Dialect <dialect>"			,1,1,0)
					--getglobal("ChatFrame" .. i ):AddMessage("   Affect <affect>"			,1,1,0)
					--getglobal("ChatFrame" .. i ):AddMessage("   Filter <filter>"			,1,1,0)
					--getglobal("ChatFrame" .. i ):AddMessage("   LoreCompatible <true|false>"	,1,1,0)
					--getglobal("ChatFrame" .. i ):AddMessage("   DialectDrift <true|false>"		,1,1,0)
					--getglobal("ChatFrame" .. i ):AddMessage("   Shapeshift <true|false>"		,1,1,0)
					_G["ChatFrame" .. i ]:AddMessage("   Help"				,1,1,0)
				end;
			elseif param[1] ~= nil and string.lower(param[1]) == "language" then
				if param[2] ~= nil then
					Tongues:SetLanguage(param[2]);
				end;
			elseif param[1] ~= nil and string.lower(param[1]) == "dialect" then

			elseif param[1] ~= nil and string.lower(param[1]) == "filter" then

			elseif param[1] ~= nil and string.lower(param[1]) == "lorecompatible" then

			elseif param[1] ~= nil and string.lower(param[1]) == "dialectdrift" then

			elseif param[1] ~= nil and string.lower(param[1]) == "shapeshift" then
			elseif param[1] ~= nil and string.lower(param[1]) == "reset" then
			--Tongues.UI.MiniMenu:SetPoint("CENTER")
                    TonguesMiniMenu:ClearAllPoints()
                    TonguesMiniMenu:SetPoint("CENTER")
            elseif param[1] ~= nil and string.lower(param[1]) == "opt" then
			
			Tongues.UI.MainMenu.Frame:Show();
			elseif param[1] ~= nil and string.lower(param[1]) == "cycle" then
               --if countLangauge() ~= 1 then
			   Tongues:CycleLanguage();
			   --end
			elseif param[1] ~= nil and string.lower(param[1]) == "remove" then
			
		           if param[2] ~= nil then
				      if param[3] ~= nil then
					     lang=param[2].." "..param[3]
						
							Tongues.Settings.Character.Fluency[Tongues:GetRealLanguage(lang)] = nil;
							else
							Tongues.Settings.Character.Fluency[Tongues:GetRealLanguage(param[2])] = nil;
							end
				       end
			
			elseif param[1] ~= nil then
				Tongues:SetLanguage(param[1]);
			end;
		end;
	end;
	---------------------------------------------------------------------------------------
	---===Helper====----
GetMountPetName = function()
	for i=1,GetNumCompanions("MOUNT") do
    local creatureID, creatureName, creatureSpellID, icon, issummoned = GetCompanionInfo("MOUNT", i);
    if issummoned then
	return creatureName;
	end
	end
end;


-----=================================
	Mountspeak = function(msg)
		local mountname = Tongues:GetMountPetName();
		local mountlanguage = nil;
		local mountspeaktype = nil;	
        local mountType = nil;
		
		for k,v in Tongues.PairsByKeys(Tongues.MountTable) do
		----print(mountname)
		 if mountname == ("Dreadsteed") or mountname == "Felsteed"then
		  mountType = mountname;
		 elseif mountname == "Headless Horseman's Mount" then
		 mountType = "Dreadsteed";
		 elseif string.find(strlower(mountname),strlower(k)) then
		 ----print("hit")
		 mountType = k;
		 end
		end
		
		
		if Tongues.MountTable[mountType] ~= nil then
			local realLanguage = "";
			if Tongues.Language[Tongues.MountTable[mountType]["Language"]] ~= nil then
				if Tongues.Language[Tongues.MountTable[mountType]["Language"]]["alias"] ~= nil then
					mountlanguage = Tongues.Language[Tongues.MountTable[mountType]["Language"]]["alias"];
				else 
					mountlanguage = Tongues.MountTable[mountType]["Language"];
				end;
				mountspeaktype = Tongues.MountTable[mountType]["Speaktype"];
			end;
		
			if mountspeaktype ~= nil and mountlanguage ~= nil then
				Tongues.PreviousMountSentMsg = msg

				---- DO STUFF BEFORE LINKS (WHEN THEY ARE NOT LINKS)
				if string.find(msg,"(.-)(|[cC][0-9a-fA-F]+|H[%a%A]-|h|r)") ~= nil then
					msg = string.gsub(msg,"(.-)(|[cC][0-9a-fA-F]+|H[%a%A]-|h|r)", 
						function(a,link)
							a = Tongues:TranslateWord(a,mountlanguage)
							return a .. link
						end
					);
				end;
				---- DO THE LAST PART OF THE MESSAGE IF NOT A LINK
				if string.find(msg,"(.*)(|[cC][0-9a-fA-F]+|H[%a%A]-|h|r)(.-)$") ~= nil then
					msg = string.gsub(msg,"(.*)(|[cC][0-9a-fA-F]+|H[%a%A]-|h|r)(.-)$", 
						function(a,link,c) 
							c = Tongues:TranslateWord(c,mountlanguage)
							return a .. link .. c
						end
					);
				else
				---- IF NO LINK THEN DO ANYWAY
					msg = Tongues:TranslateWord(msg,mountlanguage)
				end;
				
							end;
		
           Tongues.Hooks.Send( "'s mount " .. mountname .. " " .. mountspeaktype .. ", \"[".. mountlanguage .. "] " .. msg .. "\"", "EMOTE", nil, nil)

		end;
	end;

	-------------------------------------------------------------
	Petspeak = function(msg)
		local petname = UnitName("pet") ;
		local petlanguage = nil;
		local petspeaktype = nil;	

		if Tongues.PetTable[UnitCreatureFamily("pet")] ~= nil then
			local realLanguage = "";
			if Tongues.Language[Tongues.PetTable[UnitCreatureFamily("pet")]["Language"]] ~= nil then
				if Tongues.Language[Tongues.PetTable[UnitCreatureFamily("pet")]["Language"]]["alias"] ~= nil then
					petlanguage = Tongues.Language[Tongues.PetTable[UnitCreatureFamily("pet")]["Language"]]["alias"];
				else 
					petlanguage = Tongues.PetTable[UnitCreatureFamily("pet")]["Language"];
				end;
				petspeaktype = Tongues.PetTable[UnitCreatureFamily("pet")]["Speaktype"];
			end;
		
			if petspeaktype ~= nil and petlanguage ~= nil then
				Tongues.PreviousPetSentMsg = msg

				---- DO STUFF BEFORE LINKS (WHEN THEY ARE NOT LINKS)
				if string.find(msg,"(.-)(|[cC][0-9a-fA-F]+|H[%a%A]-|h|r)") ~= nil then
					msg = string.gsub(msg,"(.-)(|[cC][0-9a-fA-F]+|H[%a%A]-|h|r)", 
						function(a,link)
							a = Tongues:TranslateWord(a,petlanguage)
							return a .. link
						end
					);
				end;
				---- DO THE LAST PART OF THE MESSAGE IF NOT A LINK
				if string.find(msg,"(.*)(|[cC][0-9a-fA-F]+|H[%a%A]-|h|r)(.-)$") ~= nil then
					msg = string.gsub(msg,"(.*)(|[cC][0-9a-fA-F]+|H[%a%A]-|h|r)(.-)$", 
						function(a,link,c) 
							c = Tongues:TranslateWord(c,petlanguage)
							return a .. link .. c
						end
					);
				else
				---- IF NO LINK THEN DO ANYWAY
					msg = Tongues:TranslateWord(msg,petlanguage)
				end;
				
							end;
		
           Tongues.Hooks.Send( "'s pet " .. petname .. " " .. petspeaktype .. ", \"[".. petlanguage .. "] " .. msg .. "\"", "EMOTE", nil, nil)

		end;
	end;
	---------------------------------------------------------------------------------------
	OnLoad = function()
	end;
	---------------------------------------------------------------------------------------
	OnEvent = function(self, event,...)
		self = Tongues;

		if	(event=="ADDON_LOADED") then
			self.Settings.Character.Faction = UnitFactionGroup("player");
			self.Settings.Character.Class   = UnitClass("player");
			self.Settings.Character.Race	= UnitRace("player");
		elseif	(event=="VARIABLES_LOADED") then
			---BETTER TO HEAL TOTALLY PROGRAMMATICALLY
			local tempUI = self.Settings.Character.UI;
			local tempTranslations = self.Settings.Character.Translations;
			local tempLanguage = self.Settings.Character.Language;
			local tempLanguageLearning = self.Settings.Character.LanguageLearning

			local tempScreen = self.Settings.Character.Screen;
			local tempFluency = self.Settings.Character.Fluency;
			local tempAffectFrequency = self.Settings.Character.AffectFrequency;
			local tempTranslators = self.Settings.Character.Translators;

			self.Settings.Character = Tongues_Character
	         

			--- HEAL VARIABLES FROM OLD VERSIONS OR MALFORMED VARIABLES
			if self.Settings.Character.UI == nil then
				self.Settings.Character.UI = tempUI;
			end;
			if self.Settings.Character.Translations == nil then
				self.Settings.Character.Translations = tempTranslations;
			end;
			if self.Settings.Character.Screen == nil then
				self.Settings.Character.Screen = tempScreen;
			end;
			if self.Settings.Character.Fluency == nil then
				self.Settings.Character.Fluency = tempFluency;
			end;
			if self.Settings.Character.AffectFrequency == nil then
				self.Settings.Character.AffectFrequency = tempAffectFrequency;
			end;
			if self.Settings.Character.Translators == nil then
				self.Settings.Character.Translators = tempTranslators;
			end;
			if self.Settings.Character.Language == nil or self.Language[self.Settings.Character.Language] == nil then
				self.Settings.Character.Language = tempLanguage;
			end;
			if self.Settings.Character.LanguageLearning == nil then
				self.Settings.Character.LanguageLearning = tempLanguageLearning;
			end;

			if self.Dialect[self.Settings.Character.Dialect] == nil then
				self.Settings.Character.Dialect = "<None>";
			end;
			if self.Affect[self.Settings.Character.Affect] == nil then
				self.Settings.Character.Affect = "<None>";
			end;
			if self.Filter[self.Settings.Character.Filter] == nil then
				self.Settings.Character.Filter = "<None>";
			end;

			if self.Settings.Character.Language == nil then
				if UnitRace("player") == BRAC["Human"] then
					self.Settings.Character.Language = T_Common--T_Common
				elseif UnitRace("player") ==  BRAC["Orc"] then
					self.Settings.Character.Language = T_Orcish--T_Orcish
				elseif UnitRace("player") == BRAC["Blood Elf"] then
					self.Settings.Character.Language = T_Thalassian
				elseif UnitRace("player") == BRAC["Night Elf"] then
					self.Settings.Character.Language = T_Darnassian
				elseif UnitRace("player") == BRAC["Draenei"] then
					self.Settings.Character.Language = T_Draenei
				elseif UnitRace("player") == BRAC["Tauren"] then
					self.Settings.Character.Language = T_Taurahe
				elseif UnitRace("player") == BRAC["Dwarf"] then
					self.Settings.Character.Language = T_Dwarvish
				elseif UnitRace("player") == BRAC["Undead"] then
					self.Settings.Character.Language = T_Forsaken
				elseif UnitRace("player") == BRAC["Gnome"] then
					self.Settings.Character.Language = T_Gnomish
				elseif UnitRace("player") == BRAC["Troll"] then
					self.Settings.Character.Language = T_Troll
				elseif UnitRace("player") == BRAC["Worgen"] then
				self.Settings.Character.Language = "Gilnean-CodeSpeak"
				
				self.Settings.Character.Fluency[BCT["Wolf"]] = Tongues_Character.Fluency[BCT["Wolf"]] or 100
				elseif UnitRace("player") == BRAC["Goblin"] then
				self.Settings.Character.Language = BRAC["Goblin"]
				elseif UnitRace("player") == "Pandaren" then
				self.Settings.Character.Language = "Pandaren"
				end;
				self.Settings.Character.Fluency[self.Settings.Character.Language] = Tongues_Character.Fluency[self.Settings.Character.Language] or 100

				if UnitFactionGroup("player") == BFAC["Alliance"] then
				  --print("hit")
					self.Settings.Character.Fluency[T_Common] = Tongues_Character.Fluency[T_Common] or 100
				elseif UnitFactionGroup("player") == BFAC["Horde"] then
					self.Settings.Character.Fluency[T_Orcish] = Tongues_Character.Fluency[T_Orcish] or 100
				end;
              
				if Tclass == "DRUID" then
					self.Settings.Character.Fluency[BCT["Bear"]] = self.Settings.Character.Fluency[BCT["Bear"]] or 100;
					self.Settings.Character.Fluency[BCT["Cat"]] = self.Settings.Character.Fluency[BCT["Cat"]] or 100;
					if UnitRace("player")== BRAC["Troll"] then
					self.Settings.Character.Fluency[BCT["Bat"]] = self.Settings.Character.Fluency[BCT["Bat"]] or 100;
					else
					self.Settings.Character.Fluency[T_Bird] = self.Settings.Character.Fluency[T_Bird] or 100;
					end
					self.Settings.Character.Fluency[T_Moonkin] = self.Settings.Character.Fluency[T_Moonkin] or 100;
					self.Settings.Character.Fluency[T_Trentish] = self.Settings.Character.Fluency[T_Trentish] or 100;
					self.Settings.Character.Fluency[T_Seal] = self.Settings.Character.Fluency[T_Seal] or 100;
					self.Settings.Character.Fluency["Orca"] = self.Settings.Character.Fluency["Orca"] or 100;
					self.Settings.Character.Fluency["Stag"] = self.Settings.Character.Fluency["Stag"] or 100;
				elseif Tclass == "SHAMAN" then
				    --print("hit")
					self.Settings.Character.Fluency[T_Wolf] = self.Settings.Character.Fluency[T_Wolf] or 100;
					self.Settings.Character.Fluency[T_Kalimag] = self.Settings.Character.Fluency[T_Kalimag] or 100;
				elseif Tclass == "WARLOCK" then
					self.Settings.Character.Fluency[T_Eredun] = self.Settings.Character.Fluency[T_Eredun] or 100;
					self.Settings.Character.Fluency[T_Demonic] = self.Settings.Character.Fluency[T_Demonic] or 100;
				end;
			end;
			UIDropDownMenu_Initialize(Tongues.UI.MainMenu.Speak.LanguageDropDown.Frame, Tongues.UpdateLanguageDropDown);	
			
			self:SetLanguage(self.Settings.Character.Language);
			
			
			----------------------
			self.Settings.Global = Tongues_Global;
			self.UI:LoadDefaults();
        elseif event == "NEUTRAL_FACTION_SELECT_RESULT" then
			if UnitFactionGroup("player") == BFAC["Alliance"] then
				  --print("hit")
					self.Settings.Character.Fluency[T_Common] = Tongues_Character.Fluency[T_Common] or 100
			elseif UnitFactionGroup("player") == BFAC["Horde"] then
					self.Settings.Character.Fluency[T_Orcish] = Tongues_Character.Fluency[T_Orcish] or 100
			end;
		elseif event == "UPDATE_CHAT_COLOR" then
		  local typec, red,green,blue = ...;
		  if (
			typec == "SAY" or 
			typec == "WHISPER" or
			typec == "YELL" or
			typec == "PARTY" or
			
			typec == "GUILD" or
			typec == "OFFICER" or
			typec == "RAID" or
			typec == "RAID_WARNING" or
			typec == "RAID_LEADER" or
			typec == "PARTY_LEADER" or
			typec == "BATTLEGROUND" or
			typec == "BATTLEGROUND_LEADER" or
			typec == "CHANNEL"
			) then
			   if typec == "SAY" then
			   local saycolor = ChatTypeInfo["SAY"];
			   Tongues.Colors[typec] = {saycolor.r, saycolor.g, saycolor.b}	
			   else
				Tongues.Colors[typec] = {red, green, blue}	
				end
			end
		end;

	end;
	---------------------------------------------------------------------------------------
	Initialize = function(self)

		table.insert(self,self.UI);

	    SLASH_DIALECT1 = "/dialect";
		SlashCmdList["DIALECT"] = self.dialectcmd;
	     
		SLASH_TONGUES1 = "/tongues";
		SlashCmdList["TONGUES"] = self.Command;
		SLASH_PETSPEAK1 = "/petspeak";
		SlashCmdList["PETSPEAK"] = self.Petspeak;
		SLASH_PS1 = "/ps";
		SlashCmdList["PS"] = self.Petspeak;
		
		SLASH_MOUNTSPEAK1 = "/mountspeak";
		SlashCmdList["MOUNTSPEAK"] = self.Mountspeak;
		SLASH_MS1 = "/ms";
		SlashCmdList["MS"] = self.Mountspeak;
	
		Tongues_Global = self.Settings.Global;
		Tongues_Character = self.Settings.Character;
	
		self.Filter = merge({
			self.Filter,
			self.Custom.Filter
		});
	
		self.Dialect = merge({
			self.Dialect,
			self.Custom.Dialect
		});
		self.Language = merge({
			self.Language,
			self.Custom.Language
		});
		self.Affect = merge({
			self.Affect,
			self.Custom.Affect
		});

		self.Frame = CreateFrame("Frame",nil,UIParent);
		self.Frame:RegisterEvent("ADDON_LOADED");
		self.Frame:RegisterEvent("NEUTRAL_FACTION_SELECT_RESULT")
		self.Frame:RegisterEvent("VARIABLES_LOADED");
		self.Frame:RegisterEvent("CHAT_MSG_ADDON");
		self.Frame:RegisterEvent("UPDATE_CHAT_COLOR");
		self.Frame:SetScript("OnEvent", Tongues.OnEvent);
      TTimerFrame = CreateFrame("frame") 
	  TTimerFrame:SetScript("OnUpdate", Tongues.Timer)
	  TTimerFrame:Hide()
		self.UI:Configure()
		local diactxt = false;
		---LDB Setup Merg to tongues 2
		Tongues.LDBT={};
	  Tongues.LDBT.OnClick = function(self)
	  --print(self.value)
	  if diactxt == false then
	 Tongues:SetLanguage(self.value);
	 else
	 Tongues.Settings.Character.Dialect = self.value;
	 UIDropDownMenu_SetSelectedValue(Tongues.UI.MainMenu.Speak.DialectDropDown.Frame, self.value)
	 end
	 end
		
	tBroker = ldbt:NewDataObject("TonguesBroker", {
		type ="data source",
	icon = "Interface\\Icons\\Spell_Shadow_SoulLeech",
	text = "Tongues",
	value =  Tongues_Character.Language,
	label = "Tongues",
	OnClick = function(clickedframe, button)
    if button == "RightButton" then
    Tongues.UI.MainMenu.Frame:Show();
    else
	 if IsAltKeyDown() then
	 --Tongues.MenuClass:new();
	 diactxt = false;
	 Tongues:UpdateLanguageContext();
	 Tongues.MenuClass:Show();
	 elseif IsShiftKeyDown() then
	  diactxt = true;
	 Tongues:UpdateDialectContext();
	 Tongues.MenuClass:Show();
	 
	 else
	
	  --if countLangauge() ~= 1 then
      Tongues:CycleLanguage();
	  --end
	  end
       
    end
    
	end,
	}
)
	end;
	
		---LDB Setup Merg to tongues 2
	--==========================================================================================================
HandleSend = function(self, msg, chatType, langID, language, channel)
		--- NEVER PARSE CHANNEL AFK DND etc,
		if (chatType=="CHANNEL" or chatType=="AFK" or chatType=="DND" or chatType=="BATTLEGROUND_LEADER" or chatType == "RAID_LEADER") then
		 	self.Hooks.Send( msg, chatType, langID, channel );
			return
		end

		local languagename = "";
		local translatelanguage = "";
		local starform = self:hasStarForm()
		--- GET THE RIGHT LANGUAGE AND TAG
		if starform ~= true and self.Settings.Character.ShapeshiftLanguage == true and GetShapeshiftForm(true) ~= 0 and  Tclass == "DRUID" then
			languagename = "[" .. self:ReturnForm() .."] ";

				translatelanguage = self:ReturnForm()
		   
		elseif	UnitFactionGroup("player") == BFAC["Alliance"] and self.Settings.Character.Language == T_Common then
        elseif  UnitFactionGroup("player") == BFAC["Horde"] and self.Settings.Character.Language == T_Orcish then
		elseif self.Settings.Character.Language == self:ReturnSpecialLanguage() then
			language = self.Settings.Character.Language;
			translatelanguage = language;
		else
			languagename = "[" ..  self.Settings.Character.Language .."] ";
			translatelanguage = self.Settings.Character.Language
		end;

		-----PROCESS EMOTES
		if (chatType=="EMOTE") or (chatType=="emote") then
    
			self.Hooks.Send( msg,chatType, langID, channel);
			
			else
			--- APPLY BASIC ROLEPLAYING FULL SENTANCE FILTERS (SHOULDNT EFFECT LINKS)
			---I don't like how i am doing this check but i am doing it...
			if (self.Settings.Character.Screen.Guild == true and (chatType == "GUILD" or chatType=="guild")) then
			--nothing
						v = self:ParseLink(msg, language);

			elseif (self.Settings.Character.Screen.Raid == true and (chatType == "RAID" or chatType == "raid")) then
         				v = self:ParseLink(msg, language);

			elseif     (self.Settings.Character.Screen.RaidAlert == true and (chatType == "RAID_WARNING" or chatType == "raid_warning")) then
           			v = self:ParseLink(msg, language);
		  
		
			elseif     (self.Settings.Character.Screen.Party == true and (chatType == "PARTY" or chatType == "Party" or chatType == "PARTY_LEADER" or chatType == "party_leader")) then
            			v = self:ParseLink(msg, language);

			elseif     (self.Settings.Character.Screen.Officer == true and (chatType == "OFFICER" or chatType == "OFFICER")) then
			v = self:ParseLink(msg, language);

		   else
			msg = self:Substitute(msg, self.Filter[self.Settings.Character.Filter]["filters"]);
			msg = self:ApplyEffect(msg, self.Filter[self.Settings.Character.Filter]["affects"]);

			-- PROCESSES PARTS OF MESSAGE THAT ARE NOT LINKS
			v = self:ParseLink(msg, language);
			end;
		end;

		self.PreviousSentMsg = self:ApplySpeech(msg, false);

		--- Lots of settings have to be handled here
		-----TRANSLATIONS to SELF
		if (self.Settings.Character.Translations.Self == true and chatType~="WHISPER" and chattype~="whisper" and chatType~="CHANNEL" and chatType~="channel") then
		  if self.Settings.Character.Translations.Self == false then 
		     self.Hooks.Send(msg , chatType, langID, channel);
			SELECTED_CHAT_FRAME:AddMessage("(" .. UnitName("player") .. ": " ..msg .. ")",1,1,0);
			else
			SELECTED_CHAT_FRAME:AddMessage("(" .. UnitName("player") .. ": " ..msg .. ")",1,1,0);
			end
		end
		-----PROCESS for SAY or YELL
		if (chatType == "SAY" or chatType == "say" or chatType == "YELL" or chatType=="yell") then
		 ---taken from http://www.wowinterface.com/forums/showthread.php?p=234858#post234858
		     --      Strip all spaces around "*" and split into segments
			self.Hooks.Send( languagename .. v , chatType, langID, channel);
		end;
		----TRANSLATE TO TARGETTED
		if (self.Settings.Character.Translations.Targetted == true) and (UnitIsPlayer("target") ~= nil) and (chatType == "SAY" or chatType=="say" or chatType == "YELL" or chatType=="yell") and UnitFactionGroup("target") == UnitFactionGroup("player") and languagename ~= "" then
			self.Hooks.Send("[Translation - " .. translatelanguage .. "] " .. self:ApplySpeech(msg, false), "WHISPER", nil, UnitName("target"));
		end
		----TRANSLATE TO TRANSLATORS IF THEY ARE VISIBLE
		for kname,vname in pairs(self.Settings.Character.Translators) do
			self.Hooks.Send("[Translation - " .. translatelanguage .. "] " .. self:ApplySpeech(msg, false), "WHISPER", nil, vname);
		end;
		-----DONT DO TRANSLATION IF WHISPER IS SENT
		if (chatType=="WHISPER" or chatType=="whisper") then
			self.Hooks.Send(msg , chatType, langID, channel);
		else

			-----TRANSLATIONS and PROCESS for PARTY 
			if     (self.Settings.Character.Screen.Party == true and (chatType == "PARTY" or chatType == "party" or chatType == "PARTY_LEADER")) then
				if UnitRace("player") == BRAC["Human"] and self.Settings.Character.Language == T_Common
				or UnitRace("player") == BRAC["Orc"] and self.Settings.Character.Language == T_Orcish
				or UnitRace("player") == BRAC["Blood Elf"] and self.Settings.Character.Language == T_Thalassian
				or UnitRace("player") == BRAC["Night Elf"] and self.Settings.Character.Language == T_Darnassian
				or UnitRace("player") == BRAC["Draenei"] and self.Settings.Character.Language == T_Draenei	
				or UnitRace("player") == BRAC["Tauren"] and self.Settings.Character.Language == T_Taurahe
				or UnitRace("player") == BRAC["Dwarf"] and self.Settings.Character.Language == T_Dwarvish
				or UnitRace("player") == BRAC["Undead"] and self.Settings.Character.Language == T_Forsaken
				or UnitRace("player") == BRAC["Gnome"] and self.Settings.Character.Language == T_Gnomish
				or UnitRace("player") == BRAC["Troll"] and self.Settings.Character.Language == T_Troll
				or UnitRace("player") == BRAC["Worgen"] and self.Settings.Character.Language == "Gilnean-CodeSpeak"
				or UnitRace("player") == BRAC["Goblin"] and self.Settings.Character.Language == BRAC["Goblin"]
				or UnitRace("player") == "Pandaran" and self.Settings.Character.Language == "Pandaran" then
					language = nil
				end;
				self.Hooks.Send(msg , chatType, language, channel);
			elseif (self.Settings.Character.Translations.Party == true and (chatType == "PARTY" or chatType == "party"or chatType == "PARTY_LEADER" )) then
				self.Hooks.Send(self:ApplySpeech(msg, false), "PARTY", nil, channel);
			elseif (self.Settings.Character.Translations.Party == true and (chatType ~= "PARTY" and chatType ~= "party" or chatType ~= "PARTY_LEADER") and GetNumSubgroupMembers() ~= 0) then
				self.Hooks.Send(self:ApplySpeech(msg, false), "PARTY", nil, channel);
			elseif (self.Settings.Character.Translations.Party == false and (chatType == "PARTY" or chatType == "party"or chatType == "PARTY_LEADER" )) then
				self.Hooks.Send(languagename .. v , chatType, langID, channel);
			end

			-----TRANSLATIONS and PROCESS for GUILD 
			if     (self.Settings.Character.Screen.Guild == true and (chatType == "GUILD" or chatType=="guild")) then
				if UnitRace("player") == BRAC["Human"] and self.Settings.Character.Language == T_Common
				or UnitRace("player") == BRAC["Orc"] and self.Settings.Character.Language == T_Orcish
				or UnitRace("player") == BRAC["Blood Elf"] and self.Settings.Character.Language == T_Thalassian
				or UnitRace("player") == BRAC["Night Elf"] and self.Settings.Character.Language == T_Darnassian
				or UnitRace("player") == BRAC["Draenei"] and self.Settings.Character.Language == T_Draenei	
				or UnitRace("player") == BRAC["Tauren"] and self.Settings.Character.Language == T_Taurahe
				or UnitRace("player") == BRAC["Dwarf"] and self.Settings.Character.Language == T_Dwarvish
				or UnitRace("player") == BRAC["Undead"] and self.Settings.Character.Language == T_Forsaken
				or UnitRace("player") == BRAC["Gnome"] and self.Settings.Character.Language == T_Gnomish
				or UnitRace("player") == BRAC["Troll"] and self.Settings.Character.Language == T_Troll
				or UnitRace("player") == BRAC["Worgen"] and self.Settings.Character.Language ==  "Gilnean-CodeSpeak"
				or UnitRace("player") == BRAC["Goblin"] and self.Settings.Character.Language == BRAC["Goblin"]
				or UnitRace("player") == "Pandaran" and self.Settings.Character.Language == "Pandaran" then
					language = nil
				end;
				self.Hooks.Send(msg , "GUILD", language, channel);
			elseif (self.Settings.Character.Translations.Guild == true and (chatType == "GUILD" or chatType=="guild")) then
				self.Hooks.Send(self:ApplySpeech(msg, false), "GUILD", nil, channel);
			elseif (self.Settings.Character.Translations.Guild == true and (chatType ~= "GUILD" and chatType~="guild") and IsInGuild()) then
				self.Hooks.Send(self:ApplySpeech(msg, false), "GUILD", nil, channel);
			elseif (self.Settings.Character.Translations.Guild == false and (chatType == "GUILD" or chatType=="guild")) then
				self.Hooks.Send(languagename .. v , chatType, langID, channel);
			end
			-----TRANSLATIONS and PROCESS for OFFICER
			if     (self.Settings.Character.Screen.Officer == true and chatType == "OFFICER") then
					if UnitRace("player") == BRAC["Human"] and self.Settings.Character.Language == T_Common
				or UnitRace("player") == BRAC["Orc"] and self.Settings.Character.Language == T_Orcish
				or UnitRace("player") == BRAC["Blood Elf"] and self.Settings.Character.Language == T_Thalassian
				or UnitRace("player") == BRAC["Night Elf"] and self.Settings.Character.Language == T_Darnassian
				or UnitRace("player") == BRAC["Draenei"] and self.Settings.Character.Language == T_Draenei	
				or UnitRace("player") == BRAC["Tauren"] and self.Settings.Character.Language == T_Taurahe
				or UnitRace("player") == BRAC["Dwarf"] and self.Settings.Character.Language == T_Dwarvish
				or UnitRace("player") == BRAC["Undead"] and self.Settings.Character.Language == T_Forsaken
				or UnitRace("player") == BRAC["Gnome"] and self.Settings.Character.Language == T_Gnomish
				or UnitRace("player") == BRAC["Troll"] and self.Settings.Character.Language == T_Troll
				or UnitRace("player") == BRAC["Worgen"] and self.Settings.Character.Language ==  "Gilnean-CodeSpeak"
				or UnitRace("player") == BRAC["Goblin"] and self.Settings.Character.Language == BRAC["Goblin"]
				or UnitRace("player") == "Pandaran" and self.Settings.Character.Language == "Pandaran" then
					language = nil
				end;
				self.Hooks.Send(msg , "OFFICER", language, channel);
			elseif (self.Settings.Character.Translations.Officer == true and (chatType == "OFFICER" or chatType == "officer")) then
				self.Hooks.Send(self:ApplySpeech(msg, false), "OFFICER", nil, channel);
			elseif (self.Settings.Character.Translations.Officer == true and (chatType ~= "OFFICER" and chatType ~= "officer") and IsInGuild()) then
				self.Hooks.Send(self:ApplySpeech(msg, false), "OFFICER", nil, channel);
			elseif (self.Settings.Character.Translations.Officer == false and (chatType == "OFFICER" or chatType == "officer")) then
				self.Hooks.Send(languagename .. v , chatType, langID, channel);
			end
			-----TRANSLATIONS and PROCESS for RAID
			if     (self.Settings.Character.Screen.Raid == true and (chatType == "RAID" or chatType == "raid")) then
				if UnitRace("player") == BRAC["Human"] and self.Settings.Character.Language == T_Common
				or UnitRace("player") == BRAC["Orc"] and self.Settings.Character.Language == T_Orcish
				or UnitRace("player") == BRAC["Blood Elf"] and self.Settings.Character.Language == T_Thalassian
				or UnitRace("player") == BRAC["Night Elf"] and self.Settings.Character.Language == T_Darnassian
				or UnitRace("player") == BRAC["Draenei"] and self.Settings.Character.Language == T_Draenei	
				or UnitRace("player") == BRAC["Tauren"] and self.Settings.Character.Language == T_Taurahe
				or UnitRace("player") == BRAC["Dwarf"] and self.Settings.Character.Language == T_Dwarvish
				or UnitRace("player") == BRAC["Undead"] and self.Settings.Character.Language == T_Forsaken
				or UnitRace("player") == BRAC["Gnome"] and self.Settings.Character.Language == T_Gnomish
				or UnitRace("player") == BRAC["Troll"] and self.Settings.Character.Language == T_Troll
				or UnitRace("player") == BRAC["Worgen"] and self.Settings.Character.Language ==  "Gilnean-CodeSpeak"
				or UnitRace("player") == BRAC["Goblin"] and self.Settings.Character.Language == BRAC["Goblin"]
				or UnitRace("player") == "Pandaran" and self.Settings.Character.Language == "Pandaran" then
					language = nil
				end;
				self.Hooks.Send(msg ,"RAID", language, channel);
			elseif (self.Settings.Character.Translations.Raid == true and (chatType == "RAID" or chatType == "raid")) then
				self.Hooks.Send(self:ApplySpeech(msg, false), "RAID", nil, channel);
			elseif (self.Settings.Character.Translations.Raid == true and (chatType ~= "RAID" and chatType ~= "raid") and UnitInRaid("player")) then
				self.Hooks.Send(self:ApplySpeech(msg, false), "RAID", nil, channel);
			elseif (self.Settings.Character.Translations.Raid == false and (chatType == "RAID" or chatType == "raid")) then
				self.Hooks.Send(languagename .. v , chatType, langID, channel);
			end
			-----TRANSLATIONS and PROCESS for RAIDALERT
			if     (self.Settings.Character.Screen.RaidAlert == true and (chatType == "RAID_WARNING" or chatType == "raid_warning")) then
				if UnitRace("player") == BRAC["Human"] and self.Settings.Character.Language == T_Common
				or UnitRace("player") == BRAC["Orc"] and self.Settings.Character.Language == T_Orcish
				or UnitRace("player") == BRAC["Blood Elf"] and self.Settings.Character.Language == T_Thalassian
				or UnitRace("player") == BRAC["Night Elf"] and self.Settings.Character.Language == T_Darnassian
				or UnitRace("player") == BRAC["Draenei"] and self.Settings.Character.Language == T_Draenei	
				or UnitRace("player") == BRAC["Tauren"] and self.Settings.Character.Language == T_Taurahe
				or UnitRace("player") == BRAC["Dwarf"] and self.Settings.Character.Language == T_Dwarvish
				or UnitRace("player") == BRAC["Undead"] and self.Settings.Character.Language == T_Forsaken
				or UnitRace("player") == BRAC["Gnome"] and self.Settings.Character.Language == T_Gnomish
				or UnitRace("player") == BRAC["Troll"] and self.Settings.Character.Language == T_Troll
				or UnitRace("player") == BRAC["Worgen"] and self.Settings.Character.Language ==  "Gilnean-CodeSpeak"
				or UnitRace("player") == BRAC["Goblin"] and self.Settings.Character.Language == BRAC["Goblin"]
				or UnitRace("player") == "Pandaran" and self.Settings.Character.Language == "Pandaran" then
					language = nil
				end;
				self.Hooks.Send(msg ,"RAID_WARNING", language, channel);
			elseif (self.Settings.Character.Translations.RaidAlert == true and (chatType == "RAID_WARNING" or chatType == "raid_warning")) then
				self.Hooks.Send(self:ApplySpeech(msg, false), "RAID_WARNING", nil, channel);
			elseif (self.Settings.Character.Translations.RaidAlert == true and (chatType ~= "RAID_WARNING" and chatType ~= "raid_warning") and UnitInRaid("player")) then
				self.Hooks.Send(self:ApplySpeech(msg, false), "RAID_WARNING", nil, channel);
			elseif (self.Settings.Character.Translations.RaidAlert == false and (chatType == "RAID_WARNING" or chatType == "raid_warning")) then
				self.Hooks.Send(languagename .. v , chatType, langID, channel);
			end
			-----TRANSLATIONS and PROCESS for BATTLEGROUND
			if     (self.Settings.Character.Screen.Battleground == true and (chatType == "BATTLEGROUND" or chatType == "battleground")) then
				if UnitRace("player") == BRAC["Human"] and self.Settings.Character.Language == T_Common
				or UnitRace("player") == BRAC["Orc"] and self.Settings.Character.Language == T_Orcish
				or UnitRace("player") == BRAC["Blood Elf"] and self.Settings.Character.Language == T_Thalassian
				or UnitRace("player") == BRAC["Night Elf"] and self.Settings.Character.Language == T_Darnassian
				or UnitRace("player") == BRAC["Draenei"] and self.Settings.Character.Language == T_Draenei	
				or UnitRace("player") == BRAC["Tauren"] and self.Settings.Character.Language == T_Taurahe
				or UnitRace("player") == BRAC["Dwarf"] and self.Settings.Character.Language == T_Dwarvish
				or UnitRace("player") == BRAC["Undead"] and self.Settings.Character.Language == T_Forsaken
				or UnitRace("player") == BRAC["Gnome"] and self.Settings.Character.Language == T_Gnomish
				or UnitRace("player") == BRAC["Troll"] and self.Settings.Character.Language == T_Troll
				or UnitRace("player") == BRAC["Worgen"] and self.Settings.Character.Language ==  "Gilnean-CodeSpeak"
				or UnitRace("player") == BRAC["Goblin"] and self.Settings.Character.Language == BRAC["Goblin"]
				or UnitRace("player") == "Pandaran" and self.Settings.Character.Language == "Pandaran" then
					language = nil
				end;
				self.Hooks.Send(msg , "BATTLEGROUND", language, channel);
			elseif (self.Settings.Character.Translations.Battleground == true and (chatType == "BATTLEGROUND" or chatType == "battleground")) then
				self.Hooks.Send(self:ApplySpeech(msg, false), "BATTLEGROUND", nil, channel);
			elseif (self.Settings.Character.Translations.Battleground == true and (chatType ~= "BATTLEGROUND" and chatType ~= "battleground")) then
				self.Hooks.Send(self:ApplySpeech(msg, false), "BATTLEGROUND", nil, channel);
			elseif (self.Settings.Character.Translations.Battleground == false and (chatType == "BATTLEGROUND" or chatType == "battleground")) then
				self.Hooks.Send(languagename .. v , chatType, langID, channel);
			end
		end;
	end;
	---------------------------------------------------------------------------------------
	--local cID = nil;
	HandleReceive = function(self,CHAT_FRAME,event, ...)
		local message, snder, lang, channelString, target, flags, unknown, channelNumber, channelName, unknown, counter = ...;
       --CHAT_FRAME = CHAT_FRAME;
		--FOR NOW DOING DIRECT REQUESTS FROM THE USER WHO SENDS THE 'LANGUAGE'	--
		local TP = "<Tongues>"
		local TPLen = string.len(TP)
		dontprint = 1;
	   local cID = CHAT_FRAME:GetID()
		----print(cID:GetID())
		local cIDN = _G["ChatFrame"..cID];--CHAT_FRAME:GetID();
		--local chatFrame = _G["ChatFrame"..self:GetID()];
		----print(chatFrame)
    --print("ID"..cID);
	--print("event"..event)
	 ----print(...)
	 
		if	(event=="CHAT_MSG_SAY") 	or 
			(event=="CHAT_MSG_YELL") 	or 
			(event=="CHAT_MSG_GUILD") 	or 
			(event=="CHAT_MSG_PARTY") 	or 
			(event=="CHAT_MSG_PARTY_LEADER") or
			(event=="CHAT_MSG_RAID") 	or 
			(event=="CHAT_MSG_RAID_WARNING")or 
			(event=="CHAT_MSG_OFFICER") 	or
			(event=="CHAT_MSG_BATTLEGROUND")then

			--CODE TO EXTRACT LANGUAGE TAG IF ONE EXISTS
			local languagetag = ""
			if string.match(message, "%[([%a%s'%-]+)%][%a%A]+") then
				languagetag = string.gsub(message, "%[([%a%s'%-]+)%]([%a%A]+)", "%1")
				message = string.gsub(message, "%[([%a%s'%-]+)%]([%a%A]+)", "%2")
				languagetag = "[" .. languagetag .. "] "
			end

			---------------------------------------------
			message = self:Substitute(message, self.Filter[self.Settings.Character.Filter]["filters"]);
			message = self:ApplyEffect(message, self.Filter[self.Settings.Character.Filter]["affects"]);

			--CODE TO READ LANGUAGE TAG IF ONE EXISTS
			if (languagetag) then
			message =  languagetag .. message
			end
			---------------------------------------------

			--randomseed(math.random(0,2147483647)+(GetTime()*1000));
			if ((lang == T_Common) and (UnitFactionGroup("player") == BFAC["Alliance"]) ) or 
			   ((lang == T_Orcish) and (UnitFactionGroup("player") == BFAC["Horde"]   ) ) then
                 
					--- Check if a player knows a [<Language>] spoken in Blizzard Common/Orcish
					--print(message)
					if string.match(message , "^%[[%a%s'%-]+%][%a%A]+") then
						local language = string.gsub(message, "^%[([%a%s'%-]+)%]([%a%A]+)", "%1")
						language = self:GetRealLanguage(language)
						local fluency = self.Settings.Character.Fluency[language] or 0

						local prepstring = TP .. ":RT:fluency=" .. fluency .. ":channel=".. event ..":frame=" ..cID .. ":language=" .. language .. "" 
						prepstring = string.sub(prepstring, 1, TONGUES_MAX_MSG_LEN)
						--Tonguesc:SendMessage("WHISPER",arg4,"RT",fluency,event,frame,language)
						--- Only request if the user knows the language
						if (math.random(1,100)<= fluency) then
							--SendAddonMessage("Tongues", prepstring, "WHISPER", snder );
							
							 Tonguesc:TonguesSendMessage("WHISPER",snder,"RT",fluency,event,cID,language)
							
							if self.Settings.Character.LoreCompatibility == true then
								self.Hooks.Send("LORE::TR::" .. snder, "CHANNEL", nil, GetChannelName("xtensionxtooltip2"))
							end;
							dontprint = 0;
						else
						  
							self:LearnRequest(language,UnitFactionGroup("player"),UnitRace("player"),UnitClass("player"),cID,fluency,snder)
				
						end;
					--- If player 'doesnt know' Common/Orcish, hash it here
					elseif self.Settings.Character.Fluency[lang] == nil or self.Settings.Character.Fluency[lang] < 100 then	
						lang = self:GetRealLanguage(lang)
						local fluency = self.Settings.Character.Fluency[lang] or 0
						if (math.random(1,100)<= fluency) then
						--print("hi!")
						else
						local fluency = self.Settings.Character.Fluency[lang] or 0
						----print(cID)
						
							self:LearnRequest(lang,UnitFactionGroup("player"),UnitRace("player"),UnitClass("player"),cID, fluency, snder)
							--self:ApplySpeech(message,true)
							message = self:ParseLink2(message,lang);
							message = "[" .. lang .. "] " .. message
		
							----print(message);
							--dontprint==0;
						end;
					end;		
			elseif UnitFactionGroup("player") == "Neutral"then
			else
				--- If player does know other Blizzard Languages (ie blood elf with Thalassian), but the character /shouldn't/ know it (for RP reasons,) hash it here 
				if self:ReturnSpecialLanguage() == lang then
					if self.Settings.Character.Fluency[lang] == nil or self.Settings.Character.Fluency[lang] < 100 then	
						lang = self:GetRealLanguage(lang)
						local fluency = self.Settings.Character.Fluency[lang] or 0
						if (math.random(1,100)<= fluency) then
						else
							self:LearnRequest(lang,UnitFactionGroup("player"),UnitRace("player"),UnitClass("player"),cID, fluency, snder)
							message = self:ParseLink2(message,lang);
						end;
					end;

				--- If player doen't know other Blizzard Languages (ie human with gnomish), but the character /should/ know if (for RP reasons), send request
				--- Not sure if Cross Faction can be done this way, but it will be disabled here if it can to meet EULA
				else
					lang = self:GetRealLanguage(lang)
					if self:IsMyFactionLanguage(lang) == true then
						local fluency = self.Settings.Character.Fluency[lang] or 0
						local prepstring = TP .. ":RT:fluency=" .. fluency .. ":channel=".. event ..":frame=" .. cID .. ":language=" .. lang .. "" 
						prepstring = string.sub(prepstring, 1, TONGUES_MAX_MSG_LEN)
						----print(prepstring);

							if (math.random(1,100) <= fluency) then
								---SendAddonMessage("Tongues", prepstring, "WHISPER", snder );
								Tonguesc:TonguesSendMessage("WHISPER",snder,"RT",fluency,event,cID,lang)
								if self.Settings.Character.LoreCompatibility == true then
									self.Hooks.Send("LORE::TR::" .. snder, "CHANNEL", nil, GetChannelName("xtensionxtooltip2"))
								end;
							else
								self:LearnRequest(lang,UnitFactionGroup("player"),UnitRace("player"),UnitClass("player"),cID, fluency, snder)
							end;
					end;
					dontprint = 1;
				end;
			end;
		--------------------------------FOR LORE COMPATIBILITY----------------------------------------------------
		--elseif (event=="CHAT_MSG_CHANNEL") and (lang == "xtensionxtooltip2") and this:GetID() == 1 then
		--	if ( message == "LORE::ST::" .. UnitName("player") and arg2 == UnitName("player")) then
		--		self.Hooks.Send("<LoRe5> Self-test executed. Auto-translation works properly.", "WHISPER", nil, arg2 )
		--	elseif ( message == "LORE::TR::" .. UnitName("player") and arg2 ~= UnitName("player")) then
		--		self.Hooks.Send("<LoRe5>" .. self.PreviousSentMsg, "WHISPER", GetDefaultLanguage(), arg2 )				
		--	elseif ( message == "LORE::LR::" .. string.lower(UnitName("player")) and arg2 ~= UnitName("player")) then
		--		local str = "I understand";
		--		for k,v in pairs(self.Settings.Character.Fluency) do
		--			if v > 0 then
		--				str = str .. " " .. k
		--			end
		--		end
		--		self.Hooks.Send("<LoRe5> " .. str, "WHISPER", GetDefaultLanguage(), arg2 )
		--	elseif ( message == "LORE::VER::" .. string.lower(UnitName("player")) and arg2 ~= UnitName("player")) then
		--		self.Hooks.Send("<LoRe5> My Tongues version is v" .. self.Version, "WHISPER", GetDefaultLanguage(), arg2 )
		--	end;
		--elseif (event=="CHAT_MSG_WHISPER") and this:GetID() == 1 then
		--	if string.sub( message, 1, 7 ) =="<LoRe5>" then
		--		getglobal("ChatFrame" .. this:GetID() ):AddMessage( "(" .. arg2 .. ": " .. string.sub( message, 8, string.len(arg1) ) .. ")", 1.0, 1.0, 0.0 );
		--		dontprint = 0;
		--	end;
		--elseif (event=="CHAT_MSG_WHISPER_INFORM") and this:GetID() == 1 then
		--	if string.sub( arg1, 1, 7 ) =="<LoRe5>" or string.sub( arg1, 1, 14) == "[Translation -" then
		--		dontprint = 0;
		--	end;
		----------------------------------------------------------------------------------------------------------
		--ALLOWS TRANSLATION OF PET SPEAK AND RP EMOTE SPEAK
		elseif (event=="CHAT_MSG_EMOTE") then
			--PETSPEAK
			if string.match( message, "^'s pet [%a%A]+ [%a%A]+, \"[%a%A]+\"" ) then
				
				local petname, petspeaktype, petspeak = string.match( message, "^'s pet ([%a%A]+) ([%a%A]+), \"([%a%A]+)\"" )
				
				message = string.match( message, "%b\"\"")
				local petlanguage = ""
				petlanguage, message = string.match( message, "\"%[([%a%A]-)%] ([%a%A]-)\"");

				language = self:GetRealLanguage(petlanguage)
				local fluency = self.Settings.Character.Fluency[petlanguage] or 0

				local prepstring = "<Tongues>:PR:fluency=" .. fluency .. ":petname=".. petname ..":frame=" .. cID .. ":language=" .. petlanguage .. ":petspeaktype=" .. petspeaktype .. ":"

				--- Only request if the user knows the language
				if (math.random(1,100)<= fluency) then
					--SendAddonMessage("Tongues", prepstring, "WHISPER", arg2 );
					 Tonguesc:TonguesSendMessage("WHISPER",snder,"PR",fluency,petname,cID,petlanguage,petspeaktype)
					dontprint = 0;
				else
				----print("Before --print"..cID);
					self:LearnRequest(petlanguage,UnitFactionGroup("player"),UnitRace("player"),UnitClass("player"),cID,fluency,snder)
					local prepstring = "[" .. petname .. "] " .. petspeaktype .. ": " .. petspeak
					prepstring = string.sub(prepstring, 1, TONGUES_MAX_MSG_LEN)
					for i=1,NUM_CHAT_WINDOWS do
					if i~= 2 then
					_G["ChatFrame".. i]:AddMessage(prepstring)
					end
					end
					dontprint = 0;
				end;
			--NORMAL EMOTE SPEAK
			--elseif string.match( message, "%b\"\"" ) then
				-- local language
				--for k in string.gmatch( message, "%b\"\"" ) do
					-- getglobal("ChatFrame".. this:GetID()):AddMessage(k)
				--end;--:AddMessage(trace.." "..setTRPColorToString(Nom.." Says:  "..phrase),NpcSay.r,NpcSay.g,NpcSay.b,NpcSay.id);
			
			-- --	--SendAddonMessage()
				-- dontprint = 0;
				--if string.find(emote,"Says:  ") then
			  --[[  local Nom = string.sub(emote,3,string.find(emote,"\"\  ")-2);
			    local phrase = string.sub(emote,string.find(emote," \"\ ")+6);
			     local NpcSay = ChatTypeInfo["MONSTER_SAY"];
				 getglobal("ChatFrame".. this:GetID()):AddMessage(k)]]
				 ---mountspeak
				 elseif string.match( message, "^'s mount [%a%A]+ [%a%A]+, \"[%a%A]+\"" ) then
				
				local mountname, mountspeaktype, mountspeak = string.match( message, "^'s mount ([%a%A]+) ([%a%A]+), \"([%a%A]+)\"" )
				
				message = string.match( message, "%b\"\"")
				local mountlanguage = ""
				mountlanguage, message = string.match( message, "\"%[([%a%A]-)%] ([%a%A]-)\"");

				language = self:GetRealLanguage(mountlanguage)
				local fluency = self.Settings.Character.Fluency[mountlanguage] or 0

				local prepstring = "<Tongues>:RMN:fluency=" .. fluency .. ":mountname=".. mountname ..":frame=" .. cID .. ":language=" .. mountlanguage .. ":mountspeaktype=" .. mountspeaktype .. ":"

				--- Only request if the user knows the language
				if (math.random(1,100)<= fluency) then
					--SendAddonMessage("Tongues", prepstring, "WHISPER", snder );
					 Tonguesc:TonguesSendMessage("WHISPER",snder,"RMN",fluency,mountname,cID,mountlanguage,mountspeaktype)
					dontprint = 0;
				else
					self:LearnRequest(mountlanguage,UnitFactionGroup("player"),UnitRace("player"),UnitClass("player"),cID,fluency,snder)
				
				local prepstring = "["..UnitName("player").."'s " .. mountname .. "] " .. mountspeaktype .. ": " .. mountspeak
				if snder == UnitName("player") then
				prepstring = "["..mountname .. "] " .. mountspeaktype .. ": " .. mountspeak
				end
					prepstring = string.sub(prepstring, 1, TONGUES_MAX_MSG_LEN)
					for i=1,NUM_CHAT_WINDOWS do
					if i~=2 then
					_G["ChatFrame".. i]:AddMessage(prepstring)
					end
					end
					dontprint = 0;
				end;
		


			else
				dontprint = 1;
			end;
			
		end;
		--print(dontprint);
		--------------------------------END LORE COMPATIBILITY----------------------------------------------------
		if dontprint == 1 then
			self.Hooks.Receive(cIDN,event, ...)
		end;	

	end;
	---------------------------------------------------------------------------------------
	LearnRequest = function(self,language,faction,race,class, frame, fluency, toperson)
		if self.Settings.Character.LanguageLearning == true then
			--SendAddonMessage("Tongues","<Tongues>:RL:language=" .. language .. ":faction=" .. faction .. ":race=".. race .. ":class=" .. class .. ":frame=" .. frame .. ":fluency=" .. fluency, "WHISPER", toperson)
			 Tonguesc:TonguesSendMessage("WHISPER",toperson,"RL",language,faction,race,class,frame,fluency)
		end;
	end;
	---------------------------------------------------------------------------------------
	ProcessMessage = function(self , msg)	
		msg = self:ApplySpeech(msg, true);
		return msg
	end;
	---------------------------------------------------------------------------------------
	ApplySpeech = function( self, msg, languageflag)
		-- For Filters
		local type = "Filter";
		local s = self.Settings.Character[type];
		if (self[type] ~= nil ) and (self[type][s] ~= nil ) then
			msg = self:Substitute(msg, self[type][s]["filters"]);
			msg = self:Substitute(msg, self[type][s]["affects"]);
		end;
		-- End Filters

		-- For Dialects
		type = "Dialect";
		s = self.Settings.Character[type];

		if (self[type] ~= nil ) and (self[type][s] ~= nil ) then
			-- Dialect Filters
			msg = self:Substitute(msg, self[type][s]["filters"]);
			-- End Dialect Filters
			msg = self:Substitute(msg, self[type][s]["substitute"]);

				-- Dialect Phonetics  (ones that adjust phonemes)
				msg = self:Substitute(msg,  self[type][s]["exceptions"]);
				msg = self:ApplyEffect(msg, self[type][s]["rules"]);
				msg = self:ApplyEffect(msg, self[type][s]["mutation"], true);
				msg = self:ApplyEffect(msg, self[type][s]["remap"], true);
				-- End Dialect Phonetics


			-- For Languages
			if languageflag == true then
				if self:hasStarForm() ~= true and self.Settings.Character.ShapeshiftLanguage == true and GetShapeshiftForm(true) ~= 0 and Tclass == "DRUID" then
						
		--msg = self:ApplyLanguage("Language",msg);
		 if string.find(msg,"^[(]") then
				   msg = msg 
				   else
					msg = self:ApplyLanguage("Language",msg);
					end
		
		
				elseif 	((self.Settings.Character.Language == T_Common) and (self.Settings.Character.Faction == "Alliance") ) or
					((self.Settings.Character.Language == T_Orcish) and (self.Settings.Character.Faction == "Horde") ) or 
					(self.Settings.Character.Language == self:ReturnSpecialLanguage() ) then
				else
				   if string.find(msg,"^[(]") then
				   msg = msg 
				   else
					msg = self:ApplyLanguage("Language",msg);
					end
			
					
				end;
			end;
			-- End Languages

			-- Dialect Affects
			msg = self:ApplyEffect(msg, self[type][s]["affects"]);
			-- End Dialect Affects
		end	
		-- End Dialects

		-- For Affects
		local type = "Affect";
		local s = self.Settings.Character[type];

		--randomseed(math.random(0,2147483647)+(GetTime() * 1000));
		if (self[type] ~= nil ) and (self[type][s] ~= nil ) and (math.random(1,100) < self.Settings.Character.AffectFrequency) then
			msg = self:ApplyEffect(msg, self[type][s]["substitute"]);
		end;
		-- End Affects
		

		return msg
	end;
	---------------------------------------------------------------------------------------
	ApplyEffect = function (self , msg, t)
		if (t ~= nil) then
			local a = {};
			local k;
			local i;
			local ilevel,klevel;

			for ilevel, klevel in ipairs(t) do
				
				-- insert into indexed table
				for k,v in pairs(klevel) do 
					table.insert(a, k)
				end
					-- sort by key length
				for i=1,#a do
					for k,v in ipairs(a) do 
						if a[k+1] ~= nil then
							if string.len(a[k]) < string.len(a[k+1]) then
								a[k], a[k+1] = a[k+1], a[k] 
							end
						end
					end
				end
	
				-- perform substitutions
				for i,k in ipairs(a) do
					msg = string.gsub(msg, k, klevel[k]);
				end
			end;
		end
			
		return msg
	end;
	---------------------------------------------------------------------------------------
	ApplyLanguage = function (self, type, msg)
		local s = self.Settings.Character[type];

        

		if self:hasStarForm()~= true and self.Settings.Character.ShapeshiftLanguage == true and GetShapeshiftForm(true) ~= 0 and Tclass == "DRUID" then
				s = self:ReturnForm();
			
		end;
		
		
		
		
		msg = Tongues:TranslateWord(msg,s)

		return msg
	end;
	---------------------------------------------
	Substitute = function(self, text, t, phone)
		--- Link parsing suppression still needs to be added.
		if (t ~= nil) then
			if (text ~= nil) then
				for ilevel, klevel in ipairs(t) do
					local a = {};
					local b = {};
					local k;
					local i;

					-- insert into indexed table
					for k,v in pairs(klevel) do 
						table.insert(a, k) 
					end
	
					-- sort by key length
					for i=1,#a do
						for k,v in ipairs(a) do 
							if a[k+1] ~= nil then
								if string.len(a[k]) < string.len(a[k+1]) then
									a[k], a[k+1] = a[k+1], a[k] 
								end
							end
						end
					end

					-- perform substitutions
					for i,k in ipairs(a) do 

						-----------------------------------------------------------------
						if phone ~= true then 
							local originaltext = text;
							
							for w in string.gmatch(string.lower(text), "%f[%a0-9'](" .. string.lower(k) .. ")%f[^%a0-9']") do
								local starter, stopper, texter = string.find(string.lower(text), "%f[%a0-9'](" .. string.lower(w) .. ")%f[^%a0-9']")
								if texter ~= nil then
									local texter = string.sub(text, starter,stopper)
									if texter ~= nil then
										text = string.gsub(text, "%f[%a0-9']" .. texter .. "%f[^%a0-9']", 
										function(a) 
											return self.casematch(a,w,klevel) 
										end);
									end;
								end;
							end;
						else
						-----------------------------------------------------------------
							text = string.gsub(string.lower(text), "%f[%a0-9']" .. k .. "%f[^%a0-9']", t[k])	
						-----------------------------------------------------------------
						end;
					end
				end;
			end;
		end;
		return text;
	end;
	------------------------------------------------------------------------------------------------------------------
	ReturnForm = function(self)
		if Tongues.Settings.Character.ShapeshiftLanguage == true and GetShapeshiftForm(true) ~=0 and Tclass == "DRUID" then
			local icon, name, active, castable;
	           
			----print(Tongues.Settings.Character.ShapeshiftLanguage)
			for i=1, GetNumShapeshiftForms() do
				icon, name, active, castable = GetShapeshiftFormInfo(i);
				if active == 1 and Tclass == "DRUID" then
					if (name == "Dire Cat Form" or name=="Cat Form") then
						s = BCT["Cat"];
					elseif name == "Aquatic Form" then
						s = T_Seal;
						for i = 1, NUM_GLYPH_SLOTS do
							local enabled, glyphType, glyphTooltipIndex, glyphSpell, icon  = GetGlyphSocketInfo(i)--GetGlyphInfo(i)
						
							if (glyphSpell == 114333) then
							s = "Orca";
							end
						end
					elseif (name == "Dire Bear Form" or name=="Bear Form") then
						s = BCT["Bear"];
					elseif name == "Travel Form" then
					    s = "Stag"
						for i = 1, NUM_GLYPH_SLOTS do
							local enabled, glyphType, glyphTooltipIndex, glyphSpell, icon  = GetGlyphSocketInfo(i)--GetGlyphInfo(i)
						    if glyphSpell == 131113 then
								s = BCT["Cat"];
							end
						end
					elseif name == "Moonkin Form" then
							 s = T_Moonkin;
	
					
					elseif name == "Flight Form" or name == "Swift Flight Form" then
					 if UnitRace("player")==BRAC["Troll"] then
					s = BCT["Bat"];
					else
					s = T_Bird;
					end
						
					elseif name == "Tree of Life" or "Treant Form" then
						s = T_Trentish;
					end;
				end;
			end;
		end;
		return s
	end;
	---------------------------------------------------------------------------------------
TranslateWord = function(self,word,s)
                
		word = string.gsub( word, "[%a%!']+", 
			function(word)
			    local ignoreflag = ""; 
				local newword = "";
				local newnewword = "";
				local ignorewordflag = false;
				local substituteflag = false;
				local realLanguage = s;
				local lastlang = "";
				
				--[[if ( (string.sub(word, 0, 1)) == "$" or (string.sub(word, 0, 1)) == "=" ) then 
		                    print( string.sub(word, 2, -1)); 
							return string.sub(word, 2, -1)
				end]]
				if self.Language[s] ~= nil then
					if self.Language[s]["alias"] ~= nil then
						realLanguage = self.Language[s]["alias"];
						lastlang = realLanguage;
					end;

					--- IGNORE KEYWORDS
					if self.Language[realLanguage]["ignore"] ~= nil then
						for i,v in ipairs(self.Language[realLanguage]["ignore"]) do
							if string.lower(v) == string.lower(word) and ignorewordflag == false then
								ignorewordflag = true;
								newnewword = v
							end;
						end;
					end;
	
					--- SUBSTITUTE THE SUBSTITUTE WORDS
					if self.Language[realLanguage]["substitute"] ~= nil and ignorewordflag == false then
						for k,v in pairs(self.Language[realLanguage]["substitute"]) do
							if string.lower(k) == string.lower(word) and substituteflag == false then
								substituteflag = true;
								newnewword = v
							end;
						end;
					end;
	                ----print(string.sub(word,1,1))
					--[[if ( string.find(word,"$") ) then
							    newnewword =  string.gsub(word, "$", "%1")
								
								
							    --ignorewordflag = true;
								--return newnewword;
							end]]
						   
					--- HASH ANYTHING ELSE
					if ignorewordflag == false and substituteflag == false then
						-- HASH THE NEW WORD
						
						local i = string.len(word);
						local h = self.Hash(string.lower(word));
						if (i > #self.Language[realLanguage]) then 
							i = #self.Language[realLanguage];
						end;
						j = mod(h,#self.Language[realLanguage][i])+1;
						newword = self.Language[realLanguage][i][j];
						
						-- GET THE RIGHT CAPTIALS BACK
						for n=1,string.len(newword) do
							if string.match(string.sub(word,n,n),"%u") then
								newnewword = newnewword .. string.upper(string.sub(newword,n,n))
							else
								newnewword = newnewword .. string.sub(newword,n,n)
							end;
						end;
						 
				

					end;
								
				else
					newnewword = word;
					     
						
	            
						     local i = string.len(word);
							 realLanguage = lastlang;
							 ----print(lastlang)
						local h = self.Hash(string.lower(string.sub(word, 2)));
						if (i > #self.Language[realLanguage]) then 
							i = #self.Language[realLanguage];
						end;
						j = mod(h,#self.Language[realLanguage][i])+1;
						newword = self.Language[realLanguage][i][j];
						
						-- GET THE RIGHT CAPTIALS BACK
						for n=1,string.len(newword) do
							if string.match(string.sub(word,n,n),"%u") then
								newnewword = newnewword .. string.upper(string.sub(newword,n,n))
							else
								newnewword = newnewword .. string.sub(newword,n,n)
							end;
						end;
							    
							--print(newnewword)
							    
							

       

			 	end;
				
	                          
             --[[  if ( (string.sub(word, -1, -1)) == "$" or (string.sub(word, -1, -1)) == "=" ) then -- NEW by LuckyArts
		        print( string.sub(word, 1, -2) .. word); -- NEW by LuckyArts
	            end -- NEW by LuckyArts]]
					 return newnewword			
			end
		);
		                       

		return word
	end;
	---------------------------------------------------------------------------------------
	ParseLink = function(self, msg, language)
		-- c[0-9a-f] replaced with [cC][0-9a-fA-F] to make this work with GrypthonHeart Items
		--msg = string.gsub(msg,"|","1")
		---- DO STUFF BEFORE LINKS (WHEN THEY ARE NOT LINKS)
		if string.find(msg,"(.-)(|[cC][0-9a-fA-F]+|H[%a%A]-|h|r)") ~= nil then
			msg = string.gsub(msg,"(.-)(|[cC][0-9a-fA-F]+|H[%a%A]-|h|r)", 
				function(a,link)
					a = self:ProcessMessage(a)
					return a .. link
				end
			);
		end;
		---- DO THE LAST PART OF THE MESSAGE IF NOT A LINK
		if string.find(msg,"(.*)(|[cC][0-9a-fA-F]+|H[%a%A]-|h|r)(.-)$") ~= nil then
			msg = string.gsub(msg,"(.*)(|[cC][0-9a-fA-F]+|H[%a%A]-|h|r)(.-)$", 
				function(a,link,c) 
					c = self:ProcessMessage(c)
					return a .. link .. c
				end
			);
		else
		---- IF NO LINK THEN DO ANYWAY
			msg = self:ProcessMessage(msg)
		end;

		return msg
	end;
	---------------------------------------------------------------------------------------
	ParseLink2 = function(self, msg, language)
		-- c[0-9a-f] replaced with [cC][0-9a-fA-F] to make this work with GrypthonHeart Items
		--msg = string.gsub(msg,"|","X")
		---- DO STUFF BEFORE LINKS (WHEN THEY ARE NOT LINKS)
		if string.find(msg,"(.-)(|[cC][0-9a-fA-F]+|H[%a%A]-|h|r)") ~= nil then
			msg = string.gsub(msg,"(.-)(|[cC][0-9a-fA-F]+|H[%a%A]-|h|r)", 
				function(a,link)
					a = self:TranslateWord(a, language)
					return a .. link
				end
			);
		end;
		---- DO THE LAST PART OF THE MESSAGE IF NOT A LINK
		if string.find(msg,"(.*)(|[cC][0-9a-fA-F]+|H[%a%A]-|h|r)(.-)$") ~= nil then
			msg = string.gsub(msg,"(.*)(|[cC][0-9a-fA-F]+|H[%a%A]-|h|r)(.-)$", 
				function(a,link,c) 
					c = self:TranslateWord(c, language)
					return a .. link .. c
				end
			);
		else
		---- IF NO LINK THEN DO ANYWAY
			msg =  self:TranslateWord(msg, language)
		end;

		return msg
	end;
	---------------------------------------------------------------------------------------
	UnderstandPartial = function(self, fluency, lang)
		--randomseed(math.random(0,2147483647)+(GetTime() * 1000));
         
		msg = self.PreviousSentMsg	
         
		---- DO STUFF BEFORE LINKS (WHEN THEY ARE NOT LINKS)
		if string.find(msg,"(.-)(|[cC][0-9a-fA-F]+|H[%a%A]-|h|r)") ~= nil then
			msg = string.gsub(msg,"(.-)(|[cC][0-9a-fA-F]+|H[%a%A]-|h|r)", 
				function(a,link)

					if math.random(1,100) > fluency then 
						a = self:TranslateWord(a, lang)
					end
					return a .. link
				end
			);
		end;
		---- DO THE LAST PART OF THE MESSAGE IF NOT A LINK
		if string.find(msg,"(.*)(|[cC][0-9a-fA-F]+|H[%a%A]-|h|r)(.-)$") ~= nil then
			msg = string.gsub(msg,"(.*)(|[cC][0-9a-fA-F]+|H[%a%A]-|h|r)(.-)$", 
				function(a,link,c) 
					if math.random(1,100) > fluency then 
						c = self:TranslateWord(c, lang)
					end
					return a .. link .. c
				end
			);
		else
		---- IF NO LINK THEN DO ANYWAY
			if math.random(1,100) > fluency then
				if math.random(1,100) > fluency then 
					msg = self:TranslateWord(msg, lang)
					----print(msg);
				end
			end;
		end;
           newmsg = "[" .. lang .. "] " .. msg
		   ----print(newmsg);
		return newmsg;--"[" .. lang .. "] " .. msg
	end;
	---------------------------------------------------------------------------------------
	SetLanguage = function(self, language)
	
	---Dialect Linking Linked Dialect ,makes sure the dialects cycle off /on on approaite languages
	   --[[ local DiaL = "";
		local DiaD = "";
		 if Tongues.Settings.Character.LD ~= nil then
		for k,v in Tongues.PairsByKeys(Tongues.Settings.Character.LD) do
		----print(k);
	
		if k == language then
		 tDiaL = k;
		 tDiaD = v;

		 else
		 DiaD = "<None>";
		 end
		
		end				
		else
		 DiaD = "<None>";
end		]]
		
			
		UIDropDownMenu_ClearAll(self.UI.MainMenu.Speak.LanguageDropDown.Frame);
		 
		self.Settings.Character.Language = language;
		print("now speaking: "..language)
		self.UI.MiniMenu.Frame:SetText("Tongues\10" .. Tongues.Settings.Character.Language);
        tBroker.value =  Tongues_Character.Language;	--LDB Display cycle--Merge to Tongues 2		
		
		UIDropDownMenu_Initialize(Tongues.UI.MainMenu.Speak.LanguageDropDown.Frame, Tongues.UpdateLanguageDropDown);
		UIDropDownMenu_SetSelectedValue(self.UI.MainMenu.Speak.LanguageDropDown.Frame, language);
		
		---Linked Dialect
		--UIDropDownMenu_Initialize(Tongues.UI.MainMenu.Speak.DialectDropDown.Frame, Tongues.UpdateDialect)
		--UIDropDownMenu_SetSelectedValue(Tongues.UI.MainMenu.Speak.DialectDropDown.Frame, DiaD)
		
	
		
	end;
	---------------------------------------------------------------------------------------
	CycleLanguage = function(self)
		local t = {};
		local i = 1;
		local matchnumber = 1;
		local k,v;
		for k,v in self.PairsByKeys(self.Settings.Character.Fluency) do
			if v > 0 and self.Language[k] ~= nil then
				table.insert(t,#t + 1,k)
				if self.Settings.Character.Language == k then
					matchnumber = #t
					
				end;
			end;
		end;
		local d = ""
		if UnitFactionGroup("player") == "Alliance" then
			d = T_Common
		elseif UnitFactionGroup("player") == "Horde" then
			d = T_Orcish
		end;

		self:SetLanguage((t[((matchnumber) % #t) + 1]) or d) 
	end;
	---------------------------------------------------------------------------------------
	IsMyFactionLanguage = function(self, language)
		if UnitFactionGroup("player") == BFAC["Alliance"] then
			if language == T_Common or
			language == T_Gnomish or
			language == T_Dwarvish or
			language == T_Darnassian or
			language == T_Draenei  or
			--language == T_Gilnean then
			langauge == "Pandaren" then
				return true
			end;
		elseif UnitFactionGroup("player") == BFAC["Horde"] then
			if language == T_Orcish or
			language == T_Troll or
			language == T_Forsaken or
			language == T_Taurahe or
			language == T_Thalassian or
			langauge == BRAC["Goblin"] or
			langauge == "Pandaren" then
				return true
			end;
		end;
		return false
	end;


	---------------------------------------------------------------------------------------

});
Tongues:Initialize();

--================================================================================================================
-----------------------------------------------------------HOOKS--------------------------------------------------
function SendChatMessage(  msg, chatType, language, channel)
	
     local langID,lang = GetSpeaking()
	 --print(lang)
	
	   
	Tongues:HandleSend(msg, chatType, langID, lang, channel)
end




ChatFrame_MessageEventHandler = function(self, event, ...)

cID = self:GetID()


	if (	event == "CHAT_MSG_SAY" or 
		event == "CHAT_MSG_EMOTE" or
		event == "CHAT_MSG_YELL" or
		event == "CHAT_MSG_PARTY" or
		event == "CHAT_MSG_GUILD" or
		event == "CHAT_MSG_WHISPER" or
		event == "CHAT_MSG_WHISPER_INFORM" or
		event == "CHAT_MSG_OFFICER" or
		event == "CHAT_MSG_RAID" or
		event == "CHAT_MSG_RAID_WARNING" or
		event == "CHAT_MSG_RAID_LEADER" or
		event == "CHAT_MSG_BATTLEGROUND" or
		event == "CHAT_MSG_BATTLEGROUND_LEADER" 
		)  then 
			Tongues:HandleReceive(self,event,...);
			----print("stuff.."...)
			
	else
		Tongues.Hooks.Receive(self,event,...);
	end;
end;
--================================================================================================================

