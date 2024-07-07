require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local images = require "data.images"
local skins = require "data.skins"
local images = require "data.images"
local Prop = require "scripts.actor.enemies.prop"
local Rect = require "scripts.math.rect"
local Segment = require "scripts.math.segment"
local Lightning = require "scripts.graphics.lightning"
local Timer = require "scripts.timer"

local utf8 = require "utf8"

local ElectricArc = Prop:inherit()

function ElectricArc:init(x, y, is_active, activation_delay)
    self:init_prop(x, y, images.empty, 1, 1)
    self.name = "electric_arc"

    self.counts_as_enemy = false
    self.arc_damage = 1
    self.cooldown = 0.3

    self.segment = Segment:new(x, y, x+50, y-70)
    self.collides = false
    self.arc_target = nil
    self.arc_target_player_n = nil
    self.hitbox_expand = 2

    self.lightning = Lightning:new()
    
    self.is_immune_to_electricity = true
    self.is_arc_active = param(is_active, true)
    self.particle_probability = 0.005

    self.activation_timer = Timer:new(activation_delay or 0)
    if activation_delay then
        self.activation_timer:start()
    end
    self.disable_timer = Timer:new()

    self.t = 0
end

function ElectricArc:set_arc_target(target)
    self.arc_target = target
    if target.is_player then
        self.arc_target_player_n = target.n
    end
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

    -- Timers
    if self.activation_timer:update(dt) then
        self.is_arc_active = true
    end
    if self.disable_timer:update(dt) then
        self:kill()
    end

    self:update_target(dt)

    -- Update segment
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

function ElectricArc:update_target(dt)
    if self.arc_target then
        if (self.arc_target.is_dead or self.arc_target.is_removed) then
            self.is_arc_active = false
            self.arc_target = nil
        end
    else
        if self.arc_target_player_n ~= nil then
            for _, player in pairs(game.players) do
                if (not player.is_dead and not player.is_removed) and player.n == self.arc_target_player_n then
                    self.is_arc_active = true
                    self.arc_target = player
                    break
                end
            end
        end
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
        if a ~= self and a.is_active then
            local collision = a:get_rect(self.hitbox_expand):segment_intersection(self.segment)
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

function ElectricArc:start_disable_timer(duration)
    self.disable_timer:set_duration(duration)
    self.disable_timer:start()
    self.is_arc_active = false
end

function ElectricArc:draw()
    self:draw_prop()

    self.lightning:draw()
end

return ElectricArc