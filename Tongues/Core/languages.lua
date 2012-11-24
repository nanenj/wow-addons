-- Tongues.Language: Common - courtesy of Blizzard
Tongues.Language={};
Tongues.Custom.Language={};
local BCT = LibStub("LibBabble-CreatureType-3.0"):GetLookupTable()
local BFAC = LibStub("LibBabble-Faction-3.0"):GetLookupTable()
local BRAC = LibStub("LibBabble-Race-3.0"):GetLookupTable()
Tongues.Language[T_Common] = {
	[1] = { "a", "e", "i", "o", "u", "y" };
	[2] = { "lo", "ne", "ve", "ru", "an", "ti", "me", "lu", "re", "se", "va", "ko" };
	[3] = { "vil", "bor", "ras", "gol", "nud", "far", "wos", "mod", "ver", "ash", "lon", "bur", "hir" };
	[4] = { "nuff", "thor", "ruff", "odes", "noth", "ador", "dana", "vrum", "veld", "vohl", "lars", "goth", "agol", "uden" };
	[5] = { "wirsh", "novas", "regen", "gloin", "tiras", "barad", "garde", "majis", "ergin", "nagan", "algos", "eynes", "borne", "melka" };
	[6] = { "ruftos", "aesire", "rothas", "nevren", "rogesh", "skilde", "vandar", "valesh", "engoth", "aziris", "mandos", "goibon", "danieb", "daegil", "waldir", "ealdor" };
	[7] = { "novaedi", "lithtos", "ewiddan", "forthis", "faergas", "sturume", "vassild", "nostyec", "andovis", "koshhvel", "mandige", "kaelsig" };
	[8] = { "thonriss", "ruftvess", "aldonoth", "endirvis", "landowar", "hamerung", "cynegold", "methrine", "lordaere" };
	[9] = { "gloinador", "veldbarad", "gothalgos", "udenmajis", "danagarde", "vandarwos", "firalaine", "aetwinter", "eloderung", "regenthor" };
	[10] = { "vastrungen", "falhedring", "cynewalden", "dyrstigost", "aelgastron", "danavandar" };
	[11] = { "wershaesire", "thorlithtos", "forthasador", "vassildador", "agolandovis", "bornevalesh", "farlandowar" };
	[12] = { "nevrenrothas", "mandosdaegil", "waldirskilde", "adorstaerume", "golveldbarad" }
};
Tongues.Language[T_Common].Difficulty = {
	["default"] 	= 100;

	[BFAC["Alliance"]] 	= 0;
	[BFAC["Horde"]] 	= 900;

	[BRAC["Human"]]	= -900;
	[BRAC["Dwarf"]] 	= 0;
	[BRAC["Gnome"]] 	= 0;
	[BRAC["Night Elf"]] 	= 100;
	[BRAC["Draenei"]]	= 100;
	[BRAC["Worgen"]] = 0;

	[BRAC["Orc"]]	= 0;
	[BRAC["Troll"]]	= 0;
	[BRAC["Undead"]]	= 0;
	[BRAC["Tauren"]]	= 0;
	[BRAC["Blood Elf"]]	= -100;--blood elves were high elves and used to relate with humans..this makes it eaiser

	["Warrior"]	= 0;
	["Rogue"]	= 0;
	["Druid"]	= 0;
	["Mage"]	= 0;
	["Warlock"]	= 0;
	["Paladin"]	= 0;
	["Priest"]	= 0;
	["Shaman"]	= 0;
	["Hunter"]	= 0;
	["Death Knight"]= 0;
};

--Tongues.Language[BRAC["Human"]] = {
--	["alias"] = T_Common
--};

-- Tongues.Language: Orcish - courtesy of Blizzard
Tongues.Language[T_Orcish] = {
	[1] = { "a", "n", "g", "o", "l" };
	[2] = { "ha", "ko", "no", "mu", "ag", "ka", "gi", "il" };
	[3] = { "lok", "tar", "kaz", "ruk", "kek", "mog", "zug", "gul", "nuk", "aaz", "kil", "ogg" };
	[4] = { "rega", "nogu", "tago", "uruk", "kagg", "zaga", "grom", "ogar", "gesh", "thok", "dogg", "maka", "maza" };
	[5] = { "regas", "nogah", "kazum", "magan", "no'bu", "golar", "throm", "throm", "zugas", "re'ka", "no'ku", "ro'th" };
	[6] = { "thrakk", "revash", "nakazz", "moguna", "no'gor", "goth'a", "raznos", "ogerin", "gezzno", "thukad", "makogg", "aaz'no" };
	[7] = { "lok'tar", "gul'rok", "kazreth", "tov'osh", "zil'nok", "rath'is", "kil'azi" };
	[8] = { "throm'ka", "osh'kava", "gul'nath", "kog'zela", "ragath'a", "zuggossh", "moth'aga" };
	[9] = { "tov'nokaz", "osh'kazil", "no'throma", "gesh'nuka", "lok'mogul", "lok'balar", "ruk'ka'ha" };
	[10] = { "regasnogah", "kazum'nobu", "throm'bola", "gesh'zugas", "maza'rotha", "ogerin'naz" };
	[11] = { "thrakk'reva", "kaz'goth'no", "no'gor'goth", "kil'azi'aga", "zug-zug'ama", "maza'thrakk" };
	[12] = { "lokando'nash", "ul'gammathar", "dalggo'mazah", "golgonnashar", "golgonmathar" };
	[13] = { "khaz'rogg'ahn", "moth'kazoroth", "thok'rogg'gul" };
};
Tongues.Language[T_Orcish].Difficulty = {
	["default"] 	= 100;

	[BFAC["Alliance"]] 	= 900;
	[BFAC["Horde"]] 	= 0;

	[BRAC["Human"]]	= 0;
	[BRAC["Dwarf"]] 	= 0;
	[BRAC["Gnome"]] 	= 0;
	[BRAC["Night Elf"]] 	= 0;
	[BRAC["Draenei"]]	= 0;

	[BRAC["Orc"]]	= 0;
	[BRAC["Troll"]]	= 0;
	[BRAC["Undead"]]	= 0;
	[BRAC["Tauren"]]	= 0;
	[BRAC["Blood Elf"]]	= 0;

	["Warrior"]	= 0;
	["Rogue"]	= 0;
	["Druid"]	= 0;
	["Mage"]	= 0;
	["Warlock"]	= 0;
	["Paladin"]	= 0;
	["Priest"]	= 0;
	["Shaman"]	= 0;
	["Hunter"]	= 0;
	["Death Knight"]= 0;
};

-----------------------------------------------------------------------------------------------
-- Tongues.Language: Troll - courtesy of Blizzard
Tongues.Language[BRAC["Troll"]] = {
	[1] = { "m", "h", "e", "n", "h", "a", "j" },
	[2] = { "fu", "yu", "is", "so", "ju", "fi", "di", "ir", "im" },
	[3] = { "sca", "tor", "wha", "deh", "noh", "dim", "mek", "fus" },
	[4] = { "duti", "cyaa", "iyaz", "riva", "yudo", "skam", "ting" },
	[5] = { "ackee", "nehjo", "difus", "atuad", "siame", "t'ief", "wassa", "caang" },
	[6] = { "saakes", "stoosh", "quashi", "bwoyar", "wi'mek", "deh'yo", "fidong", "italaf", "smadda" },
	[7] = { "reespek", "rivasuf", "yahsoda", "lok'dim", "craaweh", "godeshi", "uptfeel" },
	[8] = { "machette", "oondasta", "wehnehjo", "nyamanpo", "whutless", "zutopong" },
	[9] = { "or'manley", "fus'obeah", "tor'wassa" }
};
Tongues.Language[BRAC["Troll"]].Difficulty = {
	["default"] 	= 100;

	[BFAC["Alliance"]] 	= 900;
	[BFAC["Horde"]] 	= 0;

	[BRAC["Human"]]	= 0;
	[BRAC["Dwarf"]] 	= 0;
	[BRAC["Gnome"]] 	= 0;
	[BRAC["Night Elf"]] 	= 0;
	[BRAC["Draenei"]]	= 0;

	[BRAC["Orc"]]	= 0;
	[BRAC["Troll"]]	= 0;
	[BRAC["Undead"]]	= 0;
	[BRAC["Tauren"]]	= 0;
	[BRAC["Blood Elf"]]	= 0;

	["Warrior"]	= 0;
	["Rogue"]	= 0;
	["Druid"]	= 0;
	["Mage"]	= 0;
	["Warlock"]	= 0;
	["Paladin"]	= 0;
	["Priest"]	= 0;
	["Shaman"]	= 0;
	["Hunter"]	= 0;
	["Death Knight"]= 0;
};

Tongues.Language[BRAC["Troll"]]["substitute"] = {
	["troll"] = "zandali",
};

Tongues.Language["Zandali"] = Tongues.Language[BRAC["Troll"]];
	--["alias"] = BRAC["Troll"]
--};
Tongues.Language["Amani"] = Tongues.Language[BRAC["Troll"]];
Tongues.Language["Gurubashi"] = Tongues.Language[BRAC["Troll"]];
Tongues.Language["Drakkari,"] = Tongues.Language[BRAC["Troll"]];
-----------------------------------------------------------------------------------------------
-- Tongues.Language: Dwarvish - courtesy of Blizzard
Tongues.Language[T_Dwarvish] = {
	[1] = { "a" },
	[2] = { "ke", "lo", "we", "go", "am", "ta", "ok" },
	[3] = { "ruk", "red", "mok", "mos", "gor", "kha", "ahz", "hor" },
	[4] = { "hrim", "modr", "rand", "khaz", "grum", "gear", "kost", "loch", "gosh", "gear", "guma", "rune", "hoga" },
	[5] = { "goten", "mitta", "modor", "angor", "skalf", "thros", "dagum", "havar", "scyld", "havas" },
	[6] = { "syddan", "rugosh", "bergum", "haldji", "drugan", "robush", "modoss", "modgud" },
	[7] = { "mok-kha", "kaelsag", "godkent", "thorneb", "geardum", "dun-fel", "havagun", "ok-hoga" },
	[8] = { "golganar", "moth-tur", "gefrunon", "mogodune", "khaz-dum", "misfaran" },
	[9] = { "arad-khaz", "ahz-dagum", "khaz-rand", "mund-helm", "kost-guma" },
	[10] = { "hoga-modan", "angor-magi", "midd-havas", "nagga-roth", "kael-skalf" },
	[11] = { "azgol-haman" }
};


Tongues.Language[T_Dwarvish]["ignore"] = {
	"Bael Modan", "haggis", "Khadgar", "Khaz Modan", "loch", "modan", "lorn", "magna", "thane",
	"Barab", "Aradun", "Thorin", "Magni", "Garrim", "Wendel", "Thurimar", "Chise", "Helge", "Ferya", "Furga", "Krona", "Imli",
	"Kazdun", "Hagrim", "Dondar", "Soldrin", "Kella", "Lorim", "Ar-ya", "Senica", "Angor", "Baradin", "Bael'dun", "Dun Algaz",
	"Dun Baldar", "Dun Garok", "Dun Mandarr", "Dun Modr", "Dun Morogh", "Gol'bolar", "Grim Batol", "Kharanos", "Thandol", "Thelgen",
	"Thelsamar", "Thor Modan"
};
Tongues.Language[T_Dwarvish]["substitute"] = {
	["yes"] = "oie",
	["no"] = "eta",
	["giant"] = "gar",
	["mountain"] = "modan",
	["land"] = "lorn",
	["red mountain"] = "Bael Modan",
	["the red mountain"] = "Bael Modan",
	["mountain of khaz"] = "Khaz Modan",
	["red"] = "bael",
	["red giant"] = "bael'gar",
	["mountain lake"] = "Loch Modan",
	["shire"] = "dun",
	["bael'shire"] = "redshire",
	["lake"] = "loch",
	["trust"] = "khadgar",
	["protector"] = "magna",
	["mountain king"] = "thane", 
};


Tongues.Language[T_Dwarvish].Difficulty = {
	["default"] 	= 100;

	[BFAC["Alliance"]] 	= 0;
	[BFAC["Horde"]] 	= 900;

	[BRAC["Human"]]	= 0;
	[BRAC["Dwarf"]] 	= 0;
	[BRAC["Gnome"]] 	= 0;
	[BRAC["Night Elf"]] 	= 0;
	[BRAC["Draenei"]]	= 0;

	[BRAC["Orc"]]	= 0;
	[BRAC["Troll"]]	= 0;
	[BRAC["Undead"]]	= 0;
	[BRAC["Tauren"]]	= 0;
	[BRAC["Blood Elf"]]	= 0;

	["Warrior"]	= 0;
	["Rogue"]	= 0;
	["Druid"]	= 0;
	["Mage"]	= 0;
	["Warlock"]	= 0;
	["Paladin"]	= 0;
	["Priest"]	= 0;
	["Shaman"]	= 0;
	["Hunter"]	= 0;
	["Death Knight"]= 0;
};


