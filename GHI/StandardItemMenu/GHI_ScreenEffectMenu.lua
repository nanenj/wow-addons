--===================================================
--
--	GHI_ScreenEffectMenu
--	GHI_ScreenEffectMenu.lua
--
--	Simple action menu
--
-- 	(c)2012 The Gryphonheart Team
--	All rights reserved
--===================================================
local loc = GHI_Loc()
local menus = {};
local miscAPI;
local ICON = "Interface\\Icons\\spell_nature_astralrecal";
local NAME = "GHI_ScreenEffectMenu";
local TYPE = "screen_effect";
local TYPE_LOC = loc.SCREEN_EFFECT;



function GHI_ScreenEffectMenu(_OnOkCallback, _editAction)
	if not (miscAPI) then miscAPI = GHI_MiscAPI().GetAPI(); end

	local colors = miscAPI.GHI_GetColors();
	local colorDropdown = {};
	local colorRef = {};
	local colorNames = {};
	for i, info in pairs(colors) do
		table.insert(colorDropdown, miscAPI.GHI_ColorString(loc["COLOR_"..string.upper(i)], info.r, info.g, info.b));
		table.insert(colorRef, { r = info.r, g = info.g, b = info.b });
		table.insert(colorNames, i);
	end


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
			menuFrame.ForceLabel("color", 8);

			for index, name in pairs(colorNames) do
				if name == info.color then
					menuFrame.ForceLabel("color", index);
				end
			end

			menuFrame.ForceLabel("fade_in", info.fade_in);
			menuFrame.ForceLabel("fade_out", info.fade_out);
			menuFrame.ForceLabel("duration", info.duration);
            menuFrame.ForceLabel("delay",info.delay);
		else
			class.editAction = nil;
			menuFrame.ForceLabel("color", 8);
			menuFrame.ForceLabel("fade_in", "");
			menuFrame.ForceLabel("fade_out", "");
			menuFrame.ForceLabel("duration", "");
               menuFrame.GetLabel("delay","");
		end
		menuFrame:AnimatedShow();
	end

	class.IsInUse = function() return inUse; end

	local OnOk = function()
		local action;

		--local color = menuFrame.GetLabel("color");
		local fade_in = menuFrame.GetLabel("fade_in");
		local fade_out = menuFrame.GetLabel("fade_out");
		local duration = menuFrame.GetLabel("duration");

		local colorI = menuFrame.GetLabel("color");
		local colorIDName = colorNames[colorI];
		local color = colorRef[colorI];
          local delay = menuFrame.GetLabel("delay");


		local t = {
			Type = "script",
			dynamic_rc_type = TYPE,
			type_name = TYPE_LOC,
			icon = ICON,
			details = color,
			color =color,
			dynamic_rc = true,
			fade_in = tonumber(fade_in),
			fade_out = tonumber(fade_out),
			duration = tonumber(duration),
               delay = tonumber(delay),

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
					height = 30,
					width = 10,
					align = "l",
				},
				{
					type = "Text",
					fontSize = 11,
					width = 390,
					text = loc.SCREEN_EFFECT_TEXT,
					color = "white",
					align = "l",
				},
			},
			{
				{
					type = "CustomDD",
					text = loc.COLOR,
					align = "l",
					label = "color",
					returnIndex = true,
					data = colorDropdown,
					texture = "Tooltip",
				},
			},
			{
				{
					type = "Editbox",
					text = loc.SCREEN_EFFECT_FADEIN,
					align = "l",
					label = "fade_in",
					width = 50,
					texture = "Tooltip",
				},
				{
					type = "Editbox",
					text = loc.SCREEN_EFFECT_FADEOUT,
					align = "c",
					label = "fade_out",
					width = 50,
					texture = "Tooltip",
				},
				{
					type = "Editbox",
					text = loc.DURATION,
					align = "r",
					label = "duration",
					width = 50,
					texture = "Tooltip",
				},
               },
               {
                    {
					type = "Editbox",
					text = loc.DELAY,
					align = "c",
					label = "delay",
					width = 50,
					texture = "Tooltip",
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
		lineSpacing = 20,
		OnHide = function()
			if not (menuFrame.window:IsShown()) then
				inUse = false;
			end
		end,
	});

	class.Show(_OnOkCallback, _editAction)

	return class;
end