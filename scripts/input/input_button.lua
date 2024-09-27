require "scripts.util"
local Class = require "scripts.meta.class"

local InputButton = Class:inherit()

function InputButton:init(input_type, key_name)
    self.type = input_type
    self.key_name = key_name
end

function InputButton:get_keycode()
    return tostring(self.type).."_"..tostring(self.key_name)
end

return InputButton