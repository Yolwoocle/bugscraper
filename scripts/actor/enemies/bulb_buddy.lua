require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local Fly = require "scripts.actor.enemies.fly"
local ElectricArc = require "scripts.actor.enemies.electric_arc"
local sounds = require "data.sounds"
local images = require "data.images"

local BulbBuddy = Fly:inherit()

function BulbBuddy:init(x, y, is_child)
    is_child = param(is_child, false)

    self:init_fly(x,y, images.bulb_buddy_1, 18, 24, false)
    self.name = "bulb_buddy"
    self.life = 10

    self.anim_frame_len = 0.05
    self.anim_frames = {images.bulb_buddy_1, images.bulb_buddy_2}

    self.direction = 0
    self.follow_player = false
    self.is_immune_to_electricity = true
    self.is_stompable = true
    self.do_stomp_animation = false
    self.buddy_distance = 5*16

    self.arc_ox = 0
    self.arc_oy = -4
    self.score = 10

    if not is_child then
        local arc = ElectricArc:new(self.x, self.y)
        self.electric_arc = arc
        game:new_actor(arc)
        
        local child = BulbBuddy:new(self.x, self.y, true)
        game:new_actor(child)
        self.child = child
        child.parent = self
        child.electric_arc = arc 
        
        arc.arc_damage = 1
        arc:set_arc_target(child)

        table.insert(self.spawned_actors, arc)
        table.insert(self.spawned_actors, child)
    end

	-- self.sound_damage = "glass_fracture"
	self.sound_damage = {"impactglass_light_001", "impactglass_light_002", "impactglass_light_003", "impactglass_light_004"}
	self.sound_death = "glass_break_weak"
	self.sound_stomp = "glass_break_weak"
end

function BulbBuddy:update(dt)
    self:update_fly(dt)


    self.direction = self.direction + random_sample({-1, 1}) * dt * 3
    
	self.vx = self.vx + math.cos(self.direction) * self.speed
	self.vy = self.vy + math.sin(self.direction) * self.speed

    if random_range(0, 1) < 0.05 then
        Particles:spark(self.mid_x, self.mid_y, 1)
    end
    
    self:remove_dead_parent_or_child()

    if self.child and self.electric_arc then
        self.electric_arc:set_segment(
            self.mid_x + self.arc_ox, self.mid_y + self.arc_oy,
            self.child.mid_x + self.arc_ox, self.child.mid_y + self.arc_oy
        )
    end
    
    if self.electric_arc and self.child == nil and self.parent == nil then
        self.electric_arc:kill()
    end
    
    -- if (self.parent and self.parent.is_dead) or (self.child and self.child.is_dead) then
        --     self:kill()
        -- end
        
    local buddy = param(self.parent, param(self.child, nil))
    if buddy then
        local d = dist(buddy.mid_x, buddy.mid_y, self.mid_x, self.mid_y)
        self:apply_force_from(sign0(self.buddy_distance - d) * 10, buddy)
    end
end

function BulbBuddy:remove_dead_parent_or_child()
    if self.child and self.child.is_dead then
        self.child = nil
    end
    if self.parent and self.parent.is_dead then
        self.parent = nil
    end
end

function BulbBuddy:on_death(damager, reason)
    Particles:image(self.mid_x, self.mid_y, 16, images.glass_shard, self.h)
    Particles:spark(self.mid_x, self.mid_y, 20)
end
    
function BulbBuddy:draw()
	self:draw_enemy()
end



function BulbBuddy:after_collision(col, other)
    -- Pong-like bounce
    if col.type ~= "cross" then
        -- Particles:smoke(col.touch.x, col.touch.y)

        local new_vx, new_vy = bounce_vector_cardinal(math.cos(self.direction), math.sin(self.direction), col.normal.x, col.normal.y)
        self.direction = math.atan2(new_vy, new_vx)
    end
end

return BulbBuddy