require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"
local ElectricRays = require "scripts.actor.enemies.electric_rays"
local StateMachine = require "scripts.state_machine"
local Timer = require "scripts.timer"
local Segment = require "scripts.math.segment"
local guns  = require "data.guns"
local TimedSpikes = require "scripts.actor.enemies.timed_spikes"

local BeeBoss = Enemy:inherit()

function BeeBoss:init(x, y)
    self:init_enemy(x,y, images.bee_boss_1, 32, 32)
    self.name = "bee_boss"  --changeme removeme(dont actually)

    -- Parameters 
    self.def_friction_y = self.friction_y
    self.life = 200
    self.is_flying = true
    self.gravity = 0
    self.attack_radius = 16

    self.speed = random_range(7,13) --10
    self.speed_x = self.speed
    self.speed_y = self.speed*3
    self.friction_x = 0.8
    self.friction_y = 0.8

    self.follow_player = false
    self.self_knockback_mult = 0
    self.stomps = math.huge
    self.is_stompable = true
    self.damage_on_stomp = 10
    self.friction_y = self.friction_x
    self.def_target_y = game.level.cabin_rect.ay + BW*7
    self.telegraph_oy = 16    

    self.knockback_x = self.knockback * 3
    self.knockback_y = self.knockback * 1
    self.invul = false
    self.invul_timer = Timer:new(0.5)

    -- Animation
    self.anim_frame_len = 0.05
    self.anim_frames = {images.bee_boss_1, images.bee_boss_2}

    -- Timers
    self.telegraph_timer = Timer:new(0.5)
        
    self.sin_x_value = 0
    self.sin_y_value = 0

    self.speed = 100
    self.state_timer = Timer:new(6)
    self.standby_timer = Timer:new(2)

    self.spikes = {}

    -- State machine
    self.state_machine = StateMachine:new({
        standby = {
            enter = function(state)
            end,
            update = function(state, dt)
                self:spawn_spikes()
                self.state_machine:set_state("thwomp")
            end,
        },

        random = {
            enter = function(state)
            end,
            update = function(state, dt)
                local possible_states = {
                    "spinning_spikes",
                    "thwomp",
                    "timing",
                    "bars",
                    "big_wave",
                }
                return random_sample(possible_states)
            end,
        },
        spinning_spikes = {
            enter = function(state)
                self.follow_player = false
                self.sin_x_value = 0
                self.sin_y_value = 0

                self.state_timer:start(6)
                
                for _, spike in pairs(self.spikes) do
                    spike.timing_mode = TIMED_SPIKES_TIMING_MODE_TEMPORAL
                    spike:force_off()
                    spike:freeze()
                end
                self:set_spikes_pattern_spinning(0.3, 5)

                self.dir_x = random_sample{-1, 1}
            end,
            update = function(state, dt)
                self.sin_y_value = self.sin_y_value + dt * 7
                self.vy = math.cos(self.sin_y_value) * self.speed
                self.vx = self.dir_x * self.speed

                if self.mid_x > game.level.cabin_inner_rect.bx - 32 then
                    self.dir_x = -1
                elseif self.mid_x < game.level.cabin_inner_rect.ax + 32 then
                    self.dir_x = 1
                end

                if self.state_timer:update(dt) then 
                    return random_sample {
                        "thwomp",
                        "timing",
                    }
                end
            end,
        },

        thwomp = {
            enter = function(state)
                self:set_spikes_pattern_times(2, 0.75, 0.25)

                for _, spike in pairs(self.spikes) do
                    spike.timing_mode = TIMED_SPIKES_TIMING_MODE_MANUAL
                    spike:force_off()
                    spike:freeze()
                end

                self.stomps_counter = random_range_int(1, 3)
            end,
            update = function(state, dt)
                self.state_machine:set_state("thwomp_rise")
            end,
        },
        thwomp_flying = {
            enter = function(state)
                self.friction_y = self.def_friction_y
                
                self.thwomp_target = self:get_random_player()
                self.thwomp_target_x = {
                    mid_x = random_range(game.level.cabin_inner_rect.ax + 16, game.level.cabin_inner_rect.bx - 16)
                }
                self.vy = 0

            end,
            update = function(state, dt)
                if self.thwomp_target then
                    self.vx = self.speed * sign(self.thwomp_target.mid_x - self.mid_x)
                end

                for _, player in pairs(game.players) do
                    if player.y > self.y + self.h and math.abs(self.mid_x - player.mid_x) <= self.attack_radius then
                        self.stomps_counter = self.stomps_counter - 1
                        self.state_machine:set_state("thwomp_telegraph")
                    end
                end

                if self.stomps_counter <= 0 then
                    self.state_machine:set_state("random")
                end
            end
        }, 
        thwomp_telegraph = {
            enter = function(state)
                self.vx = 0
                self.vy = 0

                self.telegraph_timer:start()
            end,
            update = function(state, dt)
                self.speed_x = 0
                self.speed_y = self.speed * 0.5

                self.vy = -self.speed_y
                if self.telegraph_timer:update(dt) then 
                    self.state_machine:set_state("thwomp_attack")
                end
            end,
        },
        thwomp_attack = {
            enter = function(state)
            end,
            update = function(state, dt)
                self.speed_x = 0
                self.speed_y = self.speed * 64
                self.friction_y = 1

                self.vy = self.vy + self.speed_y*dt
            end,
            after_collision = function(state, col)
                if col.type ~= "cross" and col.normal.x == 0 and col.normal.y == -1 then
                    self.state_machine:set_state("thwomp_rise")
                    game:screenshake(6)
                    self:set_spike_waves()
                end
            end
        },
        thwomp_rise = {
            enter = function(state)
            end,
            update = function(state, dt)
                self.speed_x = 0
                self.speed_y = self.speed * 64
                self.friction_y = 1

                self.vy = -self.speed_y*dt
                if self.y < self.def_target_y then
                    self.state_machine:set_state("thwomp_flying")
                end
            end,
        },

        timing = {
            enter = function(state)
                self.vx = 0
                self.vy = 0
                self:set_spikes_pattern_timing()

                local spike = self.spikes[1]
                local t = 7
                if spike then
                    t = spike:get_cycle_total_time() + 0.1
                end
                self.state_timer:start(t * 1--[[4 changeme]])
            end,
            update = function(state, dt)
                if self.state_timer:update(dt) then
                    self.state_machine:set_state("random")
                end
            end,
        },

        bars = {
            enter = function(state)
                self.vx = 0
                self.vy = 0
                self:set_spikes_pattern_bars()

                local spike = self.spikes[1]
                local t = 5
                if spike then
                    t = spike:get_cycle_total_time() + 0.1
                end
                self.state_timer:start(t)
            end,
            update = function(state, dt)
                if self.state_timer:update(dt) then
                    self.state_machine:set_state("random")
                end
            end,
        },

        big_wave = {
            enter = function(state)
                self.vx = 0
                self.vy = 0
                self:set_spikes_pattern_big_wave()

                local spike = self.spikes[1]
                local t = 5
                if spike then
                    t = spike:get_cycle_total_time() + 0.9
                end
                self.state_timer:start(t)
            end,
            update = function(state, dt)
                self.spr:update_offset(random_neighbor(2), random_neighbor(2))
                if self.state_timer:update(dt) then
                    self.state_machine:set_state("random")
                end
            end,
            exit = function(state)
                self.spr:update_offset(0, 0)
            end,
        },
    }, "standby")

    -- timing
    -- thwomp_flying
    -- spinning_spikes
