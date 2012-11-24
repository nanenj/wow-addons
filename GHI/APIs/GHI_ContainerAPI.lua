--===================================================
--
--				GHI_ContainerAPI
--  			GHI_ContainerAPI.lua
--
--	   Applies security checks to the container API functions and makes them available to the scripting environment
--
-- 	  (c)2012 The Gryphonheart Team
--			All rights reserved
--===================================================

local class;
function GHI_ContainerAPI()
	if class then
		return class;
	end
	class = GHClass("GHI_ContainerAPI");

	local containerList = GHI_ContainerList();
	local itemList = GHI_ItemInfoList();
	local api = {};
	--local currentStack, currentItem;
	local standardItemMenuList = GHI_StandardItemMenuList();
	local advancedItemMenuList = GHI_AdvancedItemMenuList();
    local simpleItemMenuList = GHI_SimpleItemMenuList();

	api.GHI_GetCurrentMainBagGUID = containerList.GetCurrentMainBagGUID;
	api.GHI_GetContainerItemInfo = containerList.GetContainerItemInfo;

	api.GHI_GetItemCooldown = function(guid)
		local item = itemList.GetItemInfo(guid);
		if item then
			return item.GetCooldown();
		end
	end

	api.GHI_GetItemInfo = function(guid)
		local item = itemList.GetItemInfo(guid);
		if item then
			return item.GetItemInfo();
		end
	end

	api.GHI_DisplayContainerItemTooltip = function(...)
		GHCheck("DisplayContainerItemTooltip", { "numberString", "numberString", "tableFrame", "tableFrame", "booleanNil" }, { ... })
		containerList.DisplayItemTooltip(...)
	end

	api.GHI_DisplayItemTooltip = function(...)
		itemList.DisplayItemTooltip(...);
	end

	api.GHI_UseItem = containerList.UseItem;

	api.GHI_NextMainBagPage = containerList.NextMainBagPage;
	api.GHI_PrevMainBagPage = containerList.PrevMainBagPage;
	api.GHI_GotNextMainBagPage = containerList.GotNextMainBagPage;
	api.GHI_GotPrevMainBagPage = containerList.GotPrevMainBagPage;

	api.GHI_PickupContainerItem = function(...)
		GHCheck("GHI_PickupContainerItem", { "numberString", "numberString" }, { ... })
		containerList.PickupContainerItem(...);
	end
	api.GHI_SplitContainerItem = function(...)
		GHCheck("GHI_SplitContainerItem", { "numberString", "numberString", "number" }, { ... })
		containerList.SplitContainerItem(...);
	end

	api.GHI_CanCopyItem = function(guid)
		local item = itemList.GetItemInfo(guid)
		if item then
			return item.CanCopy();
		end
		return false;
	end

	api.GHI_CopyContainerItem = function(...)
		GHCheck("GHI_CopyContainerItem", { "numberString", "numberString", "number" }, { ... })
		containerList.CopyContainerItem(...);
	end

	api.GHI_GetContainerInfo = function(guid)
		return containerList.GetContainerInfo(guid);
	end
	--[[api.GHI_GetCurrentItemGUID = function()
		if currentItem then
			return currentItem.GetGUID();
		end
	end
	api.GHI_GetCurrentItemInfo = function()
		if currentItem then
			return currentItem.GetItemInfo();
		end
	end
	api.GHI_GetCurrentAmount = function()
		if currentStack then
			local _, _, amount = currentStack.GetContainerItemInfo();
			return amount;
		end
	end   --]]
	--[[
	api.GHI_GetCurrentItemInstanceCount = function()
		if currentStack then
			return currentStack.GetItemInstanceCount();
		end
		return 0;
	end
	api.GHI_GetCurrentItemInstanceAmount = function(index)
		if currentStack then
			return currentStack.GetItemInstanceAmount();
		end
		return 0;
	end
	api.GHI_GetAttribute = function(index, name)
		if currentStack then
			return currentStack.GetAttribute(index, name);
		end
	end
	api.GHI_SetAttribute = function(index, name, value)
		if currentStack then
			currentStack.SetAttribute(index, name, value);
		end
	end   --]]

	api.GHI_NewItem = function(newType)
        if newType == "standard" then
            standardItemMenuList.New()
        elseif newType == "simple" then
            simpleItemMenuList.New()
        elseif newType == "advanced" then
            advancedItemMenuList.New()
        end
    end
        
        
	api.GHI_EditItem = function(guid )
		if not(api.GHI_IsBeingEdited(guid)) then
			local item = itemList.GetItemInfo(guid);
			if item then
				if item.GetItemComplexity() == "standard" then
					standardItemMenuList.Edit(guid)
				else
					advancedItemMenuList.Edit(guid)
				end
			end
		end
	end
   	api.GHI_IsBeingEdited = function(guid)
		return standardItemMenuList.IsBeingEdited(guid) or advancedItemMenuList.IsBeingEdited(guid);
	end


	api.GHI_CountItem = function(itemGuid)
		local stacks = containerList.FindAllStacks(itemGuid);
		local c = 0;
		for _, stack in pairs(stacks) do
			local container = stack.GetParentContainer();
			c = c + stack.GetTotalAmount();
		end
		return c;
	end

	api.GHI_FindOneItem = function(itemGuid)
		local stacks = containerList.FindAllStacks(itemGuid);
		for _, stack in pairs(stacks) do
			local container = stack.GetParentContainer();
			if container then
				return container.GetGUID(), container.GetSlotIDOfStack(stack);
			end
		end
	end

	api.GHI_GenerateExportCode = function(...)
		return GHI_ExportItem().GenerateExportCode(...);
	end

	api.GHI_ImportItemFromCode = function(...)
		return GHI_ExportItem().ImportItemFromExportCode(...);
	end

	local instanceMenuList = GHI_MenuList("GHI_InstanceMenu");
	api.GHI_DisplayAttributeAndInstanceInfo = function(containerGuid,slotID)
		local stack = containerList.GetStack(containerGuid,slotID);
		if stack then
			instanceMenuList.New(stack);
		end
	end

	class.GetAPI = function()
		local a = {};
		for i, f in pairs(api) do
			a[i] = f;
		end
		return a;
	end

	--[[
	class.UpdateMeta = function(stack)
		currentStack = stack;
		if stack then
			currentItem = stack.GetItemInfo()
		else
			currentItem = nil;
		end
	end --]]





	return class;
end

