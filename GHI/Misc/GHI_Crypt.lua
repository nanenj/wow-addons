--===================================================
--
--				GHI_Crypt
--  			GHI_Crypt.lua
--
--	          (description)
--
-- 	  (c)2012 The Gryphonheart Team
--			All rights reserved
--===================================================


local AREA = 91;
function GHI_Crypt(crypt)
	local class = GHClass("GHI_Crypt");

	local function GetCharSeqLen(n) -- charlen as according to http://en.wikipedia.org/wiki/UTF-8
		if n < 192 then
			return 1;
		elseif n < 224 then
			return 2;
		elseif n < 240 then
			return 3;
		else
			return 4;
		end
	end

	class.Encrypt = function(msg)
	-- 33 to 122
		local m = "";
		local ignore = 0;
		local i = 1;
		while i <= msg:len() do
			local n = string.byte(msg, i);
			if n == 124 then
				m = m .. strsub(msg, i, i + 1);
				i = i + 1;
			elseif (n > 190) then
				local csl = GetCharSeqLen(n);
				m = m .. strsub(msg, i, i + csl - 1);
				i = i + csl - 1;
			else
				local c = n;
				n = mod(((n - 32) + AREA) + crypt + i, AREA) + 32;
				m = m .. string.char(n);
			end
			i = i + 1;
		end

		return m;
	end

	class.Decrypt = function(msg)
		local s = "";
		local ignore = 0;
		local i = 1;
		while i <= msg:len() do
			local n = string.byte(msg, i);
			if n == 124 then -- skip |
				s = s .. strsub(msg, i, i + 1);
				i = i + 1;
			elseif (n > 190) then -- skip longer chars
				local csl = GetCharSeqLen(n);
				s = s .. strsub(msg, i, i + csl - 1);
				i = i + csl - 1;
			else
				local t = n;
				local plus = AREA;
				while (plus < i + 60) do plus = plus + AREA; end
				n = mod(((n - 32) - (crypt + i)) + plus, AREA) + 32;

				s = s .. string.char(n);
			end
			i = i + 1;
		end
		return s;
	end

	return class;
end

