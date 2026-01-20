require "scripts.util"
local Enemy                  = require "scripts.actor.enemy"
local sounds                 = require "data.sounds"
local images                 = require "data.images"
local ElectricRays           = require "scripts.actor.enemies.electric_rays"
local StateMachine           = require "scripts.state_machine"
local Timer                  = require "scripts.timer"
local Segment                = require "scripts.math.segment"
local guns                   = require "data.guns"
local TimedSpikes            = require "scripts.actor.enemies.timed_spikes"
local BeeletMinion           = require "scripts.actor.enemies.beelet_minion"
local AnimatedSprite         = require "scripts.graphics.animated_sprite"
local DrillBeeMinion         = require "scripts.actor.enemies.drill_bee_minion"
local CloudDropperProjectile = require "scripts.actor.enemies.cloud_dropper_projectile"
local Larva                  = require "scripts.actor.enemies.larva"
local Beelet                 = require "scripts.actor.enemies.beelet"
local BeeletMinion           = require "scripts.actor.enemies.beelet_minion"
local LarvaProjectile        = require "scripts.actor.enemies.larva_projectile"
local HoneypotLiquid         = require "scripts.actor.enemies.honeypot_liquid"
local HoneyPatch             = require "scripts.actor.enemies.honey_patch"

local HerMajesty             = Enemy:inherit()

