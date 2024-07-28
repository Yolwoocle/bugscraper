require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local images = require "data.images"
local Prop = require "scripts.actor.enemies.prop"
local StateMachine = require "scripts.state_machine"
local Timer = require "scripts.timer"
local Sprite= require "scripts.graphics.sprite"

local utf8 = require "utf8"

local TimedSpikes = Prop:inherit()

function TimedSpikes:init(x, y, duration_off, duration_telegraph, duration_on, start_offset)
    self:init_prop(x, y, images.timed_spikes_base, 14, 14)
    self.name = "timed_spikes_base"
    
    self.state_order = {
        -- 2, 0.5, 0.5
        {"off", duration_off or 2},
        {"telegraph", duration_telegraph or 1},
        {"on", duration_on or 0.5},
    }

    self.spike_y = -16
    self.spike_target_y = -16
    self.spike_sprite = Sprite:new(images.timed_spikes_spikes)
    
    self.counts_as_enemy = false

    self.start_offset = start_offset or 0
    local init_time, init_state_index = self:get_init_time_and_state()
    self.state_timer = Timer:new(init_time)
    self.init_time = init_time
    self.init_state_name = self.state_order[init_state_index][1]
    self.state_index = init_state_index

    self.standby_timer = Timer:new(2)

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
                if self.standby_timer:update(dt) then
                    self.state_machine:set_state(self.init_state_name)
                    self.state_timer:start()
                end
            end
        },
        off = {
            enter = function(state)
                self.damage = 0
                self.spike_target_y = 12
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

function TimedSpikes:get_init_time_and_state()
    local total_time = 0
    for _, state in pairs(self.state_order) do
        total_time = total_time + state[2]
    end

    local time = self.start_offset % total_time
    local output_i_state
    for i_state = 1, #self.state_order do
        local state_duration = self.state_order[i_state][2]
        if time <= state_duration then
            return (state_duration - time), i_state
        end
        time = time - state_duration
    end

end

function TimedSpikes:update(dt)
    self:update_prop(dt)
    self.t = self.t + dt

    if self.state_timer:update(dt) then
        self.state_index = mod_plus_1(self.state_index + 1, #self.state_order)

        local state = self.state_order[self.state_index]
        self.state_machine:set_state(state[1])
        self.state_timer:start(state[2])
    end

    self.spike_y = move_toward(self.spike_y, self.spike_target_y, 80*dt)
    self.spike_sprite.sy = lerp(self.spike_sprite.sy, 1, 0.1)

    self.state_machine:update(dt)
end
function TimedSpikes:draw()
    self.spike_sprite:draw(self.x, self.y + self.spike_y, self.w, self.h)
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