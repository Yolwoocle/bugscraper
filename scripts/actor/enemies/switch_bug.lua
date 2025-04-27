require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local PoisonCloud = require "scripts.actor.enemies.poison_cloud"
local sounds = require "data.sounds"
local images = require "data.images"
local Timer = require "scripts.timer"
local StateMachine = require "scripts.state_machine"
local vec2         = require "lib.batteries.vec2"
local mlib = require "lib.mlib.mlib"

local SwitchBug = Enemy:inherit()
	
function SwitchBug:init(x, y, index, siblings, spawner)
    index = index or 5
    siblings = siblings or {}

    self:init_enemy(x,y, images.stink_bug_1, 10, 10)
    self.name = "centipede"
    self.is_flying = true
    self.follow_player = false
    self.life = 10
    self.is_pushable = true
    self.self_knockback_mult = 0.1
    self.is_stompable = true

    if spawner then
        self.next_sibling = spawner
    end
    self.siblings = siblings
    self.switch_bug_index = index
    siblings[index] = self
    if index > 1 then
        local sibling = SwitchBug:new(self.x, self.y, self.switch_bug_index-1, siblings, self)
        game:new_actor(sibling)

        self.prev_sibling = sibling
    elseif index == 1 then
        local master = siblings[#siblings]
        self.prev_sibling = master
        master.next_sibling = self
    end

    self.signal_rad = 0
    self.signal_speed = 80
    self.signal_start = vec2(0, 0)
    self.state_machine = StateMachine:new({
        on = {
            enter = function(state)
                self.spr:set_image(images.fly)
                
                self.is_stompable = true
                
                self.destroy_bullet_on_impact = true
                self.is_bouncy_to_bullets = false
                self.is_immune_to_bullets = false

                self.signal_start = vec2(self.mid_x, self.mid_y)
                self.signal_rad = 0
            end,
            update = function(state, dt)
                self.signal_rad = self.signal_rad + self.signal_speed * dt

                if not (self.next_sibling == self) then
                    if self.signal_rad >= dist(self.signal_start.x, self.signal_start.y, self.next_sibling.mid_x, self.next_sibling.mid_y) then
                        self:switch_next()
                    end
                end
            end,
        },
        off = {
            enter = function(state)
                self.spr:set_image(images.spiked_fly)
                self.is_stompable = false
                
                self.destroy_bullet_on_impact = false
                self.is_bouncy_to_bullets = true
                self.is_immune_to_bullets = true
            end,
            update = function(state)
            end,
        },
    }, "off")
    if self.switch_bug_index == 1 then
        self.state_machine:set_state("on")
    end

    self.speed = random_range(7,13)
    self.speed_x = self.speed
    self.speed_y = self.speed

    self.direction = random_range(0, pi2)

    self.gravity = 0
    self.friction_y = self.friction_x

    self.signal = vec2(self.mid_x, self.mid_y)

    self.spr:set_anchor(SPRITE_ANCHOR_CENTER_CENTER)
end

function SwitchBug:update(dt)
    self:update_enemy(dt)

    self.state_machine:update(dt)

    self.direction = self.direction + random_sample({-1, 1}) * dt * 3
    self:follow_direction(dt*20)      
    
    -- self.debug_values[1] = self.switch_bug_index     
    -- self.debug_values[2] = self.state_machine.current_state_name     
    
    self.spr:set_rotation(self.direction)
end

function SwitchBug:switch_next()
    self.next_sibling.state_machine:set_state("on")
    self.state_machine:set_state("off")
end

function SwitchBug:follow_direction(dt)
    self.vx = self.vx + math.cos(self.direction) * self.speed
	self.vy = self.vy + math.sin(self.direction) * self.speed
end

function SwitchBug:draw()
	self:draw_enemy()

    line_color(ternary((self.state_machine.current_state_name == "on"), COL_CYAN, {1, 1, 1, 0.5}), self.mid_x, self.mid_y, self.next_sibling.mid_x, self.next_sibling.mid_y)
    
    if self.state_machine.current_state_name == "on" then
        circle_color(COL_CYAN, "line", self.signal_start.x, self.signal_start.y, self.signal_rad)

        local type, x1, y1, x2, y2 = mlib.circle.getSegmentIntersection(self.signal_start.x, self.signal_start.y, self.signal_rad, self.mid_x, self.mid_y, self.next_sibling.mid_x, self.next_sibling.mid_y)
        if x1 then
            circle_color(COL_CYAN, "fill", x1, y1, 3.5)
        end
        if x2 then
            circle_color(COL_CYAN, "fill", x2, y2, 3.5)
        end
    end
end

function SwitchBug:after_collision(col, other)
    -- Pong-like bounce
    if col.type ~= "cross" then
        local new_vx, new_vy = bounce_vector_cardinal(math.cos(self.direction), math.sin(self.direction), col.normal.x, col.normal.y)
        self.direction = math.atan2(new_vy, new_vx)
    end
end

function SwitchBug:on_death()
    self.next_sibling.prev_sibling = self.prev_sibling
    self.prev_sibling.next_sibling = self.next_sibling

    if self.state_machine.current_state_name == "on" then
        self:switch_next()
    end
end

return SwitchBug