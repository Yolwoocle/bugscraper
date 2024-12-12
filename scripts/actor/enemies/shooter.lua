require "scripts.util"
local Fly = require "scripts.actor.enemies.fly"
local Timer = require "scripts.timer"
local Explosion = require "scripts.actor.enemies.explosion"
local StateMachine = require "scripts.state_machine"
local guns = require "data.guns"
local images = require "data.images"

local Shooter = Fly:inherit()
	
function Shooter:init(x, y)
    Shooter.super.init(self, x,y, images.boomshroom_1, 20, 20, false)
    self.name = "shooter_todo_changeme"
    self.max_life = 15
    self.life = self.max_life
    
    self.follow_player = false
    self.ai_template = "random_rotate"
    self.spr:set_anchor(SPRITE_ANCHOR_CENTER_CENTER)
    self.anim_frames = nil

    self.gun = guns.unlootable.SixBullets:new(self)

    self.state_timer = Timer:new(0.0)
    self.state_machine = StateMachine:new({
        normal = {
            enter = function(state)
                self.ai_template = "random_rotate"
                self.state_timer:start(random_range(1.0, 3.0))

                self.spr:set_image(images.boomshroom_1)
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

                self.spr:set_image(images.boomshroom_2)
            end,
            update = function(state, dt)
                self.spr:update_offset(random_polar(2), random_polar(2))
                if self.state_timer:update(dt) then
                    return "shoot"    
                end
            end,
            exit = function(state)
                self.spr:update_offset(0, 0)
            end
        }, 

        shoot = {
            enter = function(state)
                self.ai_template = nil
                self.state_timer:start(1.0)

                self.spr:set_image(images.boomshroom_3)

                local a = random_range(0, pi2)
                self.gun:shoot(0.0, self, self.mid_x, self.mid_y, math.cos(a), math.sin(a))
            end, 
            update = function(state, dt)
                if self.state_timer:update(dt) then
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
    end
end

function Shooter:update(dt)
    Shooter.super.update(self, dt)
    self.t = self.t + dt
    self.gun:update(dt)

    self.state_machine:update(dt)
end

function Shooter:draw()
    Shooter.super.draw(self)
    
    rect_color(COL_RED, "line", self.x, self.y, self.w, self.h)
end

return Shooter