Tongues.Language[BCT["Gorilla"]] = {
[1] = {"o","i","e","u"},
[2] = {"oo","ie","ee"},
[3] = {"oho","ooh","oie","ohe","oug","oee","iee"},
[4] = {"ohie","eeip","eoie","uohg","ehep","uie","oppp"},
}

Tongues.Language[BCT["Monkey"]] = Tongues.Language[BCT["Gorilla"]];

Tongues.Language[BCT["Gorilla"]].Difficulty = {
	["default"] 	= 1000;

	[BFAC["Alliance"]] 	= 900;
	[BFAC["Horde"]] 	= 900;

	[BRAC["Human"]]	= 0;
	[BRAC["Dwarf"]] 	= 0;
	[BRAC["Gnome"]] 	= 0;
	[BRAC["Night Elf"]] 	= 0;
	[BRAC["Draenei"]]	= 0;

	[BRAC["Orc"]]	= 0;
	[BRAC["Troll"]]	= 0;
	[BRAC["Undead"]]	= 0;
	[BRAC["Tauren"]]	= 0;
	[BRAC["Blood Elf"]]	= 0;

	["Warrior"]	= 0;
	["Rogue"]	= 0;
	["Druid"]	= 0;
	["Mage"]	= 0;
	["Warlock"]	= 0;
	["Paladin"]	= 0;
	["Priest"]	= 0;
	["Shaman"]	= 0;
	["Hunter"]	= -300;
	["Death Knight"]= 0;
};
-----------------------------------------------------------------------------------------------
-- Tongues.Language: Gnomish - courtesy of Blizzard
Tongues.Language[T_Gnomish] = {
	[1] = { "g", "o", "c", "i", "t" },
	[2] = { "ti", "ga", "am", "ok", "we", "lo", "ke", "ti", "um" },
	[3] = { "giz", "dun", "gal", "gar", "mos", "zah", "fez", "dun", "nid" },
	[4] = { "grum", "lock", "rand", "gosh", "riff", "kahs", "cost", "dani", "hine", "helm" },
	[5] = { "tiras", "angor", "nagin", "algos", "thros", "mitta", "haven", "dagem", "goten", "havis" },
	[6] = { "danieb", "helmok", "drugan", "rugosh", "gizber", "dumssi", "waldor", "mergud" },
	[7] = { "geardum", "scrutin", "ferdosr", "godling", "bergrim", "haidren", "noxtyec", "thorneb", "costirm" },
	[8] = { "landivar", "gefrunon", "aldanoth", "kahzregi", "kahsgear", "methrine", "landivar", "godunmug", "mikthros" },
	[9] = { "nockhavis", "naggirath", "angordame", "elodmodor", "elodergrim" },
	[10] = { "sihnvulden", "danavandar", "mundgizber", "angordame", "elodmodor", "dyrstagist", "ahzodaugum", "frendgalva", "throsigear" },
	[11] = { "thrunon'gol", "robuswaldir", "helmokheram", "thrunon'gol", "kahzhaldren", "haldjinagin", "skalfgizgar", "lockrevoshi" }
};
Tongues.Language[T_Gnomish]["ignore"] = {
	"Grobnick", "Kazbo", "Hagin", "Snoonose", "Beggra", "Nefti", "Sorassa", "Gamash"
};
Tongues.Language[T_Gnomish].Difficulty = {
	["default"] 	= 100;

	[BFAC["Alliance"]] 	= 0;
	[BFAC["Horde"]] 	= 900;

	[BRAC["Human"]]	= 0;
	[BRAC["Dwarf"]] 	= 0;
	[BRAC["Gnome"]] 	= 0;
	[BRAC["Night Elf"]] 	= 0;
	[BRAC["Draenei"]]	= 0;

	[BRAC["Orc"]]	= 0;
	[BRAC["Troll"]]	= 0;
	[BRAC["Undead"]]	= 0;
	[BRAC["Tauren"]]	= 0;
	[BRAC["Blood Elf"]]	= 0;

	["Warrior"]	= 0;
	["Rogue"]	= 0;
	["Druid"]	= 0;
	["Mage"]	= 0;
	["Warlock"]	= 0;
	["Paladin"]	= 0;
	["Priest"]	= 0;
	["Shaman"]	= 0;
	["Hunter"]	= 0;
	["Death Knight"]= 0;
};

-----------------------------------------------------------------------------------------------
-- Tongues.Language: Darnassian - courtesy of Blizzard
Tongues.Language[T_Darnassian] = {
	[1] = { "o", "d", "n" },
	[2] = { "al", "ni", "su", "ri", "lo", "do", "no", "su" },
	[3] = { "osa", "fal", "ash", "tur", "nor", "dur", "tal" },
	[4] = { "dieb", "shar", "alah", "fulo", "mush", "dath", "anar", "rini", "diel", "thus", "aman" },
	[5] = { "turus", "balah", "shari", "ishnu", "terro", "talah", "thera", "falla" },
	[6] = { "ishura", "shando", "t'as'e", "ethala", "neph'o", "do'rah", "belore" },
	[7] = { "alah'ni", "dor'ano", "aman'ni", "al'shar", "shan're", "asto're" },
	[8] = { "eraburis", "d'ana'no", "mandalas", "dal'dieb", "thoribas" },
	[9] = { "thori'dal", "banthalos", "shari'fal", "fala'andu", "talah'tur" },
	[10] = { "ash'therod", "isera'duna", "shar'adore", "thero'shan", "dorados'no" },
	[11] = { "shari'adune", "fandu'talah", "t'ase'mushal" },
	[12] = { "t'ase'mushal", "dor'ana'badu", "dur'osa'dieb" }
};
Tongues.Language[T_Darnassian]["ignore"] = {
	"Medivh", "Sunstrider", "Quel'dorei", "Sin'dorei", "Quel'Thalas", "Quel'Zaram", "Quel'Danil", "Kim'jael",
	"Mariel", "Arhaniar", "Anandor", "Tharama", "Viridiel", "Malanior", "Anarial", "Freja", "Driana", "Coria", "Alanassori",
	"Melanion", "Azshara", "An'daroth", "An'owyn", "An'telas", "Anar'endal dracon", "Anara'nel belore", "balamore shanal", "bandal",
	"band'or shorel'aran", "belesa menoor", "Elrendar", "endala finel endal", "endorel aluminor", "Falthrien", "Falithas", "felomin ashal",
	"Quel'Danas", "Quel'Lithien", "selama am'oronor", "Shalandis", "Shan'dor", "tal anu'men no Sin'dorei"
};
Tongues.Language[T_Darnassian]["substitute"] = {
	["safe travels"] = "al diel shala",
	["by the light of the sun"] = "anar'alah belore",
	["speak your business"] = "anaria shola",
	["the sun guides us"] = "anu belore dela'na",
	["greetings, traveler"] = "bal'a dash, malanore",
	["taste the chill of true death"] = "bash'a no falor talah",
	["how fare you"] = "doral ana'diel",
	["little rat"] = "kim'jael",
	["keeper of secrets"] = "medivh",
	["high elves"] = "quel'dorei",
	["high kingdom"] = "quel'thalas",
	["peaceful"] = "ronae",
	["justice for our people"] = "selama ashal'anore",
	["they're breaking through"] = "shindu fallah na",
	["farewell"] = "shorel'aran",
	["blood elves"] = "sin'dorei",
	["well met"] = "sinu a'manore",
	["help me forget"] = "vendel'o eranu",
};
Tongues.Language[T_Darnassian].Difficulty = {
	["default"] 	= 100;

	[BFAC["Alliance"]] 	= 0;
	[BFAC["Horde"]] 	= 900;

	[BRAC["Human"]]	= 0;
	[BRAC["Dwarf"]] 	= 0;
	[BRAC["Gnome"]] 	= 0;
	[BRAC["Night Elf"]] 	= 0;
	[BRAC["Draenei"]]	= 0;

	[BRAC["Orc"]]	= 0;
	[BRAC["Troll"]]	= 0;
	[BRAC["Undead"]]	= 0;
	[BRAC["Tauren"]]	= 0;
	[BRAC["Blood Elf"]]	= 0;

	["Warrior"]	= 0;
	["Rogue"]	= 0;
	["Druid"]	= 0;
	["Mage"]	= 0;
	["Warlock"]	= 0;
	["Paladin"]	= 0;
	["Priest"]	= 0;
	["Shaman"]	= 0;
	["Hunter"]	= 0;
	["Death Knight"]= 0;
};
-----------------------------------------------------------------------------------------------
-- Tongues.Language: Gutterspeak - courtesy of Blizzard---As of patch 4.0.3a this was changed ot Forsaken
Tongues.Language[T_Forsaken] = {
	[1] = { "o", "y", "e" },
	[2] = { "lo", "va", "lu", "an", "ti", "re", "ne", "me", "ko", "ru" },
	[3] = { "bor", "bur", "ash", "mod", "ras", "wos", "lon", "ver", "nud", "far", "gol" },
	[4] = { "thor", "ruff", "veld", "agol", "vrum", "dana", "uden", "noth", "agol", "odes", "lars", "vohl" },
	[5] = { "tiras", "garde", "borne", "gloin", "wirsh", "ergin", "tiras", "eynes", "algos", "nagan" },
	[6] = { "ruftos", "rothas", "danieb", "valesh", "aziris", "aesire", "engoth", "ealdor", "vandar", "mandos", "skilde" },
	[7] = { "koshvel", "vassild", "faergas", "andovis", "sturume", "ewiddan", "nandige", "kaelsig", "novaedi", "lithtos" },
	[8] = { "aldonoth", "endirvis", "methrine", "lordaere", "hamerung", "thorniss", "ruftvess", "cynegold", "methrine" },
	[9] = { "vandarwos", "eloderung", "danagarde", "udenmajis", "regenthor", "gothalgos", "gloinador", "aetwinter", "firalaine" },
	[10] = { "danavandar", "falhedring", "cynewalden", "dyrstigost", "aelgestron" },
	[11] = { "farlandowar", "thorlithos", "bornevalesh", "forthasador", "agolandovis" },
	[12] = { "golvelbarad", "nevrenrothas", "waldirskilde", "mandosdaegil", "adorstaerume" }
};
Tongues.Language[T_Forsaken].Difficulty = {
	["default"] 	= 100;

	[BFAC["Alliance"]] 	= 900;
	[BFAC["Horde"]] 	= 0;

	[BRAC["Human"]]	= 0;
	[BRAC["Dwarf"]] 	= 0;
	[BRAC["Gnome"]] 	= 0;
	[BRAC["Night Elf"]] 	= 0;
	[BRAC["Draenei"]]	= 0;

	[BRAC["Orc"]]	= 0;
	[BRAC["Troll"]]	= 0;
	[BRAC["Undead"]]	= 0;
	[BRAC["Tauren"]]	= 0;
	[BRAC["Blood Elf"]]	= 0;

	["Warrior"]	= 0;
	["Rogue"]	= 0;
	["Druid"]	= 0;
	["Mage"]	= 0;
	["Warlock"]	= 0;
	["Paladin"]	= 0;
	["Priest"]	= 0;
	["Shaman"]	= 0;
	["Hunter"]	= 0;
	["Death Knight"]= 0;
};

