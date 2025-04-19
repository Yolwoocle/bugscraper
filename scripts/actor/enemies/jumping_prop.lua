require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local images = require "data.images"
local Prop = require "scripts.actor.enemies.prop"

local utf8 = require "utf8"

local JumpingProp = Prop:inherit()

function JumpingProp:init(x, y, spr)
    spr = spr or images.upgrade_jar
    JumpingProp.super.init(self, x, y, spr, spr:getWidth(), spr:getHeight())
    self.name = "jumping_prop"
    
    self.gravity = self.default_gravity

    self.life = 10
    self.loot = {}
    self.jump_force = 150
    self.cur_jump_force = self.jump_force

	self.destroy_bullet_on_impact = false
	self.is_immune_to_bullets = true

    
	-- self.sound_damage = "glass_fracture"
	-- self.sound_death = "glass_break_weak"
end

function JumpingProp:update(dt)
    if self.buffer_jump then
        self.buffer_jump = false
        self.vy = -self.cur_jump_force
    end

    JumpingProp.super.update(self, dt)
end

function JumpingProp:draw()
	JumpingProp.super.draw(self)
end

function JumpingProp:on_collision(col, other)
    if col.other.is_player and dist(col.other.vx, col.other.vy) > 100 and self.is_grounded then
        self.buffer_jump = true
        self.cur_jump_force = self.jump_force
    end

    if col.type ~= "cross" and col.normal.y == -1 and self.cur_jump_force > self.jump_force * 0.2 then
        self.buffer_jump = true
        self.cur_jump_force = self.cur_jump_force * 0.5
    end
end

return JumpingProp