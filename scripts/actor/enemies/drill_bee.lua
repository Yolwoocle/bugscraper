require "scripts.util"
local Fly = require "scripts.actor.enemies.fly"
local Timer = require "scripts.timer"
local StateMachine = require "scripts.state_machine"
local Segment = require "scripts.math.segment"
local Rect = require "scripts.math.rect"
local sounds = require "data.sounds"
local images = require "data.images"
local Explosion = require "scripts.actor.enemies.explosion"

local DrillBee = Fly:inherit()
	
function DrillBee:init(x, y, spr)
    self:init_fly(x,y, spr or images.drill_bee, 20, 20)
    self.name = "drill_bee"
    self.is_flying = true
    self.life = 10
    
	self.is_affected_by_bounds = false

    self.destroy_bullet_on_impact = false
    self.is_bouncy_to_bullets = true
    self.is_immune_to_bullets = true
    self.follow_player = false
    self.is_stompable = false

    self.speed = 50
    self.gravity = 0

    self.friction_x = 1.0
    self.friction_y = self.friction_x
    self.def_friction_y = self.friction_y
    
    self.sound_death = nil

    self.spr:set_anchor(SPRITE_ANCHOR_CENTER_CENTER)

    self.stuck_spr_oy = 8
    -- self.anim_frame_len = 0.05
    self.anim_frames = nil
    self.do_squash = true

    self.direction = random_range(0, pi2)
    self.angle_speed = 0.8
    
    self.player_detection_width = 32

    self.telegraph_timer = Timer:new(0.3)
    self.burrow_timer = Timer:new(0.05)
    self.no_attack_timer = Timer:new(1.0)
    self.score = 10

    self.state_machine = StateMachine:new({
        wander = {
            enter = function(state)
                self.is_affected_by_walls = true
                self.drill_target_player = self:get_random_player()
                self.speed = 50
                self.no_attack_timer:start()
            end,
            update = function(state, dt)
                if self.drill_target_player then
                    local target_angle = math.atan2(self.drill_target_player.mid_y - self.mid_y, self.drill_target_player.mid_x - self.mid_x)
                    self.direction = move_toward_angle(self.direction, target_angle, self.angle_speed*dt)
                end
            
                self.spr.rot = self.direction - pi/2
                self.no_attack_timer:update(dt)
            
                -- self.debug_values[1] = self.no_attack_timer.is_active

                local detected, player = self:detect_player_in_range()
                if player and (not self.no_attack_timer.is_active) then
                    self.state_machine:set_state("telegraph")
                    self.drill_target_player = player
                    self.direction = math.atan2(self.drill_target_player.mid_y - self.mid_y, self.drill_target_player.mid_x - self.mid_x)
                end
            end,
            after_collision = function(state, col)
                if col.type ~= "cross" then
                    local new_vx, new_vy = bounce_vector_cardinal(math.cos(self.direction), math.sin(self.direction), col.normal.x, col.normal.y)
                    self.direction = math.atan2(new_vy, new_vx)        
                end
            end,
        },
        telegraph = {
            enter = function(state)
                self.speed = 0

                self.telegraph_timer:start(nil, {
                    on_timeout = function(timer)
                        self.state_machine:set_state("attack")
                    end
                })
            end,
            update = function(state, dt)
                self.spr:update_offset(random_neighbor(5), random_neighbor(5))
                self.telegraph_timer:update(dt)
            end,
        },
        attack = {
            enter = function(state)
                self.is_affected_by_walls = true
                self.speed = 300
            end,
            update = function(state, dt)
                Particles:dust(self.mid_x, self.mid_y)

                if not Rect:new(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT):expand(256, 256):rectangle_intersection(self:get_rect()) then
                    self:kill()
                end
            end,
            after_collision = function(state, col)
                if col.other.collision_info and col.other.collision_info.type == COLLISION_TYPE_SOLID then
                    local explosion = Explosion:new(self.mid_x, self.mid_y, {radius = self.explosion_radius})
                    game:new_actor(explosion)
                    self:kill()
                end
            end,
        },
    }, "wander")
    
    self.t = 0
end

function DrillBee:detect_player_in_range()
    local detection_segment = Segment:new(self.mid_x, self.mid_y, self.mid_x + math.cos(self.direction)*600, self.mid_y + math.sin(self.direction)*600)
    self.detection_segment = detection_segment

    for _, p in pairs(game.players) do
        local coll = p:get_rect(self.player_detection_width):segment_intersection(detection_segment)
        if coll then
            return true, p
        end
    end
    return false
end


function DrillBee:update(dt)
    self.is_touching_wall = false
    self:update_fly(dt)

    self.state_machine:update(dt)
    self.spr.rot = lerp_angle(self.spr.rot, self.direction - pi/2, 0.15)
    -- self.debug_values[1] = self.state_machine.current_state_name

    self.vx = math.cos(self.direction) * self.speed
    self.vy = math.sin(self.direction) * self.speed            
end

function DrillBee:after_collision(col, other)
    self.state_machine:_call("after_collision", col)
end

function DrillBee:draw()
    self:draw_enemy()

    -- if self.drill_normal then
    --     line_color(COL_RED, self.mid_x, self.mid_y, self.mid_x + self.drill_normal.x * 16, self.mid_y + self.drill_normal.y*16)
    --     circle_color(COL_RED, "fill", self.mid_x + self.drill_normal.x * 16, self.mid_y + self.drill_normal.y*16, 3)
    -- end
end

return DrillBee