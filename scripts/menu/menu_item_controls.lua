require "scripts.util"
local TextMenuItem = require "scripts.menu.menu_item_text"
local images = require "data.images"

local ControlsMenuItem = TextMenuItem:inherit()

function ControlsMenuItem:init(i, x, y, player_n, input_type, action_name)
	self:init_textitem(i, x, y, action_name)

	self.player_n = player_n
	self.input_type = input_type
	self.action_name = action_name
	
	self.key = nil
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

	local x = right_bound
	local y = self.y + self.oy
	for i, button in pairs(self.value) do
		if button.type == self.input_type then
			x = self:draw_button_icon(button, x, y)
		end
	end
end

local BUTTON_ICON_MARGIN = 1

function ControlsMenuItem:draw_button_icon(button, x, y)
	local img = Input:get_button_icon(button)

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
	end
	
	-- Apply new key control
	if self.is_waiting_for_input then
		self.is_waiting_for_input = false
		Input:set_standby_mode(false)
		
		if Input:is_button_in_use(self.player_n, self.action_name, {type="k", key_name=scancode}) then
			return
		end

		self.value = scancode

		self.key = key
		self.scancode = scancode
		Input:set_action_buttons(self.player_n, self.action_name, {type="k", key_name=scancode})
	end
end

return ControlsMenuItem