function HerMajesty:init(x, y)
    HerMajesty.super.init(self, x, y, images.bee_boss_alt_1, 32, 32)
    self.name = "her_majesty"

    self.is_boss = true
    self.score = 500

    self:set_max_life(150)
    self.is_killed_on_negative_life = false

    self.spr = AnimatedSprite:new({
        normal = { images.bee_boss_alt, 0.05, 2 },
    }, "normal", SPRITE_ANCHOR_CENTER_CENTER)

    self.damage_on_stomp = 10
    self:set_max_life(10*8)

    self:reset_bee()

    self.spikes = {}
    self.minions = {}
    self.max_minions = 10

    self.damaged_player_throw_speed_x = 2000
    self.damaged_player_throw_speed_y = -300
    self.damaged_player_invincibility = 1.0

    self.boss_phase = 1

    local function lerp_to_pos(target_x, target_y, speed, dt) 
        local vx, vy = normalize_vect(target_x - self.x, target_y - self.y)
        self:set_position(self.x + vx * speed * dt, self.y + vy * speed * dt)                

        if dist(self.x, self.y, target_x, target_y) < 4 then
            return true
        end
    end

    self.ai_templates["bounce"] = {
        ready = function(ai)
            self.pong_direction = (pi / 4 + pi / 2 * love.math.random(0, 3)) % pi2
            self.pong_speed = 400
        end,
        update = function(ai, dt)
            self.pong_vx = math.cos(self.pong_direction) * self.pong_speed
            self.pong_vy = math.sin(self.pong_direction) * self.pong_speed

            self.vx = (self.pong_vx or 0)
            self.vy = (self.pong_vy or 0)
        end,
        after_collision = function(ai, col, other)
            if col.type ~= "cross" then
                local s = "metalfootstep_0" .. tostring(love.math.random(0, 4))

                local dx, dy = bounce_vector_cardinal(math.cos(self.pong_direction), math.sin(self.pong_direction),
                    col.normal.x, col.normal.y)
                self.pong_direction = math.atan2(dy, dx)
            end
        end
    }

    self.state_timer = Timer:new(0.0)
    self.state_machine = StateMachine:new({
        wait = {
            enter = function(state)
                self.state_timer:start(0.05)
            end,
            update = function(state, dt)
                if self.state_timer:update(dt) then
                    return "big_wave"
                end
            end,
        },
        
        -------------------------------------------------------

        big_wave = {
            enter = function(state)
                self.gravity = 0

                state.target_x = game.level.cabin_inner_rect.bx - self.w
                state.target_y = CANVAS_HEIGHT / 2
                state.speed = 300
            end,
            update = function(state, dt)
                local reached = lerp_to_pos(state.target_x, state.target_y, state.speed, dt) 

                if reached then
                    return "big_wave_spikes"
                end
            end,
        },

        big_wave_spikes = {
            enter = function(state)
                self:reset_bee()
                self.vx = 0
                self.vy = 0
                self:set_spikes_pattern_big_wave()

                self.is_stompable = true

                state.t = 0

                self.x = game.level.cabin_inner_rect.bx - self.w
                self.y = CANVAS_HEIGHT / 2

                self.is_pushable = false

                self.spawn_timer = Timer:new(2.0):start()

                -- self.player_give_bac_control_timer = Timer:new(0.8):start()
                -- for _, p in pairs(game.players) do
                --     p:apply_force(2500, -3, -1) 
                --     p:set_invincibility(1.5)
                --     p:reset_virtual_controller()
                -- end
            end,
            update = function(state, dt)
                -- if self.player_give_bac_control_timer:update(dt) then
                --     for _, p in pairs(game.players) do
                --         p:set_input_mode(PLAYER_INPUT_MODE_USER)
                --     end
                -- end 
                
                self.spr:update_offset(random_neighbor(2), random_neighbor(2))
                state.t = state.t + dt

                if self.spawn_timer:update(dt) then
                    local closest_player_dist = math.huge
                    local closest_player
                    for _, p in pairs(game.players) do
                        local d = abs(p.x - self.x)
                        if 32 < d and d < closest_player_dist then
                            closest_player_dist = d
                            closest_player = p
                        end
                    end

                    if closest_player then
                        local sx, sy = self.x, self.mid_y + 32
                        -- local dir = get_angle_between_vectors(sx, sy, closest_player.mid_x, closest_player.y)
                        local dir = pi

                        if self.boss_phase >= 2 then
                            local a = create_actor_centered(DrillBeeMinion, sx, sy, {
                                direction = dir
                            })
                            game:new_actor(a)
                            
                            if self.boss_phase >= 3 then
                                local a = create_actor_centered(DrillBeeMinion, sx, sy, {
                                    direction = dir + pi / 6
                                })
                                game:new_actor(a)
        
                                local a = create_actor_centered(DrillBeeMinion, sx, sy, {
                                    direction = dir - pi / 6
                                })
                                game:new_actor(a)
                            end
                        end
                    end

                    self.spawn_timer:start()
                end
            end,
            exit = function(state)
                self.spr:update_offset(0, 0)
                self:set_spikes_off()
            end,
            draw = function(state)
                if self.is_stompable then
                    -- exec_color(ternary((state.t % 0.1) < 0.05, {1,1,1,1}, {1,1,1,0}), function()
                    --     draw_centered(images.bee_boss_shield, self.mid_x, self.mid_y)
                    -- end)
                end
            end,
            on_stomped = function(state, player)
                self.state_machine:set_state("crowd")
            end
        },

        
        -------------------------------------------------------

        crowd = {
            enter = function(state)
                self:reset_bee()
                self.vx = 0
                self.vy = 0

                self.is_stompable = false
                self:set_spikes_off()

                self.gravity = 0
                state.target_x = (game.level.cabin_inner_rect.ax + game.level.cabin_inner_rect.bx) / 2 - self.w / 2
                state.target_y = game.level.cabin_inner_rect.ay + self.h + 32
                state.speed = 300
            end,
            update = function(state, dt)
                local reached = lerp_to_pos(state.target_x, state.target_y, state.speed, dt) 

                if reached then
                    return "crowd_spawn"
                end
            end,
            after_collision = function(state, col, other)
                -- if col.type ~= "cross" and col.normal.y == 1 then
                --     self.state_machine:set_state("crowd_spawn")
                -- end
            end,
        },

        crowd_spawn = {
            enter = function(state)
                self.crowd_timer = Timer:new({ 0.3, 0.6 }):start()

                self.state_timer:start(7.0)
            end,
            update = function(state, dt)
                if self.crowd_timer:update(dt) then
                    self.crowd_timer:start()
                    local sx = random_range(game.level.cabin_inner_rect.ax, game.level.cabin_inner_rect.bx)
                    local a = create_actor_centered(HoneypotLiquid, sx, -32)
                    a.is_affected_by_bounds = false
                    a.is_affected_by_walls = false

                    game:new_actor(a)
                end

                if self.state_timer:update(dt) then
                    return "crowd_wait"
                end
            end,
        },

        crowd_wait = {
            enter = function(state)
                self.state_timer:start(1.0)
            end,
            update = function(state, dt)
                if self.state_timer:update(dt) then
                    self.boss_phase = self.boss_phase + 1

                    return "fainted"
                end
            end,
        },

        -------------------------------------------------------

        fainted = {
            enter = function(state)
                self:reset_bee()
                self:set_spikes_off()
                self.vx = -500
                self.vy = -450

                self.gravity = self.default_gravity
                self.minions = {}
            end,
            update = function(state, dt)
                if self.mid_x < game.level.cabin_inner_rect.ax + 32 then
                    return "fainted_wait"
                end
            end,
        },

        fainted_wait = {
            enter = function(state)
                self.vx = 0
                self.vy = 0
                self.gravity = 0

                self.state_timer:start(1.0)
            end,
            update = function(state, dt)
                if self.state_timer:update(dt) then
                    return "fainted_fall"
                end
            end,
        },

        fainted_fall = {
            enter = function(state)
                self.vx = 0
                self.vy = 0
                self.gravity = self.default_gravity
            end,
            update = function(state, dt)
            end,
            after_collision = function(state, col, other)
                if col.type ~= "cross" and col.normal.y == -1 then
                    self.state_machine:set_state("fainted_linger")
                end
            end
        },

        fainted_linger = {
            enter = function(state)
                self.vx = 0
                self.vy = 0

                game:screenshake(6)
                self:set_spike_waves(0)
                self:play_sound_var("sfx_boss_majesty_thwomp_impact_{01-03}", 0.1, 1.1)

                self.minion_timer = Timer:new(1.0):start()
                self.minion_amnt = 12

                self.fainted_timer = Timer:new(15.0):start()

                -- for _, p in pairs(game.players) do
                --     p:apply_force(2500, ternary(p.mid_x < CANVAS_CENTER[1], -1, 1) * 3, -1) 
                -- end

                local ix = game.level.cabin_inner_rect.ax
                while ix < game.level.cabin_inner_rect.bx do
                    local enemy = create_actor_centered(
                        HoneyPatch,
                        ix,
                        game.level.cabin_inner_rect.ay,
                        {
                            wait_range = {0.1, 0.1 + 0.3}
                        }
                    )

                    enemy.vx = random_neighbor(0)
                    enemy.vy = -300
                    game:new_actor(enemy)

                    table.insert(self.minions, enemy)
                    
                    ix = ix + random_range(16, 128)
                end
            end,
            update = function(state, dt)
                if self.fainted_timer:get_time_left() < 2.0 then
                    self.spr:set_color((self.t % 0.1 < 0.05) and COL_ORANGE or COL_WHITE)
                elseif self.fainted_timer:get_time_left() < 5.0 then
                    self.spr:set_color((self.t % 0.2 < 0.1) and COL_ORANGE or COL_WHITE)
                end

                if self.fainted_timer:update(dt) then
                    return "big_wave"
                end
            end,
            after_collision = function(state, col, other)
            end,
            on_stomped = function(state, player)
                self.state_machine:set_state("big_wave")
            end,
            exit = function(state)
                for _, a in pairs(self.minions) do
                    a:kill()
                end
                for _, a in pairs(game.actors) do
                    if a.name == "larva" then
                        a:kill()
                    end
                end

                self.spr:set_color(COL_WHITE)

                self:set_spikes_off()
            end
        },

    }, "wait")
