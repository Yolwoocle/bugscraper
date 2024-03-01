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

function InputUser:init(n, default_input_map, input_map)
    self.n = n
    -- self.default_input_map = self:process_input_map(default_input_map)
    -- self.input_map = self:process_input_map(input_map)
    self:init_last_input_state()

    self.joystick = nil
end

function InputUser:get_input_map()
    return Input:get_input_map(self.n)
end

function InputUser:init_last_input_state()
	self.last_input_state = {}
	for action, _ in pairs(self:get_input_map()) do
		if action ~= "type" then
			self.last_input_state[action] = false
		end
	end
end

function InputUser:update_last_input_state()
	for action, v in pairs(self:get_input_map()) do
		if type(v) == "table" then
			self.last_input_state[action] = Input:action_down(self.n, action, true)
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
    local keys = self:get_input_map()[action]
	if not keys then   error(concat("Attempt to access button '",concat(action),"'"))   end

	for k, key in pairs(keys) do
		if self:is_keycode_down(key) then
			return true
		end
	end
	return false
end

return InputUser