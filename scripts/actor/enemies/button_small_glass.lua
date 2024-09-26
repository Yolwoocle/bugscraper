require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"
local Guns = require "data.guns"
local ButtonSmall = require "scripts.actor.enemies.button_small"
local ButtonBigGlass = require "scripts.actor.enemies.button_big_glass"

local ButtonSmallGlass = ButtonBigGlass:inherit()

function ButtonSmallGlass:init(x, y)
    self:init_button_big_glass(x, y)

    self.name = "button_small_glass"

    self.max_life = 10
    self.life = self.max_life

    self.spawned_button = ButtonSmall
    self.images_cracked = {
        [0] = images.small_button_crack0,
        [1] = images.small_button_crack2,
    }
    self.number_of_break_states = 1

    self.damage_screenshake = 0.5
    self.change_break_state_screenshake = 3
    self.change_break_state_num_particles = 10
    self.break_screenshake = 5
    self.break_num_particles = 20
    
    self.sound_fracture = "glass_fracture"
    self.sound_break = "glass_break_weak"

    self:set_image(images.small_button_crack2)
    self:set_dimensions(22, 21)
end

return ButtonSmallGlass