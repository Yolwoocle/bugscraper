local MenuItem = require "scripts.menu.menu_item"

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

	if type(self.value) ~= "nil" then
		self.text = concat(self.label_text, ": ", self.value_text)
	else
		self.text = self.label_text
	end
end

function TextMenuItem:draw()
	self:draw_textitem()
end
function TextMenuItem:draw_textitem()
	gfx.setColor(1, 1, 1, 1)
	local th = get_text_height(self.text)
	if self.is_selected then
		-- rect_color_centered(COL_LIGHT_YELLOW, "fill", self.x, self.y+th*0.4, get_text_width(self.text)+8, th/4)
		-- rect_color_centered(COL_WHITE, "fill", self.x, self.y, get_text_width(self.text)+32, th)
		print_centered_outline(COL_WHITE, COL_ORANGE, self.text, self.x + self.ox, self.y + self.oy)
		-- print_centered(self.text, self.x, self.y)
	else
		if not self.is_selectable then
			local v = 0.5
			gfx.setColor(v, v, v, 1)
		end
		print_centered(self.text, self.x, self.y + self.oy)
	end
	gfx.setColor(1, 1, 1, 1)
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