require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local ElectricArc = require "scripts.actor.enemies.electric_arc"
local images = require "data.images"
local StateMachine = require "scripts.state_machine"
local Timer        = require "scripts.timer"
local Lightning = require "scripts.graphics.lightning"
local Segment = require "scripts.math.segment"

local CloudStormZone = Enemy:inherit()
	
function CloudStormZone:init(x, y, size)
    size = size or 3
    CloudStormZone.super.init(self, x,y, images.cloud_storm, 17, 14, false)
    self.name = "cloud_storm_zone"

    self.is_flying = true
    self.do_stomp_animation = false

    self.speed = random_range(7,13) --10
    self.speed_x = self.speed
    self.speed_y = self.speed

    self.gravity = 0
    self.friction_y = self.friction_x

    self.life = 12

    self.flip_mode = ENEMY_FLIP_MODE_MANUAL
    self.lightning_angle_offset = 0.0

    self.ai_template = "rotate"
    self.follow_player = false
    self.vertical_target_offset = 64
    self.player_detection_range = 32
    self.score = 10

    self.surround_lightning = Lightning:new({
        min_step_size = 0.1,
        max_step_size = 0.2,
        jitter_width = 5,
        coordinate_mode = LIGHNING_COORDINATE_MODE_POLAR,
        do_fill = true,
        polygon_fill = transparent_color(COL_YELLOW, 0.3),
    })
    self.surround_lightning_radius = 64

    self.decorative_lightning = Lightning:new({
        min_step_size = 0.4,
        max_step_size = 0.8,
        jitter_width = 5,
        coordinate_mode = LIGHNING_COORDINATE_MODE_POLAR,
    })

    self.state_timer = Timer:new(0.0)
    self.state_machine = StateMachine:new({
        wander = {
            enter = function(state)
                self.spr:set_image(images.cloud_storm)
                self.spr:update_offset(0, 0)

                self.ai_template = "random_rotate"
                self.state_timer:start(random_range(1.0, 1.5))
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
                self.vx = 0
                self.vy = 0
                self.state_timer:start(1.0)

                self.lightning_angle_offset = random_neighbor(pi/12)

                self.surround_lightning.min_line_width = 0.1
                self.surround_lightning.max_line_width = 1.0
            end,
            update = function(state, dt)
                Particles:flash(self.mid_x + random_polar(3), self.y + self.h + 4 + random_polar(3), 4, 1)

                self.spr:update_offset(random_neighbor(1), random_neighbor(1))
                if self.state_timer:update(dt) then
                    return "attack"
                end

                self.surround_lightning:generate(Segment:new(self.surround_lightning_radius, 0, self.surround_lightning_radius, pi2))        
                
            end,
            draw = function(state)
                self.surround_lightning:draw(self.mid_x, self.mid_y)
            end,
        },
        attack = {
            enter = function(state)
                self.spr:set_image(images.cloud_storm_angry_attack)

                self.ai_template = nil
                self.state_timer:start(0.75)

                self.spr:update_offset(0, 6)
                self.spr_oy = 12

                self.buffer_pal = copy_table_deep(self.surround_lightning.palette)
                self.surround_lightning.palette = {COL_WHITE}
                self.lightning_anim_timer = Timer:new():start(0.15)

                self.surround_lightning.min_line_width = 1.0
                self.surround_lightning.max_line_width = 3.0

                self.is_stompable = true
            end,
            update = function(state, dt)
                Particles:flash(self.mid_x + random_polar(3), self.y + self.h + 4 + random_polar(3))

                local lightning_radius = random_range(6, 10)
                self.decorative_lightning:generate(Segment:new(lightning_radius, 0, lightning_radius, pi2))        

                self.surround_lightning:generate(Segment:new(self.surround_lightning_radius, 0, self.surround_lightning_radius, pi2))        

                if self.lightning_anim_timer:update(dt) then
                    self.surround_lightning.palette = self.buffer_pal
                end

                self.spr_oy = lerp(self.spr_oy, 0, 0.2)
                self.spr:update_offset(0 + random_polar(3), self.spr_oy + random_polar(3))

                if self.state_timer:update(dt) then
                    return "wander"
                end

                for _, player in pairs(game.players) do
                    if actor_mid_distance(self, player) <= self.surround_lightning_radius then
                        player:do_damage(self.damage, self)
                    end
                end
            end,
            exit = function(state)
                self.is_stompable = true
            end,
            draw = function(state)
                self.surround_lightning:draw(self.mid_x, self.mid_y)
                self.decorative_lightning:draw(self.mid_x, self.mid_y)
            end,
        },
    }, "wander")
end

function CloudStormZone:after_collision(col, other)
    if col.type ~= "cross" then
        local new_vx, new_vy = bounce_vector_cardinal(math.cos(self.direction), math.sin(self.direction), col.normal.x, col.normal.y)
        self.direction = math.atan2(new_vy, new_vx)
    end
end

function CloudStormZone:update(dt)
    self.state_machine:update(dt)

    CloudStormZone.super.update(self, dt)
end

function CloudStormZone:draw()
    CloudStormZone.super.draw(self)
    self.state_machine:draw()
end

function CloudStormZone:on_death()
    Particles:smoke(self.mid_x, self.mid_y, 15, {COL_MID_GRAY, COL_DARK_GRAY, COL_DARK_GRAY}, 12, 6, 4, fill_mode, params)
end

function CloudStormZone:on_removed()
end

return CloudStormZone