Tongues.Language[T_Gutterspeak] = Tongues.Language[T_Forsaken];
-----------------------------------------------------------------------------------------------
-- Tongues.Language: Taurahe - courtesy of Blizzard
Tongues.Language[T_Taurahe] = {
	[1] = { "i", "o", "e", "a", "n" },
	[2] = { "te", "ta", "po", "tu", "lo", "ki", "wa" },
	[3] = { "uku", "chi", "owa", "kee", "ich", "awa", "alo", "rah", "ish" },
	[4] = { "nahe", "balo", "awak", "isha", "mani", "tawa", "towa", "a'ke", "halo", "shte" },
	[5] = { "nechi", "shush", "a'hok", "nokee", "tanka", "ti'ha", "pawni", "anohe", "ishte", "yakee" },
	[6] = { "ichnee", "sho'wa", "hetawa", "washte", "lomani", "owachi", "lakota", "aloaki" },
	[7] = { "shteawa", "pikialo", "ishnelo", "kichalo", "tihikea", "sechalo" },
	[8] = { "awaihilo", "akiticha", "porahalo", "ovaktalo", "shtumani", "towateke", "ishnialo", "owatanka", "awaihilo" },
	[9] = { "echeyakee", "haloyakee", "tawaporah", "ishne'alo", "tanka'kee" },
	[10] = { "ichnee'awa", "shteowachi", "awaka'nahe", "ishamuhale", "ishte'towa" },
	[11] = { "shtumanialo", "aloaki'shne", "awakeekielo", "aloaki'shne", "lakota'mani" }
};
Tongues.Language[T_Taurahe]["ignore"] = {
	"Shu'halo", "An'she", "Mu'sha", "Apa'ro", "Echeyakee", "Isha Awak", "Ishamuhale", "Lakota'mani", "Owatanka", "Washte Pawne",
	"Azok", "Bron", "Turok", "Garaddon", "Hruon", "Jeddek", "Arikara", "Arra'chea", "Mazzranache", "Aparaje", "Mojache", "Narache", 
	"Taurajo", "Tahonda", "Ish-ne-alo por-ah", "Por-ah"
};
Tongues.Language[T_Taurahe]["substitute"] = {
	["the tauren"] = "Shu'halo",
	["the sun"] = "An'she",
	["the moon"] = "Mu'sha",
	["Apa'ro"] = "Malorne",
	["Echeyakee"] = "Whitemist",
	["Isha Awak"] = "Deep Doom",
	["Ishamuhale"] = "Speartooth",
	["Lakota'mani"] = "Earthshaker",
	["Owatanka"] = "Bluebolt",
	["Washte Pawne"] = "Spirit Biter",
};
Tongues.Language[T_Taurahe].Difficulty = {
	["default"] 	= 100;

	[BFAC["Alliance"]] 	= 900;
	[BFAC["Horde"]] 	= 0;

	[BRAC["Human"]]	= 0;
	[BRAC["Dwarf"]] 	= 0;
	[BRAC["Gnome"]] 	= 0;
	[BRAC["Night Elf"]] 	= 0;
	[BRAC["Draenei"]]	= 0;

	[BRAC["Orc"]]	= 0;
	[BRAC["Troll"]]	= 0;
	[BRAC["Undead"]]	= 0;
	[BRAC["Tauren"]]	= -900;
	[BRAC["Blood Elf"]]	= 0;

	["Warrior"]	= 0;
	["Rogue"]	= 0;
	["Druid"]	= 0;
	["Mage"]	= 0;
	["Warlock"]	= 0;
	["Paladin"]	= 0;
	["Priest"]	= 0;
	["Shaman"]	= 0;
	["Hunter"]	= 0;
	["Death Knight"]= 0;
};
-----------------------------------------------------------------------------------------------
-- Tongues.Language: Draenei - courtesy of Blizzard
Tongues.Language[BRAC["Draenei"]] = {
	[1] = { "x", "o", "y", "g", "e" },
	[2] = { "no", "me", "za", "xi", "az", "ze", "il", "ul", "ur", "re", "te" },
	[3] = { "zar", "lek", "ruk", "ril", "shi", "asj", "daz", "kar", "lok", "tor", "maz", "laz" },
	[4] = { "aman", "raka", "maez", "amir", "zenn", "rikk", "alar", "veni", "ashj", "zila" },
	[5] = { "rakir", "soran", "adare", "belan", "modas", "buras", "golad", "kamil", "melar", "refir", "zekul", "tiros", "revos" },
	[6] = { "mannor", "arakal", "thorje", "tichar", "kazile", "mishun", "rakkan", "revola", "karkun", "archim", "azgala", "rakkas", "rethul" },
	[7] = { "karaman", "tiriosh", "danashj", "toralar", "zennshi", "rethule", "amanare", "gulamir", "faramos", "belaros", "faralos" },
	[8] = { "sorankar", "romathis", "theramas", "rukadare", "azrathud", "belankar", "ashjraka", "maladath", "enklizar", "mordanas", "azgalada" },
	[9] = { "nagasraka", "melamagas", "arakalada", "melarorah", "soranaman", "teamanare", "naztheros" },
	[10] = { "burasadare", "amanemodas", "ashjrethul", "pathrebosh", "zennrakkan", "matheredor", "kamilgolad", "benthadoom", "ticharamir" },
	[11] = { "ashjrakamas", "mishunadare", "zekulrakkas", "archimtiros", "mannorgulan" },
    	[12] = { "zennshinagas" }
};
Tongues.Language[BRAC["Draenei"]].Difficulty = {
	["default"] 	= 100;

	[BFAC["Alliance"]] 	= 0;
	[BFAC["Horde"]] 	= 900;

	[BRAC["Human"]]	= 0;
	[BRAC["Dwarf"]] 	= 0;
	[BRAC["Gnome"]] 	= 0;
	[BRAC["Night Elf"]] 	= 0;
	[BRAC["Draenei"]]	= -900;

	[BRAC["Orc"]]	= 0;
	[BRAC["Troll"]]	= 0;
	[BRAC["Undead"]]	= 0;
	[BRAC["Tauren"]]	= 0;
	[BRAC["Blood Elf"]]	= 0;

	["Warrior"]	= 0;
	["Rogue"]	= 0;
	["Druid"]	= 0;
	["Mage"]	= 0;
	["Warlock"]	= 0;
	["Paladin"]	= 0;
	["Priest"]	= 0;
	["Shaman"]	= 0;
	["Hunter"]	= 0;
	["Death Knight"]= 0;
};
-----------------------------------------------------------------------------------------------
-- Tongues.Language: Thalassian - courtesy of Blizzard
Tongues.Language[T_Thalassian] = {
	[1] = { "o", "n", "d", "e" },
	[2] = { "an", "su", "ni", "no", "lo", "ri", "da", "do", "al" },
	[3] = { "tal", "anu", "ash", "nor", "tur", "fal", "dor", "ano" },
	[4] = { "shar", "rini", "fulo", "dath", "mush", "andu", "anar", "alah", "diel", "dieb" },
	[5] = { "adore", "terro", "talah", "bandu", "balah", "turus", "eburi", "thera", "shano", "shari", "ishnu", "fandu" },
	[6] = { "fallah", "neph'o", "t'as'e", "man'ar", "dorini", "u'phol", "do'rah", "ishura", "shando", "ethala" },
	[7] = { "dor'ano", "anoduna", "shan're", "mush'al", "alah'ni", "asto're" },
	[8] = { "d'ana'no", "dorithur", "eraburis", "thoribas", "dal'dieb", "mandalas", "il'amare" },
	[9] = { "fala'andu", "neph'anis", "banthalos", "dune'adah", "shari'fal", "thori'dal", "dath'anar" },
	[10] = { "isera'duna", "shar'adore", "dorados'no", "ash'therod", "thero'shan" },
	[11] = { "shari'adune", "fandu'talah", "dal'dieltha", "fala'anshus" }
};
Tongues.Language[T_Thalassian]["ignore"] = {
	"Medivh", "Sunstrider", "Quel'dorei", "Sin'dorei", "Quel'Thalas", "Quel'Zaram", "Quel'Danil", "Kim'jael",
	"Mariel", "Arhaniar", "Anandor", "Tharama", "Viridiel", "Malanior", "Anarial", "Freja", "Driana", "Coria", "Alanassori",
	"Melanion", "Azshara", "An'daroth", "An'owyn", "An'telas", "Anar'endal dracon", "Anara'nel belore", "balamore shanal", "bandal",
	"band'or shorel'aran", "belesa menoor", "Elrendar", "endala finel endal", "endorel aluminor", "Falthrien", "Falithas", "felomin ashal",
	"Quel'Danas", "Quel'Lithien", "selama am'oronor", "Shalandis", "Shan'dor", "tal anu'men no Sin'dorei"
};
Tongues.Language[T_Thalassian]["substitute"] = {
	["safe travels"] = "al diel shala",
	["by the light of the sun"] = "anar'alah belore",
	["speak your business"] = "anaria shola",
	["the sun guides us"] = "anu belore dela'na",
	["greetings, traveler"] = "bal'a dash, malanore",
	["taste the chill of true death"] = "bash'a no falor talah",
	["how fare you"] = "doral ana'diel",
	["little rat"] = "kim'jael",
	["keeper of secrets"] = "medivh",
	["high elves"] = "quel'dorei",
	["high kingdom"] = "quel'thalas",
	["peaceful"] = "ronae",
	["justice for our people"] = "selama ashal'anore",
	["they're breaking through"] = "shindu fallah na",
	["farewell"] = "shorel'aran",
	["blood elves"] = "sin'dorei",
	["well met"] = "sinu a'manore",
	["help me forget"] = "vendel'o eranu",
};
Tongues.Language[T_Thalassian].Difficulty = {
	["default"] 	= 100;

	[BFAC["Alliance"]] 	= 900;
	[BFAC["Horde"]] 	= 0;

	[BRAC["Human"]]	= 0;
	[BRAC["Dwarf"]] 	= 0;
	[BRAC["Gnome"]] 	= 0;
	[BRAC["Night Elf"]] 	= -200;
	[BRAC["Draenei"]]	= 0;

	[BRAC["Orc"]]	= 0;
	[BRAC["Troll"]]	= 0;
	[BRAC["Undead"]]	= 0;
	[BRAC["Tauren"]]	= 0;
	[BRAC["Blood Elf"]]	= -900;

	["Warrior"]	= 0;
	["Rogue"]	= 0;
	["Druid"]	= 0;
	["Mage"]	= 0;
	["Warlock"]	= 0;
	["Paladin"]	= 0;
	["Priest"]	= 0;
	["Shaman"]	= 0;
	["Hunter"]	= 0;
	["Death Knight"]= 0;
};
Tongues.Language["Sindassi"] = Tongues.Language[T_Thalassian]


Tongues.Language[BRAC["Goblin"]]={
[1]={"ak","rt","ik","um","fr","bl","zz","ap","un","ek",},
[2]={"eet","paf","gak","erk","gip","nap","kik","bap","ikk","grk"},
[3]={"tiga","moof","bitz","akak","ripl","foop","keek","errk","apap","rakr",},
[4]={"fibit","shibl","nebit","ababl","iklik","nubop","krikl","zibit","amama","apfap",},
[5]={"ripdip","skoopl","bapalu","oggnog","yipyip","kaklak","ikripl","bipfiz","kiklix","nufazl"},

[6]={"igglepop","bakfazl","rapnukl","fizbikl","lapadap","biglkip","nibbipl","fuzlpop","gipfizy","babbada",},

[7]={"ibbityip","etiggara","saklpapp","ukklnukl","bendippl","ikerfafl","ikspindl","kerpoppl","hopskopl",},

[8]={"hapkranky","skippykik","nogglefrap","rapnakskappypappl","rripdipskiplip",},

[9]={"napfazzyboggin","kikklpipkikkl","nibbityfuzhips","bobnobblepapkap","hikkitybippl",},
}

Tongues.Language[BRAC["Goblin"]].Difficulty = {
	["default"] 	= 100;

	[BFAC["Alliance"]] 	= 900;
	[BFAC["Horde"]] 	= 0;

	[BRAC["Human"]]	= 0;
	[BRAC["Dwarf"]] 	= 0;
	[BRAC["Gnome"]] 	= 0;
	[BRAC["Night Elf"]] 	= 0;
	[BRAC["Draenei"]]	= 0;

	[BRAC["Orc"]]	= 0;
	[BRAC["Troll"]]	= 0;
	[BRAC["Undead"]]	= 0;
	[BRAC["Tauren"]]	= 0;
	[BRAC["Blood Elf"]]	= 0;

	["Warrior"]	= 0;
	["Rogue"]	= 0;
	["Druid"]	= 0;
	["Mage"]	= 0;
	["Warlock"]	= 0;
	["Paladin"]	= 0;
	["Priest"]	= 0;
	["Shaman"]	= 0;
	["Hunter"]	= 0;
	["Death Knight"]= 0;
};

Tongues.Language["Gilnean-CodeSpeak"]={
[1] = {"o",},
[2] = {"oy","oi'",},
[3] = {"borrow and beg","pipe your eye","brown hat","skein of thread","near and far", "sorry and sad","flowerly dell","pot","teapot","toff","titfertat","lamps",},
[4] = {"hammer and tack","daft and barmy","nanny goat","airs","bottle","tick-tock","babbling","lemon and lime","brown bread","fore and aft","rats","sighs","ocean pearl","cow's calf","teapot lids","slip","berk","biters"},
[5] = {"grasshopper","mutter and stutter","tiddlywink","plant","tree trunk","read and write","airs and graces","babbling brook","lemon squeezer","bread and honey","sunny","thorn","howl",},
};


Tongues.Language["Gilnean-CodeSpeak"]["substitute"] = {
["talk"]="gab",
["talking"]="gabbin'",
["hey"] = "oi",
["hello"]="'ello",
--["friend"]="love",
--["friends"]="loves",
["what"]="wot",
["isn't"]="ain't",
["some"] = "sum",
				["something"] = "sumthing",
				["somethings"] = "sumthings",
				["something's"] = "sumthing's",
				["do you"] = "you",
				["you do"] = "you",
				["what"] = "wot",
				["whatever"] = "wotever",
				["you"] = "ya'",
				["your"] = "yer",
				--["woman"] = "lass",
				--["man"] = "lad",
				["was"] = "wus",
				["you'd"] = "yah'd",
				["you had"] = "yah'd",
				["never"] = "niver",
				["not"] = "no'",
				["where"] = "wer",
				


};

Tongues.Language["Gilnean-CodeSpeak"]["ignore"] = { "yes","no","a","I","I am", "I'm", "we","we are","we're","going","go","for","you","your",
"you're","you are","me","my","mine"};

