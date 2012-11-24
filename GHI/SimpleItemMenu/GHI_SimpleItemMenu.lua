--===================================================
--
--				GHI_SimpleItemMenu
--  			GHI_SimpleItemMenu.lua
--
--	          (description)
--
-- 	  (c)2011 The Gryphonheart Team
--			All rights reserved
--===================================================

local UnitName = UnitName;
local UnitGUID = UnitGUID;
local loc = GHI_Loc()

local simpleActions = {
	{ "book", loc.TITLE_TEXT, "Interface\\ICONS\\INV_Misc_Book_08", loc.BOOK },
	{ "bag", loc.BAG_TEXT, "Interface\\ICONS\\INV_Misc_Bag_08", loc.BAG },
	{ "say", loc.SM_SAY, "Interface\\ICONS\\Ability_Warrior_CommandingShout", loc.SAY },
	{ "emote", loc.SM_EMOTE, "Interface\\Icons\\Ability_Rogue_Disguise", loc.EMOTE },
	{ "sound", loc.SM_SOUND, "Interface\\ICONS\\INV_Misc_Drum_04", loc.SOUND},
	{ "message",loc.MSG_TEXT, "Interface\\ICONS\\INV_Misc_Note_04", loc.MESSAGE_TEXT_U },
	{ "buff", loc.BUFF_TEXT, "Interface\\ICONS\\Ability_Paladin_BeaconofLight", loc.BUFF },
	{ "equip_item", loc.EQUIP_ITEM_TEXT, "Interface\\ICONS\\INV_Misc_EngGizmos_swissArmy", loc.EQUIP_ITEM },
	{ "screen_effect", loc.SCREEN_EFFECT_TEXT, "Interface\\ICONS\\INV_MISC_FILM_01", loc.SCREEN_EFFECT },
	{ "none", loc.SM_NONE, "Interface\\ICONS\\INV_Misc_Dice_02", loc.NONE },
};
local menuIndex = 1;
function GHI_SimpleItemMenu()
	local class = GHClass("GHI_SimpleItemMenu");
	local menuFrame, itemTooltip, item, edit, UpdateTooltip;
    
    -- Pages
    local page2, bagPage, bookPage, sayPage, emotePage, soundPage, messagePage, buffPage, equipPage, screenEffPage
    
    -- Item Setup Stuff
	local itemList = GHI_ItemInfoList();
	local containerList = GHI_ContainerList();
	local guidCreator = GHI_GUID();
	local miscApi = GHI_MiscAPI().GetAPI();
	local inUse = false;
    -- Default Action Selection
    local actionSelection = {"none",loc.NONE}
    -- Color and Texture Info
	local textures = { "-Normal", "-Bank", "-Keyring" };
	local textures_loc = { loc.NORMAL, loc.BANK, loc.KEYRING };
    local colors = miscApi.GHI_GetColors();
	local colorDropdown = {};
	local colorRef = {};
	local colorNames = {};
    for i, info in pairs(colors) do
		table.insert(colorDropdown, miscApi.GHI_ColorString(loc["COLOR_"..string.upper(i)], info.r, info.g, info.b));
		table.insert(colorRef, { r = info.r, g = info.g, b = info.b });
		table.insert(colorNames, i);
	end
    -- Color Info End

GHIemoteList = {};
-- adapted from TitanEmote
for i = 1, 453, 1 do
   if (getglobal("EMOTE"..i.."_TOKEN") ~= nil) then
      currEmote = getglobal("EMOTE"..i.."_TOKEN")   
      table.insert(GHIemoteList, currEmote);
   end
