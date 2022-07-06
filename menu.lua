require "util"
local Class = require "class"
local images = require "images"

local MenuItem = Class:inherit()
function MenuItem:init_menuitem(i, x, y)
	self.i = i
	self.x = x
	self.y = y

	self.is_selected = false
end

function MenuItem:update_menuitem(dt)

end

function MenuItem:on_click()
end

------------

local TextMenuItem = MenuItem:inherit()

-- Split into SelectableMenuItem ? Am I becoming a Java dev now?
function TextMenuItem:init(i, x, y, text, on_click)
	self:init_menuitem(i, x, y)

	self.oy = 0
	self.text = text or ""
	
	if on_click and type(on_click) == "function" then
		self.on_click = on_click
		self.is_selectable = true
	else
		self.is_selectable = false
	end
end

function TextMenuItem:update(dt)
	self.oy = lerp(self.oy, 0, 0.3)
end

function TextMenuItem:draw()
	gfx.setColor(1,1,1,1)
	local th = get_text_height(self.text)
	if self.is_selected then
		-- rect_color_centered(COL_LIGHT_YELLOW, "fill", self.x, self.y+th*0.4, get_text_width(self.text)+8, th/4)
		-- rect_color_centered(COL_WHITE, "fill", self.x, self.y, get_text_width(self.text)+32, th)
		print_centered_outline(COL_WHITE, COL_ORANGE, self.text, self.x, self.y + self.oy)
		-- print_centered(self.text, self.x, self.y)
	else
		if not self.is_selectable then
			local v = 0.5
			gfx.setColor(v,v,v,1)
		end
		print_centered(self.text, self.x, self.y + self.oy)
	end
	gfx.setColor(1,1,1,1)
end

function TextMenuItem:set_selected(val)
	self.is_selected = val
	if val then
		self.oy = -4
	end
end

--------

local Menu = Class:inherit()

function Menu:init(items, bg_color)
	self.items = {}

	local th = get_text_height()
	local h = (#items - 1) * th
	local start_y = CANVAS_HEIGHT/2 - h/2
	for i,parms in pairs(items) do
		self.items[i] = TextMenuItem:new(i, CANVAS_WIDTH/2, start_y + i*th, unpack(parms))
	end

	self.bg_color = bg_color or {1,1,1, 0}
end

function Menu:update(dt)
	for i,item in pairs(self.items) do
		item:update(dt)
	end
end

function Menu:draw()
	for i,item in pairs(self.items) do
		item:draw()
	end
end

-----------

function func_set_menu(menu)
	return function()
		game.menu:set_menu(menu)
	end
end

-----------

local MenuManager = Class:inherit()

function MenuManager:init()
	self.menus = {}
	local callback_set_menu = function(e) return end
	self.menus.pause = Menu:new({
		-- {"<<<<<<<<< PAUSED >>>>>>>>>"},
		{"********** PAUSED **********"},
		{""},
		{"RESUME", function() game.menu:unpause() end},
		{"RETRY", function() end},
		{"OPTIONS", func_set_menu('options')},
		{"CREDITS", func_set_menu('credits')},
		{"EXIT",    func_set_menu('title')},
		{""},
		{""},
	}, {0, 0, 0, 0.85})

	self.menus.options = Menu:new({
		{"OPTIONS"},
		{""},
		{"SOUND: [ON/OFF (todo dynamic text you lazy dumbass)]", function() game:toggle_sound() end},
		{""}
	}, {0, 0, 0, 0.85})

	self.cur_menu = nil
	self.is_paused = false

	self.sel_n = 1
	self.sel_item = nil
end

function MenuManager:update(dt)
	if self.cur_menu then
		self.cur_menu:update(dt)

		-- Navigate up and down
		if game:button_pressed("up") then      self:incr_selection(-1)    end
		if game:button_pressed("down") then    self:incr_selection(1)     end

		-- Update current selection
		self.sel_n = mod_plus_1(self.sel_n, #self.cur_menu.items)
		self.sel_item = self.cur_menu.items[self.sel_n]
		self.sel_item.is_selected = true
		
		-- On pressed
		local btn = game:button_pressed("jump")
		local btn_back = game:button_pressed("shoot")
		if btn and self.sel_item and self.sel_item.on_click then
			self.sel_item:on_click()
		end
	end

	local btn_pressed, player = game:button_pressed("pause")
	if btn_pressed then
		self:toggle_pause()
	end
end

function MenuManager:draw()
	if self.cur_menu.bg_color then
		rect_color(self.cur_menu.bg_color, "fill", game.cam_x or 0, game.cam_y or 0, CANVAS_WIDTH, CANVAS_HEIGHT)
	end
	self.cur_menu:draw()
end

function MenuManager:set_menu(menu)
	if type(menu) == "nil" then
		self.cur_menu = nil
		return
	end

	local m = self.menus[menu]
	if not m then    return false, "menu '"..menu.."' does not exist"    end
	self.cur_menu = m

	-- Update selection to first selectable
	local sel, found = self:find_selectable_from(1, 1)
	self:set_selection(sel)

	return true
end

function MenuManager:pause()
	self.is_paused = true
	self:set_menu("pause")
end

function MenuManager:unpause()
	self.is_paused = false
	self:set_menu()
end

function MenuManager:toggle_pause()
	if self.is_paused then
		self:unpause()
	else
		self:pause()
	end
end

function MenuManager:incr_selection(n)
	if not self.cur_menu then    return false, "no current menu"   end
	
	-- Increment selection until valid item
	local sel, found = self:find_selectable_from(self.sel_n, n)

	if not found then
		self.sel_n = self.sel_n + n
		return false, concat("no selectable item found; selection set to n + (",n,") (",self.sel_n,")")
	end
	
	-- Update new selection
	self.sel_item:set_selected(false)
	self.sel_n = sel
	self.sel_item = self.cur_menu.items[self.sel_n]
	self.sel_item:set_selected(true)
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
		if self.cur_menu.items[sel].is_selectable then     found = true    end
		limit = limit - 1
	end

	return sel, found
end

function MenuManager:set_selection(n)
	self.cur_menu.items[self.sel_n]:set_selected(false)

	self.sel_n = n
	self.sel_item = self.cur_menu.items[self.sel_n]
	self.sel_item:set_selected(true)
end

return MenuManager