require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"
local Guns = require "data.guns"

local ExitSign = Enemy:inherit()

function ExitSign:init(x, y)
    self:init_enemy(x,y, images.exit_sign, 40, 45)
    self.name = "exit_sign"
    self.follow_player = false

    self.life = 12
    self.damage = 0
    self.self_knockback_mult = 0.1

    self.knockback = 0
    
    self.is_pushable = false
	self.is_immune_to_bullets = true
	self.destroy_bullet_on_impact = false
    self.is_knockbackable = false
    self.is_stompable = false
    self.is_touching_player = false

    self.loot = {}
end

function ExitSign:update(dt)
    self.is_touching_player = false

    self:update_enemy(dt)
end

function ExitSign:on_collision(col, other)
	if col.other.is_player then
		self.is_touching_player = true
	end
end

function ExitSign:draw()
    self:draw_enemy()

    love.graphics.print(tostring(self.is_touching_player), self.mid_x + 20, self.mid_y)
end


return ExitSign