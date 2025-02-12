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
    BreakableWall.super.init(self, x,y, images.breakable_wall, 16, 16*7)
    self.name = "breakable_wall"

    self.images_cracked = {
        images.breakable_wall,
    }

    self.change_break_state_particle_image = {
        images.brick_fragment_1,
        images.brick_fragment_2,
        images.brick_fragment_3,
    }
    self.break_particle_image = {
        images.brick_fragment_1,
        images.brick_fragment_2,
        images.brick_fragment_3,
    }
    self.sound_fracture = {}
    self.sound_break = {}
    self.sounds_impact = {}

    self.max_life = 15
    self.life = self.max_life
end

function BreakableWall:on_death()
    BreakableWall.super.on_death(self)
end

return BreakableWall