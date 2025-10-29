local OptionMenuItem = require "scripts.ui.menu.items.option_menu_item"

local RangeOptionMenuItem = OptionMenuItem:inherit()

local default_formatters = {
	["default"] = function(value)
		return tostring(value) 
	end,
	["%"] = function(value)
		return string.format("%d%%", round(value * 100)) 
	end
}

function RangeOptionMenuItem:init(i, x, y, text, property_name, range, step, text_formatter, additional_update, additional_on_click, params)	
	params = params or {}
	if type(text_formatter) == "nil" then
		text_formatter = default_formatters["default"]

	elseif type(text_formatter) == "string" then
		text_formatter = default_formatters[text_formatter] or default_formatters["default"]

	elseif type(text_formatter) ~= "function" then
		error("Invalid type for text_formatter: "..type(text_formatter))
		
	end

	RangeOptionMenuItem.super.init(self, i, x, y, text, property_name, additional_update)
	
	self.range = range
	self.step = step
	self.property_name = property_name

	self.discrete_range = {0, self:real_to_discrete(self.range[2])}

	self.text_formatter = function(value)
		return string.format("< %s >", text_formatter(value))
	end
	self.additional_on_click = additional_on_click

	self.do_vibrations = param(params.do_vibrations, true)
end

function RangeOptionMenuItem:real_to_discrete(real_value)
	return round((real_value - self.range[1]) / self.step)
end

function RangeOptionMenuItem:discrete_to_real(discrete_value)
	return lerp(self.range[1], self.range[2], discrete_value / self.discrete_range[2])
end

function RangeOptionMenuItem:round_value(real_value)
	return self:discrete_to_real(self:real_to_discrete(real_value))
end

function RangeOptionMenuItem:update(dt)
	RangeOptionMenuItem.super.update(self, dt)

	if Input:action_pressed("ui_left") and self.is_selected then
		self:on_click(-1)
	end
	if Input:action_pressed("ui_right") and self.is_selected then
		self:on_click(1)
	end
end

function RangeOptionMenuItem:on_click(diff)
	diff = diff or 1
	self.ox = sign(diff) * 6 
	
	self.value = self:round_value(self.value + diff * self.step)
	if self.value < self.range[1] then self.value = self.range[2] end
	if self.value > self.range[2] then self.value = self.range[1] end

	self:set_value_and_option(self.value)

	local ratio = (self.value - self.range[1]) / (self.range[2] - self.range[1])
	Audio:play("ui_menu_select_{01-04}", nil, 0.8 + ratio*0.4)

	if self.do_vibrations then
		local vibr_str = lerp(0.05, 0.15, ratio)
		Input:vibrate(Input:get_last_ui_user_n(), 0.02, ternary(diff < 0, vibr_str, 0), ternary(diff > 0, vibr_str, 0))
	end

	if self.additional_on_click then
		self:additional_on_click()
	end

	-- + sound preview for music & sfx
end

return RangeOptionMenuItem