Tongues.Language["Gilnean-CodeSpeak"].Difficulty = {
	["default"] 	= 100;

	[BFAC["Alliance"]] 	= 300;---its coded..its hard...
	[BFAC["Horde"]] 	= 900;

	[BRAC["Human"]]	= 0;
	[BRAC["Dwarf"]] 	= 0;
	[BRAC["Gnome"]] 	= 0;
	[BRAC["Night Elf"]] 	= 0;
	[BRAC["Draenei"]]	= 0;

	[BRAC["Orc"]]	= 0;
	[BRAC["Troll"]]	= 0;
	[BRAC["Undead"]]	= 0;
	[BRAC["Tauren"]]	= 0;
	[BRAC["Blood Elf"]]	= 0;

	["Warrior"]	= 0;
	["Rogue"]	= 0;
	["Druid"]	= 0;
	["Mage"]	= 0;
	["Warlock"]	= 0;
	["Paladin"]	= 0;
	["Priest"]	= 0;
	["Shaman"]	= 0;
	["Hunter"]	= 0;
	["Death Knight"]= 0;
};

Tongues.Language[T_Gilnean] = Tongues.Language["Gilnean-CodeSpeak"];


-----------------------------------------------------------------------------------------------
Tongues.Language[BCT["Wolf"]] = {
	[1] = { "a", "o", "u", "r" },
	[2] = { "ro", "ar", "rr", "ra", "wo", "ow", "gr" },
	[3] = { "arr", "roo", "aro", "rar", "gra", "raw", "owo", "woo", "wof", "yip", "aoo", "grr", "arg", "ruf", "awo", "rrg", "wif", "rag", "rwr" },
	[4] = { "rawr", "grar", "argh", "graw", "awoo", "aroo", "woof", "woff", "warg", "worg", "rarr", "ruff", "grrr", "roff", "rgrr", "roff", "wiff", "aooo", "rarg", "ragh", "wuff" },
	[5] = { "awroo", "grawr", "wrowl", "growl", "rawrf", "fwoof", "rrarg", "rwarg", "wroof", "grarg", "hawoo", "arrrr", "snarl", "grarr", "grarg", "graul", "awoof", "rwoof", "rawoo", "grr-r" },
	[6] = { "graroo", "grawoo", "rawoof", "rawoff", "rawuff", "grar'g", "grarrg", "rawarg", "wroofg", "rawroo",  "growrl", "rwroof", "aoo-oo", "grr'rg", "arrwoo", "rargrr", "arorrg", "grruff"},
	[7] = { "grarr'g", "awroo'fr", "grauwro", "grauwrl", "growoof", "rawroof", "graghrr", "gr'awrg", "arrgrar", "grar-rr", "rarwoof", "rawroof", "rarrgrr", "aoo-woo", "aroowrf", "grawoof", "yip-yip", "arr-grr" },
	[8] = { "woofwoof", "aroo-roo", "grauwoof", "grar-rar", "arr-grar", "grarr'arg", "aroowoof", "rawrgrrl", "growl-rr", "graw rar", "aroo woo", "grr ruff", "gra-wuff" },
	[9] = { "rrawgrawr", "grawr-rar", "rawawoof", "wrowlarrg", "wrowl'rar", "ar'grarrg", "arr grarr", "grawr rar" },
	[10] = { "grawr-rawr", "aroo-roo-o", "rawoo-woof", "ar'grar'rg", "grar rarrg", "grawr rawr", "rawoof grr", "yip grarrg", "fwoof woof", "ar grar-rr" },
	[11] = { "ar-rarrghrr", "growrl-rowr", "rrarg-rargh", "rar grr rar", "awroo grr-r", "grarr wroof", "graroo woof", "rar-wr awoo" },
	[12] = { "aroo-oo-woof", "aroo-ooo rar", "woof ar rowr", "a-rarg-rragh" },
	[13] = { "arr rarrg rag", "grawr rar rar", "grar rar awoo" },
	[14] = { "arr rarrg ragh", "grawr rar aroo" },
	[15] = { "grarr arg grawr", "grawr rawr rawr", "rrarg-rargh arr" },
	[16] = { "ruff ar rar woof", "grar gr rar aroo" }
};
Tongues.Language[BCT["Wolf"]]["substitute"] = {
	["hi"] = "arf",
	["hello"] = "arf-arf",
};
Tongues.Language[BCT["Wolf"]].Difficulty = {
	["default"] 	= 1000;

	[BFAC["Alliance"]] 	= 0;
	[BFAC["Horde"]] 	= 0;

	[BRAC["Human"]]	= 0;
	[BRAC["Dwarf"]] 	= 0;
	[BRAC["Gnome"]] 	= 0;
	[BRAC["Night Elf"]] 	= 0;
	[BRAC["Draenei"]]	= 0;

	[BRAC["Orc"]]	= 0;
	[BRAC["Troll"]]	= 0;
	[BRAC["Undead"]]	= 0;
	[BRAC["Tauren"]]	= 0;
	[BRAC["Blood Elf"]]	= 0;

	["Warrior"]	= 0;
	["Rogue"]	= 0;
	["Druid"]	= -900;
	["Mage"]	= 0;
	["Warlock"]	= 0;
	["Paladin"]	= 0;
	["Priest"]	= 0;
	["Shaman"]	= 0;
	["Hunter"]	= -200;
	["Death Knight"]= 0;
};

Tongues.Language[BCT["Hyena"]] = Tongues.Language[BCT["Wolf"]];
Tongues.Language[BCT["Core Hound"]] = Tongues.Language[BCT["Wolf"]];
Tongues.Language[BCT["Fox"]] = Tongues.Language[BCT["Wolf"]];--for cata
Tongues.Language[BCT["Dog"]] = Tongues.Language[BCT["Wolf"]];
-----------------------------------------------------------------------------------------------
Tongues.Language[BCT["Bear"]] = {
	[1] = { "g", "o", "a", "r" },
	[2] = { "ro", "ar", "rr", "ra", "gr" },
	[3] = { "grr", "ggr", "arg", },
	[4] = { "rawr", "roar", "argh", "graw" },
	[5] = { "grawr", "growl", "rrarg", "rwarg", "grarg", "arrrr", "snarl", "grarr", "grarg", "graul", "grr-r" },
	[6] = { "graroo", "grawoo", "grar'g", "grarrg", "rawarg", "wroofg", "rawroo",  "growrl", "aoo-oo", "grr'rg", "rargrr", "arorrg"},
	[7] = { "grarr'g", "awroo'fr", "grauwro", "grauwrl", "graghrr", "gr'awrg", "arrgrar", "grar-rr", "rarrgrr" },
	[8] = { "aroo-roo", "grar-rar", "arr-grar", "grarr'arg", "rawrgrrl", "growl-rr", "graw rar" },
	[9] = { "rrawgrawr", "grawr-rar", "wrowlarrg", "wrowl'rar", "ar'grarrg", "arr grarr", "grawr rar" },
	[10] = { "grawr-rawr", "aroo-roo-o", "rawoo-woof", "ar'grar'rg", "grar rarrg", "grawr rawr", "ar grar-rr" },
	[11] = { "ar-rarrghrr", "growrl-rowr", "rrarg-rargh", "rar grr rar", "awroo grr-r" },
};

Tongues.Language[BCT["Bear"]]["substitute"] = {
};
Tongues.Language[BCT["Bear"]].Difficulty = {
	["default"] 	= 1000;

	[BFAC["Alliance"]] 	= 0;
	[BFAC["Horde"]] 	= 0;

	[BRAC["Human"]]	= 0;
	[BRAC["Dwarf"]] 	= 0;
	[BRAC["Gnome"]] 	= 0;
	[BRAC["Night Elf"]] 	= 0;
	[BRAC["Draenei"]]	= 0;

	[BRAC["Orc"]]	= 0;
	[BRAC["Troll"]]	= 0;
	[BRAC["Undead"]]	= 0;
	[BRAC["Tauren"]]	= 0;
	[BRAC["Blood Elf"]]	= 0;

	["Warrior"]	= 0;
	["Rogue"]	= 0;
	["Druid"]	= -900;
	["Mage"]	= 0;
	["Warlock"]	= 0;
	["Paladin"]	= 0;
	["Priest"]	= 0;
	["Shaman"]	= 0;
	["Hunter"]	= -200;
	["Death Knight"]= 0;
};
-----------------------------------------------------------------------------------------------

Tongues.Language[BCT["Bat"]] = { 
	[1] = {"e","w","k","e","w","k","e","e","w","w",},
	[2] = {"si","wk","ak","ak","as","ew","wk","ee","iw","ia",},
	[3] = {"iss","wii","aks","kaw","ksa","iwe","eee","wkw","akk","eee",},
	[4] = {"eaks","keei","eeka","wews","esse","keww","iwee","ikke","sais","eksi",},
	[5] = {"seeas","kssws","kiiia","wekke","eiiak","kewsk","ikkis","akaee","aswaw","iwkkk",},
	[6] = {"aisika","kkkeks","kkwikw","waseee","aaaaak","iawiis","aaiwie","esiksi","swaakk","kekkek",},
	[7] = {"kakaaik","sekeeek","sseekki","wkweiak","wkkkwsi","sesikkw","sekkewk","ewkeeww","siwkaka","kasewwk",},
	[8] = {"eeiwiais","swiiaksk","awksaiwe","eeewkwak","keeeeaks","keeieeka","wewsesse","kewwiwee","ikkesais","eksiseea",},
	[9] = {"sksswskii","iawekkeei","iakkewski","kkisakaee","aswawiwkk","kaisikakk","kekskkwik","wwaseeeaa","aaakiawii","saaiwiees",},
	[10] = {"iksiswaakk","kekkekkaka","aiksekeeek","sseekkiwkw","eiakwkkkws","isesikkwse","kkewkewkee","wwsiwkakak","asewwkeeiw","iaisswiiak",},
};
Tongues.Language[BCT["Bat"]]["substitute"] = {
};
Tongues.Language[BCT["Bat"]].Difficulty = {
	["default"] 	= 1000;

	[BFAC["Alliance"]] 	= 0;
	[BFAC["Horde"]] 	= 0;

	[BRAC["Human"]]	= 0;
	[BRAC["Dwarf"]] 	= 0;
	[BRAC["Gnome"]] 	= 0;
	[BRAC["Night Elf"]] 	= 0;
	[BRAC["Draenei"]]	= 0;

	[BRAC["Orc"]]	= 0;
	[BRAC["Troll"]]	= 0;
	[BRAC["Undead"]]	= 0;
	[BRAC["Tauren"]]	= 0;
	[BRAC["Blood Elf"]]	= 0;

	["Warrior"]	= 0;
	["Rogue"]	= 0;
	["Druid"]	= -900;
	["Mage"]	= 0;
	["Warlock"]	= 0;
	["Paladin"]	= 0;
	["Priest"]	= 0;
	["Shaman"]	= 0;
	["Hunter"]	= -200;
	["Death Knight"]= 0;
};

Tongues.Language[BCT["Sporebat"]] = Tongues.Language[BCT["Bat"]];

-----------------------------------------------------------------------------------------------
Tongues.Language[BCT["Boar"]] = { 
	[1] = {"n","s","u","o","s","u","n","r","s","s",},
	[2] = {"rl","sl","gn","en","gr","os","nu","on","es","le",},
	[3] = {"lru","nle","rnr","tgs","trg","lno","ror","sns","guu","oor",},
	[4] = {"nenr","lnne","nolg","srsu","rrrr","nrss","esro","llnr","rger","ntue",},
	[5] = {"rongr","rrusr","teeeg","notno","oleel","nonrt","lutlr","gtgnn","gusen","estut",},
	[6] = {"elulng","ununtr","unnets","sgrnrn","rggegt","egsllu","eglsen","nrlnre","usggll","nntnru",},
	[7] = {"tgnggeu","urnnrot","rrootul","stnnlgt","snnnsre","rrueunn","urulnsu","osunrss","rlslgne","ngrosnu",},
	[8] = {"oneslelr","unlernrt","gstrglno","rorsnsgu","uoornenr","lnnenolg","srsurrrr","nrssesro","llnrrger","ntuerong",},
	[9] = {"rrrusrtee","egnotnool","eelnonrtl","utlrgtgnn","gusenestu","telulngun","untrunnet","ssgrnrnrg","gegtegsll","ueglsennr",},
	[10] = {"lnreusggll","nntnrutgng","geuurnnrot","rrootulstn","nlgtsnnnsr","errueunnur","ulnsuosunr","ssrlslgnen","grosnuones","lelrunlern",},
};
Tongues.Language[BCT["Boar"]]["substitute"] = {
};
Tongues.Language[BCT["Boar"]].Difficulty = {
	["default"] 	= 1000;

	[BFAC["Alliance"]] 	= 0;
	[BFAC["Horde"]] 	= 0;

	[BRAC["Human"]]	= 0;
	[BRAC["Dwarf"]] 	= 0;
	[BRAC["Gnome"]] 	= 0;
	[BRAC["Night Elf"]] 	= 0;
	[BRAC["Draenei"]]	= 0;

	[BRAC["Orc"]]	= 0;
	[BRAC["Troll"]]	= 0;
	[BRAC["Undead"]]	= 0;
	[BRAC["Tauren"]]	= 0;
	[BRAC["Blood Elf"]]	= 0;

	["Warrior"]	= 0;
	["Rogue"]	= 0;
	["Druid"]	= -900;
	["Mage"]	= 0;
	["Warlock"]	= 0;
	["Paladin"]	= 0;
	["Priest"]	= 0;
	["Shaman"]	= 0;
	["Hunter"]	= -200;
	["Death Knight"]= 0;
};

