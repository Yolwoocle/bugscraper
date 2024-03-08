require "scripts.util"
local TextMenuItem = require "scripts.ui.menu.menu_item_text"
local InputButton = require "scripts.input.input_button"
local images = require "data.images"

local ControlsMenuItem = TextMenuItem:inherit()

function ControlsMenuItem:init(i, x, y, player_n, input_type, action_name)
	self:init_textitem(i, x, y, action_name)

	self.player_n = player_n
	self.input_type = input_type
	self.action_name = action_name
	
	self.scancode = nil
	
	self.is_waiting_for_input = false
	self.is_selectable = true
end

function ControlsMenuItem:update(dt)
	self:update_textitem(dt)

	self.label_text = concat(self.action_name)
	self.value_text = "[ERROR]"

	self.label_text = self.action_name
	self.value = self:get_buttons()
	self.value_text = ""
end

function ControlsMenuItem:draw_value_text()
	local right_bound = self.x + CANVAS_WIDTH*0.25 + self.ox
	local y = self.y + self.oy

	if self.is_waiting_for_input then
		local draw_func = self:get_leftjustified_text_draw_function()
		local text = "[PRESS KEY]"
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
		function(_img, _x, _y) draw_with_selected_outline(_img, _x, _y) end,
			function(_img, _x, _y) love.graphics.draw(_img, _x, _y) end
		)

		local width = img:getWidth()
		local height = img:getHeight()
		icon_draw_func(img, x - width, y - height/2)
		return x - width - BUTTON_ICON_MARGIN
	end
	return x
end

function ControlsMenuItem:get_buttons()
	local input_map = Input:get_input_map(self.player_n)
	if input_map == nil then return {} end
	local buttons = input_map[self.action_name]
	if buttons == nil then return {} end

	return buttons
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
end

function ControlsMenuItem:keypressed(key, scancode, isrepeat)
	if scancode == "escape" then
		self.is_waiting_for_input = false
		Input:set_standby_mode(false)
	elseif scancode == "tab" and not self.is_waiting_for_input then
		self:clear_buttons()
		return
	end
	
	-- Apply new key control
	self:on_button_pressed(InputButton:new("k", scancode))
end

function ControlsMenuItem:gamepadpressed(joystick, buttoncode)
	if self.player_n ~= Input:get_joystick_user_n(joystick) then
		return
	end

	self:on_button_pressed(InputButton:new("c", buttoncode))
end

function ControlsMenuItem:on_button_pressed(button)
	if self.is_waiting_for_input then
		self.is_waiting_for_input = false
		Input:set_standby_mode(false)

		if Input:is_button_in_use(self.player_n, self.action_name, button) then
			return
		end

		self.value = button.key_name

		self.scancode = button.key_name
		Input:add_action_buttons(self.player_n, self.action_name, {button})
	end
end

function ControlsMenuItem:clear_buttons()
	local old_buttons = Input:get_buttons(self.player_n, self.action_name)
	local new_bindings = {}
	for _, button in pairs(old_buttons) do
		if button.type ~= self.input_type then
			table.insert(new_bindings, button)
		end
	end

	-- keep at least one button if clearing an UI action
	if is_in_table({"ui_up", "ui_down", "ui_left", "ui_right", "ui_select", "ui_back"}, self.action_name) then
		local button = nil
		local default_buttons = Input.default_mappings[self.player_n][self.action_name] or {}
		for _, default_button in pairs(default_buttons) do
			if default_button.type == self.input_type then
				button = default_button
				break
			end
		end
		if button then   table.insert(new_bindings, button)   end
	end
	Input:set_action_buttons(self.player_n, self.action_name, new_bindings)
end

return ControlsMenuItem