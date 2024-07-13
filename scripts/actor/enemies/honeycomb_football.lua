require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"

local truncated_ico = require "data.models.truncated_ico"
local Renderer3D = require "scripts.graphics.3d.renderer_3d"
local Object3D = require "scripts.graphics.3d.object_3d"
local Guns = require "data.guns"
local Slug = require "scripts.actor.enemies.slug"
local PongBall = require "scripts.actor.enemies.pong_ball"

local HoneycombFootball = PongBall:inherit()

function HoneycombFootball:init(x, y, spr)
    self:init_snail_shelled(x, y, spr)
end

function HoneycombFootball:init_snail_shelled(x, y, spr)
    self:init_pong_ball(x,y, spr or images.snail_shell_bouncy, 32, 32)
    self.name = "honeycomb_football"

    self.is_flying = true
    self.follow_player = false
    self.do_stomp_animation = false

    self.destroy_bullet_on_impact = false
    self.is_bouncy_to_bullets = true
    self.is_immune_to_bullets = true

    self.sound_death = "snail_shell_crack"
    self.sound_stomp = "snail_shell_crack"

    self.renderer = Renderer3D:new(Object3D:new(truncated_ico))
    self.renderer.object.scale.x = 24
    self.renderer.object.scale.y = 24
    self.renderer.object.scale.z = 24
    self.renderer.object.position.x = 200
    self.renderer.object.position.y = 200
end

function HoneycombFootball:update(dt)
    self:update_snail_shelled(dt)
end
function HoneycombFootball:update_snail_shelled(dt)
    self:update_pong_ball(dt)

    self.renderer.object.rotation.x = self.renderer.object.rotation.x + 1*dt
    self.renderer.object.rotation.y = self.renderer.object.rotation.y + 1*dt
    self.renderer.object.position.x = self.mid_x
    self.renderer.object.position.y = self.mid_y

    self.renderer:update(dt)
end

function HoneycombFootball:draw()
    self:draw_pong_ball()

    self.renderer:draw()
end

function HoneycombFootball:on_death()
    Particles:image(self.mid_x, self.mid_y, 30, images.snail_shell_bouncy_fragment, 13, nil, 0, 10)
    local slug = Slug:new(self.x, self.y)
    slug.vy = -200
    slug.harmless_timer = 0.5
    game:new_actor(slug)
end

return HoneycombFootball