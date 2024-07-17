require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"
local Guns = require "data.guns"
local Timer = require "scripts.timer"
local PongBall = require "scripts.actor.enemies.pong_ball"

local FlyingDung = PongBall:inherit()

function FlyingDung:init(x, y, spawner)
    self:init_flying_dung(x, y, spawner)
end

function FlyingDung:init_flying_dung(x, y, spawner)
    self:init_pong_ball(x,y, images.dung_flying, 16, 16)
    self.name = "flying_dung"
    self.spawner = spawner

    self.life = 4

    self.state = "ponging"
    self.invul = true
    self.invul_timer = Timer:new(1.0)
    self.invul_timer:start()

    self:init_pong(100)
    
    self.is_pushable = false
    self.is_bouncy_to_bullets = false
    self.destroy_bullet_on_impact = true
    self.do_stomp_animation = false

    self.is_stompable = true
    self.is_killed_on_stomp = false
    self.kill_when_negative_life = false

    Particles:smoke(self.mid_x, self.mid_y)
end

function FlyingDung:update(dt)
    self:update_pong_ball(dt)

    if self.invul_timer:update(dt) then
        self.invul = false
    end

    if self.state == "targeting" then
        Particles:smoke(self.mid_x, self.mid_y, 3)
        self:target_spawner()
        
        local d = dist(self.mid_x, self.mid_y, self.spawner.mid_x, self.spawner.mid_y)
        if d <= 16 then
            self:hit_target(self.spawner)
        end
    end
end

function FlyingDung:draw()
    self:draw_pong_ball()
    -- print_outline(nil, nil, self.life, self.x, self.y - 16)
end


function FlyingDung:on_negative_life()
    self:begin_targeting()
end

function FlyingDung:on_stomp_killed(damager)
    self:begin_targeting()
end

function FlyingDung:begin_targeting()
    self.state = "targeting"
    self.is_ponging = false
    Audio:play_var("flying_dung_death", 0, 1.2)

    if self.spawner then
        self:target_spawner()
        self.self_knockback_mult = 0
        game:screenshake(3) 
    end
end

function FlyingDung:target_spawner()
    if not self.spawner then
        return
    end
    
    local a = atan2(self.spawner.mid_y - self.mid_y, self.spawner.mid_x - self.mid_x)
    self.pong_vx = 0
    self.pong_vy = 0
    self.vx = math.cos(a) * self.pong_speed * 3
    self.vy = math.sin(a) * self.pong_speed * 3
end

function FlyingDung:after_collision(col, other)
    self:after_collision_pong_ball(col, other)

    if col.type ~= "cross" then
        if not self.is_ponging then 
            self:kill()
            -- self.is_ponging = true
            -- self.state = "ponging"
            -- self:init_pong()
        end
    end
    if col.other == self.spawner and not self.invul and self.state == "targeting" then
        if col.other.name == "dung_beetle" then
            self:hit_target(col.other)
        end
    end 
end

function FlyingDung:hit_target(target)
    if target.name == "dung_beetle" then
        target:on_hit_flying_dung(self)
    end
    game:screenshake(6)
    game:frameskip(8)

    self:kill()
end

function FlyingDung:on_death()
end

return FlyingDung