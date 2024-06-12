require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local images = require "data.images"
local skins = require "data.skins"
local images = require "data.images"
local Prop = require "scripts.actor.enemies.prop"
local Rect = require "scripts.math.rect"
local Segment = require "scripts.math.segment"
local Lightning = require "scripts.graphics.lightning"

local utf8 = require "utf8"

local ElectricArc = Prop:inherit()

function ElectricArc:init(x, y, is_active)
    self:init_prop(x, y, images.empty, 1, 1)
    self.name = "electric_arc"

    self.counts_as_enemy = false
    self.arc_damage = 1
    self.cooldown = 0.3

    self.segment = Segment:new(x, y, x+50, y-70)
    self.collides = false
    self.arc_target = nil
    self.hitbox_expand = 2

    self.lightning = Lightning:new()

    self.is_arc_active = param(is_active, true)
    self.particle_probability = 0.005

    self.t = 0
end

function ElectricArc:set_arc_target(target)
    self.arc_target = target
end

function ElectricArc:set_arc_active(active)
    self.is_arc_active = active
end

function ElectricArc:set_segment(ax_or_seg, ay, bx, by)
    if self.is_removed then
        return 
    end

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

    self.segment.ax = self.mid_x
    self.segment.ay = self.mid_y
    if self.arc_target then
        self.segment.bx = self.arc_target.mid_x
        self.segment.by = self.arc_target.mid_y
    end

    self.lightning.min_line_width = ternary(self.is_arc_active, 1, 0.2)
    self.lightning.max_line_width = ternary(self.is_arc_active, 3, 1)
    self.lightning:generate(self.segment)

    for _, seg in pairs(self.lightning.segments) do 
        if self.is_arc_active and random_range(0, 1) < self.particle_probability then
            Particles:spark(seg.segment.bx, seg.segment.by)
        end
    end

    if self.is_arc_active then
        self:check_for_collisions()
    end
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
    self.collides = false
    for _, a in pairs(game.actors) do
        if a ~= self then
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

    -- Sanity checks
    if a.is_immune_to_electricity then    return    end
    if not self:is_my_enemy(a) then       return    end
    if not a.do_damage then               return    end

    local success = a:do_damage(self.arc_damage, self)
    if success then 
        self.collides = true
        a:set_invincibility(self.cooldown)
    end
end

function ElectricArc:draw()
    self:draw_prop()

    self.lightning:draw()
end

return ElectricArc