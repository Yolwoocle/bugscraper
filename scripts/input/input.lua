require "scripts.util"
local Class = require "scripts.meta.class"
local InputUser = require "scripts.input.input_user"
local InputMap = require "scripts.input.input_map"
local images = require "data.images"
local key_constant_to_image_name = require "data.buttons.images_buttons_keyboard"
local controller_buttons = require "data.buttons.controller_buttons"

local InputManager = Class:inherit()

function InputManager:init()
    self.users = {}
    self.joystick_to_user_map = {}

	self.standby_mode = false
	self.buffer_standby_mode = {active = false, value = false}

	self.default_mappings = {
		-- [1] = self:process_input_map({
		-- 	left =  {"k_left", "k_a",     "c_leftstickxneg", "c_rightstickxneg", "c_dpleft"},
		-- 	right = {"k_right", "k_d",    "c_leftstickxpos", "c_rightstickxpos", "c_dpright"},
		-- 	up =    {"k_up", "k_w",       "c_leftstickyneg", "c_rightstickyneg", "c_dpup"},
		-- 	down =  {"k_down", "k_s",     "c_leftstickypos", "c_rightstickypos", "c_dpdown"},
		-- 	jump =  {"k_c", "k_b",        "c_a", "c_b"},
		-- 	shoot = {"k_x", "k_v",        "c_x", "c_y", "c_righttrigger"},
		-- 	pause = {"k_escape", "k_p",   "c_start"},
            
		-- 	ui_select = {"k_c", "k_b", "k_return",          "c_a"},
		-- 	ui_back =   {"k_x", "k_escape", "k_backspace",  "c_b"},
		-- 	ui_left =   {"k_left", "k_a",                   "c_leftstickxneg", "c_rightstickxneg", "c_dpleft"},
		-- 	ui_right =  {"k_right", "k_d",                  "c_leftstickxpos", "c_rightstickxpos", "c_dpright"},
		-- 	ui_up =     {"k_up", "k_w",                     "c_leftstickyneg", "c_rightstickyneg", "c_dpup"},
		-- 	ui_down =   {"k_down", "k_s",                   "c_leftstickypos", "c_rightstickypos", "c_dpdown"},
		-- 	ui_reset_keys = {"k_tab", "c_lefttrigger"},
		-- }),
        [1] = self:process_input_map({
			left =  {"c_leftstickxneg", "c_rightstickxneg", "c_dpleft"},
			right = {"c_leftstickxpos", "c_rightstickxpos", "c_dpright"},
			up =    {"c_leftstickyneg", "c_rightstickyneg", "c_dpup"},
			down =  {"c_leftstickypos", "c_rightstickypos", "c_dpdown"},
			jump =  {"c_a", "c_b",                   "k_h"},
			shoot = {"c_x", "c_y", "c_righttrigger"},
			pause = {"c_start"},
            
			ui_select = {"c_a"},
			ui_back =   {"c_b"},
			ui_left =   {"c_leftstickxneg", "c_rightstickxneg", "c_dpleft"},
			ui_right =  {"c_leftstickxpos", "c_rightstickxpos", "c_dpright"},
			ui_up =     {"c_leftstickyneg", "c_rightstickyneg", "c_dpup"},
			ui_down =   {"c_leftstickypos", "c_rightstickypos", "c_dpdown"},
			ui_reset_keys = {"c_lefttrigger"},
			debug_1 = {"k_1"},
			debug_2 = {"k_2"},
			debug_3 = {"k_3"},
			debug_4 = {"k_4"},
		}),
		[2] = self:process_input_map({
			left =  {"k_left", "k_a"},
			right = {"k_right", "k_d"},
			up =    {"k_up", "k_w"},
			down =  {"k_down", "k_s"},
			jump =  {"k_c", "k_b",                 "k_j"},
			shoot = {"k_x", "k_v"},
			pause = {"k_escape", "k_p"},
            
			ui_select = {"k_c", "k_b", "k_return"},
			ui_back =   {"k_x", "k_escape", "k_backspace"},
			ui_left =   {"k_left", "k_a"},
			ui_right =  {"k_right", "k_d"},
			ui_up =     {"k_up", "k_w"},
			ui_down =   {"k_down", "k_s"},
			ui_reset_keys = {"k_tab"},
			debug_1 = {"k_1"},
			debug_2 = {"k_2"},
			debug_3 = {"k_3"},
			debug_4 = {"k_4"},
		}),
        
		[3] = self:process_input_map({
			left =  {"k_left", "k_a"},
			right = {"k_right", "k_d"},
			up =    {"k_up", "k_w"},
			down =  {"k_down", "k_s"},
			jump =  {"k_c", "k_b",                   "k_k"},
			shoot = {"k_x", "k_v"},
			pause = {"k_escape", "k_p"},
            
			ui_select = {"k_c", "k_b", "k_return"},
			ui_back =   {"k_x", "k_escape", "k_backspace"},
			ui_left =   {"k_left", "k_a"},
			ui_right =  {"k_right", "k_d"},
			ui_up =     {"k_up", "k_w"},
			ui_down =   {"k_down", "k_s"},
			ui_reset_keys = {"k_tab"},
			debug_1 = {"k_1"},
			debug_2 = {"k_2"},
			debug_3 = {"k_3"},
			debug_4 = {"k_4"},
		}),
        
		[4] = self:process_input_map({
			left =  {"k_left", "k_a"},
			right = {"k_right", "k_d"},
			up =    {"k_up", "k_w"},
			down =  {"k_down", "k_s"},
			jump =  {"k_c", "k_b",                    "k_l"},
			shoot = {"k_x", "k_v"},
			pause = {"k_escape", "k_p"},
            
			ui_select = {"k_c", "k_b", "k_return"},
			ui_back =   {"k_x", "k_escape", "k_backspace"},
			ui_left =   {"k_left", "k_a"},
			ui_right =  {"k_right", "k_d"},
			ui_up =     {"k_up", "k_w"},
			ui_down =   {"k_down", "k_s"},
			ui_reset_keys = {"k_tab"},
			debug_1 = {"k_1"},
			debug_2 = {"k_2"},
			debug_3 = {"k_3"},
			debug_4 = {"k_4"},
		}),
	}

	self.input_maps = {
        [1] = InputMap:new(self.default_mappings[1]),
        [2] = InputMap:new(self.default_mappings[2]),
        [3] = InputMap:new(self.default_mappings[3]),
        [4] = InputMap:new(self.default_mappings[4]),
    }

    self:load_controls()
