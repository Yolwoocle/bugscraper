local MenuItem = require "scripts.ui.menu.menu_item"

local CustomDrawMenuItem = MenuItem:inherit()

function CustomDrawMenuItem:init(i, x, y, custom_draw)
	CustomDrawMenuItem.super.init(self, i, x, y)
	self.draw = custom_draw
end

return CustomDrawMenuItem