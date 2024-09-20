require "scripts.util"
local Class = require "scripts.meta.class"

local InputProfile = Class:inherit()

function InputProfile:init(profile_id, primary_input_type, mappings)
    self.profile_id = profile_id
    self.primary_input_type = primary_input_type

    self.default_mappings = copy_table(mappings)
    self.mappings = copy_table(mappings)
    -- self.metadata = {}
    -- for key, _ in pairs(self.default_mappings) do
    --     self.metadata[key] = {
    --         modified = false-- random_sample{true, false},
    --     }
    -- end
end

function InputProfile:set_mappings(mappings)
    self.mappings = copy_table(mappings)
end

function InputProfile:get_default_mappings()
    return self.default_mappings
end

function InputProfile:get_profile_id()
    return self.profile_id
end

function InputProfile:get_mappings()
    return self.mappings
end

function InputProfile:get_buttons(action)
    return self.mappings[action] or {}
end

function InputProfile:get_primary_button(action, input_type)
    if input_type == nil then
        return (self:get_buttons(action) or {})[1]
    else
        for _, button in ipairs(self:get_buttons(action)) do
            if button.type == input_type then
                return button
            end
        end 
        return nil
    end
end

function InputProfile:set_action_buttons(action, buttons)
    self.mappings[action] = buttons
end

function InputProfile:get_primary_input_type()
    return self.primary_input_type
end

-- function InputProfile:get_metadata(action)
--     return self.metadata[action]
-- end

return InputProfile