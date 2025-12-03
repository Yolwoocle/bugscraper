--- Makes the header of the spreadsheet
--- @param req_lang_list table
--- @return string
local function header(req_lang_list)
	--- @diagnostic disable-next-line: redefined-local
	local header = [["Path", "Reference", ]]
	for k, _ in pairs(req_lang_list) do
		-- It should let emojis through but if there's a problem check here.
		local sanitized = tostring(k):gsub("%W", "_")
		header = string.format([[%s"%s", ]], header, sanitized)
	end
	return header .. "\n"
end

return header
