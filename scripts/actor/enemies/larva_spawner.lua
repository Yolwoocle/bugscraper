require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local guns = require "data.guns"
local images = require "data.images"
local Timer = require "scripts.timer"
local Larva = require "scripts.actor.enemies.larva"

local LarvaSpawner = Enemy:inherit()

function LarvaSpawner:init(x, y)
    self:init_enemy(x,y, images.larva_spawner, 20, 24)
    self.name = "larva_spawner"
    self.follow_player = false

    self.life = 60
    
    self.is_pushable = false
    self.is_stompable = false
    self.stomps = math.huge
    self.damage_on_stomp = 5
    self.self_knockback_mult = 0

    self.spawn_larva_timer = Timer:new({1, 2})
    self.spawn_larva_timer:start()
    self.larvae = {}
    self.max_larvae = 6
end

function LarvaSpawner:update(dt)
    self:update_enemy(dt)
    
    if (#self.larvae < self.max_larvae) and not self.spawn_larva_timer.is_active then
        self.spawn_larva_timer:start()
    end
    
    if self.spawn_larva_timer:update(dt) then
        local larva = Larva:new(self.mid_x, self.mid_y)
        larva.loot = {}
        larva.score = 0
        game:new_actor(larva)

        table.insert(self.larvae, larva)
    end

    for i=#self.larvae, 1, -1 do
        if self.larvae[i].is_dead then
            table.remove(self.larvae, i)
        end
    end
end

return LarvaSpawner
