--===================================================
--									
--							GHI Backpack Button
--								ghi_buttonUI.lua
--
--	Moveable button for opening of the main GHI bag
--
-- 						(c)2012 The Gryphonheart Team
--								All rights reserved
--===================================================

function GHI_Button()
	local class = GHClass("GHI_Button");

	local loc = GHI_Loc();

	local OnMove, OnEnter, OnClick, PositionChangeCallbackFunc;

	local squaredButton = CreateFrame("CheckButton", "GHI_ButtonSquared", UIParent, "ItemButtonTemplate");
	squaredButton:Hide();

	squaredButton:SetScript("OnUpdate", function(b) if b.iconDrag then OnMove(b) end end)
	squaredButton:SetScript("OnDragStart", function(b) b.iconDrag = true end)
	squaredButton:SetScript("OnDragStop", function(b) b.iconDrag = false end)
	squaredButton:SetScript("OnEnter", function(b) OnEnter(b) end)
	squaredButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
	squaredButton:SetScript("OnClick", function(b) OnClick(b) end)
	squaredButton:RegisterForDrag("LeftButton")
	squaredButton:SetMovable();
	squaredButton:SetFrameStrata("MEDIUM");
	squaredButton:SetFrameLevel(8);
	squaredButton:SetCheckedTexture("Interface\\Buttons\\CheckButtonHilight");

	local roundButton = CreateFrame("Button", "GHI_ButtonRound", UIParent)
	roundButton:SetHeight(33);
	roundButton:SetWidth(33);

	local overlay = roundButton:CreateTexture(nil, "OVERLAY");
	overlay:SetWidth(56);
	overlay:SetHeight(56);
	overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder");
	overlay:SetPoint("TOPLEFT", 0, 0);
	roundButton.overlay = overlay;

	local icon = roundButton:CreateTexture(nil, "BACKGROUND");
	icon:SetWidth(18);
	icon:SetHeight(18);
	icon:SetTexture("Interface\\AddOns\\GHI\\Textures\\GH_RoundIcon")
	icon:SetPoint("TOPLEFT", 8, -8);
	icon:SetTexCoord(.075, .925, .075, .925)
	roundButton.icon = icon;

	roundButton:SetScript("PreClick", function() PlaySound("igMainMenuOptionCheckBoxOn") end);

	roundButton:SetFrameStrata("MEDIUM");
	roundButton:SetFrameLevel(8);
	roundButton:Hide();
	roundButton:RegisterForClicks("AnyUp")

	--roundButton:SetScript("OnMouseDown", function(b) b.icon:SetTexCoord(0,1,0,1) end);
	--roundButton:SetScript("OnMouseUp", function(b) b.icon:SetTexCoord(.075,.925,.075,.925) end);
	roundButton:Hide();

	roundButton:SetScript("OnUpdate", function(b) if b.iconDrag then OnMove(b) end end)
	roundButton:SetScript("OnDragStart", function(b) b.iconDrag = true end)
	roundButton:SetScript("OnDragStop", function(b) b.iconDrag = false end)
	roundButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
	roundButton:RegisterForDrag("LeftButton")
	roundButton:SetMovable();
	roundButton:SetScript("OnEnter", function(b) OnEnter(b) end)
	roundButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
	roundButton:SetScript("OnClick", function(b) OnClick(b) end)

	OnMove = function(b)
		if IsShiftKeyDown() then
			local _x, _y = GetCursorPosition();
			local s = b:GetEffectiveScale();

			local x, y = _x / s, _y / s;
			roundButton:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y);
			squaredButton:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y);
			PositionChangeCallbackFunc(x, y);
		end
	end

	OnEnter = function(b)
		GameTooltip:SetOwner(b, "ANCHOR_LEFT");
		GameTooltip:ClearLines()
		GameTooltip:AddLine(loc.BAG_BNT, 1.0, 1.0, 1.0);
		GameTooltip:AddLine(loc.BAG_DRAG);

		GameTooltip:Show();
	--self.UpdateTooltip = nil;
	end

	OnClick = function(b)
		GHI_ToggleBackpack();
	end

	class.UseSquared = function()
		roundButton:Hide();
		squaredButton:Show();
	end
	class.UseRound = function()
		squaredButton:Hide();
		roundButton:Show();
	end

	class.ResetPosition = function()
		local x, y = UIParent:GetWidth() / 2, UIParent:GetHeight() / 2;
		roundButton:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y);
		squaredButton:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y);
		PositionChangeCallbackFunc(x, y);
	end

	class.SetPosition = function(x, y)
		roundButton:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y);
		squaredButton:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y);
		PositionChangeCallbackFunc(x, y);
	end

	class.SetChangePositionCallbackFunction = function(func)
		PositionChangeCallbackFunc = func;
	end

	class.SetScale = function(scale)
		squaredButton:SetWidth(scale * 37);
		squaredButton:SetHeight(scale * 37);
		_G[squaredButton:GetName() .. "NormalTexture"]:SetHeight(64 * scale);
		_G[squaredButton:GetName() .. "NormalTexture"]:SetWidth(64 * scale);

		roundButton:SetWidth(scale * 33);
		roundButton:SetHeight(scale * 33);
		roundButton.icon:SetWidth(scale * 18);
		roundButton.icon:SetHeight(scale * 18);
		roundButton.overlay:SetWidth(scale * 56);
		roundButton.overlay:SetHeight(scale * 56);
		roundButton.icon:SetPoint("TOPLEFT", scale * 8, scale * (-7));
		local s = (.075 * scale);
		roundButton.texCoor = s;
		roundButton.icon:SetTexCoord(s, 1 - s, s, 1 - s)
	end

	class.SetTexture = function(texture)
		SetItemButtonTexture(squaredButton, texture);
		roundButton.icon:SetTexture(texture);
	end



	class.SetScale(1);
	class.UseSquared();



	return class;
end