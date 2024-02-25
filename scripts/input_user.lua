require "scripts.util"
local Class = require "scripts.class"

local InputUser = Class:inherit()

function InputUser:init(n, input_map)
    self.n = n
    self.input_map = input_map
    self:init_last_input_state()

    self.joystick = nil
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

function InputUser:is_keycode_down(keycode)
    if #keycode <= 2 then
        return false
    end
    local prefix = keycode:sub(1, 1)
    local keyname = keycode:sub(3, -1)
    if prefix == "k" then
        return love.keyboard.isScancodeDown(keyname)
    elseif prefix == "c" then
        if self.joystick then
            return self.joystick:isGamepadDown(keyname)
        end
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