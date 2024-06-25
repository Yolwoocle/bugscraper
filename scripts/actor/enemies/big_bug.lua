require "scripts.util"
local Woodlouse = require "scripts.actor.enemies.woodlouse"
local sounds = require "data.sounds"
local images = require "data.images"

local BigBug = Woodlouse:inherit()

function BigBug:init(x, y, spr, w, h)
    self:init_woodlouse(x,y, spr or images.big_bug_1, w or 42, h or 48)
    self.name = "big_bug"
    self.follow_player = false
    
    self.destroy_bullet_on_impact = false
    self.is_bouncy_to_bullets = true
    self.is_immune_to_bullets = true

    self.life = 10
    self.friction_x = 1
    self.speed = 80
    self.walk_dir_x = random_sample{-1, 1}
    self.stomps = 3

    self.anim_frames = {images.big_bug_1, images.big_bug_1}
    self.audio_delay = love.math.random(0.3, 1)
end

function BigBug:update(dt)
    self:update_woodlouse(dt)

    self.debug_values[1] = self.stomps
end

return BigBug
