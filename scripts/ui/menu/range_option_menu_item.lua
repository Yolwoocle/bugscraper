local OptionMenuItem = require "scripts.ui.menu.option_menu_item"

local SliderOptionMenuItem = OptionMenuItem:inherit()

local default_formatters = {
	["default"] = function(value)
		return tostring(value) 
	end,
	["%"] = function(value)
		return string.format("%d%%", round(value * 100)) 
	end
}

function SliderOptionMenuItem:init(i, x, y, text, property_name, range, step, text_formatter, additional_update, additional_on_click)	
	if type(text_formatter) == "nil" then
		text_formatter = default_formatters["default"]

	elseif type(text_formatter) == "string" then
		text_formatter = default_formatters[text_formatter] or default_formatters["default"]

	elseif type(text_formatter) ~= "function" then
		error("Invalid type for text_formatter: "..type(text_formatter))
		
	end

	SliderOptionMenuItem.super.init(self, i, x, y, text, property_name, additional_update)
	
	self.range = range
	self.step = step
	self.property_name = property_name

	self.discrete_range = {0, self:real_to_discrete(self.range[2])}

	self.text_formatter = function(value)
		return string.format("< %s >", text_formatter(value))
	end
	self.additional_on_click = additional_on_click
end

function SliderOptionMenuItem:real_to_discrete(real_value)
	local ret = round((real_value - self.range[1]) / self.step)
	print_debug("Real ", real_value, " -> ", ret)
	return ret
end

function SliderOptionMenuItem:discrete_to_real(discrete_value)
	local ret = lerp(self.range[1], self.range[2], discrete_value / self.discrete_range[2])
	print_debug("Discr ", discrete_value, " -> ", ret)
	return ret
end

function SliderOptionMenuItem:round_value(real_value)
	return self:discrete_to_real(self:real_to_discrete(real_value))
end

function SliderOptionMenuItem:update(dt)
	SliderOptionMenuItem.super.update(self, dt)

	if Input:action_pressed("ui_left") and self.is_selected then
		self:on_click(-1)
	end
	if Input:action_pressed("ui_right") and self.is_selected then
		self:on_click(1)
	end
end

function SliderOptionMenuItem:on_click(diff)
	diff = diff or 1
	self.ox = sign(diff) * 6 
	
	self.value = self:round_value(self.value + diff * self.step)
	if self.value < self.range[1] then self.value = self.range[2] end
	if self.value > self.range[2] then self.value = self.range[1] end

	self:set_value_and_option(self.value)

	local ratio = (self.value - self.range[1]) / (self.range[2] - self.range[1])
	Audio:play("menu_select", nil, 0.8 + ratio*0.4)
	if self.additional_on_click then
		self:additional_on_click()
	end

	-- + sound preview for music & sfx
end

return SliderOptionMenuItem