require "scripts.util"
local Class = require "scripts.class"

local InputMap = Class:inherit()

function InputMap:init(mappings)
    self.mappings = copy_table(mappings)
end

function InputMap:set_mappings(mappings)
    self.mappings = copy_table(mappings)
end

function InputMap:get_mappings()
    return self.mappings
end

function InputMap:get_buttons(action)
    return self.mappings[action] or {}
end

function InputMap:set_action_buttons(action, buttons)
    self.mappings[action] = buttons
end

return InputMap