local MenuItem = require "scripts.ui.menu.menu_item"

local TextMenuItem = MenuItem:inherit()

-- Split into SelectableMenuItem ? Am I becoming a Java dev now?
-- THIS IS A MESS, *HELP*
-- AAAAAAAAAAAAAAAAAAAAAAAAAAAAA
-- Should do:
-- MenuItem
-- -> TextMenuItem
-- -> SelectableMenuItem
--   -> ToggleMenuItem
--   -> SliderMenuItem
function TextMenuItem:init(i, x, y, text, on_click, update_value)
	self:init_textitem(i, x, y, text, on_click, update_value)
end
function TextMenuItem:init_textitem(i, x, y, text, on_click, update_value)
	self:init_menuitem(i, x, y)

	self.ox = 0
	self.oy = 0
	self.text = text or ""
	self.label_text = self.text
	self.value_text = ""

	self.value = nil
	self.type = "text"

	if on_click and type(on_click) == "function" then
		self.on_click = on_click
		self.is_selectable = true
	else
		self.is_selectable = false
	end

	-- -- Custom update value function
	-- if custom_update_value then
	-- 	self.update_value = custom_update_value
	-- end

	self.update_value = update_value or function() end

	-- if default_val ~= nil then
	-- 	self:update_value(default_val)
	-- end
end

function TextMenuItem:update(dt)
	self:update_textitem(dt)
end
function TextMenuItem:update_textitem(dt)
	self:update_value()

	self.ox = lerp(self.ox, 0, 0.3)
	self.oy = lerp(self.oy, 0, 0.3)

	self.text = self.label_text
	-- if self.value == nil or #self.value_text == "0" then
	-- else
	-- 	self.text = concat(self.label_text, ": ", self.value_text)
	-- end
end

function TextMenuItem:draw()
	self:draw_textitem()
end
function TextMenuItem:draw_textitem()
	gfx.setColor(1, 1, 1, 1)
	local text_height = get_text_height(self.text)

	-- /!\ This is rlly sketchy
	if type(self.value) == "nil" then
		self:draw_withoutvalue()
	else
		self:draw_withvalue()
	end
	
	gfx.setColor(1, 1, 1, 1)
end

function TextMenuItem:get_leftjustified_text_draw_function()
	local draw_func = ternary(self.is_selected,
		function(...) print_ycentered_outline(COL_WHITE, SELECTED_HIGHLIGHT_COLOR, ...) end,
		function(...) print_ycentered(...) end
	)

	return draw_func
end

function TextMenuItem:draw_withoutvalue()
	local draw_func = ternary(self.is_selected,
		function(...) print_centered_outline(COL_WHITE, SELECTED_HIGHLIGHT_COLOR, ...) end,
		function(...) print_centered(...) end
	)

	if not self.is_selectable then
		local v = 0.5
		gfx.setColor(v, v, v, 1)
	end
	draw_func(self.text, self.x, self.y + self.oy)
end

function TextMenuItem:draw_withvalue()
	local draw_func = self:get_leftjustified_text_draw_function()

	if not self.is_selectable then
		local v = 0.5
		gfx.setColor(v, v, v, 1)
	end
	draw_func(self.text, self.x - CANVAS_WIDTH*0.25, self.y + self.oy)

	self:draw_value_text()
end

function TextMenuItem:draw_value_text()
	local draw_func = self:get_leftjustified_text_draw_function()
	local value_text_width = get_text_width(self.value_text)
	
	draw_func(self.value_text, self.x + CANVAS_WIDTH*0.25 - value_text_width + self.ox, self.y + self.oy)
end

function TextMenuItem:set_selected(val, diff)
	self.is_selected = val
	if val then
		self.oy = sign(diff or 1) * 4
	end
end

function TextMenuItem:after_click()
	Options:update_options_file()
	Audio:play("menu_select")
	self.oy = -4
end

return TextMenuItem