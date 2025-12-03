local function sortByKey(inputTable)
	local sortedPairs = {}

	local keys = {}
	for key, _ in pairs(inputTable) do
		table.insert(keys, key)
	end

	table.sort(keys, function(a, b)
		return tostring(a) < tostring(b)
	end)

	for _, key in ipairs(keys) do
		table.insert(sortedPairs, { key = key, value = inputTable[key] })
	end

	return sortedPairs
end

return sortByKey
