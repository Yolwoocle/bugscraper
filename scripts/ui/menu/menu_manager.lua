require "scripts.util"
local Class = require "scripts.meta.class"
local generate_menus = require "data.menus"

local MenuManager = Class:inherit()

local MENU_SCROLL_DEADZONE = 32

function MenuManager:init(game)
	self.game = game
	
	self:reset()
end
function MenuManager:reset()
	self.menus = generate_menus()
	
	self.cur_menu = nil
	self.cur_menu_name = ""
	self.is_paused = false
	self.can_pause = true
	self.buffer_unpause = false

	self.sel_n = 1
	self.sel_item = nil

	self.menu_stack = {}
	self.last_menu = "title"

	self.joystick_wait_cooldown = 0.0
	self.joystick_wait_mode = false
	self.joystick_wait_set = {}
end

function MenuManager:update(dt)
	self:update_menu_unpausing()
	if self.cur_menu then
		self:update_current_menu(dt)
	end
	if self.joystick_wait_mode then
		self:update_joystick_wait_mode(dt)
	end

	local pause_button = Input:action_pressed("pause")
	local back_button = Input:action_pressed("ui_back")
	if pause_button then 
		if self.cur_menu == nil then
			self:pause()
		elseif self.is_paused then
			self:unpause()
		end
	elseif back_button then
		self:back()
	end

	self.joystick_wait_cooldown = math.max(self.joystick_wait_cooldown - dt, 0.0)
end

function MenuManager:get_menu(name)
	return self.menus[name]
end

