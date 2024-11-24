require "scripts.util"
local Menu = require "scripts.ui.menu.menu"
local TextMenuItem = require "scripts.ui.menu.items.text_menu_item"
local images       = require "data.images"
local debug_command_manager = require "scripts.debug.debug_command_manager"
local utf8 = require 'utf8'

local DebugCommandMenu = Menu:inherit()

function DebugCommandMenu:init(game)
	DebugCommandMenu.super.init(self, game, {{""}}, {0, 0, 0, 0.5}, nil, nil)

	self.debug_command_manager = debug_command_manager

	self:init_menu()
end

function DebugCommandMenu:on_set()
	self:init_menu()
end

function DebugCommandMenu:init_menu()
	self.blur_enabled = false

	self.input = ""
	self.cursor_pos = 0
end

function DebugCommandMenu:keypressed(key, scancode, isrepeat)
	if key == 'escape' or key == 'f1' then
		game.menu_manager:unpause()
		game.menu_manager:set_menu()
	end

	-- Send messages
	if key == "return" then
		self:send_input()
	end

	-- Backspace deletes text
	if key == 'backspace' then
		self:backspace_input(1)
	end
	if key == 'delete' then
		self:del_input(1)
	end

	-- Move cursor
	if key == 'left' then
		self:move_cursor(-1)
	end
	if key == 'right' then
		self:move_cursor(1)
	end
end

function DebugCommandMenu:send_input()
	local args = split_str(self.input, " ")
	self.debug_command_manager:run(unpack(args))
	self:clear_input()
end


function DebugCommandMenu:textinput(text)
	if self.block_next_input then
		self.block_next_input = false
		return
	end

	local a = utf8.sub(self.input, 1, self.cursor_pos)
	local b = utf8.sub(self.input, self.cursor_pos+1, utf8.len(self.input))
	self.input = a..text..b
	self.cursor_pos = self.cursor_pos + utf8.len(text)
end

function DebugCommandMenu:backspace_input(n)
	local curtext = self.input
	if #curtext == 0 or self.cursor_pos == 0 then
		return 
	end

	local b = math.max(0, self.cursor_pos-n)
	local first = utf8.sub(curtext, 1, b)
	local last  = utf8.sub(curtext, self.cursor_pos+1, -1) 
	self.input = first..last
	self.cursor_pos = clamp(math.max(0, self.cursor_pos-n), 0, utf8.len(self.input))
end

function DebugCommandMenu:del_input(n)
	local len = utf8.len(self.input)

	-- When you press "del"
	local curtext = self.input
	if #curtext == 0 or self.cursor_pos == len then
		return 
	end

	local b = math.min(len+1, self.cursor_pos+1+n)
	local first = utf8.sub(curtext, 1, self.cursor_pos)
	local last  = utf8.sub(curtext, b, -1) 
	self.input = first..last
--	self.cursor_pos = clamp(math.min(len, self.cursor_pos, 0, utf8.len(self.input))
end

function DebugCommandMenu:clear_input()
	self.input = ""
	self.cursor_pos = 0
end

function DebugCommandMenu:move_cursor(delta)
	self.cursor_pos = clamp(self.cursor_pos + delta, 0, #self.input)
end

function DebugCommandMenu:update(dt)
	DebugCommandMenu.super.update(self, dt)
end

function DebugCommandMenu:draw()
	DebugCommandMenu.super.draw(self)

	local x = 4
	local y = CANVAS_HEIGHT - 16

	-- Draw input bar
	local final_text = "> "..self.input
	rect_color({0,0,0,0.6}, "fill", 0, y, CANVAS_WIDTH, 16)
	print_outline(COL_WHITE, COL_BLACK_BLUE, final_text, x, y)
	
	local t = 1
	if love.timer.getTime() % t < t/2 then
		local substr = utf8.sub(self.input, 1, self.cursor_pos)
		local cursor_x = get_text_width(substr) + get_text_width("> ") + x
		love.graphics.setColor(1,1,1)
		love.graphics.rectangle("fill", cursor_x,y, 2,32)
	end 

	-- Draw messages
	for i = #self.debug_command_manager.messages, 1, -1 do
		local message = self.debug_command_manager.messages[i]
		local msg_w = get_text_width(message.content)
		local msg_h = get_text_height(message.content)

		y = y - msg_h

		rect_color({0, 0, 0, 0.6}, "fill", 0, y, x + msg_w + 4, msg_h)
		print_outline(message.color or COL_WHITE, COL_BLACK_BLUE, message.content, x, y)
	end
end

return DebugCommandMenu