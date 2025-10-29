require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"

local Larva = Enemy:inherit()
	
function Larva:init(x, y, spr, w, h)
    self:init_larva(x, y, spr, w, h)
end

function Larva:init_larva(x, y, spr, w, h)
    self:init_enemy(x,y, spr or images.larva1, w or 12, h or 6)
    self.name = "larva"
    self.follow_player = false
    
    self.life = random_range(2, 3)
    self.friction_x = 1
    self.speed = 40
    self.walk_dir_x = random_sample{-1, 1}

    -- self.sound_damage = {"larva_damage1", "larva_damage2", "larva_damage3"}
    self.sound_death = "sfx_enemy_kill_general_gore_{01-10}"
    self.sound_stomp = "sfx_enemy_kill_general_gore_{01-10}"
    self.anim_frame_len = 0.2
    self.anim_frames = {images.larva1, images.larva2}
    self.audio_delay = love.math.random(0.3, 1)

	self.score = 10
end

function Larva:update(dt)
    self:update_larva(dt)
end
function Larva:update_larva(dt)
    self:update_enemy(dt)
    self.vx = self.speed * self.walk_dir_x
    
    -- self.audio_delay = self.audio_delay - dt
    -- if self.audio_delay <= 0 then
    -- 	self.audio_delay = love.math.random(0.3, 1.5)
    -- 	self:play_sound({
    -- 		"larva_damage1",
    -- 		"larva_damage2",
    -- 		"larva_damage3",
    -- 		"larva_death"
    -- 	})
    -- end
end

function Larva:after_collision(col, other)
    if col.type ~= "cross" then
        if col.normal.y == 0 then
            self.walk_dir_x = col.normal.x
        end
    end
end

return Larva
