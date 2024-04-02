require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"
local Guns = require "data.guns"

local ExitSign = Enemy:inherit()

function ExitSign:init(x, y)
    self:init_enemy(x,y, images.exit_sign, 40, 45)
    self.name = "exit_sign"
    self.is_exit_sign = true
    
    self.life = 12
    self.damage = 0
    self.self_knockback_mult = 0.1
    
    self.knockback = 0
    
    self.follow_player = false
    self.is_pushable = false
	self.is_immune_to_bullets = true
	self.destroy_bullet_on_impact = false
    self.is_knockbackable = false
    self.is_stompable = false

    self.spring_active = false
    self.spring_stiffness = 3.0
    self.spring_friction = 0.94
    self.default_spring_ideal_length = 2
    self.retracted_spring_ideal_length = 40

    self.spring_vy = 0.0
    self.spring_y = self.default_spring_ideal_length
    self.spring_ideal_length = 0
    self.spring_retract_timer = 0.0

    self.loot = {}
end

function ExitSign:update(dt)
    self.is_touching_player = false

    self.spring_vy = self.spring_vy + (self.spring_ideal_length - self.spring_y) * self.spring_stiffness
    self.spring_vy = self.spring_vy * self.spring_friction
    self.spring_y = self.spring_y + self.spring_vy * dt
    
    if self.spring_retract_timer > 0 then
        self.spring_retract_timer = max(0.0, self.spring_retract_timer - dt)
    else
        self.spring_ideal_length = self.default_spring_ideal_length
    end

    self:update_enemy(dt)
end

function ExitSign:on_collision(col, other)
	if col.other.is_player then
		self.is_touching_player = true
	end
end

function ExitSign:activate(player)
    game:leave_game(player.n)
    game:screenshake(4)
    Particles:ejected_player(player.spr_dead, player.x, player.y)

    self.spring_active = true
    self.spring_retract_timer = 2.0
    self.spring_ideal_length = self.retracted_spring_ideal_length
end

function ExitSign:draw()
    self.spr = images.exit_sign
    self:draw_enemy()
    
    local final_spring_y = math.floor(self.y + self.h + 5 - self.spring_y)
    local max_spring_y = math.floor(self.y + self.h + 8)
    local spring_height = images.spring:getHeight()

    for iy = final_spring_y, max_spring_y - spring_height, spring_height do
        love.graphics.draw(images.spring, math.floor(self.mid_x - images.spring:getWidth()/2), iy)
    end
    if final_spring_y < max_spring_y then
        draw_centered(images.punching_glove, self.mid_x, final_spring_y)
    end

    self.spr = images.exit_sign_front
    self:draw_enemy()

    -- love.graphics.line(self.mid_x, self.y + self.h, self.mid_x, self.y + self.h - self.spring_ideal_length)
    -- for i=1, #self.vals-1 do
    --     local m = 0.6
    --     love.graphics.line(self.mid_x + i*m + 30, self.mid_y - self.vals[i], self.mid_x + (i + 1)*m + 30, self.mid_y - self.vals[i+1])
    -- end
end


return ExitSign