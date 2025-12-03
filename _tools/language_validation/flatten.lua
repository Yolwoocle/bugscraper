--- Creates a flat version of a table
--- @param inputTable table
--- @return table flatTable
--- @nodiscard
local function flattenTable(inputTable)
	assert(type(inputTable) == "table", "Input must be a table")

	local flatTable = {}

	--- Recursive function to flatten a table
	--- @param currentTable table
	--- @param currentPath string
	local function _recursiveFlatten(currentTable, currentPath)
		assert(type(currentTable) == "table", "Input must be a table")
		assert(type(currentPath) == "string" or currentPath == nil, "Path must be a string")
		for key, value in pairs(currentTable) do
			local newPath

			if currentPath == "" then
				newPath = tostring(key)
			else
				newPath = currentPath .. "." .. tostring(key)
			end

			if type(value) == "table" then
				_recursiveFlatten(value, newPath)
			else
				flatTable[newPath] = value
			end
		end
	end

	_recursiveFlatten(inputTable, "")

	return flatTable
end

return flattenTable
