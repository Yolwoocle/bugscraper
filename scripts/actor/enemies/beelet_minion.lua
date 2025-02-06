require "scripts.util"
local Beelet = require "scripts.actor.enemies.beelet"
local images = require "data.images"

local BeeletMinion = Beelet:inherit()

function BeeletMinion:init(x, y)
    BeeletMinion.super.init(self, x,y, images.beelet_1, 12, 12)
    self.name = "beelet_minion"

    self.is_pushable = false
    self.life = 1
end

function BeeletMinion:draw()
    BeeletMinion.super.draw(self)
end


return BeeletMinion