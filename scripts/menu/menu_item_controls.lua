local TextMenuItem = require "scripts.menu.menu_item_text"

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

	self.text = concat(self.action_name, ": [ERROR]")
	local input_map = Input:get_input_map(self.player_n)
	if input_map == nil then return end
	local buttons = input_map[self.action_name]
	if buttons == nil then return end

	local button_names = {}
	for i, button in ipairs(buttons) do
		if button.type == self.input_type then
			table.insert(button_names, button.key_name)
		end
	end
	local txt = string.upper(concatsep(button_names, " / "))

	self.text = concat(self.action_name, ": [", txt, "]")
	if self.is_waiting_for_input then
		self.text = concat(self.action_name, ": [PRESS A KEY]")
	end
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