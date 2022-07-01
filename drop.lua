local Class = require "class"
local Actor = require "actor"
local images = require "images"

local Drop = Actor:inherit()

function Drop:init(player, x, y, w, h, val, vx, vy)
	local x, y = x-w/2, y-h/2
	self:init_actor(x, y, w, h, images.Drop)
	self.is_drop = true
	self.source = player

	self.speed = 300
	self.dir = dir
	
	self.vx = vx or 0
	self.vy = vy or 0

	self.value = val

	self.damage = 2
	self.knockback = 500
end

function Drop:update(dt)
	self:update_actor(dt)
end

function Drop:draw()
	self:draw_actor()
	--gfx.draw(self.sprite, self.x, self.y)
end

function Drop:on_collision(col, other)
	if col.other == self.player then    return   end
	
	if not self.is_removed and col.other.is_player then
		self:collect(other)
	end
end

function Drop:collect(player)
	game.gems = game.gems + self.value
end

return Drop