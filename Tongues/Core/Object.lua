--======================OBJECT===============================
Object = {
	new = function(self,o)
		o = o or {}   -- create object if user does not provide one
		setmetatable(o, self)
		self.__index = self
		return o
	end;
};

--======================CLASS================================
Class = Object:new({
	GetName = function(self)
		local capture = nil;
		for k,v in pairs(_G) do
			if self == v then
				--print(k);
				capture = k;
			end;
		end;
		return capture;
	end;

	inherits = function (self, ...)
		local arg = {...}
		local c = Class:new()
		
		for i = 1, table.getn(arg) do
			for key, value in pairs(arg[i]) do
				c[key] = value;  
			end
		end;
		
	      return c
	end
});