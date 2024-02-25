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

function InputManager:set_controls(button, value)
	if not value then
		local controls = button
		self.controls = controls
		return
	end

	if not self.controls[button] then
		print(concat("Tried to set btn '", button,"'"))
		return
	end
	if type(value) ~= "table" then
		print(concat("Val '",value,"' for set_controls is not a table"))
	end
	self.controls[button] = value
end

return InputManager