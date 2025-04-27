require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"
local Loot = require "scripts.actor.loot"
local PoisonCloud = require "scripts.actor.enemies.poison_cloud"
local Explosion = require "scripts.actor.enemies.explosion"
local Larva = require "scripts.actor.enemies.larva"
local Fly = require "scripts.actor.enemies.fly"
local SpikedFly = require "scripts.actor.enemies.spiked_fly"
local Timer = require "scripts.timer"
local StateMachine = require "scripts.state_machine"

local WalkingSlotMachine = Enemy:inherit()

function WalkingSlotMachine:init(x, y, spr, w, h)
    WalkingSlotMachine.super.init(self, x, y, spr or images.walking_slot_machine, w or 40, h or 24)
    self.name = "walking_slot_machine"
    self.follow_player = false

    self.destroy_bullet_on_impact = false
    self.is_bouncy_to_bullets = true
    self.is_immune_to_bullets = true
    self.is_killed_on_stomp = false
    self.is_killed_on_negative_life = false
    
    self:set_max_life(30)
    self.damage_on_stomp = 10
    self.stomps = math.huge

    self.friction_x = 1
    self.speed = 100 + random_neighbor(15)
    self.walk_dir_x = random_sample { -1, 1 }

    self.prizes = {
        { -- Losing pattern (random images)
            {
                image = nil,
                effect = function()
                    local explosion = Explosion:new(self.mid_x, self.mid_y, {radius = self.explosion_radius})
                    game:new_actor(explosion)
                    self:kill()
                end,
            }, 30
        },
        {
            {
                image = images.heart,
                effect = function()
                    self:drop_loot(Loot.Life, {loot_type="life"})
                end,
            }, 5
        },
        {
            {
                image = images.poison_skull,
                effect = function()
                    for i = 1, random_range_int(5, 8) do
                        local spawn_x = clamp(self.mid_x - 10, game.level.cabin_rect.ax, game.level.cabin_rect.bx - 20)
                        local spawn_y = clamp(self.mid_y - 10, game.level.cabin_rect.ay, game.level.cabin_rect.by - 20)
                        local cloud = PoisonCloud:new(spawn_x, spawn_y)
                
                        local d = random_range(0, pi2)
                        local r = random_range(0, 400)
                        cloud.vx = math.cos(d) * r
                        cloud.vy = math.sin(d) * r
                        game:new_actor(cloud)
                    end
                end,
            }, 10
        },
        {
            {
                image = images.heart_empty,
                effect = function()
                    local enemies = {
                        { Larva,       15 },
                        { Fly,         10 },
                        { SpikedFly,   5 },
                    }
            
                    for i = 1, random_range_int(2,4) do
                        local e = random_weighted(enemies)
                        local enemy = create_actor_centered(e, self.mid_x + random_neighbor(5), self.mid_y + random_neighbor(5))
                        game:new_actor(enemy)
                        self:kill()
                    end
                end,
            }, 10
        },
    }
    self.all_images = {}
    for i=1, #self.prizes do
        table.insert(self.all_images, self.prizes[i][1].image)
    end
    shuffle_table(self.all_images)

    self.prize = random_weighted(self.prizes)
    self.number_of_symbols = 0
    self.max_number_of_symbols = 3

    self.score = 10

    self.state_machine = StateMachine:new({
        normal = {
            update = function(state, dt)
                if self.number_of_symbols >= self.max_number_of_symbols then
                    return "exploding"
                end
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

                self.exploding_timer = Timer:new(0.75)
                self.flash_timer = Timer:new(0.05)
                self.exploding_timer:start()
                self.flash_timer:start(0.5)
            end,
            update = function(state, dt)
                if self.flash_timer:update(dt) then
                    self.flash_white = not self.flash_white
                    if self.flash_white then
                        local d = math.max(0.02, self.flash_timer:get_duration() * 0.1)
                        self.flash_timer:set_duration(d)
                    end
                    self.flash_timer:start()
                end

                if self.exploding_timer:update(dt) then                    
                    self.prize.effect()
                    self:kill()
                end

                -- local time = self.exploding_timer:get_time()
                -- local duration = self.exploding_timer:get_duration()
                -- if time <= duration * 0.5 then
                --     local s = 1 + (1 - time/(duration*0.5)) * 0.5
                --     self:set_sprite_scale(s)
                -- else
                --     self:set_sprite_scale(1)
                -- end
            end
        }
    }, "normal")
end

function WalkingSlotMachine:update(dt)
    WalkingSlotMachine.super.update(self, dt)

    self.state_machine:update(dt)

    self.vx = self.speed * self.walk_dir_x
end

function WalkingSlotMachine:draw()
    WalkingSlotMachine.super.draw(self)

    local sym = self.prize.image
    local ox, oy = 12, 5
    if self.walk_dir_x < 0 then
        ox, oy = 5, 5
    end

    for i = 0, self.number_of_symbols - 1 do
        local img = sym
        if not sym then
            img = self.all_images[i+1]
        end
        love.graphics.draw(img, ox + self.x + i * 10, oy + self.y)
    end
end

function WalkingSlotMachine:after_collision(col, other)
    if col.type ~= "cross" then
        if col.normal.y == 0 then
            self.walk_dir_x = col.normal.x
        end
    end
end

function WalkingSlotMachine:on_stomped(player)
    -- self:apply_force(500, random_sample{-1, 1}, -0.5)

    if self.number_of_symbols >= self.max_number_of_symbols then
        return
    end

    self.speed = self.speed + 100

    self.number_of_symbols = self.number_of_symbols + 1
    self.invincible_timer = 0.2
    self.harmless_timer = 0.2
end

return WalkingSlotMachine
