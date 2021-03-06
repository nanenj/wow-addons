--===================================================
--
--				GHI_ActionBarUI
--  			GHI_ActionBarUI.lua
--
--	          (description)
--
-- 	  (c)2011 The Gryphonheart Team
--			All rights reserved
--===================================================



--[[
local MatchAnchor = function(frame,newFrame)
	newFrame:SetWidth(frame:GetWidth());
	newFrame:SetHeight(frame:GetHeight());
	newFrame:ClearAllPoints();
	for i=1,frame:GetNumPoints() do
		newFrame:SetPoint(frame:GetPoint(i));
	end

	if frame:IsShown() then
		newFrame:Show();
	else
		newFrame:Hide();
	end
end

local CloneRegion = function(region,name,parent)
	local Type = region:GetObjectType();
	local newRegion;

	if Type == "Texture" then
		newRegion = parent:CreateTexture(name);
		newRegion:SetTexture(region:GetTexture());
		newRegion:SetTexCoord(region:GetTexCoord());
	elseif Type == "FontString" then
		newRegion = parent:CreateFontString(name);
		newRegion:SetFontObject(region:GetFontObject());
		newRegion:SetTextColor(region:GetTextColor());
		newRegion:SetText(region:GetText());
	else
		print(Type);
	end

	if newRegion then
		MatchAnchor(region,newRegion);
	end
end

local CloneFrame;
CloneFrame = function(frame,name,parent)  print("Create",name)
	local newFrame = CreateFrame(frame:GetObjectType(),name,parent);
	MatchAnchor(frame,newFrame);

	local children = {frame:GetChildren()};
	for i,c in pairs(children) do
		CloneFrame(c,gsub(c:GetName(),frame:GetName(),newFrame:GetName()),newFrame);
	end

	local regions = {frame:GetRegions()};
	for i,r in pairs(regions) do
		local n;
		if r:GetName() then
			n = gsub(r:GetName(),frame:GetName(),newFrame:GetName());
		end
		CloneRegion(r,n,newFrame);
	end

	local Type = frame:GetObjectType();
	if Type == "Button" or Type == "CheckButton" then
   		if frame:GetNormalFontObject() then newFrame:SetNormalFontObject(frame:GetNormalFontObject()); end
		if frame:GetDisabledFontObject() then newFrame:SetDisabledFontObject(frame:GetDisabledFontObject()); end
		if frame:GetHighlightFontObject() then newFrame:SetHighlightFontObject(frame:GetHighlightFontObject()); end
		newFrame:SetText(frame:GetText());
		newFrame:SetNormalTexture(frame:GetNormalTexture());
		newFrame:SetPushedTexture(frame:GetPushedTexture());
		newFrame:SetHighlightTexture(frame:GetHighlightTexture());
		newFrame:SetDisabledTexture(frame:GetDisabledTexture());
	else
	end

	return newFrame
end       --]]



local variablesLoaded;
GHI_Event("GHI_ITEM_INFO_LOADED",function()
	variablesLoaded = true;
end)

