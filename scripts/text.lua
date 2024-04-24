require "scripts.util"
local utf8 = require "utf8"
local Class = require "scripts.meta.class"

local lang_en = require "data.lang.en"

local TextManager = Class:inherit()

function TextManager:init()
    self.values = self:unpack(lang_en)
end

--- Unpacks a table to be used as text keys. Example:
--- ```
--- Text:unpack({
---     val1 = "val1", 
---     subtab2 = {
---         val3 = "val3"
---     }
--- })
--- ```
--- becomes:
--- ```
--- {
---     ["val1"] = "val1",
---     ["subtab2.val3"] = "val3",
--- }
--- ```
---@param tab any
---@return table unpacked
function TextManager:unpack(tab)
    local output = {}
    local function explore(t, path)
        for k, v in pairs(t) do
            local newkey = path..k
            if type(v) == "table" then
                explore(v, newkey..".")
            else
                output[newkey] = v
            end
        end
    end 

    explore(tab, "")
    return output
end

function TextManager:value_exists(code)
    return self.values[code] ~= nil
end

function TextManager:text(code, ...)
    local v = self.values[code]
    assert(v ~= nil, "value for key '"..tostring(code).."' doesn't exist") 
    if v == nil then
        return nil
        -- print_debug("/!\\ TextManager:text - value for key '"..tostring(code).."' doesn't exist)")
    end
    if #({...}) > 0 then
        return string.format(v, ...)
    end
    return v
end

function TextManager:text_fallback(code, fallback, ...)
    if not self:value_exists(code) then
        return fallback or code
    end
    return self:text(code, ...)
end

return TextManager