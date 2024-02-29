require "scripts.util"
local Class = require "scripts.class"
local generate_menus = require "data.menus"

local MenuManager = Class:inherit()

local MENU_SCROLL_DEADZONE = 32

function MenuManager:init(game)
	self.game = game
	self.menus = generate_menus()

	self.cur_menu = nil
	self.cur_menu_name = ""
	self.is_paused = false

	self.sel_n = 1
	self.sel_item = nil

	self.menu_stack = {}
	self.last_menu = "title"
end

function MenuManager:update(dt)
	if self.cur_menu then
		self.cur_menu:update(dt)

		-- Navigate up and down
		if Input:action_pressed("up") then self:incr_selection(-1) end
		if Input:action_pressed("down") then self:incr_selection(1) end

		-- Update current selection
		self.sel_n = mod_plus_1(self.sel_n, #self.cur_menu.items)
		self.sel_item = self.cur_menu.items[self.sel_n]
		self.sel_item.is_selected = true

		-- On pressed
		local btn = Input:action_pressed("ui_select")
		if btn and self.sel_item and self.sel_item.on_click then
			if not self.sel_item.is_waiting_for_input then
				self.sel_item:on_click()
				self.sel_item:after_click()
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

	
	if Input:action_pressed("pause") and self.cur_menu == nil then
		self:pause()
	elseif Input:action_pressed("ui_back") then
		self:back()
	end
end

function MenuManager:draw()
	if self.cur_menu.bg_color then
		rect_color(self.cur_menu.bg_color, "fill", game.cam_realx-1 or -1, game.cam_realy or -1, CANVAS_WIDTH+2, CANVAS_HEIGHT+2)
	end
	self.cur_menu:draw()
end

function MenuManager:set_menu(menu, is_back)
	self.last_menu = self.cur_menu

	-- nil menu
	if menu == nil then
		self.cur_menu = nil
		self.menu_stack = {}
		game:on_unmenu()
		return
	else
		if not is_back then
			table.insert(self.menu_stack, self.cur_menu)
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

	-- Reset game screenshake
	if game then
		game.cam_x = 0
		game.cam_y = 0
	end

	game:on_menu()
	return true
end

function MenuManager:pause()
	-- Retry if game ended
	if game.is_on_win_screen then
		self:set_menu("win")
		return
	end

	if self.cur_menu == nil then
		self.is_paused = true
		self:set_menu("pause")
	end
end

function MenuManager:unpause()
	self.is_paused = false
	self:set_menu()
	game:on_unmenu()
end

function MenuManager:toggle_pause()
	if self.is_paused then
		self:unpause()
	else
		self:pause()
	end
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

	local menu = table.remove(self.menu_stack)
	if menu then
		self:set_menu(menu, true)
	end
end

function MenuManager:keypressed(key, scancode, isrepeat)
	if not self.sel_item then return end
	if not self.sel_item.keypressed then return end
	self.sel_item:keypressed(key, scancode, isrepeat)
end

return MenuManager