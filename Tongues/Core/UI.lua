

local function BoolToNum(boolvalue)
	local numval = nil;
	if boolvalue == true then
		numval = 1;
	else
		numval = 0;
	end;
	return numval;
end;
--=============================================================================================
	Tongues.UI = {
		Configure = function(self)
			self.MiniMenu:Configure();
			self.MainMenu:Configure();
		end;

		LoadDefaults = function(self)
			-- Get previous checkbox settings

			for k,v in pairs(Tongues.UI.MainMenu.Translations) do
				if k ~= "Configure" then
					Tongues.UI.MainMenu.Translations[k].Frame:SetChecked(
					BoolToNum(Tongues.Settings.Character.Translations[k]))
				end;
			end;

			for k,v in pairs(Tongues.UI.MainMenu.Screen) do
				if k ~= "Configure" then
					Tongues.UI.MainMenu.Screen[k].Frame:SetChecked(
					BoolToNum(Tongues.Settings.Character.Screen[k]))
				end;
			end;
			
			
			Tongues.UI.MainMenu.Speak.MiniHide.Frame:SetChecked(
					BoolToNum(Tongues.Settings.Character.MMH))-- MERGE
					
					if (Tongues.UI.MainMenu.Speak.MiniHide.Frame:GetChecked() == 1) then
							TonguesMiniMenu:Hide();
							
						else
							TonguesMiniMenu:Show();
						end;--MERGE

			Tongues.UI.MainMenu.Speak.ShapeshiftLanguage.Frame:SetChecked(BoolToNum(Tongues.Settings.Character.ShapeshiftLanguage))

			UIDropDownMenu_SetSelectedValue(Tongues.UI.MainMenu.Speak.LanguageDropDown.Frame, Tongues.Settings.Character.Language); 
			--**WOTLK FIX
			UIDropDownMenu_SetText(Tongues.UI.MainMenu.Speak.LanguageDropDown.Frame, Tongues.Settings.Character.Language);
		
			UIDropDownMenu_SetSelectedValue(Tongues.UI.MainMenu.Speak.AffectDropDown.Frame,Tongues.Settings.Character.Affect); 
			--**WOTLK FIX
			UIDropDownMenu_SetText(Tongues.UI.MainMenu.Speak.AffectDropDown.Frame, Tongues.Settings.Character.Affect);
			
			UIDropDownMenu_SetSelectedValue(Tongues.UI.MainMenu.Speak.DialectDropDown.Frame,Tongues.Settings.Character.Dialect);
			
			--**WOTLK FIX
			UIDropDownMenu_SetText(Tongues.UI.MainMenu.Speak.DialectDropDown.Frame, Tongues.Settings.Character.Dialect);

			UIDropDownMenu_SetSelectedValue(Tongues.UI.MainMenu.Hear.Filter.Frame,Tongues.Settings.Character.Filter);
			--**WOTLK FIX
			UIDropDownMenu_SetText(Tongues.UI.MainMenu.Hear.Filter.Frame, Tongues.Settings.Character.Filter);

			Tongues.UI.MiniMenu.Frame:SetPoint(Tongues.Settings.Character.UI.MiniMenu.point, UIParent, Tongues.Settings.Character.UI.MiniMenu.relativePoint, Tongues.Settings.Character.UI.MiniMenu.xOfs, Tongues.Settings.Character.UI.MiniMenu.yOfs);
			Tongues.UI.MainMenu.Frame:SetPoint(Tongues.Settings.Character.UI.MainMenu.point, UIParent, Tongues.Settings.Character.UI.MainMenu.relativePoint, Tongues.Settings.Character.UI.MainMenu.xOfs, Tongues.Settings.Character.UI.MainMenu.yOfs);

			Tongues.UI.MainMenu.Speak.AffectFrequency.Frame:SetValue(Tongues.Settings.Character.AffectFrequency);

			--**WOTLK FIX
			--Tongues.UI.MainMenu.Speak.LoreCompatibility.Frame:SetChecked(BoolToNum(Tongues.Settings.Character.LoreCompatibility));

			Tongues.UI.MainMenu.Speak.LanguageLearn.Frame:SetChecked(BoolToNum(Tongues.Settings.Character.LanguageLearning));
			
			InterfaceOptions_AddCategory(Tongues.UI.MainMenu.Frame);
		end;

		MiniMenu = {
			Frame;
			texture  = {};
			text	 = {};

			Configure = function(self)

				self.Frame = CreateFrame("Button","TonguesMiniMenu",UIParent, "UIPanelButtonTemplate");
				self.Frame:SetScript("OnDragStart", self.OnDragStart);
				self.Frame:SetScript("OnDragStop", self.OnDragStop);
				self.Frame:SetScript("OnMouseUp", self.OnMouseUp);
				self.Frame:SetFrameStrata("MEDIUM")
				self.Frame:SetMovable(true)
				self.Frame:SetWidth(100)
		    	    	self.Frame:SetHeight(36)
				self.Frame:SetPoint("CENTER", UIParent, "CENTER", 0,0);
				--self.texture[1] = self.Frame:CreateTexture("settings","BUTTON")		
				--self.texture[1]:SetTexture("Interface\\Icons\\Spell_Shadow_SoulLeech")
				--self.texture[1]:SetAllPoints();
				self.Frame:EnableMouse(true);
				self.Frame:RegisterForDrag("LeftButton");
				self.Frame:RegisterForClicks("RightButton");
				
				self.Frame:Show();
			end;

			OnMouseUp = function(self,button)
				if button == "RightButton" then
				  if IsAltKeyDown() then
				  Tongues:UpdateDialectContext2();
	              Tongues.MenuClass:Show();
				  else
					self:Hide();
					Tongues.UI.MainMenu.Frame:Show();
				 end
				else
				   --if countLangauge() ~= 0 then
					Tongues:CycleLanguage();
					--end
				end;
			end;

			OnDragStart = function (self)
				self:StartMoving();
			end;

			OnDragStop = function (self)
				self:StopMovingOrSizing();
				Tongues.Settings.Character.UI.MiniMenu.point, Tongues.Settings.Character.UI.MiniMenu.relativeTo, Tongues.Settings.Character.UI.MiniMenu.relativePoint, Tongues.Settings.Character.UI.MiniMenu.xOfs, Tongues.Settings.Character.UI.MiniMenu.yOfs = self:GetPoint();
			end;
		};
        	
		MainMenu = {
			Frame;
			texture  = {};
			text	 = {};

			Configure = function(self)
				self.Frame = CreateFrame("Frame","TonguesMainMenu",UIParent);
				self.Frame:SetScript("OnKeyUp", self.OnKeyDown);
				self.Frame:SetScript("OnDragStart", self.OnDragStart);
				self.Frame:SetScript("OnDragStop", self.OnDragStop);
				self.Frame:SetFrameStrata("DIALOG")
				self.Frame:SetMovable(true)
				self.Frame:SetWidth(348)
		    	    	self.Frame:SetHeight(440)
		    	    	self.Frame:SetPoint("CENTER", UIParent, "CENTER", 0,0);

				self.texture[1] = self.Frame:CreateTexture("settings","BORDER")
				self.texture[1]:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopLeft")
				self.texture[1]:SetPoint("TOPLEFT", self.Frame, "TOPLEFT", -4, 0);
				self.texture[3] = self.Frame:CreateTexture("settings","BORDER")
				self.texture[3]:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopRight")
				self.texture[3]:SetPoint("TOPRIGHT", self.Frame, "TOPRIGHT", 32, 0);
				self.texture[4] = self.Frame:CreateTexture("settings","BORDER")
				self.texture[4]:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomLeft")
				self.texture[4]:SetPoint("BOTTOMLEFT", self.Frame, "BOTTOMLEFT", -4, -72);
				self.texture[5] = self.Frame:CreateTexture("settings","BORDER")
				self.texture[5]:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomRight")
				self.texture[5]:SetPoint("BOTTOMRIGHT", self.Frame, "BOTTOMRIGHT", 32, -72);
				self.text[1] = self.Frame:CreateFontString("settings","BUTTON")
				self.text[1]:SetFont(GameFontNormal:GetFont(),12);
				self.text[1]:SetText('|cffffffffTongues Menu|r')
				self.text[1]:SetPoint("TOP", self.Frame, "TOP", 10, -16);
				self.text[2] = self.Frame:CreateFontString("settings","BUTTON")
				self.text[2]:SetFont(GameFontNormal:GetFont(),12);
				self.text[2]:SetText('|cffffff00v ' .. Tongues.Version .. '|r')
				self.text[2]:SetPoint("TOP", self.Frame, "TOP", 10, -50);

				self.Frame:EnableMouse(true);
				--self.Frame:EnableKeyboard(true);
				self.Frame:RegisterForDrag("LeftButton");

				self.Minimize:Configure();
				self.CloseButton:Configure();
				self.AdvancedButton:Configure();

				-------Speak Tab-------------------
				self.Speak:Configure();	
				self.SpeakButton:Configure();

				-------Understand Tab--------------
				self.Understand:Configure();
				self.UnderstandButton:Configure();


				-------Hear Tab--------------------
				self.Hear:Configure();
				self.HearButton:Configure();
				
				-------Advanced Tab----------------
				self.AdvancedOptions:Configure();
				
				self.Frame:Hide();
			end;

			OnKeyDown = function (self,button)
				if button == "ESCAPE" then
					self:Hide()
					Tongues.UI.MiniMenu.Frame:Show()
				end;
			end;

			OnDragStart = function (self)
				self:StartMoving();
			end;

			OnDragStop = function (self)
				self:StopMovingOrSizing();
				Tongues.Settings.Character.UI.MainMenu.point, Tongues.Settings.Character.UI.MainMenu.relativeTo, Tongues.Settings.Character.UI.MainMenu.relativePoint, Tongues.Settings.Character.UI.MainMenu.xOfs, Tongues.Settings.Character.UI.MainMenu.yOfs = self:GetPoint();
			end;
			--=======================================================================================================
			SpeakButton = {
				Frame;
				texture  = {};
				text	 = {};

				Configure = function(self)
					self.Frame = CreateFrame("Button","TonguesMainMenu",Tongues.UI.MainMenu.Frame, "UIPanelButtonTemplate");
					self.Frame:SetScript("OnKeyUp", self.OnKeyUp);
					self.Frame:SetScript("OnMouseDown", self.OnMouseDown);
					self.Frame:SetScript("OnMouseUp", self.OnMouseUp);
					self.Frame:SetFrameStrata("DIALOG")
					self.Frame:SetMovable(true)
					self.Frame:SetWidth(105)
			    	    	self.Frame:SetHeight(20)
					self.Frame:SetText("Speak");

					self.Frame:SetPoint("TOPLEFT",Tongues.UI.MainMenu.Frame, "TOPLEFT", 20, -80);

					self.Frame:EnableMouse(true);
					self.Frame:RegisterForClicks("LeftButton");
					self.Frame:Show();
				end;

				OnMouseUp = function()
					Tongues.UI.MainMenu.Speak.Frame:Show();
					Tongues.UI.MainMenu.Understand.Frame:Hide();
					Tongues.UI.MainMenu.Hear.Frame:Hide();
				end;
			};
			--=======================================================================================================
			UnderstandButton = {
				Frame;
				texture  = {};
				text	 = {};

				Configure = function(self)
					self.Frame = CreateFrame("Button","TonguesUnderstandButton",Tongues.UI.MainMenu.Frame, "UIPanelButtonTemplate");
					self.Frame:SetScript("OnKeyUp", self.OnKeyUp);
					self.Frame:SetScript("OnMouseDown", self.OnMouseDown);
					self.Frame:SetScript("OnMouseUp", self.OnMouseUp);
					self.Frame:SetFrameStrata("DIALOG")
					self.Frame:SetMovable(true)
					self.Frame:SetWidth(105)
			    	    	self.Frame:SetHeight(20)
					self.Frame:SetText("Understand");

					self.Frame:SetPoint("LEFT",Tongues.UI.MainMenu.SpeakButton.Frame, "RIGHT", 0, 0);

					self.Frame:EnableMouse(true);
					self.Frame:RegisterForClicks("LeftButton");
					self.Frame:Show();
				end;

				OnMouseUp = function()
					Tongues.UI.MainMenu.Speak.Frame:Hide();
					Tongues.UI.MainMenu.Understand.Frame:Show();
					Tongues.UI.MainMenu.Hear.Frame:Hide();
				end;
			};
			--=======================================================================================================
			HearButton = {
				Frame;
				texture  = {};
				text	 = {};

				Configure = function(self)
					self.Frame = CreateFrame("Button","TonguesHearButton",Tongues.UI.MainMenu.Frame, "UIPanelButtonTemplate");
					self.Frame:SetScript("OnKeyUp", self.OnKeyUp);
					self.Frame:SetScript("OnMouseDown", self.OnMouseDown);
					self.Frame:SetScript("OnMouseUp", self.OnMouseUp);
					self.Frame:SetFrameStrata("DIALOG")
					self.Frame:SetMovable(true)
					self.Frame:SetWidth(105)
			    	    	self.Frame:SetHeight(20)
					self.Frame:SetText("Hear");

					self.Frame:SetPoint("LEFT",Tongues.UI.MainMenu.UnderstandButton.Frame, "RIGHT", 0, 0);

					self.Frame:EnableMouse(true);
					self.Frame:RegisterForClicks("LeftButton");
					self.Frame:Show();
				end;

				OnMouseUp = function()
					Tongues.UI.MainMenu.Speak.Frame:Hide();
					Tongues.UI.MainMenu.Understand.Frame:Hide();
					Tongues.UI.MainMenu.Hear.Frame:Show();
				end;
			};
			--=======================================================================================================
			--Speak
			Speak = {
				Frame;
				texture  = {};
				text	 = {};

				Configure = function(self)
					self.Frame = CreateFrame("Frame","TonguesMainMenu",Tongues.UI.MainMenu.Frame);
					self.Frame:SetScript("OnKeyUp", self.OnKeyUp);
					self.Frame:SetScript("OnDragStart", self.OnDragStart);
					self.Frame:SetScript("OnDragStop", self.OnDragStop);
					self.Frame:SetFrameStrata("DIALOG")
					self.Frame:SetMovable(true)
					self.Frame:SetWidth(60)
			    	    	self.Frame:SetHeight(20)
					--self.Frame:SetText("Speak");

					self.Frame:SetPoint("TOPLEFT",Tongues.UI.MainMenu.Frame, "TOPLEFT", 20, -100);

					--self.Frame:EnableMouse(true);
	
					-------Speak Tab-------------------
					self.LanguageDropDown:Configure();
					self.ShapeshiftLanguage:Configure();
					self.DialectDropDown:Configure();
					--self.DialectDrift:Configure();
					self.AffectDropDown:Configure();
					self.AffectFrequency:Configure();
					--self.LoreCompatibility:Configure();
					self.LanguageLearn:Configure();
					self.MiniHide:Configure();--MERGE

					self.Frame:Show();
				end;
				---------------------------------------------------------------------------------------------
				LanguageDropDown = {
					Frame;
					texture  = {};
					text	 = {};
				
					Configure = function(self)
						self.Frame = CreateFrame("Button", "LanguageDownMenu", Tongues.UI.MainMenu.Speak.Frame, "UIDropDownMenuTemplate"); 
						self.Frame:SetPoint("LEFT",Tongues.UI.MainMenu.Speak.Frame, "TOPLEFT", 55, -20);

						self.text[2] = self.Frame:CreateFontString("settings","BUTTON")
						self.text[2]:SetFont(GameFontNormal:GetFont(),12);
						self.text[2]:SetText('|cffffffffLanguage|r')
						self.text[2]:SetPoint("LEFT", self.Frame, "LEFT", -55, 0 ); 
						--UIDropDownMenu_Initialize(self.Frame, self.Initialize);	
		
						self.Frame:Show();
					end;
				
					--Initialize = function()
					--	local info            = {};
					--	local k,v;
					--
					--	for k,v in Tongues.PairsByKeys(Tongues.Language) do
					--		local fluency = Tongues.Settings.Character.Fluency[k] or 0
					--		if fluency >= 30 then
					--			info.text       = k;
					--			info.value      = k;
					--			info.checked 	= nil; 
					--			info.func       = Tongues.UI.MainMenu.Speak.LanguageDropDown.OnClick;
					--			UIDropDownMenu_AddButton(info);
					--		end;
					--	end;		
					--end;
				
					OnClick = function(self)
					 --lang = UIDropDownMenu_GetSelectedValue("LanguageDownMenu") 
						Tongues:SetLanguage(self.value)
					end;
				};
				---------------------------------------------------------------------------------------------
				DialectDropDown = {
					Frame;
					texture  = {};
					text	 = {};
				
					Configure = function(self)
						self.Frame = CreateFrame("Button", "DialectDownMenu", Tongues.UI.MainMenu.Speak.Frame, "UIDropDownMenuTemplate"); 
						self.Frame:SetPoint("LEFT",Tongues.UI.MainMenu.Speak.Frame, "TOPLEFT", 55, -45); 	
						self.text[1] = self.Frame:CreateFontString("settings","BUTTON")
						self.text[1]:SetFont(GameFontNormal:GetFont(),12);
						self.text[1]:SetText('|cffffffffDialect|r')
						self.text[1]:SetPoint("LEFT", self.Frame, "LEFT", -55, 0 );
	
						UIDropDownMenu_Initialize(self.Frame, self.Initialize);
						
						self.Frame:Show();
					end;
				
					Initialize = function()
						local info            = {};
						local k,v;
						for k,v in Tongues.PairsByKeys(Tongues.Dialect) do
							info.text       = k;
							info.value      = k;
							info.checked = nil; 
							info.func       = Tongues.UI.MainMenu.Speak.DialectDropDown.OnClick;
							UIDropDownMenu_AddButton(info);
						end;		
					end;
				
					OnClick = function(self)
						UIDropDownMenu_ClearAll(Tongues.UI.MainMenu.Speak.DialectDropDown.Frame);
						UIDropDownMenu_SetSelectedValue(Tongues.UI.MainMenu.Speak.DialectDropDown.Frame, self.value)
						--print(UIDropDownMenu_GetSelectedValue(Tongues.UI.MainMenu.Speak.DialectDropDown.Frame:GetText()))
						Tongues.Settings.Character.Dialect = self.value--Tongues.UI.MainMenu.Speak.DialectDropDown.Frame.value
					end;
				};
				---------------------------------------------------------------------------------------------
				AffectDropDown = {
					Frame;
					texture  = {};
					text	 = {};
				
					Configure = function(self)
						self.Frame = CreateFrame("Button", "AffectDownMenu", Tongues.UI.MainMenu.Speak.Frame, "UIDropDownMenuTemplate"); 
						self.Frame:SetPoint("LEFT",Tongues.UI.MainMenu.Speak.Frame, "TOPLEFT", 55, -70); 	
						self.text[1] = self.Frame:CreateFontString("settings","BUTTON")
						self.text[1]:SetFont(GameFontNormal:GetFont(),12);
						self.text[1]:SetText('|cffffffffAffect|r')
						self.text[1]:SetPoint("LEFT", self.Frame, "LEFT", -55, 0 );
	
						UIDropDownMenu_Initialize(self.Frame, self.Initialize);		
						self.Frame:Show();
					end;
				
					Initialize = function()
						local info            = {};
						local k,v;
						for k,v in Tongues.PairsByKeys(Tongues.Affect) do
							info.text       = k;
							info.value      = k;
							info.checked = nil; 
							info.func       = Tongues.UI.MainMenu.Speak.AffectDropDown.OnClick;
							UIDropDownMenu_AddButton(info);
						end;		
					end;
				
					OnClick = function(self)
						UIDropDownMenu_ClearAll(Tongues.UI.MainMenu.Speak.AffectDropDown.Frame);
						UIDropDownMenu_SetSelectedValue(Tongues.UI.MainMenu.Speak.AffectDropDown.Frame, self.value); 
						 --affct = UIDropDownMenu_GetSelectedValue("AffectDownMenu") 
						Tongues.Settings.Character.Affect = self.value;
					end;
				};
				---------------------------------------------------------------------------------------------
				AffectFrequency = {
					Frame;
					texture  = {};
					text	 = {};
				
					Configure = function(self)
						self.Frame = CreateFrame("Slider", "AffectFrequencySlider", Tongues.UI.MainMenu.Speak.Frame, "OptionsSliderTemplate"); 
						self.Frame:SetPoint("LEFT",Tongues.UI.MainMenu.Speak.Frame, "TOPLEFT", 75, -90); 
						self.Frame:SetScript("OnMouseUp", self.OnMouseUp);
						self.Frame:SetMinMaxValues(0,100);
						self.Frame:SetValueStep(1);
			
						self.Frame:Show();
					end;
	
					OnMouseUp = function(self)
						Tongues.Settings.Character.AffectFrequency = Tongues.UI.MainMenu.Speak.AffectFrequency.Frame:GetValue();
					end;
				};
				---------------------------------------------------------------------------------------------
				DialectDrift = {
					Frame;
					texture  = {};
					text	 = {};
		
					Configure = function(self)
						self.Frame = CreateFrame("CheckButton","DialectDrift", Tongues.UI.MainMenu.Speak.Frame,"OptionsCheckButtonTemplate");
						self.Frame:SetScript("OnMouseDown", self.OnMouseDown);
						self.Frame:SetScript("OnMouseUp", self.OnMouseUp);				
						self.Frame:SetFrameStrata("DIALOG")
		
						self.text[1] = self.Frame:CreateFontString("settings","BUTTON")
						self.text[1]:SetFont(GameFontNormal:GetFont(),12);
						self.text[1]:SetText('|cffffffffDialect Drift|r')
						self.text[1]:SetPoint("LEFT", self.Frame, "LEFT",25, 0 );
		
						self.Frame:SetWidth(25)
				    	    	self.Frame:SetHeight(25)
						self.Frame:SetPoint("LEFT", Tongues.UI.MainMenu.Speak.Frame, "TOPLEFT",205,  -40);
						self.Frame:SetText("CheckBox Thing");
						self.Frame:EnableMouse(true);
						self.Frame:RegisterForClicks("LeftButton");		
						self.Frame:Show();
					end;
	
					OnMouseUp = function(self)
						Tongues.UI.MainMenu.Speak.DialectDrift.Frame:SetChecked(not Tongues.UI.MainMenu.Speak.DialectDrift.Frame:GetChecked());
								
						if (Tongues.UI.MainMenu.Speak.DialectDrift.Frame:GetChecked() == 1) then
							--Tongues.Settings.Character.Translations.Self = true;
						else
							--Tongues.Settings.Character.Translations.Self = false;
						end;
					end;
		
					OnMouseDown = function(self)
					end;
				};
				---------------------------------------------------------------------------------------------
				LanguageLearn = {
					Frame;
					texture  = {};
					text	 = {};
		
					Configure = function(self)
						self.Frame = CreateFrame("CheckButton","LanguageLearn", Tongues.UI.MainMenu.Speak.Frame,"OptionsCheckButtonTemplate");
						self.Frame:SetScript("OnMouseDown", self.OnMouseDown);
						self.Frame:SetScript("OnMouseUp", self.OnMouseUp);				
						self.Frame:SetFrameStrata("DIALOG")
		
						self.text[1] = self.Frame:CreateFontString("settings","BUTTON")
						self.text[1]:SetFont(GameFontNormal:GetFont(),12);
						self.text[1]:SetText('|cffffffffAutomatic Language Learning|r')
						self.text[1]:SetPoint("LEFT", self.Frame, "LEFT",25, 0 );
		
						self.Frame:SetWidth(25)
				    	    	self.Frame:SetHeight(25)
						self.Frame:SetPoint("LEFT", Tongues.UI.MainMenu.Speak.Frame, "TOPLEFT",0,  -170);
						self.Frame:SetText("CheckBox Thing");
						self.Frame:EnableMouse(true);
						self.Frame:RegisterForClicks("LeftButton");		
						self.Frame:Show();
					end;
	
					OnMouseUp = function(self)
						Tongues.UI.MainMenu.Speak.LanguageLearn.Frame:SetChecked(not Tongues.UI.MainMenu.Speak.LanguageLearn.Frame:GetChecked());

						if (Tongues.UI.MainMenu.Speak.LanguageLearn.Frame:GetChecked() == 1) then
							Tongues.Settings.Character.LanguageLearning = true;
						else
							Tongues.Settings.Character.LanguageLearning = false;
						end;
					end;
		
					OnMouseDown = function(self)
					end;
				};
				---------------------------------------------------------------------------------------------
				ShapeshiftLanguage = {
					Frame;
					texture  = {};
					text	 = {};
		
					Configure = function(self)
						self.Frame = CreateFrame("CheckButton","ShapeShiftLanguage", Tongues.UI.MainMenu.Speak.Frame,"OptionsCheckButtonTemplate");
						self.Frame:SetScript("OnMouseDown", self.OnMouseDown);
						self.Frame:SetScript("OnMouseUp", self.OnMouseUp);				
						self.Frame:SetFrameStrata("DIALOG")
		
						self.text[1] = self.Frame:CreateFontString("settings","BUTTON")
						self.text[1]:SetFont(GameFontNormal:GetFont(),12);
						self.text[1]:SetText('|cffffffffUse Shapeshifted Language|r')
						self.text[1]:SetPoint("LEFT", self.Frame, "LEFT",25, 0 );
		
						self.Frame:SetWidth(25)
				    	    	self.Frame:SetHeight(25)
						self.Frame:SetPoint("LEFT", Tongues.UI.MainMenu.Speak.Frame, "TOPLEFT", 0,  -150);
						self.Frame:SetText("CheckBox Thing");
						self.Frame:EnableMouse(true);
						self.Frame:RegisterForClicks("LeftButton");		
						self.Frame:Show();
					end;
		
					OnMouseUp = function(self)
						Tongues.UI.MainMenu.Speak.ShapeshiftLanguage.Frame:SetChecked(not Tongues.UI.MainMenu.Speak.ShapeshiftLanguage.Frame:GetChecked());
								
						if (Tongues.UI.MainMenu.Speak.ShapeshiftLanguage.Frame:GetChecked() == 1) then
							Tongues.Settings.Character.ShapeshiftLanguage = true;
							--print(Tongues.Settings.Character.ShapeshiftLanguage)
							--print(Tongues.UI.MainMenu.Speak.ShapeshiftLanguage.Frame:GetChecked())
						else
							Tongues.Settings.Character.ShapeshiftLanguage = false;
							--print(Tongues.Settings.Character.ShapeshiftLanguage)
							--print(Tongues.UI.MainMenu.Speak.ShapeshiftLanguage.Frame:GetChecked())
						end;
					end;
		
					OnMouseDown = function(self)
					end;
				};
				
				--MERGE
				MiniHide = {
				
					Frame;
					texture  = {};
					text	 = {};
	
					Configure = function(self)
						self.Frame = CreateFrame("CheckButton","HideMiniF", Tongues.UI.MainMenu.Speak.Frame,"OptionsCheckButtonTemplate");
						self.Frame:SetScript("OnMouseDown", self.OnMouseDown);
						self.Frame:SetScript("OnMouseUp", self.OnMouseUp);				
						self.Frame:SetFrameStrata("DIALOG")
	
						self.text[1] = self.Frame:CreateFontString("settings","BUTTON")
						self.text[1]:SetFont(GameFontNormal:GetFont(),12);
						self.text[1]:SetText('|cffffffffHide\nMiniMenu|r')
						self.text[1]:SetPoint("LEFT", self.Frame, "LEFT",25, 0 );
	
						self.Frame:SetWidth(25)
				    	    	self.Frame:SetHeight(25)
						self.Frame:SetPoint("LEFT", Tongues.UI.MainMenu.Speak.Frame, "TOPLEFT",0, -130);
						self.Frame:SetText("CheckBox Thing");
	
						self.Frame:EnableMouse(true);
						self.Frame:RegisterForClicks("LeftButton");		
						self.Frame:Show();
					end;
	
					OnMouseUp = function(self)
Tongues.UI.MainMenu.Speak.MiniHide.Frame:SetChecked(not Tongues.UI.MainMenu.Speak.MiniHide.Frame:GetChecked());

						if (Tongues.UI.MainMenu.Speak.MiniHide.Frame:GetChecked() == 1) then
							Tongues.Settings.Character.MMH = true;
							TonguesMiniMenu:Hide();
							
						else
							Tongues.Settings.Character.MMH = false;
							TonguesMiniMenu:Show();
						end;
					end;
	
					OnMouseDown = function(self)
					end;
				};
				---------------------------------------------------------------------------------------------
				LoreCompatibility = {
					Frame;
					texture  = {};
					text	 = {};
		
					Configure = function(self)
						self.Frame = CreateFrame("CheckButton","LoreCompatibility", Tongues.UI.MainMenu.Speak.Frame,"OptionsCheckButtonTemplate");
						self.Frame:SetScript("OnMouseDown", self.OnMouseDown);
						self.Frame:SetScript("OnMouseUp", self.OnMouseUp);				
						self.Frame:SetFrameStrata("DIALOG")
		
						self.text[1] = self.Frame:CreateFontString("settings","BUTTON")
						self.text[1]:SetFont(GameFontNormal:GetFont(),12);
						self.text[1]:SetText('|cffffffffLore Compatibility|r')
						self.text[1]:SetPoint("LEFT", self.Frame, "LEFT",25, 0 );
		
						self.Frame:SetWidth(25)
				    	    	self.Frame:SetHeight(25)
						self.Frame:SetPoint("LEFT", Tongues.UI.MainMenu.Speak.Frame, "TOPLEFT", 0,  -130);
						self.Frame:SetText("CheckBox Thing");
						self.Frame:EnableMouse(true);
						self.Frame:RegisterForClicks("LeftButton");		
						self.Frame:Show();
					end;
		
					OnMouseUp = function(self)
						Tongues.UI.MainMenu.Speak.LoreCompatibility.Frame:SetChecked(not Tongues.UI.MainMenu.Speak.LoreCompatibility.Frame:GetChecked());
						if Tongues.UI.MainMenu.Speak.LoreCompatibility.Frame:GetChecked() == 1 then
							RemoveChatWindowChannel(1, "xtensionxtooltip2")
							JoinChannelByName("xtensionxtooltip2")
							Tongues.Settings.Character.LoreCompatibility = true;
						else
							Tongues.Settings.Character.LoreCompatibility = false;
							LeaveChannelByName("xtensionxtooltip2")
						end;
					end;
		
					OnMouseDown = function(self)
					end;
				};

			};
			--=======================================================================================================
			--Understand
			Understand = {
				Frame;
				texture  = {};
				text	 = {};

				Configure = function(self)
					self.Frame = CreateFrame("Frame","TonguesMainMenu",Tongues.UI.MainMenu.Frame);
					self.Frame:SetScript("OnKeyUp", self.OnKeyUp);
					self.Frame:SetScript("OnDragStart", self.OnDragStart);
					self.Frame:SetScript("OnDragStop", self.OnDragStop);
					self.Frame:SetFrameStrata("DIALOG")
					self.Frame:SetMovable(true)
					self.Frame:SetWidth(120)
			    	    	self.Frame:SetHeight(20)
					--self.Frame:SetText("Understand");

					self.Frame:SetPoint("TOPLEFT",Tongues.UI.MainMenu.Frame, "TOPLEFT", 20, -100);

					--self.Frame:EnableMouse(true);
	
					-------Understand Tab-------------------
					self.Language:Configure();
					--self.IgnoreWord:Configure()
				--	self.LDialectDropDown:Configure();
					self.Fluency:Configure();
					self.UpdateButton:Configure();
					self.ClearLanguagesButton:Configure();
					self.ListLanguagesButton:Configure();

					self.Frame:Hide();
				end;
							---------------------------------------------------------------------------------------------
				Language = {
					Frame;
					texture  = {};
					text	 = {};
			
					Configure = function(self)
						self.Frame = CreateFrame("Editbox", "UnderstandLanguageTextbox", Tongues.UI.MainMenu.Understand.Frame,"InputBoxTemplate"); 
						self.Frame:SetScript("OnEditFocusGained", self.OnEditFocusGained);
						self.Frame:SetScript("OnEditFocusLost", self.OnEditFocusLost);
						self.Frame:SetScript("OnEnterPressed", self.OnEnterPressed);

						self.Frame:SetPoint("LEFT",Tongues.UI.MainMenu.Understand.Frame, "TOPLEFT", 82, -20);
						--self.Frame:SetPoint("TOPLEFT",Tongues.UI.MainMenu.Understand.Frame, "TOPLEFT", 82, 0); 

						self.Frame:SetFrameStrata("DIALOG");
						self.Frame:SetAutoFocus(false);
						self.Frame:SetWidth(120);
				    	    	self.Frame:SetHeight(20);

						self.text[1] = self.Frame:CreateFontString("settings","BUTTON")
						self.text[1]:SetFont(GameFontNormal:GetFont(),12);
						self.text[1]:SetText('|cffffffffLanguage|r')
						self.text[1]:SetPoint("LEFT", self.Frame, "LEFT", -82, 0 );
		
						self.Frame:Show();
					end;

					OnEnterPressed = function(self)
						Tongues.UI.MainMenu.Understand.Language.Frame:ClearFocus();


					end;

					OnEditFocusGained = function(self)
					end;

					OnEditFocusLost = function(self)
						if Tongues.Settings.Character.Fluency[Tongues.UI.MainMenu.Understand.Language.Frame:GetText()] ~= nil then
							Tongues.UI.MainMenu.Understand.Fluency.Frame:SetValue(Tongues.Settings.Character.Fluency[Tongues:GetRealLanguage(Tongues.UI.MainMenu.Understand.Language.Frame:GetText())]);
						else
							Tongues.UI.MainMenu.Understand.Fluency.Frame:SetValue(0);
						end;

					end;
				};	
				---------------------------------------------------------------------------------------------
				Fluency = {
					Frame;
					texture  = {};
					text	 = {};
			
					Configure = function(self)
						self.Frame = CreateFrame("Slider", "UnderstoodFluencyTextbox", Tongues.UI.MainMenu.Understand.Frame, "OptionsSliderTemplate"); 
						self.Frame:SetPoint("TOPLEFT",Tongues.UI.MainMenu.Understand.Language.Frame, "BOTTOMLEFT", 0, -40); 
	
						self.Frame:SetMinMaxValues(0,100);
						self.Frame:SetValueStep(1);
			
						self.Frame:Show();
					end;
				};
				---------------------------------------------------------------------------------------------
				UpdateButton = {
					Frame;
					texture  = {};
					text	 = {};
	
					Configure = function(self)
						self.Frame = CreateFrame("Button",nil, Tongues.UI.MainMenu.Understand.Frame,"UIPanelButtonTemplate");
						self.Frame:SetScript("OnMouseDown", self.OnMouseDown);
						self.Frame:SetScript("OnMouseUp", self.OnMouseUp);				
						self.Frame:SetFrameStrata("DIALOG")
						self.Frame:SetWidth(30)
				    	    	self.Frame:SetHeight(25)
						self.Frame:SetPoint("LEFT",Tongues.UI.MainMenu.Understand.Language.Frame, "RIGHT", 10, 0); 
						self.Frame:SetText("Set");
	
						self.Frame:EnableMouse(true);
						self.Frame:RegisterForClicks("LeftButton");		
						self.Frame:Show();
					end;

					OnMouseUp = function(self)
						if Tongues.UI.MainMenu.Understand.Language.Frame:GetText() ~= "" and Tongues:GetRealLanguage(Tongues.UI.MainMenu.Understand.Language.Frame:GetText()) ~= nil then
							Tongues.Settings.Character.Fluency[Tongues:GetRealLanguage(Tongues.UI.MainMenu.Understand.Language.Frame:GetText())] = Tongues.UI.MainMenu.Understand.Fluency.Frame:GetValue();
					
						else
							Tongues.Settings.Character.Fluency[Tongues.UI.MainMenu.Understand.Language.Frame:GetText()] = Tongues.UI.MainMenu.Understand.Fluency.Frame:GetValue();
						end;
						
						--if Tongues.Settings.Character.IgnoreFlag[Tongues.UI.MainMenu.Understand.Language.Frame:GetText()] ~= nil then
						--	Tongues.Settings.Character.IgnoreFlag[Tongues.UI.MainMenu.Understand.Language.Frame:GetText()] = Tongues.UI.MainMenu.Understand.IgnoreWord.Frame:GetText()
						--else
							
						--	Tongues.Settings.Character.IgnoreFlag[Tongues.UI.MainMenu.Understand.Language.Frame:GetText()] = Tongues.UI.MainMenu.Understand.IgnoreWord.Frame:GetText()
						--end;
						--if UIDropDownMenu_GetSelectedValue(Tongues.UI.MainMenu.Understand.LDialectDropDown.Frame) ~= nil or "<None>" then
						     --Tongues.Settings.Character.LD[Tongues.UI.MainMenu.Understand.Language.Frame:GetText()] = {};
							 --print(Tongues.UI.MainMenu.Understand.Language.Frame:GetText());
							 --print(Tongues.UI.MainMenu.Understand.LDialectDropDown.Frame:GetText())
							-- val = UIDropDownMenu_GetSelectedValue(Tongues.UI.MainMenu.Understand.LDialectDropDown.Frame)
							--print(val)
							--print(DiaTemp);
							--Tongues.Settings.Character.LD = {};--or Tongues.Settings.Character.LD;
							--Tongues.Settings.Character.LD[Tongues.UI.MainMenu.Understand.Language.Frame:GetText()] = UIDropDownMenu_GetSelectedValue(Tongues.UI.MainMenu.Understand.LDialectDropDown.Frame);
							--print(Tongues.Settings.Character.LD[Tongues.UI.MainMenu.Understand.Language.Frame:GetText()])
							--UIDropDownMenu_SetSelectedValue(Tongues.UI.MainMenu.Speak.DialectDropDown.Frame, val)
							
                        --else
						-- Tongues.Settings.Character.LD[Tongues.UI.MainMenu.Understand.Language.Frame:GetText()] = nil;
						-- val = "<None>"
						 --UIDropDownMenu_SetSelectedValue(Tongues.UI.MainMenu.Speak.DialectDropDown.Frame,val)
						--end]]
						
						UIDropDownMenu_Initialize(Tongues.UI.MainMenu.Speak.LanguageDropDown.Frame, Tongues.UpdateLanguageDropDown);	
					end;

					OnMouseDown = function(self)
					end;
				};
				---------------------------------------------------------------------------------------------
				ClearLanguagesButton = {
					Frame;
					texture  = {};
					text	 = {};
	
					Configure = function(self)
						self.Frame = CreateFrame("Button",nil, Tongues.UI.MainMenu.Understand.Frame,"UIPanelButtonTemplate");
						self.Frame:SetScript("OnMouseDown", self.OnMouseDown);
						self.Frame:SetScript("OnMouseUp", self.OnMouseUp);				
						self.Frame:SetFrameStrata("DIALOG")
						self.Frame:SetWidth(40)
				    	    	self.Frame:SetHeight(25)
						self.Frame:SetPoint("LEFT",Tongues.UI.MainMenu.Understand.UpdateButton.Frame, "RIGHT", 0, 0);
						self.Frame:SetText("Clear");
	
						self.Frame:EnableMouse(true);
						self.Frame:RegisterForClicks("LeftButton");		
						self.Frame:Show();
					end;
	
					OnMouseUp = function(self)
					if Tongues.UI.MainMenu.Understand.Language.Frame:GetText() ~= "" and Tongues:GetRealLanguage(Tongues.UI.MainMenu.Understand.Language.Frame:GetText()) ~= nil then
							Tongues.Settings.Character.Fluency[Tongues:GetRealLanguage(Tongues.UI.MainMenu.Understand.Language.Frame:GetText())] = nil;
						--	Tongues.Settings.Character.LD[Tongues.UI.MainMenu.Understand.Language.Frame:GetText()] = {}
						else
						--Tongues.Settings.Character.LD = {};
						Tongues.Settings.Character.Fluency = {};
						end
					end;
	
					OnMouseDown = function(self)
					end;
				};
				---------------------------------------------------------------------------------------------
				ListLanguagesButton = {
					Frame;
					texture  = {};
					text	 = {};

					Configure = function(self)
						self.Frame = CreateFrame("Button",nil, Tongues.UI.MainMenu.Understand.Frame,"UIPanelButtonTemplate");
						self.Frame:SetScript("OnMouseDown", self.OnMouseDown);
						self.Frame:SetScript("OnMouseUp", self.OnMouseUp);				
						self.Frame:SetFrameStrata("DIALOG")
						self.Frame:SetWidth(30)
				    	    	self.Frame:SetHeight(25)
						self.Frame:SetPoint("LEFT",Tongues.UI.MainMenu.Understand.ClearLanguagesButton.Frame, "RIGHT", 0, 0);
						self.Frame:SetText("List");

						self.Frame:EnableMouse(true);
						self.Frame:RegisterForClicks("LeftButton");		
						self.Frame:Show();
					end;
	
					OnMouseUp = function(self)
						DEFAULT_CHAT_FRAME:AddMessage("Known Languages:");
						for k,v in pairs(Tongues.Settings.Character.Fluency) do
							DEFAULT_CHAT_FRAME:AddMessage(k .. " = " .. v .. "%")
						end;
					end;

					OnMouseDown = function(self)
					end;
				};

		 };
	
		 
			--=======================================================================================================
			--Hear
			Hear = {
				Frame;
				texture  = {};
				text	 = {};

				Configure = function(self)
					self.Frame = CreateFrame("Frame","TonguesMainMenu",Tongues.UI.MainMenu.Frame);
					self.Frame:SetScript("OnKeyUp", self.OnKeyUp);
					self.Frame:SetScript("OnDragStart", self.OnDragStart);
					self.Frame:SetScript("OnDragStop", self.OnDragStop);
					self.Frame:SetFrameStrata("DIALOG")
					self.Frame:SetMovable(true)
					self.Frame:SetWidth(120)
			    	    	self.Frame:SetHeight(20)

					self.Frame:SetPoint("TOPLEFT",Tongues.UI.MainMenu.Frame, "TOPLEFT", 20, -100);
	
					-------Hear Tab-------------------
					self.Filter:Configure();

					self.Frame:Hide();
				end;
				---------------------------------------------------------------------------------------------
				Filter = {
					Frame;
					texture  = {};
					text	 = {};
			
					Configure = function(self)
						self.Frame = CreateFrame("Button", "HearFilterTextbox", Tongues.UI.MainMenu.Hear.Frame,"UIDropDownMenuTemplate"); 
						self.Frame:SetPoint("LEFT",Tongues.UI.MainMenu.Hear.Frame, "TOPLEFT", 55, -20);
						self.text[1] = self.Frame:CreateFontString("settings","BUTTON")
						self.text[1]:SetFont(GameFontNormal:GetFont(),12);
						self.text[1]:SetText('|cffffffffFilter|r')
						self.text[1]:SetPoint("LEFT", self.Frame, "LEFT", -55, 0 );

						UIDropDownMenu_Initialize(self.Frame, self.Initialize);		
						self.Frame:Show();
					end;

					Initialize = function()
						local info            = {};
						local k,v;
						for k,v in Tongues.PairsByKeys(Tongues.Filter) do
							info.text       = k;
							info.value      = k;
							info.checked = nil; 
							info.func       = Tongues.UI.MainMenu.Hear.Filter.OnClick;
							UIDropDownMenu_AddButton(info);
						end;		
					end;
				
					OnClick = function(self)
						UIDropDownMenu_ClearAll(Tongues.UI.MainMenu.Hear.Filter.Frame);
						UIDropDownMenu_SetSelectedValue(Tongues.UI.MainMenu.Hear.Filter.Frame, self.value); 
						Tongues.Settings.Character.Filter = self.value;
					end;
				};
			};
			--=======================================================================================================
			--Advanced
			--=======================================================================================================
			Minimize = {
				Frame;
				texture  = {};
				text	 = {};

				Configure = function(self)
					self.Frame = CreateFrame("Button",nil, Tongues.UI.MainMenu.Frame);
					self.Frame:SetScript("OnMouseDown", self.OnMouseDown);
					self.Frame:SetScript("OnMouseUp", self.OnMouseUp);
					self.Frame:SetScript("OnDragStart", self.OnDragStart);
					self.Frame:SetScript("OnDragStop", self.OnDragStop);				
					self.Frame:SetFrameStrata("DIALOG")
					--self.Frame:SetFrameStrata("BACKGROUND")
					self.Frame:SetWidth(70)
			    	    	self.Frame:SetHeight(70)
					self.Frame:SetPoint("TOPLEFT", Tongues.UI.MainMenu.Frame, -2,0);
					self.texture[1] = self.Frame:CreateTexture("settings","BUTTON")
					self.texture[1]:SetTexture("Interface\\Icons\\Spell_Shadow_SoulLeech")
					self.texture[1]:SetAllPoints();
					self.Frame:EnableMouse(true);
					self.Frame:RegisterForClicks("LeftButton");
					self.Frame:RegisterForDrag("LeftButton");		
					self.Frame:Show();
				end;

				OnMouseUp = function(self)
					Tongues.UI.MainMenu.Frame:Hide()
					Tongues.UI.MiniMenu.Frame:Show()
				end;

				OnMouseDown = function(self)
				end;

				OnDragStart = function (self)
					Tongues.UI.MainMenu.Frame:StartMoving();
				end;
				OnDragStop = function (self)
					Tongues.UI.MainMenu.Frame:StopMovingOrSizing();
	
				end;
			};


			--=======================================================================================================


		
			--=======================================================================================================
			CloseButton = {
				Frame;
				texture  = {};
				text	 = {};

				Configure = function(self)
					self.Frame = CreateFrame("Button",nil, Tongues.UI.MainMenu.Frame, "UIPanelCloseButton");
					self.Frame:SetScript("OnMouseDown", self.OnMouseDown);
					self.Frame:SetScript("OnMouseUp", self.OnMouseUp);				
					self.Frame:SetFrameStrata("DIALOG")
					--self.Frame:SetWidth(10)
			    	    	--self.Frame:SetHeight(10)
					self.Frame:SetPoint("TOPRIGHT", Tongues.UI.MainMenu.Frame, 2,-9);
					--self.texture[1] = self.Frame:CreateTexture("settings","BUTTON")
					--self.texture[1]:SetTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
					--self.texture[1]:SetPoint("CENTER", self.Frame, "CENTER", 0, 0);
					self.Frame:EnableMouse(true);
					self.Frame:RegisterForClicks("LeftButton");		
					self.Frame:Show();
				end;

				OnMouseUp = function(self)
					--Tongues.UI.MainMenu.CloseButton.texture[1]:SetTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
					--Tongues.UI.MainMenu.CloseButton.texture[1]:SetPoint("CENTER", self, "CENTER", 0, 0);
					Tongues.UI.MainMenu.Frame:Hide()
					if (Tongues.UI.MainMenu.Speak.MiniHide.Frame:GetChecked() == 1) then
							Tongues.Settings.Character.MMH = true;
							TonguesMiniMenu:Hide();
							
						else
							Tongues.Settings.Character.MMH = false;
							TonguesMiniMenu:Show();
						end;
					end;

				OnMouseDown = function(self)
					--Tongues.UI.MainMenu.CloseButton.texture[1]:SetTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
					--Tongues.UI.MainMenu.CloseButton.texture[1]:SetPoint("CENTER", self, "CENTER", 0, 0);
				end;
			};
			--=======================================================================================================
			AdvancedButton = {
				Frame;
				texture  = {};
				text	 = {};

				Configure = function(self)
					self.Frame = CreateFrame("Button","AdvancedButton", Tongues.UI.MainMenu.Frame,"UIPanelButtonTemplate");
					self.Frame:SetScript("OnMouseDown", self.OnMouseDown);
					self.Frame:SetScript("OnMouseUp", self.OnMouseUp);				
					self.Frame:SetFrameStrata("DIALOG")
					self.Frame:SetWidth(135)
			    	    	self.Frame:SetHeight(25)
					self.Frame:SetPoint("LEFT",Tongues.UI.MainMenu.Frame, "TOPLEFT", 95, -415);
					self.Frame:SetText("Advanced Options");

					self.Frame:EnableMouse(true);
					self.Frame:RegisterForClicks("LeftButton");		
					self.Frame:Show();
				end;

				OnMouseUp = function(self)
					if Tongues.UI.MainMenu.AdvancedOptions.Frame:IsVisible() == 1 then
						Tongues.UI.MainMenu.AdvancedOptions.Frame:Hide()
					else
						Tongues.UI.MainMenu.AdvancedOptions.Frame:Show()
					end;
				end;

				OnMouseDown = function(self)
				end;
			};
			--=======================================================================================================
			AdvancedOptions = {
				Frame;
				texture  = {};
				text	 = {};

				Configure = function(self)
					self.Frame = CreateFrame("Button","AdvancedOptions",Tongues.UI.MainMenu.Frame);

					self.Frame:SetFrameStrata("DIALOG")
					self.Frame:SetScript("OnDragStart", self.OnDragStart);
					self.Frame:SetScript("OnDragStop", self.OnDragStop);
					self.Frame:SetWidth(348)
			    	    	--self.Frame:SetHeight(440)
					self.Frame:SetHeight(240)
			    	    	self.Frame:SetPoint("TOP", Tongues.UI.MainMenu.Frame, "BOTTOM", 0, 0);
			
					self.text[1] = self.Frame:CreateFontString("settings","BUTTON")
					self.text[1]:SetFont(GameFontNormal:GetFont(),18);
					self.text[1]:SetText('|cffffffffTranslations|r')
					self.text[1]:SetPoint("LEFT", self.Frame, "TOPLEFT",20,  -10);

					self.text[2] = self.Frame:CreateFontString("settings","BUTTON")
					self.text[2]:SetFont(GameFontNormal:GetFont(),18);
					self.text[2]:SetText('|cffffffffScreen|r')
					self.text[2]:SetPoint("LEFT", self.Frame, "TOPLEFT",150,  -10);

					self.texture[4] = self.Frame:CreateTexture("settings","BORDER")
					self.texture[4]:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomLeft")
					self.texture[4]:SetTexCoord(0, 1, 0, 0.75)
					self.texture[4]:SetPoint("BOTTOMLEFT", self.Frame, "TOPLEFT", -4, -250);
					

					self.texture[5] = self.Frame:CreateTexture("settings","BORDER")
					self.texture[5]:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomRight")
					self.texture[5]:SetTexCoord(0, 1, 0, 0.75)
					self.texture[5]:SetPoint("BOTTOMRIGHT", self.Frame, "TOPRIGHT", 32, -250);

					--self.texture[6] = self.Frame:CreateTexture("settings","BORDER")
					--self.texture[6]:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomLeft")
					--self.texture[6]:SetPoint("BOTTOMLEFT", self.Frame, "BOTTOMLEFT", -4, -290);
					--self.texture[7] = self.Frame:CreateTexture("settings","BORDER")
					--self.texture[7]:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomRight")
					--self.texture[7]:SetPoint("BOTTOMRIGHT", self.Frame, "BOTTOMRIGHT", 32, -290);


					Tongues.UI.MainMenu.Translations:Configure();
					Tongues.UI.MainMenu.Translators:Configure();
					Tongues.UI.MainMenu.Screen:Configure();
					

					self.Frame:EnableMouse(true);
					self.Frame:RegisterForDrag("LeftButton");

					self.Frame:Hide();
				end;

				OnDragStart = function (self)
					Tongues.UI.MainMenu.Frame:StartMoving();
				end;
				OnDragStop = function (self)
					Tongues.UI.MainMenu.Frame:StopMovingOrSizing();
	
				end;

			};
			--=======================================================================================================
			Translations = {
				Configure = function(self)
					self.Self:Configure();
					self.Targetted:Configure();
					self.Party:Configure();
					self.Guild:Configure();
					self.Officer:Configure();
					self.Raid:Configure();
					self.RaidAlert:Configure();
					self.Battleground:Configure();
				end;
				--=======================================================================================================
				Self = {
					Frame;
					texture  = {};
					text	 = {};
	
					Configure = function(self)
						self.Frame = CreateFrame("CheckButton","TranslationsSelf", Tongues.UI.MainMenu.AdvancedOptions.Frame,"OptionsCheckButtonTemplate");
						self.Frame:SetScript("OnMouseDown", self.OnMouseDown);
						self.Frame:SetScript("OnMouseUp", self.OnMouseUp);				
						self.Frame:SetFrameStrata("DIALOG")
	
						self.text[1] = self.Frame:CreateFontString("settings","BUTTON")
						self.text[1]:SetFont(GameFontNormal:GetFont(),12);
						self.text[1]:SetText('|cffffffffSelf|r')
						self.text[1]:SetPoint("LEFT", self.Frame, "LEFT",25, 0 );
	
						self.Frame:SetWidth(25)
				    	    	self.Frame:SetHeight(25)
						self.Frame:SetPoint("LEFT", Tongues.UI.MainMenu.AdvancedOptions.Frame, "TOPLEFT",20,  -30);
						self.Frame:SetText("CheckBox Thing");
	
						self.Frame:EnableMouse(true);
						self.Frame:RegisterForClicks("LeftButton");		
						self.Frame:Show();
					end;
	
					OnMouseUp = function(self)
						Tongues.UI.MainMenu.Translations.Self.Frame:SetChecked(not Tongues.UI.MainMenu.Translations.Self.Frame:GetChecked());
							
						if (Tongues.UI.MainMenu.Translations.Self.Frame:GetChecked() == 1) then
							Tongues.Settings.Character.Translations.Self = true;
						else
							Tongues.Settings.Character.Translations.Self = false;
						end;
					end;
	
					OnMouseDown = function(self)
					end;
				};
				--=======================================================================================================
				Targetted = {
					Frame;
					texture  = {};
					text	 = {};
	
					Configure = function(self)
						self.Frame = CreateFrame("CheckButton","TranslationsTargetted", Tongues.UI.MainMenu.AdvancedOptions.Frame,"OptionsCheckButtonTemplate");
						self.Frame:SetScript("OnMouseDown", self.OnMouseDown);
						self.Frame:SetScript("OnMouseUp", self.OnMouseUp);				
						self.Frame:SetFrameStrata("DIALOG")
	
						self.text[1] = self.Frame:CreateFontString("settings","BUTTON")
						self.text[1]:SetFont(GameFontNormal:GetFont(),12);
						self.text[1]:SetText('|cffffffffTo Targetted|r')
						self.text[1]:SetPoint("LEFT", self.Frame, "LEFT",25, 0 );
	
						self.Frame:SetWidth(25)
				    	    	self.Frame:SetHeight(25)
						self.Frame:SetPoint("LEFT", Tongues.UI.MainMenu.AdvancedOptions.Frame, "TOPLEFT",20,  -50);
						self.Frame:SetText("CheckBox Thing");
	
						self.Frame:EnableMouse(true);
						self.Frame:RegisterForClicks("LeftButton");		
						self.Frame:Show();
					end;
	
					OnMouseUp = function(self)
						Tongues.UI.MainMenu.Translations.Targetted.Frame:SetChecked(not Tongues.UI.MainMenu.Translations.Targetted.Frame:GetChecked());
							
						if (Tongues.UI.MainMenu.Translations.Targetted.Frame:GetChecked() == 1) then
							Tongues.Settings.Character.Translations.Targetted = true;
						else
							Tongues.Settings.Character.Translations.Targetted = false;
						end;
					end;
	
					OnMouseDown = function(self)
					end;
				};
				--=======================================================================================================
				Party = {
					Frame;
					texture  = {};
					text	 = {};
	
					Configure = function(self)
						self.Frame = CreateFrame("CheckButton","TranslationsParty", Tongues.UI.MainMenu.AdvancedOptions.Frame,"OptionsCheckButtonTemplate");
						self.Frame:SetScript("OnMouseDown", self.OnMouseDown);
						self.Frame:SetScript("OnMouseUp", self.OnMouseUp);				
						self.Frame:SetFrameStrata("DIALOG")
	
						self.text[1] = self.Frame:CreateFontString("settings","BUTTON")
						self.text[1]:SetFont(GameFontNormal:GetFont(),12);
						self.text[1]:SetText('|cffffffffParty|r')
						self.text[1]:SetPoint("LEFT", self.Frame, "LEFT",25, 0 );
	
						self.Frame:SetWidth(25)
				    	    	self.Frame:SetHeight(25)
						self.Frame:SetPoint("LEFT", Tongues.UI.MainMenu.AdvancedOptions.Frame, "TOPLEFT",20,  -70);
						self.Frame:SetText("CheckBox Thing");
	
						self.Frame:EnableMouse(true);
						self.Frame:RegisterForClicks("LeftButton");		
						self.Frame:Show();
					end;
	
					OnMouseUp = function(self)
						Tongues.UI.MainMenu.Translations.Party.Frame:SetChecked(not Tongues.UI.MainMenu.Translations.Party.Frame:GetChecked());

						if (Tongues.UI.MainMenu.Translations.Party.Frame:GetChecked() == 1) then
							Tongues.Settings.Character.Translations.Party = true;
						else
							Tongues.Settings.Character.Translations.Party = false;
						end;
					end;
	
					OnMouseDown = function(self)
					end;
				};
				--=======================================================================================================
				Guild = {
					Frame;
					texture  = {};
					text	 = {};
	
					Configure = function(self)
						self.Frame = CreateFrame("CheckButton","TranslationsGuild", Tongues.UI.MainMenu.AdvancedOptions.Frame,"OptionsCheckButtonTemplate");
						self.Frame:SetScript("OnMouseDown", self.OnMouseDown);
						self.Frame:SetScript("OnMouseUp", self.OnMouseUp);				
						self.Frame:SetFrameStrata("DIALOG")
	
						self.text[1] = self.Frame:CreateFontString("settings","BUTTON")
						self.text[1]:SetFont(GameFontNormal:GetFont(),12);
						self.text[1]:SetText('|cffffffffGuild|r')
						self.text[1]:SetPoint("LEFT", self.Frame, "LEFT",25, 0 );
	
						self.Frame:SetWidth(25)
				    	    	self.Frame:SetHeight(25)
						self.Frame:SetPoint("LEFT", Tongues.UI.MainMenu.AdvancedOptions.Frame, "TOPLEFT",20,  -90);
						self.Frame:SetText("CheckBox Thing");
	
						self.Frame:EnableMouse(true);
						self.Frame:RegisterForClicks("LeftButton");		
						self.Frame:Show();
					end;
	
					OnMouseUp = function(self)
						Tongues.UI.MainMenu.Translations.Guild.Frame:SetChecked(not Tongues.UI.MainMenu.Translations.Guild.Frame:GetChecked());

						if (Tongues.UI.MainMenu.Translations.Guild.Frame:GetChecked() == 1) then
							Tongues.Settings.Character.Translations.Guild = true;
						else
							Tongues.Settings.Character.Translations.Guild = false;
						end;
					end;
	
					OnMouseDown = function(self)
					end;
				};
				--=======================================================================================================
				Officer = {
					Frame;
					texture  = {};
					text	 = {};
	
					Configure = function(self)
						self.Frame = CreateFrame("CheckButton","TranslationsOfficer", Tongues.UI.MainMenu.AdvancedOptions.Frame,"OptionsCheckButtonTemplate");
						self.Frame:SetScript("OnMouseDown", self.OnMouseDown);
						self.Frame:SetScript("OnMouseUp", self.OnMouseUp);				
						self.Frame:SetFrameStrata("DIALOG")
	
						self.text[1] = self.Frame:CreateFontString("settings","BUTTON")
						self.text[1]:SetFont(GameFontNormal:GetFont(),12);
						self.text[1]:SetText('|cffffffffOfficer|r')
						self.text[1]:SetPoint("LEFT", self.Frame, "LEFT",25, 0 );
	
						self.Frame:SetWidth(25)
				    	    	self.Frame:SetHeight(25)
						self.Frame:SetPoint("LEFT", Tongues.UI.MainMenu.AdvancedOptions.Frame, "TOPLEFT",20,  -110);
						self.Frame:SetText("CheckBox Thing");
	
						self.Frame:EnableMouse(true);
						self.Frame:RegisterForClicks("LeftButton");		
						self.Frame:Show();
					end;
	
					OnMouseUp = function(self)
						Tongues.UI.MainMenu.Translations.Officer.Frame:SetChecked(not Tongues.UI.MainMenu.Translations.Officer.Frame:GetChecked());

						if (Tongues.UI.MainMenu.Translations.Officer.Frame:GetChecked() == 1) then
							Tongues.Settings.Character.Translations.Officer = true;
						else
							Tongues.Settings.Character.Translations.Officer = false;
						end;
					end;
	
					OnMouseDown = function(self)
					end;
				};
				--=======================================================================================================
				Raid = {
					Frame;
					texture  = {};
					text	 = {};
	
					Configure = function(self)
						self.Frame = CreateFrame("CheckButton","TranslationsRaidButton", Tongues.UI.MainMenu.AdvancedOptions.Frame,"OptionsCheckButtonTemplate");
						self.Frame:SetScript("OnMouseDown", self.OnMouseDown);
						self.Frame:SetScript("OnMouseUp", self.OnMouseUp);				
						self.Frame:SetFrameStrata("DIALOG")
	
						self.text[1] = self.Frame:CreateFontString("settings","BUTTON")
						self.text[1]:SetFont(GameFontNormal:GetFont(),12);
						self.text[1]:SetText('|cffffffffRaid|r')
						self.text[1]:SetPoint("LEFT", self.Frame, "LEFT",25, 0 );
	
						self.Frame:SetWidth(25)
				    	    	self.Frame:SetHeight(25)
						self.Frame:SetPoint("LEFT", Tongues.UI.MainMenu.AdvancedOptions.Frame, "TOPLEFT",20,  -130);
						self.Frame:SetText("CheckBox Thing");
	
						self.Frame:EnableMouse(true);
						self.Frame:RegisterForClicks("LeftButton");		
						self.Frame:Show();
					end;
	
					OnMouseUp = function(self)
						Tongues.UI.MainMenu.Translations.Raid.Frame:SetChecked(not Tongues.UI.MainMenu.Translations.Raid.Frame:GetChecked());

						if (Tongues.UI.MainMenu.Translations.Raid.Frame:GetChecked() == 1) then
							Tongues.Settings.Character.Translations.Raid = true;
						else
							Tongues.Settings.Character.Translations.Raid = false;
						end;
					end;
	
					OnMouseDown = function(self)
					end;
				};
				--=======================================================================================================
				RaidAlert = {
					Frame;
					texture  = {};
					text	 = {};
	
					Configure = function(self)
						self.Frame = CreateFrame("CheckButton","TranslationsRaidAlert", Tongues.UI.MainMenu.AdvancedOptions.Frame,"OptionsCheckButtonTemplate");
						self.Frame:SetScript("OnMouseDown", self.OnMouseDown);
						self.Frame:SetScript("OnMouseUp", self.OnMouseUp);				
						self.Frame:SetFrameStrata("DIALOG")
	
						self.text[1] = self.Frame:CreateFontString("settings","BUTTON")
						self.text[1]:SetFont(GameFontNormal:GetFont(),12);
						self.text[1]:SetText('|cffffffffRaid Alert|r')
						self.text[1]:SetPoint("LEFT", self.Frame, "LEFT",25, 0 );
	
						self.Frame:SetWidth(25)
				    	    	self.Frame:SetHeight(25)
						self.Frame:SetPoint("LEFT", Tongues.UI.MainMenu.AdvancedOptions.Frame, "TOPLEFT",20,  -150);
						self.Frame:SetText("CheckBox Thing");
	
						self.Frame:EnableMouse(true);
						self.Frame:RegisterForClicks("LeftButton");		
						self.Frame:Show();
					end;
	
					OnMouseUp = function(self)
						Tongues.UI.MainMenu.Translations.RaidAlert.Frame:SetChecked(not Tongues.UI.MainMenu.Translations.RaidAlert.Frame:GetChecked());

						if (Tongues.UI.MainMenu.Translations.RaidAlert.Frame:GetChecked() == 1) then
							Tongues.Settings.Character.Translations.RaidAlert = true;
						else
							Tongues.Settings.Character.Translations.RaidAlert = false;
						end;
					end;
	
					OnMouseDown = function(self)
					end;
				};
				--=======================================================================================================
				Battleground = {
					Frame;
					texture  = {};
					text	 = {};
	
					Configure = function(self)
						self.Frame = CreateFrame("CheckButton","TranslationsBattleground", Tongues.UI.MainMenu.AdvancedOptions.Frame,"OptionsCheckButtonTemplate");
						self.Frame:SetScript("OnMouseDown", self.OnMouseDown);
						self.Frame:SetScript("OnMouseUp", self.OnMouseUp);				
						self.Frame:SetFrameStrata("DIALOG")
	
						self.text[1] = self.Frame:CreateFontString("settings","BUTTON")
						self.text[1]:SetFont(GameFontNormal:GetFont(),12);
						self.text[1]:SetText('|cffffffffBattleground|r')
						self.text[1]:SetPoint("LEFT", self.Frame, "LEFT",25, 0 );
	
						self.Frame:SetWidth(25)
				    	    	self.Frame:SetHeight(25)
						self.Frame:SetPoint("LEFT", Tongues.UI.MainMenu.AdvancedOptions.Frame, "TOPLEFT",20,  -170);
						self.Frame:SetText("CheckBox Thing");
	
						self.Frame:EnableMouse(true);
						self.Frame:RegisterForClicks("LeftButton");		
						self.Frame:Show();
					end;
	
					OnMouseUp = function(self)
						Tongues.UI.MainMenu.Translations.Battleground.Frame:SetChecked(not Tongues.UI.MainMenu.Translations.Battleground.Frame:GetChecked());

						if (Tongues.UI.MainMenu.Translations.Battleground.Frame:GetChecked() == 1) then
							Tongues.Settings.Character.Translations.Battleground = true;
						else
							Tongues.Settings.Character.Translations.Battleground = false;
						end;
					end;
	
					OnMouseDown = function(self)
					end;
				};
				--=======================================================================================================
			};
		
			
			
				--=======================================================================================================
			
