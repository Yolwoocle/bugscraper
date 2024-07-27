require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local images = require "data.images"
local Prop = require "scripts.actor.enemies.prop"
local StateMachine = require "scripts.state_machine"
local Timer = require "scripts.timer"

local utf8 = require "utf8"

local TimedSpikes = Prop:inherit()

function TimedSpikes:init(x, y, duration_off, duration_telegraph, duration_on, start_offset)
    self:init_prop(x, y, images.upgrade_jar, 14, 14)
    self.name = "timed_spikes"
    
    self.state_order = {
        {"off", duration_off or 3},
        {"telegraph", duration_telegraph or 1},
        {"on", duration_on or 2},
    }
    
    self.counts_as_enemy = false

    self.start_offset = start_offset or 0
    local init_time, init_state_index = self:get_init_time_and_state()
    self.state_timer = Timer:new(init_time)
    self.state_timer:start()
    self.init_time = init_time
    self.state_index = init_state_index

    self.state_machine = StateMachine:new({
        off = {
            enter = function(state)
                self.damage = 0
                self.spr:set_image(images.timed_spikes_off)
            end, 
        },
        telegraph = {
            enter = function(state)
                self.damage = 0
                self.spr:set_image(images.timed_spikes_telegraph)
            end, 
        },
        on = {
            enter = function(state)
                self.damage = 1
                self.spr:set_image(images.timed_spikes_on)
                self.spr.sy = 1.5
            end, 
        },
    }, self.state_order[init_state_index][1])
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

    if self.state_timer:update(dt) then
        self.state_index = mod_plus_1(self.state_index + 1, #self.state_order)

        local state = self.state_order[self.state_index]
        self.state_machine:set_state(state[1])
        self.state_timer:start(state[2])
    end

    self.spr.sx = lerp(self.spr.sx, 1, 0.1)
    self.spr.sy = lerp(self.spr.sy, 1, 0.1)

    self.state_machine:update(dt)
end
function TimedSpikes:draw()
    self:draw_enemy()

    -- rect_color(COL_BLACK_BLUE, "fill", self.x, self.y - 8, 12, 6)
    -- local w = self.state_timer.time / (self.state_order[self.state_index][2])
    -- rect_color(COL_LIGHT_BLUE, "fill", self.x+1, self.y+1 - 8, 10*w, 4)

    -- local old_font = love.graphics.getFont()
    -- love.graphics.setFont(FONT_MINI)
    -- love.graphics.print(concat(), self.x+1, self.y+1 - 8)
    -- love.graphics.setFont(old_font)
end

return TimedSpikes