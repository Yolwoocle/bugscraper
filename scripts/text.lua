require "scripts.util"
local utf8 = require "utf8"
local Class = require "scripts.meta.class"

local TextManager = Class:inherit()

function TextManager:init()
    local start = love.timer.getTime()
    self.languages = {
        en = require "data.lang.en",
        es = require "data.lang.es",
        fr = require "data.lang.fr",
        zh = require "data.lang.zh",
        pl = require "data.lang.pl",
        pt = require "data.lang.pt",
    }
    self.locale_to_language = {
        ["en"] = "en",
        ["en_US"] = "en", 
        ["en_GB"] = "en",

        ["fr"] = "fr",
        ["fr_FR"] = "fr",
        ["fr_CA"] = "fr",

        ["zh"] = "zh",
        ["zh_CN"] = "zh",
        ["zh_SG"] = "zh",

        ["pl"] = "pl",
        ["pl_PL"] = "pl",

        ["pt"] = "pt",
        ["pt_BR"] = "pt",
    }

    for lang_name, lang_values in pairs(self.languages) do
        self.languages[lang_name] = self:unpack(lang_values)
    end

    self.default_lang = "en"
    if DEBUG_MODE then
        self:sanity_check_languages(self.default_lang)
    end

    self.language = self:get_locale()
    self.values = self:unpack(self.languages[self.language or self.default_lang] or self.languages[self.default_lang])

    local words = 0
    for _, v in pairs(self.values) do
        local s = split_str(v, " ")
        -- print_table(s)
        words = words + #s
    end
    print("TextManager: Unpacked "..tostring(words).." words in "..(1000* (love.timer.getTime() - start)).."ms.")

    ------
    
    self.font_stack = {}
end

function TextManager:get_locale()
    local option = Options:get("language")

    if not option or option == "default" then
        local locales = love.system.getPreferredLocales() -- TODO if first language not supported, look for others
        print("User preferred locales :", table_to_str(locales))

        local lang = self.locale_to_language[locales[1] or "_____"]
        if lang then
            option = lang
        end
    end 

    return option
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
        output = utf8.upper(output)
    end
    if params.lowercase then
        output = utf8.lower(output)
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


function TextManager:parse(text)
    text = text:gsub("{lbrace}", "\1"):gsub("{rbrace}", "\2")
    
    text = text:gsub("{(.-)}", function(key)
        return self:text(key)
    end)

    text = text:gsub("\1", "{"):gsub("\2", "}")
    return text
end

function TextManager:sanity_check_languages(reference_language)
    -- Check for missing keys
    for lang_name, lang_values in pairs(self.languages) do
        for ref_key, ref_value in pairs(self.languages[reference_language]) do
            if lang_name ~= reference_language and not lang_values[ref_key] then
                print("- [Text] /!\\ missing key '"..ref_key.."' for language '"..lang_name.."'")
            end
        end
        print(" ")
    end

    -- TODO: check for "ghost keys" that don't have an equivalent in the reference language
end

function TextManager:push_font(font)
    if not font then
        return self:pop_font()
    end
	table.insert(self.font_stack, font)
	love.graphics.setFont(font)
end

function TextManager:pop_font()
	local font = table.remove(self.font_stack, #self.font_stack)
	love.graphics.setFont(self.font_stack[#self.font_stack] or FONT_REGULAR)
	return font
end

return TextManager