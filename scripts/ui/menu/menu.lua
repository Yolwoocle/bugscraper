require "scripts.util"
local Class = require "scripts.meta.class"
local TextMenuItem = require "scripts.ui.menu.text_menu_item"

local Menu = Class:inherit()

function Menu:init(game, items, bg_color, prompts, extra_draw)
	self.items = {}
	self.is_menu = true
	
	local th = get_text_height() + 2
	self.height = (#items - 1) * th

	for i, parms in pairs(items) do
		local parm1 = parms[1]
		if type(parm1) == "string" then
			self.items[i] = TextMenuItem:new(i, CANVAS_WIDTH / 2, (i - 1) * th, unpack(parms))
		else
			local class = table.remove(parms, 1)
			self.items[i] = class:new(i, CANVAS_WIDTH / 2, (i - 1) * th, unpack(parms))
		end
	end

	self.bg_color = bg_color or { 1, 1, 1, 0 }
	self.padding_y = 50

	self.prompts = prompts or {}
	self.second_layer = love.graphics.newCanvas(CANVAS_WIDTH, CANVAS_HEIGHT)

	self.is_scrollable = self.height > (CANVAS_HEIGHT - self.padding_y)
	if self.is_scrollable then
		self.def_y = -self.padding_y
	else
		self.def_y = -CANVAS_HEIGHT / 2 + self.height / 2
	end

	self.scroll_position = self.def_y
	self.target_scroll_position = self.def_y

	self.extra_draw = extra_draw or function() end
end

function Menu:update(dt)
	if self.is_scrollable then
		self.scroll_position = lerp(self.scroll_position, self.target_scroll_position, 0.3)
	end
	
	for i, item in pairs(self.items) do
		item.y = item.def_y - self.scroll_position
		item:update(dt)
	end
end

function Menu:draw()
	for i, item in pairs(self.items) do
		if not item.is_selected then
			item:draw()
		end
	end
	for i, item in pairs(self.items) do
		if item.is_selected then
			item:draw()
		end
	end
	self:draw_prompts()
	if self.extra_draw then self.extra_draw() end
end

function Menu:set_target_scroll_position(value)
	self.target_scroll_position = clamp(value, -self.padding_y, self.height - CANVAS_HEIGHT + self.padding_y)
end

function Menu:draw_prompts()
	local x = 2
	local rect_h = 18
	local def_y = CANVAS_HEIGHT - rect_h
	local y = def_y

	local old_canvas = love.graphics.getCanvas()
	love.graphics.setCanvas(self.second_layer)
	love.graphics.clear()

	local bottom_width = 0
	local top_width = 0
	for i, prompt in ipairs(self.prompts) do
		if i == #self.prompts then
			bottom_width = x
			x = 2
			y = 2
		end

		if #prompt >= 2 then
			local actions, text = prompt[1], prompt[2]
			local user_n = Input:get_last_ui_user_n() -- scotch
			if Input:get_user(user_n) == nil then
				local function find_first_valid_player()
					for i = 1, MAX_NUMBER_OF_PLAYERS do
						if Input:get_user(i) then
							return i
						end
					end
					return -1
				end
				user_n = find_first_valid_player()
			end
			local new_x = Input:draw_input_prompt(user_n, actions, text, COL_LIGHTEST_GRAY, x, y)
			x = new_x + 4
		end
	end

	love.graphics.setCanvas(old_canvas)
	rect_color({0,0,0,0.7}, "fill", 0, def_y, bottom_width, rect_h)
	rect_color({0,0,0,0.7}, "fill", 0, 0, x, rect_h)
	love.graphics.draw(self.second_layer, 0, 0)
end

return Menu