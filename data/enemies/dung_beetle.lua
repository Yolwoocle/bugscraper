require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local Larva = require "data.enemies.larva"
local sounds = require "data.sounds"
local images = require "data.images"

local DungBeetle = Larva:inherit()
	
function DungBeetle:init(x, y, spr, w, h)
    self:init_dung_beetle(x, y, spr, w, h)
end

function DungBeetle:init_dung_beetle(x, y, spr, w, h)
    self:init_larva(x,y, spr or images.dung_beetle_1, w or 24, h or 24)
    self.name = "dung_beetle"
    self.follow_player = false
    
    self.life = random_range(2, 3)
    self.friction_x = 1
    self.speed = 40
    self.walk_dir_x = random_sample{-1, 1}

    -- self.sound_damage = {"larva_damage1", "larva_damage2", "larva_damage3"}
    -- self.sound_death = "larva_death"
    -- self.anim_frame_len = 0.2
    -- self.anim_frames = {images.larva1, images.larva2}
    self.audio_delay = love.math.random(0.3, 1)
end

function DungBeetle:update(dt)
    self:update_larva(dt)
end
function DungBeetle:update_larva(dt)
    self:update_enemy(dt)
    self.vx = self.speed * self.walk_dir_x
    
    -- self.audio_delay = self.audio_delay - dt
    -- if self.audio_delay <= 0 then
    -- 	self.audio_delay = love.math.random(0.3, 1.5)
    -- 	audio:play({
    -- 		"larva_damage1",
    -- 		"larva_damage2",
    -- 		"larva_damage3",
    -- 		"larva_death"
    -- 	})
    -- end
end

function DungBeetle:after_collision(col, other)
    if other.is_solid then
        if col.normal.y == 0 then
            self.walk_dir_x = col.normal.x
        end
    end
end

return DungBeetle
