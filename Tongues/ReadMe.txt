-----------------------------------------------------------------
-			Tongues Manual				-
-----------------------------------------------------------------
Note: 	Tongues was inspired by Lore by Rook and maintained by Rufftran, 
	but only uses the same hash coding... 
	everything else is a complete rewrite.

-----------------
Table of Contents
-----------------
[1]	History of the Addon
[2]	Installing
[3]	Standard Settings
   [3.1]	Speak
	[3.1.1]		Language
	[3.1.2]		Dialect
	[3.1.3]		Affect
	[3.1.4]		Lore Compatibility
   [3.2]	Understand
   [3.3]	Hear
[4]	Advanced Settings
[5]	Creating Custom Languages,Dialects or Affects
   [5.1] Converting Languages from Lore
[6]	Bug Watch
[7]	Acknowledgements
[8]	Version Changes
----------------------------------------------------------------------------------------------------------
[1]	History of the Addon
	
	A while ago I started using Lore (while it was in version 7.5.7).
	I found it very difficult to configure, and thought the user interface
	was confusing, so I began making modifications to the version I downloaded.
	I started by correcting bugs, and then got to a point where I realized that
	I wouldn't be able to do any more without rewriting a bunch of code.

	I sent a message to Rufftran with the things I'd been doing with Lore,
	and if it would be acceptable to help him with it. I didn't hear from him, 
	so I began working on Tongues.  6 months after I sent the original message
	I received a response: "Wow, I'm speechless. I'd never have thought 
	of any of these. With your permission I'll definetly add these."  

	I said of course he could add them, but at that point I had already finished
	my first stable release of Tongues (which was version 1.0.0.8.)  

	I have been very active to bring all the features from Lore into Tongues, but
	along the way I have added my own ideas, so this is very much a 'child' of Lore.
	I have asked Rufftran if he would be interested in either merging projects
	or adding code to Lore to make it Tongues compatible.  I haven't received a
	response yet.  In the mean time I have made Tongues compatible with Lore.
----------------------------------------------------------------------------------------------------------
[2]	Installing
	
	Installation should be very simple, just unzip the Tongues zip file to 
	"<World of Warcraft>\Interface\Addons"
	(e.g. "C:\World of Warcraft\Interface\Addons",) and you're done!
