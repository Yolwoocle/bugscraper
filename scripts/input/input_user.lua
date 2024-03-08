require "scripts.util"
local Class = require "scripts.meta.class"
local InputButton = require "scripts.input.input_button"
local gamepadguesser = require "lib.gamepadguesser"
gamepadguesser.loadMappings("lib/gamepadguesser")

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

function InputUser:init(n)
    self.n = n
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

	for _, key in pairs(keys) do
		if self:is_keycode_down(key) then
			return true
		end
	end
	return false
end

function InputUser:get_button_style()
    local style = Options:get("button_style_p"..self.n)
    if style == BUTTON_STYLE_DETECT then
        local console_name = "generic"
        if self.joystick then
            console_name = gamepadguesser.joystickToConsole(self.joystick)
        end

        if console_name == "playstation" then
            return BUTTON_STYLE_PLAYSTATION5
        elseif console_name == "nintendo" then
            return BUTTON_STYLE_SWITCH
        elseif console_name == "xbox" then
            return BUTTON_STYLE_XBOX
        else 
            return BUTTON_STYLE_XBOX
        end
    end
    return style
end

function InputUser:set_button_style(style)
    Options:set_button_style(self.n, style)
end

return InputUser