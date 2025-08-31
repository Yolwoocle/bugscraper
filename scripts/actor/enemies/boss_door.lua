require "scripts.util"
local images = require "data.images"

local BreakableActor = require "scripts.actor.enemies.breakable_actor"

local BossDoor = BreakableActor:inherit()

function BossDoor:init(x, y)
    BossDoor.super.init(self, x,y, images.boss_door, 16, 16*5)
    self.name = "button_big_glass"

    self.images_cracked = {
        images.boss_door_cracked,
        images.boss_door,
    }

    self.max_life = 30
    self.life = self.max_life
end

function BossDoor:on_death()
    BossDoor.super.on_death(self)

    game.camera:set_target_offset(1000, 0)
    game.camera.max_x = 76*16

    game:play_cutscene("enter_ceo_office")
end

return BossDoor