----------------------------------------------------------------------------------------------------------
[3]	Standard Settings

	I have designed Tongues to have, what I feel is, an intuitive layout.
	As such I have broken up the Standard Settings into 3 areas: "Speak", 
	"Understand", and "Hear".
	
	The "Understand" section is where you control what you can understand.
	The "Hear" section is where you can modify or add filters to what your character
	would hear.
	----------------------------------------------------------------------------------------------------------
	[3.1]	Speak
		The "Speak" section is where you control what you actually say.
		----------------------------------------------------------------------------------------------------------
		[3.1.1]	Language
		
			All languages that are in "Tongues\Core\Languages.lua" and 
			"Tongues\Custom\Languages.lua" are available to speak, but Custom languages
			that share a name with a Core language will overwrite them.  This means that
			you never need to change anything in Core unless you want to completely 
			remove it.
	
			To select a language to speak, simply click on the languages drop down 
			box and select in what language you'd like to speak.  By default this 
			will be "Screened" to all but say and yell.

			More on how to adjust this is in Advanced Settings.

			The Shapeshifted checkbox lets you automatically switch to a Bear, Moonkin, 
			Trentish, Cat, or a Bird language based on your shapeshifted form.  This 
			only currently applies to Druids.  Eventually I would like to allow special
			items and spells that shift your form to also be included (e.g. someone who was
			'sheep'ed would start saying "BAAH" or a Shaman in ghost wolf form would speak
			"Wolf".
		----------------------------------------------------------------------------------------------------------
		[3.1.2] Dialects
			
			All dialects follow the same rules regarding customization as languages.
			It's important to note that if your spoken language is understood by 
			someone that they still will see your dialect.  So if I am speaking Orcish in
			a Pirate dialect, and someone can understand Orcish, they will still see the
			Pirate dialect.  

			I find that this makes for much more emmersive play.  I also
			recognize that not everyone will want to speak in character in party, guild, raid
			so I have added the ability to filter these individually. By default party, guild,
			raid, etc. are "Screened" and thus do not see dialect or language.

			More on how to adjust this is in Advanced Settings.
		----------------------------------------------------------------------------------------------------------
		[3.1.3] Affect
			
			Some players will want to add some affect to speech, such as a stutter, slur, lisp, etc.
			but still want a dialect or language.  Because affect is based on the sound, this can do
			some interesting things.  Stuttering in Orcish would return something like "K-kek l-loktar", if
			seen by folks with 0% understanding of Orcish, or "H-heh h-hello" if seen with 100% understanding.

			Affects are also not applied to any channel you are screening.
		----------------------------------------------------------------------------------------------------------
		[3.1.4]	Lore Compatibility
		
			This check box allows Tongues to provide translations to users of Lore and vice versa.
			If someone were using both, having this checked may result in 2 messages being seen, one from
			Lore and one from Tongues.
	
		----------------------------------------------------------------------------------------------------------
	[3.2]	Understand

		This is probably the most important section of Tongues.  To understand any language that is not 
		"Common" for Alliance, or "Orcish" for Horde, you have to at least have 1% knowledge
		in that language.  Because you may want or need to learn a custom language that someone created, I didn't
		put a dropdown box here.  This way if someone has a language called "Xyxxyx" you can still learn it by doing
		the following:

		Type "Xyxxyx" into the textbox and press enter (enter is optional at this point, but it becomes more important
		if you need to adjust your understanding.)  Then adjust the slider below to the approximate level you want.
		Then press Set.  If you want to erase ALL the language you know, you'd press "Clear".  

		Any percent at 0 will never translate, any at 100% will always translate, and any in between will either translate
		each word that percentage of the time, or, in the case of links translate the whole sentance that percent of the time.

		"List" will dump a list of all the languages you know and their percentage into the default chat frame.
	----------------------------------------------------------------------------------------------------------
	[3.3]	Hear
		
		This applies to all incoming messages from other players whether they have Tongues or not.
		This will become more important with future patches, but currently it has two options: None and Roleplaying.
		Currently all Roleplaying does is Capitalize the first letter of each sentance and punctuate the end.
		Later patches will reintroduce filtures that allow the expansion of common Worldcraft appreviations and chat
		abbrieviations to their full word equivelent.  For instance "SW" would become "Stormwind" or "ZA" would become
		"Zul'Aman", etc.
	----------------------------------------------------------------------------------------------------------
[4]	Advanced Settings

	These basically break down into 2 categories: "Screen from Channel" and "Translate to Channel".
	A check in a Translate means that if you say something in Say or Yell that it will put the translated version of
	that to that channel.  

	A check in a Screen means that it will not apply any of the "Speak" Languages, Dialects, or Affects to that channel.

	A check in both Translate and Screen in the same channel means that if you Say or Yell, it will send the original text
	stripped of all Languages, Dialects, or Affects to that channel.  

	You can accomplish some interesting things this way, but I generally don't recommend it.

	If you have "To Targetted" checked then whoever you have targetted (if they are a member of your faction) will get
	either a Translated message if you have that checked or a Screened message if you have that checked (the same rules apply.)

	The final thing of note is the "Translators" bit at the bottom.  This is basically the same as Lore's Translators.
	If you add a name of a player to that textbox and hit "+/-" they will be added, if you already added that name they will 
	be removed.  It is important to note that they will ALWAYS RECEIVE ANYTHING YOU SAY, unless you remove them so used 
	this with caution.  You can clear all Translators with the "Clear" button or list them all with the "List" button.
----------------------------------------------------------------------------------------------------------
[5]	Custom Languages, Dialects, or Affects
	NOTE: I DO NOT PROVIDE SUPPORT FOR THIS, IT IS HIGHLY COMPLICATED, USE AT YOUR OWN RISK
	----------------------------------------------------------------------------------------------------------
	[5.1] Converting Languages from Lore
		Languages are slightly different from Lore in how they are formatted, below is a simple Lore language:

			Lore_Archive["Your Language Name"] = {
				[1] = { "r", "b" },
				[2] = { "rb", "bb", "br", "rr" }
			};

		The Tongues version would need to be below Tongues.Custom.Language = {} and need to be put 
		in Custom\CustomLanguages.lua and look like this:

			Tongues.Custom.Language["Your Language Name"] = {
				[1] = { "r", "b" },
				[2] = { "rb", "bb", "br", "rr" }
			};
	
		As you can see this is almost identical! This takes words with 1 letter, and uses either "r" or "b",
		takes words with 2 or more letters and substitutes "rb","bb","br", or "rr".  It's suggested to at least to go [10]
		since there are many words with more than 2 letters, and not alot with more than 10, but you can go as high as you'd like.
		----------------------------------------------------------------------------------------------------------
		For more complicated Lore Languages things change slightly ... take the keywords for example:
			
			Lore_Archive["Your Language Name"]["keywords"] = { "this", "that" };
	
		In Tongues again this would go in Custom\CustomLanguages.lua but as the following:
	
			Tongues.Custom.Language["ignore"] = { "this", "that" };
	
		The behavior is much the same, Tongues sees those words and won't hash them ... it will ignore them.
		----------------------------------------------------------------------------------------------------------
		Now for Lore's Altwords ... this is totally different in Tongues:
			
			Lore_Archive["Your Language Name"]["altwords"] = {
				["old"] = { "the", "this", "that" },
				["new"] = { "de", "dis", "dat" }
			};
	
		And in Tongues:
	
			Tongues.Custom.Language["Your Language Name"]["substitute"] = {
				["the"]  = "de",
				["this"] = "dis",
				["that"]  = "dat",
			};
		You don't need to specify something different for "This", "this", "THIS", "tHiS" etc, Tongues will figure it out,
		and apply the appropriate result. ("The" would be "De", "THE" would be "DE", but "thE" would be "de").
		I also recommend putting a comma after your last entry (in this case "dat")... even though it's not needed
		when you add another line below it, you might forget the comma on the line above.
	----------------------------------------------------------------------------------------------------------
	[5.2] Converting Dialects from Lore

		Dialects are alot more flexible (and complex) than in Lore.  To make a simple dialect you can
		use sometime very like the Tongues Languages substitute ... which works by word.
		These go below Tongues.Custom.Dialect = {}; in the Custom\customdialects.lua
		Here is a Lore Dialect example:

			Lore_Archive["*Dialect's Name"]["altwords"] = { 
				["old"] = { "the", "these", "this", "them" },
				["new"] = { "de", "dese", "dis", "dem"}
			};

		And in Tongues:

			Tongues.Custom.Dialect["Dialect's Name"] = {
				["substitute"] = {
					[1] = {
						["the"] = "de",
						["these"] = "dese",
						["this"] = "dis",
						["them"] = "dem",
					};
				};
			};

		It's worth nothing that the words are applied in groups ... 1 being the first then 2 etc.
		Normally you just need 1 unless you have something like this:

			Tongues.Custom.Dialect["Dialect's Name"] = {
				["substitute"] = {
					[1] = {
						["bye"] = "good bye",
					},
				};
			};

		In this case you might end up with "good good bye", instead you should do the following:
			Tongues.Custom.Dialect["Dialect's Name"] = {
				["substitute"] = {
					[1] = {
						["good bye"] = "bye",
					},
					[2] = {
						["bye"] = "good bye",
					},
				};
			};

		This way you take all "good bye"s and make them into "bye" which means "bye" or "good bye" would become "bye", and then
		you take "bye" and make it "good bye" ... the result is "good bye" and "bye" will always be "bye".
		Like I said this is more complicated and you won't need to use most of the time.

		Now for the hard part!

		Lets say I always want to turn "th" into "d", I can use affects to achieve this.
		Example:
			Tongues.Custom.Dialect["Dialect's Name"] = {
				["substitute"] = {
					[1] = {
					},
				},
				["affects"] = {
					[1] = {
						["([t])[hH]"] = "d",
						["([T])[hH]"] = "D",
					},
				};
			};

		And if you are really ambitious this will also work:
			Tongues.Custom.Dialect["Dialect's Name"] = {
				["substitute"] = {
					[1] = {
					},
				},
				["affects"] = {
					[1] = {
						["([tT])[hH]"] = function(a)
							if a == "t" then
								return a
							else
								return string.upper(a)
							end;
						end;
					},
				};
			};
		
		The last useful thing to know is you can use my merge functions to build upon previously 
		made affects/substitutes etc.  If you got this far just go ahead and look at Core\dialects.lua for examples :)

