local utf8 = require "utf8"

-- Thanks to "index five" on Discord
local utf8pos, utf8len = utf8.offset, utf8.len
local sub = string.sub
local max, min = math.max, math.min

local function posrelat(pos, len)
	if pos >= 0 then return pos end
	if -pos > len then return 0 end
	return pos + len + 1
end

function utf8.sub(str, i, j)
	local len = utf8len(str)
	i, j = max(posrelat(i, len), 1), j and min(posrelat(j, len), len) or len
	if i <= j then
		return sub(str, utf8pos(str, i), utf8pos(str, j + 1) - 1)
	end
	return ""
end

utf8.upper = string.upper -- TODO
utf8.lower = string.lower