--=======================================================================================================
			Translators = {
				Frame;
				texture = {};
				text = {};
				Configure = function(self)
					self.AddTranslatorButton:Configure();
					self.ClearTranslatorButton:Configure();
					self.ListTranslatorButton:Configure();
					self.TranslatorEditbox:Configure();
				end;

				--=======================================================================================================
				TranslatorEditbox = {
					Frame;
					texture  = {};
					text	 = {};

					Configure = function(self)
						self.Frame = CreateFrame("Editbox","TranslatorEditbox", Tongues.UI.MainMenu.AdvancedOptions.Frame,"InputBoxTemplate");
						--self.Frame:SetScript("OnMouseDown", self.OnMouseDown);
						--self.Frame:SetScript("OnMouseUp", self.OnMouseUp);	
						self.Frame:SetScript("OnEditFocusGained", self.OnEditFocusGained);
						self.Frame:SetScript("OnEditFocusLost", self.OnEditFocusLost);
						self.Frame:SetScript("OnEnterPressed", self.OnEnterPressed);
				
						self.Frame:SetFrameStrata("DIALOG")
						self.Frame:SetAutoFocus(false);
						self.Frame:SetWidth(120)
				    	    	self.Frame:SetHeight(25)
	
						self.Frame:SetPoint("LEFT",Tongues.UI.MainMenu.AdvancedOptions.Frame, "TOPLEFT", 100, -200);
						self.text[1] = self.Frame:CreateFontString("settings","BUTTON")
						self.text[1]:SetFont(GameFontNormal:GetFont(),12);
						self.text[1]:SetText('|cffffffffTranslator|r')
						self.text[1]:SetPoint("LEFT", self.Frame, "LEFT", -80, 0 ); 
	
						self.Frame:EnableMouse(true);	
						self.Frame:Show();
					end;
	
					OnEnterPressed = function(self)
						Tongues.UI.MainMenu.Translators.TranslatorEditbox.Frame:ClearFocus();
					end;
	
					OnEditFocusGained = function(self)
					end;
	
					OnEditFocusLost = function(self)
	
					end;
	
				};
				--=======================================================================================================
				AddTranslatorButton = {
					Frame;
					texture  = {};
					text	 = {};
	
					Configure = function(self)
						self.Frame = CreateFrame("Button",nil, Tongues.UI.MainMenu.AdvancedOptions.Frame,"UIPanelButtonTemplate");
						self.Frame:SetScript("OnMouseDown", self.OnMouseDown);
						self.Frame:SetScript("OnMouseUp", self.OnMouseUp);				
						self.Frame:SetFrameStrata("DIALOG")
						self.Frame:SetWidth(30)
				    	    	self.Frame:SetHeight(25)
						self.Frame:SetPoint("LEFT",Tongues.UI.MainMenu.AdvancedOptions.Frame, "TOPLEFT", 230, -200);
						self.Frame:SetText("+/-");
	
						self.Frame:EnableMouse(true);
						self.Frame:RegisterForClicks("LeftButton");		
						self.Frame:Show();
					end;
	
					OnMouseUp = function(self)
						if Tongues.UI.MainMenu.Translators.TranslatorEditbox.Frame:GetText() ~= "" then
							if Tongues:FindTranslator(Tongues.UI.MainMenu.Translators.TranslatorEditbox.Frame:GetText())==false then
								Tongues:AddTranslator(Tongues.UI.MainMenu.Translators.TranslatorEditbox.Frame:GetText());
								DEFAULT_CHAT_FRAME:AddMessage("Added " .. Tongues.UI.MainMenu.Translators.TranslatorEditbox.Frame:GetText() .. " to the Translator list")
							else
								Tongues:RemoveTranslator(Tongues.UI.MainMenu.Translators.TranslatorEditbox.Frame:GetText());
								DEFAULT_CHAT_FRAME:AddMessage("Removed " .. Tongues.UI.MainMenu.Translators.TranslatorEditbox.Frame:GetText() .. " from the Translator list")
							end;
						end;
					end;
	
					OnMouseDown = function(self)
					end;
				};
				--=======================================================================================================
				ClearTranslatorButton = {
					Frame;
					texture  = {};
					text	 = {};
	
					Configure = function(self)
						self.Frame = CreateFrame("Button",nil, Tongues.UI.MainMenu.AdvancedOptions.Frame,"UIPanelButtonTemplate");
						self.Frame:SetScript("OnMouseDown", self.OnMouseDown);
						self.Frame:SetScript("OnMouseUp", self.OnMouseUp);				
						self.Frame:SetFrameStrata("DIALOG")
						self.Frame:SetWidth(40)
				    	    	self.Frame:SetHeight(25)
						self.Frame:SetPoint("LEFT",Tongues.UI.MainMenu.AdvancedOptions.Frame, "TOPLEFT", 260, -200);
						self.Frame:SetText("Clear");
	
						self.Frame:EnableMouse(true);
						self.Frame:RegisterForClicks("LeftButton");		
						self.Frame:Show();
					end;
	
					OnMouseUp = function(self)
						Tongues.Settings.Character.Translators = {};
					end;
	
					OnMouseDown = function(self)
					end;
				};
				--=======================================================================================================
				ListTranslatorButton = {
					Frame;
					texture  = {};
					text	 = {};
	
					Configure = function(self)
						self.Frame = CreateFrame("Button",nil, Tongues.UI.MainMenu.AdvancedOptions.Frame,"UIPanelButtonTemplate");
						self.Frame:SetScript("OnMouseDown", self.OnMouseDown);
						self.Frame:SetScript("OnMouseUp", self.OnMouseUp);				
						self.Frame:SetFrameStrata("DIALOG")
						self.Frame:SetWidth(30)
				    	    	self.Frame:SetHeight(25)
						self.Frame:SetPoint("LEFT",Tongues.UI.MainMenu.AdvancedOptions.Frame, "TOPLEFT", 300, -200);
						self.Frame:SetText("List");
	
						self.Frame:EnableMouse(true);
						self.Frame:RegisterForClicks("LeftButton");		
						self.Frame:Show();
					end;
	
					OnMouseUp = function(self)
						DEFAULT_CHAT_FRAME:AddMessage("Known Translators:");
						for k,v in pairs(Tongues.Settings.Character.Translators) do
							DEFAULT_CHAT_FRAME:AddMessage(v)
						end;
					end;
	
					OnMouseDown = function(self)
					end;
				};
			};
			--=======================================================================================================
		
			
			
			Screen = {
				Configure = function(self)
					self.Self:Configure();
					self.Targetted:Configure();
					self.Party:Configure();
					self.Guild:Configure();
					self.Officer:Configure();
					self.Raid:Configure();
					self.RaidAlert:Configure();
					self.Battleground:Configure();
				end;
				--=======================================================================================================
				Self = {
					Frame;
					texture  = {};
					text	 = {};
	
					Configure = function(self)
						self.Frame = CreateFrame("CheckButton","ScreenSelf", Tongues.UI.MainMenu.AdvancedOptions.Frame,"OptionsCheckButtonTemplate");
						self.Frame:SetScript("OnMouseDown", self.OnMouseDown);
						self.Frame:SetScript("OnMouseUp", self.OnMouseUp);				
						self.Frame:SetFrameStrata("DIALOG")
	
						self.text[1] = self.Frame:CreateFontString("settings","BUTTON")
						self.text[1]:SetFont(GameFontNormal:GetFont(),12);
						self.text[1]:SetText('|cffffffffSelf|r')
						self.text[1]:SetPoint("LEFT", self.Frame, "LEFT",25, 0 );
	
						self.Frame:SetWidth(25)
				    	    	self.Frame:SetHeight(25)
						self.Frame:SetPoint("LEFT", Tongues.UI.MainMenu.AdvancedOptions.Frame, "TOPLEFT",150,  -30);
						self.Frame:SetText("CheckBox Thing");
	
						self.Frame:EnableMouse(true);
						self.Frame:RegisterForClicks("LeftButton");		
						self.Frame:Show();
					end;
	
					OnMouseUp = function(self)
						Tongues.UI.MainMenu.Screen.Self.Frame:SetChecked(not Tongues.UI.MainMenu.Screen.Self.Frame:GetChecked());

						if (Tongues.UI.MainMenu.Screen.Self.Frame:GetChecked() == 1) then
							Tongues.Settings.Character.Screen.Self = true;
						else
							Tongues.Settings.Character.Screen.Self = false;
						end;
					end;
	
					OnMouseDown = function(self)
					end;
				};
				--=======================================================================================================
				Targetted = {
					Frame;
					texture  = {};
					text	 = {};
	
					Configure = function(self)
						self.Frame = CreateFrame("CheckButton","ScreenTargetted", Tongues.UI.MainMenu.AdvancedOptions.Frame,"OptionsCheckButtonTemplate");
						self.Frame:SetScript("OnMouseDown", self.OnMouseDown);
						self.Frame:SetScript("OnMouseUp", self.OnMouseUp);				
						self.Frame:SetFrameStrata("DIALOG")
	
						self.text[1] = self.Frame:CreateFontString("settings","BUTTON")
						self.text[1]:SetFont(GameFontNormal:GetFont(),12);
						self.text[1]:SetText('|cffffffffTo Targetted|r')
						self.text[1]:SetPoint("LEFT", self.Frame, "LEFT",25, 0 );
	
						self.Frame:SetWidth(25)
				    	    	self.Frame:SetHeight(25)
						self.Frame:SetPoint("LEFT", Tongues.UI.MainMenu.AdvancedOptions.Frame, "TOPLEFT",150,  -50);
						self.Frame:SetText("CheckBox Thing");
	
						self.Frame:EnableMouse(true);
						self.Frame:RegisterForClicks("LeftButton");		
						self.Frame:Show();
					end;
	
					OnMouseUp = function(self)
						Tongues.UI.MainMenu.Screen.Targetted.Frame:SetChecked(not Tongues.UI.MainMenu.Screen.Targetted.Frame:GetChecked());
							
						if (Tongues.UI.MainMenu.Screen.Targetted.Frame:GetChecked() == 1) then
							Tongues.Settings.Character.Screen.Targetted = true;
						else
							Tongues.Settings.Character.Screen.Targetted = false;
						end;
					end;
	
					OnMouseDown = function(self)
					end;
				};
				--=======================================================================================================
				Party = {
					Frame;
					texture  = {};
					text	 = {};
	
					Configure = function(self)
						self.Frame = CreateFrame("CheckButton","ScreenParty", Tongues.UI.MainMenu.AdvancedOptions.Frame,"OptionsCheckButtonTemplate");
						self.Frame:SetScript("OnMouseDown", self.OnMouseDown);
						self.Frame:SetScript("OnMouseUp", self.OnMouseUp);				
						self.Frame:SetFrameStrata("DIALOG")
	
						self.text[1] = self.Frame:CreateFontString("settings","BUTTON")
						self.text[1]:SetFont(GameFontNormal:GetFont(),12);
						self.text[1]:SetText('|cffffffffParty|r')
						self.text[1]:SetPoint("LEFT", self.Frame, "LEFT",25, 0 );
	
						self.Frame:SetWidth(25)
				    	    	self.Frame:SetHeight(25)
						self.Frame:SetPoint("LEFT", Tongues.UI.MainMenu.AdvancedOptions.Frame, "TOPLEFT",150,  -70);
						self.Frame:SetText("CheckBox Thing");
	
						self.Frame:EnableMouse(true);
						self.Frame:RegisterForClicks("LeftButton");		
						self.Frame:Show();
					end;
	
					OnMouseUp = function(self)
						Tongues.UI.MainMenu.Screen.Party.Frame:SetChecked(not Tongues.UI.MainMenu.Screen.Party.Frame:GetChecked());

						if (Tongues.UI.MainMenu.Screen.Party.Frame:GetChecked() == 1) then
							Tongues.Settings.Character.Screen.Party = true;
						else
							Tongues.Settings.Character.Screen.Party = false;
						end;
					end;
	
					OnMouseDown = function(self)
					end;
				};
				--=======================================================================================================
				Guild = {
					Frame;
					texture  = {};
					text	 = {};
	
					Configure = function(self)
						self.Frame = CreateFrame("CheckButton","ScreenGuild", Tongues.UI.MainMenu.AdvancedOptions.Frame,"OptionsCheckButtonTemplate");
						self.Frame:SetScript("OnMouseDown", self.OnMouseDown);
						self.Frame:SetScript("OnMouseUp", self.OnMouseUp);				
						self.Frame:SetFrameStrata("DIALOG")
	
						self.text[1] = self.Frame:CreateFontString("settings","BUTTON")
						self.text[1]:SetFont(GameFontNormal:GetFont(),12);
						self.text[1]:SetText('|cffffffffGuild|r')
						self.text[1]:SetPoint("LEFT", self.Frame, "LEFT",25, 0 );
	
						self.Frame:SetWidth(25)
				    	    	self.Frame:SetHeight(25)
						self.Frame:SetPoint("LEFT", Tongues.UI.MainMenu.AdvancedOptions.Frame, "TOPLEFT",150,  -90);
						self.Frame:SetText("CheckBox Thing");
	
						self.Frame:EnableMouse(true);
						self.Frame:RegisterForClicks("LeftButton");		
						self.Frame:Show();
					end;
	
					OnMouseUp = function(self)
						Tongues.UI.MainMenu.Screen.Guild.Frame:SetChecked(not Tongues.UI.MainMenu.Screen.Guild.Frame:GetChecked());

						if (Tongues.UI.MainMenu.Screen.Guild.Frame:GetChecked() == 1) then
							Tongues.Settings.Character.Screen.Guild = true;
						else
							Tongues.Settings.Character.Screen.Guild = false;
						end;
					end;
	
					OnMouseDown = function(self)
					end;
				};
				--=======================================================================================================
				Officer = {
					Frame;
					texture  = {};
					text	 = {};
	
					Configure = function(self)
						self.Frame = CreateFrame("CheckButton","ScreenOfficer", Tongues.UI.MainMenu.AdvancedOptions.Frame,"OptionsCheckButtonTemplate");
						self.Frame:SetScript("OnMouseDown", self.OnMouseDown);
						self.Frame:SetScript("OnMouseUp", self.OnMouseUp);				
						self.Frame:SetFrameStrata("DIALOG")
	
						self.text[1] = self.Frame:CreateFontString("settings","BUTTON")
						self.text[1]:SetFont(GameFontNormal:GetFont(),12);
						self.text[1]:SetText('|cffffffffOfficer|r')
						self.text[1]:SetPoint("LEFT", self.Frame, "LEFT",25, 0 );
	
						self.Frame:SetWidth(25)
				    	    	self.Frame:SetHeight(25)
						self.Frame:SetPoint("LEFT", Tongues.UI.MainMenu.AdvancedOptions.Frame, "TOPLEFT",150,  -110);
						self.Frame:SetText("CheckBox Thing");
	
						self.Frame:EnableMouse(true);
						self.Frame:RegisterForClicks("LeftButton");		
						self.Frame:Show();
					end;
	
					OnMouseUp = function(self)
						Tongues.UI.MainMenu.Screen.Officer.Frame:SetChecked(not Tongues.UI.MainMenu.Screen.Officer.Frame:GetChecked());

						if (Tongues.UI.MainMenu.Screen.Officer.Frame:GetChecked() == 1) then
							Tongues.Settings.Character.Screen.Officer = true;
						else
							Tongues.Settings.Character.Screen.Officer = false;
						end;
					end;
	
					OnMouseDown = function(self)
					end;
				};
				--=======================================================================================================
				Raid = {
					Frame;
					texture  = {};
					text	 = {};
	
					Configure = function(self)
						self.Frame = CreateFrame("CheckButton","ScreenRaidButton", Tongues.UI.MainMenu.AdvancedOptions.Frame,"OptionsCheckButtonTemplate");
						self.Frame:SetScript("OnMouseDown", self.OnMouseDown);
						self.Frame:SetScript("OnMouseUp", self.OnMouseUp);				
						self.Frame:SetFrameStrata("DIALOG")
	
						self.text[1] = self.Frame:CreateFontString("settings","BUTTON")
						self.text[1]:SetFont(GameFontNormal:GetFont(),12);
						self.text[1]:SetText('|cffffffffRaid|r')
						self.text[1]:SetPoint("LEFT", self.Frame, "LEFT",25, 0 );
	
						self.Frame:SetWidth(25)
				    	    	self.Frame:SetHeight(25)
						self.Frame:SetPoint("LEFT", Tongues.UI.MainMenu.AdvancedOptions.Frame, "TOPLEFT",150,  -130);
						self.Frame:SetText("CheckBox Thing");
	
						self.Frame:EnableMouse(true);
						self.Frame:RegisterForClicks("LeftButton");		
						self.Frame:Show();
					end;
	
					OnMouseUp = function(self)
						Tongues.UI.MainMenu.Screen.Raid.Frame:SetChecked(not Tongues.UI.MainMenu.Screen.Raid.Frame:GetChecked());

						if (Tongues.UI.MainMenu.Screen.Raid.Frame:GetChecked() == 1) then
							Tongues.Settings.Character.Screen.Raid = true;
						else
							Tongues.Settings.Character.Screen.Raid = false;
						end;
					end;
	
					OnMouseDown = function(self)
					end;
				};
				--=======================================================================================================
				RaidAlert = {
					Frame;
					texture  = {};
					text	 = {};
	
					Configure = function(self)
						self.Frame = CreateFrame("CheckButton","ScreenRaidAlert", Tongues.UI.MainMenu.AdvancedOptions.Frame,"OptionsCheckButtonTemplate");
						self.Frame:SetScript("OnMouseDown", self.OnMouseDown);
						self.Frame:SetScript("OnMouseUp", self.OnMouseUp);				
						self.Frame:SetFrameStrata("DIALOG")
	
						self.text[1] = self.Frame:CreateFontString("settings","BUTTON")
						self.text[1]:SetFont(GameFontNormal:GetFont(),12);
						self.text[1]:SetText('|cffffffffRaid Alert|r')
						self.text[1]:SetPoint("LEFT", self.Frame, "LEFT",25, 0 );
	
						self.Frame:SetWidth(25)
				    	    	self.Frame:SetHeight(25)
						self.Frame:SetPoint("LEFT", Tongues.UI.MainMenu.AdvancedOptions.Frame, "TOPLEFT",150,  -150);
						self.Frame:SetText("CheckBox Thing");
	
						self.Frame:EnableMouse(true);
						self.Frame:RegisterForClicks("LeftButton");		
						self.Frame:Show();
					end;
	
					OnMouseUp = function(self)
						Tongues.UI.MainMenu.Screen.RaidAlert.Frame:SetChecked(not Tongues.UI.MainMenu.Screen.RaidAlert.Frame:GetChecked());

						if (Tongues.UI.MainMenu.Screen.RaidAlert.Frame:GetChecked() == 1) then
							Tongues.Settings.Character.Screen.RaidAlert = true;
						else
							Tongues.Settings.Character.Screen.RaidAlert = false;
						end;
					end;
	
					OnMouseDown = function(self)
					end;
				};
				--=======================================================================================================
				Battleground = {
					Frame;
					texture  = {};
					text	 = {};
	
					Configure = function(self)
						self.Frame = CreateFrame("CheckButton","ScreenBattleground", Tongues.UI.MainMenu.AdvancedOptions.Frame,"OptionsCheckButtonTemplate");
						self.Frame:SetScript("OnMouseDown", self.OnMouseDown);
						self.Frame:SetScript("OnMouseUp", self.OnMouseUp);				
						self.Frame:SetFrameStrata("DIALOG")
	
						self.text[1] = self.Frame:CreateFontString("settings","BUTTON")
						self.text[1]:SetFont(GameFontNormal:GetFont(),12);
						self.text[1]:SetText('|cffffffffBattleground|r')
						self.text[1]:SetPoint("LEFT", self.Frame, "LEFT",25, 0 );
	
						self.Frame:SetWidth(25)
				    	    	self.Frame:SetHeight(25)
						self.Frame:SetPoint("LEFT", Tongues.UI.MainMenu.AdvancedOptions.Frame, "TOPLEFT",150,  -170);
						self.Frame:SetText("CheckBox Thing");
	
						self.Frame:EnableMouse(true);
						self.Frame:RegisterForClicks("LeftButton");		
						self.Frame:Show();
					end;
	
					OnMouseUp = function(self)
						Tongues.UI.MainMenu.Screen.Battleground.Frame:SetChecked(not Tongues.UI.MainMenu.Screen.Battleground.Frame:GetChecked());

						if (Tongues.UI.MainMenu.Screen.Battleground.Frame:GetChecked() == 1) then
							Tongues.Settings.Character.Screen.Battleground = true;
						else
							Tongues.Settings.Character.Screen.Battleground = false;
						end;
					end;
	
					OnMouseDown = function(self)
					end;
				};
				--=======================================================================================================

			};
			--=======================================================================================================

		};

	};
	 
	 function TAddToOptionsPanel()
	  
	 end
	 

		
	