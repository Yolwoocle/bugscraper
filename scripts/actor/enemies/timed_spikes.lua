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

    self:init_prop(x, y, images.timed_spikes_base, 14, 14)
    self.name = "timed_spikes"
    
    self.orientation = args.orientation or 0
    local sprite_anchor = ({
        [0] = SPRITE_ANCHOR_CENTER_BOTTOM,
        [1] = SPRITE_ANCHOR_LEFT_CENTER,
        [2] = SPRITE_ANCHOR_CENTER_TOP,
        [3] = SPRITE_ANCHOR_RIGHT_CENTER,
    })[self.orientation] or SPRITE_ANCHOR_CENTER_BOTTOM
    self.orientation_dir_x = round(math.cos(self.orientation * pi/2 + pi/2), 1)
    self.orientation_dir_y = round(math.sin(self.orientation * pi/2 + pi/2), 1)
    self.spr:set_anchor(sprite_anchor)
    self.spr:set_rotation(self.orientation * pi/2)

    self.timing_mode = TIMED_SPIKES_TIMING_MODE_TEMPORAL

    self.z = 2
    self.state_order = {
        -- 2, 0.5, 0.5
        {"off", duration_off or 4},
        {"telegraph", duration_telegraph or 2},
        {"on", duration_on or 1},
    }

    self.spike_length = args.spike_length or 16 
    self.spike_y = -self.spike_length
    self.spike_target_y = -self.spike_length
    self.spike_sprite = Sprite:new(images.timed_spikes_spikes)
    self.spike_sprite:set_anchor(sprite_anchor)
    self.spike_sprite:set_rotation(self.orientation * pi/2)
    
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
                    self.spike_target_y = 8
                    self.spike_sprite.color = {0.5,0.5,0.5}
                else
                    self.spike_target_y = 16
                    self.spike_sprite.color = COL_WHITE
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
            end,
        },
        disabled = {
            enter = function(state)
                self.state_timer:stop()

                self.damage = 0
                self.spike_target_y = 13
                self.spike_sprite.color = {0.5,0.5,0.5}
            end, 
        },
        off = {
            enter = function(state)
                self.damage = 0
                self.spike_target_y = 13
                self.spike_sprite.color = {0.5,0.5,0.5}
            end, 
        },
        telegraph = {
            enter = function(state)
                self.damage = 0
                self.spike_target_y = 8
                self.spike_sprite.color = {0.5,0.5,0.5}
            end, 
        },
        on = {
            enter = function(state)
                self.damage = 1
                self.spike_target_y = 0
                self.spike_sprite.color = COL_WHITE
                self.spike_sprite.sy = 1.7
            end, 
        },
    }, "standby")

    self.t = 0
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

    local time = time_offset % total_time
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

function TimedSpikes:set_state(index)
    self.state_index = mod_plus_1(index, #self.state_order)
    local state = self.state_order[self.state_index]
    self.state_machine:set_state(state[1])
end

function TimedSpikes:update(dt)
    self:update_prop(dt)
    self.t = self.t + dt

    if self.state_timer:update(dt) then
        local new_state = mod_plus_1(self.state_index + 1, #self.state_order)
        
        self:set_state(new_state)

        if (self.timing_mode == TIMED_SPIKES_TIMING_MODE_TEMPORAL) or (self.timing_mode == TIMED_SPIKES_TIMING_MODE_MANUAL and self.state_index ~= 1) then
            self.state_timer:start(self.state_order[self.state_index][2])
        end
    end

    self.spike_y = move_toward(self.spike_y, self.spike_target_y, 80*dt)
    self.spike_sprite.sy = lerp(self.spike_sprite.sy, 1, 0.1)

    self.state_machine:update(dt)
end

function TimedSpikes:draw()
    self.spike_sprite:draw(self.x + self.orientation_dir_x * self.spike_y, self.y + self.orientation_dir_y * self.spike_y, self.w, self.h)
    self:draw_enemy()

    if game.debug.colview_mode then
        local old_font = love.graphics.getFont()
        love.graphics.setFont(FONT_MINI)
        love.graphics.print(utf8.sub(self.state_machine.current_state_name, 1, 3), self.x+1, self.y+1 - 8)
        love.graphics.setFont(old_font)
    end

    -- rect_color(COL_BLACK_BLUE, "fill", self.x, self.y - 8, 12, 6)
    -- local w = self.state_timer.time / (self.state_order[self.state_index][2])
    -- rect_color(COL_LIGHT_BLUE, "fill", self.x+1, self.y+1 - 8, 10*w, 4)
end

return TimedSpikes