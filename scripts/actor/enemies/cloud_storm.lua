require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local ElectricArc = require "scripts.actor.enemies.electric_arc"
local images = require "data.images"
local StateMachine = require "scripts.state_machine"
local Timer        = require "scripts.timer"
local Lightning = require "scripts.graphics.lightning"
local Segment = require "scripts.math.segment"

local CloudStorm = Enemy:inherit()
	
function CloudStorm:init(x, y, size)
    size = size or 3
    CloudStorm.super.init(self, x,y, images.cloud_storm, 17, 14, false)
    self.name = "cloud_storm"

    self.is_flying = true
    self.do_stomp_animation = false

    self.speed = random_range(7,13) --10
    self.speed_x = self.speed
    self.speed_y = self.speed

    self.gravity = 0
    self.friction_y = self.friction_x

    self.life = 12
    self.ai_template = "random_rotate_upper"
    self.follow_player = false

    self.arc = ElectricArc:new(self.mid_x, self.mid_y)
    game:new_actor(self.arc)

    self.flip_mode = ENEMY_FLIP_MODE_MANUAL
    self.lightning_angle_offset = 0.0

    self.state_timer = Timer:new(0.0)
    self.state_machine = StateMachine:new({
        wander = {
            enter = function(state)
                self.spr:set_image(images.cloud_storm)
                self.spr:update_offset(0, 0)

                self.ai_template = "random_rotate_upper"
                self.state_timer:start(random_range(1.0, 3.0))
                self.arc:set_active(false)
            end,
            update = function(state, dt)
                if self.state_timer:update(dt) then
                    return "telegraph"
                end
            end
        },
        telegraph = {
            enter = function(state)
                self.spr:set_image(images.cloud_storm_angry)

                self.ai_template = nil
                self.arc:set_active(true)
                self.arc:set_arc_active(false)
                self.state_timer:start(1.0)

                self.lightning_angle_offset = random_neighbor(pi/12)
            end,
            update = function(state, dt)
                Particles:flash(self.mid_x + random_polar(3), self.y + self.h + 4 + random_polar(3), 4, 1)

                self.spr:update_offset(random_neighbor(1), random_neighbor(1))
                if self.state_timer:update(dt) then
                    return "attack"
                end
            end
        },
        attack = {
            enter = function(state)
                self.spr:set_image(images.cloud_storm_angry_attack)

                self.ai_template = nil
                self.arc:set_active(true)
                self.arc:set_arc_active(true)
                self.state_timer:start(0.75)

                self.spr:update_offset(0, 6)
                self.spr_oy = 12

                self.buffer_pal = copy_table_deep(self.arc.lightning.palette)
                self.arc.lightning.palette = {COL_WHITE}
                self.arc.active_arc_min_line_width = 6
                self.arc.active_arc_max_line_width = 12
                self.lightning_anim_timer = Timer:new():start(0.15)

                self.surround_lightning = Lightning:new({
                    min_step_size = 0.4,
                    max_step_size = 0.8,
                    jitter_width = 5,
                    coordinate_mode = LIGHNING_COORDINATE_MODE_POLAR,
                })

                self.is_stompable = false
            end,
            update = function(state, dt)
                Particles:flash(self.mid_x + random_polar(3), self.y + self.h + 4 + random_polar(3))

                local lightning_radius = random_range(6, 10)
                self.surround_lightning:generate(Segment:new(lightning_radius, 0, lightning_radius, pi2))        

                if self.lightning_anim_timer:update(dt) then
                    self.arc.lightning.palette = self.buffer_pal
                    self.arc.active_arc_min_line_width = 1
                    self.arc.active_arc_max_line_width = 3
                end

                self.spr_oy = lerp(self.spr_oy, 0, 0.2)
                self.spr:update_offset(0 + random_polar(3), self.spr_oy + random_polar(3))

                if self.state_timer:update(dt) then
                    return "wander"
                end
            end,
            exit = function(state)
                self.is_stompable = true
            end,
            draw = function(state)
                self.surround_lightning:draw(self.mid_x, self.mid_y)
            end,
        },
    }, "wander")
end

function CloudStorm:after_collision(col, other)
    if col.type ~= "cross" then
        local new_vx, new_vy = bounce_vector_cardinal(math.cos(self.direction), math.sin(self.direction), col.normal.x, col.normal.y)
        self.direction = math.atan2(new_vy, new_vx)
    end
end

function CloudStorm:update(dt)
    CloudStorm.super.update(self, dt)

    self.state_machine:update(dt)
    
    local bounds = game.level.cabin_inner_rect

    local bx = self.mid_x + math.cos(pi/2 + self.lightning_angle_offset) * 1000
    local by = self.mid_y + math.sin(pi/2 + self.lightning_angle_offset) * 1000
    local ax, ay, bx, by = clamp_segment_to_rectangle(Segment:new(self.mid_x, self.mid_y, bx, by), game.level.cabin_inner_rect)
    self.arc:set_segment(ax, ay, bx, by)
end

function CloudStorm:draw()
    CloudStorm.super.draw(self)
    self.state_machine:draw()
end

function CloudStorm:on_death()
    Particles:smoke(self.mid_x, self.mid_y, 15, {COL_MID_GRAY, COL_DARK_GRAY, COL_DARK_GRAY}, 12, 6, 4, layer, fill_mode, params)
end

function CloudStorm:on_removed()
    self.arc:remove()
end

return CloudStorm