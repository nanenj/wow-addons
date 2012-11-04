local addonName = ...
local addon = _G[addonName]

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local addonList = {
	"Altoholic",
	"Altoholic_Summary",
	"Altoholic_Characters",
	"Altoholic_Search",
	"Altoholic_Guild",
	"Altoholic_Achievements",
	"Altoholic_Agenda",
	"Altoholic_Grids",
}

local WHITE		= "|cFFFFFFFF"
local GREEN		= "|cFF00FF00"
local TEAL		= "|cFF00FF9A"
local ORANGE   = "|cFFFF8400"

local url1 = "http://wow.curse.com/downloads/wow-addons/details/altoholic.aspx"
local url2 = "http://www.wowinterface.com/downloads/info8533-Altoholic.html"
local url3 = "http://wow.curseforge.com/addons/altoholic/localization/"

local help = {
	{	name = "General",
		questions = {
			"How do I remove a character that has been renamed/transfered/deleted?",
			"Does Altoholic support command line options?",
			"My minimap icon is gone, how do I get it back?",
			"What are the official homepages?",
			"What is this 'DataStore' thing? Why so many directories?",
			"I am developper, I want to know more about DataStore",
			"Does the add-on support FuBar?",
			"What is the add-on's memory footprint?",
			"Where have my suggestions gone?",
		},
		answers = {
			"Go into the 'Account Summary', mouse over the character, right-click it to get the contextual menu, and select 'Delete this Alt'.",
			"Type /alto or /altoholic to get the list of command line options.",
			"Go into Altoholic's main option panel, and check 'Show Minimap Icon'.\nYou can also type /alto show.",
			format("%s%s\n%s\n%s", "The add-on is only released on these two sites, it is recommended NOT TO get it through other means:", GREEN, url1, url2 ),
			"DataStore and its modules take care of storing data for client add-ons; Altoholic itself now only stores very little information. The main purpose of the numerous directories is to offer split databases, instead of one massive database containing all the information required by the add-on.",
			"Refer to DataStore's own help topic for more information.",
			"Not anymore. Instead, it supports LibDataBroker (aka LDB), if you really want FuBar, use Broker2FuBar.",
			"For 10 characters and 1 guild bank, the add-on takes around 4-5mb on my machine. Note that due to its name, the add-on is one of the first in the alphabet, and often gets credited of the memory/cpu usage of its libraries.",
			"Development is an iterative process, and I review parts of the add-on constantly. Depending on my spare time, some suggestions might take longer than others to make it into the add-on. Be patient, the add-on is still far from being complete.",
		}
	},
	{	name = "Containers",
		questions = {
			"Do I have to open all my bags to let the add-on know about their content?",
			"What about my bank? .. and my guild bank?",
			"Will the content of my bags be visible in the tooltip? Can I configure that?",
		},
		answers = {
			"No. This happens silently and does not require any action from your part.",
			"You have to open your bank in order to let the add-on read its content. Same goes for the guild bank, except that the add-on can only read it tab per tab, so make sure to open them all.",
			"Yes. There are several tooltip options that can be set to specify what you want to see or not."
		}
	},
	{	name = "Professions",
		questions = {
			"Do I have to open all professions manually?",
		},
		answers = {
			"Yes. Some advanced features require that you open the tradeskill pane once per profession.",
		}
	},
	{	name = "Mails",
		questions = {
			"Can Altoholic read my mails without being at the mailbox?",
			"Altoholic marks all my mails as read, how can I avoid that?",
			"My mailbox is full, can Altoholic read beyond the list of visible mails?",
		},
		answers = {
			"No. This is a restriction imposed by Blizzard. Your character must physically be at a mailbox to retrieve your mails.",
			"Go into the 'Options -> DataStore -> DataStore_Mails' and disable 'Scan mail body'.",
			"No. You will have to clear your mailbox to release mails that are queued server-side.",
		}
	},
	{	name = "Localization",
		questions = {
			"I found a bad translation, how can I help fixing it?",
		},
		answers = {
			format("Use the CurseForge localization tool, at %s|r.", GREEN..url3),
		}
	},
}	

