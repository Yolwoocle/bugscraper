require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local images = require "data.images"
local images = require "data.images"
local Prop = require "scripts.actor.enemies.prop"
local Rect = require "scripts.math.rect"
local Segment = require "scripts.math.segment"
local Lightning = require "scripts.graphics.lightning"
local Timer = require "scripts.timer"

local utf8 = require "utf8"

local FloorHoleSpawner = Prop:inherit()

function FloorHoleSpawner:init(x, y)
    FloorHoleSpawner.super.init(self, x, y, images.empty, 1, 1)
    self.name = "floor_hole_spawner"

    self.counts_as_enemy = false
    self.pattern_x = 3
    self.pattern_y = 15
    self.pattern_ox = 0
    self.pattern_x_direction = 1
    self.floor_width = 24
    self.hole_pattern = {2, 4}
    self.hole_pattern_sum = table_sum(self.hole_pattern)

    self.move_timer = 0.0
    self.move_timer_duration = 0.5
    self.start_timer = Timer:new(5.0):start()
    self.warning_timer = Timer:new(1.0):start()

    for ix = 0, self.floor_width - 1 do
        game.level.map:set_tile(self.pattern_x + ix, self.pattern_y, TILE_FLIP_ON)
    end
end

function FloorHoleSpawner:update(dt)
    FloorHoleSpawner.super.update(self, dt)

    if self.start_timer.is_active then 
        self.start_timer:update(dt)
        if self.warning_timer:update(dt) then
            self.warning_timer:start()
            self:warn()
        end

    else
        self.move_timer = self.move_timer - dt
        if self.move_timer < 0 then
            self.move_timer = self.move_timer + self.move_timer_duration
            self.pattern_ox = (self.pattern_ox + self.pattern_x_direction) % self.hole_pattern_sum
    
            self:update_pattern()
        end
    end

end

function FloorHoleSpawner:warn()
    for ix = 0, self.floor_width - 1 do
        local i = (self.pattern_ox + ix) % self.hole_pattern_sum 
        
        if i < self.hole_pattern[1] then
            Particles:text((self.pattern_x + ix)*16 + 8, (self.pattern_y)*16 + 8, "⚠", COL_ORANGE)
        end
    end 
end

function FloorHoleSpawner:update_pattern()
    local map = game.level.map

    for ix = 0, self.floor_width - 1 do
        local i = (self.pattern_ox + ix) % self.hole_pattern_sum 
        
        map:set_tile(self.pattern_x + ix, self.pattern_y, 
        ternary(i < self.hole_pattern[1], TILE_FLIP_OFF, TILE_FLIP_ON))
    end
end

function FloorHoleSpawner:draw()
end

function FloorHoleSpawner:on_removed()
    for ix = 0, self.floor_width - 1 do
        game.level.map:set_tile(self.pattern_x + ix, self.pattern_y, TILE_METAL)
    end
end

return FloorHoleSpawner
