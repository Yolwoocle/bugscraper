require "scripts.util"
local Class = require "scripts.class"
local InputUser = require "scripts.input_user"

local InputManager = Class:inherit()

function InputManager:init()
    self.users = {}
    self.joystick_to_user_map = {}

	self.standby_mode = false
	self.buffer_standby_mode = {active = false, value = false}

	self.control_presets = {
		[1] = self:process_input_map {
			left =  {"k_a", "k_left",     "c_dpleft",  "c_leftstickxneg", "c_rightstickxneg"},
			right = {"k_d", "k_right",    "c_dpright", "c_leftstickxpos", "c_rightstickxpos"},
			up =    {"k_w", "k_up",       "c_dpup",    "c_leftstickyneg", "c_rightstickyneg"},
			down =  {"k_s", "k_down",     "c_dpdown",  "c_leftstickypos", "c_rightstickypos"},
			jump =  {"k_z", "k_c", "k_b", "c_a", "c_b"},
			shoot = {"k_x", "k_v", "k_n", "c_x", "c_y", "c_righttrigger"},
			pause = {"k_escape", "k_p",   "c_start"},

			ui_select = {"k_return", "k_z", "k_c", "k_b", "k_x", "k_v", "k_n", "c_a"},
			ui_back =   {"k_escape",       "c_b"},
			ui_left =   {"k_a", "k_left",  "c_dpleft"},
			ui_right =  {"k_d", "k_right", "c_dpright"},
			ui_up =     {"k_w", "k_up",    "c_dpup"},
			ui_down =   {"k_s", "k_down",  "c_dpdown"},
		},
	}

	self.control_schemes = copy_table(self.control_presets)

    self:load_controls()
end

function InputManager:update(dt)
end

function InputManager:update_last_input_state(dt)
    for i, user in ipairs(self.users) do
        user:update_last_input_state()
    end

    if self.buffer_standby_mode.active then
        self.standby_mode = self.buffer_standby_mode.value
        self.buffer_standby_mode.active = false
    end
end

function InputManager:get_input_map(n)
    return self.control_schemes[n]
end

function InputManager:new_user()
    local n = #self.users + 1

    local default_input_map = self.control_schemes[n]
    local input_map = self.control_schemes[n]
    table.insert(self.users, InputUser:new(n, default_input_map, input_map))
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

function InputManager:action_down(n, action, bypass_standy)
    if self.standby_mode and not bypass_standy then
        return false
    end
    if action == nil then
        return self:action_down_any_player(n)
    end
    local user = self.users[n]
    if not user then return false end
    return user:action_down(action)
end

function InputManager:action_pressed(n, action, bypass_standy)
    if self.standby_mode and not bypass_standy then
        return false
    end
    if action == nil then
        return self:action_pressed_any_player(n)
    end
    local user = self.users[n]
    if not user then return false end
    return user:action_pressed(action)
end

function InputManager:action_down_any_player(action, bypass_standy)
    if self.standby_mode and not bypass_standy then
        return false
    end
    for i, user in ipairs(self.users) do
        if user:action_down(action) then return true end
    end
    return false
end

function InputManager:action_pressed_any_player(action, bypass_standy)
    if self.standby_mode and not bypass_standy then
        return false
    end
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
        print(concat("set_action_buttons: user number ",n," doesn't exist"))
        return
    end

    self.control_schemes[n][action] = buttons

	self:update_controls_file(n)
end

function InputManager:reset_controls(n)
	local user = self.users[n]
    assert(user ~= nil, concat("user ",n, " does not exist"))

    self.control_schemes = copy_table(self.control_presets[n])

	self:update_controls_file(n)
end

function InputManager:is_button_in_use(n, action, button)
	local input_map = self:get_input_map(n)
    assert(input_map ~= nil, concat("input map number ", n, " does not exist"))
    
    local assigned_buttons = input_map[action]
    assert(assigned_buttons ~= nil, concat("action ",action, " has no assigned buttons for user number ", n))
    for _, assigned_button in ipairs(assigned_buttons) do
        if assigned_button.type == button.type and assigned_button.key_name == button.key_name then
            return true
        end
    end
    return false
end

function InputManager:set_standby_mode(enabled)
    -- self.standby_mode = enabled
    self.buffer_standby_mode.value = enabled
    self.buffer_standby_mode.active = true
end

-----------------------------------------------------
------------------- Reading files -------------------
-----------------------------------------------------

function InputManager:keycode_to_button(keycode)
    if keycode ~= nil and #keycode > 2 then
        local prefix = keycode:sub(1, 1)
        local keyname = keycode:sub(3, -1)
        return {
            type = prefix,
            key_name = keyname
        }
    end
    return nil
end

function InputManager:process_input_map(raw_input_map)
    local new_map = {}
    for action, keys in pairs(raw_input_map) do
        new_map[action] = {}
        for _, keycode in pairs(keys) do
            local button = self:keycode_to_button(keycode)
            if button ~= nil then
                table.insert(new_map[action], button)
            end
        end
    end
    return new_map
end

function InputManager:load_controls()
	if love.filesystem.getInfo == nil then
		print("/!\\ WARNING: love.filesystem.getInfo doesn't exist. Either running on web or LÖVE version is incorrect. Loading controls for players aborted, so custom keybinds will not be loaded.")
		return
	end

    print("IM GONNA LOAD CONTROLS ")
	for n=1, #self.control_schemes do
		local filename = concat("controls_p",n,".txt")

		-- Check if file exists
		local file_exists = love.filesystem.getInfo(filename)
		if not file_exists then
			print(filename, "does not exist, so creating it")
			self:update_controls_file(n)
			break
		end

		local file = love.filesystem.newFile(filename)
		file:open("r")

        local new_controls = copy_table(self.control_presets)
        -- process_input_map

		-- Read file contents
		local text, size = file:read()
		if not text then    print(concat("Error reading ",filename,": ",size))    end
		local lines = split_str(text, "\n") -- Split lines
	
		for iline = 1, #lines do
			local line = lines[iline]
			local tab = split_str(line, ":")
			local action_name, keycodes = tab[1], tab[2]
            local keycode_table = split_str(keycodes, ",")

            new_controls[action_name] = {}
            for _, keycode in pairs(keycode_table) do
                print(concat("reading for p",n," action '",action_name,"'' keycode '",keycode,"'"))
                local button = self:keycode_to_button(keycode)
                if button ~= nil then
                    table.insert(new_controls[action_name], button)
                end
            end
		end

		file:close()
        
        self.control_schemes[n] = new_controls
	end
end

function InputManager:buttons_to_keycodes(buttons)
    local keycodes = {}
    for i, button in ipairs(buttons) do
        table.insert(keycodes, button.type .. "_" .. button.key_name)
    end
    return keycodes
end

function InputManager:update_all_controls_files()
	for n=1, #self.control_schemes do
        self:update_controls_file(n)
    end
end

function InputManager:update_controls_file(player_n)
    local filename = concat("controls_p",player_n,".txt")
    local controlsfile = love.filesystem.newFile(filename)
    print(concat("Creating or updating ", filename, " file"))
    controlsfile:open("w")
    
    for action_name, buttons in pairs(self.control_schemes[player_n]) do
        local keycodes = self:buttons_to_keycodes(buttons)
        local keycodes_string = concatsep(keycodes,",")
        print("keycodes_string ", table_to_str(keycodes_string))
        
        controlsfile:write(concat(action_name, ":", keycodes_string, "\n"))
    end
    print(concat(">>> Finished or updating ", filename, " file"))

    controlsfile:close()
end

function InputManager:on_quit()
    self:update_all_controls_files()
end

return InputManager