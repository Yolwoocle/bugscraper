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

    self.vibration_timer = 0.0
    self.vibration_strength_left  = 0.0
    self.vibration_strength_right = 0.0

    -- Game specifics
    self.skin = nil
end

function InputUser:update(dt)
    for action, action_state in pairs(self.action_states) do
        action_state:update(dt)
	end
    self:update_vibration(dt)
end

function InputUser:get_primary_input_type()
    return self.primary_input_type
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

function InputUser:mark_all_actions_as_handled()
    for action, action_state in pairs(self.action_states) do
        action_state:mark_as_handled()
    end
end

function InputUser:update_last_input_state()
    for action, action_state in pairs(self.action_states) do
        action_state:update_last_input_state()
    end
end

function InputUser:mark_action_as_handled(action)
    self.action_states[action]:mark_as_handled()
end

function InputUser:action_pressed(action)
    -- This makes sure that the button state table assigns "true" to buttons
	-- that have been just pressed  
    local action_state = self.action_states[action]
    local result = action_state.state == STATE_PRESSED
    if self.action_states[action].is_handled then
        return false
    end
    
    if not result and action_state.can_action_hold_repeat then
        result = action_state:is_hold_repeat_pressed()
    end

    if result and is_in_table(UI_ACTIONS, action) and self.n ~= GLOBAL_INPUT_USER_PLAYER_N then
        Input:set_last_ui_user_n(self.n)
    end
    return result
end

function InputUser:action_down(action)
    local buttons = self:get_input_profile():get_mappings()[action]
	if not buttons then   error(concat("Attempt to access button '",concat(action),"'"))   end
    if self.action_states[action].is_handled then
        return false
    end

	for _, button in pairs(buttons) do
        local is_ui_action = is_in_table(UI_ACTIONS, action)
		if self:is_button_down(button, is_ui_action) then
			return true
		end
	end
	return false
end

function InputUser:is_button_down(button, is_ui_action)
    is_ui_action = param(is_ui_action, false)

    local is_down = false
    if button.type == INPUT_TYPE_KEYBOARD then
        is_down = Input:is_keyboard_down(button)

    elseif button.type == INPUT_TYPE_CONTROLLER then 
        if self.joystick then 
            is_down = self:is_joystick_down(button, self.joystick, is_ui_action)
        elseif self.is_global then
            is_down = self:is_any_joystick_down(button, is_ui_action)
        end
    end
    
    if is_down then
        self.last_pressed_button = button
    end
    return is_down
end      

function InputUser:is_joystick_down(button, joystick, is_ui_action)
    joystick = param(joystick, self.joystick)
    is_ui_action = param(is_ui_action, false)
    if joystick == nil then return false end
    if not joystick:isConnected() then return false end
    local output = false

    if Input:is_axis(button.key_name) then
        return self:is_axis_down(button.key_name, joystick, is_ui_action)
    else
        if CONTROLLER_BUTTONS[button.key_name] then
            output = joystick:isGamepadDown(button.key_name)
        end
    end

    if output then
        self.last_active_joystick = joystick
    end
    return output
end

-- FIXME: what the fuck is this disgusting hack doing in InputUser
function InputUser:is_any_joystick_down(button, is_ui_action)
    is_ui_action = param(is_ui_action, false)

    local joysticks = love.joystick.getJoysticks()
    for i, joystick in ipairs(joysticks) do
        if joystick:isGamepad() and self:is_joystick_down(button, joystick, is_ui_action) then
            return true
        end
    end
    return false
end

local axis_functions = {
    leftxpos =  function(joystick, margin, deadzone) return Input:is_axis_in_angle_range(joystick, "leftx", "lefty", deadzone, 0,     margin) end,
    leftxneg =  function(joystick, margin, deadzone) return Input:is_axis_in_angle_range(joystick, "leftx", "lefty", deadzone, pi,    margin) end,
    leftypos =  function(joystick, margin, deadzone) return Input:is_axis_in_angle_range(joystick, "leftx", "lefty", deadzone, pi/2,  margin) end,
    leftyneg =  function(joystick, margin, deadzone) return Input:is_axis_in_angle_range(joystick, "leftx", "lefty", deadzone, -pi/2, margin) end,

    rightxpos = function(joystick, margin, deadzone) return Input:is_axis_in_angle_range(joystick, "rightx", "righty", deadzone, 0,     margin) end,
    rightxneg = function(joystick, margin, deadzone) return Input:is_axis_in_angle_range(joystick, "rightx", "righty", deadzone, pi,    margin) end,
    rightypos = function(joystick, margin, deadzone) return Input:is_axis_in_angle_range(joystick, "rightx", "righty", deadzone, pi/2,  margin) end,
    rightyneg = function(joystick, margin, deadzone) return Input:is_axis_in_angle_range(joystick, "rightx", "righty", deadzone, -pi/2, margin) end,

    triggerleft =    function(joystick, margin, deadzone) return joystick:getGamepadAxis("triggerleft")  > TRIGGER_DEADZONE end,
    triggerright =   function(joystick, margin, deadzone) return joystick:getGamepadAxis("triggerright") > TRIGGER_DEADZONE end,
}

function InputUser:is_axis_down(axis_name, joystick, is_ui_axis)
    joystick = param(joystick, self.joystick)
    if self.joystick == nil then
        return false
    end

    if Input:is_axis(axis_name) then
        local axis_func = axis_functions[axis_name]
        local deadzone = Options:get("axis_deadzone_p"..tostring(self.n)) or AXIS_DEADZONE
        if is_in_table({
            "controls_keyboard_solo",
            "controls_keyboard_split_p1",
            "controls_keyboard_split_p2",
            "controls_controller_p1",
            "controls_controller_p2",
            "controls_controller_p3",
            "controls_controller_p4",
            "controls_controller_p5",
            "controls_controller_p6",
            "controls_controller_p7",
            "controls_controller_p8",
        }, game.menu_manager.cur_menu_name) then
            -- Specific exception if in the joystick settings menu
            deadzone = AXIS_DEADZONE
        end
        return axis_func(
            joystick, 
            ternary(is_ui_axis, UI_AXIS_ANGLE_MARGIN, AXIS_ANGLE_MARGIN),
            deadzone
        )
    end
    return false
end

function InputUser:get_button_style()
    local style = Options:get("button_style_p"..self.n)
    if style == BUTTON_STYLE_DETECT then
        local console_name = "xbox"
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

function InputUser:vibrate(duration, strength_left, strength_right)
    strength_right = param(strength_right, strength_left)
    
    if not self.joystick then 
        return
    end
    self.vibration_timer = math.max(self.vibration_timer, duration)
    self.vibration_strength_left  = strength_left
    self.vibration_strength_right = strength_right
    self:update_vibration(0)
end

function InputUser:update_vibration(dt)
    if self.joystick then
        if self.vibration_timer <= 0 then
            self.vibration_strength_left, self.vibration_strength_right = 0, 0 
        end
        local m = Options:get("vibration_p"..tostring(self.n))
        self.joystick:setVibration(self.vibration_strength_left * m, self.vibration_strength_right * m)
    end
    
    self.vibration_timer = math.max(self.vibration_timer - dt, 0.0)
end

function InputUser:set_skin(skin)
    self.skin = skin
end

function InputUser:get_skin()
    return self.skin
end

return InputUser