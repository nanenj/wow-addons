--===================================================
--
--				GHI_SimpleItemMenuList
--  			GHI_SimpleItemMenuList.lua
--
--	          Handler for the simple item menus
--
-- 	  (c)2012 The Gryphonheart Team
--			All rights reserved
--===================================================

local class;
function GHI_SimpleItemMenuList()
	if class then
		return class;
	end
	class = GHClass("GHI_SimpleItemMenuList");

	local menus = {};

	local GetMenu = function()
		for i, menu in pairs(menus) do
			if not (menu.IsInUse()) then
				return menu
			end
		end
		local menu = GHI_SimpleItemMenu();
		table.insert(menus, menu);
		return menu;
	end

	class.New = function()
		GetMenu().New();
	end
	class.Edit = function(guid)
		GetMenu().Edit(guid);
	end


	return class;
end

