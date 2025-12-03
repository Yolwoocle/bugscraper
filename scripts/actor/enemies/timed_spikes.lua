require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local images = require "data.images"
local Prop = require "scripts.actor.enemies.prop"
local StateMachine = require "scripts.state_machine"
local Timer = require "scripts.timer"
local Sprite= require "scripts.graphics.sprite"

local utf8 = require "utf8"

local TimedSpikes = Prop:inherit()

function TimedSpikes:init(x, y, duration_off, duration_telegraph, duration_on, start_offset, args)
    args = args or {}
    start_offset = start_offset or 0
    self.orientation = args.orientation or 0
    self.spike_length = args.spike_length or 16
    local w, h = 14, 14
    x = x + 1
    y = y + 1

    if self.orientation == 0 then --up
        x, y = x, y - (self.spike_length - h)
        w, h = w, self.spike_length
    elseif self.orientation == 1 then --right
        w, h = self.spike_length, h
    elseif self.orientation == 2 then -- down
        w, h = w, self.spike_length
    elseif self.orientation == 3 then -- left
        x, y = x - (self.spike_length - x), y
        w, h = self.spike_length, h 
    end

    TimedSpikes.super.init(self, x, y, images.empty, w, h)
    self.name = "timed_spikes"
    
    local sprite_anchor = ({
        [0] = SPRITE_ANCHOR_CENTER_TOP, -- upwards spikes
        [1] = SPRITE_ANCHOR_RIGHT_CENTER, -- rightward
        [2] = SPRITE_ANCHOR_CENTER_BOTTOM, -- downward
        [3] = SPRITE_ANCHOR_LEFT_CENTER, -- leftward 
    })[self.orientation] or SPRITE_ANCHOR_CENTER_BOTTOM
    self.orientation_dir_x = round(-math.cos(self.orientation * pi/2 - pi/2), 1)
    self.orientation_dir_y = round(-math.sin(self.orientation * pi/2 - pi/2), 1)
    self.spr:set_anchor(sprite_anchor)
    self.spr:set_rotation(self.orientation * pi/2)

    self.timing_mode = TIMED_SPIKES_TIMING_MODE_TEMPORAL
    self.do_circular_timing = param(args.do_circular_timing, true) -- whether the cycle loops back after finishing

    self.do_standby_warning = param(args.do_standby_warning, false)

    self.z = 2
    self.state_order = {
        -- 2, 0.5, 0.5
        {"off", duration_off or 4},
        {"telegraph", duration_telegraph or 2},
        {"on", duration_on or 1},
    }

    self.extend_speed = 10
    self.spike_y = -self.spike_length
    self.spike_target_y = -self.spike_length

    self.spike_sprite = Sprite:new(images.timed_spikes_spikes)
    self.spike_sprite:set_anchor(sprite_anchor)
    self.spike_sprite:set_rotation(self.orientation * pi/2)

    self.spike_stem_sprite = Sprite:new(images.timed_spikes_spikes_stem)
    self.spike_stem_sprite:set_anchor(sprite_anchor)
    self.spike_stem_sprite:set_rotation(self.orientation * pi/2)
    
    self.counts_as_enemy = false

    -- State management
    self.standby_timer = Timer:new(2)
    self.state_timer = Timer:new(0)
    self:standby(start_offset)

    self.state_machine = StateMachine:new({
        standby = {
            enter = function(state)
                self.damage = 0
                if self.init_state_name == "on" then
                    self.spike_target_y = 6
                    self.spike_sprite.color = {0.5,0.5,0.5}
                    self.spike_stem_sprite.color = {0.5,0.5,0.5}
                    self.spike_sprite.is_visible = true
                else
                    self.spike_target_y = 0
                    self.spike_sprite.color = COL_WHITE
                    self.spike_stem_sprite.color = COL_WHITE
                    self.spike_sprite.is_visible = false
                end
                self.spike_y = self.spike_target_y
                self.standby_timer:start()
            end, 
            update = function(state, dt)
                -- Update timer
                if self.standby_timer:update(dt) then
                    self.state_machine:set_state(self.init_state_name)
                    self.state_timer:start()
                end
            end,
            exit = function(state)
                self.spr:set_scale(1, 1)
                self.spike_sprite:set_scale(1, 1)
                self.spike_stem_sprite:set_scale(1, 1)

                self.spike_sprite.is_visible = true
            end,
        },
        disabled = {
            enter = function(state)
                self.state_timer:stop()

                self.damage = 0
                self.spike_target_y = 0
                self.spike_sprite.color = {0.5,0.5,0.5}
            end, 
        },
        off = {
            enter = function(state)
                self.damage = 0
                self.spike_target_y = 0
                self.spike_sprite.color = {0.5,0.5,0.5}
            end, 
        },
        telegraph = {
            enter = function(state)
                self.damage = 0
                self.spike_target_y = 6
                self.spike_sprite.color = {0.5,0.5,0.5}
            end, 
        },
        on = {
            enter = function(state)
                self.spike_target_y = self.spike_length
                self.spike_sprite.color = COL_WHITE
                -- self.spike_sprite.sy = 1.7

                self:play_sound_var("sfx_enemy_timed_spikes_unearth_{01-05}", 0.2, 1.2, {volume=0.3})
            end, 
            update = function(state, dt)
                if self.spike_y >= self.spike_length - 8 then
                    self.damage = 1
                end
            end
        },
    }, "standby")

    self.spike_stem_sprite.is_visible = false

    self.t = 0
end

function TimedSpikes:set_pattern_times(t_off, t_telegraph, t_on)
    self:set_off_duration(t_off)
    self:set_telegraph_duration(t_telegraph)
    self:set_on_duration(t_on)
