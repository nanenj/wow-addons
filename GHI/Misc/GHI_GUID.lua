local class


function GHI_GUID()
	if class then
		return class;
	end
	class = GHClass("GHI_GUID");

	local lastTime;
	local guid;

	local ToHex = function(v)
		return string.format("%X", v)
	end

	class.MakeGUID = function()
		if not (guid) then
			guid = string.gsub(string.gsub(UnitGUID("player"), "0x..", ""), "00[0]*", "")
		end

		local t = time() - 1315000000;
		if t <= (lastTime or 0) then
			t = lastTime + 1;
		end
		lastTime = t;

		local hashTime = ToHex(t)

		return guid .. "_" .. hashTime;
	end

	return class;
end


