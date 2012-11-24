--===================================================
--
--			GHI_Logic
--			GHI_Logic.lua
--
--	   Dynamic action data for the 'Logic' category
--
--		(c)2012 The Gryphonheart Team
--			All rights reserved
--===================================================

local category = "Logic";

table.insert(GHI_ProvidedDynamicActions, {
	name = "Either Input (OR)",
	guid = "or_01",
	authorName = "The Gryphonheart Team",
	authorGuid = "00x1",
	version = 1,
	category = category,
	description = "Triggers the output when either of the inputs are triggered.",
	icon = "Interface\\Icons\\ACHIEVEMENT_GUILDPERK_FASTTRACK",
	gotOnSetupPort = false,
	setupOnlyOnce = false,
	allPortsTriggerScript = true,
	script =
	[[
		dyn.SetPortInFunction("in1",function()
			dyn.TriggerOutPort("out");
		end);
		dyn.SetPortInFunction("in2",function()
			dyn.TriggerOutPort("out");
		end);
	   	dyn.TriggerOutPort("out");
	]],
	ports = {
		in1 = {
			name = "Input Port 1",
			order = 1,
			direction = "in",
			description = "Triggers the output port, based on a Connection from another outport",
		},
		in2 = {
			name = "Input Port 2",
			order = 1,
			direction = "in",
			description = "Triggers the output port, based on a Connection from another outport",
		},
		out = {
			name = "Output Port",
			order = 1,
			direction = "out",
			description = "Triggered by either of the input ports.",
		},
	},
	inputs = {},
	outputs = {},
});

table.insert(GHI_ProvidedDynamicActions, {
	name = "Random number",
	guid = "rand_01",
	authorName = "The Gryphonheart Team",
	authorGuid = "00x1",
	version = 1,
	category = category,
	description = "Generates a random number based on input",
	icon = "Interface\\Icons\\inv_misc_dice_01",
	gotOnSetupPort = false,
	setupOnlyOnce = false,
	allPortsTriggerScript = true,
	script =
	[[

	   local targetRand = dyn.GetInput("randommax")

	   local produceRandom = math.random(1,targetRand)

        dyn.SetOutput("randomNum",produceRandom);
	   dyn.TriggerOutPort("random1");
	]],
	ports = {
		random1 = {
			name = "Random number Generated",
			order = 1,
			direction = "out",
			description = "Port triggered after the random number is generated",
		},
	},
	inputs = {
		randommax = {
			name = "Max Interval",
			description = "The maximum of number to random by (IE 1-(input))",
			type = "number",
			defaultValue = "",
		},
	},
	outputs = {
		randomNum = {
			name = "Random Number",
			description = "The generated random number",
			type = "number",
		},
	},
});


