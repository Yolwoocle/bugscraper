require "scripts.util"
local Class = require "scripts.meta.class"

local MenuItem = Class:inherit()
function MenuItem:init_menuitem(i, x, y)
	self.i = i
	self.x = x
	self.y = y
	self.def_x = x
	self.def_y = y

	self.is_selected = false
end

function MenuItem:update(dt)
	self:update_menuitem(dt)
end
function MenuItem:update_menuitem(dt)

end

function MenuItem:on_click()
end

return MenuItem