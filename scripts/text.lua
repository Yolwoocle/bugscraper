require "scripts.util"
local utf8 = require "utf8"
local Class = require "scripts.meta.class"

local TextManager = Class:inherit()

function TextManager:init()
    local start = love.timer.getTime()
    self.languages = {
        en = require "data.lang.en",
        zh = require "data.lang.zh",
        fr = require "data.lang.fr",
    }
    for lang_name, lang_values in pairs(self.languages) do
        self.languages[lang_name] = self:unpack(lang_values)
    end

    self.default_lang = "en"
    if DEBUG_MODE then
        self:sanity_check_languages(self.default_lang)
    end

    self.user_locale = os.setlocale(nil, "all")
    print_debug("User locale = '"..self.user_locale.."'")

    self.language = Options:get("language")
    self.values = self:unpack(self.languages[self.language or self.default_lang])

    local words = 0
    for _, v in pairs(self.values) do
        local s = split_str(v, " ")
        -- print_table(s)
        words = words + #s
    end
    print("TextManager: Unpacked "..tostring(words).." words in "..(1000* (love.timer.getTime() - start)).."ms.")
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
    local s = ""
    local output = {}
    local function explore(t, path)
        for k, v in pairs(t) do
            local newkey = path..k
            if type(v) == "table" then
                explore(v, newkey..".")
            else
                output[newkey] = v
                s = s..v.."\n"
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
    local key_code
    local params = {}
    if type(code) == "table" then
        key_code = code[1]
        params = code
    elseif type(code) == "string" then
        key_code = code
    else 
        error("Invalid type for 'code': "..tostring(type(code)))
        return
    end

    local raw_value = self.values[key_code]
    local output = raw_value
    if raw_value == nil then
        output = key_code

    elseif #({...}) > 0 then
        output = string.format(raw_value, ...)
    end

    if params.uppercase then
        output = string.upper(output)
    end
    if params.lowercase then
        output = string.lower(output)
    end
    return output

    -- assert(v ~= nil, "Text value for key '"..tostring(code).."' doesn't exist") 
    -- print_debug("/!\\ TextManager:text - value for key '"..tostring(code).."' doesn't exist)");
end

function TextManager:text_fallback(code, fallback, ...)
    if not self:value_exists(code) then
        return fallback or code
    end
    return self:text(code, ...)
end


function TextManager:parse_string(text)
    text = text:gsub("{lbrace}", "\1"):gsub("{rbrace}", "\2")
    
    text = text:gsub("{(.-)}", function(key)
        return self:text(key)
    end)

    text = text:gsub("\1", "{"):gsub("\2", "}")
    return text
end

function TextManager:sanity_check_languages(reference_language)
    -- Check for missing keys
    for ref_key, ref_value in pairs(self.languages[reference_language]) do
        for lang_name, lang_values in pairs(self.languages) do
            if lang_name ~= reference_language and not lang_values[ref_key] then
                print_debug("- [Text] /!\\ missing key '"..ref_key.."' for language '"..lang_name.."'")
            end
        end
    end
end

return TextManager