require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local images = require "data.images"
local StaticProp = require "scripts.actor.enemies.static_prop"

local utf8 = require "utf8"

local JumpingProp = StaticProp:inherit()

function JumpingProp:init(x, y, spr, sound)
    spr = spr or images.upgrade_jar
    JumpingProp.super.init(self, x, y, spr)
    self.name = "jumping_prop"

    self.gravity = self.default_gravity

    self.sound = sound
    self.jump_force = 350
    self.cur_jump_force = self.jump_force

    self.can_jump = true
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
    if col.other.is_player and dist(col.other.vx, col.other.vy) > 100 and self.is_grounded and self.can_jump then
        self.can_jump = false
        self.buffer_jump = true
        self.cur_jump_force = self.jump_force

        if self.sound then
            self:play_sound_var(self.sound, 0.2, 1.2)
        end
    end

    if col.type ~= "cross" and col.normal.y == -1 then
        if self.cur_jump_force > self.jump_force * 0.2 then
            self.buffer_jump = true
            self.cur_jump_force = self.cur_jump_force * 0.5
        else
            self.can_jump = true
        end
    end
end

return JumpingProp