end
table.sort(GHIemoteList);
-- end adapt

	while _G["GHI_Standard_Item_Menu" .. menuIndex] do menuIndex = menuIndex + 1; end
	menuIndex = menuIndex + 1;
	local UpdateMenu = function()
		local name, icon, quality, stackSize = item.GetItemInfo();
		local white1, white2, comment, useText = item.GetFlavorText();
		menuFrame.ForceLabel("name", name);
		menuFrame.ForceLabel("white1", white1);
		menuFrame.ForceLabel("white2", white2);
		menuFrame.ForceLabel("comment", comment);
		menuFrame.ForceLabel("quality", quality);
		menuFrame.ForceLabel("icon", icon);
		menuFrame.ForceLabel("stackSize", stackSize);
		--menuFrame.ForceLabel("copyable", item.IsCopyable());
		--menuFrame.ForceLabel("editable", item.IsEditable());
		menuFrame.ForceLabel("useText", useText);
		menuFrame.ForceLabel("consumed", item.IsConsumed());
		menuFrame.ForceLabel("cooldown", item.GetCooldown());
	end

	local SetupWithEditItem = function()
		inUse = true;
		edit = true;

		UpdateMenu();
		UpdateTooltip();
	end

	local SetupWithNewItem = function()
		inUse = true;
		edit = false;
		item = GHI_ItemInfo({
			authorName = UnitName("player"),
			authorGuid = UnitGUID("player"),
			guid = guidCreator.MakeGUID();
		});
		UpdateMenu();
		UpdateTooltip();
	end

	UpdateTooltip = function()
		if item then
			local lines = item.GetTooltipLines();

			if (not itemTooltip:IsShown()) then
				itemTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE");
			end

			itemTooltip:ClearLines();
			for _, line in pairs(lines) do
				itemTooltip:AddLine(line.text, line.r, line.g, line.b, true);
			end
			if page2:IsShown() then
				itemTooltip:Show()
			else
				itemTooltip:Hide()
			end
			--itemTooltip:SetFrameStrata("MEDIUM");
			--itemTooltip:SetFrameLevel(0)
			itemTooltip:SetWidth(245)
			itemTooltip:SetHeight(min(itemTooltip:GetHeight(), 180));
		end
	end
    local function ActionData(selAct)
        local t = {}
        if selAct == simpleActions[1][1] then
            local title = menuFrame.GetLabel("book_title")
            t = {
                Type = simpleActions[1][1],
                type_name = simpleActions[1][4],
                icon = simpleActions[1][3],
                details = title,
                title = title,
            };
        elseif selAct == simpleActions[2][1] then
            local size = menuFrame.GetLabel("bag_size");
            local textureI = menuFrame.GetLabel("bag_texture");
            t = {
			Type = simpleActions[2][1],
			type_name = simpleActions[2][4],
			icon = simpleActions[2][3],
			details = string.format(loc.SLOTS_NUMBER, size),
			size = size,
			texture = textures[textureI],
		};
        elseif selAct == simpleActions[3][1] then
            local text = menuFrame.GetLabel("say_text");
            local delay = menuFrame.GetLabel("say_delay");
            t = {
                Type = "expression",
                type_name = loc.EXPRESSION,
                icon = simpleActions[3][3],
                details = (simpleActions[3][4] or "") .. ": " .. string.sub(text, 0, 100),
                text = text,
                expression_type = "Say",
                delay = delay,
            };
        
        elseif selAct == simpleActions[4][1] then
            local text = menuFrame.GetLabel("emote_text");
            local delay = menuFrame.GetLabel("emote_delay");
            t = {
                Type = "expression",
                type_name = loc.EXPRESSION,
                icon = simpleActions[4][3],
                details = (simpleActions[4][4] or "") .. ": " .. string.sub(text, 0, 100),
                text = text,
                expression_type = "Emote",
                delay = delay,
            };
        elseif selAct == simpleActions[5][1] then
            local path = menuFrame.GetLabel("simple_currentSound");
            local delay = menuFrame.GetLabel("sound_delay");
            local range = menuFrame.GetLabel("sound_range");
            t = {
                Type = simpleActions[5][1],
                type_name = simpleActions[5][4],
                icon = simpleActions[5][3],
                details = string.sub(path, 0, 100),
                sound_path = path,
                delay = delay,
                range = range,
            };
        elseif selAct == simpleActions[6][1] then
            local text = menuFrame.GetLabel("mess_text");
            local colorI = menuFrame.GetLabel("mess_color");
            local colorIDName = colorNames[colorI];
            local color = colorRef[colorI];
            t = {
                Type = "script",
                dynamic_rc_type = "message",
                type_name = simpleActions[7][4],
                icon = simpleActions[7][3],
                details = miscApi.GHI_ColorString(string.sub(text, 0, 100), color.r, color.g, color.b),
                text = text,
                dynamic_rc = true,
                color = colorIDName,
                delay = menuFrame.GetLabel("mess_delay"),
                output_type = menuFrame.GetLabel("mess_type"),
            };
        elseif selAct == simpleActions[7][1] then
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
            local delay = menuFrame.GetLabel("buff_delay");
            local amount = menuFrame.GetLabel("buff_amount");
            local range = menuFrame.GetLabel("buff_range");
            t = {
                Type = simpleActions[7][1],
                type_name = simpleActions[7][4],
                icon = simpleActions[7][3],
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
        elseif selAct == simpleActions[9][1] then
        local fade_in = menuFrame.GetLabel("fade_in");
		local fade_out = menuFrame.GetLabel("fade_out");
		local duration = menuFrame.GetLabel("se_duration");
		local colorI = menuFrame.GetLabel("se_color");
		local colorIDName = colorNames[colorI];
		local color = colorRef[colorI];
        local delay = menuFrame.GetLabel("se_delay");
        local se_details = "Screen Effect: "..colorIDName
            t = {
			Type = "script",
			dynamic_rc_type = "screen_effect",
			type_name = simpleActions[9][4],
			icon = simpleActions[9][3],
			details = se_details,
			color =color,
			dynamic_rc = true,
			fade_in = tonumber(fade_in),
			fade_out = tonumber(fade_out),
			duration = tonumber(duration),
            delay = tonumber(delay),
            };
        elseif selAct == simpleActions[8][1] then
            local itemname = menuFrame.GetLabel("item_name");
            local delay = menuFrame.GetLabel("eq_delay")
            t = {
                Type = simpleActions[8][1],
                type_name = simpleActions[8][4],
                icon = simpleActions[8][3],
                details = "", --need to add details.
                item_name = itemname,
                delay = delay
            };
        end
        local action = GHI_SimpleAction(t);
        item.AddSimpleAction(action);
    end
    
	local OnOk = function()
        if actionSelection[1] ~= simpleActions[10][1] then
        ActionData(actionSelection[1])
        end
        
		--if (edit) then
			item.IncreaseVersion(true);
		--end
		itemList.UpdateItem(item);
		if not (edit) then
			containerList.InsertItemInMainBag(item.GetGUID());
		end
		menuFrame:Hide();
		GHI_MiscData.lastUpdateItemTime = GetTime();
	end

	local t = {
		{
			{
				{
					align = "l",
					type = "Editbox",
					text = loc.NAME;
					tooltip = loc.NAME_TT;
					label = "name",
					texture = "Tooltip",
					OnTextChanged = function(self)
						item.SetName(self:GetText())
						UpdateTooltip();
					end,
				},
			},
			{
				{
					align = "l",
					type = "Editbox",
					text = loc.WHITE_TEXT_1;
					label = "white1",
					texture = "Tooltip",
					OnTextChanged = function(self)
						item.SetWhite1(self:GetText())
						UpdateTooltip();
					end,
				},
			},
			{
				{
					align = "l",
					type = "Editbox",
					text = loc.WHITE_TEXT_2;
					label = "white2",
					texture = "Tooltip",
					OnTextChanged = function(self)
						item.SetWhite2(self:GetText())
						UpdateTooltip();
					end,
				},
			},
			{
				{
					align = "l",
					type = "Editbox",
					text = loc.YELLOW_QUOTE;
					label = "comment",
					texture = "Tooltip",
					OnTextChanged = function(self)
						item.SetComment(self:GetText())
						UpdateTooltip();
					end,
				},
			},
			{
				{
					align = "r",
					type = "QualityDD",
					text = loc.QUALITY;
					label = "quality",
					OnValueChanged = function(newValue)
						item.SetQuality(newValue);
						UpdateTooltip();
					end,
				},
				{
					type = "Icon",
					text = loc.ICON,
					align = "c",
					label = "icon",
					framealign = "r",
					CloseOnChoosen = true,
					OnChanged = function(icon)
						item.SetIcon(icon);
					end
				},
				{
					align = "l",
					type = "Editbox",
					text = loc.USE;
					label = "useText",
					texture = "Tooltip",
					OnTextChanged = function(self)
						item.SetUseText(self:GetText())
						UpdateTooltip();
					end,
				},
			},
			{
				{
					type = "TimeSlider",
					text = loc.ITEM_CD,
					align = "l",
					label = "cooldown",
					OnValueChanged = function(cd)
						item.SetCooldown(cd);
					end,
				},
				{
					type = "StackSlider",
					text = loc.STACK_SIZE,
					align = "r",
					label = "stackSize",
					OnValueChanged = function(size)
						item.SetStackSize(size);
					end,
				},
			},
			{
				{
					type = "CheckBox",
					text = loc.CONSUMED,
					align = "l",
					label = "consumed",
					OnClick = function(self)

						item.SetConsumed(self:GetChecked());
					end
				},
			},
		},
		title = loc.CREATE_TITLE,
		name = "GHI_Simple_Item_Menu" .. menuIndex,
		theme = "BlankWizardTheme",
		width = 500,
		height = 360,
		useWindow = true,
		----background = "INTERFACE\\GLUES\\MODELS\\UI_BLOODELF\\bloodelf_mountains",
		OnShow = UpdateTooltip,
		OnHide = function()
			if not (menuFrame.window:IsShown()) then
				inUse = false;
			end
		end,
	};
    t.OnOk = OnOk
    
  	local selectActionPage = {
		{
			{
				type = "Text",
				text = loc.SM_SELECT,
				align = "l",
				fontSize = 16,
				color = "yellow",
				width = 400,
			},
		},
	};
	for i=1,math.floor(#(simpleActions)/2)+1 do
		table.insert(selectActionPage,{
			{
				type = "Dummy",
				label = "actionButtonAnchor"..(i*2)-1,
				align = "l",
				height = 50,
				width = 240,
			},
			{
				type = "Dummy",
				label = "actionButtonAnchor"..i*2,
				align = "r",
				height = 50,
				width = 240,
			},
		})
	end
    local editBagPage = {
            {
                {
					type = "Text",
                    fontSize = 16,
					width = 490,
					text = loc.SM_BAG_SET,
					color = "Yellow",
					align = "l",
				},
            },
            {
                {
					type = "Dummy",
					height = 25,
					width = 1,
					align = "l",
				},
            },
			{
				{
					type = "Text",
					fontSize = 11,
					width = 490,
					text = loc.BAG_TEXT,
					color = "white",
					align = "l",
				},
			},
			{
				{
					type = "SlotSlider",
					label = "bag_size",
					align = "l",
					text = loc.SLOTS,
					width = 150,
				},
				{
					type = "RadioButtonSet",
					texture = "Tooltip",
					label = "bag_texture",
					align = "r",
					text = loc.TEXTURE,
					data = textures_loc,
					returnIndex = true,
				},
			},
    }
    local editBookPage = {
        {
                {
                    type = "Text",
                    text = loc.SM_BOOK_SET,
                    align = "l",
                    fontSize = 16,
                    color = "yellow",
                    width = 490,
                },
        },
        {
				{
                    type = "Dummy",
                    width = 25,
                    height = 50,
                    align = "l"
                },
        },
        {
                {
					type = "Text",
					fontSize = 11,
					width = 490,
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
					width = 350,
					label = "book_title",
                    text = loc.TITLE,
				},
        },
        {
                {
                    align = "l",
                    type = "Dummy",
                    height = 120,
                    width = 10,
                },
        },
    }
    local editSayPage = {
        {
                {
                    type = "Text",
                    text = loc.SM_SPEACH_SET,
                    align = "l",
                    fontSize = 16,
                    color = "yellow",
                    width = 490,
                },
        },
        {
				{
					type = "Dummy",
					height = 25,
					width = 1,
					align = "l",
                },
        },
        {
                {
					type = "Text",
					fontSize = 11,
					width = 490,
					text = loc.SM_SPEACH_TEXT,
					color = "white",
					align = "l",
                },
        },
        {
				{
					align = "l",
					type = "Editbox",
					text = loc.TEXT;
					label = "say_text",
					width = 390,
					texture = "Tooltip",
					OnTextChanged = function(self)
					end,
				},
                {
					align = "r",
					type = "Editbox",
					text = loc.DELAY;
					label = "say_delay",
					width = 80,
					texture = "Tooltip",
					numbersOnly = true,
				},
        },
        {
				{
					type = "Dummy",
					height = 60,
					width = 10,
					align = "l",
				},
				{
					type = "Text",
					fontSize = 11,
					width = 490,
					text = loc.EXPRESSION_TIP,
					color = "white",
					align = "l",
				},
        },
    }
    local editEmotePage = {
        {
                {
                    type = "Text",
                    text = loc.SM_EMOTE_SET,
                    align = "l",
                    fontSize = 16,
                    color = "yellow",
                    width = 400,
                },
        },
        {
                {
					type = "Dummy",
					height = 25,
					width = 1,
					align = "c",
				},
        },
        {
            {
                align = "l",
                type = "Editbox",
                label = "emote_text",
                width = 300,
                text = loc.EMOTE,
                texture = "Tooltip",
                value = "",
                OnTextChanged = function()
                    local emoteDDMenu = {}
                    local emoteSearch = {}
                    local emoteTyping = string.upper(menuFrame.GetLabel("emote_text"))
                    local emoMenuTitle = {text = "Emote Suggestions", isTitle = true, isNotRadio = true, notCheckable = true}
                    if strlen(emoteTyping) >= 1 then
                    for i,v in ipairs(GHIemoteList) do
                    if string.find(strsub(v, 1,strlen(emoteTyping)),emoteTyping) then
                        table.insert(emoteSearch, v)
                    elseif not string.find(strsub(v, 1,strlen(emoteTyping)),emoteTyping) then
                        GameTooltip:ClearLines()
                    end
                    end
                    for i,v in ipairs(emoteSearch) do
                        local emoteMenuEntry = {text="",func="",isNotRadio = true, notCheckable = true}
                        emoteMenuEntry.text = v
                        emoteMenuEntry.func = function()
                            menuFrame.ForceLabel("emote_text", strlower(v))
                        end
                        table.insert(emoteDDMenu,emoteMenuEntry)
                    end

                    table.insert(emoteDDMenu,1,emoMenuTitle)

                    local emoMenuFrame = CreateFrame("Frame", "ExampleMenuFrame", GHM_EditBox9Box, "UIDropDownMenuTemplate")

                    -- Make the menu appear at the cursor: 
                    EasyMenu(emoteDDMenu, emoMenuFrame, GHM_EditBox9Box, 0 , 0, "MENU");
                    end
                end,
            },
            {
               align = "l",
               type = "PlayButton",
               width = 40,
               yOff = -3,
               onclick = function()
                  local selEmote = menuFrame.GetLabel("emote_text");
                  local isStdEmote
                  for key,value in pairs(GHIemoteList) do
                     if value ==  string.upper(selEmote) then
                        isStdEmote = true
                     end
                  end
                  if isStdEmote then
                     DoEmote(string.upper(selEmote));
                  else
                     SendChatMessage(selEmote, EMOTE)
                  end
               end,
            }, 
            {
					align = "r",
					type = "Editbox",
					text = loc.DELAY;
					label = "emote_delay",
					width = 80,
					texture = "Tooltip",
					numbersOnly = true,
            },
        },
        {
				{
					type = "Dummy",
					height = 60,
					width = 10,
					align = "l",
				},
				{
					type = "Text",
					fontSize = 11,
					width = 450,
					text = loc.EXPRESSION_TIP,
					color = "white",
					align = "l",
				},
        },
    }
    local editSoundPage = {
        {
                {
                    type = "Text",
                    text = loc.SM_SOUND_SET,
                    align = "l",
                    fontSize = 16,
                    color = "yellow",
                    width = 400,
                },
        },
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
					width = 490,
					text = loc.SOUND_SEL,
					color = "white",
					align = "l",
				},
        },
        {
				{
					align = "l",
					type = "SoundSelection",
					label = "simplesoundTree",
					width = 400,
					height = 180,
					texture = "Tooltip",
					OnSelect = function(path,duration)
						if not(menuFrame) then return end
						menuFrame.ForceLabel("simple_currentSound", path);


						local timeString = miscApi.GHI_GetPreciseTimeString(duration);
						if duration == 0.05 or duration == 0 then
							timeString = "(Unknown)"
						end
						local coloredTimeString = miscApi.GHI_ColorString(timeString, 0.0, 0.7, 0.5);

						menuFrame.ForceLabel("simple_soundDuration", coloredTimeString);

					end,
				},
                				{
					type = "Editbox",
					texture = "Tooltip",
					label = "sound_range",
					align = "r",
					text = loc.RANGE,
					numbersOnly = true,
					width = 60,
                    yOff = 40
				},
                {
					type = "Editbox",
					texture = "Tooltip",
					label = "sound_delay",
					align = "r",
					text = loc.DELAY,
					numbersOnly = true,
					width = 60,
                    yOff = 40,
				},
        },
        {
				{
					type = "Text",
					fontSize = 11,
					width = 150,
					text = loc.CURRENTLY_SELECTED,
					color = "yellow",
					align = "l",
					singleLine = true,
				},
				{
					type = "PlayButton",
					xOff = 20,
                    yOff = 5,
					align = "l",
					label = "simplePlaySound",
                    onclick = function(self)
                            local path = menuFrame.GetLabel("simple_currentSound")
                            if path then
                                PlaySoundFile(path)
                            else
                                print("You have not chosen a sound yet.")
                            end
                    end,
				},

        },
        {
                {
					type = "Text",
					fontSize = 11,
					width = 400,
					height = 50,
					text = loc.NONE,
					color = "white",
					align = "l",
					label = "simple_currentSound",
					singleLine = true,
                    yOff = 6.
				},
				{
					type = "Text",
					fontSize = 11,
					width = 250,
					text = "",
					color = "white",
					yOff = -14,
					align = "l",
					label = "simple_soundDuration",
					singleLine = true,
				},
        },
    }
    local editMessagePage = {
        {
                {
                    type = "Text",
                    text = loc.SM_MESS_SET,
                    align = "l",
                    fontSize = 16,
                    color = "yellow",
                    width = 400,
                },
        },
			{
				{
					type = "Dummy",
					height = 25,
					width = 10,
					align = "c",
				},
            },
            {
				{
					type = "Text",
					fontSize = 11,
					text = loc.MSG_TEXT,
					align = "l",
					color = "white",
					width = 400,
				},
			},
        {
				{
					type = "Editbox",
					text = loc.TEXT,
					align = "l",
					label = "mess_text",
					width = 300,
					texture = "Tooltip",
				},
				{
					type = "Editbox",
					text = loc.DELAY,
					align = "r",
					label = "mess_delay",
					width = 50,
					numbersOnly = true,
					texture = "Tooltip",
				}
			},
			{
				{
					type = "RadioButtonSet",
					text = loc.OUTPUT_TYPE,
					align = "r",
					label = "mess_type",
					returnIndex = true,
					data = { loc.CHAT_FRAME, loc.ERROR_MSG_FRAME },
					texture = "Tooltip",

				},
				{
					type = "CustomDD",
					text = loc.COLOR,  --will need help localizing color as they are formated as a table, unsure on
					align = "l",
					label = "mess_color",
					returnIndex = true,
					data = colorDropdown,
					texture = "Tooltip",
                    xOffset = -5,
				},
			},
    }
    local editBuffPage = {
        {
                {
                    type = "Text",
                    text = loc.SM_BUFF_SET,
                    align = "l",
                    fontSize = 16,
                    color = "yellow",
                    width = 400,
                },
        },
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
					width = 490,
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
                    width = 300,
				},
				{
					align = "r",
					type = "Icon",
					label = "buff_icon",
					align = "r",
					text = loc.ICON,
					CloseOnChoosen = true,
				},
		},
        {
				{
					align = "l",
					type = "Editbox",
					texture = "Tooltip",
					text = loc.BUFF_DETAILS,
					label = "buff_details",
                    width = 300,
				},
        },
        {
				{
					align = "c",
					type = "CheckBox",
					text = loc.BUFF_ON_SELF,
					label = "castOnSelf",
				},
				{
					type = "Editbox",
					texture = "Tooltip",
					label = "buff_range",
					align = "r",
					text = loc.RANGE,
					numbersOnly = true,
					width = 60,
				},
				{
					type = "CustomDD",
					texture = "Tooltip",
					width = 155,
					label = "buff_type",
					align = "l",
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
        },
        {
				{
					align = "c",
					type = "CheckBox",
					text = loc.BUFF_UNTIL_CANCELED,
					label = "until_canceled",
					yOff = 10,
				},		
				{
					type = "Editbox",
					texture = "Tooltip",
					label = "buff_amount",
					align = "r",
					text = loc.AMOUNT,
					numbersOnly = true,
					width = 60,
					yOff = 10,
				}, 		
				{
					align = "l",
					type = "TimeSlider",
					text = loc.BUFF_DURATION,
					label = "buff_duration",
					yOff = 10,
				},
			},
			{
				{
					type = "RadioButtonSet",
					texture = "Tooltip",
					width = 155,
					label = "filter",
					align = "l",
					text = loc.BUFF_DEBUFF,
					data = {
						loc.HELPFUL,
						loc.HARMFUL,
					},
					returnIndex = false,
					yOff = 10,
				},
				{
					type = "Editbox",
					texture = "Tooltip",
					label = "buff_delay",
					align = "r",
					text = loc.DELAY,
					numbersOnly = true,
					width = 60,
					yOff = 20,
				},
                {
					align = "c",
					type = "CheckBox",
					text = loc.STACKABLE,
					label = "stackable",
					yOff = 20,
				}, 				
			},
    }
    local editEquipPage = {
        {
                {
                    type = "Text",
                    text = loc.SM_EQUIP_SET,
                    align = "l",
                    fontSize = 16,
                    color = "yellow",
                    width = 400,
                },
        },
        {
				{
					type = "Dummy",
					height = 25,
					width = 10,
					align = "l",
				},
        },
        {
				{
					type = "Text",
					fontSize = 11,
					width = 490,
					text = loc.EQUIP_ITEM_TEXT,
					color = "white",
					align = "l",
				},
        },
        {
				{
					align = "l",
					type = "Editbox",
					texture = "Tooltip",
					text = loc.ITEM_NAME,
					label = "item_name",
					width = 200,
				},
				{
					type = "Dummy",
					height = 10,
					width = 50,
					align = "r",
				},
				{
					type = "Editbox",
					texture = "Tooltip",
					label = "eq_delay",
					align = "r",
					text = loc.DELAY,
					numbersOnly = true,
					width = 50,
				},
        },
    }
    local editScreenEffPage = {
        {
                {
                    type = "Text",
                    text = loc.SM_SCREEN_EFF_SET,
                    align = "l",
                    fontSize = 16,
                    color = "yellow",
                    width = 400,
                },
        },
        {
				{
					type = "Dummy",
					height = 25,
					width = 10,
					align = "l",
				},
        },
        {
				{
					type = "Text",
					fontSize = 11,
					width = 490,
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
					label = "se_color",
					returnIndex = true,
					data = colorDropdown,
					texture = "Tooltip",
				},
				{
					type = "Editbox",
					align = "r",
					label = "se_duration",
					width = 50,
					texture = "Tooltip",
				},
                {
					align = "r",
					type = "TimeSlider",
					text = loc.DURATION,
					label = "screen_duration",
                    xOff = -20,
                    values = {0,1,2,3,4,5,6,7,8,9,10,15,30,60,60*2,60*2.5,60*3,60*3.5,60*4,60*5},
					OnValueChanged = function(self)
                            local timeValue = menuFrame.GetLabel("screen_duration")
                            menuFrame.ForceLabel("se_duration", timeValue)
                    end,
				},
        },
        {
				{
					align = "l",
					type = "TimeSlider",
					text = loc.DELAY,
					label = "screen_delay",
                    xOff = 10,
                    values = {0,1,2,3,4,5,6,7,8,9,10,15,30,60,60*2,60*2.5,60*3,60*3.5,60*4,60*5},
					OnValueChanged = function(self)
                            local timeValue = menuFrame.GetLabel("screen_delay")
                            menuFrame.ForceLabel("se_delay", timeValue)
                    end,
				},
				{
					type = "Editbox",
					align = "l",
					label = "se_delay",
					width = 50,
					numbersOnly = true,
					texture = "Tooltip",
                    xOff = 15,
				},
                {
					type = "Editbox",
					align = "r",
					label = "fade_in",
					width = 50,
					texture = "Tooltip",
				},
                                				{
					align = "r",
					type = "TimeSlider",
					text = loc.SCREEN_EFFECT_FADEIN,
					label = "fadeIn_duration",
                    xOff = -20,
					values = {0,1,2,3,4,5,6,7,8,9,10,15,30,60,60*2,60*2.5,60*3,60*3.5,60*4,60*5},
					OnValueChanged = function(self)
                            local timeValue = menuFrame.GetLabel("fadeIn_duration")
                            menuFrame.ForceLabel("fade_in", timeValue)
                    end,
				},
        },
        {
				{
					type = "Editbox",
					align = "r",
					label = "fade_out",
					width = 50,
					texture = "Tooltip",
				},
                {
					align = "r",
					type = "TimeSlider",
					text = loc.SCREEN_EFFECT_FADEOUT,
					label = "fadeOut_duration",
                    xOff = -20,
					values = {0,1,2,3,4,5,6,7,8,9,10,15,30,60,60*2,60*2.5,60*3,60*3.5,60*4,60*5},
					OnValueChanged = function(self)
                            local timeValue = menuFrame.GetLabel("fadeOut_duration")
                            menuFrame.ForceLabel("fade_out", timeValue)
                    end,
                    
				},

        },
    }
    
    
	table.insert(t,1,selectActionPage);
    table.insert(t,3,editBagPage);
    table.insert(t,4,editBookPage);
    table.insert(t,5,editSayPage);
    table.insert(t,6,editEmotePage);
    table.insert(t,7,editSoundPage);
    table.insert(t,8,editMessagePage);
    table.insert(t,9,editBuffPage);
    table.insert(t,10,editEquipPage);
    table.insert(t,11,editScreenEffPage);
    
	menuFrame = GHM_NewFrame(class, t);
	page2 = _G[menuFrame:GetName().."_P2"];
    bagPage = _G[menuFrame:GetName().."_P3"];
    bookPage = _G[menuFrame:GetName().."_P4"];
    sayPage = _G[menuFrame:GetName().."_P5"];
    emotePage = _G[menuFrame:GetName().."_P6"];
    soundPage = _G[menuFrame:GetName().."_P7"];
    messagePage = _G[menuFrame:GetName().."_P8"];
    buffPage = _G[menuFrame:GetName().."_P9"];
    equipPage = _G[menuFrame:GetName().."_P10"];
    screenEffPage = _G[menuFrame:GetName().."_P11"];
    
    bagPage.active, bookPage.active, sayPage.active, emotePage.active, soundPage.active, messagePage.active, buffPage.active, equipPage.active, screenEffPage.active = false
    local buttonList = {}
	for i,action in pairs(simpleActions) do
		local actionType,actionText,actionIcon,actionName = unpack(action);
		local anchor = menuFrame.GetLabelFrame("actionButtonAnchor"..i);
      	local f = CreateFrame("Button",menuFrame:GetName().."ActionButton"..i,anchor,"GHI_SimpleActionButtonTemplate");
        table.insert(buttonList,f)

        f:SetPoint("TOPLEFT");
        f.name:SetText(actionName);
        f.icon:SetTexture(actionIcon);
        f.selHigh = f:CreateTexture("selHighlight", "OVERLAY")
        f.selHigh:SetPoint("CENTER",f.icon,"CENTER")
        f.selHigh:SetTexture("Interface\\Buttons\\CheckButtonGlow")
        f.selHigh:SetSize(70,70)
        f.selHigh:Hide()
        f:SetScript("OnClick",function()
          actionSelection[1] = actionType
          actionSelection[2] = actionName
          bagPage.active, bookPage.active, sayPage.active, emotePage.active, soundPage.active, messagePage.active, buffPage.active, equipPage.active, screenEffPage.active = false
          
            for i, button in pairs(buttonList) do
                button.selHigh:Hide()
            end
            f.selHigh:Show()
      
          if actionType == "bag" then
             bagPage.active = true
          elseif actionType == "book" then
             bookPage.active = true
          elseif actionType == "say" then
             sayPage.active = true
          elseif actionType == "emote" then
             emotePage.active = true
          elseif actionType == "sound" then
             soundPage.active = true
          elseif actionType == "message" then
             messagePage.active = true
          elseif actionType == "buff" then
             buffPage.active = true
          elseif actionType == "equip_item" then
             equipPage.active = true
          elseif actionType == "screen_effect" then
             screenEffPage.active = true
          end
      
          for i,action in pairs(simpleActions) do
             local selectedButton = menuFrame.GetLabelFrame("actionButtonAnchor"..i);
          end
          
          menuFrame.UpdatePages()
       end
);
        f:SetScript("OnEnter", function()

            GameTooltip:SetOwner(f)
            GameTooltip:SetAnchorType("ANCHOR_LEFT" ,0 , 0)
            GameTooltip:ClearLines();
            GameTooltip:SetText(actionName, 1,0.75,0)
            GameTooltip:AddLine(actionText,1,1,1,true)
            GameTooltip:Show()
        end    )
        f:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end    )

	end
    

    class.IsInUse = function() return inUse end
	
    class.GetItemGuid = function()
		return item.GetGUID();
	end
    
	class.New = function()

		menuFrame:AnimatedShow();
		menuFrame.SetPage(1);

		SetupWithNewItem();
	end

	class.Edit = function(guid)
		local editItem = itemList.GetItemInfo(guid);
		if not (editItem.IsEditable() or editItem.IsCreatedByPlayer()) then
			GHI_Message(loc.CAN_NOT_EDIT);
			menuFrame:Hide();
			return
		end



		item = editItem.CloneItem();

		if editItem.IsAdvanced() then
			edit = true;
			return ConvertToAdvItem();
		end


		menuFrame:AnimatedShow();
		menuFrame.SetPage(1);
		SetupWithEditItem();
	end

	itemTooltip = CreateFrame("GameTooltip", "GHI_SimpleItemMenuItemTooltip" .. menuIndex, menuFrame, "GHI_StandardItemMenuItemTooltip");
	_G["GHI_SimpleItemMenuItemTooltip" .. menuIndex .. "TextLabel"]:SetText(loc.PREVIEW)

	itemTooltip:SetPoint("TOPRIGHT", 10, -24)

	menuFrame.OnPageChange = function(page)
		UpdateTooltip();
	end

	menuFrame.window:AddScript("OnMinimize", function()

	end);

	return class;
end

