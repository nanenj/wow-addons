if GetLocale() ~= "koKR" then return end

local addonName = "Altoholic"
local addon = _G[addonName]

local BF = LibStub("LibBabble-Faction-3.0"):GetLookupTable()

local WHITE		= "|cFFFFFFFF"
local GREEN		= "|cFF00FF00"
local YELLOW	= "|cFFFFFF00"

addon.FactionLeveling = {

	-- Reputation levels
	-- -42000 = "Hated", "매우 적대적"
	-- -6000 = "Hostile", "적대적"
	-- -3000 = "Unfriendly", "약간 적대적"
	-- 0 = "Neutral", "중립적"
	-- 3000 = "Friendly", "약간 우호적"
	-- 9000 = "Honored", "우호적"
	-- 21000 = "Revered", "매우 우호적"
	-- 42000 = "Exalted", "확고한 동맹"
	
	-- Outland factions: source: http://www.mmo-champion.com/
	[BF["The Aldor"]] = {
		[0] = WHITE .. "[Dreadfang Venom Sac]|r +250 rep\n\n"
				.. YELLOW .. "Dreadfang Lurker,\nDreadfang Widow\n"
				.. WHITE .. "(Terrokar Forest)",
		[9000] = WHITE .. "[Mark of Kil'jaeden]|r\n+25 rep",
		[42000] = WHITE .. "[Mark of Sargeras]|r +25 rep per mark\n" 
				.. GREEN .. "[Fel Armament]|r +350 rep (+1 Holy Dust)"
	},
	[BF["The Scryers"]] = {
		[0] = WHITE .. "[Dampscale Basilisk Eye]|r +250 rep\n\n"
				.. YELLOW .. "Ironspine Petrifier,\nDampscale Devourer,\nDampscale Basilisk\n"
				.. WHITE .. "(Terrokar Forest)",
		[9000] = WHITE .. "[Firewing Signet]|r\n+25 rep",
		[42000] = WHITE .. "[Sunfury Signet]|r +25 rep per mark\n" 
				.. GREEN .. "[Arcane Tome]|r +350 rep (+1 Arcane Rune)"
	},
	[BF["Netherwing"]] = {
		[3000] = "repeat these quests:\n\n" 
				.. YELLOW .. "A Slow Death (Daily)|r 250 rep\n"
				.. YELLOW.. "Netherdust Pollen (Daily)|r 250 rep\n"
				.. YELLOW.. "Netherwing crystal (Daily)|r 250 rep\n"
				.. YELLOW.. "Not so friendly skies (Daily)\n"
				.. YELLOW.. "Great Netherwing egg hunt (Repeatable)|r 250 rep",
		[9000] = "repeat these quests:\n\n" 
				.. YELLOW .. "Overseeing and you: making the right choices|r 350 rep\n"
				.. YELLOW .. "The Booterang: A Cure ... (Daily)|r 350 rep\n"
				.. YELLOW .. "Picking up the pieces (Daily)|r 350 rep\n"
				.. YELLOW .. "Dragons are the least of our problems (Daily)|r 350 rep\n"
				.. YELLOW .. "Crazed & confused|r 350 rep\n",
		[21000] = "repeat these quests:\n\n" 
				.. YELLOW .. "Subduing the Subduer|r 500 rep\n" 
				.. YELLOW .. "Disrupting the Twiligth Generator (Daily)|r 500 rep\n"
				.. YELLOW .. "Race quests 500 each for first 5, 1000 for 6th\n",
		[42000] = "repeat this quest:\n\n" 
				.. YELLOW .. "The greatest trap ever (Daily) (3 man group)|r 500 rep"
	},
	[BF["Honor Hold"]] = {
		[9000] = "\n" 
				.. YELLOW .. "Quest in Hellfire Peninsula\n"
				.. GREEN .. "Hellfire Remparts |r(Normal)\n"
				.. GREEN .. "Blood Furnace |r(Normal)",
		[42000] = "\n" 
				.. GREEN .. "Shattered Halls |r(Normal & Heroic)\n"
				.. GREEN .. "Hellfire Remparts |r(Heroic)\n"
				.. GREEN .. "Blood Furnace |r(Heroic)"
	},
	[BF["Thrallmar"]] = {
		[9000] = "\n" 
				.. YELLOW .. "Quest in Hellfire Peninsula\n"
				.. GREEN .. "Hellfire Remparts |r(Normal)\n"
				.. GREEN .. "Blood Furnace |r(Normal)",
		[42000] = "\n" 
				.. GREEN .. "Shattered Halls |r(Normal & Heroic)\n"
				.. GREEN .. "Hellfire Remparts |r(Heroic)\n"
				.. GREEN .. "Blood Furnace |r(Heroic)"
	},
	[BF["Cenarion Expedition"]] = {
		[3000] = "\n" 
				.. WHITE .. "Darkcrest & Bloodscale Nagas (+5 rep)\n"
				.. YELLOW .. "Quest in Zangarmarsh\n"
				.. "|rRun any " .. GREEN .. "Coilfang|r instance\n\n"
				.. WHITE .. "Keep [Unidentified Plant Parts] for later",
		[9000] = "\n" 
				.. WHITE .. "Turn in [Unidentified Plant Parts] x240\n"
				.. YELLOW .. "Quest in Zangarmarsh\n"
				.. "|rRun any " .. GREEN .. "Coilfang|r instance",
		[42000] = "\n" 
				.. WHITE .. "Turn in [Coilfang Armaments] +75 rep\n\n"
				.. GREEN .. "Steamvault |r(Normal)\n"
				.. GREEN .. "Any Coilfang instance |r(Heroic)"
	},
	[BF["Keepers of Time"]] = {
		[42000] = "\n" 
				.. "|rRun the " .. GREEN .. "Old Hillsbrad Foothills|r & " .. GREEN .. "The Black Morass\n\n"
				.. YELLOW .. "Keep quests for later:\nOld Hillsbrad quesline = 5000 rep\nBlack Morass questline = 8000 rep"
	},
	[BF["The Sha'tar"]] = {
		[42000] = "\n" 
				.. GREEN .. "The Botanica |r(Normal & Heroic)\n"
				.. GREEN .. "The Mechanar |r(Normal & Heroic)\n"
				.. GREEN .. "The Arcatraz |r(Normal & Heroic)\n"
	},	
	[BF["Lower City"]] = {
		[9000] = "\n" 
				.. WHITE .. "Turn in [Arrakoa Feather] x30 (+250 rep)\n"
				.. GREEN .. "Shadow Labyrinth |r(Normal)\n"
				.. GREEN .. "Auchenai Crypts |r(Normal)\n"
				.. GREEN .. "Sethekk Halls |r(Normal)",
		[42000] = "\n" 
				.. GREEN .. "Shadow Labyrinth |r(Normal & Heroic)\n"
				.. GREEN .. "Auchenai Crypts |r(Heroic)\n"
				.. GREEN .. "Sethekk Halls |r(Heroic)"
	},	
	[BF["The Consortium"]] = {
		[3000] = "\n" 
				.. "|rTurn in [Oshu'gun Crystal Fragment] +250 rep\n"
				.. "Turn in [Pair of Ivory Tusks] +250 rep\n\n"
				.. GREEN .. "Mana-Tombs |r(Normal)",
		[9000] = "\n" 
				.. "|rTurn in [Obsidian Warbeads] +250 rep\n\n"
				.. GREEN .. "Mana-Tombs |r(Normal)",
		[42000] = "\n" 
				.. "|rTurn in [Zaxxis Insignia] +250 rep\n"
				.. "|rTurn in [Obsidian Warbeads] +250 rep\n\n"
				.. GREEN .. "Mana-Tombs |r(Heroic)"
	}
}