function MenuManager:update_current_menu(dt)
	-- Navigate up and down
	if Input:action_pressed("ui_up") then
		self:incr_selection(-1)
	end
	if Input:action_pressed("ui_down") then
		self:incr_selection(1)
	end
	
	self.cur_menu:update(dt)

	-- Update current selection
	self.sel_n = mod_plus_1(self.sel_n, #self.cur_menu.items)
	self.sel_item = self.cur_menu.items[self.sel_n]
	self.sel_item.is_selected = true

	-- On pressed
	local btn = Input:action_pressed("ui_select")
	if btn and self.sel_item and self.sel_item.on_click then
		if not self.sel_item.is_waiting_for_input then
			self.sel_item:on_click()
			if self.sel_item then self.sel_item:after_click() end
		end
	end

	-- Scroll
	if self.cur_menu and self.sel_item and self.cur_menu.is_scrollable then
		if self.sel_item.y > CANVAS_HEIGHT/2 + MENU_SCROLL_DEADZONE then
			self.cur_menu:set_target_scroll_position(self.sel_item.def_y - (CANVAS_HEIGHT/2 + MENU_SCROLL_DEADZONE))
		elseif self.sel_item.y < CANVAS_HEIGHT/2 - MENU_SCROLL_DEADZONE then
			self.cur_menu:set_target_scroll_position(self.sel_item.def_y - (CANVAS_HEIGHT/2 - MENU_SCROLL_DEADZONE))
		end
	end
end

function MenuManager:draw()
	if self.cur_menu.bg_color then
		rect_color(self.cur_menu.bg_color, "fill", -1, -1, CANVAS_WIDTH+2, CANVAS_HEIGHT+2)
	end
	self.cur_menu:draw()
end

function MenuManager:set_menu(menu, is_back)
	self.last_menu = self.cur_menu

	-- nil menu
	if menu == nil then
		self.buffer_unpause = true
		return
	else
		if not is_back then
			table.insert(self.menu_stack, {
				menu = self.cur_menu,
				sel_n = self.sel_n,
			})
		end
	end

	local m = self.menus[menu]
	if type(menu) ~= "string" and menu.is_menu then
		m = menu
	end

	if not m then return false, "menu '" .. menu .. "' does not exist" end
	self.cur_menu = m
	self.cur_menu_name = menu

	-- Update selection to first selectable
	local sel, found = self:find_selectable_from(1, 1)
	self:set_selection(sel)
	self.cur_menu:update(0)

	-- Reset game screenshake
	-- if game and game.camera then
		-- game.camera:reset()
	-- end

	game:on_menu()
	return true
end

function MenuManager:update_menu_unpausing()
	if self.buffer_unpause then
		self.buffer_unpause = false
		self.cur_menu = nil
		self.menu_stack = {}
		game:on_unmenu()
	end
end

function MenuManager:set_can_pause(value)
    self.can_pause = value
end

function MenuManager:pause()
	-- Retry if game ended
	if self.is_paused then return end
	if not self.can_pause then return end

	if game.game_state == GAME_STATE_WIN then --scotch
		self:set_menu("win")
		self.game.music_player:set_disk("game_over")
		return
	end

	if self.cur_menu == nil then
		self.is_paused = true
		self:set_menu("pause")
		game:on_pause()
	end
end

function MenuManager:unpause()
	if not self.is_paused then return end

	self.is_paused = false
	self:set_menu()
	game:on_unmenu()
	game:on_unpause()
end

function MenuManager:incr_selection(n)
	if not self.cur_menu then return false, "no current menu" end

	-- Increment selection until valid item
	local sel, found = self:find_selectable_from(self.sel_n, n)

	if not found then
		self.sel_n = self.sel_n + n
		return false, concat("no selectable item found; selection set to n + (", n, ") (", self.sel_n, ")")
	end

	-- Update new selection
	self.sel_item:set_selected(false, n)
	self.sel_n = sel
	self.sel_item = self.cur_menu.items[self.sel_n]
	self.sel_item:set_selected(true, n)
	
	Audio:play_var("menu_hover", 0.2, 1)

	return true
end

function MenuManager:find_selectable_from(n, diff)
	diff = diff or 1

	local len = #self.cur_menu.items
	local sel = n

	local limit = len
	local found = false
	while not found and limit > 0 do
		sel = mod_plus_1(sel + diff, len)
		if self.cur_menu.items[sel].is_selectable then found = true end
		limit = limit - 1
	end

	return sel, found
end

function MenuManager:set_selection(n)
	if self.sel_item then self.sel_item:set_selected(false) end
	if not self.cur_menu then return false end

	self.sel_n = n
	self.sel_item = self.cur_menu.items[self.sel_n]
	if not self.sel_item then return false end
	self.sel_item:set_selected(true)

	return true
end

function MenuManager:back()
	if #self.menu_stack == 0 then
		self:unpause()
		return
	end

	local item = table.remove(self.menu_stack)
	if item.menu then
		self:set_menu(item.menu, true)
		self:set_selection(item.sel_n)
	end
end

function MenuManager:keypressed(key, scancode, isrepeat)
	if self.sel_item == nil then return end
	if self.sel_item.keypressed == nil then return end
	self.sel_item:keypressed(key, scancode, isrepeat)
end

function MenuManager:gamepadpressed(joystick, buttoncode)
	if self.sel_item == nil then return end
	if self.sel_item.gamepadpressed == nil then return end
	self.sel_item:gamepadpressed(joystick, buttoncode)
end

function MenuManager:gamepadreleased(joystick, buttoncode)
	if self.sel_item == nil then return end
	if self.sel_item.gamepadreleased == nil then return end
	self.sel_item:gamepadreleased(joystick, buttoncode)
end

function MenuManager:gamepadaxis(joystick, axis, value)
	if self.sel_item == nil then return end
	if self.sel_item.gamepadaxis == nil then return end
	self.sel_item:gamepadaxis(joystick, axis, value)
end

function MenuManager:mousepressed(x, y, button, istouch, presses)
	if self.sel_item == nil then return end
	if self.sel_item.mousepressed == nil then return end
	self.sel_item:mousepressed(x, y, button, istouch, presses)
end

function MenuManager:mousereleased(x, y, button, istouch, presses)
	if self.sel_item == nil then return end
	if self.sel_item.mousereleased == nil then return end
	self.sel_item:mousereleased(x, y, button, istouch, presses)
end

---------------------------------------------

function MenuManager:enable_joystick_wait_mode(joystick)
	self:set_menu("joystick_removed")
	self.joystick_wait_cooldown = 1.0
	self.joystick_wait_mode = true
	self.joystick_wait_set[joystick] = true
end

function MenuManager:disable_joystick_wait_mode()
	self:unpause()
	self:set_menu()
	self.joystick_wait_mode = false
	self.joystick_wait_set = {}
end

function MenuManager:update_joystick_wait_mode(dt)
	local count = 0
	for controller, _ in pairs(self.joystick_wait_set) do
		if controller:isConnected() then
			self.joystick_wait_set[controller] = nil
		else
			count = count + 1
		end
	end

	if count == 0 and self.joystick_wait_mode then
		self:disable_joystick_wait_mode()
	end
end

return MenuManager