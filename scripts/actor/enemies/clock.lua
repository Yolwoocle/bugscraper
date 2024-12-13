require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local images = require "data.images"
local Prop = require "scripts.actor.enemies.prop"
local CollisionInfo = require "scripts.physics.collision_info"

local utf8 = require "utf8"

local Clock = Prop:inherit()

function Clock:init(x, y)
    Clock.super.init(self, x, y, images.clock, 1, 1)
    self.name = "clock"    

    self.collision_info = CollisionInfo:new({enabled = false})
    self.datetime = os.date("*t")
    self.spr:set_anchor(SPRITE_ANCHOR_CENTER_CENTER)
    
    self.hours_arrow_size = 4
    self.minutes_arrow_size = 7
    self.seconds_arrow_size = 6 

    self.hours_arrow_color = COL_DARK_GRAY
    self.minutes_arrow_color = COL_DARK_GRAY
    self.seconds_arrow_color = COL_MID_GRAY

    self.t = 0
end

function Clock:update(dt)
    Clock.super.update(self, dt)

    self.t = self.t + dt
    self.datetime = os.date("*t")
end

function Clock:draw()
	Clock.super.draw(self)
    
    self:draw_arrow(self.datetime.sec / 60, self.seconds_arrow_size, self.seconds_arrow_color)
    self:draw_arrow(self.datetime.hour / 12 + (self.datetime.min / (60 * 12)), self.hours_arrow_size, self.hours_arrow_color)
    self:draw_arrow(self.datetime.min / 60, self.minutes_arrow_size, self.minutes_arrow_color)
end

function Clock:draw_arrow(ratio, length, color)
    exec_color(color, function()
        local ang = ratio*pi2 - pi/2 
        love.graphics.line(self.mid_x, self.mid_y, self.mid_x + math.cos(ang) * length, self.mid_y + math.sin(ang) * length)
    end)
end

return Clock