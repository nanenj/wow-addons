--===================================================
--
--	GHI_BookMenu
--	GHI_BookMenu.lua
--
--	Simple action menu
--
-- 	(c)2012 The Gryphonheart Team
--	All rights reserved
--===================================================
local loc = GHI_Loc()
local menus = {};
local miscAPI;
local ICON = "Interface\\Icons\\INV_Misc_Book_09";
local NAME = "GHI_BookMenu";
local TYPE = "book";
local TYPE_LOC = loc.BOOK;

function GHI_BookMenu(_OnOkCallback, _editAction)
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
			menuFrame.ForceLabel("title", info.title);
		else
			class.editAction = nil;
			menuFrame.ForceLabel("title", "");
		end
		menuFrame:AnimatedShow();
	end

	class.IsInUse = function() return inUse; end

	local OnOk = function()
		local action;

		local title = menuFrame.GetLabel("title");

		if (class.editAction) then
			action = class.editAction;
			local t2 = action.GetInfo();
			t2.title = title;
			t2.details = title;
			action.UpdateInfo(t2);
		else
			local t = {
				Type = TYPE,
				type_name = TYPE_LOC,
				icon = ICON,
				details = title,
				title = title,
			};
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
					height = 20,
					width = 10,
					align = "l",
				},
				{
					type = "Text",
					fontSize = 11,
					width = 390,
					text = loc.TITLE_TEXT,
					color = "white",
					align = "l",
				},
			},
			{
				{
					align = "c",
					type = "Editbox",
					texture = "Tooltip",
					width = 200,
					label = "title",
					text = loc.TITLE,
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