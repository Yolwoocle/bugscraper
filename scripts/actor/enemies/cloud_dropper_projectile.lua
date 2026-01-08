require "scripts.util"
local Fly = require "scripts.actor.enemies.fly"
local Timer = require "scripts.timer"
local Explosion = require "scripts.actor.enemies.explosion"
local StateMachine = require "scripts.state_machine"
local sounds = require "data.sounds"
local images = require "data.images"

local CloudDropperProjectile = Fly:inherit()
	
function CloudDropperProjectile:init(x, y)
    CloudDropperProjectile.super.init(self, x,y, images.cloud_dropper_projectile, 8, 8, false)
    self.name = "cloud_dropper_projectile"
    self.max_life = 1
    self.life = self.max_life
    self.is_stompable = false

    self.do_stomp_animation = false
    self.counts_as_enemy = false
    self.follow_player = false
    self.is_pushable = false

    self.flip_mode = ENEMY_FLIP_MODE_MANUAL
    self.score = 10

    self.loot = {}
    self.ai_template = nil

    self.gravity = self.default_gravity * 0.75
    self.friction_x = 1
    self.friction_y = 1

    self.anim_frames = nil
    self.spr:set_anchor(SPRITE_ANCHOR_CENTER_CENTER)
end

function CloudDropperProjectile:after_collision(col, other)
    if col.type ~= "cross" then
        self:kill()
        return
    end
end

function CloudDropperProjectile:update(dt)
    CloudDropperProjectile.super.update(self, dt)

end

function CloudDropperProjectile:draw()
    CloudDropperProjectile.super.draw(self)
end

return CloudDropperProjectile