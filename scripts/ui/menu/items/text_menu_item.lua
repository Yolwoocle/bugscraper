local MenuItem = require "scripts.ui.menu.items.menu_item"
local images   = require "data.images"

local TextMenuItem = MenuItem:inherit()

function TextMenuItem:init(i, x, y, text, on_click, update_value)
	TextMenuItem.super.init(self, i, x, y)

	self.ox = 0
	self.oy = 0
	self:set_label_text(Text:parse_string(text))
	self:set_value_text("")

	self.value = nil
	self.type = "text"

	if on_click and type(on_click) == "function" then
		self.on_click = on_click
		self.is_selectable = true
	else
		self.is_selectable = false
	end

	-- Custom update value function
	self.update_value = update_value or function(_) end

	self.annotation = nil

	-- if default_val ~= nil then
	-- 	self:update_value(default_val)
	-- end
end

function TextMenuItem:set_annotation(text)
	self.annotation = Text:parse_string(text)
end

function TextMenuItem:set_label_text(text)
	self.label_text = Text:parse_string(text)
end

function TextMenuItem:set_value_text(text)
	self.value_text = Text:parse_string(text)
end

function TextMenuItem:update(dt)
	TextMenuItem.super.update(self, dt)
	self.update_value(self)
	-- self.label_text = random_neighbor(3)

	self.ox = lerp(self.ox, 0, 0.3)
	self.oy = lerp(self.oy, 0, 0.3)
	if math.abs(self.ox) <= 0.1 then self.ox = 0 end
	if math.abs(self.oy) <= 0.1 then self.oy = 0 end
end

function TextMenuItem:draw()
	self:draw_textitem()
end
function TextMenuItem:draw_textitem()
	gfx.setColor(1, 1, 1, 1)
	local text_height = get_text_height(self.label_text)
	
	-- if self.is_selected then
	-- 	local col = Input:get_last_ui_player_color()
	-- 	local x = math.floor(self.x - MENU_PADDING - 8)
	-- 	local y = math.floor(self.y + self.oy - 6)
	-- 	local w = math.floor(MENU_PADDING*2 + 16)
	-- 	local h = math.floor(14)
	-- 	circle_color(col, "fill", x,   y+h/2, h/2)
	-- 	circle_color(col, "fill", x+w, y+h/2, h/2)
	-- 	rect_color(col, "fill", x, y, w, h)
	-- end
	
	if self.is_selected and self.label_text ~= "" then
		local col = Input:get_last_ui_player_color()
		local x = math.floor(MENU_PADDING)
		local y = math.floor(self.y + self.oy - 6)
		local w = math.floor(CANVAS_WIDTH - MENU_PADDING*2)
		local h = 16

		draw_3_slice(images.selection_left, images.selection_right, col, x, y, w, h)
	end
	
	if type(self.value) == "nil" then
		self:draw_without_value()
	else
		self:draw_with_value()
	end
	
	gfx.setColor(1, 1, 1, 1)

	self:draw_annotation()
end

function TextMenuItem:draw_annotation()
	if self.is_selected and self.annotation then
		local x = math.floor(MENU_PADDING)
		local y = math.floor(self.y + self.oy - 6 + 24)
		local w = math.floor(CANVAS_WIDTH - MENU_PADDING*2)
		local h = math.floor(16)

		draw_3_slice(images.selection_left, images.selection_right, COL_WHITE, x, y, w, h)
		draw_centered(images.bubble_tip, x + w/2, y - images.bubble_tip:getHeight()/2)

		print_centered_outline(COL_BLACK_BLUE, COL_WHITE, self.annotation, x + w/2, y + h/2)

	end
end

-- this is awful. please ffs change it
function TextMenuItem:get_leftjustified_text_draw_function()
	local col = Input:get_last_ui_player_color()
	local draw_func = ternary(self.is_selected,
		function(...) print_ycentered_outline(nil, col, ...) end,
		function(...) print_ycentered(...) end
	)

	return draw_func
end

function TextMenuItem:draw_without_value(text_color)
	local col = Input:get_last_ui_player_color()
	local draw_func = ternary(self.is_selected,
		function(...) print_centered_outline(text_color, col, ...) end,
		function(...) print_centered(...) end
	)

	if not self.is_selectable then
		gfx.setColor(COL_LIGHT_GRAY)
	end
	print_centered(self.label_text, self.x, self.y + self.oy)
end

function TextMenuItem:draw_with_value()
	local draw_func = self:get_leftjustified_text_draw_function()

	if not self.is_selectable then
		gfx.setColor(COL_MID_GRAY)
	end
	-- draw_func(self.label_text, self.x + MENU_PADDING, self.y + self.oy)
	draw_func(self.label_text, MENU_PADDING + 16, self.y + self.oy)

	self:draw_value_text()
end

function TextMenuItem:draw_value_text()
	local draw_func = self:get_leftjustified_text_draw_function()
	local value_text_width = get_text_width(self.value_text)
	
	draw_func(self.value_text, CANVAS_WIDTH - MENU_PADDING - value_text_width - 16 + self.ox, self.y + self.oy)
end

function TextMenuItem:set_selected(val, diff)
	self.is_selected = val
	if val then
		self.oy = sign(diff or 1) * 4
	end
end

function TextMenuItem:after_click()
	self.oy = -4
end

return TextMenuItem