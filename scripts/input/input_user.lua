require "scripts.util"
local Class = require "scripts.meta.class"
local InputButton = require "scripts.input.input_button"
local gamepadguesser = require "lib.gamepadguesser"
gamepadguesser.loadMappings("lib/gamepadguesser")

local InputUser = Class:inherit()

function InputUser:init(n)
    self.n = n
    self:init_last_input_state()

    self.joystick = nil
    self.primary_input_type = ternary(n == 1, "k", "c")
end

function InputUser:get_input_map()
    return Input:get_input_map(self.n)
end

function InputUser:get_primary_button(action)
    local buttons = Input:get_buttons(self.n, action, self.primary_input_type) or {}
    return buttons[1]
end

function InputUser:init_last_input_state()
	self.last_input_state = {}
	for action, _ in pairs(self:get_input_map()) do
        self.last_input_state[action] = false
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

function InputUser:is_button_down(key)
    if key.type == INPUT_TYPE_KEYBOARD then
        return love.keyboard.isScancodeDown(key.key_name)

    elseif key.type == INPUT_TYPE_CONTROLLER and self.joystick then
        local axis_func = AXIS_FUNCTIONS[key.key_name]
        if axis_func ~= nil then
            return axis_func(self.joystick)
        end
        return self.joystick:isGamepadDown(key.key_name)
        
    end
    return false
end

function InputUser:is_axis_down(axis_name)
    if self.joystick == nil then
        return false
    end

    local axis_func = AXIS_FUNCTIONS[axis_name]
    if axis_func ~= nil then
        return axis_func(self.joystick)
    end
    return false
end

function InputUser:action_down(action)
    local buttons = self:get_input_map()[action]
	if not buttons then   error(concat("Attempt to access button '",concat(action),"'"))   end

	for _, button in pairs(buttons) do
		if self:is_button_down(button) then
            self:update_primary_input_type(button.type)
			return true
		end
	end
	return false
end

function InputUser:update_primary_input_type(input_type)
    self.primary_input_type = input_type
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