----------------------------------------------------------------------------------------------------------
[6]	Bug Watch

	Recently, bugs reports almost exclusively have been related to a "nil value".  This happens when I add new Character settings,
	but forget to add self-healing to people who are migrating from one version to the next.  This is easiest to fix by
	removing variable file <World of Warcraft>\WTF\Account\<AccountName>\<ServerName>\<CharacterName>\Tongues.lua for each
	character affected (e.g. "C:\World of Warcraft\WTF\Account\SkrullsAccount\Lightninghoof\Skrul\Tongues.lua" .)

	I also fix these bugs quickly so most of the time you can just get the next version.

	If any bugs are found please post a ticket on www.curseforge.com on the Tongues project.  These are easiest for me
	to get notified on and I'll be sure to respond quickly.
----------------------------------------------------------------------------------------------------------
[7]	Acknowledgements

	I'd like to thank Rook and Rufftran and the folks who helped him with Lore for inspiring me to create Tongues 

	Skunkwerks (for the good ideas and feedback)
	Aurorablade (for all the constructive feedback, and the Swift Flight Form bug post!)
	Szaazmaan (for his enthusiasm for Language learning)
	Avanina (for all her very useful suggestions)
	Victarion (for letting me continually test with him)
	Unagh (for letting me test 1.0.3.4 with her)
	Vykalidan (for letting me test 1.0.3.5, inviting me to the guild, and getting the word out!)

	and everyone else who has offered feedback!
