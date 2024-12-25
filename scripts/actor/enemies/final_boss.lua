require "scripts.util"
local Enemy          = require "scripts.actor.enemy"
local sounds         = require "data.sounds"
local images         = require "data.images"
local ElectricRays   = require "scripts.actor.enemies.electric_rays"
local StateMachine   = require "scripts.state_machine"
local Timer          = require "scripts.timer"
local Segment        = require "scripts.math.segment"
local guns           = require "data.guns"
local TimedSpikes    = require "scripts.actor.enemies.timed_spikes"
local AnimatedSprite = require "scripts.graphics.animated_sprite"

local FinalBoss      = Enemy:inherit()

function FinalBoss:init(x, y)
    self:init_enemy(x, y, images.ceo, 90, 74)
    self.name = "final_boss"

    self.spr = AnimatedSprite:new({
        introduction = { { images.ceo_normal }, 0.1 },
        fight = { { images.ceo }, 0.1 },
    }, "introduction")

    self.layers = {
        { spr = self.spr, is_visible = true },
        { -- Desk
            spr = AnimatedSprite:new({
                normal = { { images.ceo_office_desk }, 0.1 },
            }, "normal"),
            is_visible = true
        },
        { -- Glass
            spr = AnimatedSprite:new({
                normal = { { images.ceo_office_glass }, 0.1 },
            }, "normal"),
            is_visible = true
        },
        { -- Legs
            spr = AnimatedSprite:new({
                normal = { { images.ceo_office_legs }, 0.1 },
            }, "normal"),
            is_visible = true
        },
    }

    -- Parameters
    self.def_friction_y = self.friction_y
    self.life = 200
    self.is_flying = true
    self.gravity = 0
    self.attack_radius = 64

    self.destroy_bullet_on_impact = false
    self.is_bouncy_to_bullets = true
    self.is_immune_to_bullets = true

    self.is_stompable = true
    self.can_be_stomped_if_falling_down = false
    self.damage_on_stomp = 5

    self.speed = 10
    self.speed_x = self.speed
    self.speed_y = self.speed * 3
    self.friction_x = 0.8
    self.friction_y = 0.8
    self.thwomp_follow_player_speed = 150
    self.thwomp_telegraph_speed = self.speed * 8
    self.thwomp_attack_speed = self.speed * 512
    self.thwomp_rise_speed = self.speed * 1024

    self.follow_player = false
    self.self_knockback_mult = 0
    self.stomps = math.huge
    self.friction_y = self.friction_x
    self.def_target_y = game.level.cabin_rect.ay + BW * 3
    self.telegraph_oy = 16

    self.charge_speed = 600

    -- Timers
    self.telegraph_timer = Timer:new(0.5)

    self.sin_x_value = 0
    self.sin_y_value = 0

    self.speed = 100
    self.state_timer = Timer:new(6)
    self.standby_timer = Timer:new(2)
    self.unstompable_timer = Timer:new(1)

    self.spikes = {}

    self.flip_mode = ENEMY_FLIP_MODE_MANUAL

    -- State machine
    self.state_machine = StateMachine:new({
        introduction = {
            enter = function(state)
                self.spr:set_animation("introduction")
            end,
        },

        standby = {
            enter = function(state)
                self.spr:set_animation("fight")
            end,
            update = function(state, dt)
                self:spawn_spikes()
                return "random"
            end,
        },

        random = {
            enter = function(state)
            end,
            update = function(state, dt)
                local possible_states = {
                    "thwomp",
                    "charge",
                    "bunny_hopping_telegraph",
                }
                self.state_machine:set_state(random_sample(possible_states))
            end,
        },

        waiting = {
            enter = function(state)
                self.state_timer:start(0.5)
            end,
            update = function(state, dt)
                if self.state_timer:update(dt) then
                    return "random"
                end
            end
        },

        -----------------------------------------------------
        --- JUMPING ---
        -----------------------------------------------------
        bunny_hopping_telegraph = {
            enter = function(state)
                self:reset_spikes()

                self.speed_x = 0
                self.state_timer:start(0.7)

                self.friction_x = 1
                self.friction_y = self.def_friction_y

                self.gravity = self.default_gravity

                self.bunny_hop_target = self:get_random_player()
            end,
            update = function(state, dt)
                local ox = 0
                if self.bunny_hop_target then
                    ox = (self.bunny_hop_target.mid_x - self.mid_x) / 64
                end
                self.spr:update_offset(ox + random_neighbor_int(3), 5 + random_neighbor_int(3))

                if self.state_timer:update(dt) then
                    return "bunny_hopping"
                end
            end,
            exit = function(state)
                self.spr:update_offset(0, 0)
            end,
        },
        bunny_hopping = {
            enter = function(state)
                self.vy = -500

                if not self.bunny_hop_target then
                    return
                end

                self.vx = (self.bunny_hop_target.mid_x - self.mid_x) * random_range(0.8, 1.2)
            end,
            after_collision = function(state, col)
                if col.normal.y == -1 then
                    self.state_machine:set_state("waiting")
                    self.vx = 0
                    Input:vibrate_all(0.2, 0.5)
                    game:screenshake(6)
                end
            end
        },

        -----------------------------------------------------
        --- CHARGE ---
        -----------------------------------------------------
        charge = {
            enter = function(state)
                self:reset_spikes()

                local target = self:get_random_player()
                local dir
                if target then
                    dir = sign(target.mid_x - self.mid_x)
                else
                    dir = random_sample { -1, 1 }
                end

                self.friction_x = 1
                self.friction_y = self.def_friction_y

                self.charge_dir = dir
                self.gravity = self.default_gravity
            end,
            update = function(state, dt)
                return "charge_telegraph"
            end,
        },
        charge_telegraph = {
            enter = function(state)
                self.vx = 0
                self.vy = 0
                self.state_timer:start(0.6)

                self.telegraph_t = 0
            end,
            update = function(state, dt)
                self.telegraph_t = (self.telegraph_t + dt * 200) % images.ceo_telegraph_arrow:getWidth()

                self.spr:update_offset(random_neighbor_int(3), random_neighbor_int(3))
                if self.state_timer:update(dt) then
                    return "charging"
                end
            end,
            draw_bg = function(state)
                local a, b, step
                if self.charge_dir == 1 then
                    a = self.x + self.telegraph_t
                    b = self.x + 200
                    step = images.ceo_telegraph_arrow:getWidth()
                else
                    a = self.x + self.w - self.telegraph_t
                    b = self.x + self.w - 200
                    step = -images.ceo_telegraph_arrow:getWidth()
                end
                for ix = a, b, step do
                    local alpha = 0.8
                    if math.abs(ix - a) < 32 then
                        alpha = 0.8 * math.abs(ix - a) / 32
                    end
                    if math.abs(ix - b) < 32 then
                        alpha = 0.8 * math.abs(ix - b) / 32
                    end
                    exec_color({ 1, 1, 1, alpha }, function()
                        love.graphics.draw(images.ceo_telegraph_arrow, ix, self.y, 0, self.charge_dir, 1)
                    end)
                end
            end,
        },
        charging = {
            enter = function(state)
                self.vx = self.charge_dir * self.charge_speed
                self.vy = 0
            end,
            after_collision = function(state, col)
                if col.type ~= "cross" and math.abs(col.normal.x) == 1 then
                    self.state_machine:set_state("waiting")
                    Input:vibrate_all(0.2, 0.5)
                    game:screenshake(6)
                end
            end
        },

        -----------------------------------------------------
        --- THWOMP ---
        -----------------------------------------------------
        thwomp = {
            enter = function(state)
                self:reset_spikes()

                self.stomps_counter = 2
                self.gravity = 0
            end,
            update = function(state, dt)
                self.state_machine:set_state("thwomp_rise")
            end,
        },
        thwomp_flying = {
            enter = function(state)
                self.friction_y = self.def_friction_y

                self.thwomp_target = self:get_random_player()
                self.vy = 0
            end,
            update = function(state, dt)
                if self.thwomp_target then
                    self.vx = self.thwomp_follow_player_speed * sign(self.thwomp_target.mid_x - self.mid_x)
                end

                for _, player in pairs(game.players) do
                    if math.abs(self.mid_x - player.mid_x) <= self.attack_radius then
                        return "thwomp_telegraph"
                    end
                end

                if self.stomps_counter <= 0 then
                    return "waiting"
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
                self.speed_y = self.thwomp_telegraph_speed

                self.vy = -self.speed_y
                if self.telegraph_timer:update(dt) then
                    return "thwomp_attack"
                end
                self.spr:update_offset(random_neighbor_int(3), random_neighbor_int(3))
            end,
            exit = function(state)
                self.spr:update_offset(0, 0)
            end,
        },
        thwomp_attack = {
            enter = function(state)
            end,
            update = function(state, dt)
                self.speed_x = 0
                self.speed_y = self.thwomp_attack_speed
                self.friction_y = 1

                self.vy = self.vy + self.speed_y * dt
            end,
            after_collision = function(state, col)
                if col.type ~= "cross" and col.normal.x == 0 and col.normal.y == -1 then
                    self.stomps_counter = self.stomps_counter - 1

                    if self.stomps_counter <= 0 then
                        self.state_machine:set_state("waiting")
                    else
                        self.state_machine:set_state("thwomp_rise")
                    end
                    Input:vibrate_all(0.2, 0.5)
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
                self.speed_y = self.thwomp_rise_speed
                self.friction_y = 1

                self.vy = -self.speed_y * dt
                if self.y < self.def_target_y then
                    self.state_machine:set_state("thwomp_flying")
                end
            end,
        },

    }, "introduction")