local class;
function GHI_ActionBarUI(clickFunc,getInfoFunc,tooltipFunc)
	if class then
		return class;
	end
	class = GHClass("GHI_ActionBarUI");

	local saved = GHI_SavedData("GHI_ActionBarData");
	local showingAllBars = false;
	local buttons = {};
	local savedData;

	local ClearItem = function(button)
		local iconFrame = _G[button:GetName().."Icon"];
		local cooldownFrame = _G[button:GetName().."Cooldown"];
		iconFrame:Hide();
		cooldownFrame:Hide();
		SetItemButtonCount(button,0);
		button.guid = nil;
		saved.SetVar(button:GetName(),nil);
	end

	local ButtonScripts = function(ghButton)
		ghButton:SetScript("OnClick",function()
			ghButton:SetChecked(false);
			if ghButton.guid then
				clickFunc(ghButton.guid);
			end
		end);
		ghButton:SetScript("OnDragStart",function()
			local cursor = GHI_CursorHandler();
			if ghButton.guid then
				cursor.SetCursor("ITEM", ghButton.icon, function() end, function()end, "GHI_ITEM_REF", nil, nil, nil, nil, ghButton.guid);
				ClearItem(ghButton);
			else
				error("No guid for dragging")
			end
		end);
		ghButton:SetScript("OnEnter",function()
			if ghButton.guid then
				tooltipFunc(ghButton,ghButton.guid)
			end
		end)

		ghButton:SetScript("OnLeave",function()
			GameTooltip:Hide();

		end)
	end

	local SetItem = function(button,guid)
		local icon,count,total, elapsed  = getInfoFunc(guid);

		local iconFrame = _G[button:GetName().."Icon"];
		local cooldownFrame = _G[button:GetName().."Cooldown"];

		iconFrame:SetTexture(icon);
		iconFrame:Show();
		SetItemButtonCount(button,count);

		if not (elapsed) then
			cooldownFrame:Hide();
		else
			CooldownFrame_SetTimer(cooldownFrame, GetTime() - (elapsed), total, 1);
		end


		button:SetChecked(false);
		local setup = (button.guid ~= guid)
		button.guid = guid;
		button.icon = icon;


		local index = button:GetName();
		local savedGuid = savedData[index];
		if not(guid == savedGuid) then
			savedData[index] = guid;
			saved.SetVar(index,guid);
		end
		if setup then
			ButtonScripts(button);
		end

	end



	class.ShowAll = function(guid,icon,clearFunc)
		for barName,b in pairs(buttons) do
			local origButton = b.origButton;
			local ghButton = b.ghButton;
			ghButton:Show();
			ghButton:SetScript("OnClick",function()
				SetItem(ghButton,guid)
				b.guid = guid;
				class.HideEmpty();
				if clearFunc then
					clearFunc();
				end
			end)
		end
	end



	class.HideEmpty = function()
		for barName,b in pairs(buttons) do
			local origButton = b.origButton;
			local ghButton = b.ghButton;
			if not(ghButton.guid) then
				ghButton:Hide();
			end
			ButtonScripts(ghButton);

		end
	end


	local GenerateGHButton = function(actionButton)
		local b = CreateFrame("CheckButton",actionButton:GetName().."GH",actionButton:GetParent(),"ActionButtonTemplate") --SecureActionButtonTemplate
		b:ClearAllPoints();
		b:SetAllPoints(actionButton);
		b:Hide();
		b:RegisterForDrag("LeftButton","RightButton");
		b:RegisterForClicks("LeftButtonUp","RightButtonUp");
		if actionButton:GetNormalTexture() then
			local texture = actionButton:GetNormalTexture();
			if string.startsWith(actionButton:GetName(),"BT4Button") then
				b:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2");
				local newTexture = b:GetNormalTexture();
				newTexture:SetTexCoord(texture:GetTexCoord());
			else
				b:SetNormalTexture(texture:GetTexture() or "Interface\\Buttons\\UI-Quickslot2");
				local newTexture = b:GetNormalTexture();
				newTexture:SetTexCoord(texture:GetTexCoord());
			end
		else
			b:SetNormalTexture(nil);
		end  --]]
		b:SetFrameStrata(actionButton:GetFrameStrata());
		b:SetFrameLevel(actionButton:GetFrameLevel() + 1);

		local t = savedData[b:GetName()];
		if type(t) == "string" then
			SetItem(b,t);
			b:Show();
		end     --]]

		return b;
	end

	GHI_Event("GHI_BAG_UPDATE_COOLDOWN",function(stackGuid,guid)
		for barName,b in pairs(buttons) do
			local ghButton = b.ghButton;
			if ghButton.guid == guid then
				local icon,count,total, elapsed  = getInfoFunc(guid);
				local cooldownFrame = _G[button:GetName().."Cooldown"];

				if not (elapsed) then
					cooldownFrame:Hide();
				else
					CooldownFrame_SetTimer(cooldownFrame, GetTime() - (elapsed), total, 1);
				end
			end
		end
	end);

	GHI_Event("GHI_CONTAINER_UPDATE",function()
		for barName,b in pairs(buttons) do
			local ghButton = b.ghButton;
			SetItem(ghButton,ghButton.guid);
		end
	end);

	local NewButton = function(mirror)
		if not(buttons[mirror:GetName()]) then
			buttons[mirror:GetName()] = {
				origButton = mirror,
				ghButton = GenerateGHButton(mirror),
			};
		end
	end

    local Initialize = function()
		savedData = saved.GetAll();

		-- convert saved data from before v.2.0 format
		local buttonPrefixes = {
			[6] = "MultiBarBottomLeftButton%sGH",
			[5] = "MultiBarBottomRightButton%sGH",
			[4] = "MultiBarLeftButton%sGH",
			[3] = "MultiBarRightButton%sGH",
		};
		for index,data in pairs(savedData) do
			if type(index) == "number" and buttonPrefixes[index] then
				if type(data) == "table" then -- loop trough the data for the given actionbar
					for i,value in pairs(data) do
						local newIndex = string.format(buttonPrefixes[index],i);
						savedData[newIndex] = value;
					end
					saved.SetVar(index,nil);
				end
			end
		end

		local func = function(s,e)
			NewButton(s);
		end
		--hooksecurefunc("ActionButton_OnUpdate",func);
		hooksecurefunc("ActionButton_OnEvent",func);

		GHI_Event().TriggerEventOnAllFrames("ACTIONBAR_SHOWGRID");

		-- Look for eventual bartender buttons
		for i=1,100 do
			if _G["BT4Button"..i] then
				NewButton(_G["BT4Button"..i]);
			end
		end
	end



	if variablesLoaded then
		Initialize();
	else
		GHI_Event("GHI_ITEM_INFO_LOADED",function()
			Initialize();
		end)
	end

	return class;
end

