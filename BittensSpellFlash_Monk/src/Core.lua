local AddonName, a = ...
a.AddonName = AddonName
a.Build = select(4, GetBuildInfo())
a.AddonTitle = select(2, GetAddOnInfo(AddonName))
a.PlainAddonTitle = a.AddonTitle:gsub("|c........", ""):gsub("|r", "")
local L = a.Localize
local s = SpellFlashAddon
local CheckButtonOptions = nil
local EditBoxOptions = nil
local OnModuleSettingsSave = nil
local DefaultConfigs = {}

local parent = AddonName.."_SpellFlashAddonOptionsFrame"
a.OptionsFrame = CreateFrame("Frame", parent, nil, "SpellFlashAddon_OptionsFrameTemplate2")
s.RegisterModuleOptionsWindow(AddonName, a.OptionsFrame)

function a.BuildFail(Min, Over)
	return a.Build < (Min or 0) or ( (Over or 0) > 0 and a.Build >= Over )
end

function a.print(...)
	return print("|cFF00FFFF["..a.PlainAddonTitle.."]|r", ...)
end

function a.SetDefault(key, value)
	DefaultConfigs[key] = value
end

function a.GetDefault(key)
	return DefaultConfigs[key]
end

function a.SetConfig(key, value, NoDefault)
	if NoDefault or value ~= a.GetDefault(key) then
		s.SetModuleConfig(AddonName, key, value)
	else
		s.SetModuleConfig(AddonName, key, nil)
	end
end

function a.GetConfig(key, NoDefault)
	if NoDefault then
		return s.GetModuleConfig(AddonName, key)
	end
	return s.GetModuleConfig(AddonName, key) or a.GetDefault(key)
end

function a.ClearAllConfigs()
	s.ClearAllModuleConfigs(AddonName)
end

function a.OptionsFrame.okay()
	a.SetConfig("spell_flashing_off", not _G[parent.."_SpellFlashing"]:GetChecked())
	if type(CheckButtonOptions) == "table" then
		for button, option in pairs(CheckButtonOptions) do
			if _G[parent..button] and type(option) == "table" and type(option.ConfigKey) == "string" and option.ConfigKey ~= "" and option.ConfigKey ~= "My_Config_Key" then
				if option.DefaultChecked then
					a.SetConfig(option.ConfigKey, not _G[parent..button]:GetChecked())
				else
					a.SetConfig(option.ConfigKey, not not _G[parent..button]:GetChecked())
				end
			end
		end
	end
	if type(EditBoxOptions) == "table" then
		for box, option in pairs(EditBoxOptions) do
			if _G[parent..box] and type(option) == "table" and type(option.ConfigKey) == "string" and option.ConfigKey ~= "" and option.ConfigKey ~= "My_Config_Key" then
				if option.Numeric then
					a.SetConfig(option.ConfigKey, _G[parent..box]:GetNumber() or 0)
				else
					a.SetConfig(option.ConfigKey, _G[parent..box]:GetText() or "")
				end
			end
		end
	end
	if type(a.Spam) == "table" and type(a.Spam[1]) == "table" and type(a.Spam[1].Function) == "function" then
		local Value = _G[parent.."_ScriptSlider"]:GetValue()
		if Value == 1 or type(a.Spam[Value]) ~= "table" or type(a.Spam[Value].Function) ~= "function" then
			Value = nil
		end
		a.SetConfig("script_number", Value)
	end
	if type(OnModuleSettingsSave) == "function" then
		OnModuleSettingsSave()
	end
end

