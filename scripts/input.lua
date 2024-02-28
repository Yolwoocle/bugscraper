require "scripts.util"
local Class = require "scripts.class"
local InputManagerUser = require "scripts.input_user"

local InputManager = Class:inherit()

function InputManager:init()
    self.users = {}
    self.joystick_to_user_map = {}
end

function InputManager:update(dt)
    for i, user in ipairs(self.users) do
        user:update_input_state()
    end
end

function InputManager:new_user(input_map)
    table.insert(self.users, InputManagerUser:new(#self.users + 1, input_map))
end

function InputManager:joystickadded(joystick)
    for i = 1, #self.users do
		local input_user = Input.users[i]
		if input_user and (input_user.joystick == nil or not input_user.joystick:isConnected()) then
			input_user.joystick = joystick
            self.joystick_to_user_map[joystick] = input_user
			return
		end
	end
end

function InputManager:joystickremoved(joystick)
    local input_user = self.joystick_to_user_map[joystick]
    if input_user == nil then
        return
    end

    input_user.joystick = joystick
end

function InputManager:action_down(n, action)
    if action == nil then
        return self:action_down_any_player(n)
    end
    local user = self.users[n]
    if not user then return false end
    return user:action_down(action)
end

function InputManager:action_pressed(n, action)
    if action == nil then
        return self:action_pressed_any_player(n)
    end
    local user = self.users[n]
    if not user then return false end
    return user:action_pressed(action)
end

function InputManager:action_down_any_player(action)
    for i, user in ipairs(self.users) do
        if user:action_down(action) then return true end
    end
    return false
end

function InputManager:action_pressed_any_player(action)
    for i, user in ipairs(self.users) do
        if user:action_pressed(action) then return true end
    end
    return false
end

function InputManager:get_user(n)
    return self.users[n]
end

function InputManager:set_action_buttons(n, action, buttons)
	if type(buttons) ~= table then
		buttons = {buttons}
	end

    local user = self.users[n]
    if user == nil then
        print("set_action_buttons: player",n,"doesn't exist")
        return
    end

    user:set_action_buttons(action, buttons)

	Options:update_controls_file()
end

function InputManager:is_button_in_use(n, action, button)
	local user = self.users[n]
    assert(user ~= nil, concat("user ",n, " does not exist"))
    
    local assigned_buttons = user.input_map[action]
    assert(user ~= nil, concat("action ",action, " has no assigned buttons"))
    for _, assigned_button in ipairs(assigned_buttons) do
        if assigned_button.type == button.type and assigned_button.key_name == button.key_name then
            return true
        end
    end
    return false
end

return InputManager