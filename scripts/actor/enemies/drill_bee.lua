require "scripts.util"
local Fly = require "scripts.actor.enemies.fly"
local Timer = require "scripts.timer"
local sounds = require "data.sounds"
local images = require "data.images"

local DrillBee = Fly:inherit()
	
function DrillBee:init(x, y, spr)
    self:init_fly(x,y, spr or images.drill_bee, 14, 16)
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
    self.friction_x = 0.8
    self.friction_y = 0.8

    self.target_y = game.level.cabin_rect.ay + BW*4
    self.attack_radius = 16
    self.phase = "flying"

    self.gravity = 0
    self.friction_y = self.friction_x

    self.telegraph_oy = 16
    self.telegraph_timer = Timer:new(0.5)
    self.stuck_timer = Timer:new(5.0)
    
    self.img_normal = images.drill_bee
    self.img_stuck = images.drill_bee_buried
    self.spr:set_anchor(SPRITE_ANCHOR_CENTER_CENTER)

    self.stuck_spr_oy = 8
    -- self.anim_frame_len = 0.05
    self.anim_frames = nil
    self.do_squash = true

    -- self.buzz_source = sounds.fly_buzz.source:clone()
    -- self.buzz_source:seek(random_range(0, self.buzz_source:getDuration()))
    -- self.buzz_is_started = false

    self.t = 0
end


function DrillBee:update(dt)
    local nearest_player = self:get_nearest_player()
    if nearest_player and self.phase == "flying" then
        if math.abs(self.x - nearest_player.x) <= self.attack_radius then
            self.phase = "telegraph"
            self.telegraph_timer:start()
        end
    end

    self:update_phase(dt, nearest_player)
    
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
        self.speed_y = self.speed * 0.5
        target_y = self.target_y - self.telegraph_oy
        
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
        self.spr:set_image(self.img_stuck)
        self.spr:update_offset(0, self.stuck_spr_oy)
        if self.stuck_timer:update(dt) then
            self.phase = "flying"
            self.spr:set_image(self.img_normal)
            self.spr:update_offset(0, 0)
        end
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
            self.stuck_timer:start()
            self.squash = 2
        end
    end
end

return DrillBee