function a.OptionsFrame.refresh()
	_G[parent.."_SpellFlashing"]:SetChecked(not a.GetConfig("spell_flashing_off"))
	if type(CheckButtonOptions) == "table" then
		for button, option in pairs(CheckButtonOptions) do
			if _G[parent..button] and type(option) == "table" and type(option.ConfigKey) == "string" and option.ConfigKey ~= "" and option.ConfigKey ~= "My_Config_Key" then
				if option.DefaultChecked then
					_G[parent..button]:SetChecked(not a.GetConfig(option.ConfigKey))
				else
					_G[parent..button]:SetChecked(a.GetConfig(option.ConfigKey))
				end
				_G[parent..button.."Text"]:SetText(option.Label or "")
				_G[parent..button]:Show()
			end
		end
	end
	if type(EditBoxOptions) == "table" then
		for box, option in pairs(EditBoxOptions) do
			if _G[parent..box] and type(option) == "table" and type(option.ConfigKey) == "string" and option.ConfigKey ~= "" and option.ConfigKey ~= "My_Config_Key" then
				_G[parent..box]:SetMaxLetters(tonumber(option.MaxCharacters) or 999)
				_G[parent..box]:SetNumeric(option.Numeric or false)
				if option.Numeric then
					_G[parent..box]:SetNumber(a.GetConfig(option.ConfigKey))
				else
					_G[parent..box]:SetText(a.GetConfig(option.ConfigKey))
				end
				_G[parent..box.."TextLabel"]:SetText(option.Label or "")
				_G[parent..box.."Text"]:Show()
				_G[parent..box]:Show()
			end
		end
	end
	if type(a.Spam) == "table" and type(a.Spam[1]) == "table" and type(a.Spam[1].Function) == "function" then
		_G[parent.."_ScriptSlider"]:Show()
		_G[parent.."_ScriptSliderTitle"]:Show()
		_G[parent.."_ScriptSliderDescription"]:Show()
		_G[parent.."_ScriptSliderMinValue"]:Show()
		_G[parent.."_ScriptSliderMaxValue"]:Show()
		_G[parent.."_ScriptSliderValue"]:Show()
		local MaxValue = getn(a.Spam)
		_G[parent.."_ScriptSlider"]:SetMinMaxValues(1, MaxValue)
		_G[parent.."_ScriptSliderMinValueLabel"]:SetText("1")
		_G[parent.."_ScriptSliderMaxValueLabel"]:SetText(""..MaxValue)
		local Value = a.GetConfig("script_number") or 1
		if type(a.Spam[Value]) ~= "table" or type(a.Spam[Value].Function) ~= "function" then
			Value = 1
		end
		_G[parent.."_ScriptSlider"]:SetValue(Value)
		_G[parent.."_ScriptSliderTitleLabel"]:SetText(a.Spam[Value].Title or "")
		_G[parent.."_ScriptSliderDescriptionLabel"]:SetText(a.Spam[Value].Description or "")
		_G[parent.."_ScriptSliderValueLabel"]:SetText(""..Value)
	end
end

function a.OptionsFrame.default()
	a.ClearAllConfigs()
end

L["Spell Flashing"] = s.L["Spell Flashing"]
local function LocalizeFontStrings(frame)
	for _, f in next, {frame:GetChildren()} do
		if f:GetObjectType() == "FontString" then
			f:SetText(L[f:GetText()])
		else
			for _, f in next, {f:GetRegions()} do
				if f:GetObjectType() == "FontString" then
					f:SetText(L[f:GetText()])
				end
			end
		end
	end
end
LocalizeFontStrings(a.OptionsFrame)
_G[parent.."TitleString"]:SetText(a.AddonTitle.." "..GetAddOnMetadata(AddonName, "Version"))

function a.OptionsFrame.UpdateSliderText(self)
	if self and self:IsVisible() then
		local Value = self:GetValue()
		if type(a.Spam[Value]) ~= "table" or type(a.Spam[Value].Function) ~= "function" then
			Value = 1
		end
		_G[parent.."_ScriptSliderTitleLabel"]:SetText(a.Spam[Value].Title or "")
		_G[parent.."_ScriptSliderDescriptionLabel"]:SetText(a.Spam[Value].Description or "")
		_G[parent.."_ScriptSliderValueLabel"]:SetText(""..Value)
	end
end

function a.RunSpamTable()
	if type(a.Spam) == "table" then
		local i = a.GetConfig("script_number") or 1
		if type(a.Spam[i]) == "table" and type(a.Spam[i].Function) == "function" then
			a.Spam[i].Function()
		elseif type(a.Spam[1]) == "table" and type(a.Spam[1].Function) == "function" then
			a.SetConfig("script_number", nil)
			a.Spam[1].Function()
		else
			a.Spam = nil
		end
	end
