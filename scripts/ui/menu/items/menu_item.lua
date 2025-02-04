require "scripts.util"
local Class = require "scripts.meta.class"

local MenuItem = Class:inherit()
function MenuItem:init(i, x, y)
	self.i = i
	self.x = x
	self.y = y
	self.def_x = x
	self.def_y = y

	self.is_selected = false
	self.is_visible = true -- TODO
end

function MenuItem:update(dt)

end

function MenuItem:on_click()
end

function MenuItem:on_set()
end

return MenuItem