require "scripts.util"
local Class = require "scripts.meta.class"
local images= require "data.images"

local Upgrade = Class:inherit()

function Upgrade:init()
    self:init_upgrade()
end
function Upgrade:init_upgrade()
    self.name = "upgrade"
    self.type = UPGRADE_TYPE_INSTANT

    self.title = self.name

    self.sprite = images.upgrade_coffee
    self.color = COL_MID_GREEN 
end

function Upgrade:update(dt)
    self:update_upgrade(dt)
end

function Upgrade:update_upgrade(dt)
end

function Upgrade:on_apply(player)
end

function Upgrade:on_finish(player)
end

function Upgrade:draw(x, y, s)
    self:draw_upgrade(x, y, s)
end
function Upgrade:draw_upgrade(x, y, s)
    draw_centered(self.sprite, x, y, 0, s, s)
end

function Upgrade:get_title()
    return self.title
end

return Upgrade