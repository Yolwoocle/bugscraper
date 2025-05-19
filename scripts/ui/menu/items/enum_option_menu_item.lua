local OptionMenuItem = require "scripts.ui.menu.items.option_menu_item"

local EnumOptionMenuItem = OptionMenuItem:inherit()

function EnumOptionMenuItem:init(i, x, y, text, property_name, values, text_format, additional_update)	
	local text_formatter
	if type(text_format) == "nil" then
		text_formatter = function(value) return tostring(value) end
		
	elseif type(text_format) == "string" then
		text_formatter = function(value) return Text:text(text_format.."."..tostring(value)) end
	
	elseif type(text_format) == "function" then
		text_formatter = text_format

	else
		error("Invalid type for text_formatter: "..type(text_format))
	end

	EnumOptionMenuItem.super.init(self, i, x, y, text, property_name, additional_update)
	
	self.values = values
	self:update_option_value()
	self.option_index = self:find_option_index()
	self.value = self.values[self.option_index]

	self.text_formatter = function(value)
		return string.format("< %s >", text_formatter(value))
	end
end

function EnumOptionMenuItem:find_option_index()
	for i = 1, #self.values do
		if self.values[i] == self.value then
			return i
		end
	end

	print("WARNING: EnumOptionMenuItem: cannot find index of value '"..tostring(self.value or "[nil]").."' for '"..tostring(self.label_text or "[nil]").."'")
	return 1
end

function EnumOptionMenuItem:update(dt)
	EnumOptionMenuItem.super.update(self, dt)

	if Input:action_pressed("ui_left") and self.is_selected then
		self:on_click(-1)
	end
	if Input:action_pressed("ui_right") and self.is_selected then
		self:on_click(1)
	end
end

function EnumOptionMenuItem:on_click(diff)
	diff = diff or 1
	self.ox = sign(diff) * 6 
	
	self.option_index = mod_plus_1(self.option_index + diff, #self.values)
	self:set_value_and_option(self.values[self.option_index])

	Audio:play("ui_menu_select_{01-04}")
end

return EnumOptionMenuItem