-----------------------------------------------------------------------------------------------
Tongues.Language[BCT["Serpent"]] = { 
	[1] = {"z","s","s","z","s","s","z","h","s","s",},
	[2] = {"si","si","es","es","es","zs","ss","zz","es","ie",},
	[3] = {"iss","sii","sss","hes","ise","isz","zzh","sss","ess","zzh",},
	[4] = {"zess","iszi","szie","shss","hssh","szss","eshz","iish","sees","shse",},
	[5] = {"szses","hssss","heeie","szhsz","zieei","szssi","isiis","shesz","esses","eshsh",},
	[6] = {"eisise","ssssis","sssiis","seszhs","seeeeh","iesiis","eeisiz","ssisse","sseeii","szhshs",},
	[7] = {"hssseis","shszhzi","sszzhsi","shssiei","sssssse","shsisss","shsizss","zsszhss","sisiese","seszsss",},
	[8] = {"zzesieis","ssiisssh","esiseisz","zzhssses","szzhzess","isziszie","shsshssh","szsseshz","iishsees","shseszse",},
	[9] = {"shsssshee","ieszhszzi","eeiszssii","siisshesz","esseseshs","heisisess","ssissssii","sseszhsse","eeehiesii","seeisizss",},
	[10] = {"issesseeii","szhshshsss","eisshszhzi","sszzhsishs","sieissssss","eshsissssh","sizsszsszh","sssisieses","eszssszzes","ieisssiiss",},
};
Tongues.Language[BCT["Serpent"]]["substitute"] = {
};
Tongues.Language[BCT["Serpent"]].Difficulty = {
	["default"] 	= 1000;

	[BFAC["Alliance"]] 	= 0;
	[BFAC["Horde"]] 	= 0;

	[BRAC["Human"]]	= 0;
	[BRAC["Dwarf"]] 	= 0;
	[BRAC["Gnome"]] 	= 0;
	[BRAC["Night Elf"]] 	= 0;
	[BRAC["Draenei"]]	= 0;

	[BRAC["Orc"]]	= 0;
	[BRAC["Troll"]]	= 0;
	[BRAC["Undead"]]	= 0;
	[BRAC["Tauren"]]	= 0;
	[BRAC["Blood Elf"]]	= 0;

	["Warrior"]	= 0;
	["Rogue"]	= 0;
	["Druid"]	= -900;
	["Mage"]	= 0;
	["Warlock"]	= 0;
	["Paladin"]	= 0;
	["Priest"]	= 0;
	["Shaman"]	= 0;
	["Hunter"]	= -200;
	["Death Knight"]= 0;
};
Tongues.Language[T_Nether] = Tongues.Language[BCT["Serpent"]];
Tongues.Language[BCT["Nether Ray"]] = Tongues.Language[BCT["Serpent"]];
Tongues.Language[BCT["Chimaera"]] = Tongues.Language[BCT["Serpent"]];
Tongues.Language[BCT["Crocolisk"]] = Tongues.Language[BCT["Serpent"]];
Tongues.Language[BCT["Devilsaur"]] = Tongues.Language[BCT["Serpent"]];
Tongues.Language[BCT["Raptor"]] = Tongues.Language[BCT["Serpent"]];
Tongues.Language[BCT["Dragonhawk"]] = Tongues.Language[BCT["Serpent"]];
-----------------------------------------------------------------------------------------------
-- Language: Ursine 
Tongues.Language[T_Ursine] = { 
	[1] = {"*grunt*", "y", "e", "*bark*", "a" }, 
	[2] = {"*snort*", "xi", "na", "to", "kt", "*bark*", "za", "ro", "ge", "sa", "bx", "za", "ig", "yh", "fe" }, 
	[3] = {"xip", "yar", "tak", "mik", "pel", "*bark*", "*growl*", "kix", "*yelp*", "*snort*", "ved", "sah", "fak", "tep", "ded", "gra", "dmo", "xiz" }, 
	[4] = {"ritk", "azul", "ilos", "boro", "derx", "rabo", "delu", "deri", "*bark*", "*growl*", "ferv", "seff", "ggrev", "xesa", "pukx", "goxh", "weyt", "pxof", "kopa", "gher", "vark" }, 
	[5] = {"mixik", "iffin", "oomtor", "delez", "franr", "ordef", "sredn", "kefed", "lemko", "infit", "defik", "daxin", "netox", "kkret", "denno", "gra'ge", "*growl*", "*bark*", "sejrn", "homta" }, 
	[6] = {"mil'ork", "gomsho", "*bark*", "*snort*", "*growl*", "*snarl*", "ifnega", "bevsoz", "kel'ond", "feevne", "anarro", "derona", "tevtepa", "nohjaa", "nekhot", "ghrelz", "dett'ox" }, 
	[7] = {"kor'edax", "ritkyar", "deleznoe", "*bark*", "*yelp*", "*snort*", "ghex'ort", "degretz", "homdrex", "feppz'ex", "xedfror", "bomofed", "dessaxi", "kegizos", "fezzer", "gtornox", "zzednok", "nemefez" }, 
	[8] = {"kin'chikx", "kitch'kal", "yitix'kil", "vlartstaf", "ritkboro", "travnoka", "sen'tanob", "zrap'nekt", "klexpili", "stanvano", "keplaveg", "seff'yha", "*bark*", "*growl*", "*snort*", "*snarl*", "hoxa'dnet", "baxajeha" }, 
	[9] = {"ilosd'enzi", "ghex'jevno", "*bark*", "*snort*", "*yelp*", "*growl*", "nexokrate", "depr'randa", "dret'yuiz", "grezpelan", "stralvopr", "belok'dean", "tremsedop", "kretdelpa", "kevd'orxla" }, 
	[10] = {"franrazuly", "vrazfolond", "dekkoratno", "deen'taroja", "feren'yonyx", "*growl*", "*bark*", "*yelp*", "*snarl*", "vetranxepn", "dropa'tidna", "grepnatxed", "fredn'aldox", "trepne'toxo", "grelxsraft" }, 
	[11] = {"kitch'yardel", "dortana'dotz", "greppfretan", "deel'deloana", "razdol'oxnap", "sednexretap", "desfreton'zi", "brakche'ynot", "derett'ongra", "pexdonn'rena", "*growl*", "*bark*", "*snarl*", "*yelp*" }, 
	[12] = {"reldon'atfrez", "chredon'akrez", "feztondrado", "dezrech'lanon", "noppro'ajvrek", "krezan'odroch", "verntrakonix", "brelsn'rakjej", "yimo'ifreltax", "*bark*", "*snarl*", "*growl*", "*yelp*", "firegne'tanox" } 
}; 
Tongues.Language[T_Ursine].Difficulty = {
	["default"] 	= 1000;

	[BFAC["Alliance"]] 	= 0;
	[BFAC["Horde"]] 	= 0;

	[BRAC["Human"]]	= 0;
	[BRAC["Dwarf"]] 	= 0;
	[BRAC["Gnome"]] 	= 0;
	[BRAC["Night Elf"]] 	= 0;
	[BRAC["Draenei"]]	= 0;

	[BRAC["Orc"]]	= 0;
	[BRAC["Troll"]]	= 0;
	[BRAC["Undead"]]	= 0;
	[BRAC["Tauren"]]	= 0;
	[BRAC["Blood Elf"]]	= 0;

	["Warrior"]	= 0;
	["Rogue"]	= 0;
	["Druid"]	= 0;
	["Mage"]	= 0;
	["Warlock"]	= 0;
	["Paladin"]	= 0;
	["Priest"]	= 0;
	["Shaman"]	= 0;
	["Hunter"]	= 0;
	["Death Knight"]= 0;
};

Tongues.Language[T_Kodo] = Tongues.Language[T_Ursine];
Tongues.Language[BCT["Rhino"]] = Tongues.Language[T_Ursine];

-----------------------------------------------------------------------------------------------
Tongues.Language[BCT["Cat"]] = {
	[1] = { "e", "o", "i", "r"},
	[2] = { "rw", "ow", "mi", "ra", "er", "rw", "rr", "pr" },
	[3] = { "brr", "prr", "mrr", "rrr"},
	[4] = { "mrow", "rowr", "miew", "miao", "meow", "reow", "purr" },
	[5] = { "mrowr", "rowrr", "miewr", "miaor", "meowr", "reorr", "reowr", "purrr" },
	[6] = { "screor", "burrrr" },
	[7] = { "meerrro", "mi-owr" },
	[8] = { "meerrror", "mi-owrr" },
	[9] = { "rowr-mrow", "rowr-reor", "prowr-brr"  },
};

Tongues.Language[BCT["Cat"]]["substitute"] = {
};
Tongues.Language[BCT["Cat"]].Difficulty = {
	["default"] 	= 1000;

	[BFAC["Alliance"]] 	= 0;
	[BFAC["Horde"]] 	= 0;

	[BRAC["Human"]]	= 0;
	[BRAC["Dwarf"]] 	= 0;
	[BRAC["Gnome"]] 	= 0;
	[BRAC["Night Elf"]] 	= 0;
	[BRAC["Draenei"]]	= 0;

	[BRAC["Orc"]]	= 0;
	[BRAC["Troll"]]	= 0;
	[BRAC["Undead"]]	= 0;
	[BRAC["Tauren"]]	= 0;
	[BRAC["Blood Elf"]]	= 0;

	["Warrior"]	= 0;
	["Rogue"]	= 0;
	["Druid"]	= -900;
	["Mage"]	= 0;
	["Warlock"]	= 0;
	["Paladin"]	= 0;
	["Priest"]	= 0;
	["Shaman"]	= 0;
	["Hunter"]	= -200;
	["Death Knight"]= 0;
};
Tongues.Language[T_Wyvern] = Tongues.Language[BCT["Cat"]];
-----------------------------------------------------------------------------------------------
Tongues.Language[T_Seal] = {
	[1] = { "g", "o", "a", "r" },
	[2] = { "or", "ar", "rr", "ra", "rf" },
	[3] = { "art", "arf", "grr", },
	[4] = { "aorf", "aort", "argh", "gart" },
	[5] = { "grawr", "growl", "rrarg", "rwarg", "grarg", "arrrr", "snarl", "grarr", "grarg", "graul", "grr-r" },
	[6] = { "graart", "grar'g", "grarrg", "rawarg", "wroofg", "rawroo",  "growrl", "aoo-oo", "grr'rg", "rargrr", "arorrg"},
	[7] = { "grarr'g", "awroo'fr", "grauwro", "grauwrl", "graghrr", "gr'awrg", "arrgrar", "grar-rr", "rarrgrr" },
	[8] = { "aroo-roo", "grar-rar", "arr-grar", "grarr'arg", "rawrgrrl", "growl-rr", "graw rar" },
	[9] = { "rrawgrawr", "grawr-rar", "wrowlarrg", "wrowl'arf", "arf rarrg", "art grarr", "grawr rar" },
	[10] = { "grawr-rawr", "aroo-roo-o", "rawoo-woof", "ar'grar'rg", "grar rarrg", "grawr rawr", "ar grar-rr" },
	[11] = { "ar-rarrghrr", "growrl-rowr", "rrarg-rargh", "rar grr rar", "awroo grr-r" },
};

Tongues.Language[T_Seal]["substitute"] = {
};

Tongues.Language[T_Seal].Difficulty = {
	["default"] 	= 1000;

	[BFAC["Alliance"]] 	= 0;
	[BFAC["Horde"]] 	= 0;

	[BRAC["Human"]]	= 0;
	[BRAC["Dwarf"]] 	= 0;
	[BRAC["Gnome"]] 	= 0;
	[BRAC["Night Elf"]] 	= 0;
	[BRAC["Draenei"]]	= 0;

	[BRAC["Orc"]]	= 0;
	[BRAC["Troll"]]	= 0;
	[BRAC["Undead"]]	= 0;
	[BRAC["Tauren"]]	= 0;
	[BRAC["Blood Elf"]]	= 0;

	["Warrior"]	= 0;
	["Rogue"]	= 0;
	["Druid"]	= -900;
	["Mage"]	= 0;
	["Warlock"]	= 0;
	["Paladin"]	= 0;
	["Priest"]	= 0;
	["Shaman"]	= 0;
	["Hunter"]	= 0;
	["Death Knight"]= 0;
};
-----------------------------------------------------------------------------------------------
Tongues.Language[T_Bird] = {
	[1] = { "c", "k", "a", "w" },
	[2] = { "ka", "ca", "aw", "aa" },
	[3] = { "cah", "kah", "kaw", "caw", "kaa", "caa" },
	[4] = { "caah", "kaah", "kaww", "caww", "kaaw", "caaw" },
	[5] = { "cacah", "kacah", "kakah", "cakah", "cacaw", "kacaw", "kakaw", "cakaw", "cacaa", "kacaa", "kakaa", "cakaa" },  
	[6] = { "cawcaw", "kawcaw", "kawkaw", "cawkaw", "cahcaw", "kahcaw", "kahkaw", "cahkaw", "cahcaa", "kahcaa", "kahkaa", "cahkaa" },  
};

