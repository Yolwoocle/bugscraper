require "scripts.util"
local Fly = require "scripts.actor.enemies.fly"
local Timer = require "scripts.timer"
local Explosion = require "scripts.actor.enemies.explosion"
local StateMachine = require "scripts.state_machine"
local guns = require "data.guns"
local images = require "data.images"
local Sprite = require "scripts.graphics.sprite"

local Shooter = Fly:inherit()
	
function Shooter:init(x, y)
    Shooter.super.init(self, x,y, images.shooter_normal, 14, 14, false)
    self.name = "shooter"
    self.max_life = 15
    self.life = self.max_life
    
    self.follow_player = false
    self.ai_template = "random_rotate"
    self.spr:set_anchor(SPRITE_ANCHOR_CENTER_CENTER)
    self.anim_frames = nil
    self.do_squash = true

    self.spr_focused = Sprite:new(images.shooter_focused, SPRITE_ANCHOR_CENTER_CENTER)

    self.gun = guns.unlootable.SixBullets:new(self)
    self.score = 10

    self.state_timer = Timer:new(0.0)
    self.state_machine = StateMachine:new({
        normal = {
            enter = function(state)
                self.ai_template = "random_rotate"
                self.state_timer:start(random_range(1.0, 3.0))

                self.spr:set_image(images.shooter_normal)
            end,
            update = function(state, dt)
                if self.state_timer:update(dt) then
                    return "telegraph"
                end
            end
        }, 
            
        telegraph = {
            enter = function(state)
                self.ai_template = nil
                self.state_timer:start(1.0)

                self.spr:set_image(images.shooter_focused_uncharged)
            end,
            update = function(state, dt)
                local ox, oy = random_polar(2), random_polar(2)
                self.spr:update_offset(ox, oy)
                self.spr_focused:update_offset(ox, oy)
                if self.state_timer:update(dt) then
                    return "shoot"    
                end

                local a = self.state_timer.time / self.state_timer.duration
                self.spr_focused:set_color({1, 1, 1, 1-a})
                self.spr_focused:set_scale(self.spr.sx, self.spr.sy)
            end,
            exit = function(state)
                self.spr:update_offset(0, 0)
            end,
            draw = function(state)
                self.spr_focused:draw(self.x, self.y, self.w, self.h)
            end
        }, 

        shoot = {
            enter = function(state)
                self.ai_template = nil
                self.state_timer:start(1.0)

                self.spr:set_image(images.shooter_normal)

                -- local a = random_range(0, pi2)
                local a = 0
                self.gun:shoot(0.0, self, self.mid_x, self.mid_y, math.cos(a), math.sin(a))

                self.offset_scale = 3.0
            end, 
            update = function(state, dt)
                self.offset_scale = lerp(self.offset_scale, 1, 0.3)
                self.spr:set_scale(self.offset_scale, lerp(self.offset_scale, 1, 0.5))
                
                if self.state_timer:update(dt) then
                    self.offset_scale = 1
                    self.spr:set_scale(self.offset_scale)
                    return "normal"
                end
            end
        }
    }, "normal")

    self.t = 0
end

function Shooter:after_collision(col, other)
    if col.type ~= "cross" then
        local new_vx, new_vy = bounce_vector_cardinal(math.cos(self.direction), math.sin(self.direction), col.normal.x, col.normal.y)
        self.direction = math.atan2(new_vy, new_vx)

        self.squash = 1.5
    end
end

function Shooter:update(dt)
    Shooter.super.update(self, dt)
    self.gun:update(dt)

    self.state_machine:update(dt)
end

function Shooter:draw()
    Shooter.super.draw(self) 
    self.state_machine:draw()
end

return Shooter