end

function HerMajesty:reset_bee()
    self.stomps = math.huge
    self.is_stompable = true

    self.self_knockback_mult = 0.0

    self.destroy_bullet_on_impact = false
    self.is_bouncy_to_bullets = true
    self.is_immune_to_bullets = true


    self.def_friction_x = self.friction_x
    self.def_friction_y = self.friction_y
    self.friction_x = 1
    self.friction_y = 1

    self.attack_radius = 16
    self.thwomp_speed = 100

    self.spr:set_anchor(SPRITE_ANCHOR_CENTER_CENTER)

    self.gravity = 0
    self.follow_player = false

    self.def_target_y = game.level.cabin_rect.ay + BW * 6
end

function HerMajesty:ready()
    HerMajesty.super.ready(self)
    self:spawn_spikes()
end

function HerMajesty:set_state(state_name)
    self.previous_state_name = self.state_machine.current_state_name
    self.state_machine:set_state(state_name)
end

function HerMajesty:update(dt)
    HerMajesty.super.update(self, dt)

    self.state_machine:update(dt)

    for i = #self.minions, 1, -1 do
        local m = self.minions[i]
        if m.is_removed then
            table.remove(self.minions, i)
        end
    end

    self.debug_values[1] = tostring(self.boss_phase)
end

function HerMajesty:draw()
    HerMajesty.super.draw(self)

    self.state_machine:draw()

    if not self.is_stompable then
        draw_centered(images.bee_boss_shield, self.mid_x, self.mid_y)
    end
end

