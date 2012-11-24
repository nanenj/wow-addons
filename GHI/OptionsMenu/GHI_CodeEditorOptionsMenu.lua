--===================================================
--
--				GHI_CodeEditorOptionsMenu
--  			GHI_CodeEditorOptionsMenu.lua
--
--	          (description)
--
-- 	  (c)2012 The Gryphonheart Team
--			All rights reserved
--===================================================

local class;
function GHI_CodeEditorOptionsMenu(parentName)
	if class then
		return class;
     end
     local loc = GHI_Loc()
	class = GHClass("GHI_CodeEditorOptionsMenu");
	local parentWidth = InterfaceOptionsFramePanelContainer:GetWidth() - 20;

	local miscAPI = GHI_MiscAPI().GetAPI();
	local LoadSyntaxColors;

	local menuFrame = GHM_NewFrame(CreateFrame("frame"), {
		onOk = function(self) end,
		{
			{
				{
					align = "c",
					type = "Text",
					text = loc.SCRIPT_CODE_EDITOR_SETTINGS,
					fontSize = 13,
				},
			},
			{
								{
					align = "l",
					type = "CheckBox",
					text = loc.SCRIPT_USE_WIDE,
					label = "useWideEditor",
				},
			},
			{
				{
					align = "l",
					type = "CheckBox",
					text = "Disable Syntax Highlighting",
					label = "disableSyntax",
				},
				{
					type = "Button",
					label = "ResetColors",
					align = "c",
					text = loc.SCRIPT_RESET_COLORS,
					compact = false,
					onclick = function(self)
						LoadSyntaxColors(true);
					end,
				},
			},
			{
				{
					height = 170,
					type = "Dummy",
					align = "l",
					width = 20,
					label = "SyntaxColorAnchor"
				},
			},
		},
		OnShow = function()
		end,
		title = loc.SCRIPT_CODE_EDITOR_SETTINGS,
		height = 400,
		name = "GHI_OptionsCodeEditorSettingsFrame",
		theme = "BlankTheme",
		width = parentWidth,
	});

	local syntaxColors = CreateFrame("Frame", "GHI_OptionsMenu_SyntaxColors", menuFrame, "ChatConfigBoxWithHeaderTemplate");
	syntaxColors:SetHeight(10);
	syntaxColors:SetWidth(10);
	syntaxColors:SetPoint("TOPLEFT", menuFrame.GetLabelFrame("SyntaxColorAnchor"), 0, -20)

	local syntaxColorPreview = CreateFrame("Frame", nil, syntaxColors);
	syntaxColorPreview:SetPoint("TOPLEFT", syntaxColors, "TOPRIGHT", 10, 0)
	syntaxColorPreview.title = syntaxColorPreview:CreateFontString();
	syntaxColorPreview.title:SetFontObject(GHM_GameFontSmall);
	syntaxColorPreview.title:SetTextColor(1, 1, 1)

	syntaxColorPreview.title:SetText(loc.OPT_SYNTAX_PREVIEW)
	syntaxColorPreview.title:SetPoint("TOPLEFT", 0, 10)
	syntaxColorPreview:SetWidth(parentWidth - 250)

	syntaxColorPreview.text = syntaxColorPreview:CreateFontString();
	syntaxColorPreview.text:SetFontObject(GameFontHighlight);
	syntaxColorPreview.text:SetJustifyH("LEFT");
	syntaxColorPreview.text:SetPoint("TOPLEFT", 6, -6)

	syntaxColorPreview:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	});
	syntaxColorPreview:SetBackdropColor(0, 0, 0, 1);
	syntaxColorPreview:Show()
	local syntax = menuFrame.GetLabelFrame("disableSyntax")
	syntax.SetOnClick(
		function()
			if menuFrame.GetLabel("disableSyntax") == true then
				syntaxColors:Hide()
			else
				syntaxColors:Show()
			end
		end
	)

	local GetSyntaxColorsTable = function()
		local t = {};
		local nameString = syntaxColors:GetName() .. "CheckBox";
		local checkBoxName, checkBox, baseName, base;
		local i = 1;
		baseName = nameString .. i;

		while _G[baseName] do
			base = _G[baseName];
			t[base.type] = { base.GetColor() };
			t[base.type].disabled = not (_G[baseName .. "Check"]:GetChecked() and true);
			i = i + 1;
			baseName = nameString .. i;
		end

		return t;
	end

	local UpdateSyntaxPreview = function()
		local syntax = GetSyntaxColorsTable();
		local form = function(s, t)
			if not (t.disabled) then
				return miscAPI.GHI_ColorString(s, unpack(t));
			else
				return s;
			end
		end
		local strings = {
			form("--Syntax colors example", (syntax.comment)),
			form("local", (syntax.keyword)) .. " i = " .. form("12", (syntax.number)) .. ";",
			form("if", (syntax.keyword)) .. " ( i > " .. form("10", (syntax.number)) .. ") " .. form("then", (syntax.keyword)),
			"   print(" .. form("\"Hello World\"", (syntax.string)) .. ");",
			form("   return", (syntax.keyword)) .. " " .. form("true", (syntax.boolean)) .. ";",
			form("end", (syntax.keyword)),
		};
		local s = strjoin("\n", unpack(strings));
		syntaxColorPreview.text:SetText(s)
	end


	local colorConfig = {};
	local catagories = GHM_GetSyntaxCatagories();
	for _, cat in pairs(catagories) do
		table.insert(colorConfig, {
			text = loc["SYNTAX_" .. string.upper(cat)] or cat,
			type = cat,
			checked = function() return true end,
			func = function(self, checked) UpdateSyntaxPreview(); end,
		});
	end

	ChatConfig_CreateCheckboxes(syntaxColors, colorConfig, "GHM_ChatConfigCheckBoxWithSwatchTemplate", loc.OPT_SYNTAX_HIGHLIGHT_COLOR);

	LoadSyntaxColors = function(default)
		local nameString = syntaxColors:GetName() .. "CheckBox";
		local i = 1;
		local baseName = nameString .. i;
		while _G[baseName] do
			local base = _G[baseName];
			local value = syntaxColors.checkBoxTable[i];
			if (base) then
				base.OnColor = UpdateSyntaxPreview;
				base.SetColor(GHM_GetSyntaxColor(value.type, default));
				base.type = value.type;
				_G[baseName .. "Check"]:SetChecked(not (GHM_IsSyntaxColorDisabled(value.type)))
			end
			i = i + 1;
			baseName = nameString .. i;
		end
		UpdateSyntaxPreview();
	end

	local bool = function(b)
		if b then return true; end
		return false;
	end
	local LoadSettings = function()
		local useWideEditor = bool(GHI_MiscData.useWideEditor);
		GHI_ScriptMenu_UseWideEditor(useWideEditor);
		menuFrame.ForceLabel("useWideEditor", useWideEditor)
		local syntaxDisabled = bool(GHI_MiscData.syntaxDisabled);
		menuFrame.ForceLabel("disableSyntax",syntaxDisabled);
		if syntaxDisabled == true then
			syntaxColors:Hide()
		end
		
	end

	menuFrame.name = loc.SCRIPT_CODE_EDITOR;
	menuFrame.refresh = function()
		syntaxColorPreview:SetHeight(syntaxColors:GetHeight());
		LoadSyntaxColors();
		LoadSettings();
	end
	menuFrame.okay = function()
		local t = GetSyntaxColorsTable();
		for i, v in pairs(t) do
			GHM_SetSyntaxColor(i, v[1], v[2], v[3]);
		end
		local useWideEditor = bool(menuFrame.GetLabel("useWideEditor"));
		local syntaxDisabled = bool(menuFrame.GetLabel("disableSyntax"));
		GHI_ScriptMenu_UseWideEditor(useWideEditor);
		GHI_MiscData.useWideEditor = useWideEditor;
		GHI_MiscData.syntaxDisabled = syntaxDisabled
		
	end;
	menuFrame.parent = parentName;

	LoadSettings();

	InterfaceOptions_AddCategory(menuFrame)

	class.Show = function(cat)
		InterfaceOptionsFrame_OpenToCategory(menuFrame);
	end

	return class;
end

