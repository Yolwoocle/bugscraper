require "scripts.util"
local Class = require "scripts.meta.class"

local InputProfile = Class:inherit()

function InputProfile:init(primary_input_type, mappings)
    self.primary_input_type = primary_input_type

    self.default_mappings = copy_table(mappings)
    self.mappings = copy_table(mappings)
end

function InputProfile:set_mappings(mappings)
    self.mappings = copy_table(mappings)
end

function InputProfile:get_default_mappings()
    return self.default_mappings
end

function InputProfile:get_mappings()
    return self.mappings
end

function InputProfile:get_buttons(action)
    return self.mappings[action] or {}
end

function InputProfile:set_action_buttons(action, buttons)
    self.mappings[action] = buttons
end

function InputProfile:get_primary_input_type()
    return self.primary_input_type
end

return InputProfile