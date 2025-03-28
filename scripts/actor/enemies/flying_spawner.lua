require "scripts.util"
local SinusoidalFlyer = require "scripts.actor.enemies.sinusoidal_flyer"
local StateMachine = require "scripts.state_machine"
local images = require "data.images"
local Timer = require "scripts.timer"
local Larva = require "scripts.actor.enemies.larva"
local LarvaProjectile = require "scripts.actor.enemies.larva_projectile"
local images = require "data.images"
local AnimatedSprite = require "scripts.graphics.animated_sprite"
local Sprite = require "scripts.graphics.sprite"

local FlyingSpawner = SinusoidalFlyer:inherit()

function FlyingSpawner:init(x, y, spr, w, h)
    FlyingSpawner.super.init(self, x, y, spr or images.flying_spawner_big, w or 16, h or 24)
    self.name = "flying_spawner"

    self.spr = AnimatedSprite:new({
        normal = { images.flying_spawner_big, 0.06, 6 }
    }, "normal", SPRITE_ANCHOR_CENTER_CENTER)

    self.flip_mode = ENEMY_FLIP_MODE_MANUAL

    self.life = 15

    self.is_killed_on_negative_life = false

    self.spawn_larva_timer = Timer:new({ 1, 2 })
    self.larva_projectiles = {}
    self.larvae = {}
    self.max_larvae = 6
    self.death_larva_range = {3, 5}

    self.larva_telegraph_spr = AnimatedSprite:new({
        normal = { images.larva_projectile_telegraph, 0.06, 1 }
    }, "normal", SPRITE_ANCHOR_LEFT_TOP)
    self.shoot_telegraph_offsets = {
        {0, 0},  -- top left 
        {-4, 8}, -- left
        {9, 0},  -- top right
        {13, 8}, -- right
    }
    self.shoot_telegraph_ox = 0
    self.shoot_telegraph_oy = 0
    self.shoot_direction = 1
    self.directions = {
        -3*pi/4, -- top left 
        pi + pi/8,      -- left
        -pi/4,   -- top right
        -pi/8,       -- right
    }
    self.flash_timer = Timer:new(2.0)

    self.target_y = (game.level.cabin_inner_rect.ay + game.level.cabin_inner_rect.by) / 2
    self.target_follow_speed_y = 60
    
    self.score = 50

    self.state_machine = StateMachine:new({
        rise = {
            update = function(state, dt)
                self.vy = sign(self.target_y - self.mid_y) * self.target_follow_speed_y
                if math.abs(self.mid_y - self.target_y) < 16 then
                    return "normal"
                end
            end,
        },
        normal = {
            enter = function(state)
                self.spawn_larva_timer:start()
            end,
            update = function(state, dt)
                if (#self.larvae + #self.larva_projectiles < self.max_larvae) and not self.spawn_larva_timer.is_active then
                    self.spawn_larva_timer:start()
                end 

                -- Spawn larvae at regular intervals
                if self.spawn_larva_timer:update(dt) then
                    self:spawn_larva(self.shoot_direction)
                    self.shoot_direction = random_range_int(1, #self.directions)
                end

                -- Larva telegraph
                if self.spawn_larva_timer:get_ratio() > 0.5 then
                    self.larva_telegraph_spr:update_offset(random_neighbor(1), random_neighbor(1))
                else
                    self.larva_telegraph_spr:update_offset(0, 0)
                end
                self.larva_telegraph_spr:set_flip_x(self.shoot_direction <= 2)

                -- Update projectile & larva tables
                for i = #self.larva_projectiles, 1, -1 do
                    local larva_projectile = self.larva_projectiles[i]
                    if larva_projectile.is_dead then
                        table.remove(self.larva_projectiles, i)

                        if larva_projectile.larva then
                            table.insert(self.larvae, larva_projectile.larva)
                        else
                            assert(false, "larva_projectile.larva = nil")
                        end
                    end
                end

                -- Remove dead larva from table
                for i = #self.larvae, 1, -1 do
                    if self.larvae[i].is_dead then
                        table.remove(self.larvae, i)
                    end
                end
            end,
            draw = function(state)
                local ox, oy = unpack(self.shoot_telegraph_offsets[self.shoot_direction])
                if ox and oy then
                    self.larva_telegraph_spr:draw(self.x + ox, self.y + oy)
                end
            end,
        },
        exploding = {
            enter = function(state)
                self.flash_timer:start()
            end,
            update = function(state, dt)
                if self.flash_timer:update(dt) then
                    self:kill()
                end

                local flash = false
                if self.flash_timer:get_ratio() > 0.75 then
                    flash = self.flash_timer.time % 0.1 < 0.05

                elseif self.flash_timer:get_ratio() > 0.5 then
                    flash = self.flash_timer.time % 0.2 < 0.1
                end
                self.spr:set_flashing_white(flash)
                self.larva_telegraph_spr:set_flashing_white(flash)
            end,
            draw = function(state)
                for i=1, #self.shoot_telegraph_offsets do
                    local ox, oy = unpack(self.shoot_telegraph_offsets[i])
                    self.larva_telegraph_spr:set_flip_x(i <= 2)
                    self.larva_telegraph_spr:draw(self.x + ox, self.y + oy)
                end
            end,
        }
    }, "rise")
end

function FlyingSpawner:update(dt)
    FlyingSpawner.super.update(self, dt)

    self.state_machine:update(dt)
end

function FlyingSpawner:on_negative_life()
    self.state_machine:set_state("exploding")
end

function FlyingSpawner:on_death()
    for i = 1, #self.directions do
        self:spawn_larva(i)
    end
end

function FlyingSpawner:spawn_larva(direction)
    direction = direction or self.shoot_direction

    local angle = self.directions[direction]
    local x, y = unpack(self.shoot_telegraph_offsets[direction])
    local larva_projectile = LarvaProjectile:new(self.x + x, self.y + y, angle)
    game:new_actor(larva_projectile)
    
    table.insert(self.larva_projectiles, larva_projectile)
    Particles:star_splash_small(self.x + x, self.y + y)
    Particles:smoke(self.x + x, self.y + y)
end

function FlyingSpawner:draw()
    FlyingSpawner.super.draw(self)
    self.state_machine:draw()
end

return FlyingSpawner