local support = {
	{	name = "Reporting Bugs",
		questions = {
			"I found an error, how/where do I report it?",
			"What should I do before reporting?",
			"I just upgraded to the latest version, and there are so many Lua errors, what the..??",
			"I have multiple Lua errors at login, should I report them all?",
		},
		answers = {
			"Both Curse and WoWInterface have a ticket section, I also read comments and respond as often as I materially can, so feel free to report in one of these places.",
			format("%s\n\n%s\n%s\n%s\n%s\n%s\n", 
				"A few things:",
				"1) Make sure you have the latest version of the add-on.",
				"2) If you suspect a conflict with another add-on, try to reproduce the issue with only Altoholic enabled. As the add-on deals with a lot of things, a conflict is always possible.",
				"3) Make sure your issue has not been reported by someone else.",
				"4) Never, ever, report that 'it does not work', this is the most useless sentence in the world! Be specific about what does not work.",
				"5) DO NOT copy the entire add-on list from Swatter. While conflicts are possible, they are the exception rather than the rule."
			),
			"I'm just human, I make mistakes. But because I'm human, I fix them too, so be patient. This is a project that I develop in my spare time, and it fluctuates a lot.",
			"No. Only the first error you will get is relevant, it means that something failed during the initialization process of the add-on, or of a library, and this is likely to cause several subsequent errors that are more often than not irrelevant.",
		}
	},
	{	name = "Live support",
		questions = {
			"Is there an IRC channel where I could get live support?",
		},
		answers = {
			format("Yes. Join the %s#altoholic|r IRC channel on Freenode : %sirc://irc.freenode.net:6667/|r", WHITE, GREEN),
		}
	},
}

-- this content will be subject to frequent changes, do not bother translating it !!
local whatsnew = {
	{	name = "5.0.002 Changes",
		bulletedList = {
			"Integrated the Void Storage to the container's UI (Characters -> Containers).",
			"Added Mists of Pandaria factions (Grids -> Reputations).",
			"Added Mists of Pandaria archaeology artefacts (Grids -> Archaeology).",
			"Added Mists of Pandaria crafts for each professions (Grids -> Tradeskills).",
			"Fixed a few Lua errors related to Battle Pets. They are temporarily NOT scanned at the Auction House.",
		},
	},
	{	name = "5.0.001d Changes",
		bulletedList = {
			"Fixed tooltips sometime being incorrect in Grids -> reputations & currencies.",
			"Fixed potential tainting issues due to the usage of the underscore in the code.",
			"Cleared a few source files that were no longer used.",
			"Fixed scanning of partially completed achievements.",
			"Fixed Lua errors that appeared in 5.0.5 due to a wrong spell ID for fishing.",
		},
	},
	{	name = "5.0.001c Changes",
		bulletedList = {
			"Fixed tooltip showing 'No data' for herbalism in the Skills pane.. for good this time !",
			"Fixed a Lua error when scanning glyphs.. for good this time too ! (Thanks Sylvannis)",
			"Fixed a Lua error when clicking on glyphs, blaming DataStore_Crafts and/or DataStore_Achievements.",
		},
	},
	{	name = "5.0.001b Changes",
		bulletedList = {
			"Fixed a Lua error when trying to scan glyphs on a low level character.",
			"Fixed a Lua error when scanning Inscription.",
			"Fixed invalid profession spell id's for Fishing & Herbalism.",
			"Fixed version number in .TOC",
			"Fixed a Lua error when mousing over a specific cell in the guild members pane.",
		},
	},
	{	name = "5.0.001 Changes",
		bulletedList = {
			"Added support for itIT. If you can help with the translations, please go here: http://wow.curseforge.com/addons/altoholic/localization/",
			"Updated Achievement lists, please advise if you notice errors (especially for horde players).",
			"Fixed many issues related to changes in MoP. Too much to list.",
			"Talent pane is temporarily disabled. It will be back soon.",
			"Changed all drop down definitions to prevent tainting (Thanks ckaotik !)",
			"Fixed a Lua error in Grids->Reputations when selecting guild reputation.",
			"Added missing Tol Barad achievement : Occu'thar (Thanks Daveo77)",
			"Fixed a few UI issues related to account sharing.",
			"Fixed searching item upgrades based on iLevel",
			"Moved the sumary tab into its own module, this is in preparation of future new features.",
			"Fixed pets not sorted alphabetically in Grids->Pets.",
			"Added back the All-in-one view in Grids->Pets.",
		},
	},
	{	name = "Earlier changes",
		textLines = {
			"Refer to |cFF00FF00changelog.txt",
		},
	},
}

