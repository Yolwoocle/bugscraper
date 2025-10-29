require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local Fly = require "scripts.actor.enemies.fly"
local sounds = require "data.sounds"
local images = require "data.images"

local Bee = Fly:inherit()
	
local PHASE_CHASE = "chase"
local PHASE_TELEGRAPH = "telegraph"
local PHASE_ATTACK = "attack"

local PHASE_TELEGRAPH_DURATION = 0.4

function Bee:init(x, y)
    Bee.super.init(self, x,y, images.bee_1, 12, 16)
    self.name = "bee"
    self.life = 5

    self.anim_frame_len = 0.05
    self.anim_frames = {images.bee_1, images.bee_2}

    self.phase = PHASE_CHASE
    self.attack_speed = 5000

    self.attack_target = nil
    self.attack_vector_x = 0.0
    self.attack_vector_y = 0.0
    self.current_phase_timer = random_range(1.0, 5.0)

    self.buzz_source = sounds.fly_buzz.source:clone()
    self.buzz_source:setPitch(1.5)

    self.sound_death = "sfx_enemy_kill_general_crush_{01-10}"
    self.sound_stomp = "sfx_enemy_kill_general_crush_{01-10}"

    self.spr:set_anchor(SPRITE_ANCHOR_CENTER_CENTER)
    self.score = 10
end

function Bee:update(dt)
    Bee.super.update(self, dt)
    self:update_phase(dt)

    if self.phase == PHASE_CHASE then
        self:update_phase_chase(dt)
        
    elseif self.phase == PHASE_TELEGRAPH then
        self:update_phase_telegraph(dt)
        
    elseif self.phase == PHASE_ATTACK then
        self:update_phase_attack(dt)
        
    end
end

function Bee:update_phase_chase(dt)
    self.follow_player = true
    self.buzz_source:setPitch(1.5)
end

function Bee:update_phase_telegraph(dt)
    self.buzz_source:setPitch(1)
    self.follow_player = false
    
    self.attack_target = self:get_nearest_player()
    if self.attack_target == nil then
        return
    end
    
    local dir_x = self.attack_target.x - self.x
    local dir_y = self.attack_target.y - self.y
    self.attack_vector_x, self.attack_vector_y = normalize_vect(dir_x, dir_y)
    
    local spr_ox = math.sin(self.t * 30) * self.attack_vector_x * 5
    local spr_oy = math.sin(self.t * 30) * self.attack_vector_y * 5
    self.spr:update_offset(spr_ox, spr_oy)
    Particles:dust(self.mid_x + random_polar(8), self.mid_y + random_polar(8))    
end

function Bee:update_phase_attack(dt)
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

function Bee:update_phase(dt)
    self.current_phase_timer = self.current_phase_timer - dt
    if self.current_phase_timer < 0 then
        if self.phase == PHASE_ATTACK then
            self.phase = PHASE_CHASE
            self.current_phase_timer = random_range(0.5, 3.0)
            
        elseif self.phase == PHASE_CHASE then
            self:play_sound_var("sfx_enemy_bee_attack_{01-05}", 0.1, 1.1)
            self.phase = PHASE_TELEGRAPH
            self.current_phase_timer = PHASE_TELEGRAPH_DURATION
            self.t = 0
            
        elseif self.phase == PHASE_TELEGRAPH then
            self.phase = PHASE_ATTACK
            self.current_phase_timer = random_range(0.3, 0.5)
        end
    end
end

function Bee:draw()
	self:draw_enemy()
    
    -- love.graphics.flrprint(concat(self.phase), self.x, self.y-16)
    -- love.graphics.flrprint(concat(self.attack_target == nil), self.x, self.y-32)
end


function Bee:pause_repeating_sounds() --scotch
    self.buzz_source:setVolume(0)
end
function Bee:play_repeating_sounds()
    self.buzz_source:setVolume(1)
end

function Bee:on_death()
    self.buzz_source:stop()
end

return Bee