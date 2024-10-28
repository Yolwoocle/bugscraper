local TextMenuItem = require "scripts.ui.menu.text_menu_item"

local OptionMenuItem = TextMenuItem:inherit()

function OptionMenuItem:init(i, x, y, text, property_name, additional_update)	
	OptionMenuItem.super.init(self, i, x, y, text)
	
	self.ox = 0
	self.oy = 0
	self.text = text or ""
	self:set_label_text(self.text)
	self:set_value_text("")
	
	self.property_name = property_name
	self.is_selectable = true
	
	self.additional_update = additional_update or function(self) end
	self.text_formatter = function(value)
		return tostring(value)
	end
end

function OptionMenuItem:update(dt)
	OptionMenuItem.super.update(self, dt)
	
	self:update_option_value()

	if type(self.value) ~= "nil" then
		self:set_value_text(self.text_formatter(self.value))
	else
		self.text = self.label_text
	end

	self:additional_update()
end

function OptionMenuItem:update_option_value()
	self.value = Options:get(self.property_name)
end

function OptionMenuItem:set_value_and_option(value)
	self.value = value
	Options:set(self.property_name, self.value)
end

function OptionMenuItem:on_click()
	self:set_value_and_option(not self.value)
	Audio:play("menu_select")
end


return OptionMenuItem