end

function TimedSpikes:set_off_duration(duration)
    self.state_order[1][2] = duration
end

function TimedSpikes:set_telegraph_duration(duration)
    self.state_order[2][2] = duration
end

function TimedSpikes:set_on_duration(duration)
    self.state_order[3][2] = duration
end

function TimedSpikes:set_length(new_length)
    local old_length = self.spike_length
    self.spike_length = new_length

    local x, y = self.x, self.y
    local w, h = self.w, self.h

    if self.orientation == 0 then --up
        x, y = x, y - (new_length - old_length)
        w, h = w, new_length

    elseif self.orientation == 1 then --right
        w, h = new_length, h

    elseif self.orientation == 2 then -- down
        w, h = w, new_length

    elseif self.orientation == 3 then -- left
        x, y = x - (new_length - old_length), y
        w, h = new_length, h 
    end

    self:set_position(x, y)
    self:set_dimensions(w, h)
end

function TimedSpikes:standby(init_offset, duration)
    self.standby_timer:start(duration)

    local init_time, init_state_index = self:get_offset_time_and_state(init_offset)
    self.state_index = init_state_index
    self.init_time = init_time
    self.init_state_name = self.state_order[init_state_index][1]
    self.state_timer:set_duration(self.init_time)

    if self.state_machine then
        self.state_machine:set_state("standby")
    end
end

function TimedSpikes:set_time_offset(time_offset)
    local time, state_index = self:get_offset_time_and_state(time_offset)
    self.state_timer:start(time)
    self:set_state(state_index)
end

function TimedSpikes:get_offset_time_and_state(time_offset)
    local total_time = 0
    for _, state in pairs(self.state_order) do
        total_time = total_time + state[2]
    end

    local time = time_offset
    if self.do_circular_timing then
        time = time % total_time
    end
    for i_state = 1, #self.state_order do
        local state_duration = self.state_order[i_state][2]
        if time <= state_duration then
            return (state_duration - time), i_state
        end
        time = time - state_duration
    end

end

function TimedSpikes:get_cycle_total_time()
    local s = 0
    for _, state in pairs(self.state_order) do
        s = s + state[2] 
    end
    return s
end

function TimedSpikes:force_off()
    self:set_state(1)
end

function TimedSpikes:freeze()
    self.state_timer:stop()
end

function TimedSpikes:disable_spikes()
    self.state_machine:set_state("disabled")
end

function TimedSpikes:set_state(index)
    self.state_index = mod_plus_1(index, #self.state_order)
    local state = self.state_order[self.state_index]
    self.state_machine:set_state(state[1])
end

function TimedSpikes:update(dt)
    TimedSpikes.super.update(self, dt)

    self:update_spike_state(dt)

    self.spike_y = move_toward(self.spike_y, self.spike_target_y, self.extend_speed*self.spike_length*dt)
    self.spike_sprite.sy = lerp(self.spike_sprite.sy, 1, 0.1)

    self.spike_stem_sprite.color = self.spike_sprite.color
    self.spike_stem_sprite.is_visible = self.spike_sprite.is_visible

    self.state_machine:update(dt)
end

function TimedSpikes:update_spike_state(dt)
    if self.state_timer:update(dt) then
        local new_state = self.state_index + 1
        if self.do_circular_timing then
            new_state = mod_plus_1(new_state, #self.state_order)
        else
            if new_state > #self.state_order then
                self:disable_spikes()
                return
            end
        end
        
        self:set_state(new_state)

        if (self.timing_mode == TIMED_SPIKES_TIMING_MODE_TEMPORAL) or (self.timing_mode == TIMED_SPIKES_TIMING_MODE_MANUAL and self.state_index ~= 1) then
            self.state_timer:start(self.state_order[self.state_index][2])
        end
    end
end

function TimedSpikes:draw()
    -- huge hack, don't try to understand it
    -- it's not very pretty but eh fuck it, it works, life is too short to pull my hair over this shit
    local x = self.x + self.orientation_dir_x * (self.spike_length - self.spike_y) 
    local y = self.y + self.orientation_dir_y * (self.spike_length - self.spike_y) 
    
    if self.orientation == 0 or self.orientation == 2 then
        self.spike_sprite:draw(x, y, self.w, self.h)
    else
        x = self.x + self.orientation_dir_x * (self.spike_length - self.spike_y - self.spike_sprite.image:getHeight() + 2) 
        y = self.y + self.orientation_dir_y * (self.spike_length - self.spike_y - self.spike_sprite.image:getHeight() + 2) 
        self.spike_sprite:draw(x, y, self.w, self.h)
    end

    self.spike_stem_sprite.sy = self.spike_y - self.spike_sprite.image:getHeight() + 1
    if self.orientation == 0 or self.orientation == 2 then
        self.spike_stem_sprite:draw(
            x + self.orientation_dir_x * (self.spike_sprite.image:getHeight() - self.spike_stem_sprite.sy / 2), 
            y + self.orientation_dir_y * (self.spike_sprite.image:getHeight() - self.spike_stem_sprite.sy / 2), 
        self.w, self.h)
    else 
        self.spike_stem_sprite:draw(
            x + self.orientation_dir_x * (self.spike_sprite.image:getHeight() - 3), 
            y + self.orientation_dir_y * (self.spike_sprite.image:getHeight() - 3), 
        self.w, self.h)
    end

    TimedSpikes.super.draw(self)

    if self.do_standby_warning and self.state_machine.current_state_name == "standby" and self.t % 0.2 < 0.1 then
        print_centered_outline(COL_LIGHT_GRAY, nil, "⚠", self.mid_x, self.mid_y)
    end
end

return TimedSpikes