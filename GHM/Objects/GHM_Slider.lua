--===================================================
--
--				GHM_Slider
--  			GHM_Slider.lua
--
--	          GHM_Slider object for GHM
--
-- 	  (c)2012 The Gryphonheart Team
--			All rights reserved
--===================================================

local count = 1;

function GHM_Slider(parent, main, profile)
	local frame = CreateFrame("Frame", "GHM_Slider" .. count, parent, "GHM_Slider_Template");
	count = count + 1;

	-- declaration and initialization
	profile = profile or {};
	local label = profile.label;

	-- setup
	local labelFrame = _G[frame:GetName() .. "TextLabel"];
	local slider = _G[frame:GetName() .. "Slider"];
	local valueLabel = _G[slider:GetName() .. "ValueLabel"];



	labelFrame:SetText(profile.text or "");

	local width = profile.width or frame:GetWidth();
	frame:SetWidth(width);
	editBox:SetWidth(width);
	_G[editBox:GetName() .. "Left"]:SetWidth(width - 10);



	GHM_FramePositioning(frame,profile,parent);



	-- functions
	local varAttFrame;

	local Force1 = function(data)
		if type(data) == "string" or type(data) == "number" then
			editBox:SetText(data);
		end
	end

	local Force2 = function(inputType, inputValue)
		if (inputType == "attribute" or inputType == "variable") and varAttFrame then
			editBox:SetText("");
			varAttFrame:SetValue(inputType, inputValue);

		else -- static
			varAttFrame:Clear();
			editBox:SetText(inputValue);
		end
	end

	frame.Force = function(self, ...)
		if self ~= frame then return frame.Force(frame, self, ...); end
		local numInput = #({ ... });

		if numInput == 1 then
			Force1(...);
		elseif numInput == 2 then
			Force2(...);
		end
	end

	frame.Clear = function(self)
		editBox:SetText("");
	end


	frame.EnableVariableAttributeInput = function(self, scriptingEnv, item)
		if not (varAttFrame) then
			varAttFrame = GHM_VarAttInput(frame, editBox, editBox:GetWidth());
			frame:SetHeight(DEFUALT_HEIGHT + 15);
		end
		varAttFrame:EnableVariableAttributeInput(scriptingEnv, item, profile.outputOnly)
	end

	frame.GetValue = function(self)
		if (varAttFrame and not (varAttFrame:IsStaticTabShown())) then
			return varAttFrame:GetValue();
		else
			if editBox.numbersOnly then
				return tonumber(editBox:GetText()) or 0;
			else
				return editBox:GetText();
			end
		end
	end



	if type(profile.OnLoad) == "function" then
		profile.OnLoad(frame);
	end


	frame:Show();
	--GHM_TempBG(frame);

	return frame;
end

