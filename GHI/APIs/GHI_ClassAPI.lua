--===================================================
--
--				GHI_ClassAPI
--  			GHI_ClassAPI.lua
--
--	          (description)
--
-- 	  (c)2011 The Gryphonheart Team
--			All rights reserved
--===================================================

local class;
function GHI_ClassAPI()
	if class then
		return class;
	end
	class = GHClass("GHI_ClassAPI");

	local api = {};

	api.GHI_Timer = GHI_Timer;
	--syntax GHI_Timer(func, interval, onceOnly) function must be a declared, not existing. interval is number, onceOnly is boolean if nil, repeats.
	api.GHI_Comm = function()
		local obj = {};
		local comm = GHI_Comm();
		obj.AddRecieveFunc = comm.AddRecieveFunc;
		obj.Send = comm.Send;
		obj.GetQueueSize = comm.GetQueueSize;
		return obj;
	end
	api.GHI_Position = function()
		local obj = {};
		local pos = GHI_Position();

		obj.GetCoor = pos.GetCoor;
		-- Syntax: obj.GetCoor(unit, deciPlace) returns string of coordinates.
		obj.GetPlayerPos = pos.GetPlayerPos;
		--  Syntax obj.GetPlayerPos(deciPlace) returns table {x = number, y = number, world = number(1 = Azeroth, 2 = Outland) all 0 for dungeons}
		obj.IsPosWithinRange = pos.IsPosWithinRange;
		-- Syntax obj.IsPosWithinRange(positon,range), position = table {x,y,world} range = number returns boolean
		return obj;
	end
	api.GHI_SlashCmd = GHI_SlashCmd;
	--syntax obj = GHI_SlashCmd(mainSlashPrefix)
	-- returns obj.SetDefaultFunc(func) func = Function, obj.RegisterSubPrefix(subPrefix, func) subPrefix = String, func = Function, 
	api.GHI_ChannelComm = function()
		local obj = {};
		local comm = GHI_ChannelComm();
		obj.AddRecieveFunc = comm.AddRecieveFunc;
		obj.Send = comm.Send;
		return obj;
	end

	api.GHI_Event = function(event,func)
		GHI_Event(event,func);
	end

	api.GHI_GUID = function()
	
		local GUID = GHI_GUID()
		local obj = {};
		obj.MakeGUID = GUID.MakeGUID;
	     return obj;
	end
	
	class.GetAPI = function()
		local a = {};
		for i, f in pairs(api) do
			a[i] = f;
		end
		return a;
	end

	return class;
end