table.insert(GHI_ProvidedDynamicActions, {
	name = "Random Port (weighted)",
	guid = "rand_02",
	authorName = "The Gryphonheart Team",
	authorGuid = "00x1",
	version = 2,
	category = category,
	description = "triggers a random port based on a inputed weight scale",
	icon = "Interface\\Icons\\inv_misc_dice_02",
	gotOnSetupPort = true,
	setupOnlyOnce = false,
	allPortsTriggerScript = false,
	script =
	[[

	   local scale1 = dyn.GetInput("randomscale1")
	   local scale2 = dyn.GetInput("randomscale2")
	   local scale3 = dyn.GetInput("randomscale3")
	   local scale4 = dyn.GetInput("randomscale4")
	   local scale5 = dyn.GetInput("randomscale5")
	   local scale6 = dyn.GetInput("randomscale6")

	   local sum = scale1 + scale2 + scale3 + scale4 + scale5 + scale6
        local r = math.random(sum)
          if r <= scale1 then
             dyn.TriggerOutPort("randomport1");
          elseif r <= scale1 + scale2 then
             dyn.TriggerOutPort("randomport2");
          elseif r <= scale1 + scale2 + scale3 then
             dyn.TriggerOutPort("randomport3");
          elseif r <= scale1 + scale2 + scale3 + scale4 then
             dyn.TriggerOutPort("randomport4");
          elseif r <= scale1 + scale2 + scale3 + scale4 + scale5 then
             dyn.TriggerOutPort("randomport5");
          else
             dyn.TriggerOutPort("randomport6");
          end

        --dyn.SetOutput("randomNum",produceRandom);
	   ;
	]],
	ports = {
		randomport1 = {
			name = "Random port 1",
			order = 1,
			direction = "out",
			description = "random port to use",
		},
		randomport2 = {
			name = "Random port 2",
			order = 2,
			direction = "out",
			description = "random port to use",
		},
		randomport3 = {
			name = "Random port 3",
			order = 3,
			direction = "out",
			description = "random port to use",
		},
		randomport4 = {
			name = "Random port 4",
			order = 4,
			direction = "out",
			description = "random port to use",
		},
		randomport5 = {
			name = "Random port 5",
			order = 5,
			direction = "out",
			description = "random port to use",
		},
		randomport6 = {
			name = "Random port 6",
			order = 6,
			direction = "out",
			description = "random port to use",
		},
	},
	inputs = {
		randomscale1 = {
			name = "Scale 1",
			description = "the weight to use for port one",
			order = 1,
			type = "number",
			defaultValue = 0,
		},
		randomscale2 = {
			name = "Scale 2",
			description = "the weight to use for port two",
			order = 2,
			type = "number",
			defaultValue = 0,
		},
		randomscale3 = {
			name = "Scale 3",
			description = "the weight to use for port three",
			order = 3,
			type = "number",
			defaultValue = 0,
		},
		randomscale4 = {
			name = "Scale 4",
			description = "the weight to use for port four",
			order = 4,
			type = "number",
			defaultValue = 0,
		},
		randomscale5 = {
			name = "Scale 5",
			description = "the weight to use for port five",
			order = 5,
			type = "number",
			defaultValue = 0,
		},
		randomscale6 = {
			name = "Scale 6",
			description = "the weight to use for port six",
			order = 6,
			type = "number",
			defaultValue = 0,
		},
	},
	outputs = {},
});


table.insert(GHI_ProvidedDynamicActions, {
	name = "Random Port (percentage)",
	guid = "rand_03",
	authorName = "The Gryphonheart Team",
	authorGuid = "00x1",
	version = 1,
	category = category,
	description = "triggers a random port based on a inputed weight scale",
	icon = "Interface\\Icons\\inv_misc_dice_02",
	gotOnSetupPort = false,
	setupOnlyOnce = false,
	allPortsTriggerScript = true,
	script =
	[[

	   local scale1 = dyn.GetInput(percentscale1)
	   local scale2 = dyn.GetInput(percentscale2)
	   local scale3 = dyn.GetInput(percentscale3)
	   local scale4 = dyn.GetInput(percentscale4)

	   local sum = scale1 + scale2 + scale3 + scale4
        local r = math.random(sum)
          if r <= scale1 then
             dyn.TriggerOutPort("randomport1");
          end
          if r <= scale2 then
             dyn.TriggerOutPort("randomport2");
          end
          if r <= scale3 then
             dyn.TriggerOutPort("randomport3");
          end
          if r <= scale4 then
             dyn.TriggerOutPort("randomport4");
          end

        --dyn.SetOutput("randomNum",produceRandom);
	   ;
	]],
	ports = {
		randomport1 = {
			name = "Random port 1",
			order = 1,
			direction = "out",
			description = "random port to use",
		},
		randomport2 = {
			name = "Random port 2",
			order = 1,
			direction = "out",
			description = "random port to use",
		},
		randomport3 = {
			name = "Random port 3",
			order = 1,
			direction = "out",
			description = "random port to use",
		},
		randomport4 = {
			name = "Random port 4",
			order = 1,
			direction = "out",
			description = "random port to use",
		},
	},
	inputs = {
		percentscale1 = {
			name = "port1",
			description = "the weight to use for port one",
			order = 1,
			type = "number",
			defaultValue = "",
		},
		percentscale2 = {
			name = "port2",
			description = "the weight to use for port two",
			order = 2,
			type = "number",
			defaultValue = "",
		},
		percentscale3 = {
			name = "port3",
			description = "the weight to use for port three",
			order = 3,
			type = "number",
			defaultValue = "",
		},
		percentscale4 = {
			name = "port4",
			description = "the weight to use for port four",
			order = 4,
			type = "number",
			defaultValue = "",
		},
	},
	outputs = {},
});

