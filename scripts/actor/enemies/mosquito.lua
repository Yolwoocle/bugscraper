require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local Fly = require "scripts.actor.enemies.fly"
local sounds = require "data.sounds"
local images = require "data.images"

local Mosquito = Fly:inherit()
	
local PHASE_CHASE = "chase"
local PHASE_TELEGRAPH = "telegraph"
local PHASE_ATTACK = "attack"

local PHASE_TELEGRAPH_DURATION = 0.4

function Mosquito:init(x, y)
    self:init_fly(x,y, images.mosquito1)
    self.name = "mosquito"
    self.life = 5

    self.anim_frame_len = 0.05
    self.anim_frames = {images.mosquito1, images.mosquito2}

    self.phase = PHASE_CHASE
    self.attack_speed = 5000

    self.attack_target = nil
    self.attack_vector_x = 0.0
    self.attack_vector_y = 0.0
    self.current_phase_timer = random_range(0.0, 5.0)

    self.buzz_source = sounds.fly_buzz.source:clone()
    self.buzz_source:setPitch(1.5)

    self.t = 0
end

function Mosquito:update(dt)
    self:update_fly(dt)
    self:update_phase(dt)

    self.t = self.t + dt

    if self.phase == PHASE_CHASE then
        self:update_phase_chase(dt)
        
    elseif self.phase == PHASE_TELEGRAPH then
        self:update_phase_telegraph(dt)
        
    elseif self.phase == PHASE_ATTACK then
        self:update_phase_attack(dt)
        
    end
end

function Mosquito:update_phase_chase(dt)
    self.follow_player = true
    self.buzz_source:setPitch(1.5)
end

function Mosquito:update_phase_telegraph(dt)
    self.buzz_source:setPitch(1)
    self.follow_player = false
    
    self.attack_target = self:get_nearest_player()
    if self.attack_target == nil then
        return
    end
    
    local dir_x = self.attack_target.x - self.x
    local dir_y = self.attack_target.y - self.y
    self.attack_vector_x, self.attack_vector_y = normalize_vect(dir_x, dir_y)
    
    self.spr_ox = math.sin(self.t * 30) * self.attack_vector_x * 5
    self.spr_oy = math.sin(self.t * 30) * self.attack_vector_y * 5
    Particles:dust(self.mid_x + random_polar(8), self.mid_y + random_polar(8))    
end

function Mosquito:update_phase_attack(dt)
    local target = self.attack_target
    if target == nil then
        return
    end
    self.buzz_source:setPitch(2)
    self.follow_player = false
    self.vx = self.vx + self.attack_vector_x * dt * self.attack_speed
    self.vy = self.vy + self.attack_vector_y * dt * self.attack_speed
    
    Particles:dust(self.mid_x, self.mid_y)
end

function Mosquito:update_phase(dt)
    self.current_phase_timer = self.current_phase_timer - dt
    if self.current_phase_timer < 0 then
        if self.phase == PHASE_ATTACK then
            self.phase = PHASE_CHASE
            self.current_phase_timer = random_range(0.5, 3.0)
            
        elseif self.phase == PHASE_CHASE then
            self.phase = PHASE_TELEGRAPH
            self.current_phase_timer = PHASE_TELEGRAPH_DURATION
            self.t = 0
            
        elseif self.phase == PHASE_TELEGRAPH then
            self.phase = PHASE_ATTACK
            self.current_phase_timer = random_range(0.3, 0.5)
        end
    end
end

function Mosquito:draw()
	self:draw_enemy()
    
    -- love.graphics.print(concat(self.phase), self.x, self.y-16)
    -- love.graphics.print(concat(self.attack_target == nil), self.x, self.y-32)
end

return Mosquito