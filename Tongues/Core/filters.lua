local Filter = {
	["chat"] = {
		["substitute"] = {
			[1] = {
				["u"]					= "you",
				["ur"]					= "your",
				["lol"]  				= "*laugh*",
				["rofl"]				= "*laugh*",
				["wts"]	 				= "want to sell",
				["wtb"]	 				= "want to buy",
				["afk"]	 				= "away from the keyboard",
				["afn"]	 				= "all for now",
				["asap"]	 			= "as soon as possible",
				["atm"]	 				= "at the moment",
				["b4"] 					= "before",
				["bbl"]	 				= "be back later",
				["b/c"]	 				= "because",
				["gf"]	 				= "girlfriend",
				["bf"] 					= "boyfriend",
				["bfn"] 				= "bye for now",
				["brb"]	 				= "be right back",
				["btdt"]	 			= "been there, done that",
				["btw"]	 				= "by the way",
				["k"] 					= "okay",
				["omw"]					= "on my way",
				["kk"]	 				= "alright",
				["l8r"]	 				= "later",
				["lmao"]				= "*laugh*",
				["nvm"]		 			= "nevermind",
				["oic"]		 			= "oh, I see",
				["omg"] 				= "oh my god",
				["pst"]	 				= "please send tell",
				["ppl"]	 				= "people",
				["np"]	 				= "no problem",
				["rgr"]					= "roger",
				["lfg"]					= "looking for group",
			};
		};
	};
	["wow"] = {
		["substitute"] = {
			[1] = {
				["stv"]				= "Stranglethorn Vale",
				["bb"]				= "Booty Bay",
				["zg"]				= "Zul'Gurub",
				["sm"] 				= "Scarlet Monestary",
				["sw"] 				= "Stormwind City",
				["IF"] 				= "Ironforge",
				["dm"] 				= "Dire Maul",
				["vc"] 				= "VC",
				["sfk"] 			= "Shadowfang Keep",
				["ulda"] 			= "Uldaman",
				["st"] 				= "Sunken Temple",
				["zf"] 				= "Zul'Farak",
				["mara"] 			= "Maraudon",
				["brd"] 			= "Blackrock Depths",
				["stocks"] 			= "The Stockades",
				["scholo"] 			= "Scholomance",
				["strath?"] 			= "Stratholme",
				["bot"] 			= "Botanica",
				["bm"] 				= "Black Morass",
				["mt"] 				= "Mana Tombs",
				["sl"] 				= "Shadow Labyrinth",
				["slabs?"] 			= "Shadow Labyrinth",
				["shadow labs?"] 		= "Shadow Labyrinth",
			};
		};
	};
	["contractions"] = {
		["substitute"] = {
			[1] = {
				["whats"] 	= "what's",
				["isnt"] 	= "isn't",
				["thats"] 	= "that's",
				["dont"] 	= "don't",
				["cant"] 	= "can't",
				["aint"] 	= "ain't",
				["arent"] 	= "aren't",
				["wont"] 	= "won't",
				["shouldnt"] 	= "shouldn't",
				["wouldnt"] 	= "wouldn't",
				["couldnt"] 	= "couldn't",
				["shant"] 	= "shan't",
				["itd"] 	= "it'd",
				["hed"] 	= "he'd",
				["shed"] 	= "she'd",
				["maam"] 	= "ma'am",
			};
		};
	};

	["punctuate"] = {
		["substitute"] = {
			[1] = {
				["([^\42\46\33\63\40\41\44%s]+)[%s]*$"] = "%1\46",
			};
		};
	};

	["capitalize"] = {
		["substitute"] = {
			[1] = {
				["^(%a)"] =  function(a) return string.upper(a) end;
				["([\46\33\63\40\41]+[%s]*)(%a)"] = function(a,b) return a .. string.upper(b) end;
			};
		};
	};
};

Tongues.Filter = {
	["<None>"] = {};
	["Roleplay"] = {
		["filters"] = {
			[1] = merge({
				Filter["chat"]["substitute"][1],
				Filter["contractions"]["substitute"][1],
				--Filter["wow"]["substitute"][1],
			});
		},
		["substitue"] = {};
		["affects"] = 	{
			[1] = merge({
				Filter["capitalize"]["substitute"][1],
				Filter["punctuate"]["substitute"][1],
			});
		};
	};
};
Tongues.Custom.Filter={};	
