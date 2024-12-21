require "scripts.util"
local images = require "data.images"
local guns   = require "data.guns"

local truncated_ico = require "data.models.truncated_ico"
local Renderer3D = require "scripts.graphics.3d.renderer_3d"
local Object3D = require "scripts.graphics.3d.object_3d"
local Slug = require "scripts.actor.enemies.slug"
local PongBall = require "scripts.actor.enemies.pong_ball"
local StateMachine = require "scripts.state_machine"
local Timer = require "scripts.timer"
local Explosion = require "scripts.actor.enemies.explosion"

local HoneycombFootball = PongBall:inherit()

function HoneycombFootball:init(x, y, spr)
    self:init_pong_ball(x,y, spr, 32, 32)
    self.name = "honeycomb_football"

    self.is_flying = true
    self.follow_player = false
    self.do_stomp_animation = false

    self.destroy_bullet_on_impact = false
    self.is_bouncy_to_bullets = true
    self.is_immune_to_bullets = true

    self.sound_death = "snail_shell_crack"
    self.sound_stomp = "snail_shell_crack"

    self.stomps = 5
    self.damage_on_stomp = 0.1
    self.is_killed_on_stomp = false

    self.def_ball_scale = 24
    self.object_3d = Object3D:new(truncated_ico)
    self.renderer = Renderer3D:new({self.object_3d})
    self.object_3d.scale:sset(self.def_ball_scale)
    self.object_3d.position.x = 200
    self.object_3d.position.y = 200
	self.ball_lighting_palette = {color(0xf77622), color(0xfeae34), color(0xfee761), color(0xfee761), COL_WHITE}

    self.exploding_timer = Timer:new(2.0)
    self.flash_timer = Timer:new(0.5)

    self.unstompable_timer = Timer:new(1.0)

    self.gun = guns.unlootable.HoneycombFootballGun:new(self)

    self.state_machine = StateMachine:new({
        normal = {
            update = function(state, dt)
            end
        },
        slowdown = {
            enter = function(state)
                self.is_stompable = false 
                self.damage = 0
            end,
            update = function(state, dt)
                self.pong_speed = move_toward(self.pong_speed, 0, 200*dt)
                if dist(self.vx, self.vy) <= 1 then
                    self.state_machine:set_state("exploding")
                end

            end
        },
        exploding = {
            enter = function(state)
                self.pong_speed = 0
                self.vx = 0
                self.vy = 0

                self.exploding_timer:start()
                self.flash_timer:start(0.5)
                self.speed = 0
                self.speed_x = 0
                self.speed_y = 0
                self.damage = 0
                self.weight = 1       
                
                self.exploding_rot_speed = 0

                self.exploding_timer:start()
                self.flash_timer:start(0.5)
            end,
            update = function(state, dt)
                self.exploding_rot_speed = self.exploding_rot_speed + 5*dt
                self.object_3d.rotation.x = self.object_3d.rotation.x + self.exploding_rot_speed*dt
                self.object_3d.rotation.y = self.object_3d.rotation.y + self.exploding_rot_speed*dt

                if self.flash_timer:update(dt) then
                    self.flash_white = not self.flash_white
                    if self.flash_white then
                        local d = math.max(0.05, self.flash_timer:get_duration() * 0.3)
                        self.flash_timer:set_duration(d)
                    end
                    self.flash_timer:start()
                end

                if self.exploding_timer:update(dt) then
                    local explosion = Explosion:new(self.mid_x, self.mid_y, {radius = self.explosion_radius})
                    game:new_actor(explosion)
                    self:kill()
                end

                local time = self.exploding_timer:get_time()
                local duration = self.exploding_timer:get_duration()
                if time <= duration * 0.5 then
                    local s = 1 + (1 - time/(duration*0.5)) * 0.3
                    self.object_3d.scale:sset(self.def_ball_scale * s)
                end
            end,
        }
    }, "normal")

    self:update_renderer(0)
end

function HoneycombFootball:update(dt)
    self.super.update(self, dt)

    self:update_renderer(dt)

    self.state_machine:update(dt)
end

function HoneycombFootball:update_renderer(dt)
    self.object_3d.rotation.x = self.object_3d.rotation.x + (self.vx / 50)*dt
    self.object_3d.rotation.y = self.object_3d.rotation.y + (self.vy / 50)*dt
    self.object_3d.position.x = self.mid_x
    self.object_3d.position.y = self.mid_y

    if self.unstompable_timer:update(dt) then
        self.is_stompable = true
        self.damage = 1
    end

    if self:is_flashing_white() then
        self.renderer.lighting_palette = {COL_WHITE}
        self.renderer.line_color = COL_WHITE
    else
        self.renderer.lighting_palette = self.ball_lighting_palette
        self.renderer.line_color = COL_BLACK_BLUE
    end
    self.renderer:update(dt)
end

function HoneycombFootball:on_stomped()
    self.pong_speed = self.pong_speed + 60

    self.unstompable_timer:start()
    self.is_stompable = false
    self.damage = 0
    if math.sin(self.pong_direction) < 0 then
        self.pong_direction = math.atan2(math.abs(math.sin(self.pong_direction)), math.cos(self.pong_direction))
    end
end

function HoneycombFootball:draw()
    self:draw_pong_ball()
    self.renderer:draw()
end

function HoneycombFootball:on_death()
    Particles:image(self.mid_x, self.mid_y, 30, images.snail_shell_bouncy_fragment, 13, nil, 0, 10)

    local a = random_range(0, pi2)
    self.gun:shoot(0, self, self.mid_x, self.mid_y, math.cos(a), math.sin(a))
end

function HoneycombFootball:on_stomp_killed()
    self.state_machine:set_state("slowdown")
end

return HoneycombFootball