end

function InputManager:init_users()
end

function InputManager:update(dt)
    for i, user in pairs(self.users) do
        user:update(dt)
    end
end

function InputManager:update_last_input_state(dt)
    for i, user in pairs(self.users) do
        user:update_last_input_state()
    end

    if self.buffer_standby_mode.active then
        self.standby_mode = self.buffer_standby_mode.value
        self.buffer_standby_mode.active = false
    end
end

function InputManager:get_input_map(n)
    local map = self.input_maps[n]
    if map == nil then return {} end
    return self.input_maps[n]:get_mappings() or {}
end

function InputManager:new_user(n)
    self.users[n] = InputUser:new(n)
end

function InputManager:remove_user(n)
    local user = self.users[n]
    if user == nil then
        return false
    end

    if user.joystick then
        self.joystick_to_user_map[user.joystick] = nil
    end
    self.users[n] = nil
end

function InputManager:joystickadded(joystick)
    for i = 1, MAX_NUMBER_OF_PLAYERS do
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
    self.joystick_to_user_map[joystick] = nil
end

function InputManager:gamepadaxis(joystick, axis, value)
end

function InputManager:axis_to_key_name(axis, value)
    local code = tostring(axis)..ternary(value > 0, "+", "-")
    local name = AXIS_TO_KEY_NAME_MAP[code]
    return name
end

function InputManager:is_axis_down_from_number(player_n, axis, value)
    local key_name = self:axis_to_key_name(axis, value)
    return self:is_axis_down(player_n, key_name)
end

function InputManager:is_axis_down(player_n, axis_name) 
    local user = self:get_user(player_n)
    assert(user ~= nil, "user "..tostring(player_n).." doesn't exist")

    return user:is_axis_down(axis_name)
end

function InputManager:get_joystick_user(joystick)
    return self.joystick_to_user_map[joystick]
end

function InputManager:get_joystick_user_n(joystick)
    local user = self.joystick_to_user_map[joystick]
    if user == nil then return -1 end

    return user.n
end

function InputManager:gamepadpressed(joystick, buttoncode)
end

function InputManager:gamepadreleased(joystick, buttoncode)
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
    for i, user in pairs(self.users) do
        if user:action_down(action) then return true end
    end
    return false
end

function InputManager:action_pressed_any_player(action, bypass_standy)
    if self.standby_mode and not bypass_standy then
        return false
    end
    for i, user in pairs(self.users) do
        if user:action_pressed(action) then return true end
    end
    return false
end

function InputManager:get_user(n)
    return self.users[n]
end

function InputManager:get_primary_button(n, action)
    local user = self:get_user(n)
    if user == nil then
        return nil
    end
    return user:get_primary_button(action)
end

function InputManager:get_buttons(n, action, input_type)
    if self.input_maps[n] == nil then   return {}   end
    local buttons = self.input_maps[n]:get_buttons(action) or {}
    
    local output = {}
    if input_type ~= nil then
        for _, b in pairs(buttons) do
            if b.type == input_type then
                table.insert(output, b)
            end
        end
        return output
    end
    return buttons
