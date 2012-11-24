Tongues = {};
Tongues.Custom = {};
Tongues.MenuClass={};

-- helpful function to merge tables
function merge(arglist)
	--Takes all passed tables and combines them into the output table
	local newtable = {};
	for i = 1, table.getn(arglist) do
		for key, value in pairs(arglist[i]) do
			newtable[key] = value;  
		end
	end
	return newtable
end
-----------------------------------------------------------------------
Tongues.ReturnSpecialLanguage = function()
	local x
	for x=1, GetNumLanguages() do
		if GetLanguageByIndex(x) ~= "Orcish" and GetLanguageByIndex(x) ~= "Common" then
			return GetLanguageByIndex(x)
		end;
	end
end;

Tongues.hasStarForm = function()
		if UnitClass("player") == "Druid" and GetShapeshiftForm(true) ~= 0 then
			for i = 1, NUM_GLYPH_SLOTS do
			  local enabled, glyphType, glyphTooltipIndex, glyphSpell, icon  = GetGlyphSocketInfo(i)--GetGlyphInfo(i)
			    if glyphSpell == 114301 then
				 hasSForm = true;
				end
			end
			for i=1, GetNumShapeshiftForms() do
				icon, name, active, castable = GetShapeshiftFormInfo(i);
				if name ~= "Moonkin Form" and active == 1 then
				  hasSForm =false;
				end
		    end
		end
		
	return hasSForm
end
-----------------------------------------------------------------------
Tongues.PairsByKeys = function(t, f)
	local a = {};
	for n in pairs(t) do table.insert(a, n) end
		table.sort(a, f);
		local i = 0      -- iterator variable
		local iter = function ()   -- iterator function
			i = i + 1
			if a[i] == nil then 
				return nil
			else 
				return a[i], t[a[i]]
			end;
	end
	return iter
