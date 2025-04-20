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
end

function ArumTitanMinion:update(dt)
    ArumTitanMinion.super.update(self, dt)

    self.t = self.t + dt
    if self.harmless_timer > 0 and self.t % 0.2 <= 0.1 then
        self.spr:set_color({ 1, 1, 1, 0.5 })
    else
        self.spr:set_color({ 1, 1, 1, 1 })
    end

    self.rotate_angle = self.rotate_angle + dt * self.rotate_speed
    local x = self.parent.mid_x - self.w / 2 + math.cos(self.rotate_angle) * self.rotate_distance
    local y = self.parent.mid_y - self.h / 2 + math.sin(self.rotate_angle) * self.rotate_distance
    self:set_position(x, y)
end

function ArumTitanMinion:spawn_minions()
end

function ArumTitanMinion:on_death()
    local e = random_weighted(self.enemy_spawn_probabilities)

    if e then
        local actor = create_actor_centered(e, self.mid_x, self.mid_y)
        game:new_actor(actor)
    end
end

function ArumTitanMinion:draw()
    ArumTitanMinion.super.draw(self)

    -- rect_color(COL_RED, "line", self.x, self.y, self.w, self.h)
end

return ArumTitanMinion
