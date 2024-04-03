require "scripts.util"
local Class = require "scripts.meta.class"
local InputButton = require "scripts.input.input_button"
local InputActionState = require "scripts.input.input_action_state"
local gamepadguesser = require "lib.gamepadguesser"
gamepadguesser.loadMappings("lib/gamepadguesser")

local InputUser = Class:inherit()

function InputUser:init(n, input_profile_id, is_global)
    is_global = param(is_global, false)

    self.n = n
    self.is_global = is_global
    self.input_profile_id = input_profile_id or "empty"

    self.action_states = {}
    self:init_action_states()

    self.joystick = nil
    self.last_active_joystick = nil
    self.last_pressed_button = nil
    self.primary_input_type = self:get_input_profile():get_primary_input_type()
end

function InputUser:update(dt)
    for action, action_state in pairs(self.action_states) do
        action_state:update(dt)
	end
end

function InputUser:set_input_profile_id(profile_id)
    self.input_profile_id = profile_id
end

function InputUser:get_input_profile()
    return Input:get_input_profile(self.input_profile_id)
end

function InputUser:get_primary_button(action)
    local buttons = Input:get_buttons_from_player_n(self.n, action) or {}
    return buttons[1]
end

function InputUser:init_action_states()
    local hold_repeat_actions = {
        ui_left = true,
        ui_right = true,
        ui_up = true,
        ui_down = true
    }

    local profile = self:get_input_profile()
    assert(profile ~= nil, "cannot find input profile")

	self.action_states = {}
	for action, _ in pairs(profile:get_mappings()) do
        self.action_states[action] = InputActionState:new(self, action, hold_repeat_actions[action] ~= nil)
	end
end

function InputUser:update_last_input_state()
    for action, action_state in pairs(self.action_states) do
        action_state:update_last_input_state()
    end
end

function InputUser:action_down(action)
    local buttons = self:get_input_profile():get_mappings()[action]
	if not buttons then   error(concat("Attempt to access button '",concat(action),"'"))   end
    if self.action_states[action].is_handled then
        return false
    end

	for _, button in pairs(buttons) do
		if self:is_button_down(button) then
			return true
		end
	end
	return false
end

function InputUser:mark_action_as_handled(action)
    self.action_states[action]:mark_as_handled()
end

function InputUser:action_pressed(action)
    -- This makes sure that the button state table assigns "true" to buttons
	-- that have been just pressed  
    local action_state = self.action_states[action]
	local last = action_state.last_state
	local now = self:action_down(action)
    local result = not last and now
    
    if not result and action_state.can_action_hold_repeat then
        result = action_state:is_hold_repeat_pressed()
    end

    if result and is_in_table(UI_ACTIONS, action) then
        Input:set_last_ui_user_n(self.n)
    end
    return result
end

function InputUser:is_button_down(button)
    local v = false
    if button.type == INPUT_TYPE_KEYBOARD then
        v = Input:is_keyboard_down(button)

    elseif button.type == INPUT_TYPE_CONTROLLER then 
        if self.joystick then 
            v = self:is_joystick_down(button)
        elseif self.is_global then
            v = self:is_any_joystick_down(button)            
        end
    end
    
    if v then
        self.last_pressed_button = button
    end
    return v
end      

function InputUser:is_joystick_down(button, joystick)
    joystick = param(joystick, self.joystick)
    if joystick == nil then return false end
    local output = false

    local axis_func = AXIS_FUNCTIONS[button.key_name]
    if axis_func ~= nil then
        output = axis_func(joystick)
    else
        output = joystick:isGamepadDown(button.key_name)
    end

    if output then
        self.last_active_joystick = joystick
    end
    return output
end

function InputUser:is_any_joystick_down(button)
    local joysticks = love.joystick.getJoysticks()
    for i, joystick in ipairs(joysticks) do
        if joystick:isGamepad() and self:is_joystick_down(button, joystick) then
            return true
        end
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