require "scripts.util"
local Class = require "scripts.meta.class"

local Files = Class:inherit()

function Files:init()
    
end


function Files:parse_value(str_value, reference_value)
    local val
    local typ = type(reference_value)
    if typ == "string" then
        val = str_value   
    elseif typ == "number" then
        val = tonumber(str_value)
    elseif typ == "boolean" then
        val = strtobool(str_value)
    elseif typ == "table" then
        val = split_str(str_value, ",") 
        for index, subval in pairs(val) do
            val[index] = self:parse_value(subval, (reference_value[index] or reference_value[1]) or "")
        end
    end

    return val
end


function Files:read_config_file(path, reference, create_if_missing)
    create_if_missing = param(create_if_missing, true)

    if not love.filesystem.getInfo then
        print("/!\\ WARNING: love.filesystem.getInfo doesn't exist. Either running on web or LÖVE version is incorrect. Loading options.txt aborted, so custom options will not be loaded.")
        return copy_table_deep(reference)
    end
    local options_file_exists = love.filesystem.getInfo(path)
    if not options_file_exists then
        if create_if_missing then
            print("'"..tostring(path).."' does not exist, so creating it")
            self.is_first_time = true
            self:write_config_file(path, reference)
        end
        return copy_table_deep(reference)
    end

    -- Read options.txt file
    local file = love.filesystem.openFile(path, "r")

    local text, size = file:read()
    if not text then    print("Error reading '"..tostring(path).."' file: "..size)    end
    local lines = split_str(text, "\n") -- Split lines

    local output = copy_table_deep(reference)
    for i = 1, #lines do
        local line = lines[i]
        local tab = split_str(line, ":")
        local key, value = tab[1], tab[2]

        if reference[key] ~= nil then
            local val = self:parse_value(value, reference[key])
            output[key] = val
        else
            print(concat("Key error: key '",key,"' for '",path,"' does not exist"))
        end
    end

	file:close()

    return output
end


function Files:write_config_file(path, values) 
    -- Does not support writing the ":" character as it is used as separator. Good enough for now, implement escaping if needed.
    local file = love.filesystem.openFile(path, "w")
	
	for key, value in pairs(values) do
		local string_val = value
        if type(value) == "number" then   string_val = tostring(value)   end
        if type(value) == "boolean" then  string_val = tostring(value)   end
        if type(value) == "table" then    string_val = concatsep(value, ",")   end

		local success, errmsg = file:write(concat(key, ":", string_val, "\n"))
	end
	
	file:close()
end

return Files