function HerMajesty:on_stomped(player)
    self.state_machine:_call("on_stomped", player)

    game:frameskip(10)
    game:screenshake(8)

    self:set_invincibility(0.5)
    self:set_harmless(0.5)

    Audio:play_var("sfx_boss_majesty_crowd_happy_{01-04}", 0.1, 1.1)
    self:play_sound_var("sfx_boss_majesty_hit_{01-06}", 0.1, 1.1)
    game.level:add_fury(1.5)

    if game.level.elevator and game.level.elevator.cheer_audience then
        game.level.elevator:cheer_audience(2.0)
    end

    -- player:set_invincibility(self.damaged_player_invincibility)
    -- player.vy = self.damaged_player_throw_speed_y
    -- if player.mid_x < CANVAS_WIDTH/2 then
    --     player.vx = self.damaged_player_throw_speed_x
    -- else
    --     player.vx = -self.damaged_player_throw_speed_x
    -- end
end

function HerMajesty:on_negative_life()
    for _, actor in pairs(self.minions) do
        actor:kill()
    end

    for _, actor in pairs(self.spikes) do
        actor:remove()
    end

    game.ambience_player:fade_out("bee_boss_crowd_cheer", 0.4)
    game.level.elevator:cheer_audience(200000000.0)

    self.state_machine:set_state("dying")
end

function HerMajesty:on_death()
end

function HerMajesty:on_damage_player(player, damage)
end

-----------------------------------------------------

function HerMajesty:set_spikes_off()
    for _, spike in pairs(self.spikes) do
        spike.timing_mode = TIMED_SPIKES_TIMING_MODE_MANUAL
        spike.do_circular_timing = false
        spike:force_off()
        spike:freeze()
    end
end

function HerMajesty:set_spikes_pattern_times(t_off, t_telegraph, t_on)
    for _, spike in pairs(self.spikes) do
        spike:set_pattern_times(t_off, t_telegraph, t_on)
    end
end

function HerMajesty:set_spikes_length(length)
    for _, spike in pairs(self.spikes) do
        spike:set_length(length)
    end
end

function HerMajesty:set_spike_waves(direction)
    self:set_spikes_off()
    self:set_spikes_length(32)
    self:set_spikes_looping(true)

    for _, spike in pairs(self.spikes) do
        if spike.orientation == (direction or 0) then
            local t_off, t_tel, t_on = 2.0, 0.4, 0.2
            spike:set_pattern_times(t_off, t_tel, t_on)

            local t = (t_off + t_tel + t_on) - (0.005 * abs(self.mid_x - spike.mid_x))
            spike:set_time_offset(t_off + t_tel + t)
        end
    end
end

function HerMajesty:set_spikes_looping(looping)
    for _, spike in pairs(self.spikes) do
        spike.timing_mode = TIMED_SPIKES_TIMING_MODE_TEMPORAL
        spike.do_circular_timing = looping
    end
end

function HerMajesty:set_spikes_pattern_big_wave()
    self:set_spikes_looping(true)
    self:set_spikes_length(64)
    local t_off, t_tel, t_on = 1, 0.6, 0.1
    local t_total = t_off + t_tel + t_on
    self:set_spikes_pattern_times(t_off, t_tel, t_on)

    local wave_pos = 0

    for _, spike in pairs(self.spikes) do
        if spike.orientation == 0 then
            local t = ((spike.mid_x - game.level.cabin_inner_rect.bx) / 200) + (t_off+t_tel)
            spike:force_off()
            spike:freeze()
 
            spike:standby(t, - math.floor(t / t_total) * t_total)
        end
    end
end

-----------------------------------------------------

function HerMajesty:after_collision(col, other)
    if col.type ~= "cross" then
        self.state_machine:_call("after_collision", col)
    end
end

function HerMajesty:spawn_spikes()
    self.spikes = {}

    local j = 0

    local t_off, t_tel, t_on = 2, 0.75, 0.25
    local t_total = t_off + t_tel + t_on
    local function spawn_spike(x, y, orientation, j)
        local spikes = TimedSpikes:new(x, y, t_off, t_tel, t_on, j * (t_total / 68) * 2, {
            orientation = orientation,
            start_after_standby = false,
            do_circular_timing = false,
        })
        spikes.spike_i = j
        spikes.timing_mode = TIMED_SPIKES_TIMING_MODE_MANUAL
        spikes.z = 2 - j / 100
        -- spikes.debug_values[1] = j
        game:new_actor(spikes)
        table.insert(self.spikes, spikes)
    end
    local spikes

    -- Bottom
    for i = 3, CANVAS_WIDTH / 16 - 4 do
        spawn_spike(i * BW, CANVAS_HEIGHT * 0.85, 0, j)

        if i ~= CANVAS_WIDTH / 16 - 4 then
            j = j + 1
        end
    end
end

return HerMajesty