Tongues.Language[T_Bird]["substitute"] = {
};
Tongues.Language[BCT["Tallstrider"]] = {
	["alias"] = T_Bird
};
Tongues.Language[T_Bird].Difficulty = {
	["default"] 	= 1000;

	[BFAC["Alliance"]] 	= 0;
	[BFAC["Horde"]] 	= 0;

	[BRAC["Human"]]	= 0;
	[BRAC["Dwarf"]] 	= 0;
	[BRAC["Gnome"]] 	= 0;
	[BRAC["Night Elf"]] 	= 0;
	[BRAC["Draenei"]]	= 0;

	[BRAC["Orc"]]	= 0;
	[BRAC["Troll"]]	= 0;
	[BRAC["Undead"]]	= 0;
	[BRAC["Tauren"]]	= 0;
	[BRAC["Blood Elf"]]	= 0;

	["Warrior"]	= 0;
	["Rogue"]	= 0;
	["Druid"]	= -900;
	["Mage"]	= 0;
	["Warlock"]	= 0;
	["Paladin"]	= 0;
	["Priest"]	= 0;
	["Shaman"]	= 0;
	["Hunter"]	= -200;
	["Death Knight"]= 0;
};
-----------------------------------------------------------------------------------------------
Tongues.Language[T_Ravenspeech] = {
	[1] = { "c", "k", "a", "w" },
	[2] = { "ka", "ca", "aw", "aa" },
	[3] = { "cah", "kah", "kaw", "caw", "kaa", "caa" },
	[4] = { "caah", "kaah", "kaww", "caww", "kaaw", "caaw" },
	[5] = { "cacah", "kacah", "kakah", "cakah", "cacaw", "kacaw", "kakaw", "cakaw", "cacaa", "kacaa", "kakaa", "cakaa" },  
	[6] = { "cawcaw", "kawcaw", "kawkaw", "cawkaw", "cahcaw", "kahcaw", "kahkaw", "cahkaw", "cahcaa", "kahcaa", "kahkaa", "cahkaa" },  
};

Tongues.Language[T_Ravenspeech]["substitute"] = {
};

Tongues.Language[T_Ravenspeech].Difficulty = {
	["default"] 	= 1000;

	[BFAC["Alliance"]] 	= 0;
	[BFAC["Horde"]] 	= 0;

	[BRAC["Human"]]	= 0;
	[BRAC["Dwarf"]] 	= 0;
	[BRAC["Gnome"]] 	= 0;
	[BRAC["Night Elf"]] 	= 0;
	[BRAC["Draenei"]]	= 0;

	[BRAC["Orc"]]	= 0;
	[BRAC["Troll"]]	= 0;
	[BRAC["Undead"]]	= 0;
	[BRAC["Tauren"]]	= 0;
	[BRAC["Blood Elf"]]	= 0;

	["Warrior"]	= 0;
	["Rogue"]	= 0;
	["Druid"]	= 0;
	["Mage"]	= 0;
	["Warlock"]	= 0;
	["Paladin"]	= 0;
	["Priest"]	= 0;
	["Shaman"]	= 0;
	["Hunter"]	= 0;
	["Death Knight"]= 0;
};
-----------------------------------------------------------------------------------------------
Tongues.Language[T_Equine] = { 
	[1] = {"ni",},
	[2] = {" whinny","niegh",},
	[3] = {" whinny niegh",},
	[4] = {" whinny  whinny"," niegh niegh ",},
	[5] = {" whinny niegh","whinny *snort*","whinny niegh ",},
};
Tongues.Language[T_Equine].Difficulty = {
	["default"] 	= 1000;

	[BFAC["Alliance"]] 	= 0;
	[BFAC["Horde"]] 	= 0;

	[BRAC["Human"]]	= 0;
	[BRAC["Dwarf"]] 	= 0;
	[BRAC["Gnome"]] 	= 0;
	[BRAC["Night Elf"]] 	= 0;
	[BRAC["Draenei"]]	= 0;

	[BRAC["Orc"]]	= 0;
	[BRAC["Troll"]]	= 0;
	[BRAC["Undead"]]	= 0;
	[BRAC["Tauren"]]	= 0;
	[BRAC["Blood Elf"]]	= 0;

	["Warrior"]	= 0;
	["Rogue"]	= 0;
	["Druid"]	= 0;
	["Mage"]	= 0;
	["Warlock"]	= 0;
	["Paladin"]	= 0;
	["Priest"]	= 0;
	["Shaman"]	= 0;
	["Hunter"]	= 0;
	["Death Knight"]= 0;
};
Tongues.Language[T_Binary] = {
[1] = {"1","0"},
[2] = {"11","10","00","01"},
[3] = {"111","110","100","000","001","011","101","010"},
[4] = {"1111","1110","1100","1000","0000","0001","0011","0111","0101","0110","1001"},
}

Tongues.Language[T_Binary].Difficulty = {
	["default"] 	= 1000;

	[BFAC["Alliance"]] 	= 0;
	[BFAC["Horde"]] 	= 0;

	[BRAC["Human"]]	= 0;
	[BRAC["Dwarf"]] 	= 0;
	[BRAC["Gnome"]] 	= -900;
	[BRAC["Night Elf"]] 	= 0;
	[BRAC["Draenei"]]	= 0;

	[BRAC["Orc"]]	= 0;
	[BRAC["Troll"]]	= 0;
	[BRAC["Undead"]]	= 0;
	[BRAC["Tauren"]]	= 0;
	[BRAC["Blood Elf"]]	= 0;
	[BRAC["Goblin"]] = -900;

	["Warrior"]	= 0;
	["Rogue"]	= 0;
	["Druid"]	= 0;
	["Mage"]	= 0;
	["Warlock"]	= 0;
	["Paladin"]	= 0;
	["Priest"]	= 0;
	["Shaman"]	= 0;
	["Hunter"]	= 0;
	["Death Knight"]= 0;
};

Tongues.Language[T_Moonkin] = {
	[1] = { "h", "w", "l", "o" },
	[2] = { "ho", "wo", "ol", "oo" },
	[3] = { "hoh", "woh", "hol", "oow", "koo", "ool" },
	[4] = { "hooh", "wool", "holl", "ooow", "kooo", "oool" },
	[5] = { "howol", "wohol", "hohol", "oooow", "kokoo", "ooool"},
	[6] = { "howhol", "wohwol", "holhol", "oowoow", "oolool", "oohhooo"},
};
Tongues.Language[T_Moonkin].Difficulty = {
	["default"] 	= 1000;

	[BFAC["Alliance"]] 	= 0;
	[BFAC["Horde"]] 	= 0;

	[BRAC["Human"]]	= 0;
	[BRAC["Dwarf"]] 	= 0;
	[BRAC["Gnome"]] 	= 0;
	[BRAC["Night Elf"]] 	= -500;
	[BRAC["Draenei"]]	= 0;

	[BRAC["Orc"]]	= 0;
	[BRAC["Troll"]]	= 0;
	[BRAC["Undead"]]	= 0;
	[BRAC["Tauren"]]	= 0;
	[BRAC["Blood Elf"]]	= 0;

	["Warrior"]	= 0;
	["Rogue"]	= 0;
	["Druid"]	= -900;
	["Mage"]	= 0;
	["Warlock"]	= 0;
	["Paladin"]	= 0;
	["Priest"]	= 0;
	["Shaman"]	= 0;
	["Hunter"]	= 0;
	["Death Knight"]= 0;
};
-----------------------------------------------------------------------------------------------
-- Appearantly according to Warcraft lore, Trents and Ancients speak and/or understand Darnassian so this will no longer be needed
Tongues.Language[T_Trentish] = {
	[1] = { "r", "o", "e", "a" },
	[2] = { "re", "ro", "rr", "ra", "oo", "oa", "ea" },
	[3] = { "eek", "ree", "rea", "roo", "ooo", "oak", "koa"},
	[4] = { "keek", "reek", "reak", "rook", "oook", "woak", "koak"},
	[5] = { "rooaa", "ooaor", "oaaoo", "eeoao", "oooao", "rooaa", "ooroo"},
	[6] = { "roooaa", "ooaaor", "oaaoao", "eeoaoe", "eoooao", "erooaa", "ooeroo"},
	[6] = { "rooroaa", "oroaaor", "oaraoao", "eeroaoe", "eroooao", "erooraa", "ooreroo"},
	[7] = { "rororoaa", "oroaraor", "roaraoao", "eerroaoe", "erooorao", "eroorraa", "oorerroo"},
	[8] = { "rororkoaa", "orkoaraor", "roakraoao", "eerrkoaoe", "erokoorao", "eroorkraa", "ookrerroo"},
	[9] = { "rkororkoaa", "korkoaraor", "roakraoako", "eerrkokaoe", "erokoorkao", "eroorkraak", "ookrerkroo"},
	[10] = { "rokororkoaa", "okorkoaraor", "oroakraoako", "oeerrkokaoe", "oerokoorkao", "oeroorkraak", "oookrerkroo"},
};

Tongues.Language[T_Trentish].Difficulty = {
	["default"] 	= 1000;

	[BFAC["Alliance"]] 	= 0;
	[BFAC["Horde"]] 	= 0;

	[BRAC["Human"]]	= 0;
	[BRAC["Dwarf"]] 	= 0;
	[BRAC["Gnome"]] 	= 0;
	[BRAC["Night Elf"]] 	= -500;
	[BRAC["Draenei"]]	= 0;

	[BRAC["Orc"]]	= 0;
	[BRAC["Troll"]]	= 0;
	[BRAC["Undead"]]	= 0;
	[BRAC["Tauren"]]	= 0;
	[BRAC["Blood Elf"]]	= 0;

	["Warrior"]	= 0;
	["Rogue"]	= 0;
	["Druid"]	= -900;
	["Mage"]	= 0;
	["Warlock"]	= 0;
	["Paladin"]	= 0;
	["Priest"]	= 0;
	["Shaman"]	= -500;
	["Hunter"]	= 0;
	["Death Knight"]= 0;
};
Tongues.Language[BCT["Turtle"]] = Tongues.Language["Trentish"]
-----------------------------------------------------------------------------------------------
-- Tongues.Language: Dark Iron
Tongues.Language[T_DarkIron] = Tongues.Language[T_Dwarvish];
-----------------------------------------------------------------------------------------------
-- Tongues.Language: Kalimag ( Elemental ) - courtesy of Blizzard
Tongues.Language[T_Kalimag] = {
	[1] = { "a", "o", "k", "t", "g", "u" },
	[2] = { "ko", "ta", "gi", "ka", "tu", "os", "ma", "ra" },
	[3] = { "fel", "rok", "kir", "dor", "von", "nuk", "tor", "kan", "tas", "gun", "dra", "sto" },
	[4] = { "brom", "kras", "toro", "drae", "krin", "zoln", "fmer", "guto", "reth", "shin", "tols", "mahn" },
	[5] = { "bromo", "krast", "torin", "draek", "kranu", "zoern", "fmerk", "gatin", "roath", "shone", "talsa", "fraht" },
	[6] = { "ben'nig", "korsul", "ter'ran", "for'kin", "suz'ahn", "dratir", "fel'tes", "toka'an", "drinor", "tadrom" },
	[7] = { "kel'shae", "dak'kaun", "tchor'ah", "zela'von", "telsrah", "kis'tean", "dorvrem", "koaresh", "fiilrok", "ven'tiro", "gi'frazsh", "chokgan", "fanroke" },
	[8] = { "taegoson", "kilagrin", "roc'grare", "gi'azol'em", "nuk'tra'te", "quin'mahk", "ties'alla", "shodru'ga", "os'retiak", "desh'noka", "rohh'krah", "krast'ven", "aasrugel" },
	[9] = { "tae'gel'kir", "draemierr", "dor'dra'tor", "zoln'nakaz", "mastrosum", "gatin'roth", "ahn'torunt", "thukad'aaz", "gesh'throm", "brud'remek" },
	[10] = { "aer'rohgmar", "mok'tavaler", "torrath'unt", "ignan'kitch", "caus'tearic", "borg'helmak", "huut'vactah", "tzench'drah", "vendo're'mik", "kraus'ghosa", "dalgo'nizha" },
	[11] = { "moth'keretch", "bach'usiv'hal", "jolpat'krim", "thloy'martok", "danal'korang", "kawee'fe'more", "sunep'kosach", "peng'yaas'ahn", "nash'lokan'ar", "derr'moran'ki", "moor'tosav'ak", "kis'an'tadrom", "korsukgrare" },
	[12] = { "golgo'nishver", "tagha'senchal" }
};

-- ignore: Kalimag
Tongues.Language[T_Kalimag]["ignore"] = { "kalimag", "ragnaros", "neptulon", "therazane" };

