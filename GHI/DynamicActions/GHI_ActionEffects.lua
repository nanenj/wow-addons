--===================================================
--
--			GHI_Action and Effects
--			GHI_ActionEffects.lua
--
--	   Dynamic action data for the Action and Effects category
--
--		(c)2012 The Gryphonheart Team
--			All rights reserved
--===================================================
local category = "Actions and Effects";


table.insert(GHI_ProvidedDynamicActions, {
	name = "Summon Companion",
	guid = "companion_01",
	authorName = "The Gryphonheart Team",
	authorGuid = "00x1",
	version = 1,
	order = 1,
	category = category,
	description = "This action summons a companion based on a provided input.",
	icon = "Interface\\Icons\\inv_pet_deweaonizedmechcompanion",
	gotOnSetupPort = false,
	setupOnlyOnce = false,
	script =
	[[
	
	    --local numPets = GetNumCompanions("CRITTER");
        local _,numPets = C_PetJournal.GetNumPets(false)
	    local targetCompanion = dyn.GetInput("companion")
        local cName,active;
	    for i=1,numPets do
            local petID,_, isOwned, customName,_,_,_, cName, _, _, _, _, _, _,_ = C_PetJournal.GetPetInfoByIndex(i, false);--mop code
	   
			 
            if cName:lower() == targetCompanion:lower() or (customName ~= nil and customName:lower() == targetCompanion:lower()) then
			     
			       
				if C_PetJournal.GetSummonedPetID() == petID then active = true else active = false end
				   
                if active then---pet is already out or can't be summoned
                    dyn.TriggerOutPort("issummon");
                else
                    dyn.SetOutput("currentPet",cName);
                    dyn.TriggerOutPort("summon");
                     --unsure if correct as the code next to summon will be
                     --CallCompanion("CRITTER", i)
					C_PetJournal.SummonPetByID(petID)

                end
	        end
	    end
	]],
	ports = {
		summon = {
			name = "Summon Companion",
			order = 1,
			direction = "out",
			description = "If the player does not have the companion summoned, summon it",
		},
		issummon = {
			name = "Has a Companion",
			direction = "out",
			order = 2,
			description = "If the player has pet Summoned",
		},
	},
	inputs = {
		companion = {
			name = "companion",
			description = "The Companion name to summon",
			type = "string",
			defaultValue = "",
			--specialGHM = "ghm_fromDDList",
			--specialGHMScript = [[
			--dataFunc = function()

			--	local t = {};
			--	local _,numPets = C_PetJournal.GetNumPets(false)
				
				
			--    for i=1,numPets do
			--    	local petID,_, isOwned, customName,_,_,_, cName,icon,, _, _, _, _, _,_ = C_PetJournal.GetPetInfoByIndex(i, false);--mop code
			--        if isOwned then
			--		table.insert(t,{value = cName,text = "\124T"..icon..":16\124t "..cName});
			--		end
			--   	end
			--   	return t;
			--end]],
		},
	},
	outputs = {
		currentPet = {
			name = "Current Pet",
			description = "The pet currently summoned",
			type = "string",
		},
	},
});


table.insert(GHI_ProvidedDynamicActions, {
	name = "Dismiss Companion",
	guid = "companion_02",
	authorName = "The Gryphonheart Team",
	authorGuid = "00x1",
	version = 1,
	order = 2,
	category = category,
	description = "This action dismisses a summoned companion.",
	icon = "Interface\\Icons\\inv_pet_deweaonizedmechcompanion",
	gotOnSetupPort = false,
	setupOnlyOnce = false,
	script =
	[[
	    --local numPets = GetNumCompanions("CRITTER");

	    --local targetCompanion = dyn.GetInput("companion")
         --local cName,active;
         --dyn.SetOutput("currentPet",false);
	    ---for i=1,numPets do

	       -- _, cName, _, _, active,_ = GetCompanionInfo("CRITTER", i)

	        --if active then

                DismissCompanion("CRITTER")
			 dyn.TriggerOutPort("dismiss");
	        --end
	    --end
	]],
	ports = {
		dismiss = {
			name = "Dismiss Companion",
			order = 1,
			direction = "out",
			description = "Dismisses a currently summoned companion",
		},
	},
	inputs = {},
	outputs = {},
});


