local TextMenuItem = require "scripts.ui.menu.menu_item_text"

local SliderMenuItem = TextMenuItem:inherit()

function SliderMenuItem:init(i, x, y, text, on_click, values, update_value)
	self:init_textitem(i, x, y)

	self.ox = 0
	self.oy = 0
	self.text = text or ""
	self.label_text = self.text
	self.value_text = ""

	self.values = values
	self.value_index = 1
	self.value = values[1]
	self.value_text = tostring(self.value)

	self.on_click = on_click
	self.is_selectable = true

	self.update_value = update_value
end

function SliderMenuItem:update(dt)
	self.ox = lerp(self.ox, 0, 0.3)
	self.oy = lerp(self.oy, 0, 0.3)
	
	self:update_value()

	if type(self.value) ~= "nil" then
		self.value_text = concat("< ", self.value_text, " >")
	else
		self.text = self.label_text
	end

	if Input:action_pressed("ui_left") and self.is_selected then
		self:on_click(-1)
		self:after_click(-1)
	end
	if Input:action_pressed("ui_right") and self.is_selected then
		self:on_click(1)
		self:after_click(1)
	end
end

function SliderMenuItem:set_selected(val, diff)
	self.is_selected = val
	if val then
		self.oy = sign(diff or 1) * 4
	end
end

function SliderMenuItem:next_value(diff)
	diff = diff or 1
	self.value_index = mod_plus_1(self.value_index + diff, #self.values)
	self.value = self.values[self.value_index]
	self.value_text = tostring(self.value)
end

function SliderMenuItem:after_click(diff)
	diff = diff or 1
	self.ox = sign(diff) * 6
	Options:update_options_file()

	-- TODO: rising pitch or decreasing pitch
	-- + sound preview for music & sfx
	-- audio:play("menu_select)
end

return SliderMenuItem