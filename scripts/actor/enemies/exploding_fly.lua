require "scripts.util"
local Fly = require "scripts.actor.enemies.fly"
local Timer = require "scripts.timer"
local Explosion = require "scripts.actor.enemies.explosion"
local sounds = require "data.sounds"
local images = require "data.images"

local ExplodingFly = Fly:inherit()
	
function ExplodingFly:init(x, y, spr)
    self:init_fly(x,y, spr or images.drill_bee, 14, 16)
    self.name = "exploding_fly"
    self.life = 15
    
    self.kill_when_negative_life = false

    self.state = "normal" -- "normal", "exploding"
    self.exploding_timer = Timer:new(2.0)
    self.flash_timer = Timer:new(0.5)
    self.loot = {}

    self.t = 0
end

function ExplodingFly:update(dt)
    self:update_fly(dt)
    self.t = self.t + dt

    if self.state == "normal" then
        

    elseif self.state == "exploding" then
        if self.flash_timer:update(dt) then
            self.flash_white = not self.flash_white
            if self.flash_white then
                local d = math.max(0.05, self.flash_timer:get_duration() * 0.3)
                self.flash_timer:set_duration(d)
            end
            self.flash_timer:start()
        end
        if self.exploding_timer:update(dt) then
            local explosion = Explosion:new(self.mid_x, self.mid_y)
            game:new_actor(explosion)
            self:kill()
        end
    end
end

function ExplodingFly:on_negative_life()
    self.state = "exploding"
    self.is_immune_to_bullets = true
    self.destroy_bullet_on_impact = false
    self.speed = 0
    self.speed_x = 0
    self.speed_y = 0
    self.damage = 0

    self.exploding_timer:start()
    self.flash_timer:start(0.5)
end

return ExplodingFly