--===================================================
--
--				GHM_Inputs
--  			GHM_Inputs.lua
--
--	          (description)
--
-- 	  (c)2012 The Gryphonheart Team
--			All rights reserved
--===================================================
local function GetInputTypes()
local loc = GHI_Loc();
return {
	string = {
		ghm = {
			type = "Editbox",
			width = 130,
			texture = "Tooltip",
		},
		ghm_fromDDList = {
			type = "CustomDD",
		},
		ghm_fromRadio = {
			type = "RadioButtonSet"
		},
		validate = function(value) return type(value) == "string" end,
		default = "",
	},
	number = {
		ghm = {
			type = "Editbox",
			width = 130,
			texture = "Tooltip",
			numbersOnly = true,
		},
		validate = function(value) return type(value) == "number" end,
		default = 0,
		mergeRules = {
			average = {
				func = function(value1,count1,value2,count2)
					return ((value1*count1) + (value2*count2)) / (count1+count2);
				end
			},
			average_rounded = {
				func = function(value1,count1,value2,count2)
					return math.floor(((value1*count1) + (value2*count2)) / (count1+count2) + 0.5);
				end
			},
			sum = {
				func = function(value1,count1,value2,count2)
					return value1 + value2;
				end
			},
			min = {
		   		func = function(value1,count1,value2,count2)
					return math.min(value1,value2);
				end
			},
			max = {
				func = function(value1,count1,value2,count2)
					return math.max(value1,value2);
				end
			},
		},
	},
	code = {
		ghm = {
			type = "CodeField",
			height = 430,
			width = 380,
			size = "L",
		},
		validate = function(value) return type(value) == "string" end,
		default = "",
		toValueString = function(value) return "..."; end,
	},
	position = {
		ghm = {
			type = "Position",
			size = "M",
		},
		validate = function(value)
			return (type(value) == "table" and type(value.x) == "number" and type(value.y) == "number" and type(value.world) == "number" );

		end,
		default = {
			x = 0,
			y = 0,
			world = 0,
		},
		toValueString = function(value) return string.format("%.2f; %.2f; %.2f",value.x,value.y,value.world); end,
	},
	boolean= {
		ghm = {
			type = "CheckBox",
		},
		validate = function(value)
			return (not(value) or type(value) == "boolean");
		end,
		default = false,
		defaultGhm = {
			type = "RadioButtonSet",
			dataFunc = function()
				return {
					{
						value = true,
						text = "true",
					},
					{
						value = false,
						text = "false",
					},
				}
			end,
		},
		toValueString = function(value) if value == true then return "true"; else return "false"; end end,
	},
	icon = {
		ghm = {
			type = "Icon",
			text = loc.ICON,
			align = "c",
			label = "icon",
			framealign = "r",
			CloseOnChoosen = true,
			OnChanged = function(icon)

			end
		},
		validate = function(value)
			if type(value) == "string" then
				return true;
			end
		end,
		default = "",
		toValueString = function(value) return "\124T"..value..":16\124t"; end,
	},
	sound = {
		ghm = {
			type = "Sound",
		},
		validate = function(value)
			return (type(value) == "table" and type(value.path) == "string" and type(value.duration) == "number");
		end,
		default = nil,

	},
	text = {
		ghm = {
			type = "EditField",
			width = 130,
		},
		validate = function(value)
			return (type(value) == "string");
		end,
		default = "",
	},
	color = {
		ghm = {
			type = "Color",
		},
		validate = function(value)
			return (type(value) == "table" and value.r and value.g and value.b);
		end,
		default = {r=1,g=0,b=0.5},
	},
	item = {
		ghm = {
			type = "Item",
			size = "M",
		},
		validate = function(value)
			return type(value) == "string";
		end,
		default = "",
	},
};
 end

local INPUT_TYPES;

function GHM_Input_GetAvailableTypes()
	if not(INPUT_TYPES) then INPUT_TYPES = GetInputTypes() end

	local t = {};
	for type, _ in pairs(INPUT_TYPES) do
		table.insert(t, type);
	end
	return t;
end

function GHM_Input_Validate(typeName, value)
	if not(INPUT_TYPES) then INPUT_TYPES = GetInputTypes() end

	if INPUT_TYPES[typeName] and INPUT_TYPES[typeName].validate then
		if INPUT_TYPES[typeName].validate(value) then
			return true;
		else
			return false,"Validation false for type: "..tostring(typeName).." with value "..tostring(value).." ("..type(value)..")";
		end
	end
	return false,"Validation not found for type: "..tostring(typeName);
end

function GHM_Input_GenerateMenuObject(typeName, name, label, defaultGHM)
	if not(INPUT_TYPES) then INPUT_TYPES = GetInputTypes() end
	local ghmType = "ghm";
	if defaultGHM == true then
		ghmType = "defaultGhm";
	elseif defaultGHM then
		ghmType = defaultGHM;
	end
	if INPUT_TYPES[typeName] and (INPUT_TYPES[typeName][ghmType] or INPUT_TYPES[typeName].ghm)  then
		local t = {};
		for i, v in pairs(INPUT_TYPES[typeName][ghmType] or INPUT_TYPES[typeName].ghm ) do
			t[i] = v;
		end
		t.text = name;
		t.label = label;
		return t;
	end
end

function GHM_Input_GetDefaultValue(typeName)
	if not(INPUT_TYPES) then INPUT_TYPES = GetInputTypes() end
	if INPUT_TYPES[typeName] and INPUT_TYPES[typeName].default then
		return INPUT_TYPES[typeName].default;
	end
end

function GHM_Input_Merge(typeName,mergeRule,value1,count1,value2,count2)
	if not(INPUT_TYPES) then INPUT_TYPES = GetInputTypes() end
	if INPUT_TYPES[typeName] and INPUT_TYPES[typeName].mergeRules and INPUT_TYPES[typeName].mergeRules[mergeRule] then
		return INPUT_TYPES[typeName].mergeRules[mergeRule].func(value1,count1,value2,count2);
	end
	return value1;
end

function GHM_Input_GetAvailableMergeRules()
	if not(INPUT_TYPES) then INPUT_TYPES = GetInputTypes() end
	local t = {};
	for typeName, d in pairs(INPUT_TYPES) do
		local m = {"none"};
		if d.mergeRules then
			for ruleName,_ in pairs(d.mergeRules) do
				table.insert(m,ruleName);
			end
		end
		t[typeName] = m;
	end
	return t;
end

function GHM_Input_ToString(typeName,value)
	if not(INPUT_TYPES) then INPUT_TYPES = GetInputTypes() end
	if INPUT_TYPES[typeName] then
		if INPUT_TYPES[typeName].toValueString then
			return INPUT_TYPES[typeName].toValueString(value);
		else
			return tostring(value);
		end
	end
	return "..."
end



