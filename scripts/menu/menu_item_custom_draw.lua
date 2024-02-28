local MenuItem = require "scripts.menu.menu_item"

local CustomDrawMenuItem = MenuItem:inherit()

function CustomDrawMenuItem:init(i, x, y, custom_draw)
	self:init_menuitem(i, x, y)
	self.draw = custom_draw
end

return CustomDrawMenuItem