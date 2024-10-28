local TextMenuItem = require "scripts.ui.menu.text_menu_item"

local StatsMenuItem = TextMenuItem:inherit()

function StatsMenuItem:init(i, x, y, text, get_value)
	self:init_textitem(i, x, y, text)
	self.get_value = get_value
	self.value = nil
end

function StatsMenuItem:update(dt)
	self:update_textitem(dt)
	self.value = self:get_value()
	self:set_value_text(tostring(self.value))
end

return StatsMenuItem
