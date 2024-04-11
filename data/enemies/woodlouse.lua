require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"

local Woodlouse = Enemy:inherit()

function Woodlouse:init(x, y, spr, w, h)
    self:init_enemy(x,y, spr or images.woodlouse_1, w or 20, h or 14)
    self.name = "woodlouse"
    self.follow_player = false
    
    self.destroy_bullet_on_impact = false
    self.is_bouncy_to_bullets = true
    self.is_immune_to_bullets = true

    self.life = 10
    self.friction_x = 1
    self.speed = 40
    self.walk_dir_x = random_sample{-1, 1}

    -- self.sound_damage = {"larva_damage1", "larva_damage2", "larva_damage3"}
    -- self.sound_death = "larva_death"
    -- self.anim_frame_len = 0.2
    self.anim_frames = {images.woodlouse_1, images.woodlouse_2}
    self.audio_delay = love.math.random(0.3, 1)
end

function Woodlouse:update(dt)
    self:update_enemy(dt)
    self.vx = self.speed * self.walk_dir_x
end

function Woodlouse:after_collision(col, other)
    if other.is_solid then
        if col.normal.y == 0 then
            self.walk_dir_x = col.normal.x
        end
    end
end

return Woodlouse
