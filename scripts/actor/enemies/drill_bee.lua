require "scripts.util"
local Fly = require "scripts.actor.enemies.fly"
local Timer = require "scripts.timer"
local sounds = require "data.sounds"
local images = require "data.images"

local DrillBee = Fly:inherit()
	
function DrillBee:init(x, y, spr)
    self:init_fly(x,y, spr or images.drill_bee, 14, 18)
    self.name = "drill_bee"
    self.is_flying = true
    self.life = 10
    
    self.destroy_bullet_on_impact = false
    self.is_bouncy_to_bullets = true
    self.is_immune_to_bullets = true

    self.follow_player = false

    self.speed = random_range(7,13) --10
    self.speed_x = self.speed
    self.speed_y = self.speed*3

    self.target_y = game.level.cabin_rect.ay + BW*4
    self.attack_radius = 16
    self.phase = "flying"

    self.gravity = 0
    self.friction_y = self.friction_x

    self.anim_frame_len = 0.05
    self.anim_frames = {images.drill_bee, images.drill_bee}
    self.do_squash = false

    self.telegraph_oy = 0
    self.telegraph_timer = Timer:new(0.5)

    self.buzz_source = sounds.fly_buzz.source:clone()
    self.buzz_source:seek(random_range(0, self.buzz_source:getDuration()))
    self.buzz_is_started = false

    self.t = 0
end


function DrillBee:update(dt)
    local nearest_player = self:get_nearest_player()
    if nearest_player and self.phase == "flying" then
        if math.abs(self.x - nearest_player.x) <= self.attack_radius then
            self.phase = "telegraph"
            self.telegraph_oy = 0
            self.telegraph_timer:start()
        end
    end

    -- self:update_phase(dt, nearest_player)
    
    self.t = self.t + dt
    self.spr:update_offset(0, 0)
    self.spr:set_scale(self.t, 1/self.t)
    -- self.squash = self.t
    self.vx = 0
    self.vy = 0
    -- self.squash = 1 + 0.1*(1/math.abs(self.vy))
    -- self.debug_values[1] = self.phase

    self:update_fly(dt)
end

function DrillBee:update_phase(dt, nearest_player)
    local target_x 
    if nearest_player then
        target_x = nearest_player.x 
    end
    local target_y = self.target_y
    if self.phase == "flying" then
        self.speed_x = self.speed
        self.speed_y = self.speed * 3
        
    elseif self.phase == "telegraph" then
        self.speed_x = 0
        self.speed_y = 0
        self.telegraph_oy = move_toward(self.telegraph_oy, -8, 16*dt)
        self.spr:update_offset(nil, self.telegraph_oy)
        if self.telegraph_timer:update(dt) then 
            self.phase = "attack"
            self.spr:update_offset(0, 0)
        end

    elseif self.phase == "attack" then
        self.speed_x = 0
        self.speed_y = self.speed * 4
        self.friction_y = 1
        self.squash = clamp(1/math.abs(self.vy*0.01), 0.5, 1)
        target_y = game.level.cabin_rect.by

    elseif self.phase == "stuck" then
        self.vx = 0
        self.vy = 0
        self.spr:update_offset(0, 12)
    end

    self.target = {
        x = target_x or self.x,
        y = target_y,
    }
end

function DrillBee:after_collision(col, other)
    if col.type ~= "cross" then
        if self.phase == "attack" then--and col.normal.y == -1 then
            self.phase = "stuck"
            self.squash = 2
        end
    end
end

return DrillBee