table.insert(GHI_ProvidedDynamicActions, {
	name = "Summon Mount",
	guid = "mount_01",
	authorName = "The Gryphonheart Team",
	authorGuid = "00x1",
	version = 1,
	category = category,
	description = "This action summons a mount based on a provided input.",
	icon = "Interface\\Icons\\ability_mount_ridinghorse",
	gotOnSetupPort = false,
	setupOnlyOnce = false,
	script =
	[[
	    local numPets = GetNumCompanions("MOUNT");

	    local targetCompanion 
	    local mountInput = dyn.GetInput("mountCustom")
		if mountInput ~= nil or mountInput ~= "" then
			targetCompanion = mountInput
		else
			targetCompanion = dyn.GetInput("mount")
		end
         local cName,active;

	    for i=1,numPets do

	        local _, cName, _, _, active,_ = GetCompanionInfo("MOUNT", i)

             if cName:lower() == targetCompanion:lower() then
                  if active then
                    dyn.TriggerOutPort("issummon");
                  else
                   --dyn.SetOutput("currentPet",cName);
                     dyn.TriggerOutPort("summon");
                     CallCompanion("MOUNT", i)

                  end
	        end
	    end
	]],
	ports = {
		summon = {
			name = "Summon Mount",
			order = 1,
			direction = "out",
			description = "If the player does not have the mount summoned, summon it",
		},
		issummon = {
			name = "Has a Mount",
			direction = "out",
			order = 2,
			description = "If the player has mount Summoned",
		},
	},
	inputs = {
		
		mountCustom = {
			name = "Mount Name",
			description = "The name of the mount to summon (Optional, if not found in drop down)",
			type = "string",
			defaultValue = "",
		},
		mount = {
			name = "Mount",
			description = "The Companion name to summon",
			type = "string",
			defaultValue = "",
			specialGHM = "ghm_fromDDList",
			specialGHMScript = [[
			dataFunc = function()

				local t = {};
				local numPets = GetNumCompanions("MOUNT");
			    for i=1,numPets do
			    	local _, cName, _, icon, active,_ = GetCompanionInfo("MOUNT", i);
			        table.insert(t,{value = cName,text = "\124T"..icon..":16\124t "..cName});
			   	end
			   	return t;
			end]],
		},
	},
	outputs = {},
});


table.insert(GHI_ProvidedDynamicActions, {
	name = "Dismiss Mount",
	guid = "mount_02",
	authorName = "The Gryphonheart Team",
	authorGuid = "00x1",
	version = 1,
	category = category,
	description = "This action dismisses a summoned Mount.",
	icon = "Interface\\Icons\\ability_mount_ridinghorse",
	gotOnSetupPort = false,
	setupOnlyOnce = false,
	script =
	[[
	    local numPets = GetNumCompanions("MOUNT");

	    --local targetCompanion = dyn.GetInput("companion")
         local cName,active;
         --dyn.SetOutput("currentPet",false);
	    for i=1,numPets do

	        _, cName, _, _, active,_ = GetCompanionInfo("MOUNT", i)

	        if active then

              if not(IsFlying()) then
                DismissCompanion("MOUNT")
			 dyn.TriggerOutPort("dismiss");
		    end
	        end
	    end
	]],
	ports = {
		dismiss = {
			name = "Dismiss Mount",
			order = 1,
			direction = "out",
			description = "Dismisses a currently summoned companion",
		},
	},
	inputs = {},
	outputs = {},
});

