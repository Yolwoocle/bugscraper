require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local images = require "data.images"
local skins = require "data.skins"
local images = require "data.images"
local Prop = require "scripts.actor.enemies.prop"
local Rect = require "scripts.math.rect"
local Segment = require "scripts.math.segment"

local utf8 = require "utf8"

local ElectricArc = Prop:inherit()

function ElectricArc:init(x, y)
    self:init_prop(x, y, images.empty, 1, 1)
    self.name = "electric_arc"

    self.counts_as_enemy = false
    self.arc_damage = 1
    self.cooldown = 0.3

    self.segment = Segment:new(x, y, x+50, y-70)
    self.collides = false
    self.arc_target = nil
    self.hitbox_expand = 2

    self.lightning_points = {}
    self.lightning_min_step = 4
    self.lightning_max_step = 10
    self.lightning_jitter_width = 3
    self.lightning_palette = {
        COL_LIGHT_YELLOW,
        COL_ORANGE,
        COL_YELLOW_ORANGE,
        COL_WHITE,
    }

    self.particle_probability = 0.005

    self.t = 0
end

function ElectricArc:set_arc_target(target)
    self.arc_target = target
end

function ElectricArc:set_segment(ax_or_seg, ay, bx, by)
    local ax = ax_or_seg
    if type(ax_or_seg) ~= "number" then
        ax = ax_or_seg.ax
        ay = ax_or_seg.ay
        bx = ax_or_seg.bx
        by = ax_or_seg.by
    end

    self:set_pos(ax, ay)
    self.segment:set_bounds(ax, ay, bx, by)
end

function ElectricArc:update(dt)
    self:update_prop(dt)
    
    -- self.t = self.t + dt
    -- self:move_to(CANVAS_WIDTH/2 + math.cos(self.t) * 32, CANVAS_HEIGHT/2 + math.sin(self.t) * 32)

    self.segment.ax = self.mid_x
    self.segment.ay = self.mid_y
    if self.arc_target then
        self.segment.bx = self.arc_target.mid_x
        self.segment.by = self.arc_target.mid_y
    end

    self:check_for_collisions()
    self:create_lightning_points()
end

--- Returns whether an actor is considered an enemy or not. 
function ElectricArc:is_my_enemy(actor)
    if not actor.is_actor then
        return false
    end
    if self.arc_target then
        return self.arc_target.is_enemy ~= actor.is_enemy
    end
    return actor.is_player
end

function ElectricArc:check_for_collisions()
    -- NOTE I think that bump.lua has a function that does the same thing  
    self.collides = false
    for _, a in pairs(game.actors) do
        if a ~= self and self:is_my_enemy(a) then
            local collision = Rect:new(a.x, a.y, a.x+a.w, a.y+a.h):expand(self.hitbox_expand):segment_intersection(self.segment)
            if collision then
                self:collide_with_actor(a)
            end
        end
    end
end

function ElectricArc:collide_with_actor(a)
    if a.on_hit_electrictiy then
        a:on_hit_electrictiy()
    end
    if a.is_immune_to_electricity then
        return
    end
    if not a.do_damage then
        return
    end

    local success = a:do_damage(self.arc_damage, self)
    if success then 
        self.collides = true
        a:set_invincibility(self.cooldown)
    end
end

function ElectricArc:draw()
    self:draw_prop()

    self:draw_lightning()
end

function ElectricArc:create_lightning_points()
    self.lightning_points = {}

    local dir_x, dir_y = self.segment:get_direction()
    local normal_x, normal_y = get_orthogonal(dir_x, dir_y)
    local length = self.segment:get_length()

    local t = 0.0
    local i = 1
    local last_x, last_y = self.segment.ax, self.segment.ay
    local color = random_sample(self.lightning_palette)
    while t < length - self.lightning_max_step and i <= 300 do
        local step = random_range(self.lightning_min_step, self.lightning_max_step)
        local jitter_offset = random_neighbor(self.lightning_jitter_width)
        t = t + step
        local new_x = self.segment.ax + dir_x*t + normal_x*jitter_offset 
        local new_y = self.segment.ay + dir_y*t + normal_y*jitter_offset
        
        line_color(color, last_x, last_y, new_x, new_y)
        table.insert(self.lightning_points, {
            color = color,
            line_width = random_range(1, 3),
            segment = Segment:new(last_x, last_y, new_x, new_y)
        })
        if random_range(0, 1) < self.particle_probability then
            Particles:spark(new_x, new_y)
        end

        last_x, last_y = new_x, new_y
        i = i + 1
    end
    table.insert(self.lightning_points, {
        color = color,
        line_width = random_range(1, 3),
        segment = Segment:new(last_x, last_y, self.segment.bx, self.segment.by)
    })
end

function ElectricArc:draw_lightning()
    local old_width = love.graphics.getLineWidth()
    for i, point in pairs(self.lightning_points) do
        love.graphics.setLineWidth(point.line_width) 
        line_color(point.color, point.segment.ax, point.segment.ay, point.segment.bx, point.segment.by)
        i = i + 1
    end

    love.graphics.setLineWidth(old_width)
end

return ElectricArc