require "scripts.util"
local Class = require "scripts.meta.class"

local InputActionState = Class:inherit()

function InputActionState:init(user, action, can_action_hold_repeat)
    self.user = user

    self.action = action
    self.last_state = false
    self.can_action_hold_repeat = can_action_hold_repeat

    self.is_handled = false -- whether the input should be ignored on consecutive reads

    self.held_time = 0.0
    self.hold_repeat_timer = 0.0
end

function InputActionState:update(dt)
    self:update_button_held_time(dt)
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
    self.last_state = Input:action_down(self.user.n, self.action, true)
    if self.hold_repeat_timer >= BUTTON_HOLD_REPEAT_INTERVAL then
        self.hold_repeat_timer = 0.0
    end
    self.is_handled = false
end

function InputActionState:mark_as_handled()
    self.is_handled = true
end

return InputActionState