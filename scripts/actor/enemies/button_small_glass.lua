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
    
    self.sounds_impact = "sfx_weapon_glassjump_{01-06}"
    self.sound_fracture = "sfx_weapon_glassbreak"
    self.sound_break = "sfx_weapon_glassbreak"

    self.collision_info = CollisionInfo:new {
        type = COLLISION_TYPE_SEMISOLID,
        is_slidable = true,
        walk_sound = "sfx_player_footstep_glass_{01-06}",
    }
end

return ButtonSmallGlass