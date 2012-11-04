local addonName = "Altoholic"
local addon = _G[addonName]

addon.Helpers = {}

local ns = addon.Helpers		-- ns = namespace

-- ** Drop Down Menus **

function ns.DDM_AddTitle(text, icon)
	local info = UIDropDownMenu_CreateInfo()

	info.isTitle	= 1
	info.text = text
	info.icon = icon
	info.checked = nil
	info.notCheckable = 1
	UIDropDownMenu_AddButton(info, 1)
end

function ns.DDM_Add(text, value, func, icon, isChecked)
	local info = UIDropDownMenu_CreateInfo()
	
	info.text		= text
	info.value		= value
	info.func		= func
	info.icon		= icon
	info.checked	= isChecked
	UIDropDownMenu_AddButton(info, 1)
end

function ns.DDM_AddWithArgs(text, value, func, arg1, arg2, isChecked)
	local info = UIDropDownMenu_CreateInfo()
	
	info.text		= text
	info.value		= value
	info.func		= func
	info.arg1		= arg1
	info.arg2		= arg2
	info.checked	= isChecked
	UIDropDownMenu_AddButton(info, 1)
end

function ns.DDM_AddCloseMenu()
	local info = UIDropDownMenu_CreateInfo()

	info.text = CLOSE
	info.func = function() CloseDropDownMenus() end
	info.icon = nil
	info.checked = nil
	info.notCheckable = 1
	UIDropDownMenu_AddButton(info, 1)
end

-- ** 2-level Drop Down Menus **

function ns.DDMLv1_Add(text, value, arg1, arg2)
	local info = UIDropDownMenu_CreateInfo()
	
	info.text		= text
	info.value		= value
	info.arg1		= arg1
	info.arg2		= arg2
	info.checked	= nil
	info.hasArrow	= 1
	UIDropDownMenu_AddButton(info, 1)
end

function ns.DDMLv2_Add(text, value, func, icon, isChecked)
	local info = UIDropDownMenu_CreateInfo()
	
	info.text		= text
	info.value		= value
	info.func		= func
	info.icon		= icon
	info.checked	= isChecked
	UIDropDownMenu_AddButton(info, 2)
end


-- ** String **

function ns.IsNumberInString(number, str)
	-- ex: with str = "15|10|3" returns true if value is in this string
	for v in str:gmatch("(%d+)") do
		if tonumber(v) == number then
			return true
		end
	end
end
