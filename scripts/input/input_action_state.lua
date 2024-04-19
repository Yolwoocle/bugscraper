require "scripts.util"
local Class = require "scripts.meta.class"

local InputActionState = Class:inherit()

STATE_OFF = 0
STATE_PRESSED = 1 -- this counts as ON too
STATE_ON = 2
STATE_RELEASED = 3 -- this counts as OFF too

function InputActionState:init(user, action, can_action_hold_repeat)
    self.user = user

    self.action = action
    self.state = STATE_OFF
    self.can_action_hold_repeat = can_action_hold_repeat

    self.is_handled = false -- whether the input should be ignored on consecutive reads

    self.held_time = 0.0
    self.hold_repeat_timer = 0.0
end

function InputActionState:update(dt)
    self:update_button_held_time(dt)
    self:update_state(dt)
end

function InputActionState:is_on(dt)
    return (self.state == STATE_PRESSED) or (self.state == STATE_ON)
end

function InputActionState:is_off(dt)
    return (self.state == STATE_RELEASED) or (self.state == STATE_OFF)
end

function InputActionState:update_state(dt)
    if self.user:action_down(self.action) then
        if self.state == STATE_OFF or self.state == STATE_RELEASED then
            self.state = STATE_PRESSED
        elseif self.state == STATE_PRESSED then
            self.state = STATE_ON
        end
    else
        if self.state == STATE_ON or self.state == STATE_PRESSED then
            self.state = STATE_RELEASED
        elseif self.state == STATE_RELEASED then
            self.state = STATE_OFF
        end
    end
end

function InputActionState:update_button_held_time(dt)
    if self.user:action_down(self.action) then
        self.held_time = self.held_time + dt
        if self.held_time >= BUTTON_HOLD_REPEAT_TIME then
            self.hold_repeat_timer = self.hold_repeat_timer + dt
        end
    else
        self.held_time = 0.0
        self.hold_repeat_timer = 0.0
    end
end

function InputActionState:is_hold_repeat_pressed()
    return self.hold_repeat_timer >= BUTTON_HOLD_REPEAT_INTERVAL
end

function InputActionState:update_last_input_state()
    if self.hold_repeat_timer >= BUTTON_HOLD_REPEAT_INTERVAL then
        self.hold_repeat_timer = 0.0
    end
    self.is_handled = false
end

function InputActionState:mark_as_handled()
    self.is_handled = true
end

return InputActionState