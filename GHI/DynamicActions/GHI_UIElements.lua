
local category = "UI Elements";

table.insert(GHI_ProvidedDynamicActions, {
	name = "Slash Command",
	guid = "slash_01",
	authorName = "The Gryphonheart Team",
	authorGuid = "00x1",
	version = 1,
	category = category,
	description = "Sets up a slash command.",
	icon = "Interface\\Icons\\INV_Misc_Note_04",
	gotOnSetupPort = true,
	setupOnlyOnce = true,
	allowedInUpdateSequence = false,
	script =
	[[  local cmdPrefix = dyn.GetInput("cmdPrefix");
		local slashCmdHandler = GHI_SlashCmd(cmdPrefix);
	    slashCmdHandler.SetDefaultFunc(function(cmd)
	    	dyn.SetOutput("cmd",cmd);
	    	dyn.TriggerOutPort("cmdEntered");
	    end)
	]],
	ports = {
		cmdEntered = {
			name = "Command entered",
			direction = "out",
			order = 1,
			description = "Fired when a command is entered.",
		},
	},
	inputs = {
		cmdPrefix = {
			name = "Slash prefix",
			description = "The /prefix that should be reacted to.",
			type = "string",
			defaultValue = "",
		},
	},
	outputs = {
		cmd = {
			name = "Command",
			description = "The command entered",
			type = "string",
		},
	},
});