-- Altwords: Kalimag
Tongues.Language[T_Kalimag]["substitute"] = {
	["elemental"] = "kalimag",
	["elementals"] = "kalimar"
};

Tongues.Language["Elemental"] = {
	["alias"] = T_Kalimag
};
Tongues.Language[T_Kalimag].Difficulty = {
	["default"] 	= 1000;

	[BFAC["Alliance"]] 	= 0;
	[BFAC["Horde"]] 	= 0;

	[BRAC["Human"]]	= 0;
	[BRAC["Dwarf"]] 	= 0;
	[BRAC["Gnome"]] 	= 0;
	[BRAC["Night Elf"]] 	= 0;
	[BRAC["Draenei"]]	= 0;

	[BRAC["Orc"]]	= 0;
	[BRAC["Troll"]]	= 0;
	[BRAC["Undead"]]	= 0;
	[BRAC["Tauren"]]	= 0;
	[BRAC["Blood Elf"]]	= 0;

	["Warrior"]	= 0;
	["Rogue"]	= 0;
	["Druid"]	= 0;
	["Mage"]	= 0;
	["Warlock"]	= 0;
	["Paladin"]	= 0;
	["Priest"]	= 0;
	["Shaman"]	= -900;
	["Hunter"]	= 0;
	["Death Knight"]= 0;
};
Tongues.Language["Elemental"] = Tongues.Language[T_Kalimag]

-----------------------------------------------------------------------------------------------
-- Tongues.Language: Eredun ( Demonic ) - courtesy of Blizzard
Tongues.Language[T_Demonic] = {
	[1] = { "a", "e", "i", "o", "u", "y", "g", "x" },
	[2] = { "il", "no", "az", "te", "ur", "za", "ze", "re", "ul", "me", "xi" },
	[3] = { "tor", "gul", "lok", "asj", "kar", "lek", "daz", "maz", "ril", "ruk", "laz", "shi", "zar" },
	[4] = { "ashj", "alar", "orah", "amir", "aman", "ante", "kiel", "maez", "maev", "veni", "raka", "zila", "zenn", "parn", "rikk" },
	[5] = { "melar", "ashke", "rakir", "tiros", "modas", "belan", "zekul", "soran", "gular", "enkil", "adare", "golad", "buras", "nagas", "revos", "refir", "kamil" },
	[6] = { "rethul", "rakkan", "rakkas", "tichar", "mannor", "archim", "azgala", "karkun", "revola", "mishun", "arakal", "kazile", "thorje" },
	[7] = { "belaros", "tiriosh", "faramos", "danashj", "amanare", "kieldaz", "karaman", "gulamir", "toralar", "rethule", "zennshi" },
	[8] = { "maladath", "kirasath", "romathis", "amanare", "theramas", "azrathud", "mordanas", "amanalar", "ashjraka", "azgalada", "rukadare", "sorankar", "enkilzar", "belankar" },
	[9] = { "naztheros", "zilthuras", "kanrethad", "melarorah", "arakalada", "soranaman", "nagasraka", "teamanare" },
	[10] = { "matheredor", "ticharamir", "pathrebosh", "benthadoom", "enkilgular", "burasadare", "melarnagas", "zennrakkan", "ashjrethul", "amanemodas", "kamilgolad" },
	[11] = { "zekulrakkas", "archimtiros", "mannorgulan", "mishunadare", "ashjrakamas" },
	[12] = { "zennshinagas" }
};

-- ignore: Eredun
Tongues.Language[T_Demonic]["ignore"] = { 
	"eredun", 
	"eredar", 
	"Sargeras", 
	"Archimonde", 
	"Mannoroth",

	"Nozdormu", 
	"Alexstrasza", 
	"Ysera", 
	"Malygos", 
	"Neltharion", 
	"Krasus", 
	"Korialstrasz", 
	"Tyrannostrasz", 
	"Vaelastrasz", 
	"Belnistrasz", 
	"Azuregos", 
	"Haleh", 
	"Kalec", 
	"Kalecgyos", 
	"Sapphiron", 
	"Eranikus", 
	"Itharius", 
	"Ysondre", 
	"Lethon", 
	"Emeriss", 
	"Taerar", 
	"Morphaz", 
	"Chronormu", 
	"Occulus", 
	"Chronalis", 
	"Onyxia", 
	"Nefarion", 
	"Kalaran", 
	"Teremus", 
	"Searinox", 
	"Gyth", 
	"Drakkisath", 
	"Wyrmthalak"
};

-- Altwords: Eredun
Tongues.Language[T_Demonic]["substitute"] = { 
	["demonic"]	= "eredun", 
	["demon"]	= "eredar"
};
Tongues.Language[T_Demonic].Difficulty = {
	["default"] 	= 1000;

	[BFAC["Alliance"]] 	= 0;
	[BFAC["Horde"]] 	= 0;

	[BRAC["Human"]]	= 0;
	[BRAC["Dwarf"]] 	= 0;
	[BRAC["Gnome"]] 	= 0;
	[BRAC["Night Elf"]] 	= 0;
	[BRAC["Draenei"]]	= 0;

	[BRAC["Orc"]]	= 0;
	[BRAC["Troll"]]	= 0;
	[BRAC["Undead"]]	= 0;
	[BRAC["Tauren"]]	= 0;
	[BRAC["Blood Elf"]]	= 0;

	["Warrior"]	= 0;
	["Rogue"]	= 0;
	["Druid"]	= 0;
	["Mage"]	= 0;
	["Warlock"]	= -900;
	["Paladin"]	= 0;
	["Priest"]	= 0;
	["Shaman"]	= 0;
	["Hunter"]	= 0;
	["Death Knight"]= 0;
};


-- Other Languages that are separate but use Eredun's table
Tongues.Language[T_Eredun] = Tongues.Language[T_Demonic]
Tongues.Language[T_Titan] = Tongues.Language[T_Demonic]
Tongues.Language[T_Draconic] = Tongues.Language[T_Demonic]

-----------------------------------------------------------------------------------------------
-- Tongues.Language: Nerubian
Tongues.Language[T_Nerubian] = {
	[1] = { "m", "a", "t", "c", "k", "s", "u" },
	[2] = { "s'k", "ix", "t'k", "w'k", "qa", "h'r", "ph", "te", "en", "m'g" },
	[3] = { "ikh", "mar", "has", "mah", "chk", "mhj", "rhj", "ner", "m'rh", "kah", "sdh", "aa't", "k'st", "at't", "hs'p" },
	[4] = { "mh'gh", "tckh", "sujt", "gash", "tadh", "hasn", "kuht", "ahpt", "gher", "hadr", "ahtj", "anq'j", "uahr", "katc", "nifn", "mht'l", "ahtl", "anll", "tuvh", "qhna", "tajh" },
	[5] = { "hsatl", "tihkh", "nerub", "ankan", "anhqi", "mersk", "ind'eu", "ahtil", "tuhtl", "nehhm", "tutha", "xstha", "rhash", "sc'chk", "huskh", "ankha", "ni'cht", "asknq", "tchir", "cthsu", "khath", "nedhk", "nirjk", "ernhb" },
	[6] = { "natchk", "arahtl", "st'hcha", "ner'zuh", "anshtj", "thema't", "xhlatl", "tutank", "mahcrj", "qhuz'mn", "tas'qkb", "amnenn", "ras'zuj", "ak'schk" },
	[7] = { "amni'gkh", "zh'aqlir", "gaishan", "as'aith", "khashab", "tahattu", "ahamtik", "amhawnj", "gahdhmn", "ner'khan", "zub'amna", "narjhgt", "ash'rhjn" },
	[8] = { "thsk'anqi", "ashnt'khu", "ahtshakh", "amraa'nsh", "anj'khasz", "aman'ginh", "chak'sckh", "abrihght", "thkimpsa", "tltoani", "akh'nerig" },
	[9] = { "amnennar", "aszarh'itl", "nah'ahlzir", "ahjs'mhari", "nerub'anka", "mhandarjh", "ahlt'anksq", "qui'xhitl" },
	[10] = { "askh'nadfir", "zelk'neruzh", "gahdamarah", "erubtijiel", "unkh'leifra", "shiq'jhahnr", "tahat'ahk'nm", "haf'rahtuth" },
	[11] = { "hahse'nerutl", "anmhrabhskt", "majhanqhji", "gaht'nerdjhz", "nerhtl'qansh" }
};

-- ignore: Nerubian
Tongues.Language[T_Nerubian]["ignore"] = { "nerubian", "azjol", "nerub" };

Tongues.Language[T_Nerubian].Difficulty = {
	["default"] 	= 1000;

	[BFAC["Alliance"]] 	= 0;
	[BFAC["Horde"]] 	= 0;

	[BRAC["Human"]]	= 0;
	[BRAC["Dwarf"]] 	= 0;
	[BRAC["Gnome"]] 	= 0;
	[BRAC["Night Elf"]] 	= 0;
	[BRAC["Draenei"]]	= 0;

	[BRAC["Orc"]]	= 0;
	[BRAC["Troll"]]	= 0;
	[BRAC["Undead"]]	= 0;
	[BRAC["Tauren"]]	= 0;
	[BRAC["Blood Elf"]]	= 0;

	["Warrior"]	= 0;
	["Rogue"]	= 0;
	["Druid"]	= 0;
	["Mage"]	= 0;
	["Warlock"]	= 0;
	["Paladin"]	= 0;
	["Priest"]	= 0;
	["Shaman"]	= 0;
	["Hunter"]	= 0;
	["Death Knight"]= 0;
};

Tongues.Language[T_Qiraji] = Tongues.Language[T_Nerubian]
Tongues.Language[BCT["Silithid"]] = Tongues.Language[T_Nerubian]
Tongues.Language[BCT["Wasp"]] = Tongues.Language[T_Nerubian]
Tongues.Language[BCT["Ravager"]] = Tongues.Language[T_Nerubian]
Tongues.Language[BCT["Scorpid"]] = Tongues.Language[T_Nerubian]
Tongues.Language[BCT["Spider"]] = Tongues.Language[T_Nerubian]
Tongues.Language[BCT["Beetle"]] = Tongues.Language[T_Nerubian]

-----------------------------------------------------------------------------------------------
-- Tongues.Language: Nerglish (Murloc Tongues.Language)
Tongues.Language[T_Nerglish] = { 
	[1] = {"b","u","r","g","l","m",},
	[2] = {"rm","bg","lr","gl","gu","mg","gg","uu","mr","ur",},
	[3] = {"rmu","ggb","mmm","rur","rrr","bbu","glu","mrg","ggg","brl",},
	[4] = {"rugm","ubrg","lgub","mllm","grml","rmrl","gurl","gurr","rlur","glur",},
	[5] = {"lglgb","uubbg","glrub","gmrgu","rgmur","lgglm","rlrlr","rurlg","mgulm","uugru",},
	[6] = {"uuggrr","rlmgug","ulllur","gurggm","lugrgg","guguug","mruurr","rgruuu","uuuulg","umuugu",},
	[7] = {"brumbbr","mgrurgg","lrruuur","uluumgm","urmumrg","rmbrugu","rrugrru","uluuubr","rmbglrg","lgumggg",},
	[8] = {"uumrurrm","uggbubur","urlumbbu","glumrggg","gbrlrugm","uuuuubrg","lgubgruu","mllmgrml","ubguuuum","rmrllglg",},
	[9] = {"buubbgglr","ubgmrgurg","murlgglmr","lrlrrurlg","mgulmuugr","uuuggrrrl","mgugulllu","rgurggmlu","grggguguu","gmruurrrg",},
	[10] = {"ruuuuuuulg","umuugubrum","bbrmgrurgg","lrruuurulu","umgmurmumr","grmbrugurr","ugrruuluuu","brrmbglrgl","gumggguumr","urrmuggbub",},
	[11] = {"ururlumbbug","lumrggggbrl","rugmuuuuubr","glgubgruuml","lmgrmlubguu","uumrmrllglg","buubbgglrub","gmrgurgmurl","gglmrlrlrru","rlgmgulmuug",},
	[12] = {"ruuuggrrrlmg","ugulllurgurg","gmlugrgggugu","ugmruurrrgru","uuuuuulgumuu","gubrumbbrmgr","urgglrruuuru","luumgmurmumr","grmbrugurrug","rruuluuubrrm",},
};

-- ignore: Nerglish
Tongues.Language[T_Nerglish]["ignore"] = { "Mmmrrrggglll" };

Tongues.Language[T_Nerglish].Difficulty = {
	["default"] 	= 1000;

	[BFAC["Alliance"]] 	= 0;
	[BFAC["Horde"]] 	= 0;

	[BRAC["Human"]]	= 0;
	[BRAC["Dwarf"]] 	= 0;
	[BRAC["Gnome"]] 	= 0;
	[BRAC["Night Elf"]] 	= 0;
	[BRAC["Draenei"]]	= 0;

	[BRAC["Orc"]]	= 0;
	[BRAC["Troll"]]	= 0;
	[BRAC["Undead"]]	= 0;
	[BRAC["Tauren"]]	= 0;
	[BRAC["Blood Elf"]]	= 0;

	["Warrior"]	= 0;
	["Rogue"]	= 0;
	["Druid"]	= 0;
	["Mage"]	= 0;
	["Warlock"]	= 0;
	["Paladin"]	= 0;
	["Priest"]	= 0;
	["Shaman"]	= 0;
	["Hunter"]	= 0;
	["Death Knight"]= 0;
};

