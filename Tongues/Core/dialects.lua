
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-- Applied order:
-----------------------------------------------------------------------------------------------
--	filters 	are whole word text to text conversions such as "cant" to "can't" (mainly for fixing chat to provide a standard interface for substitutions)
--	substitues 	are whole word text to text conversions such as "go" to "gwo"
--	exceptions 	are whole word text to phonetic transcriptions such as "have" to "H_AEV_"
--	rules 		are full message text to phonetic transcriptions such as "wr" to "R_"
--	remap 		is full message phonetic to text transcriptions such as "AE" to "a"
--	affects 	are full message text to text conversions such as "r" to "rr" (mostly for applying post language and providing custom speech affects like stutter)
-----------------------------------------------------------------------------------------------
Tongues.Dialect = {
	------------------------------------------------------------------
	-- None Dialect:						--
	--	Not quite "None", as filters outbound messages to be	--
	--	very basic roleplaying style.				--
	------------------------------------------------------------------
	["<None>"] = {
		["type"] = "All",
		["substitute"] = {
			[1] = {};
		};
	};
--------------------------------------------------------------------------
-- Player Race Dialects							--
--------------------------------------------------------------------------

["Gilnean"]={

["substitute"] = {

[1]={["talk"]="gab",
["talking"]="gabbin'",
["hey"] = "oi",
["hello"]="'ello",
--["friend"]="mate",
--["friends"]="mates",
["what"]="wot",
["whatever"] = "wotevah",
["isn't"]="ain't",
["some"] = "sum",
				["something"] = "sumthing",
				["somethings"] = "sumthings",
				["something's"] = "sumthing's",
				["do you"] = "you",
				["you do"] = "you",
				["you"] = "ya'",
				["your"] = "yer",
				["was"] = "wus",
				["you'd"] = "yah'd",
				["you had"] = "yah'd",
				["never"] = "niver",
				["not"] = "no'",
				["where"] = "wer",
},
};

["affects"] = {
			[1] = merge({
				Tongues.Affect["Wordcut"]["substitute"][1],
				--Tongues.Affect["Growl"]["substitute"][1],
			})


};

};

["Gilnaen-CocknyRhyme"]={

["substitute"] = {
[1]={
["talk"]="gab",
["talking"]="gabbin'",
["hey"] = "oi",
["hello"]="'ello",
["friend"]="mate",
["friends"]="mates",
["what"]="wot",
["whatever"] = "wotevah",
["isn't"]="ain't",
["some"] = "sum",
				["something"] = "sumthing",
				["somethings"] = "sumthings",
				["something's"] = "sumthing's",
				["do you"] = "you",
				["you do"] = "you",
				["you"] = "ya'",
				["your"] = "yer",
				["was"] = "wus",
				["you'd"] = "yah'd",
				["you had"] = "yah'd",
				["never"] = "niver",
				["not"] = "no'",
				["where"] = "wer",


["bad"]="sorry and sad",
["bitter"]="fritter",
["boat"]="nanny goat",
["bonkers"]="marbles",
["brace"]="airs",
["braces"]="airs and graces",
["cat"]="this and that",
["cell"]="flowery dell",
["class"]="bottle",
["clock"]="tick-tock",
["cook"]="babbling",
["cooking"]="babbling",
["crime"]="lemon and lime",
["dead"]="brown bread",
["daft"]="fore and aft",
["dice"]="rats",
["drink"]="tiddly",
["ears"]="sighs",
["fight"]="read and write",
["geezer"]="lemon squeezer",
["girl"]="ocean pearl",
["half"]="cow's calf",
["kid"]="teapot",
["kids"]="teapot lids",
["man"]="cove",
["money"]="bread and honey",
["mouth"]="sunny",
---planers cant slang..it works!

["air elemental"] = "Air Dancer",
["air element"] = "Air Dance",
["insane"] = "bally",
["shut it"] ="bar that",
["shut up"] = "bar that",
["betray"] = "bark",
["betrayed"] = "barked",
["chatter"] = "barrikin",
["fool"] = "berk",
--["mean"] = "biters",
["assassin"] = "crow feeder",
["secret"] = "dark",
["rumor"] = "howl",
["annoy"] = "thorn",
["annoying"] = "thorning",
--[[Copyright i could find for the following, not all words used."Copyright crap:  The author of this thingy retains full copyright of the material, while hereby granting full permission for it to be reprinted in any format whatsoever, with the provisos that his name be forever attached to it, the text of the document be forever unaltered, and if anyone manages to figure out how to make big bucks off of it, the above mentioned author wants a cut.  Oh, yes, and lest I forget, this notice  must remain attached to the main text.

  I. Marc Carlson
  IMC@VAX2.UTULSA.EDU
  26 January 1994"
==================================
"The Unquiet Grave, Cyril Connolly.
--------------------------------------------
http://www.tcp.co.uk:80/~gentloser/

All my own material is Copyright (c) by David Crowhurst 1995, 1996
All other material is Copyright (c) the original authors"--]]

["victem"]="plant",
["gentleman"] = "toff",
["evil man"] = "trasseno",
["woman"] = "bour",
["eye"] = "lamps",
["eyes"] = "lamps",
["gun"] = "irons",
["drunk"] = "kanurd",
["food"]="scran",
["cake"] = "shiver and shake",
["pants"] = "kecks",
["hat"] = "titfertat",
["beat up"] = "do down",
["pillow"] = "weeping willow",
["fuck"] = "bloody",
["blast"] = "bloody",
["get away"] = "nommus",
},

};

};

	------------------------------------------------------------------
	-- Dwarvish Dialect:						--
	--	This is highly based on the Scottish dialect 		--
	--	from Lore.  Since Dwarves tend to have a Scottish	--
	--	accent I have kept this largely as is, except in 	--
	--	areas where the word is too different from normal	--
	--	or the word can be different parts of speech and 	--
	--	therefore not really apply			 	--
	------------------------------------------------------------------
	["Dwarvish"] = {
		["substitute"] = {
			[1] = {	
				["see ya later"] = 	"watch your back",		
				["see you later"] = 	"watch your back",
				["whats up"]	=	"what's on your mind",
				["what's up"]	=	"what's on your mind",
				["so"]		=	"soo",
				["lake"]	=	"loch",
				["back"]	=	"beck",
				["yes"]		=	"aye",
				["a baby"]	=	"a wee one",
				["the baby"]	=	"the wee one",
				["little baby"]	=	"wee one",
				["child"]	=	"bairn",
				["kid"]		=	"bairn",
				["children"]	=	"bairn",
				["kids"]	=	"bairn",
				["moron"]	=	"bampot",
				["splendid"]	=	"barry",
				["drink"]	=	"bewy",
				["alcohol"]	=	"bewy",
				["drunk"]	=	"hammered",
				["mess"]	=	"burach",
				["river"]	=	"burn",
				["dance"]	=	"ceilidh",
				["cold"]	=	"cauld",
				["frost"]	=	"baltic",
				["do"]		=	"de",
				
				["understand"]	=	"ken",
				["thirst"]	=	"druth",
				["dog"]		=	"dug",
				["idiot"]	=	"idgit",
				["ass"]		=	"arse",
				["person"]	=	"gadgee",
				["broken"]	=	"gassed",
				["broke"]	=	"hosed",
	
				["don't"]	=	"dunnae",
				["do not"]	=	"dunnae",
				["cannot"]	=	"cannae",
				["can't"]	=	"cannae",
	
				["shit"]	=	"shite",
				["fucking"]	=	"bloody",
				["fuck"]	=	"bloody hell",
				["fuckin'"]	=	"bloody",
				["fuckin"]	=	"bloody",
				["fuckn"]	=	"bloody",
				["church"]	=	"kirk",
				["crazy"]	=	"barmy",
				["a crazy"]	=	"a loon",
				["the crazy"]	=	"the loon",
				["male"]	=	"manny",
				["female"]	=	"biddy",
				["woman"]	=	"biddy",
				["man"]		=	"manny",
				["smelly"]	=	"minky",
				["stinky"]	=	"minky",
				["not"]		=	"nae",
				["oh"]		=	"och",
				["cheer"]	=	"slange",
				["cheers"]	=	"slange",
				["small"]	=	"tad",
				["wife"]	=	"wifey",
				["and"]		=	"an'",
				["old"]		=	"ol'",
				["newbie"]	=	"youngin'",
				["newb"]	=	"youngin'",
				["noob"]	=	"choob'",
				["n00b"]	=	"choob'",
				["you"]		=	"ye",
				["mom"]		=	"mum",
				["mother"]	=	"mammy",
				
				["night"]	=	"nicht",
				["a little"]	=	"a wee bit",
				["goodbye"]	=	"be good",
				["good bye"]	=	"be good",
			};
			[2] = {
				["you"]		=	"ye",
				["your"]	=	"yer",
				["bye"]		=	"keep your feet on the ground",
			};
		};
		["affects"] = {
			[1] = merge({
				{
					["([oO])([uUwW])"] 	= function(a,b)
						if b == "u" or b=="w" then
							b = "o"
						elseif b == "U" or b=="W" then
							b = "O"
						end
						return a .. b
					end;
				},
			});
		};
	};
	
	
	["Dwarvish(Heavyish)"] = {
		["substitute"] = {
			[1] = {	
				["see ya later"] = 	"watch your back",		
				["see you later"] = 	"watch your back",
				["whats up"]	=	"what's on your mind",
				["what's up"]	=	"what's on your mind",
				["so"]		=	"soo",
				["lake"]	=	"loch",
				["back"]	=	"beck",
				["yes"]		=	"aye",
				["a baby"]	=	"a wee one",
				["the baby"]	=	"the wee one",
				["little baby"]	=	"wee one",
				["child"]	=	"bairn",
				["kid"]		=	"bairn",
				["children"]	=	"bairn",
				["kids"]	=	"bairn",
				["moron"]	=	"bampot",
				["splendid"]	=	"barry",
				["drink"]	=	"bewy",
				["alcohol"]	=	"bewy",
				["drunk"]	=	"hammered",
				["mess"]	=	"burach",
				["river"]	=	"burn",
				["dance"]	=	"ceilidh",
				["cold"]	=	"cauld",
				["frost"]	=	"baltic",
				["do"]		=	"de",
				
				["understand"]	=	"ken",
				["thirst"]	=	"druth",
				["dog"]		=	"dug",
				["idiot"]	=	"idgit",
				["ass"]		=	"arse",
				["person"]	=	"gadgee",
				["broken"]	=	"gassed",
				["broke"]	=	"hosed",
	
				["don't"]	=	"dunnae",
				["do not"]	=	"dunnae",
				["cannot"]	=	"cannae",
				["can't"]	=	"cannae",
	
				["shit"]	=	"shite",
				["fucking"]	=	"bloody",
				["fuck"]	=	"bloody hell",
				["fuckin'"]	=	"bloody",
				["fuckin"]	=	"bloody",
				["fuckn"]	=	"bloody",
				["church"]	=	"kirk",
				["crazy"]	=	"barmy",
				["a crazy"]	=	"a loon",
				["the crazy"]	=	"the loon",
				["male"]	=	"manny",
				["female"]	=	"biddy",
				["woman"]	=	"biddy",
				["man"]		=	"manny",
				["smelly"]	=	"minky",
				["stinky"]	=	"minky",
				["not"]		=	"nae",
				["oh"]		=	"och",
				["cheer"]	=	"slange",
				["cheers"]	=	"slange",
				["small"]	=	"tad",
				["wife"]	=	"wifey",
				["and"]		=	"an'",
				["old"]		=	"ol'",
				["newbie"]	=	"youngin'",
				["newb"]	=	"youngin'",
				["noob"]	=	"choob'",
				["n00b"]	=	"choob'",
				["you"]		=	"ye",
				["mom"]		=	"mum",
				["mother"]	=	"mammy",
				
				["night"]	=	"nicht",
				["a little"]	=	"a wee bit",
				["goodbye"]	=	"be good",
				["good bye"]	=	"be good",
				
				["no"] = "nae",
				["isn't"] = "ain't",
				---corutsy http://www.delving.com/langmain.html (dosen't work currently)
				["about"] = "aboot",
				["after"] = "efter",
				["are"] = "ur",
				["around"]="'roon",
				["before"]="'fore",
				["between"]="a'tween",
				["can"]="kin",
				["can't"] = "cannae",
				["couldn't"]= "couldnae",
				["dead"]="deid",
				["gone"]="guan",
				["was"]="wer",
				["understand"]="understaun",
				
			};
			[2] = {
				["you"]		=	"ye",
				["your"]	=	"yer",
				["bye"]		=	"keep your feet on the ground",
			};
		};
		["affects"] = {
			[1] = merge({
				{
					["([oO])([uUwW])"] 	= function(a,b)
						if b == "u" or b=="w" then
							b = "o"
						elseif b == "U" or b=="W" then
							b = "O"
						end
						return a .. b
					end;
				},
			});
		};
	};
	
	
	------------------------------------------------------------------
	-- Draenai Dialect:						--
	--	My Draenai Dialect, which is inspired from the	--
	--	Lore Romanian Dialect, 					--
	------------------------------------------------------------------
	["Draenei"] = {
		["substitute"] = {
			[1] = {
					["bye"]	=	"Good health!  Long life!",
					["goodbye"]	=	"Remain vigilant.",
					["good bye"]	=	"Do not lose faith.",
					["hello"]	=	"Good fortune!",
					["hi"]	=	"Arkanon Por'os.",
					["greetings"]	=	"Blessings upon you!",

			};
		};
		["affects"] = {
			[1] = merge({
				{
					["w[hH]?"] 		= "v",
					["W[hH]?"] 		= "V",
					["(%A)h(%a)"] 		= "%1kh%2",
					["(%A)H(%a)"] 		= "%1Kh%2",
					--["^h(%a)"] 		= "kh%1",
					--["^H(%a)"] 		= "Kh%1",
					["(%a)([nN])g(%A)"] 	= "%1%2k%3",
					["(%a)([nN])G(%A)"] 	= "%1%2K%3",
					["(%a)([nN])g$"] 	= "%1%2k",
					["(%a)([nN])G$"]	= "%1%2K",
					["c"]			= "k",
					["C"]			= "K",
					["o"]			= "u",
					["O"]			= "U",
				},
				Tongues.Affect["Growl"]["substitute"][1]	
			});
		};
	};
	
	
	["Draenei(Light)"] = {
		["substitute"] = {
			[1] = {
					["bye"]	=	"Good health!  Long life!",
					["goodbye"]	=	"Remain vigilant.",
					["good bye"]	=	"Do not lose faith.",
					["hello"]	=	"Good fortune!",
					["hi"]	=	"Arkanon Por'os.",
					["greetings"]	=	"Blessings upon you!",

			};
		};
		["affects"] = {
			[1] = merge({
				{
					["w[hH]?"] 		= "v",
					["W[hH]?"] 		= "V",
					["([t][hH])"]		= "z",
					["([T][hH])"]		= "Z",
					["(%A)h(%a)"] 		= "%1kh%2",
					["(%A)H(%a)"] 		= "%1Kh%2",
					["(%a)([nN])g(%A)"] 	= "%1%2k%3",
					["(%a)([nN])G(%A)"] 	= "%1%2K%3",
					["(%a)([nN])g$"] 	= "%1%2k",
					["(%a)([nN])G$"]	= "%1%2K",
					--["c"]			= "k",
					--["C"]			= "K",
					["o"]			= "u",
					["O"]			= "U",
					--["i"]			= "ee",
					--["I"]			= "Ee",
				},
				Tongues.Affect["Growl"]["substitute"][1]	
			});
		};
	};
	
	["Draenei(Very Light)"] = {
		["substitute"] = {
			[1] = {
					["bye"]	=	"Good health!  Long life!",
					["goodbye"]	=	"Remain vigilant.",
					["good bye"]	=	"Do not lose faith.",
					["hello"]	=	"Good fortune!",
					["hi"]	=	"Arkanon Por'os.",
					["greetings"]	=	"Blessings upon you!",

			};
		};
		["affects"] = {
			[1] = merge({
				{
					  ["wh"]                 = "vh",
                      ["Wh"]                 = "Vh",
                      ["wo"]                 = "vh",
                      ["Wo"]                 = "Vh",
                      ["wi"]                 = "vh",
                      ["Wi"]                 = "Vh",
                      ["th"]                = "z",
                      ["Th"]                = "Z",
                      ["it"]                = "eet",
                      ["It"]                = "Eet",
                      ["ng"]                = "nk",
				},
				Tongues.Affect["Growl"]["substitute"][1]	
			});
		};
	};
	
	["Draenei(Heavy)"] = {
		["substitute"] = {
			[1] = {
					["bye"]	=	"Good health!  Long life!",
					["goodbye"]	=	"Remain vigilant.",
					["good bye"]	=	"Do not lose faith.",
					["hello"]	=	"Good fortune!",
					["hi"]	=	"Arkanon Por'os.",
					["greetings"]	=	"Blessings upon you!",

			};
		};
		["affects"] = {
			[1] = merge({
				{
					["w[hH]?"] 		= "v",
					["W[hH]?"] 		= "V",
					["([t][hH])"]		= "z",
					["([T][hH])"]		= "Z",
					["(%a)([nN])g(%A)"] 	= "%1%2k%3",
					["(%a)([nN])G(%A)"] 	= "%1%2K%3",
					["(%a)([nN])g$"] 	= "%1%2k",
					["(%a)([nN])G$"]	= "%1%2K",
					["c"]			= "k",
					["C"]			= "K",
					["u"]			= "oo",
					["U"]			= "Oo",
					["i"]			= "ee",
					["I"]			= "Ee",
				},
				Tongues.Affect["Growl"]["substitute"][1]	
			});
		};
	};
	------------------------------------------------------------------
	-- Thalassian Dialect:						--
	-- EXPERIMENTAL!						--
	------------------------------------------------------------------
	["Thalassian"] = {
		["substitute"] = {
			[1] = {
				["safe travels"] = "al diel shala",
				["goodbye"] = "al diel shala",
				--["should"] = "shall",
				["good bye"] = "bye",
				["the sun"] = "belore",
				["by the light of"] = "anar'alah",
				["speak your business"] = "anaria shola",
				["the sun guides us"] = "anu belore dela'na",
				["traveler"]	= "malanore",
				["traveller"]	= "malanore",
				["travellers"]	= "malanoran",
				["travelers"]	= "malanoran",
				["greetings"] = "bal'a dash",
				["hi there"] = "hi",
				["hello there"] = "hello",
				["taste the chill of true death"] = "bash'a no falor talah",
				["how fare you"] = "doral ana'diel",
				["how are you"] = "doral ana'diel",
				["how're you"] = "doral ana'diel",
				["little rat"] = "kim'jael",
				["keeper of secrets"] = "medivh",
				["high elves"] = "quel'dorei",
				["high kingdom"] = "quel'thalas",
				["peaceful"] = "ronae",
				["justice for our people"] = "selama ashal'anore",
				["they're breaking through"] = "shindu fallah na",
				["farewell"] = "shorel'aran",
				["blood elves"] = "sin'dorei",
				["bless you"] = "sinu a'manore",
				["blessings upon you"] = "sinu a'manore",
				["blessings be upon you"] = "sinu a'manore",
				["help me forget"] = "vendel'o eranu",
			},
			[2] = {
				["hi"] = "bal'a dash",
				["hello"] = "bal'a dash",
				["bye"] = "al diel shala",
			};
		};
	};
	------------------------------------------------------------------
	-- DarnDarnassian Dialect:						--
	-- EXPERIMENTAL!						--
	------------------------------------------------------------------
	["Darnassian"] = {
		["substitute"] = {
			[1] = {
				["good bye"] = "bye",
				["goodbye"] = "bye",

				["keeper of secrets"] = "medivh",
				["high kingdom"] = "quel'thalas",

				["high elves"] = "quel'dorei",
				["night elves"] = "kaldorei",
				["blood elves"] = "sin'dorei",

				["the ancients"] = "delar",
				["ancients"] = "delar",
				["ancient one"] = "delar",
				["ancient ones"] = "delar",
				["ancient ones"] = "delar",
				
				["papa"] = "an'da",
				["on my honor"] = "Az'thero'dalah'dor",
                ["what is it"] = "Ashra thoraman",
                ["who goes there"] = "Fandu'dath'belore",
                ["who's there"] = "Fandu'dath'belore",
                ["whos there"] = "Fandu'dath'belore",
                ["who is there"] = "Fandu'dath'belore",
                ["do it"] = "Ash Karath",
                ["farewell"] = "Enshu fallah na",

				["elune be with you"] = "elune'adore",

				["moon"] = "elune",

				["greetings"] 	= "alah darnana dor",
				["hello there"]	= "ishnu'dal'dieb",
				["hi there"]	= "ishnu'dal'dieb",
				["hello"] 	= "ishnu'alah",
				["hi"] 		= "ishnu'alah",
			},
			[2] = {
				["bye"] = "ande'thoras'ethil",
			};
		};
	};
	------------------------------------------------------------------
	-- Gnomish Dialect:						--
	--	In my Gnomish Dialect Gnomes tend to like using		--
	--	gadget names, underplay problems, and see their		--
	--	height as 'normal' (e.g. World Enlarger).		--
	--	I believe this fits with Blizzards conception.		--
	------------------------------------------------------------------
	["Gnomish"] = {
		["substitute"] = {
			[1] = {
				["hello there"] = "hi",
				["hello"] 	= "hi",
				["howdy"] 	= "hi",
				["goodbye"]	= "bye",
				["good bye"]	= "bye",
				["greetings"]	= "salutations",
				["small"]	= "adverage",
				["a small"]	= "an adverage",
				["a little"]	= "an adverage",
				["little"]	= "adverage",
				["smaller"]	= "adverager",
				["a smaller"]	= "an adverager",
				["a smallest"]	= "an adveragest",
				["smallest"]	= "adveragest",
				["big"]		= "huge",
				["bigger"]	= "huger",
				["biggest"]	= "hugest",
				["large"]	= "huge",
				["larger"]	= "huger",
				["largest"]	= "hugest",
				["giant"]	= "gigantor",
				["gigantic"]	= "gigantornormus",
				["tiny"]	= "teeny",
				["problem"]	= "opportunity",
				["problem with"]= "opportunity around",
				["broken"]	= "fixable",
				["lost"]	= "exploring",
				["trinket"]	= "gadget",
				["tool"]	= "Toolator",
				["copy"]	= "Zerocks",
				["email"]	= "magic mail",
				["e-mail"]	= "magic mail",
				["smurf"]	= "blue gnome",
				["smurfy"]	= "gnomey",
			};
			[2]=	{
				["bye"]	= "bye now";
				["hi"]	= "hi there";
			};
		};
	};
	------------------------------------------------------------------
	-- Troll Dialect:						--
	--	Since Troll dialect seems to be either Jamaican		--
	--	or Cuban (at least for some trolls), I have made	--
	--	some mutations that should simulate some of the		--
	--	accent.  A very phonetic heavy one is called Tuska	--
	--	which is loosely based on rules that a guild called	--
	--	The Tuska Tribe uses					--
	------------------------------------------------------------------
	["Troll"] = {
		["substitute"] = {
			[1] = {
				["am"]		= "be",
				["it"]		= "et",
				["you"]		= "ya",
				["that"]	= "dat",
				["these"]	= "dese",
				["those"]	= "dems",
				["then"]	= "den",
				["than"]	= "dan",
				["them"]	= "dems",
				["thems"]	= "dems",
				["this"]	= "dis",
				["got to"]  	= "gatta",
				["have to"]  	= "hafta",
				["have"]  	= "haf",
				["kind of"]  	= "kinda",
				["got"]  	= "gat",
				["man"] 	= "mon",
				["human"] 	= "humon",
				["woman"] 	= "womon",
				["who"] 	= "hoo",
				--["world"] 	= "worlt",
				--["worlds"] 	= "worlts",
				--["world's"] 	= "worlt's",
			};
		},
		["affects"] = {
			[1] = {
				["([wW])[hH]"] = "%1",
				["(%A)[hH]"] = "%1'",
				["^[hH]"] = "'",
				["([tT])[hH]"] = "%1",
			},
		};
	};
	["Troll, Heavy"] = {
		["substitute"] = {
			[1] = {
				["maybe"]	= "mebbe",
				["yes"]		= "yah",
				["one"]		= "wun",
				["am"]		= "be",
				["it"]		= "et",
				["is"]		= "is",
				["are"]		= "be",
				["you"]		= "yu",
				["does"]	= "do",
				["that"]	= "dat",
				["these"]	= "dese",
				["there"]	= "dere",
				["they"]	= "dey",
				["their"]	= "deir",
				["theirs"]	= "deirs",
				["the"]		= "da",
				["those"]	= "dems",
				["then"]	= "den",
				["than"]	= "dan",
				["them"]	= "dems",
				["thems"]	= "dems",
				["this"]	= "dis",
				["got to"]  	= "gatta",
				["have to"]  	= "hafta",
				["have"]  	= "haf",
				["kind of"]  	= "kinda",
				["got"]  	= "gat",
				["going"]	= "goin'",
				["ok"]		= "okay",
				["man"] 	= "mon",
				["human"] 	= "humon",
				["woman"] 	= "womon",
				["the magic"] 	= "da voodoo",
				["magic"] 	= "juju",
				["who"] 	= "hoo",
			};
			[2] = {
				["okay"] = "okey dokey",
			}
		},
		["affects"] = {
			[1] = merge({
				{
					["%f[%a'][hH]"] = "'",
					["([tT])[hH]"] = "t",
					["([T])[hH]"] = "T",
					["([er])"] = "a",
					["([sS])([tT])([rR])"] = function (a,b,c) 
						if a == "s" then
							a = "suh"
						else
							a = "S"
							if string.upper(b) == b then
								a = a .. "UH"
							else
								a = a .. "uh"
							end;
						end
	
						if b == "t" then
							b = "c"
						else
							c = "C"
						end;

						if c == "r" then
							c = "hr"
						else
							c = "HR"
						end
	                     
						 						 
						return a .. b .. c
					end;
					["(%f[%a'%-][%a'%-]+)([eEaA])[rR]%f[^%a'%-]"] = function(a,b)
						if string.upper(a) == a then
							a = string.upper(a)
						else 
							a = string.lower(a)
						end;
						return a .. b
					end
				},
				Tongues.Affect["WH Vocalization"]["substitute"][1],
				--Tongues.Affect["L Vocalization"]["substitute"][1],
				Tongues.Affect["Wordcut"]["substitute"][1]
			});
		};
	};
	------------------------------------------------------------------
	-- Tauren Dialect:						--
	--	Since Taurens are based on native American tribes from	--
	--	the mid-west I have made the Tauren dialect reflect	--
	--	the nature based language (sometimes sterotypically).	--
	--	Vowel mutations based on real native American tribes	--
	--	will be added later after I do more research.		--
	------------------------------------------------------------------
	["Taurahe"] = {
		["substitute"] = {
			[1] = {
				["hi"]		= "how goes",
				["hello"]	= "greetings",
				["ghost"]	= "spirit",
				["days"]  	= "moons",
				["month"]  	= "moon cycle",
				["months"]  	= "moon cycles",
				["year"]  	= "sun cycle",
				["years"]  	= "sun cycles",
				["can't"] 	= "cannot",
				["don't"] 	= "do not",
				["won't"] 	= "will not",
				["isn't"] 	= "not",
				["wouldn't"] 	= "would not",
				["couldn't"] 	= "could not",
				["shouldn't"] 	= "should not",
				["haven't"] 	= "have not",
				["hadn't"] 	= "had not",
			};
		};
	};
	------------------------------------------------------------------
	-- Orcish Dialect:						--
	--	Orcs are highly based on the D&D Orcs, which are in turn--
	--	based on Tolkien's Orcs. Since Tolkien developed an Orc	--
	--	language which is somewhat applicable (at least with the--
	--	sounds being consistant with the Warcraft orc voice,)	--
	--	My Orcish dialect has hard, gutteral sounds.		--
	------------------------------------------------------------------
	["Orcish"] = {
		["substitute"] = {
			[1] = {
				["heh"]		= "kek",
				["hah"]		= "kek",
				["hahaha"]		= "kekekek",
				["hahahah"]		= "kekekek",
			};
		};
		["affects"] = {
			[1] = merge({
				{
					["([^cChH])[cC]([^cChH])"] = "%1k%2",
					["([^cC])[cC]$"] = "%1k",
					["([cC])([cC])"] = "ks",
					["^[cC]([^cChH])"] = "k%1",
	

					["([oO])([rR])"] = "%1%1%2",
				},
				Tongues.Affect["Growl"]["substitute"][1]	
			});
		};
	};
	------------------------------------------------------------------
	-- Gutterspeak Dialect:						--
	-- EXPERIMENTAL!						--
	------------------------------------------------------------------
	["Gutterspeak"] = {
		["substitute"] = {
		};
		["affects"] = {
			[1] = merge({
				{
					["([w])[hH]?"] = "v",
					["([W])[hH]?"] = "V",
				},
				Tongues.Affect["Hiss"]["substitute"][1]	
			});
		};
	};
--------------------------------------------------------------------------
-- Non-Player Race Dialects						--
--------------------------------------------------------------------------
	------------------------------------------------------------------
	-- Goblin Dialect:						--
	--	Since Goblins tend to like explosions -- the bigger the --
	--	better, I have made the Goblin dialect consist of 	--
	--	'shouting' anything that is related to explosions or 	--
	--	or being big in size.					--
	--	I think this mirrors how they are portrayed in the	--
	--	Warcraft series.					--
	------------------------------------------------------------------
	["Goblin"] = {
		["substitute"] = {
			[1] = {
				["boom"] = "BOOM",
				["bang"] ="BANG",
				["kaboom"] = "KABOOM",
				["fire"] = "FIRE",
				["blast"] = "BLAST",
				["bomb"] = "BOMB",
				["goblin"] = "GOBLIN",
				["blow up"] = "BLOW UP",
				["dynamite"] = "DYNAMITE",
				["mortar"] = "MORTAR",
				["big"] = "BIG",
				["huge"] = "HUGE",
				["massive"] = "MASSIVE",
				["giant"] = "GIANT",
				["gigantic"] = "GIGANTIC",
				["enormous"] = "ENORMOUS",
				["explode"] = "EXPLODE",
				["explosive"] = "EXPLOSIVE",
				["explosive"] = "EXPLOSIVES",
				["explosion"] = "EXPLOSION",
				["gun"] = "GUN",
				["guns"] = "GUNS",
			};
		};
	};
	
	
	------------------------------------------------------------------
	---Heavy Feral
	--This is simply a mix of Hiss and growl Affects
	------------------------------------------------------------------
["Heavy Feral"] = {
["affects"] = {
[1] = merge({
Tongues.Affect["Hiss"]["substitute"][1],
Tongues.Affect["Growl"]["substitute"][1],
});
};
};
	------------------------------------------------------------------
	-- Nerglish Dialect:						--
	--	According to warcraft lore, this is the Murloc/Makura 	--
	--	dialect.  Since there are several places the sounds for --
	--	Murlocs can be heard, and one on Bloodmist Isle that 	--
	--	gives and example of Nerglish, I have modeled the 	--
	--	dialect to squish things together. 			--
	------------------------------------------------------------------
	["Nerglish"] = {
		["substitute"] = {
			[1] = {
			};
		};
		["affects"] = {
			[1] = merge({
				{
					["[sS]"]		= function(a)
						if a == "S" then
							return "Z"
						elseif a == "s" then
							return "z"
						end
					end;
					["([^SsTtWw])([h])"]	= "%1gh",
					["([^SsTtWw])([H])"]	= "%1Gh",
					["([t][hH])"]		= "d",
					["([T][hH])"]		= "D",
					["([w][hH]?)"]		= "l",
					["([W][hH]?)"]		= "L",
					["[uU][bB]"]		= "urb",
					["[b]+"]		= "b",
					["[B][bB]"]		= "B",
					["[b][lL]"]		= "bul",
					["[B][lL]"]		= "Bul",
					["f"]			= "v",
					["F"]			= "V",
					["v"]			= "b",
					["V"]			= "B",
					["c[lL]"]		= "gl",
					["C[lL]"]		= "Gl",
					["^([aAeEiIoOuUyY])"] 	= function(a)
						return "g" .. string.lower(a)
					end;
					["(%s)([aAeEiIoOuUyY])"] = function(a,b)
						return a .. "g" .. string.lower(b)
					end;
				},
				Tongues.Affect["Ramble"]["substitute"][1],	
			});
		};

	};

	------------------------------------------------------------------
	-- Low Common Dialect:						--
	--	Speek like Oger.  Speek like Kobold! Say 'Wat you want!'--
	--	Oger talk like dis. Sum little peepel talk like dis too!--
	------------------------------------------------------------------
	["Common, Low"] = {
		["substitute"] = {
			[1] = {
				["some"] = "sum",
				["something"] = "sumthing",
				["somethings"] = "sumthings",
				["something's"] = "sumthing's",
				["do you"] = "you",
				["you do"] = "you",
				["what"] = "wot",
				["whatever"] = "wotevah",
				["you"] = "ya'",
				["your"] = "yer",
				["woman"] = "lass",
				["man"] = "lad",
				["was"] = "wus",
				["you'd"] = "yah'd",
				["you had"] = "yah'd",
				["never"] = "niver",
				["not"] = "no'",
				["where"] = "wer",
				
				
			};
		};
	};

--[[
	------------------------------------------------------------------
	-- Ravenspeak Dialect:						--
	--	Based on the Arakkoa Ravenspeech language.  Alot of 	--
	--	guesswork will be needed as to what a bird would sound	--
	--	like speaking 'Common'					--
	------------------------------------------------------------------
	["Ravenspeak"] = {
		["substitute"] = {
			[1] = {};
		};
	};
	------------------------------------------------------------------
	-- Ursine Dialect:						--
	--	Used by the Furbolgs					--
	------------------------------------------------------------------
	["Ursine"] = {
		["substitute"] = {
			[1] = {};
		};
	};

	------------------------------------------------------------------
	-- Krenkese Dialect:						--
	--	Used by the Centaurs					--
	------------------------------------------------------------------
	["Krenkese"] = {
		["substitute"] = {
			[1] = {};
		};
	};

	------------------------------------------------------------------
	-- Nazja Dialect:						--
	--	Used by the Naga					--
	------------------------------------------------------------------
	["Nazja"] = {
		["substitute"] = {
			[1] = {};
		};
	};

	------------------------------------------------------------------
	-- Titan Dialect:						--
	--	Used by the Titans					--
	------------------------------------------------------------------
	["Titan"] = {
		["substitute"] = {
			[1] = {};
		};
	};

	------------------------------------------------------------------
	-- Aqir Dialect:						--
	--	Used by the Aqir (northern insect people)		--
	------------------------------------------------------------------
	["Aqir"] = {
		["substitute"] = {
			[1] = {};
		};
	};

	------------------------------------------------------------------
	-- Qiraji Dialect:						--
	--	Used by the Qiraji (southern insect people)		--
	------------------------------------------------------------------
	["Qiraji"] = {
		["substitute"] = {
			[1] = {};
		};
	};

	------------------------------------------------------------------
	-- Pandaren Dialect:						--
	--	Used by the Pandaren					--
	------------------------------------------------------------------
	["Pandaren"] = {
		["substitute"] = {
			[1] = {};
		};
	};

	------------------------------------------------------------------
	-- Eredun Dialect:						--
	--	Used by the Satyrs and other Demons			--
	------------------------------------------------------------------
	["Eredun"] = {
		["substitute"] = {
			[1] = {};
		};
	};

	------------------------------------------------------------------
	-- Nerubian Dialect:						--
	--	Used by the Nerubians (crypt lords)			--
	------------------------------------------------------------------
	["Nerubian"] = {
		["substitute"] = {
			[1] = {};
		};
	};

	------------------------------------------------------------------
	-- Taunka Dialect:						--
	--	Used by the Taunka of Northrend				--
	------------------------------------------------------------------
	["Taunka"] = {
		["substitute"] = {
			[1] = {};
		};
	};

	------------------------------------------------------------------
	-- Gnoll Dialect:						--
	--	Used by the Gnolls					--
	------------------------------------------------------------------
	["Gnoll"] = {
		["substitute"] = {
			[1] = {};
		};
	};

	------------------------------------------------------------------
	-- Tuskarr Dialect:						--
	--	Used by the Tuskarr					--
	------------------------------------------------------------------
	["Tuskarr"] = {
		["substitute"] = {
			[1] = {};
		};
	};
]]
--------------------------------------------------------------------------
-- Player Class Dialects						--
--------------------------------------------------------------------------
	------------------------------------------------------------------
	-- Paladin Dialect:						--
	--	Paladins are shown to have a connection to 'The Light'	--
	--	They have been represented as Holy and have some British--
	--	and/or biblical words (technically the use of Thou,Thy	--
	--	Thine, Thee represents a Personal God, since these are 	--
	--	singular/informal, but don't know that You, Your, Yours,--
	--	You are plural/formal and so alot of confusion exists.)	--
	--	I have tried to use British spellings and some basic	--
	--	2nd person singular noun/verb combinations.  This 	--
	--	process is very complicated, and it isn't really 	--
	--	to represent all possible verbs.			--
	------------------------------------------------------------------
--[[
	["Paladin"] = {
		-- Try to separate out the 2nd Person Singular pronouns (thou, thee, thy, thine)
		-- from the 2nd Person Plural pronouns (you, you, your, yours)
		["substitute"] = {
			[1] = {
				["you are"]	= "thou art",
				["you were"]	= "thou werest",
				["you have"]	= "thou hast",
				["you do"]	= "thou dost",
	
				["are thou"]	= "art thou",
				["are you"]	= "art thou",
				["were thou"]	= "werst thou",
				["were thou"]	= "werst thou",
				["have thou"]	= "hast thou",
				["have you"]	= "hast thou",
				["do you"]	= "dost thou",
				["do thou"]	= "dost thou",
	
				["from you"]	= "from thee",
				["to you"]	= "to thee",
				["on you"]	= "on thee",
				["off you"]	= "off thee",
				["in you"]	= "in thee",
				["out you"]	= "out thee",
				["into you"]	= "into thee",
				["through you"]	= "through thee",
				["about you"]   	= "about thee",
				["around you"]	= "around thee",
				["above you"]   	= "above thee",
				["below you"]   	= "below thee",
				["at you"]   	= "at thee",
				["beyond you"]	= "beyond thee",
				["behind you"]	= "behind thee",
				["before you"]	= "before thee",
			},
			[2] = {
				["it is"]	= "'tis",
				["its"]		= "'tis",
				["it's"]	= "'tis",
				["until"]	= "'til",
				["til"]		= "til",
				["i will"]	= "I shall",
				["i'll"]	= "I shall",

				["shit"]	= "'zounds",
				["o shit"]	= "'zounds",
				["oh shit"]	= "'zounds",

				["color"] 	= "colour",
				["honor"] 	= "honour",
				["valor"] 	= "valour",
			},
			[3] = {
				["yall"]  	= "you",
				["y'all"] 	= "you",
				["you all"] 	= "you",
				["yous"] 	= "you",
				["yous guys"] 	= "you",
				["you guys"] 	= "you",
				["you ones"] 	= "you",
				["yuns"] 	= "you",
				["y'uns"] 	= "you",
			};
		};
	};
	------------------------------------------------------------------
	-- Death Knight Dialect:					--
	------------------------------------------------------------------
	["Death Knight"] = {
		["substitute"] = {
			[1] = {
				["you are"]	= "thou art",
				["you were"]	= "thou werest",
				["you have"]	= "thou hast",
				["you do"]	= "thou dost",
	
				["are thou"]	= "art thou",
				["are you"]	= "art thou",
				["were thou"]	= "werst thou",
				["were thou"]	= "werst thou",
				["have thou"]	= "hast thou",
				["have you"]	= "hast thou",
				["do you"]	= "dost thou",
				["do thou"]	= "dost thou",
	
				["from you"]	= "from thee",
				["to you"]	= "to thee",
				["on you"]	= "on thee",
				["off you"]	= "off thee",
				["in you"]	= "in thee",
				["out you"]	= "out thee",
				["into you"]	= "into thee",
				["through you"]	= "through thee",
				["about you"]   	= "about thee",
				["around you"]	= "around thee",
				["above you"]   	= "above thee",
				["below you"]   	= "below thee",
				["at you"]   	= "at thee",
				["beyond you"]	= "beyond thee",
				["behind you"]	= "behind thee",
				["before you"]	= "before thee",
			},
			[2] = {
				["it is"]	= "'tis",
				["its"]		= "'tis",
				["it's"]	= "'tis",
				["until"]	= "'til",
				["til"]		= "til",
				["i will"]	= "I shall",
				["i'll"]	= "I shall",

				["shit"]	= "'zounds",
				["o shit"]	= "'zounds",
				["oh shit"]	= "'zounds",

				["color"] 	= "colour",
				["honor"] 	= "honour",
				["valor"] 	= "valour",
			},
			[3] = {
				["yall"]  	= "you",
				["y'all"] 	= "you",
				["you all"] 	= "you",
				["yous"] 	= "you",
				["yous guys"] 	= "you",
				["you guys"] 	= "you",
				["you ones"] 	= "you",
				["yuns"] 	= "you",
				["y'uns"] 	= "you",
			};
		};

		["affects"] = {
			[1] = merge({
				Tongues.Affect["Hiss"]["substitute"][1],
				Tongues.Affect["Growl"]["substitute"][1],
			})
		};
	};
	------------------------------------------------------------------
	-- Priest Dialect:						--
	------------------------------------------------------------------
	["Priest"] = {
		["substitute"] = {
			[1] = {};
		};
	};
	------------------------------------------------------------------
	-- Warlock Dialect:						--
	------------------------------------------------------------------
	["Warlock"] = {
		["substitute"] = {
			[1] = {};
		};
	};
	------------------------------------------------------------------
	-- Druid Dialect:						--
	------------------------------------------------------------------
	["Druid"] = {
		["substitute"] = {
			[1] = {};
		};
	};
	------------------------------------------------------------------
	-- Shaman Dialect:						--
	------------------------------------------------------------------
	["Shaman"] = {
		["substitute"] = {
			[1] = {};
		};
	};	
	------------------------------------------------------------------
	-- Mage Dialect:						--
	------------------------------------------------------------------
	["Mage"] = {
		["substitute"] = {
			[1] = {};
		};
	};
	------------------------------------------------------------------
	-- Hunter Dialect:						--
	------------------------------------------------------------------
	["Hunter"] = {
		["substitute"] = {
			[1] = {};
		};
	};
	------------------------------------------------------------------
	-- Warrior Dialect:						--
	------------------------------------------------------------------
	["Warrior"] = {
		["substitute"] = {
			[1] = {
				["hello"] 	= "'ello",
				["think"] 	= "fink",
				["something"] 	= "somefing",
				["somethings"] 	= "somefings",
				["something's"] = "somefing's",
				["this"] = 	"dis",
				["these"] = 	"dese",
				["those"] = 	"dose",
				["there"] = 	"dere",
				["hi"] =	"oi",
				["hey"] =	"oi",
				["have to"] = 	"hafta",
				["have"] = 	"haf",
				["don't"] = 	"dun",
				["my"] = 	"me",
				["friend"] =	"mate",
				["friends"] =   "mates",
			};
		};
	};
	------------------------------------------------------------------
	-- Rogue Dialect:						--
	------------------------------------------------------------------
	["Rogue"] = {
		["substitute"] = {
			[1] = {
				["think"] 	= "fink",
				["something"] 	= "somefing",
				["somethings"] 	= "somefings",
				["something's"] = "somefing's",
				["nothing's"] 	= "nuffing's",
				["nothings"] 	= "nuffings",
				["nothing"] 	= "nuffing",
				["thing"] 	= "fing",
				["things"] 	= "fings",
				["thing's"] 	= "fing's",
				["this"] 	= "dis",
				["these"] 	= "dese",
				["there"] 	= "dere",
				["the"]		= "da",
				["hi"] 		= "oi",
				["hey"] 	= "oi",
				["have"] 	= "haf",
				["don't"] 	= "dun",
				["don't know"] 	= "dunno",
				["isn't it"] 	= "in'nit",
				["my"] 		= "me",
				["friend"] 	= "mate",
				["friends"] 	= "mates",
			};
		};

		["affect"]	= {
			[1] = {
				
			};
		};
	};
]]
--------------------------------------------------------------------------
-- Miscellanious Dialects						--
--------------------------------------------------------------------------
	["Pirate"] = {	
		["substitute"] = {
			[1] = {
				["am"] = "be",
				["is"] = "be",
				["are"] = "be",
				["there"] = "thar",
				["for"] = "fer",
				["my"] = "me",
				["you"] = "ye",
				["your"] = "yer",
				["friend"] = "mate",
				["friends"] = "mates",
				["yes"] = "aye",
				["yep"] = "aye",
				["raise"] = "hoist",
				["eggs"] = "cackle fruit",
				["noose"] = "hempen halter",
				["wow"] = "blow me down",
				["woah"] = "shiver me timbers",
				["my god"] = "shiver me timbers",
				["jesus"] = "blow me down",
				["uh oh"] = "shiver me timbers", 
				["uhoh"] = "shiver me timbers",
				["look out"] = "avast",
				["watch it you"] = "avast ye",
				["watch it"] = "avast ye",
				["hi"] = "oi",
				["hello"] = "ahoy",
				["greets"] = "ahoy",
				["greetings"] = "ahoy",
				["ready"] = "reddy",
				["gun"] = "barker",
				["guns"] = "barkers",
				["pistol"] = "barker",
				["pistols"] = "barker",
				["stop"] = "belay",
				["i'm"] = "i be",
				["im"] = "i be",
				["ya"] = "ye",
				["yah"] = "aye",
				["ma'am"] = "mum",
				["madam"] = "mum",
				["listen"] = "hark",
				["you listen to me"] = "hark ye",
				["listen to me"] = "hark ye",
				["should"] = "best",
			};
		};
		["affects"] = {
			[1] = merge({
				Tongues.Affect["Wordcut"]["substitute"][1],
				Tongues.Affect["Growl"]["substitute"][1],
			})
		};
	};


["Pirate-No Growl"] = {	
		["substitute"] = {
			[1] = {
				["am"] = "be",
				["is"] = "be",
				["are"] = "be",
				["there"] = "thar",
				["for"] = "fer",
				["my"] = "me",
				["you"] = "ye",
				["your"] = "yer",
				["friend"] = "mate",
				["friends"] = "mates",
				["yes"] = "aye",
				["yep"] = "aye",
				["raise"] = "hoist",
				["eggs"] = "cackle fruit",
				["noose"] = "hempen halter",
				["wow"] = "blow me down",
				["woah"] = "shiver me timbers",
				["my god"] = "shiver me timbers",
				["jesus"] = "blow me down",
				["uh oh"] = "shiver me timbers", 
				["uhoh"] = "shiver me timbers",
				["look out"] = "avast",
				["watch it you"] = "avast ye",
				["watch it"] = "avast ye",
				["hi"] = "oi",
				["hello"] = "ahoy",
				["greets"] = "ahoy",
				["greetings"] = "ahoy",
				["ready"] = "reddy",
				["gun"] = "barker",
				["guns"] = "barkers",
				["pistol"] = "barker",
				["pistols"] = "barker",
				["stop"] = "belay",
				["i'm"] = "i be",
				["im"] = "i be",
				["ya"] = "ye",
				["yah"] = "aye",
				["ma'am"] = "mum",
				["madam"] = "mum",
				["listen"] = "hark",
				["you listen to me"] = "hark ye",
				["listen to me"] = "hark ye",
				["should"] = "best",
			};
		};
		["affects"] = {
			[1] = merge({
				Tongues.Affect["Wordcut"]["substitute"][1],
				
			})
		};
	};
};

--======================================================================================================================--
--[[	-- Inspired by the Tuska Clan guild method of "Da Tak"
	-- OUT OF DATE FORMAT BUT PROVIDES A FRAMEWORK TO REBUILD FROM
Tongues.Dialect["Tuska"] = {
		["substitute"] = {
			[1] = {
				["said"]	=	"wen do say",
				["had"]		=	"wen have",
				["did"]		=	"wen do",
				["couldn't"]	=	"no could",
				["shouldn't"]	=	"no should",
				["wouldn't"]	=	"no would",
				["won't"]	=	"no going",
				["wont"]	=	"no going",
				["speaking"]	= 	"talk",
				["of"]		= 	"",
				["are"]		= 	"",
				["is"]		= 	"",
				["was"]		=	"wen",
				["were"]	= 	"wen",
	
				["have"]	= 	"got",
			};
		};
		["exceptions"] = merge({
			Phonetic["GA"]["exceptions"],
		});
		["rules"] = merge({
			Phonetic["RP"]["rules"],
		});
		["mutation"] = merge({
			Phonetic["th_t"]["mutation"],
			Phonetic["dh_d"]["mutation"],
			{
				["AEL_K_"] = "AAK_",

				["Y_"] = "IY",
				["AER_"] = "AAAA",
				["AOR_"] = "AAEH",
				["IYR_"] = "IYER",
				["EYR_"] = "EYER",
				["EYER"] = "EYEH",
				["EHR_"] = "ER",
				["AWR_"] = "AWEH",
				["IYER"] = "IYEH",
				["UWR_"] = "UWER",
				["UWR_"] = "UWEH",

				["IYIH"] = "IY",

				--["HW([^_])"] = "W_%1",

				--tr / chr Mutaion
				["T_AAR_"]= "CHR_",

				["N_D_"] = "N_",
				["NG"] = "N_",
			},
		});
		["remap"] = merge({
			Phonetic["GA"]["remap"],
			{
				["R_"] = "r",
				["AA"] = "a",
				["AHS_"] = "as",
				["AAN_"] = "on",
				["AW"] = "au",
				["OW"] = "a",
				["AY"] = "ai",

				["AHY_"] = "ai",
				["AEY_"] = "ei",
				["AEIY"] = "ei",
				["AE"]	= "a",
				["AO"]	= "au",
				["EY"] = "ei",
				["IH"] = "i",
				["IY"] = "i",

				["IYEH"] 	= "ia",
				["EYEH"] 	= "ea",
				["UWEH"]	= "ua",
				["ER"] = "a",
				["R_"] 		= "r",				
				["AWEH"] 	= "aua",
				["K_[Ss][_]?"]			= "ks",

				["UW"] = "u",
				["([BLKTW])_[BLKTW]_"] = "%1_",
				
				--["H_(%a*)"] = "'%1",
			}, 
		});
	};
]]
Tongues.Custom.Dialect={};
