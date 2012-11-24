--===================================================
--
--	GHI_BuffMenu
--	GHI_BuffMenu.lua
--
--	Simple action menu
--
-- 	(c)2012 The Gryphonheart Team
--	All rights reserved
--===================================================
 local loc = GHI_Loc()
local menus = {};
local miscAPI;
local ICON = "Interface\\Icons\\Spell_Holy_WordFortitude";
local NAME = "GHI_BuffMenu";
local TYPE = "buff";
local TYPE_LOC = loc.BUFF;

function GHI_BuffMenu(_OnOkCallback, _editAction)
	if not (miscAPI) then miscAPI = GHI_MiscAPI().GetAPI(); end

	for i, menu in pairs(menus) do
		if _editAction and menu.IsInUse() and menu.editAction == _editAction then
			GHI_Message(loc.ACTION_BEING_EDITED);
			return;
		end
	end
	for i, menu in pairs(menus) do
		if not (menu.IsInUse()) then
			menu.Show(_OnOkCallback, _editAction)
			return menu
		end
	end
	local class = GHClass(NAME);
	table.insert(menus, class);

	local menuFrame, OnOkCallback;
	local inUse = false;
	local menuIndex = 1;
	while _G[NAME .. menuIndex] do menuIndex = menuIndex + 1; end


	class.Show = function(_OnOkCallback, _editAction)
		OnOkCallback = _OnOkCallback;
		inUse = true;
		if (_editAction) then
			class.editAction = _editAction;
			local info = class.editAction.GetInfo();
			menuFrame.ForceLabel("buff_name", info.buffName);
			menuFrame.ForceLabel("buff_details", info.buffDetails);
			menuFrame.ForceLabel("buff_duration", info.buffDuration);
			menuFrame.ForceLabel("until_canceled", info.untilCanceled);
			menuFrame.ForceLabel("castOnSelf", info.castOnSelf);
			menuFrame.ForceLabel("filter", info.filter);
			menuFrame.ForceLabel("stackable", info.stackable);
			menuFrame.ForceLabel("buff_type", info.buffType);
			menuFrame.ForceLabel("buff_icon", info.buffIcon);
			menuFrame.ForceLabel("delay", info.delay);
			menuFrame.ForceLabel("amount", info.amount);
			menuFrame.ForceLabel("range", info.range);

		else
			class.editAction = nil;
			menuFrame.ForceLabel("buff_name", "");
			menuFrame.ForceLabel("buff_details", "");
			menuFrame.ForceLabel("buff_duration", 1);
			menuFrame.ForceLabel("until_canceled", false);
			menuFrame.ForceLabel("castOnSelf", false);
			menuFrame.ForceLabel("filter", "Helpful");
			menuFrame.ForceLabel("stackable", false);
			menuFrame.ForceLabel("buff_type", "Magic");
			menuFrame.ForceLabel("buff_icon", "Interface\\Icons\\INV_Misc_QuestionMark");
			menuFrame.ForceLabel("delay", 0);
			menuFrame.ForceLabel("amount", 1);
			menuFrame.ForceLabel("range", 0);
		end
		menuFrame:AnimatedShow();
	end

	class.IsInUse = function() return inUse; end

	local OnOk = function()
		local action;

		local buff_name = menuFrame.GetLabel("buff_name");
		local buff_details = menuFrame.GetLabel("buff_details");
		local buff_duration = menuFrame.GetLabel("buff_duration");
		local until_canceled = menuFrame.GetLabel("until_canceled");
		local castOnSelf = menuFrame.GetLabel("castOnSelf");
		local filter = menuFrame.GetLabel("filter");
		if filter == "" then filter = "Helpful"; end
		local stackable = menuFrame.GetLabel("stackable");
		local buff_type = menuFrame.GetLabel("buff_type");
		local buff_icon = menuFrame.GetLabel("buff_icon");
		local delay = menuFrame.GetLabel("delay");
		local amount = menuFrame.GetLabel("amount");
		local range = menuFrame.GetLabel("range");

		local t = {
			Type = TYPE,
			type_name = TYPE_LOC,
			icon = ICON,
			details = buff_name,
			buffName = buff_name,
			buffDetails = buff_details,
			buffDuration = buff_duration,
			untilCanceled = until_canceled,
			castOnSelf = castOnSelf,
			filter = filter,
			stackable = stackable,
			buffType = buff_type,
			buffIcon = buff_icon,
			delay = delay,
			amount = amount,
			range = range,
		};

		if (class.editAction) then
			action = class.editAction;
			action.UpdateInfo(t);
		else
			action = GHI_SimpleAction(t);
		end

		if OnOkCallback then
			OnOkCallback(action);
		end
		inUse = false;
		menuFrame:Hide();
	end

	menuFrame = GHM_NewFrame(class, {
		onOk = function(self) end,
		{
			{
				{
					type = "Dummy",
					height = 40,
					width = 10,
					align = "l",
				},
				{
					type = "Text",
					fontSize = 11,
					width = 390,
					text = loc.BUFF_TEXT,
					color = "white",
					align = "l",
				},
			},
			{
				{
					align = "l",
					type = "Editbox",
					texture = "Tooltip",
					text = loc.BUFF_NAME,
					label = "buff_name",
				},
			},
			{
				{
					align = "l",
					type = "Editbox",
					texture = "Tooltip",
					text = loc.BUFF_DETAILS,
					label = "buff_details",
				},
			},
			{
				{
					type = "Dummy",
					height = 20,
					width = 10,
					align = "c",
				},
			},
			{
				{
					align = "r",
					type = "TimeSlider",
					text = loc.BUFF_DURATION,
					label = "buff_duration",
				},
				{
					align = "l",
					type = "CheckBox",
					text = loc.BUFF_UNTIL_CANCELED,
					label = "until_canceled",
				},
			},
			{
				{
					align = "l",
					type = "CheckBox",
					text = loc.BUFF_ON_SELF,
					label = "castOnSelf",
				},
				{
					type = "RadioButtonSet",
					texture = "Tooltip",
					width = 155,
					label = "filter",
					align = "r",
					text = loc.BUFF_DEBUFF,
					data = {
						loc.HELPFUL,
						loc.HARMFUL,
					},
					returnIndex = false,
				},
			},
			{
				{
					align = "l",
					type = "CheckBox",
					text = loc.STACKABLE,
					label = "stackable",
				},
				{
					type = "CustomDD",
					texture = "Tooltip",
					width = 155,
					label = "buff_type",
					align = "r",
					text = loc.BUFF_TYPE,
					data = {
						loc.TYPE_MAGIC,
						loc.TYPE_CURSE,
						loc.TYPE_DISEASE,
						loc.TYPE_POISON,
						loc.TYPE_PHYSICAL,
					},
					returnIndex = false,
				},
				{
					framealign = "r",
					type = "Icon",
					label = "buff_icon",
					align = "c",
					text = loc.ICON,
					CloseOnChoosen = true,
				},
			},
			{
				{
					type = "Editbox",
					texture = "Tooltip",
					label = "delay",
					align = "r",
					text = loc.DELAY,
					numbersOnly = true,
					width = 60,
				},
				{
					type = "Editbox",
					texture = "Tooltip",
					label = "amount",
					align = "c",
					text = loc.AMOUNT,
					numbersOnly = true,
					width = 60,
				},
				{
					type = "Editbox",
					texture = "Tooltip",
					label = "range",
					align = "l",
					text = loc.RANGE,
					numbersOnly = true,
					width = 60,
				},
			},
			{
				{
					type = "Dummy",
					height = 20,
					width = 10,
					align = "c",
				},
			},
			{
				{
					type = "Dummy",
					height = 10,
					width = 100,
					align = "l",
				},
				{
					type = "Button",
					text = OKAY,
					align = "l",
					label = "ok",
					compact = false,
					OnClick = OnOk,
				},
				{
					type = "Dummy",
					height = 10,
					width = 100,
					align = "r",
				},
				{
					type = "Button",
					text = CANCEL,
					align = "r",
					label = "cancel",
					compact = false,
					OnClick = function(obj)
						menuFrame:Hide();
					end,
				},
			},
		},
		title = TYPE_LOC,
		name = NAME .. menuIndex,
		theme = "BlankTheme",
		width = 400,
		useWindow = true,
		--background = "INTERFACE\\GLUES\\MODELS\\UI_BLOODELF\\bloodelf_mountains",
		OnShow = UpdateTooltip,
		icon = ICON,
		lineSpacing = 0,
		OnHide = function()
			if not (menuFrame.window:IsShown()) then
				inUse = false;
			end
		end,
	});

	class.Show(_OnOkCallback, _editAction)

	return class;
end