----------------------------------------------------------------------------------------------------------
[8]	Version Changes
	1.0.4.10 
		*Fixed GHI compatibility error
		*Fixed Blizzard languages not screening properly
	1.0.4.9
		*Fixed randomseed error that cropped up with WoW 3.1
	1.0.4.8
		*Fixed a compatibility problems with GryphonHeart Item links

		*Added /petspeak and /ps command and all the gunk that makes the language translation work (alot)

		*Modified the Versioning to pull from the toc file
	1.0.4.7
		*Fixed a parsing error with languages named with words that could be modified by the Roleplaying filter e.g. Cant -> Can't
		
		*Fixed Swift Flight Form speaking
	1.0.4.6 
		*Production version

	1.0.4.5 WotLK Beta 8820 --
		*Correction on to make Common and Orcish work again

	1.0.4.5 WotLK Beta 8820 --
		*Removed Lore Compatibility due to changes in WotLK that change how channels work
		
		*Minor corrections to UIDropDownMenu_SetText param order

		*ChatFrame_OnEvent hooking is now ChatFrame_MessageEventHandler and takes the proper arguments

	1.0.4.4 --
		*Cross Faction languages being spoken will no longer generate a Player not Found message
		(Note they still cannot be understood, nor will they be)

		*Minor corrections to Custom Languages not processing correctly in some circumstances.

	1.0.4.3 --
		*Minor bug in auto language learning fixed for non same race Blizzard languages

		*Tree of Life language fixed

		*Fixed issue with chat filter returning the wrong "BFD" :)

	1.0.4.2 -- 
		*Bug in auto language learning fixed

	1.0.4.1 -- 
		*Darnassian dialect is now more in line with Darnassian language (instead of Thalassian)

		*Experimental Gutterspeak dialect added (v substitues for w and hiss is applied)

		*Demonic is now the main table (instead of Eredun)

		*Fix to Understand on languages not already available

		*Removed unused commands from being listed in /tongues help

	1.0.4.0 --
		*Fixed minor issue with aliases not working properly.

		*Added Automatic Language Learning (only learns from others using Tongues)

		*Added a tool to generate custom languages (hta format, which requires a hta interpreter, Microsoft Windows has this built in)

		*Expanded Nerglish

		*Added difficulties to languages

		*Druid, Shaman, and Warlock automatically start with certain languages now

		*Trentish is again the Tree Form Druid's language
	
		*Bird is now the Flight Form Druid's language (Ravenspeech will be adjusted to match Arakkoa's actually speech later)

		*Druidic, Tier, Yserian removed since I couldn't find justification within Warcraft lore (they are in the customlanguages.txt in case people want this)

		*Added Qiraji (uses same table as Nerubian)

		*Added Demonic, Titan, and Draconic readded (uses same table as Eredun)

	1.0.3.9 --
		*Fixed minor issue about race base language translations cross race.

	1.0.3.8 --
		*Fixed racial languages translating properly across race if both players have Tongues.
		(Minor issues remain but this works now.)		

		*Fixed addition carsh that occurred if messages were larger than 256 (code was in but I 
		had left it commented out by mistake. 

	1.0.3.7 --
		*Switched Minimenu cycle so left rotates and right opens the Main Menu

		*Corrected issue with Substitution only parsing some times

		*New Substitution method also solves the only 3 word phrase issue

		*Outbound filters are now controled by Filter (Inbound remains the same)

		*Fixed crash that occurred if messages were larger than 256 characters

		*Links in translated messages no longer disappear

	1.0.3.6 --
		*Refixed links ... quest and item links should work in languages now

		*Abstracted Set Language so that the Language Dropdown or /language command call the same command (Tongues:SetLanguage(<language>))

		*Right clicking the MiniMenu now cycles languages instead of openning the MainMenu.

		*Corrected and issue with custom language/dialects etc not loading properly
	1.0.3.5 --
		*Corrected an issue where saved language variables were being replaced with default language

		*Added Thalassian dialect
	
		*Added Ursine to languages

		*Several small fixes

	1.0.3.4 --
		*Fixed Lore Compatibility

		*Changes in UI

		*Now Orcish and Common are encrypted if you don't know those languages

		*Blizzard Languages used when possible

	1.0.3.3 --
		*Resolved multiple receive issue

		*Resolved multiple receive issue (it deserves to be mentioned twice!)
		
		*Translate to Self no longer needed to fix multiple receive issue

		*Changes to Language to allow Substitute words and Ignore words

		*Changes to Languages to make the names in line with Warcraft lore (such as Dwarven instead of Dwarvish etc)

		*Changes to Dialects to make the names in line with Languages (the Tauren dialect is now called Taurahe for instance.)

		*Tongues Main Menu can now be closed by pressing ESC (Thanks for the suggestion Avanina!)

		*Tongues Main Menu's Icon/Button now completely covers the circle (Thanks for the suggestion Avanina!)

		*All Dialects, Languages, Affects and Filters are now capitialized.

		*All 'none', 'None' are now '<None>' to put them at the top and make them look nicer.

		*Dialect Drift button has been hidden again until it can officially be used.

		*Languages can be aliased now, so that if you use Demonic for instance and you know Eredun, it will still translate.

		*Numerous small under the hood fixes that shouldn't be noticeable

	1.0.3.2 -- 
		*Hotfix for multiple receive issue

	1.0.3.1 --
		*ReadMe.txt added (was in post 1.0.2.7 beta and alpha releases as well.)

		*More flexibility in the order Substitutions and ApplyEffects are added

		*Changes to Dialects, Affects, Phonetics, and Filters to make them compatible with the new flexibility.

		*Rewrote how Links are Parsed

		*Roleplay filter always applied on outbound messages (essentially this was the case before, but it was handled in the Dialects, 
		now it is global. This was put in as a result of the new Link Parsing)

		*Fixed Chat Addons message from sending duplicates (a timer is no longer used, and Translate to Self is now needed to see
		one's own messages translated.)

		*Translate to Self now formats more like the Lore Compatibility mode when messages are received from other players.

		