end

function FinalBoss:update(dt)
    self:update_enemy(dt)

    self.state_machine:update(dt)

    if self.unstompable_timer:update(dt) then
        self.spr:set_color(COL_WHITE)
        self.is_stompable = true
        self.damage = 1
    end
    if self.unstompable_timer.is_active then
        local freq = ternary(self.unstompable_timer.time < self.unstompable_timer.duration / 2, 0.12, 0.07)
        if self.unstompable_timer.time % freq > freq / 2 then
            self.spr:set_color(COL_WHITE)
        else
            self.spr:set_color({ 0.5, 0.5, 0.5 })
        end
    end

    for _, layer in pairs(self.layers) do
        layer:update_offset(self.spr.ox, self.spr.oy)
    end

    -- self.debug_values[1] = concat(self.state_machine.current_state_name)
    self.debug_values[1] = ""
    self.debug_values[2] = concat(self.life, "❤")
end

function FinalBoss:on_stomped(player)
    self.unstompable_timer:start()
    self.is_stompable = false
    self.damage = 0

    game:frameskip(10)
    game:screenshake(4)
    Input:vibrate(player.n, 0.1, 0.3)
end

function FinalBoss:reset_spikes()
    for _, spike in pairs(self.spikes) do
        spike.timing_mode = TIMED_SPIKES_TIMING_MODE_MANUAL
        spike:force_off()
        spike:freeze()
    end
