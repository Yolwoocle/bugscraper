require "scripts.util"
local Fly = require "scripts.actor.enemies.fly"
local Timer = require "scripts.timer"
local StateMachine = require "scripts.state_machine"
local AnimatedSprite = require "scripts.graphics.animated_sprite"
local sounds = require "data.sounds"
local images = require "data.images"

local Stabee = Fly:inherit()
	
function Stabee:init(x, y, spr)
    Stabee.super.init(self, x,y, spr or images.stabee, 10, 14, false)
    self.normal_h = self.h
    self.stuck_h = 7

    self.name = "stabee"
    self.is_flying = true
    self.life = 10
    
    self.destroy_bullet_on_impact = false
    self.is_bouncy_to_bullets = true
    self.is_immune_to_bullets = true
    self.follow_player = false

    self.speed = random_range(7,13) --10
    self.speed_x = self.speed
    self.speed_y = self.speed*3
    self.friction_x = 0.8
    self.friction_y = 0.8

    self.def_target_y = game.level.cabin_rect.ay + BW*4
    self.attack_radius = 16

    self.gravity = 0
    self.friction_y = self.friction_x
    self.def_friction_y = self.friction_y

    self.telegraph_oy = 16
    self.telegraph_timer = Timer:new(0.5)
    -- self.stuck_timer = Timer:new(5.0)
    self.stuck_timer = Timer:new(1.0)
    
    self.spr = AnimatedSprite:new({
        fly = {images.stabee, 0.04, 2},
        stuck = {images.stabee, 0.1, 2},
    }, "fly", SPRITE_ANCHOR_CENTER_CENTER)

    self.stuck_spr_oy = 8
    -- self.anim_frame_len = 0.05
    self.anim_frames = nil
    self.do_squash = true
    self.score = 10
    
    self.state_machine = StateMachine:new({
        flying = {
            enter = function(state)
                self.spr:set_animation("fly")
                self.spr:update_offset(0, 0)

                self.friction_y = self.def_friction_y
            end,
            update = function(state, dt)
                self.speed_x = self.speed
                self.speed_y = self.speed * 3
            end
        }, 
            
        telegraph = {
            update = function(state, dt)
                self.speed_x = 0
                self.speed_y = self.speed * 0.5
                self.target_y = self.def_target_y - self.telegraph_oy
                if self.telegraph_timer:update(dt) then 
                    self.state_machine:set_state("attack")
                end
            end,
        },
    
        attack = {
            enter = function(state)
                self.spr:update_offset(0, 0)

                Audio:play_var("stabee_attack", 0.1, 1.1)
            end,
            update = function(state, dt)
                self.speed_x = 0
                self.speed_y = self.speed * 4
                self.friction_y = 1
                self.squash = clamp(1/math.abs(self.vy*0.01), 0.5, 1)
                self.target_y = game.level.cabin_rect.by

                Particles:dust(self.mid_x, self.mid_y, nil, 3, nil, 2)
            end,
        },

        stuck = {
            enter = function(state)
                Audio:play_var("sfx_enemy_stabee_land_{01-04}", 0.1, 1.1)
				Audio:play_var("sfx_bullet_bounce_{01-02}", 0.2, 1.2, {pitch = 0.8})

                self.stuck_oscillation_t = 0.0
                self.stuck_oscillation_amplitude = 1.0
                self.spr:set_animation("stuck")

                self.sweat_timer = Timer:new(0.2):start()

                self.is_affected_by_bounds = false
                self.is_affected_by_walls = false
                self:set_position(self.x, self.y + self.stuck_spr_oy)

                local y0 = self.y + self.h - self.stuck_spr_oy
                local vx = random_range(40, 60)

                Particles:dust(self.mid_x, y0, COL_WHITE, 8, nil, 0, {
                    vx1 = -vx, vx2 = -vx, vy1 = 0, vy2 = 0
                })
                Particles:dust(self.mid_x, y0, COL_WHITE, 8, nil, 0, {
                    vx1 = vx, vx2 = vx, vy1 = 0, vy2 = 0
                })
            end,
            update = function(state, dt)
                self.vx = 0
                self.vy = 0
                -- self.spr:update_offset(0, self.stuck_spr_oy)

                self.stuck_oscillation_t = self.stuck_oscillation_t + dt
                self.stuck_oscillation_amplitude = math.max(0.0, self.stuck_timer.time / self.stuck_timer.duration - 0.5)
                self.spr.rot = math.sin(self.stuck_oscillation_t * 100) * pi/10 * self.stuck_oscillation_amplitude

                if self.stuck_timer:update(dt) then
                    self.state_machine:set_state("flying")
                end

                if self.sweat_timer:update(dt) then
                    Particles:sweat(self.x + self.w + 4, self.y - 4)
                end
            end,
            exit = function(state)
                self.is_affected_by_bounds = true
                self.is_affected_by_walls = true
                self:set_position(self.x, self.y - self.stuck_spr_oy)
                Audio:play_var("sfx_enemy_stabee_unstuck_{01-04}", 0.2, 1.2)

                local y0 = self.y + self.h
                local vx = random_range(40, 60)
                Particles:dust(self.mid_x, y0, COL_WHITE, 8, nil, 0, {
                    vx1 = -vx, vx2 = -vx, vy1 = 0, vy2 = 0
                })
                Particles:dust(self.mid_x, y0, COL_WHITE, 8, nil, 0, {
                    vx1 = vx, vx2 = vx, vy1 = 0, vy2 = 0
                })
            end
        },
    }, "flying")

    self.t = 0
end


function Stabee:update(dt)
    local nearest_player = self:get_nearest_player()
    if self.state_machine.current_state_name == "flying" and nearest_player then
        if nearest_player.y > self.y + self.h and math.abs(self.mid_x - nearest_player.mid_x) <= self.attack_radius then
            self.state_machine:set_state("telegraph")
            self.telegraph_timer:start()
        end
    end

    self:update_phase(dt, nearest_player)
    
    -- self.debug_values[1] = self.phase
    
    Stabee.super.update(self, dt)
end

function Stabee:update_phase(dt, nearest_player)
    self.target_x = nil 
    if nearest_player then
        self.target_x = nearest_player.x 
    end
    self.target_y = self.def_target_y
    
    self.state_machine:update(dt)

    self.target = {
        x = self.target_x or self.x,
        y = self.target_y,
    }
end

function Stabee:after_collision(col, other)
    if col.type ~= "cross" then
        if self.state_machine.current_state_name == "attack" then--and col.normal.y == -1 then
            self.state_machine:set_state("stuck")
            self.stuck_timer:start()
            self.squash = 2
        end
    end
end

return Stabee