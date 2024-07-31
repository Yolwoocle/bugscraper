require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"

local Grasshopper = Enemy:inherit()

function Grasshopper:init(x, y)
    self:init_enemy(x,y, images.grasshopper, 12, 12)
    self.name = "grasshopper"
    self.life = 7
    self.follow_player = false
    
    self.speed = 100
    self.vx = self.speed
    self.friction = 1
    self.friction_x = 1
    self.friction_y = 1
    self.walk_dir_x = random_sample{-1, 1}
    self.is_knockbackable = true

    self.gravity = self.gravity * 0.5

    self.squash_target = 1
    self.squash = 1
    self.stretch_multiplier = 1 / 400
    self.shrear_multiplier = 0.06
    self.landing_squash = 0.7

    self.jump_speed = 300
    -- self.jump_speed = 200

    self.removeme_graph = {}
end

function Grasshopper:update(dt)
    self:update_enemy(dt)
    self.vx = self.speed * self.walk_dir_x

    local squash = 1 + sqr(clamp(math.abs(self.vy) * self.stretch_multiplier, 0, 2))
    self.squash_target = squash
    self.squash = lerp(self.squash, self.squash_target, 0.2)

    self.spr:set_scale(1/self.squash, self.squash)
    self.spr:set_image(ternary(math.abs(self.vy) > 150, images.grasshopper, images.grasshopper_fall))
end

function Grasshopper:draw()    
    love.graphics.push()
    
    -- Courtesy of @clemapfel on Discord
    local rot = math.atan2(self.vy, self.vx)
    love.graphics.translate(self.mid_x, self.mid_y)
    love.graphics.shear(math.tan(rot) * self.shrear_multiplier, 0)
    love.graphics.translate(-self.mid_x, -self.mid_y)

    self:draw_enemy()

    love.graphics.pop() 
end

function Grasshopper:after_collision(col, other)
    if col.type ~= "cross"  then
        if col.normal.y == 0 then
            self.walk_dir_x = col.normal.x
        elseif col.normal.x == 0 then
            self:on_grounded()
        end
    end
end

function Grasshopper:on_grounded()
    self.squash = self.landing_squash
    self.vy = -self.jump_speed
    Audio:play_var("jump_short", 0.2, 1.2, {pitch=0.4})
end

return Grasshopper