end

function FinalBoss:after_collision(col, other)
    if col.type ~= "cross" then
        self.state_machine:_call("after_collision", col)
    end
end

function FinalBoss:draw()
    self.state_machine:_call("draw_bg")

    local def_spr = self.spr
    for i, layer in pairs(self.layers) do
        if layer.is_visible then
            self.spr = layer.spr
            self:draw_enemy()
        end
    end
    self.spr = def_spr

    self.state_machine:draw()
end

function FinalBoss:set_spike_waves()
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

function FinalBoss:set_spikes_pattern_timing()
    for _, spike in pairs(self.spikes) do
        spike.timing_mode = TIMED_SPIKES_TIMING_MODE_TEMPORAL
        spike:force_off()
        spike:freeze()
        spike:set_time_offset(0)
    end
end

function FinalBoss:set_spikes_pattern_spinning(time_offset, number_of_waves)
    local t_total = self.spikes[1]:get_cycle_total_time()
    for _, spike in pairs(self.spikes) do
        -- spike:set_time_offset()
        spike:standby(spike.spike_i * (t_total / 68) * number_of_waves + time_offset, 1.5)
    end
end

function FinalBoss:spawn_spikes()
    self.spikes = {}

    local j = 0

    local t_off, t_tel, t_on = 2, 0.75, 0.25
    local t_total = t_off + t_tel + t_on
    local function spawn_spike(x, y, orientation, j)
        local spikes = TimedSpikes:new(x, y, t_off, t_tel, t_on, j * (t_total / 68) * 2, {
            orientation = orientation,
            start_after_standby = false,
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


    -- Right
    for i = 14, 3, -1 do
        spawn_spike(CANVAS_WIDTH - 32, i * BW, 3, j)

        if i ~= 3 then
            j = j + 1
        end
    end

    -- Top
    for i = CANVAS_WIDTH / 16 - 4, 3, -1 do
        spawn_spike(i * BW, BW * 3, 2, j)

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

return FinalBoss
