local TextMenuItem = require "scripts.menu.menu_item_text"

local ControlsMenuItem = TextMenuItem:inherit()

function ControlsMenuItem:init(i, x, y, action_name, player_n)
	self:init_textitem(i, x, y, action_name)

	self.player_n = player_n
	self.action_name = action_name
	
	self.key = nil
	self.scancode = nil
	
	self.is_waiting_for_input = false
	self.is_selectable = true
end

function ControlsMenuItem:update(dt)
	self:update_textitem(dt)

	self.text = concat(self.action_name, ": [ERROR]")
	local user = Input:get_user(self.player_n)
	if user == nil then return end
	local buttons = user.input_map[self.action_name]
	if buttons == nil then return end

	local button_names = {}
	for i, button in ipairs(buttons) do
		table.insert(button_names, button.key_name)
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
	
	self.is_waiting_for_input = true
	-- self.is_selectable = false
end

function ControlsMenuItem:keypressed(key, scancode, isrepeat)
	if scancode == "escape" then
		self.is_waiting_for_input = false
		-- self.is_selectable = true
	end
	
	-- Apply new key control
	if self.is_waiting_for_input then
		self.is_waiting_for_input = false
		-- self.is_selectable = true
		
		local is_valid = Input:check_if_key_in_use(scancode)
		if not is_valid then return end

		self.value = scancode

		self.key = key
		self.scancode = scancode
		Input:set_button_bind(1, self.button_id, "k_"..scancode)
		-- self.value_text = key
	end
end

return ControlsMenuItem