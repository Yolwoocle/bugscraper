require "scripts.util"
local images = require "data.images"

local BreakableActor = require "scripts.actor.enemies.breakable_actor"
local Button = require "scripts.actor.enemies.button_big"

local BreakableCrate = BreakableActor:inherit()

function BreakableCrate:init(x, y, img, w, h)
    BreakableCrate.super.init(self, x, y, img or images.big_red_button_crack3, w or 58, h or 45)
    self.name = "breakable_crate"

    self.spawned_actor = Button
end

function BreakableCrate:on_death()
    BreakableCrate.super.on_death(self)

    local b = create_actor_centered(self.spawned_actor, self.mid_x, self.mid_y)
    game:new_actor(b)
end

return BreakableCrate