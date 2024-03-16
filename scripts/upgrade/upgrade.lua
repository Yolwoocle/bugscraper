require "scripts.util"
local Class = require "scripts.meta.class"
local images= require "data.images"

local Upgrade = Class:inherit()

function Upgrade:init()
    self:init_upgrade()
end
function Upgrade:init_upgrade()
    self.name = "upgrade"
    self.sprite = images.upgrade_coffee
    self.type = UPGRADE_TYPE_INSTANT
end

function Upgrade:update(dt)
    self:update_upgrade(dt)
end

function Upgrade:update_upgrade(dt)
end

function Upgrade:on_apply(actor)
end

function Upgrade:on_finish(actor)
end

function Upgrade:draw(x, y)
    self:draw_upgrade(x, y)
end
function Upgrade:draw_upgrade(x, y)
    draw_centered(self.sprite, x, y)
end

return Upgrade