end

function BeeBoss:after_collision(col, other)
    if col.type ~= "cross" then
        if self.state_machine.current_state_name == "thwomp_attack" then--and col.normal.y == -1 then
            self.state_machine:_call("after_collision", col)
        end
    end
end

function BeeBoss:update(dt)
    self:update_enemy(dt)

    self.state_machine:update(dt)

    if self.invul_timer:update(dt) then
        self.invul = false
        self.damage = 1
        self.is_stompable = true
    end

    -- self.debug_values[1] = concat(self.state_machine.current_state_name)
    self.debug_values[2] = concat(self.life,"❤")
end

function BeeBoss:draw()
    self:draw_enemy()

    -- rect_color(COL_RED, "line", self.x, self.y, self.w, self.h)
end

function BeeBoss:set_spike_waves()
    self:set_spikes_length(16)

    local function dist_func(source, spike)
        return 3 - 0.01 * dist(source.mid_x, source.mid_y, spike.mid_x, spike.mid_y)
    end

    for _, spike in pairs(self.spikes) do
        if spike.orientation == 0 then
            local t = (dist_func(self, spike))
            spike:set_time_offset(t)
        end
    end
end

function BeeBoss:set_spikes_pattern_big_wave()
    self:set_spikes_length(64)
    self:set_spikes_pattern_times(2, 0.6, 0.25)

    local wave_pos = random_sample{0, CANVAS_WIDTH}

    for _, spike in pairs(self.spikes) do
        if spike.orientation == 0 then
            local t = math.abs(spike.mid_x - wave_pos) / 200
            spike:force_off()
            spike:freeze()
            spike:standby(t, 0.5)
        else
            spike:force_off()
            spike:freeze()
        end
    end
