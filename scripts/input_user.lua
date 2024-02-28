require "scripts.util"
local Class = require "scripts.class"

local InputUser = Class:inherit()

local AXIS_DEADZONE = 0.2

local axis_functions = {
    leftstickxpos = function(joystick) return joystick:getAxis(1) > AXIS_DEADZONE end,
    leftstickxneg = function(joystick) return joystick:getAxis(1) < -AXIS_DEADZONE end,
    leftstickypos = function(joystick) return joystick:getAxis(2) > AXIS_DEADZONE end,
    leftstickyneg = function(joystick) return joystick:getAxis(2) < -AXIS_DEADZONE end,

    rightstickxpos = function(joystick) return joystick:getAxis(3) > AXIS_DEADZONE end,
    rightstickxneg = function(joystick) return joystick:getAxis(3) < -AXIS_DEADZONE end,
    rightstickypos = function(joystick) return joystick:getAxis(4) > AXIS_DEADZONE end,
    rightstickyneg = function(joystick) return joystick:getAxis(4) < -AXIS_DEADZONE end,

    lefttrigger  = function(joystick) return joystick:getAxis(5) > -1 + AXIS_DEADZONE end,
    righttrigger = function(joystick) return joystick:getAxis(6) > -1 + AXIS_DEADZONE end,
}

function InputUser:init(n, input_map)
    self.n = n
    self.input_map = self:process_input_map(input_map)
    print_table(self.input_map)
    self:init_last_input_state()

    self.joystick = nil
end

function InputUser:process_input_map(raw_input_map)
    local new_map = {}
    for action, keys in pairs(raw_input_map) do
        new_map[action] = {}
        for _, keycode in pairs(keys) do
            local button = self:keycode_to_button(keycode)
            if button ~= nil then
                table.insert(new_map[action], button)
            end
        end
    end
    return new_map
end

function InputUser:keycode_to_button(keycode)
    if keycode ~= nil and #keycode > 2 then
        local prefix = keycode:sub(1, 1)
        local keyname = keycode:sub(3, -1)
        return {
            type = prefix,
            key_name = keyname
        }
    end
    return nil
end

function InputUser:set_action_buttons(action, buttons)
    self.input_map[action] = buttons
end

function InputUser:init_last_input_state()
	self.last_input_state = {}
	for action, _ in pairs(self.input_map) do
		if action ~= "type" then
			self.last_input_state[action] = false
            
		end
	end
end

function InputUser:update_input_state()
	for action, v in pairs(self.input_map) do
		if type(v) == "table" then
			self.last_input_state[action] = Input:action_down(action)
		else
			if action ~= "type" then
				print(concat("update_button_state not a table:", action, ", ", table_to_str(v)))
			end
		end
	end
end

function InputUser:action_pressed(action)
    -- This makes sure that the button state table assigns "true" to buttons
	-- that have been just pressed 
	local last = self.last_input_state[action]
	local now = self:action_down(action)
	return not last and now
end

function InputUser:is_keycode_down(key)
    if key.type == "k" then
        return love.keyboard.isScancodeDown(key.key_name)

    elseif key.type == "c" and self.joystick then
        local axis_func = axis_functions[key.key_name]
        if axis_func ~= nil then
            return axis_func(self.joystick)
        end
        return self.joystick:isGamepadDown(key.key_name)
        
    end
    return false
end

function InputUser:action_down(action)
    local keys = self.input_map[action]
	if not keys then   error(concat("Attempt to access button '",concat(action),"'"))   end

	for k, key in pairs(keys) do
		if self:is_keycode_down(key) then
			return true
		end
	end
	return false
end


return InputUser