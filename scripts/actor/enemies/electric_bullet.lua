require "scripts.util"
local ElectricArc = require "scripts.actor.enemies.electric_arc"
local Segment = require "scripts.math.segment"

local utf8 = require "utf8"

local ElectricBullet = ElectricArc:inherit()

function ElectricBullet:init(x, y, i)
    ElectricBullet.super.init(self, x, y)
    self.name = "electric_bullet"

    self.remove_on_exit_bounds = true
end

function ElectricBullet:set_properties(x, y, angle, length, speed, bounds)
    self.angle = angle
    self.length = length
    self.speed = speed
    self.bounds = bounds

    local cosa, sina = math.cos(angle), math.sin(angle) 
    self:set_segment(
        x, y,
        x + length * cosa, y + length * sina
    )

    self.arc_vx = speed * cosa
    self.arc_vy = speed * sina
end

function ElectricBullet:update(dt)
    
    local new_segment = Segment:new(
        self.segment.ax + self.arc_vx * dt,
        self.segment.ay + self.arc_vy * dt,
        self.segment.bx + self.arc_vx * dt,
        self.segment.by + self.arc_vy * dt 
    )
    
    self:set_segment(new_segment)
    local ax, ay, bx, by = clamp_segment_to_rectangle(new_segment, self.bounds)
    if ax then
        self:set_segment(ax, ay, bx, by)
    else
        if self.remove_on_exit_bounds then
            self:remove()
        else
            self:set_active(false)
        end
    end

    ElectricBullet.super.update(self, dt)
end

function ElectricBullet:draw()
    ElectricBullet.super.draw(self)

    -- love.graphics.circle("fill", self.x, self.y, 10)
    -- love.graphics.line(self.segment.ax, self.segment.ay, self.segment.bx, self.segment.by)
end

return ElectricBullet