end

function InputManager:set_action_buttons(n, action, buttons)
    local map = self.input_maps[n]
    if map == nil then
        print(concat("set_action_buttons: input map number ",n," doesn't exist"))
        return
    end

    map:set_action_buttons(action, buttons)

	self:update_controls_file(n)
end

function InputManager:add_action_buttons(n, action, buttons)
    local map = self.input_maps[n]
    if map == nil then
        print(concat("set_action_buttons: input map number ",n," doesn't exist"))
        return
    end

    local current_buttons = map:get_buttons(action)
    for _, new_button in pairs(buttons) do
        table.insert(current_buttons, new_button)
    end

	self:update_controls_file(n)
end

function InputManager:reset_controls(n, input_mode)
	local user = self.users[n]
    assert(user ~= nil, concat("user ",n, " does not exist"))

    local new_mapping = {}
    for action, default_buttons in pairs(self.default_mappings[n]) do
        local current_buttons = self.input_maps[n]:get_buttons(action)

        local new_buttons = {}
        for _, button in pairs(default_buttons) do
            if button.type == input_mode then
                table.insert(new_buttons, button)
            end
        end

        for _, button in pairs(current_buttons) do
            if button.type ~= input_mode then
                table.insert(new_buttons, button)
            end
        end
        new_mapping[action] = new_buttons
    end

    self.input_maps[n] = InputMap:new(new_mapping)

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

function InputManager:generate_unknown_key_icon(icon, text)
    local old_canvas = love.graphics.getCanvas()

    local text_w = get_text_width(text.."[]")
    local open_bracket_w = get_text_width("[")
    local new_canvas = love.graphics.newCanvas(icon:getWidth() + text_w + 3, icon:getHeight() + 2)
    love.graphics.setCanvas(new_canvas)

    love.graphics.print("[", 1, 1)
    love.graphics.draw(icon, open_bracket_w + 1, 1)
    love.graphics.print(text.."]", open_bracket_w + icon:getWidth() + 1, 1)

    love.graphics.setCanvas(old_canvas)
    return new_canvas
end

function InputManager:get_action_primary_icon(player_n, action)
    local button = Input:get_primary_button(player_n, action)
    local icon = Input:get_button_icon(player_n, button)
    return icon
end

function InputManager:get_button_icon(player_n, button)
    button = button or {}

    local img = nil
    if button.type == "k" then
		local key_constant = love.keyboard.getKeyFromScancode(button.key_name)
        local image_name = key_constant_to_image_name[key_constant]
		if image_name ~= nil then
            img = images[image_name]
        end

        if img == nil or img == images.btn_k_unknown then
            return self:generate_unknown_key_icon(images.btn_k_unknown, button.key_name)
        end

    elseif button.type == "c" then
        local user = self:get_user(player_n)
        if user ~= nil then
            local brand = user:get_button_style()
            local image_name = string.format("btn_c_%s_%s", brand, button.key_name)
            img = images[image_name]
        end

        if img == nil then
            return self:generate_unknown_key_icon(images.btn_c_unknown, button.key_name)
        end

	end
    return img or self:generate_unknown_key_icon(images.btn_k_unknown, "?")
end

-----------------------------------------------------
------------------| Reading files |------------------
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

	for n=1, #self.input_maps do
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

        local new_input_map = copy_table(self.default_mappings[n])

		-- Read file contents
		local text, size = file:read()
		if not text then    print(concat("Error reading ",filename,": ",size))    end
		local lines = split_str(text, "\n") -- Split lines
	
		for iline = 1, #lines do
			local line = lines[iline]
			local tab = split_str(line, ":")
			local action_name, keycodes = tab[1], tab[2]
            local keycode_table = split_str(keycodes, " ")

            local new_buttons = {}
            for _, keycode in pairs(keycode_table) do
                local button = self:keycode_to_button(keycode)
                if button ~= nil then
                    table.insert(new_buttons, button)
                end
            end
            new_input_map[action_name] = new_buttons
		end

		file:close()

        self.input_maps[n] = InputMap:new(new_input_map)
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
	for n=1, #self.input_maps do
        self:update_controls_file(n)
    end
end

function InputManager:update_controls_file(player_n)
    local filename = concat("controls_p",player_n,".txt")
    local controlsfile = love.filesystem.newFile(filename)
    print(concat("Creating or updating ", filename, " file"))
    controlsfile:open("w")

    for action_name, buttons in pairs(self.input_maps[player_n]:get_mappings()) do
        local keycodes = self:buttons_to_keycodes(buttons)
        local keycodes_string = concatsep(keycodes," ")

        controlsfile:write(concat(action_name, ":", keycodes_string, "\n"))
    end

    controlsfile:close()
end

function InputManager:on_quit()
    self:update_all_controls_files()
end

return InputManager