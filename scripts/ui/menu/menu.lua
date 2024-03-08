require "scripts.util"
local Class = require "scripts.meta.class"
local TextMenuItem = require "scripts.ui.menu.menu_item_text"

local Menu = Class:inherit()

function Menu:init(game, items, bg_color)
	self.items = {}
	self.is_menu = true
	
	local th = get_text_height()
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
	self.padding = 50

	self.is_scrollable = self.height > (CANVAS_HEIGHT - self.padding)
	if self.is_scrollable then
		self.def_y = -self.padding
	else
		self.def_y = -CANVAS_HEIGHT / 2 + self.height / 2
	end

	self.scroll_position = self.def_y
	self.target_scroll_position = self.def_y
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
		item:draw()
	end
end

function Menu:set_target_scroll_position(value)
	self.target_scroll_position = clamp(value, -self.padding, self.height - CANVAS_HEIGHT + self.padding)
end

return Menu