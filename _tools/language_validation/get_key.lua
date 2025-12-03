--- Retrieves a value from a nested table using a dot-separated path string.
---
--- @param inputTable table The table to search within.
--- @param pathString string The dot-separated path to the desired value
---                          (e.g., "details.properties.weight").
--- @return any The value found at the specified path, or `nil` if the path
---             does not exist, an intermediate segment is not a table,
---             or the input path is invalid.
local function getValueFromPath(inputTable, pathString)
	if pathString == "" then
		return inputTable
	end

	local current = inputTable

	for segment in pathString:gmatch("[^.]+") do
		if type(current) ~= "table" then
			return nil
		end

		-- Access the next level using the current segment as a key.
		-- Lua handles implicit conversion of string "1" to number 1 for table keys
		-- if the table has a numeric key, which is usually what you want for
		-- paths like "my_list.1.name". For explicit string keys like `['1']`,
		-- it still works as `current["1"]`.
		current = current[segment]

		-- If 'current' becomes nil at any point, it means the segment doesn't exist.
		if current == nil then
			return nil
		end
	end

	return current
end

return getValueFromPath
