require "scripts.util"
local images = require "data.images"
local sounds = require "data.sounds"
local cutscenes = require "data.cutscenes"

local BreakableActor = require "scripts.actor.enemies.breakable_actor"
local Guns = require "data.guns"
local Button = require "scripts.actor.enemies.button_big"
local CollisionInfo = require "scripts.physics.collision_info"

local BreakableWall = BreakableActor:inherit()

function BreakableWall:init(x, y)
    BreakableWall.super.init(self, x,y, images.boss_door, 16, 16*7)
    self.name = "breakable_wall"

    self.images_cracked = {
        images.boss_door_cracked,
        images.boss_door,
    }

    self.max_life = 15
    self.life = self.max_life
end

function BreakableWall:on_death()
    BreakableWall.super.on_death(self)
end

return BreakableWall