Tongues.Language[BCT["Crab"]] = Tongues.Language[T_Nerglish]
-----------------------------------------------------------------------------------------------
-- Tongues.Language: Nazja
Tongues.Language[T_Nazja] = {
	[1] = { "o", "d", "n" },
	[2] = { "al", "ni", "zu", "ri", "lo", "do", "no", "zu" },
	[3] = { "osa", "fal", "azjh", "tur", "nor", "dur", "tal" },
	[4] = { "dieb", "zjar", "alah", "fulo", "muzj", "dath", "anar", "rini", "diel", "thuz", "aman" },
	[5] = { "turuz", "balah", "zjari", "izjnu", "terro", "talah", "thera", "falla" },
	[6] = { "izjura", "zjando", "t'az'e", "ethala", "neph'o", "do'rah", "belore" },
	[7] = { "alah'ni", "dor'ano", "aman'ni", "al'zjar", "zjan're", "asto're" },
	[8] = { "eraburiz", "d'ana'no", "mandalaz", "dal'dieb", "thoribaz" },
	[9] = { "thori'dal", "banthaloz", "zjari'fal", "fala'andu", "talah'tur" },
	[10] = { "azj'therod", "izera'duna", "zjar'adore", "thero'shan", "doradoz'no" },
	[11] = { "zjari'adune", "fandu'talah", "t'ase'muzjal" },
	[12] = { "t'ase'muzjal", "dor'ana'badu", "dur'oza'dieb" }
};

Tongues.Language[T_Nazja].Difficulty = {
	["default"] 	= 1000;

	[BFAC["Alliance"]] 	= 0;
	[BFAC["Horde"]] 	= 0;

	[BRAC["Human"]]	= 0;
	[BRAC["Dwarf"]] 	= 0;
	[BRAC["Gnome"]] 	= 0;
	[BRAC["Night Elf"]] 	= 0;
	[BRAC["Draenei"]]	= 0;

	[BRAC["Orc"]]	= 0;
	[BRAC["Troll"]]	= 0;
	[BRAC["Undead"]]	= 0;
	[BRAC["Tauren"]]	= 0;
	[BRAC["Blood Elf"]]	= 0;

	["Warrior"]	= 0;
	["Rogue"]	= 0;
	["Druid"]	= 0;
	["Mage"]	= 0;
	["Warlock"]	= 0;
	["Paladin"]	= 0;
	["Priest"]	= 0;
	["Shaman"]	= 0;
	["Hunter"]	= 0;
	["Death Knight"]= 0;
};

--[[based on blizzard zombie language ]]
Tongues.Language[BRAC["Undead"]] = { 
	[1] = {".",},
	[2] = {". .", ".."},
	[3] = {"...",". . .", "bra-",},
	[4] = {"....", "brai-",},
	[5] = {"brain","....." ,},
	[6] = {"brains","......",},
};

Tongues.Language[BRAC["Undead"]].Difficulty = {
	["default"] 	= 1000;

	[BFAC["Alliance"]] 	= 0;
	[BFAC["Horde"]] 	= 0;

	[BRAC["Human"]]	= 0;
	[BRAC["Dwarf"]] 	= 0;
	[BRAC["Gnome"]] 	= 0;
	[BRAC["Night Elf"]] 	= 0;
	[BRAC["Draenei"]]	= 0;

	[BRAC["Orc"]]	= 0;
	[BRAC["Troll"]]	= 0;
	[BRAC["Undead"]]	= -900;
	[BRAC["Tauren"]]	= 0;
	[BRAC["Blood Elf"]]	= 0;

	["Warrior"]	= 0;
	["Rogue"]	= 0;
	["Druid"]	= 0;
	["Mage"]	= 0;
	["Warlock"]	= 0;
	["Paladin"]	= 0;
	["Priest"]	= 0;
	["Shaman"]	= 0;
	["Hunter"]	= 0;
	["Death Knight"]= -900;
};


Tongues.Language["Unknown"] = {
	[1] = { "o", "d", "n" },
	[2] = { "al", "ni", "zu", "ri", "lo", "do", "no", "zu" },
	[3] = { "osa", "fal", "azjh", "tur", "nor", "dur", "tal" },
	[4] = { "dieb", "zjar", "alah", "fulo", "muzj", "dath", "anar", "rini", "diel", "thuz", "aman" },
	[5] = { "turuz", "balah", "zjari", "izjnu", "terro", "talah", "thera", "falla" },
	[6] = { "izjura", "zjando", "t'az'e", "ethala", "neph'o", "do'rah", "belore" },
	[7] = { "alah'ni", "dor'ano", "aman'ni", "al'zjar", "zjan're", "asto're" },
	[8] = { "eraburiz", "d'ana'no", "mandalaz", "dal'dieb", "thoribaz" },
	[9] = { "thori'dal", "banthaloz", "zjari'fal", "fala'andu", "talah'tur" },
	[10] = { "azj'therod", "izera'duna", "zjar'adore", "thero'shan", "doradoz'no" },
	[11] = { "zjari'adune", "fandu'talah", "t'ase'muzjal" },
	[12] = { "t'ase'muzjal", "dor'ana'badu", "dur'oza'dieb" },
};

Tongues.Language["Unknown"].Difficulty = {
	["default"] 	= 0;
};

--contribution by Jaxxav
--Base Language by: Kaelash of Wyrmrest Accord
-- Tongues.Language: Scourge
Tongues.Language[T_Scourge] = {
    [1] = { "e", "u", "a", "i" },
    [2] = { "eh", "eg", "er", "en", "ah", "ag", "ar", "an", "ih", "ig", "ir" , "gh", "gr","rh", "nh", "hu" },
    [3] = { "ehh", "egh", "reh", "nhe", "nhu", "ghi", "hgh", "ahr","rhu", "fah", "rhf", "fhn", "khe" },
    [4] = { "ghar", "hhan", "grih", "rehg", "rhan", "gihr", "khur", "khaf", "rruh" },
    [5] = { "ehhga", "fhang", "kihge", "rrahg", "khufu", "arhaf", "hrrun", "gheff" },
    [6] = { "hrregk", "gihhka", "fehngr", "krahfn", "ehrruf", "saahrk" },
    [7] = { "khranus", "nurrahk", "fehskir", "ighrahf", "nessihn", "hrraffn", "gifuhrr" },
    [8] = { "fharrukk", "gheskurn", "hrrakhen", "nhurukef", "eganihrr", "ssarnihg" },
    [9] = { "ghaskurrf", "surrenahk", "khurranef", "firrahnes" }
};

-- ignore: Scourge
Tongues.Language[T_Scourge]["ignore"] = { "Arthas", "Darion", "Mograine", "Tirion", "Fordring", "Ebon Hold", "Ebon Blade", "Acherus", "Naxxramus", "Death Knight","Silvermoon","Thunder Bluff","Orgrimmar","Stormwind","Ironforge","Darnassus","Exodar" };

Tongues.Language[T_Scourge]["substitute"] = {
    ["tauren"]    = "Garehn",
    ["orc"]        = "Ahrk",
    ["forsaken"]    = "Frrsakn",
    ["blood elf"]    = "Ghag Heff",
    ["troll"]    = "Grehl",
    ["human"]    = "Henihn",
    ["dwarf"]    = "Garrf",
    ["night elf"]    = "Nih Heff",
    ["draenei"]    = "Grehne",
    ["gnome"]    = "Nohn",
    ["priest"]    = "Grehsk",
    ["shaman"]    = "Sahan",
    ["druid"]    = "Gruhg",
    ["hunter"]    = "Hahhnr",
    ["warlock"]    = "Urahhk",
    ["warrior"]    = "Ahrir",
    ["rogue"]    = "Rohg",
    ["mage"]    = "Nahgus",
    ["paladin"]    = "Kahranen",
    ["undercity"]    = "Lordaeron", };

Tongues.Language[T_Scourge].Difficulty = {
    ["default"]     = 1000;

    [BFAC["Alliance"]]     = 900;
    [BFAC["Horde"]]     = 900;

    [BRAC["Human"]]    = 0;
    [BRAC["Dwarf"]]     = 0;
    [BRAC["Gnome"]]     = 0;
    [BRAC["Night Elf"]]     = 0;
    [BRAC["Draenei"]]    = 0;

    [BRAC["Orc"]]    = 0;
    [BRAC["Troll"]]    = 0;
    [BRAC["Undead"]]    = -900;
    [BRAC["Tauren"]]    = 0;
    [BRAC["Blood Elf"]]    = 0;

    ["Warrior"]    = 0;
    ["Rogue"]    = 0;
    ["Druid"]    = 0;
    ["Mage"]    = 0;
    ["Warlock"]    = 0;
    ["Paladin"]    = 0;
    ["Priest"]    = 0;
    ["Shaman"]    = 0;
    ["Hunter"]    = 0;
    ["Death Knight"]= -900;
};
---MOP Additions

Tongues.Language["Pandaren"] = {
	[1] = { "om","nom"},
	[2] = { "om nom", "nom om","nom nom", "om om",},
	[3] = { "om nom nom", "nom om om","nom nom nom", "om om om",},
	[4] = { "om nom nom nom", "nom om om om","nom nom nom nom", "om om om om",},
};


Tongues.Language["Pandaren"]["ignore"] = { "Stormstout"}

Tongues.Language["Pandaren"].Difficulty = {
	["default"] 	= 0;

	[BFAC["Alliance"]] 	= 0;
	[BFAC["Horde"]] 	= 0;

	[BRAC["Human"]]	= 100;
	[BRAC["Dwarf"]] 	= 100;
	[BRAC["Gnome"]] 	= 100;
	[BRAC["Night Elf"]] 	= 100;
	[BRAC["Draenei"]]	= 100;

	[BRAC["Orc"]]	=100;
	[BRAC["Troll"]]	= 100;
	[BRAC["Undead"]]	= 100;
	[BRAC["Tauren"]]	= 100;
	[BRAC["Blood Elf"]]	= 100;

	["Warrior"]	= 0;
	["Rogue"]	= 0;
	["Druid"]	= 0;
	["Mage"]	= 0;
	["Warlock"]	= 0;
	["Paladin"]	= 0;
	["Priest"]	= 0;
	["Shaman"]	= 0;
	["Hunter"]	= 0;
	["Death Knight"]= 0;
};

Tongues.Language["Stag"] = {
	[1] = { "baa","bleet","grrhn"},
};


Tongues.Language["Stag"].Difficulty = {
	["default"] 	= 1000;

	[BFAC["Alliance"]] 	= 0;
	[BFAC["Horde"]] 	= 0;

	[BRAC["Human"]]	= 100;
	[BRAC["Dwarf"]] 	= 100;
	[BRAC["Gnome"]] 	= 100;
	[BRAC["Night Elf"]] 	= 100;
	[BRAC["Draenei"]]	= 100;

	[BRAC["Orc"]]	=100;
	[BRAC["Troll"]]	= 100;
	[BRAC["Undead"]]	= 100;
	[BRAC["Tauren"]]	= 100;
	[BRAC["Blood Elf"]]	= 100;

	["Warrior"]	= 0;
	["Rogue"]	= 0;
	["Druid"]	= -1000;
	["Mage"]	= 0;
	["Warlock"]	= 0;
	["Paladin"]	= 0;
	["Priest"]	= 0;
	["Shaman"]	= 0;
	["Hunter"]	= 0;
	["Death Knight"]= 0;
};
---Be glad yall got this one...
Tongues.Language["Orca"] = {
	[1] = { "OOOOOOWWWOOOAOA"," *click* "},
	[2] = {"WOOOAOAAAAAAAOOOOOOOOOOO OOOOOOWWWOOOAO","*click*",},
};


Tongues.Language["Orca"].Difficulty = {
	["default"] 	= 1000;

	[BFAC["Alliance"]] 	= 0;
	[BFAC["Horde"]] 	= 0;

	[BRAC["Human"]]	= 100;
	[BRAC["Dwarf"]] 	= 100;
	[BRAC["Gnome"]] 	= 100;
	[BRAC["Night Elf"]] 	= 100;
	[BRAC["Draenei"]]	= 100;

	[BRAC["Orc"]]	=100;
	[BRAC["Troll"]]	= 100;
	[BRAC["Undead"]]	= 100;
	[BRAC["Tauren"]]	= 100;
	[BRAC["Blood Elf"]]	= 100;

	["Warrior"]	= 0;
	["Rogue"]	= 0;
	["Druid"]	= -1000;
	["Mage"]	= 0;
	["Warlock"]	= 0;
	["Paladin"]	= 0;
	["Priest"]	= 0;
	["Shaman"]	= 0;
	["Hunter"]	= 0;
	["Death Knight"]= 0;
};






