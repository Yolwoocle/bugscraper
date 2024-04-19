require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local Larva = require "scripts.actor.enemies.larva"
local sounds = require "data.sounds"
local images = require "data.images"
local DungBeetle = require "scripts.actor.enemies.dung_beetle"

local Dung = Enemy:inherit()
	
function Dung:init(x, y, spr, w, h)
    self:init_dung(x, y, spr, w, h)
end

function Dung:init_dung(x, y, spr, w, h)
    self:init_enemy(x,y, spr or images.dung_beetle_1, w or 24, h or 30)
    self.name = "dung"
    self.follow_player = true
    
    self.life = math.huge

    self.friction_x = 0.999
    self.speed_x = 5
    self.self_knockback_mult = 0.06
    
    self.is_stompable = false
    self.destroy_bullet_on_impact = false
	self.is_immune_to_bullets = true
    
    local beetle = DungBeetle:new(self.x, self.y - 30)
    game:new_actor(beetle)
    self:set_rider(beetle)

    self.rot_mult = 0.1

    -- self.sound_damage = {"larva_damage1", "larva_damage2", "larva_damage3"}
    -- self.sound_death = "larva_death"
    -- self.anim_frame_len = 0.2
    -- self.anim_frames = {images.larva1, images.larva2}
    self.audio_delay = love.math.random(0.3, 1)
end

function Dung:update(dt)
    self:update_dung_beetle(dt)
end
function Dung:update_dung_beetle(dt)
    self:update_enemy(dt)

    self.rot = self.rot + self.vx * self.rot_mult * dt

    -- self.vx = self.speed * self.walk_dir_x
    
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

function Dung:after_collision(col, other)
    if col.type ~= "cross" then
        if col.normal.y == 0 then
            self.vx = col.normal.x * math.abs(self.vx)
        end
    end
end

function Dung:follow_nearest_player(dt)
	self.target = nil
	if not self.follow_player then
		return
	end

	-- Find closest player
	local nearest_player = self:get_nearest_player()
	if not nearest_player then
		return
	end
	self.target = nearest_player
	
	self.speed_x = self.speed_x or self.speed
	if self.is_flying then    self.speed_y = self.speed_y or self.speed 
	else                      self.speed_y = self.speed_y or 0    end 

	self.vx = self.vx + sign0(nearest_player.x - self.x) * self.speed_x * 0.3
	self.vy = self.vy + sign0(nearest_player.y - self.y) * self.speed_y * 0.3
end

return Dung
