require "scripts.util"
local TextMenuItem = require "scripts.ui.menu.menu_item_text"
local InputButton = require "scripts.input.input_button"
local images = require "data.images"

local ControlsMenuItem = TextMenuItem:inherit()

function ControlsMenuItem:init(i, x, y, player_n, profile_id, input_type, action_name, label_text)
	self:init_textitem(i, x, y, action_name)

	self.player_n = player_n
	self.label_text = label_text or action_name
	self.profile_id = profile_id
	self.input_type = input_type
	self.action_name = action_name
	
	self.scancode = nil
	
	self.is_waiting_for_input = false
	self.waiting_timer = 0.0
	self.waiting_duration = 5.0
	self.is_selectable = true
end

function ControlsMenuItem:update(dt)
	self:update_textitem(dt)

	self.value_text = "[ERROR]"

	self.value = self:get_buttons()
	self.value_text = ""

	self.waiting_timer = max(0.0, self.waiting_timer - dt)
	if self.is_waiting_for_input and self.waiting_timer <= 0 then
		self:stop_waiting()
	end

	if self.is_selected and not self.is_waiting_for_input and Input:action_pressed("ui_reset_keys") then
		self:clear_buttons()
		return
	end
end

function ControlsMenuItem:draw_value_text()
	local right_bound = self.x + MENU_PADDING + self.ox
	local y = self.y + self.oy

	local draw_func = self:get_leftjustified_text_draw_function()
	if self.is_waiting_for_input then
		local text = "[PRESS BUTTON]"
		local w = get_text_width(text)
		draw_func(text, right_bound - w, y)

	elseif type(self.value) == "table" and #self.value == 0 then
		local text = "[NO BUTTONS]"
		local w = get_text_width(text)
		draw_func(text, right_bound - w, y)

	else
		local x = right_bound
		for i, button in pairs(self.value) do
			if button.type == self.input_type then
				x = self:draw_button_icon(button, x, y)
			end
		end
	end
end

local BUTTON_ICON_MARGIN = 1

function ControlsMenuItem:draw_button_icon(button, x, y)
	local img = Input:get_button_icon(self.player_n, button)

	if img ~= nil then
		local icon_draw_func = ternary(self.is_selected,
			function(_img, _x, _y) draw_with_outline(Input:get_last_ui_player_color(), "square", _img, _x, _y) end,
			function(_img, _x, _y) love.graphics.draw(_img, _x, _y) end
		)

		local width = img:getWidth()
		local height = img:getHeight()
		icon_draw_func(img, x - width, y - height/2)
		return x - width - BUTTON_ICON_MARGIN
	end
	return x
end

function ControlsMenuItem:get_profile()
	return Input:get_input_profile(self.profile_id)
end

function ControlsMenuItem:get_buttons()
	return self:get_profile():get_buttons(self.action_name, self.input_type)
end

function ControlsMenuItem:on_click()
	if self.is_waiting_for_input then return end
	if not self.is_selectable then return end

	-- Go in standby mode
	Options:update_options_file()
	Audio:play("menu_select")
	self.oy = -4
	
	Input:set_standby_mode(true)
	self.is_waiting_for_input = true
	self.waiting_timer = self.waiting_duration
end

function ControlsMenuItem:keypressed(key, scancode, isrepeat)
	if scancode == "escape" then
		self.is_waiting_for_input = false
		Input:set_standby_mode(false)
	end
	
	-- Apply new key control
	self:on_button_pressed(InputButton:new(INPUT_TYPE_KEYBOARD, scancode))
end

function ControlsMenuItem:gamepadpressed(joystick, buttoncode)
	-- if Input:get_user(self.player_n) and self.player_n ~= Input:get_joystick_user_n(joystick) then
	-- 	return
	-- end
	
	self:on_button_pressed(InputButton:new(INPUT_TYPE_CONTROLLER, buttoncode))
end

function ControlsMenuItem:gamepadaxis(joystick, axis, value)
	-- if Input:get_user(self.player_n) and self.player_n ~= Input:get_joystick_user_n(joystick) then
	-- 	return
	-- end

	local user_n = ternary(Input:get_user(self.player_n) == nil, Input:get_joystick_user_n(joystick), self.player_n)

	local key_name = Input:axis_to_key_name(axis, value)
	print_debug(axis)
	if Input:is_axis_down(user_n, key_name) then
		self:on_button_pressed(InputButton:new(INPUT_TYPE_CONTROLLER, key_name))
	end
end

function ControlsMenuItem:stop_waiting()
	self.is_waiting_for_input = false
	Input:set_standby_mode(false)
end

function ControlsMenuItem:on_button_pressed(button)
	if self.is_waiting_for_input then
		if not Input:is_allowed_button(button) then
			return
		end
		if self.input_type ~= button.type then
			return
		end

		self.oy = -4
		self:stop_waiting()
		
		if Input:is_button_in_use(self.profile_id, self.action_name, button) then
			return
		end
		if #self:get_buttons() >= MAX_ASSIGNABLE_BUTTONS then
			return
		end
		
		self.scancode = button.key_name
		Input:add_action_button(self.profile_id, self.action_name, button)
		Input:update_controls_file(self.profile_id)
		
		self.value = self:get_buttons()
	end
end

function ControlsMenuItem:clear_buttons()
	local old_buttons = self:get_buttons()
	local new_bindings = {}
	for _, button in pairs(old_buttons) do
		if button.type ~= self.input_type then
			table.insert(new_bindings, button)
		end
	end

	-- keep at least one button if clearing an UI action
	if is_in_table(UI_ACTIONS, self.action_name) then
		local button = nil
		local default_buttons = self:get_profile():get_default_mappings()[self.action_name] or {}
		for _, default_button in pairs(default_buttons) do
			if default_button.type == self.input_type then
				button = default_button
				break
			end
		end
		if button then   table.insert(new_bindings, button)   end
	end
	Input:set_action_buttons(self.profile_id, self.action_name, new_bindings)
end

return ControlsMenuItem