table.insert(GHI_ProvidedDynamicActions, {
	name = "Play Sound",
	guid = "sound_01",
	authorName = "The Gryphonheart Team",
	authorGuid = "00x1",
	version = 1,
	category = category,
	description = "This action plays a specified sound.",
	icon = "Interface\\Icons\\inv_misc_drum_06",
	gotOnSetupPort = false,
	setupOnlyOnce = false,
	script =
	[[
		local targetSound = dyn.GetInput("sound")

		if targetSound ~= nil then
			PlaySoundFile(targetSound.path);
			dyn.TriggerOutPort("playsound")
		end
	]],
	ports = {
		playsound = {
			name = "Play Sound",
			order = 1,
			direction = "out",
			description = "play the sound",
		},
	},
	inputs = {
		sound = {
			name = "Sound",
			description = "The sound to play",
			type = "sound",
			defaultValue = "",
		},
	},
	outputs = {},
});

table.insert(GHI_ProvidedDynamicActions, {
	name = "Play Sound Loop",
	guid = "sound_03",
	authorName = "The Gryphonheart Team",
	authorGuid = "00x1",
	version = 1,
	category = category,
	description = "Plays a specific set of sounds in a loop",
	icon = "Interface\\Icons\\inv_misc_drum_02",
	gotOnSetupPort = false,
	setupOnlyOnce = false,
	script =
	[[
		local rawSounds = {
			dyn.GetInput("sound1"),
			dyn.GetInput("sound2"),
			dyn.GetInput("sound3"),
			dyn.GetInput("sound4"),
			dyn.GetInput("sound5"),
		};

		local sounds = {}
		for _,s in pairs(rawSounds) do
			table.insert(sounds,s);
		end

		local stop = false;
		GHI_Timer(function()
			stop = true;
		end,dyn.GetInput("totalDuration"),true);

		dyn.SetPortInFunction("interrupt",function()
			stop = true;
		end);

		local Play;
		Play = function()
			local selected = random(#(sounds));
			if selected == 0 then
				return;
			end
			local sound = sounds[selected];
			PlaySoundFile(sound.path);


			GHI_Timer(function()
				if stop == true then
					dyn.TriggerOutPort("stoppedSound")
					return
				end
	        	Play();
			end,sound.duration or 2,true);
		end
		Play();
		dyn.TriggerOutPort("playSound")
	]],
	ports = {
		playSound = {
			name = "Started sound loop",
			order = 1,
			direction = "out",
			description = "The sound loop have started playing",
		},
		stoppedSound = {
			name = "Stopped sound loop",
			order = 2,
			direction = "out",
			description = "The sound loop have stopped playing",
		},
		interrupt = {
			name = "Interrupt loop",
			order = 2,
			direction = "in",
			description = "The sound loop will be interrupted at next sound",
		},
	},
	inputs = {
		totalDuration = {
			name = "Total duration",
			description = "Total amount of seconds to play in",
			type = "number",
			defaultValue = 10,
			order = 1,
		},
		sound1 = {
			name = "Sound 1",
			description = "1. sound to play",
			type = "sound",
			defaultValue = "",
			order = 2,
		},
		sound2 = {
			name = "Sound 2",
			description = "2. sound to play",
			type = "sound",
			defaultValue = "",
			order = 3,
		},
		sound3 = {
			name = "Sound 3",
			description = "3. sound to play",
			type = "sound",
			defaultValue = "",
			order = 4,
		},
		sound4 = {
			name = "Sound 4",
			description = "4. sound to play",
			type = "sound",
			defaultValue = "",
			order = 5,
		},
		sound5 = {
			name = "Sound 5",
			description = "5. sound to play",
			type = "sound",
			defaultValue = "",
			order = 6,
		},
	},
	outputs = {},
});


table.insert(GHI_ProvidedDynamicActions, {
	name = "Play Area Sound",
	guid = "sound_02",
	authorName = "The Gryphonheart Team",
	authorGuid = "00x1",
	version = 1,
	category = category,
	description = "This action plays a specified sound.",
	icon = "Interface\\Icons\\inv_misc_drum_06",
	gotOnSetupPort = false,
	setupOnlyOnce = false,
	script =
	[[


	    local targetSound = dyn.GetInput("sound")

         local range = dyn.GetInput("range")
         local delay = dyn.GetInput("delay") or 0;
         -- print(targetSound)
        if targetSound ~= nil then
             if range > 0 then
                GHI_PlayAreaSound(targetSound.path,range,delay)
                dyn.TriggerOutPort("playsound")
             else
                  GHI_PlayAreaSound(argetSound.path,10,delay)
                --GHI_PlaySound(targetSound)
                 dyn.TriggerOutPort("playsound")
             end
        end
	]],
	ports = {
		playsound = {
			name = "Play Sound",
			order = 1,
			direction = "out",
			description = "play the sound",
		},
	},
	inputs = {
		sound = {
			name = "Sound",
			description = "The sound to play",
			type = "sound",
			defaultValue = "",
		},
		range = {
			name = "Range",
			description = "The range of the sound",
			type = "number",
			defaultValue = 0,
          },
          delay = {
			name = "Delay",
			description = "The delay of the sound(optional)",
			type = "number",
			defaultValue = 0,
		}
	},
	outputs = {},
});

table.insert(GHI_ProvidedDynamicActions, {
	name = "Equip Item",
	guid = "equip_01",
	authorName = "The Gryphonheart Team",
	authorGuid = "00x1",
	version = 1,
	category = category,
	description = "This action equips an item based on input.",
	icon = "Interface\\Icons\\inv_sword_2h_ashbringercorrupt",
	gotOnSetupPort = false,
	setupOnlyOnce = false,
	script =
	[[

	    local targetEquip = dyn.GetInput("equip")

         EquipItemByName(targetEquip)

         dyn.TriggerOutPort("equip")
	]],
	ports = {
		equip = {
			name = "Item Equiped",
			order = 1,
			direction = "out",
			description = "when the item is (hopefully) equiped.",
		},
	},
	inputs = {
		equip = {
			name = "Item Name",
			description = "The name of the item to equip.",
			type = "string",
			defaultValue = "",
		},
	},
	outputs = {},
});

table.insert(GHI_ProvidedDynamicActions, {
	name = "Expression: Say",
	guid = "expression_01",
	authorName = "The Gryphonheart Team",
	authorGuid = "00x1",
	version = 1,
	category = category,
	description = "This actions makes the user say a sentence..",
	icon = "Interface\\Icons\\Spell_Shadow_SoothingKiss",
	gotOnSetupPort = false,
	setupOnlyOnce = false,
	script =
	[[

	    local targetSay = dyn.GetInput("expressSay")

         GHI_Say(targetSay,0)

         dyn.TriggerOutPort("say")
	]],
	ports = {
		say = {
			name = "Expression triggerd",
			order = 1,
			direction = "out",
			description = "when the expression happens",
		},
	},
	inputs = {
		expressSay = {
			name = "Expression",
			description = "What will be said in say.",
			type = "string",
			defaultValue = "",
		},
	},
	outputs = {},
});

table.insert(GHI_ProvidedDynamicActions, {
	name = "Perform speach",
	guid = "say_02",
	authorName = "The Gryphonheart Team",
	authorGuid = "00x1",
	version = 1,
	category = category,
	description = "This action makes the user perform a speach from a given text.",
	icon = "Interface\\Icons\\Spell_Shadow_SoothingKiss",
	gotOnSetupPort = false,
	setupOnlyOnce = false,
	script =
	[[

	    local text = dyn.GetInput("text");

		local parts = {};
		while (strlen(text) > 0) do
	        local part = string.sub(text,0,256);
	        local index = 0;
	        local dotIndex;
	        while (index) do
	        	dotIndex = index;
	         	index = string.find(part,"%.",index+1);
	        end

			if dotIndex == 0 then
				index = 0;
				while (index) do
					dotIndex = index;
					index = string.find(part," ",index+1);
				end
			end

	        if dotIndex > 0 then
	        	part = string.sub(part,0,dotIndex);
	        end
	       	text = string.sub(text,string.len(part)+2);
	       	table.insert(parts,part);
		end

		local c = 1;
		while(_G["TriggerSay"..c]) do
			c = c + 1;
		end

	    _G["TriggerSay"..c] = function(index)
	    	if parts[index] then
	        	GHI_Say(parts[index]);
				if parts[index+1] then
					local dur = math.floor(string.len(parts[index])/15);
					GHI_DoScript("TriggerSay"..c.."("..(index+1)..");",dur);
				else
					dyn.TriggerOutPort("done")
				end
	    	end
	    end

        _G["TriggerSay"..c](1);

        dyn.TriggerOutPort("say")
	]],
	ports = {
		say = {
			name = "Speach started",
			order = 1,
			direction = "out",
			description = "When the speach begins.",
		},
		done = {
			name = "Speach ended",
			order = 2,
			direction = "out",
			description = "When the speach is done.",
		},
		interrupt = {
			name = "Interrupt",
			order = 2,
			direction = "out",
			description = "Interrupts the speach when triggered.",
		},
	},
	inputs = {
		text = {
			name = "Text",
			description = "The text to say in the speach.",
			type = "text",
			defaultValue = "",
		},
	},
	outputs = {},
});

table.insert(GHI_ProvidedDynamicActions, {
	name = "Expression: Emote",
	guid = "expression_02",
	authorName = "The Gryphonheart Team",
	authorGuid = "00x1",
	version = 1,
	category = category,
	description = "This action equips an item based on input.",
	icon = "Interface\\Icons\\inv_misc_discoball_01",
	gotOnSetupPort = false,
	setupOnlyOnce = false,
	script =
	[[

	    local targetEmote = dyn.GetInput("expressEmote")

         GHI_Emote(targetEmote,0)

         dyn.TriggerOutPort("emote")
	]],
	ports = {
		emote = {
			name = "Expression triggerd",
			order = 1,
			direction = "out",
			description = "when the expression happens",
		},
	},
	inputs = {
		expressEmote = {
			name = "Expression",
			description = "What will be performed in an emote.",
			type = "string",
			defaultValue = "",
		},
	},
	outputs = {},
});

table.insert(GHI_ProvidedDynamicActions, {
	name = "Message",
	guid = "Message_02",
	authorName = "The Gryphonheart Team",
	authorGuid = "00x1",
	version = 1,
	category = category,
	description = "This displays a message based on input.",
	icon = "Interface\\Icons\\inv_letter_15",
	gotOnSetupPort = false,
	setupOnlyOnce = false,
	script =
	[[
		local color = dyn.GetInput("inputcolor");
	    local targetMessage = dyn.GetInput("message");

        DEFAULT_CHAT_FRAME:AddMessage(targetMessage,color.r,color.g,color.b)

        dyn.TriggerOutPort("msgPort")
	]],
	ports = {
		msgPort = {
			name = "Message triggerd",
			order = 1,
			direction = "out",
			description = "when the Message happens",
		},
	},
	inputs = {
		message = {
			name = "Message",
			description = "What will be displayed in a message",
			type = "string",
			defaultValue = "",
		},
		inputcolor = {
			name = "Color",
			description = "The color for the message",
			type = "color",
			defaultValue = "",
		},
	},
	outputs = {},
});


table.insert(GHI_ProvidedDynamicActions, {
	name = "Screen Effect: Color",
	guid = "Screen_01",
	authorName = "The Gryphonheart Team",
	authorGuid = "00x1",
	version = 1,
	category = category,
	description = "Produces a screen effect flash.",
	icon = "Interface\\Icons\\achievement_doublerainbow",
	gotOnSetupPort = false,
	setupOnlyOnce = false,
	script =
	[[
        -- local miscAPI = GHI_MiscAPI().GetAPI();
         local color = dyn.GetInput("inputcolor")
         local fadeIn = dyn.GetInput("fadein")
         local fadeOut = dyn.GetInput("fadeout")
         local duration = dyn.GetInput("duration")
         --local delay = dyn.GetInput("delay")

         GHI_ScreenFlash(fadeIn,fadeOut,duration,color)


         dyn.TriggerOutPort("effectPort")
	]],
	ports = {
		effectPort = {
			name = "effect triggerd",
			order = 1,
			direction = "out",
			description = "when the effect happens",
		},
	},
	inputs = {
		fadein = {
			name = "Fade in",
			description = "the time (in seconds) the effect will fade in for",
			order = 1,
			type = "number",
			defaultValue = "",
		},
		fadeout = {
			name = "Fade out",
			description = "the time (in seconds) the effect will fade out for",
			order = 2,
			type = "number",
			defaultValue = "",
		},
		duration = {
			name = "Duration",
			description = "how long the effect lasts",
			order = 3,
			type = "number",
			defaultValue = "",
		},
		inputcolor = {
			name = "Color",
			description = "The color for the effect",
			order = 4,
			type = "color",
		},
	},
	outputs = {},
});


table.insert(GHI_ProvidedDynamicActions, {
	name = "Screen Effect: Shake",
	guid = "Screen_02",
	authorName = "The Gryphonheart Team",
	authorGuid = "00x1",
	version = 1,
	category = category,
	description = "Produces a screen shaking effect.",
	icon = "Interface\\Icons\\spell_Shaman_Earthquake",
	gotOnSetupPort = false,
	setupOnlyOnce = false,
	script =
	[[
        local intensity = dyn.GetInput("intensity")
        local duration = dyn.GetInput("duration")
         
		GHI_ScreenShake(duration, intensity)

        dyn.TriggerOutPort("effectPort")
	]],
	ports = {
		effectPort = {
			name = "effect triggerd",
			order = 1,
			direction = "out",
			description = "when the effect happens",
		},
	},
	inputs = {
		intensity = {
			name = "Shake Intensity",
			description = "The intensity of the shaking.",
			order = 1,
			type = "number",
			defaultValue = "",
		},
		duration = {
			name = "Duration",
			description = "how long the effect lasts.",
			order = 2,
			type = "number",
			defaultValue = "",
		},
	},
	outputs = {},
});

table.insert(GHI_ProvidedDynamicActions, {
	name = "Cast buff",
	guid = "buff_01",
	authorName = "The Gryphonheart Team",
	authorGuid = "00x1",
	version = 1,
	category = category,
	description = "Casts a buff",
	icon = "Interface\\Icons\\Spell_Holy_WordFortitude",
	gotOnSetupPort = true,
	setupOnlyOnce = false,
	script =
	[[

         local buffName = dyn.GetInput("buffName")
         local buffDetails = dyn.GetInput("buffDetails")
         local buffIcon = dyn.GetInput("buffIcon")
         local untilCanceled = dyn.GetInput("untilCanceled")
         local filter = dyn.GetInput("filter")
         local buffType = dyn.GetInput("buffType")
         local buffDuration = dyn.GetInput("duration")
         local cancelable = dyn.GetInput("cancelable")
         local stackable = dyn.GetInput("stackable")
         local count = dyn.GetInput("count")
         local delay = dyn.GetInput("delay")
         local range = dyn.GetInput("range")
         local alwaysCastOnSelf = dyn.GetInput("alwaysCastOnSelf")



         GHI_ApplyBuff(buffName, buffDetails, buffIcon, untilCanceled, filter, buffType, buffDuration, cancelable, stackable, count, delay, range, alwaysCastOnSelf);
	]],
	ports = {
	},
	inputs = {
		buffName = {
			name = "Buff name",
			description = "The name of the buff",
			order = 1,
			type = "string",
			defaultValue = "",
		},
		buffDetails = {
			name = "Buff details",
			description = "The detail description of the buff",
			order = 2,
			type = "string",
			defaultValue = "",
		},
		buffIcon = {
			name = "Icon",
			description = "Icon of the buff",
			order = 3,
			type = "icon",
			defaultValue = "",
		},
		untilCanceled = {
			name = "Until canceled",
			description = "If the buff is applied untill it is canceled",
			order = 4,
			type = "boolean",
			defaultValue = false,
		},
		filter = {
			name = "Buff/debuff",
			description = "A buff or a debuff",
			order = 5,
			type = "string",
			defaultValue = false,
			specialGHM = "ghm_fromRadio",
			specialGHMScript = [[
			dataFunc = function()
				return {
					{ value = "Helpful", text = "Buff"},
					{ value = "Harmful", text = "Debuff"},
				};
			end]],
		},
		buffType = {
			name = "Debufftype",
			description = "The type of the debuff",
			order = 6,
			type = "string",
			defaultValue = false,
			specialGHM = "ghm_fromDDList",
			specialGHMScript = [[
			dataFunc = function()
				return {
					{ value = "Curse", text = "Curse"},
					{ value = "Disease", text = "Disease"},
					{ value = "Magic", text = "Magic"},
					{ value = "Poison", text = "Poison"},
					{ value = "Physical", text = "Physical"},
				};
			end]],
		},
		duration = {
			name = "Duration",
			description = "The duration of the buff (in seconds)",
			order = 7,
			type = "number",
			defaultValue = 30,
		},
		cancelable = {
			name = "Cancelable",
			description = "Mark true if the player can cancel a helpful buff by right clicking.",
			order = 8,
			type = "boolean",
			defaultValue = false,
		},
		stackable = {
			name = "Stackable",
			description = "True or False if the buff can have multiple stacks.",
			order = 9,
			type = "boolean",
			defaultValue = true,
		},
		count = {
			name = "Count",
			description = "The number of buffs to apply",
			order = 10,
			type = "number",
			defaultValue = 1,
		},
		delay = {
			name = "Delay",
			description = "How long time the buff is delayed before casted",
			order = 11,
			type = "number",
			defaultValue = 0,
		},
		range = {
			name = "Range",
			description = "The range (if area buff)",
			order = 12,
			type = "number",
			defaultValue = 0,
		},
		alwaysCastOnSelf = {
			name = "Always cast on self",
			description = "Mark true if yo want to make sure the buff does not cast on anyone but the user.",
			order = 13,
			type = "boolean",
			defaultValue = false,
		},
	},
	outputs = {},
});


table.insert(GHI_ProvidedDynamicActions, {
	name = "Remove buff",
	guid = "buff_02",
	authorName = "The Gryphonheart Team",
	authorGuid = "00x1",
	version = 1,
	category = category,
	description = "Removes a buff.",
	icon = "Interface\\Icons\\Spell_Holy_WordFortitude",
	gotOnSetupPort = true,
	setupOnlyOnce = false,
	script =
	[[
         local buffName = dyn.GetInput("buffName")
         local filter = dyn.GetInput("filter")
         local amount = dyn.GetInput("amount")
         local delay = dyn.GetInput("delay")

         GHI_RemoveBuff(buffName,filter,amount,delay);
	]],
	ports = {
	},
	inputs = {
		buffName = {
			name = "Buff name",
			description = "The name of the buff",
			order = 1,
			type = "string",
			defaultValue = "",
		},
		filter = {
			name = "Buff/debuff",
			description = "A buff or a debuff",
			order = 5,
			type = "string",
			defaultValue = false,
			specialGHM = "ghm_fromRadio",
			specialGHMScript = [[
			dataFunc = function()
				return {
					{ value = "Helpful", text = "Buff"},
					{ value = "Harmful", text = "Debuff"},
				};
			end]],
		},
		amount = {
			name = "Amount",
			description = "The number of buffs to remove",
			order = 10,
			type = "number",
			defaultValue = 1,
		},
		delay = {
			name = "Delay",
			description = "How long time the buff is delayed before casted",
			order = 11,
			type = "number",
			defaultValue = 0,
		},
	},
	outputs = {},
});