function addon:GetOption(name)
	if addon.db and addon.db.global and addon.db.global.options then
		return addon.db.global.options[name]
	end
end

function addon:SetOption(name, value)
	if addon.db and addon.db.global and addon.db.global.options then 
		addon.db.global.options[name] = value
	end
end

function addon:ToggleOption(frame, option)
	if frame then
		addon:SetOption(option, (frame:GetChecked()) and 1 or 0)
	else
		if addon:GetOption(option) == 1 then
			addon:SetOption(option, 0)
		else
			addon:SetOption(option, 1)
		end
	end
end

function addon:SetupOptions()
	-- create categories in Blizzard's options panel
	
	DataStore:AddOptionCategory(AltoholicGeneralOptions, addonName)
	LibStub("LibAboutPanel").new(addonName, addonName);
	DataStore:AddOptionCategory(AltoholicHelp, HELP_LABEL, addonName)
	DataStore:AddOptionCategory(AltoholicSupport, "Getting support", addonName)
	DataStore:AddOptionCategory(AltoholicWhatsNew, "What's new?", addonName)
	DataStore:AddOptionCategory(AltoholicMemoryOptions, L["Memory used"], addonName)
	DataStore:AddOptionCategory(AltoholicSearchOptions, SEARCH, addonName)
	DataStore:AddOptionCategory(AltoholicMailOptions, MAIL_LABEL, addonName)
	DataStore:AddOptionCategory(AltoholicMiscOptions, MISCELLANEOUS, addonName)
	DataStore:AddOptionCategory(AltoholicAccountSharingOptions, L["Account Sharing"], addonName)
	DataStore:AddOptionCategory(AltoholicSharedContent, "Shared Content", addonName)
	DataStore:AddOptionCategory(AltoholicTooltipOptions, L["Tooltip"], addonName)
	DataStore:AddOptionCategory(AltoholicCalendarOptions, L["Calendar"], addonName)

	DataStore:SetupInfoPanel(help, AltoholicHelp_Text)
	DataStore:SetupInfoPanel(support, AltoholicSupport_Text)
	DataStore:SetupInfoPanel(whatsnew, AltoholicWhatsNew_Text)
	
	help = nil
	support = nil
	whatsnew = nil
	
	local value
	
	-- ** General **
	AltoholicGeneralOptions_Title:SetText(TEAL..format("%s %s", addonName, addon.Version))
	AltoholicGeneralOptions_RestXPModeText:SetText(L["Max rest XP displayed as 150%"])
	AltoholicGeneralOptions_GuildBankAutoUpdateText:SetText(L["Automatically authorize guild bank updates"])
	AltoholicGeneralOptions_GuildBankAutoUpdate.tooltip = format("%s%s%s",
		L["|cFFFFFFFFWhen |cFF00FF00enabled|cFFFFFFFF, this option will allow other Altoholic users\nto update their guild bank information with yours automatically.\n\n"],
		L["When |cFFFF0000disabled|cFFFFFFFF, your confirmation will be\nrequired before sending any information.\n\n"],
		L["Security hint: disable this if you have officer rights\non guild bank tabs that may not be viewed by everyone,\nand authorize requests manually"])
	
	AltoholicGeneralOptions_ClampWindowToScreenText:SetText(L["Clamp window to screen"])
	
	L["|cFFFFFFFFWhen |cFF00FF00enabled|cFFFFFFFF, this option will allow other Altoholic users\nto update their guild bank information with yours automatically.\n\n"] = nil
	L["When |cFFFF0000disabled|cFFFFFFFF, your confirmation will be\nrequired before sending any information.\n\n"] = nil
	L["Security hint: disable this if you have officer rights\non guild bank tabs that may not be viewed by everyone,\nand authorize requests manually"] = nil
	L["Max rest XP displayed as 150%"] = nil
	L["Automatically authorize guild bank updates"] = nil
	
	value = AltoholicGeneralOptions_SliderAngle:GetValue()
	AltoholicGeneralOptions_SliderAngle.tooltipText = L["Move to change the angle of the minimap icon"]
	AltoholicGeneralOptions_SliderAngleLow:SetText("1");
	AltoholicGeneralOptions_SliderAngleHigh:SetText("360"); 
	AltoholicGeneralOptions_SliderAngleText:SetText(format("%s (%s)", L["Minimap Icon Angle"], value))
	L["Move to change the angle of the minimap icon"] = nil
	
	value = AltoholicGeneralOptions_SliderRadius:GetValue()
	AltoholicGeneralOptions_SliderRadius.tooltipText = L["Move to change the radius of the minimap icon"]; 
	AltoholicGeneralOptions_SliderRadiusLow:SetText("1");
	AltoholicGeneralOptions_SliderRadiusHigh:SetText("200"); 
	AltoholicGeneralOptions_SliderRadiusText:SetText(format("%s (%s)", L["Minimap Icon Radius"], value))
	L["Move to change the radius of the minimap icon"] = nil
	
	AltoholicGeneralOptions_ShowMinimapText:SetText(L["Show Minimap Icon"])
	L["Show Minimap Icon"] = nil
	
	value = AltoholicGeneralOptions_SliderAlpha:GetValue()
	AltoholicGeneralOptions_SliderAlphaLow:SetText("0.1");
	AltoholicGeneralOptions_SliderAlphaHigh:SetText("1.0"); 
	AltoholicGeneralOptions_SliderAlphaText:SetText(format("%s (%1.2f)", L["Transparency"], value));
	
	-- ** Memory **
	AltoholicMemoryOptions_AddonsText:SetText(ORANGE..ADDONS)
	local list = ""
	for index, module in ipairs(addonList) do
		list = format("%s%s:\n", list, module)
	end

	list = format("%s\n%s", list, format("%s:", L["Memory used"]))
	
	AltoholicMemoryOptions_AddonsList:SetText(list)
	
	-- ** Search **
	AltoholicSearchOptions_SearchAutoQueryText:SetText(L["AutoQuery server |cFFFF0000(disconnection risk)"])
	AltoholicSearchOptions_SearchAutoQuery.tooltip = format("%s%s%s%s",
		L["|cFFFFFFFFIf an item not in the local item cache\nis encountered while searching loot tables,\nAltoholic will attempt to query the server for 5 new items.\n\n"],
		L["This will gradually improve the consistency of the searches,\nas more items are available in the item cache.\n\n"],
		L["There is a risk of disconnection if the queried item\nis a loot from a high level dungeon.\n\n"],
		L["|cFF00FF00Disable|r to avoid this risk"])	
	
	AltoholicSearchOptions_SortDescendingText:SetText(L["Sort loots in descending order"])
	AltoholicSearchOptions_IncludeNoMinLevelText:SetText(L["Include items without level requirement"])
	AltoholicSearchOptions_IncludeMailboxText:SetText(L["Include mailboxes"])
	AltoholicSearchOptions_IncludeGuildBankText:SetText(L["Include guild bank(s)"])
	AltoholicSearchOptions_IncludeRecipesText:SetText(L["Include known recipes"])
	AltoholicSearchOptions_IncludeGuildSkillsText:SetText(L["Include guild members' professions"])
	L["AutoQuery server |cFFFF0000(disconnection risk)"] = nil
	L["Sort loots in descending order"] = nil
	L["Include items without level requirement"] = nil
	L["Include mailboxes"] = nil
	L["Include guild bank(s)"] = nil
	L["Include known recipes"] = nil
	L["Include guild members' professions"] = nil
	
	-- ** Mail **
	value = AltoholicMailOptions_SliderTimeToNextWarning:GetValue()
	AltoholicMailOptions_SliderTimeToNextWarning.tooltipText = L["TIME_TO_NEXT_WARNING_TOOLTIP"]
	AltoholicMailOptions_SliderTimeToNextWarningLow:SetText("1");
	AltoholicMailOptions_SliderTimeToNextWarningHigh:SetText("12"); 
	AltoholicMailOptions_SliderTimeToNextWarningText:SetText(format("%s (%s)", L["TIME_TO_NEXT_WARNING_TEXT"], format(D_HOURS, value)))
	AltoholicMailOptions_GuildMailWarningText:SetText(L["New mail notification"])
	L["New mail notification"] = nil
		
	AltoholicMailOptions_GuildMailWarning.tooltip = format("%s",
		L["Be informed when a guildmate sends a mail to one of my alts.\n\nMail content is directly visible without having to reconnect the character"])

	AltoholicMailOptions_NameAutoCompleteText:SetText("Auto-complete recipient name" )
		
	AltoholicMiscOptions_AHColorCodingText:SetText(L["Use color-coding for recipes at the AH"])
	AltoholicMiscOptions_VendorColorCodingText:SetText(L["Use color-coding for recipes at vendors"])
		
		
	-- ** Account Sharing **
	AltoholicAccountSharingOptions_AccSharingCommText:SetText(L["Account Sharing Enabled"])
	AltoholicAccountSharingOptions_AccSharingComm.tooltip = format("%s%s%s%s",
		L["|cFFFFFFFFWhen |cFF00FF00enabled|cFFFFFFFF, this option will allow other Altoholic users\nto send you account sharing requests.\n"],
		L["Your confirmation will still be required any time someone requests your information.\n\n"],
		L["When |cFFFF0000disabled|cFFFFFFFF, all requests will be automatically rejected.\n\n"],
		L["Security hint: Only enable this when you actually need to transfer data,\ndisable otherwise"])

	L["Account Sharing Enabled"] = nil
	L["|cFFFFFFFFWhen |cFF00FF00enabled|cFFFFFFFF, this option will allow other Altoholic users\nto send you account sharing requests.\n"] = nil
	L["Your confirmation will still be required any time someone requests your information.\n\n"] = nil
	L["When |cFFFF0000disabled|cFFFFFFFF, all requests will be automatically rejected.\n\n"] = nil
	L["Security hint: Only enable this when you actually need to transfer data,\ndisable otherwise"] = nil

	AltoholicAccountSharingOptionsText1:SetText(WHITE.."Authorizations")
	AltoholicAccountSharingOptionsText2:SetText(WHITE..L["Character"])
	AltoholicAccountSharingOptions_InfoButton.tooltip = format("%s\n%s\n\n%s", 
	
	WHITE.."This list allows you to automate responses to account sharing requests.",
	"You can choose to automatically accept or reject requests, or be asked when a request comes in.",
	"If account sharing is totally disabled, this list will be ignored, and all requests will be rejected." )
	
	AltoholicAccountSharingOptionsIconNever:SetText("\124TInterface\\RaidFrame\\ReadyCheck-NotReady:14\124t")
	AltoholicAccountSharingOptionsIconAsk:SetText("\124TInterface\\RaidFrame\\ReadyCheck-Waiting:14\124t")
	AltoholicAccountSharingOptionsIconAuto:SetText("\124TInterface\\RaidFrame\\ReadyCheck-Ready:14\124t")
	
	-- ** Shared Content **
	AltoholicSharedContentText1:SetText(WHITE.."Shared Content")
	AltoholicSharedContent_SharedContentInfoButton.tooltip = format("%s\n%s", 
		WHITE.."Select the content that will be visible to players who send you",
		"account sharing requests.")
	
	
	-- ** Tooltip **
	AltoholicTooltipOptionsSourceText:SetText(L["Show item source"])
	AltoholicTooltipOptionsCountText:SetText(L["Show item count per character"])
	AltoholicTooltipOptionsTotalText:SetText(L["Show total item count"])
	AltoholicTooltipOptionsRecipeInfoText:SetText(L["Show recipes already known/learnable by"])
	AltoholicTooltipOptionsPetInfoText:SetText(L["Show pets already known/learnable by"])
	AltoholicTooltipOptionsItemIDText:SetText(L["Show item ID and item level"])
	AltoholicTooltipOptionsGatheringNodeText:SetText(L["Show counters on gathering nodes"])
	AltoholicTooltipOptionsCrossFactionText:SetText(L["Show counters for both factions"])
	AltoholicTooltipOptionsMultiAccountText:SetText(L["Show counters for all accounts"])
	AltoholicTooltipOptionsGuildBankText:SetText(L["Show guild bank count"])
	AltoholicTooltipOptionsGuildBankCountText:SetText(L["Include guild bank count in the total count"])
	AltoholicTooltipOptionsGuildBankCountPerTabText:SetText(L["Detailed guild bank count"])
	L["Show item source"] = nil
	L["Show item count per character"] = nil
	L["Show total item count"] = nil
	L["Show guild bank count"] = nil
	L["Show already known/learnable by"] = nil
	L["Show recipes already known/learnable by"] = nil
	L["Show pets already known/learnable by"] = nil
	L["Show item ID and item level"] = nil
	L["Show counters on gathering nodes"] = nil
	L["Show counters for both factions"] = nil
	L["Show counters for all accounts"] = nil
	L["Include guild bank count in the total count"] = nil
	
	-- ** Calendar **
	AltoholicCalendarOptionsFirstDayText:SetText(L["Week starts on Monday"])
	AltoholicCalendarOptionsDialogBoxText:SetText(L["Display warnings in a dialog box"])
	AltoholicCalendarOptionsDisableWarningsText:SetText(L["Disable warnings"])
	L["Week starts on Monday"] = nil
	L["Warn %d minutes before an event starts"] = nil
	L["Display warnings in a dialog box"] = nil
	
	for i = 1, 4 do 
		addon:DDM_Initialize(_G["AltoholicCalendarOptions_WarningType"..i], Altoholic.Events.WarningType_Initialize)
	end
	UIDropDownMenu_SetText(AltoholicCalendarOptions_WarningType1, "Profession Cooldowns")
	UIDropDownMenu_SetText(AltoholicCalendarOptions_WarningType2, "Dungeon Resets")
	UIDropDownMenu_SetText(AltoholicCalendarOptions_WarningType3, "Calendar Events")
	UIDropDownMenu_SetText(AltoholicCalendarOptions_WarningType4, "Item Timers")