end

function a.LoadConfigs(config)
	if type(config) == "table" then
		s.RegisterOtherAurasFunction(config.OtherAurasFunction, AddonName)
		if type(config.event) == "table" and next(config.event) then
			for Event, Function in pairs(config.event) do
				s.RegisterModuleEvent(AddonName, Event, Function, a.OptionsFrame)
			end
		end
		if type(config.CheckButtonOptions) == "table" then
			CheckButtonOptions = config.CheckButtonOptions
		end
		if type(config.EditBoxOptions) == "table" then
			EditBoxOptions = config.EditBoxOptions
			for box, option in pairs(EditBoxOptions) do
				if _G[parent..box] and type(option) == "table" and type(option.ConfigKey) == "string" and option.ConfigKey ~= "" and option.ConfigKey ~= "My_Config_Key" then
					if option.Numeric then
						a.SetDefault(option.ConfigKey, tonumber(option.DefaultValue) or 0)
					else
						a.SetDefault(option.ConfigKey, tostring(option.DefaultValue or ""))
					end
				end
			end
		end
		if type(config.SlashHandler) == "function" then
			SlashCmdList[AddonName] = config.SlashHandler
		end
		if type(config.SlashCommands) == "table" then
			for i, v in ipairs(config.SlashCommands) do
				_G["SLASH_"..AddonName..i] = v
			end
		end
		if type(config.OnModuleSettingsSave) == "function" then
			OnModuleSettingsSave = config.OnModuleSettingsSave
		end
	end
end

a.spells = {}
L["<SPELL> has not been defined in a table!"] = s.L["<SPELL> has not been defined in a table!"]

local function CheckThenFlash(name, NoFlash)
	if not name then return false end
	local z = a.spells[name]
	if not z then
		a.print(s.Replace(L["<SPELL> has not been defined in a table!"], "<SPELL>", "\""..name.."\""))
		return false
	end
	return s.CheckThenFlash(z, NoFlash)
end

function a.Flash(...)
	local name = ...
	if type(name) == "table" then
		return a.Flash(unpack(name))
	end
	local last = nil
	for i = 1, select("#", ...) do
		name = select(i, ...)
		if CheckThenFlash(name) then
			last = name
			if not a.spells[name].Continue then
				break
			end
		end
	end
	return last
end

function a.FlashAll(...)
	local name = ...
	if type(name) == "table" then
		return a.FlashAll(unpack(name))
	end
	local last = nil
	for i = 1, select("#", ...) do
		name = select(i, ...)
		if CheckThenFlash(name) then
			last = name
		end
	end
	return last
end

function a.Flashable(...)
	local name = ...
	if type(name) == "table" then
		return a.Flashable(unpack(name))
	end
	for i = 1, select("#", ...) do
		name = select(i, ...)
		if CheckThenFlash(name, 1) then
			return name
		end
	end
	return nil
end

function a.AllFlashable(...)
	local name = ...
	if type(name) == "table" then
		return a.AllFlashable(unpack(name))
	end
	local last = nil
	for i = 1, select("#", ...) do
		name = select(i, ...)
		if CheckThenFlash(name, 1) then
			last = name
		elseif name then
			return nil
		end
	end
	return last
end

a.OptionsFrame.parent = select(2, GetAddOnInfo("SpellFlash"))
a.OptionsFrame.name = a.AddonTitle
InterfaceOptions_AddCategory(a.OptionsFrame)


-- old code left in for backward compatibility to allow partial transitions to the newer methods
local function False() return false end
local function DefaultCastable(_, key) a.print(s.Replace(L["<SPELL> has not been defined in a table!"], "<SPELL>", "\""..key.."\"")) return False end
a.Castable = setmetatable({}, {__index = DefaultCastable})
a.VehicleCastable = setmetatable({}, {__index = DefaultCastable})
a.ItemCastable = setmetatable({}, {__index = DefaultCastable})