end

function BeeBoss:set_spikes_pattern_bars()
    self:set_spikes_length(16)
    self:set_spikes_pattern_times(2, 0.8, 0.25)

    local r = random_range_int(0, 2)
    for _, spike in pairs(self.spikes) do
        spike:force_off()
        spike:freeze()
        if spike.orientation == 0 and spike.spike_i % 3 == r then
            spike.timing_mode = TIMED_SPIKES_TIMING_MODE_TEMPORAL
            spike:set_time_offset(0)    
            spike:set_length(12*16)
        end
    end
end

function BeeBoss:set_spikes_pattern_timing()
    self:set_spikes_length(12)
    self:set_spikes_pattern_times(2, 0.75, 0.25)

    for _, spike in pairs(self.spikes) do
        spike.timing_mode = TIMED_SPIKES_TIMING_MODE_TEMPORAL
        spike:force_off()
        spike:freeze()
        spike:set_time_offset(0)
    end
end

function BeeBoss:set_spikes_pattern_spinning(time_offset, number_of_waves)
    self:set_spikes_length(16)
    self:set_spikes_pattern_times(2, 0.75, 0.25)

    local t_total = self.spikes[1]:get_cycle_total_time()
    local rand_t_offset = random_range(0, t_total)
    for _, spike in pairs(self.spikes) do
        -- spike:set_time_offset()
        spike:standby(spike.spike_i * (t_total/68)*number_of_waves + time_offset + rand_t_offset, 0.75)
    end
end

------------------------------------------

function BeeBoss:set_spikes_pattern_times(t_off, t_telegraph, t_on)
    for _, spike in pairs(self.spikes) do
        spike:set_pattern_times(t_off, t_telegraph, t_on)
    end
end

function BeeBoss:set_spikes_length(length)
    for _, spike in pairs(self.spikes) do
        spike:set_length(length)
    end
end

function BeeBoss:on_stomped(player)
    game:frameskip(10)
    game:screenshake(8)

    local dx, dy = normalize_vect(player.mid_x - self.mid_x, player.mid_y - self.mid_y)

    player.vx = self.vx + dx * self.knockback_x
    player.vx = self.vx + dy * self.knockback_y

    self.invul_timer:start(1.0)
    self.invul = true
    self.damage = 0
    self.is_stompable = false
end

function BeeBoss:spawn_spikes()
    self.spikes = {}

    local j = 0

    local t_off, t_tel, t_on = 2, 0.75, 0.25
    local t_total = t_off + t_tel + t_on
    local function spawn_spike(x, y, orientation, j)
        local spikes = TimedSpikes:new(x, y, t_off, t_tel, t_on, j*(t_total/68)*2, {
            orientation = orientation,
            start_after_standby = false,
        })
        spikes.spike_i = j
        spikes.timing_mode = TIMED_SPIKES_TIMING_MODE_MANUAL
        spikes.z = 2 - j/100
        -- spikes.debug_values[1] = j
        game:new_actor(spikes)
        table.insert(self.spikes, spikes)
    end
    local spikes

    -- Bottom
    for i = 3, CANVAS_WIDTH/16 - 4 do
        spawn_spike(i * BW, CANVAS_HEIGHT*0.85, 0, j)
    
        if i ~= CANVAS_WIDTH/16 - 4 then
            j = j + 1
        end
    end

    
    -- Right
    for i = 14, 3, -1 do
        spawn_spike(CANVAS_WIDTH - 32, i * BW, 3, j)

        if i ~= 3 then
            j = j + 1
        end
    end

    -- Top
    for i = CANVAS_WIDTH/16 - 4, 3, -1 do
        spawn_spike(i * BW, BW*3, 2, j)
        
        if i ~= 3 then
            j = j + 1
        end

    end
    
    -- Left
    for i = 3, 14 do
        spawn_spike(3, i * BW, 1, j)
                        
        if i ~= 14 then
            j = j + 1
        end

    end
end


return BeeBoss