end

function addon:RestoreOptionsToUI()
	local O = Altoholic.db.global.options
	
	AltoholicGeneralOptions_RestXPMode:SetChecked(O.RestXPMode)
	AltoholicGeneralOptions_GuildBankAutoUpdate:SetChecked(O.GuildBankAutoUpdate)
	AltoholicGeneralOptions_ClampWindowToScreen:SetChecked(O.ClampWindowToScreen)

	AltoholicGeneralOptions_SliderAngle:SetValue(O.MinimapIconAngle)
	AltoholicGeneralOptions_SliderRadius:SetValue(O.MinimapIconRadius)
	AltoholicGeneralOptions_ShowMinimap:SetChecked(O.ShowMinimap)
	AltoholicGeneralOptions_SliderScale:SetValue(O.UIScale)
	AltoholicFrame:SetScale(O.UIScale)
	AltoholicGeneralOptions_SliderAlpha:SetValue(O.UITransparency)

	-- set communication handlers according to user settings.
	if O.AccSharingHandlerEnabled == 1 then
		Altoholic.Comm.Sharing:SetMessageHandler("ActiveHandler")
	else
		Altoholic.Comm.Sharing:SetMessageHandler("EmptyHandler")
	end
	
	AltoholicSearchOptions_SearchAutoQuery:SetChecked(O.SearchAutoQuery)
	AltoholicSearchOptions_SortDescending:SetChecked(O.SortDescending)
	AltoholicSearchOptions_IncludeNoMinLevel:SetChecked(O.IncludeNoMinLevel)
	AltoholicSearchOptions_IncludeMailbox:SetChecked(O.IncludeMailbox)
	AltoholicSearchOptions_IncludeGuildBank:SetChecked(O.IncludeGuildBank)
	AltoholicSearchOptions_IncludeRecipes:SetChecked(O.IncludeRecipes)
	AltoholicSearchOptions_IncludeGuildSkills:SetChecked(O.IncludeGuildSkills)
	AltoholicSearchOptionsLootInfo:SetText(GREEN .. O.TotalLoots .. "|r " .. L["Loots"] .. " / "
										.. GREEN .. O.UnknownLoots .. "|r " .. L["Unknown"])

										
	AltoholicMailOptions_SliderTimeToNextWarning:SetValue(O["UI.Mail.TimeToNextWarning"])
	AltoholicMailOptions_GuildMailWarning:SetChecked(O.GuildMailWarning)
	AltoholicMailOptions_NameAutoComplete:SetChecked(O.NameAutoComplete)

	AltoholicMiscOptions_AHColorCoding:SetChecked(O["UI.AHColorCoding"])
	AltoholicMiscOptions_VendorColorCoding:SetChecked(O["UI.VendorColorCoding"])
	
	AltoholicAccountSharingOptions_AccSharingComm:SetChecked(O.AccSharingHandlerEnabled)
	
	AltoholicTooltipOptionsSource:SetChecked(O.TooltipSource)
	AltoholicTooltipOptionsCount:SetChecked(O.TooltipCount)
	AltoholicTooltipOptionsTotal:SetChecked(O.TooltipTotal)
	AltoholicTooltipOptionsGuildBank:SetChecked(O.TooltipGuildBank)
	AltoholicTooltipOptionsGuildBankCount:SetChecked(O.TooltipGuildBankCount)
	AltoholicTooltipOptionsGuildBankCountPerTab:SetChecked(O.TooltipGuildBankCountPerTab)
	AltoholicTooltipOptionsRecipeInfo:SetChecked(O.TooltipRecipeInfo)
	AltoholicTooltipOptionsPetInfo:SetChecked(O.TooltipPetInfo)
	AltoholicTooltipOptionsItemID:SetChecked(O.TooltipItemID)
	AltoholicTooltipOptionsGatheringNode:SetChecked(O.TooltipGatheringNode)
	AltoholicTooltipOptionsCrossFaction:SetChecked(O.TooltipCrossFaction)
	AltoholicTooltipOptionsMultiAccount:SetChecked(O.TooltipMultiAccount)
	
	AltoholicCalendarOptionsFirstDay:SetChecked(O.WeekStartsMonday)
	AltoholicCalendarOptionsDialogBox:SetChecked(O.WarningDialogBox)
	AltoholicCalendarOptionsDisableWarnings:SetChecked(O.DisableWarnings)
