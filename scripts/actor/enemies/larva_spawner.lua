require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local guns = require "data.guns"
local images = require "data.images"
local Timer = require "scripts.timer"
local Larva = require "scripts.actor.enemies.larva"

local LarvaSpawner = Enemy:inherit()

function LarvaSpawner:init(x, y)
    self:init_enemy(x,y, images.spiked_fly, 20, 24)
    self.name = "larva_spawner"
    self.follow_player = false

    self.life = 100
    
    self.is_pushable = false
    self.is_stompable = false
    self.stomps = math.huge
    self.damage_on_stomp = 5
    self.self_knockback_mult = 0

    self.spawn_larva_timer = Timer:new({1, 2})
    self.spawn_larva_timer:start()
    self.larvae = {}
end

function LarvaSpawner:update(dt)
    self:update_enemy(dt)
    
    if self.spawn_larva_timer:update(dt) then
        local larva = Larva:new(self.mid_x, self.mid_y)
        larva.loot = {}
        game:new_actor(larva)

        self.spawn_larva_timer:start()
    end
end

function LarvaSpawner:after_collision(col, other)
end

return LarvaSpawner
