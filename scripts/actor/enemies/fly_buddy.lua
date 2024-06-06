require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local Fly = require "scripts.actor.enemies.fly"
local ElectricArc = require "scripts.actor.enemies.electric_arc"
local sounds = require "data.sounds"
local images = require "data.images"

local FlyBuddy = Fly:inherit()

function FlyBuddy:init(x, y, is_child)
    is_child = param(is_child, false)

    self:init_fly(x,y, images.spiked_fly)
    self.name = "fly_buddy"
    self.life = 15

    self.anim_frame_len = 0.05
    self.anim_frames = {images.spiked_fly}

    -- self.buzz_source = sounds.fly_buzz.source:clone()
    -- self.buzz_source:setPitch(1.5)

    self.is_immune_to_electricity = true
    self.is_stompable = false
    self.buddy_distance = 8*16

    if not is_child then
        local arc = ElectricArc:new(self.x, self.y)
        self.electric_arc = arc
        game:new_actor(arc)
        
        local child = FlyBuddy:new(self.x + 50, self.y, true)
        game:new_actor(child)
        self.child = child
        child.parent = self
        child.electric_arc = arc 
        
        arc.arc_damage = 1
        arc:set_arc_target(child)
    end
end

function FlyBuddy:update(dt)
    self:update_fly(dt)

    if random_range(0, 1) < 0.05 then
        Particles:spark(self.mid_x, self.mid_y, 1)
    end
    
    self:remove_dead_parent_or_child()

    print_debug("t", self.child, self.electric_arc)
    if self.child and self.electric_arc then
        self.electric_arc:set_segment(
            self.mid_x, self.mid_y,
            self.child.mid_x, self.child.mid_y
        )
    end
    
    if self.electric_arc and self.child == nil and self.parent == nil then
        self.electric_arc:kill()
    end
    
    self.debug_values[1] = ternary(self.child ~= nil, "parent", "child")
    -- if (self.parent and self.parent.is_dead) or (self.child and self.child.is_dead) then
        --     self:kill()
        -- end
        
    local buddy = param(self.parent, param(self.child, nil))
    if buddy and dist(buddy.mid_x, buddy.mid_y, self.mid_x, self.mid_y) <= self.buddy_distance then
        self:apply_force_from(5, buddy)
    end
end

function FlyBuddy:remove_dead_parent_or_child()
    if self.child and self.child.is_dead then
        self.child = nil
    end
    if self.parent and self.parent.is_dead then
        self.parent = nil
    end
end
    
function FlyBuddy:draw()
	self:draw_enemy()
end

function FlyBuddy:pause_repeating_sounds() --scotch
    -- self.buzz_source:setVolume(0)
end
function FlyBuddy:play_repeating_sounds()
    -- self.buzz_source:setVolume(1)
end

function FlyBuddy:on_death()
    self.buzz_source:stop()

    Particles:spark(self.mid_x, self.mid_y, 10)
end

return FlyBuddy