end

function addon:UpdateMinimapIconCoords()
	-- Thanks to Atlas for this code, modified to fit this addon's requirements though
	local xPos, yPos = GetCursorPosition() 
	local left, bottom = Minimap:GetLeft(), Minimap:GetBottom() 

	xPos = left - xPos/UIParent:GetScale() + 70 
	yPos = yPos/UIParent:GetScale() - bottom - 70 

	local iconAngle = math.deg(math.atan2(yPos, xPos))
	if(iconAngle < 0) then
		iconAngle = iconAngle + 360
	end
	
	addon:SetOption("MinimapIconAngle", iconAngle)
	AltoholicGeneralOptions_SliderAngle:SetValue(iconAngle)
end

function addon:MoveMinimapIcon()
	local radius = addon:GetOption("MinimapIconRadius")
	local angle = addon:GetOption("MinimapIconAngle")
	
	AltoholicMinimapButton:SetPoint( "TOPLEFT", "Minimap", "TOPLEFT", 54 - (radius * cos(angle)), (radius * sin(angle)) - 55 );
end

function addon:UpdateMyMemoryUsage()
	DataStore:UpdateMemoryUsage(addonList, AltoholicMemoryOptions, format("%s:", L["Memory used"]))
end

local function ResizeScrollFrame(frame, width, height)
	-- just a small wrapper, nothing generic in here.
	
	local name = frame:GetName()
	_G[name]:SetWidth(width-45)
	_G[name.."_ScrollFrame"]:SetWidth(width-45)
	_G[name]:SetHeight(height-30)
	_G[name.."_ScrollFrame"]:SetHeight(height-30)
	_G[name.."_Text"]:SetWidth(width-80)
end

local OnSizeUpdate = {	-- custom resize functions
	AltoholicHelp = ResizeScrollFrame,
	AltoholicSupport = ResizeScrollFrame,
	AltoholicWhatsNew = ResizeScrollFrame,
}

local OptionsPanelWidth, OptionsPanelHeight
local lastOptionsPanelWidth = 0
local lastOptionsPanelHeight = 0

function addon:OnUpdate(self, mandatoryResize)
	OptionsPanelWidth = InterfaceOptionsFramePanelContainer:GetWidth()
	OptionsPanelHeight = InterfaceOptionsFramePanelContainer:GetHeight()
	
	if not mandatoryResize then -- if resize is not mandatory, allow exit
		if OptionsPanelWidth == lastOptionsPanelWidth and OptionsPanelHeight == lastOptionsPanelHeight then return end		-- no size change ? exit
	end
		
	lastOptionsPanelWidth = OptionsPanelWidth
	lastOptionsPanelHeight = OptionsPanelHeight
	
	local frameName = self:GetName()
	if frameName and OnSizeUpdate[frameName] then
		OnSizeUpdate[frameName](self, OptionsPanelWidth, OptionsPanelHeight)
	end
end
