require "scripts.util"
local Class = require "scripts.class"

local InputButton = Class:inherit()

function InputButton:init(input_type, key_name)
    self.type = input_type
    self.key_name = key_name
end

return InputButton