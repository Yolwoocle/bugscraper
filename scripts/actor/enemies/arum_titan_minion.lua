require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local StateMachine = require "scripts.state_machine"
local AnimatedSprite = require "scripts.graphics.animated_sprite"
local images = require "data.images"

local Mole = require "scripts.actor.enemies.mole"
local CloudEnemy = require "scripts.actor.enemies.cloud_enemy"
local Shooter = require "scripts.actor.enemies.shooter"
local Larva = require "scripts.actor.enemies.larva"
local Fly = require "scripts.actor.enemies.fly"
local SpikedFly = require "scripts.actor.enemies.spiked_fly"
local StinkBug = require "scripts.actor.enemies.stink_bug"
local Boomshroom = require "scripts.actor.enemies.boomshroom"
local Bee = require "scripts.actor.enemies.bee"
local Beelet = require "scripts.actor.enemies.beelet"
local Grasshopper = require "scripts.actor.enemies.grasshopper"
local Explosion = require "scripts.actor.enemies.explosion"
local Timer = require "scripts.timer"

local ArumTitanMinion = Enemy:inherit()

function ArumTitanMinion:init(x, y, parent, params)
    params = params or {}
    local w, h = 16, 16
    self.parent = parent
    self.rotate_distance = params.rotate_distance
    self.rotate_angle = params.rotate_angle
    self.rotate_speed = params.rotate_speed
    x = parent.mid_x - w / 2 + math.cos(self.rotate_angle) * self.rotate_distance
    y = parent.mid_y - h / 2 + math.sin(self.rotate_angle) * self.rotate_distance

    ArumTitanMinion.super.init(self, x, y, images.fly1, w, h)

    self.is_affected_by_bounds = false
    self.is_affected_by_walls = false

    self.name = "arum_titan_minion"
    self.is_flying = true
    self.life = 10

    self.speed = 0
    self.speed_x = self.speed
    self.speed_y = self.speed

    self.gravity = 0
    self.friction_y = self.friction_x
    self.self_knockback_mult = 0

    self.flip_mode = ENEMY_FLIP_MODE_MANUAL

    self.is_killed_on_negative_life = false
    self.is_killed_on_stomp = false
    self.do_stomp_animation = false
    self.counts_as_enemy = true

    self.spr = AnimatedSprite:new({
        normal = { { images.arum_titan_minion }, 0.1 },
        spiked = { { images.arum_titan_minion_spiked }, 0.1 },
    }, "normal", SPRITE_ANCHOR_CENTER_CENTER)
    if random_range(0, 1) < 0.2 then
        self.is_stompable = false
        self.spr:set_animation("spiked")
    end
    self.spr:set_scale(0.7,0.7)

    self.loot = {}
    self.enemy_spawn_probabilities = {
        { nil,         60 },
        { Larva,       10 },
        { Shooter,     10 },
        { Fly,         10 },
        { SpikedFly,   10 },
        { StinkBug,    10 },
        { Bee,         10 },
        { Beelet,      10 },
        { Grasshopper, 10 },
    }

    self.score = 10

    self.t = 0
    self:set_harmless(2.0)

    self.state_machine = StateMachine:new({
        rotate = {
            update = function(state, dt)
                self:rotate_around_parent(dt)
            end
        },

        exploding = {
            enter = function(state)
                self.is_immune_to_bullets = true
                self.is_stompable = false
                self.destroy_bullet_on_impact = false
                self.counts_as_enemy = false -- FIXME: check if this affects the "kills" stat
                self.speed = 0
                self.speed_x = 0
                self.speed_y = 0
                self.damage = 0

                self.exploding_timer = Timer:new(2.0)
                self.flash_timer = Timer:new(0.5)
                self.exploding_timer:start()
                self.flash_timer:start(0.5)

                Audio:play("stomp2")
            end,
            update = function(state, dt)
                self:rotate_around_parent(dt)

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
                    local s = 1 + (1 - time/(duration*0.5)) * 0.5
                    self:set_sprite_scale(s)
                else
                    self:set_sprite_scale(1)
                end
            end
        }
    }, "rotate")
end

function ArumTitanMinion:rotate_around_parent(dt)
    self.rotate_angle = self.rotate_angle + dt * self.rotate_speed
    local x = self.parent.mid_x - self.w / 2 + math.cos(self.rotate_angle) * self.rotate_distance
    local y = self.parent.mid_y - self.h / 2 + math.sin(self.rotate_angle) * self.rotate_distance
    self:set_position(x, y)
end

function ArumTitanMinion:update(dt)
    ArumTitanMinion.super.update(self, dt)

    self.state_machine:update(dt)

    self.t = self.t + dt
    if self.harmless_timer > 0 and self.t % 0.2 <= 0.1 then
        self.spr:set_color({ 1, 1, 1, 0.5 })
    else
        self.spr:set_color({ 1, 1, 1, 1 })
    end
end

function ArumTitanMinion:on_negative_life()
    self.state_machine:set_state("exploding")

    -- local e = random_weighted(self.enemy_spawn_probabilities)

    -- if e then
    --     local actor = create_actor_centered(e, self.mid_x, self.mid_y)
    --     game:new_actor(actor)
    -- end
end

function ArumTitanMinion:on_stomped()
    self.state_machine:set_state("exploding")
end

function ArumTitanMinion:draw()
    line_color({1, 1, 1, 0.5}, self.mid_x, self.mid_y, self.parent.mid_x, self.parent.mid_y)
    ArumTitanMinion.super.draw(self)

    -- rect_color(COL_RED, "line", self.x, self.y, self.w, self.h)
end

return ArumTitanMinion