end
-----------------------------------------------------------------------
-- BORROWED FROM LORE!!!!! The below comment is from the Lore addon (I kept this because it seems the most accurate to the Blizzard hash
-- Iriel's simpleHash algorithm: modified , also at Iriel's suggestion,
-- to reproduce the djb2 algorithm
Tongues.Hash = function( text )

	local l = strlen( text );
	-- Prime numbers
	local primes = { 5347, 5351, 5381, 5387, 5393, 5399, 5407, 5413, 5417, 5419, 5431, 5437, 5441, 5443, 5449 };

	local h = 5381;

	for i = 1, l, 1 do
		local v = strbyte( text, i );
		local p = primes[ mod( v, table.getn( primes ) ) + 1 ];

		h = ( ( h * p ) + v );
	end

	return h;

end;
----------------------------------------------------------------------------------------------------------------------------------
-- This should be processed from a variable/table later
Tongues.SplitLine = function(txt)
	local subtxt = {};
	local substring = "";
	local flag = false;

	substring = txt;
	substring = string.gsub(substring, "([%a'%s\46\33\63\40\41\44]+)(\42[%a]+\42)([%a'%s\46\33\63\40\41\44]+)", 
	function(a,b,c)
		if ( a ~= " " ) then
			table.insert(subtxt, a);
		end;
		if ( b ~= " " ) then
			table.insert(subtxt, b);
		end;
		if ( c ~= " " ) then
			table.insert(subtxt, c);
		end;
	end);

	-- If there are no splits just use the original message
	if (table.getn(subtxt) == 0) then
		table.insert(subtxt,txt);
	end

	return subtxt
end
----------------------------------------------------------------------------------------------------------------------------------
Tongues.ParseEmotes = function(msg)
	-- Change text like "*smile*" to emotes this might be better off as a conditional right next to the Hook Send
	msg = string.gsub(msg, "[\42]([%a]*)[\42]", function(a,b) DoEmote(string.upper(a)) return "" end);
	return msg
end
----------------------------------------------------------------------------------------------------------------------------------
Tongues.casematch = function (a, k, t)
	local b;
	if k ~= string.lower(a) then
		if a == string.upper(a) then
			b = string.upper(a);
		elseif a == string.lower(a) then
			b = string.lower(a);
		elseif string.find(a, "^%u") then
			b = string.gsub(a, "^(%a)", string.upper);
		else
			b = a
		end;
	elseif k == string.lower(a) then
			if a == string.upper(a) then
				b = string.upper(t[k])	
			elseif a == string.lower(a) then
				b = t[k]	
			elseif string.find(a, "^%u") then
				b = string.gsub(t[k], "^(%a)", string.upper);	
			else
				b = t[k]	
			end;
	end;
	return b;
end
----------------------------------------------------------------------------------------------------------------------------------
Tongues.AddTranslator = function(self,playername)
	tinsert(self.Settings.Character.Translators, playername);
end;
----------------------------------------------------------------------------------------------------------------------------------
Tongues.RemoveTranslator = function(self,playername)
	newtable = {};
	for i,v in ipairs(self.Settings.Character.Translators) do
		if v ~= playername then
			tinsert(newtable, playername);
		end;
	end;
	self.Settings.Character.Translators = newtable;
end;
----------------------------------------------------------------------------------------------------------------------------------
Tongues.FindTranslator = function(self,playername)
	playerexists = false
	for i,v in ipairs(self.Settings.Character.Translators) do
		if string.lower(v) == string.lower(playername) then
			playerexists = true;
		end;
	end;
	return playerexists
end;
----------------------------------------------------------------------------------------------------------------------------------
Tongues.GetRealLanguage = function(self, language)
	if self.Language[language] ~= nil then
		language = self.Language[language]["alias"] or language
	end;

	return language
end;
----------------------------------------------------------------------------------------------------------------------------------
Tongues.UpdateLanguageDropDown = function(self)
	local info            = {};
	local k,v;

	for k,v in Tongues.PairsByKeys(Tongues.Language) do
		local fluency = Tongues.Settings.Character.Fluency[k] or 0
		if fluency >= 30 then
			info.text       = k;
			info.value      = k;
			info.checked 	= nil; 
			info.func       = Tongues.UI.MainMenu.Speak.LanguageDropDown.OnClick;
			UIDropDownMenu_AddButton(info);
		end;
	end;		
end;


Tongues.UpdateDialect = function(self)
local info            = {};
						local k,v;
						for k,v in Tongues.PairsByKeys(Tongues.Dialect) do
							info.text       = k;
							info.value      = k;
							info.checked = nil; 
							info.func       = Tongues.UI.MainMenu.Speak.DialectDropDown.OnClick;
							UIDropDownMenu_AddButton(info);
						end;		

end--used for language to dialect link
-----------------------------------------------------------------------------------------------------------------------------------
---context menu Merge to tongues 2
Tongues.Timer = function(self,elapsed)
    local total = 0
 total = total + elapsed
    if total >= 15 then
       TTimerFrame:Hide()
        total = 0
 

    end

 

end

Tongues.UpdateLanguageContext = function(self)
	local info            = {};
	local k,v;
Tongues.MenuClass.menuItems = {};
	for k,v in Tongues.PairsByKeys(Tongues.Language) do
	--print(k)
	
		local fluency = Tongues.Settings.Character.Fluency[k] or 0
		if fluency >= 30 then
		table.insert(Tongues.MenuClass.menuItems, {
        ["text"] = k,
        ["func"] = Tongues.LDBT.OnClick,
        ["isTitle"] = nil,
		
    })			
			--Tongues.Menuss:AddItem(text,func,isTitle);
		
		end;
	end;		
end;


Tongues.UpdateDialectContext = function(self)
	local info            = {};
	local k,v;
Tongues.MenuClass.menuItems = {};
	for k,v in Tongues.PairsByKeys(Tongues.Dialect) do
		--local fluency = Tongues.Settings.Character.Fluency[k] or 0
		--if fluency >= 30 then
		table.insert(Tongues.MenuClass.menuItems, {
        ["text"] = k,
        ["func"] = Tongues.LDBT.OnClick,
        ["isTitle"] = nil,
		
    })			
			--Tongues.Menuss:AddItem(text,func,isTitle);
		
		--end;
	end;		
end;


Tongues.MenuClass.menuItems= {};






--[[
    Show the menu.
--]]
Tongues.MenuClass.uniqueID = 0;
Tongues.MenuClass.Show=function(self)

    if not self.menuFrame then
        while _G['GenericMenuClassFrame'..Tongues.MenuClass.uniqueID] do -- ensure that there's no namespace collisions
            Tongues.MenuClass.uniqueID = Tongues.MenuClass.uniqueID + 1
        end
        -- the frame must be named for some reason
        Tongues.MenuClass.menuFrame = CreateFrame('Frame', 'GenericMenuClassFrame'..Tongues.MenuClass.uniqueID, UIParent, "UIDropDownMenuTemplate")
    end
    EasyMenu(Tongues.MenuClass.menuItems, Tongues.MenuClass.menuFrame, "cursor", 0, 0, 'MENU', 10)
end