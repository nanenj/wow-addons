--===================================================
--
--				GHM_Text
--  			GHM_Text.lua
--
--	          EditBox object for GHM
--
-- 	  (c)2012 The Gryphonheart Team
--			All rights reserved
--===================================================

local DEFAULT_WIDTH = 300;
local DEFUALT_HEIGHT = 20;
local count = 1;

function GHM_Text(parent, main, profile)
	local frame = CreateFrame("Frame", "GHM_Text" .. count, parent, "GHM_Text_Template");
	count = count + 1;

	-- declaration and initialization
	profile = profile or {};

	-- setup
	local labelFrame = _G[frame:GetName() .. "Label"];

	if profile.fontSize then
		labelFrame:SetFont("Fonts\\FRIZQT__.TTF", profile.fontSize);
	end

	labelFrame:SetText("");
	if profile.color == "white" then
		labelFrame:SetTextColor(1, 1, 1);
	end

	if profile.align == "c" then
		labelFrame:SetJustifyH("CENTER");
	elseif profile.align == "r" then
		labelFrame:SetJustifyH("RIGHT");
	else
		labelFrame:SetJustifyH("LEFT");
	end



	--[[
	local width = profile.width or labelFrame:GetWidth();
	frame:SetWidth(width);
	labelFrame:SetWidth(width);

	if profile.singleLine == true then
		frame:SetHeight(labelFrame:GetHeight());
	else
		frame:SetHeight(labelFrame:GetHeight());
	end
	              --]]






	frame.Force = function(self, text)
		if self ~= frame then return frame.Force(frame, self); end

		labelFrame:SetText(text);

		if profile.width then
			frame:SetWidth(profile.width);
			labelFrame:SetWidth(profile.width);

			frame:SetHeight(labelFrame:GetHeight()+15)
		else
			frame:SetWidth(labelFrame:GetWidth());

		end
	end
	frame.Force(profile.text);


	GHM_FramePositioning(frame,profile,parent);

	if type(profile.OnLoad) == "function" then
		profile.OnLoad(frame);
	end

	frame:Show();
	--GHM_TempBG(frame);

	return frame;
end

