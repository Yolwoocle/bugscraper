require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"
local Guns = require "data.guns"
local ButtonSmall = require "scripts.actor.enemies.button_small"
local BreakableCrate = require "scripts.actor.enemies.breakable_crate"
local CollisionInfo = require "scripts.physics.collision_info"

local ButtonSmallGlass = BreakableCrate:inherit()

function ButtonSmallGlass:init(x, y)
    ButtonSmallGlass.super.init(self, x, y, images.small_button_crack2, 22, 21)

    self.name = "button_small_glass"

    self.max_life = 10
    self.life = self.max_life

    self.spawned_actor = ButtonSmall
    self.images_cracked = {
        images.small_button_crack0,
        images.small_button_crack2,
    }

    self.damage_screenshake = 0.5
    self.change_break_state_screenshake = 3
    self.change_break_state_num_particles = 10
    self.break_screenshake = 5
    self.break_num_particles = 20
    
    self.sound_fracture = {"glass_fracture"}
    self.sound_break = {"glass_break_weak"}

    self.collision_info = CollisionInfo:new {
        type = COLLISION_TYPE_SEMISOLID,
        is_slidable = true,
    }
end

return ButtonSmallGlass