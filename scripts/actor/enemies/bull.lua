require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"
local Timer = require "scripts.timer"
local StateMachine = require "scripts.state_machine"
local Rect = require "scripts.math.rect"

local Bull = Enemy:inherit()
	
function Bull:init(x, y, spr, w, h)
    Bull.super.init(self, x,y, spr or images.larva1, w or 16, h or 16)
    self.name = "bull"
    self.follow_player = false
    self.is_pushable = false
    
    self.life = 30
    self.friction_x = 1

    -- State properties
    self.def_speed = 70
    self.speed_randomness = 5
    self.telegraph_duration = 0.5
    self.def_attack_speed = 400
    self.attack_speed_randomness = 20
    self.linger_duration = 1
    self.linger_duration_randomness = 0.2

    self.self_knockback_mult = 0
    self.walk_dir_x = random_sample{-1, 1}

    -- self.sound_damage = {"larva_damage1", "larva_damage2", "larva_damage3"}
    -- self.sound_death = "larva_death"
    self.anim_frame_len = 0.2
    self.anim_frames = {images.larva1, images.larva2}
    self.audio_delay = love.math.random(0.3, 1)

    self.detect_range = 128

    self.state_timer = Timer:new(1.0)
    self.state_machine = StateMachine:new({
        wander = {
            enter = function(state)
                self.speed = self.def_speed + random_neighbor(self.speed_randomness)
                self.state_timer:start(1.0)
            end,
            update = function(state, dt)
                self.vx = self.speed * self.walk_dir_x

                -- Don't attack for a second
                self.state_timer:update(dt)
                if self.state_timer.is_active then
                    return
                end

                -- Foind player in range
                for _, p in pairs(game.players) do
                    local r = Rect:new(self.x, self.y, self.x + self.w, self.y + self.h)
                    if self.walk_dir_x < 0 then
                        r:set_ax(r.x - self.detect_range)
                    else
                        r:set_bx(r.bx + self.detect_range)
                    end

                    local p_rect = p:get_rect()
                    if r:rectangle_intersection(p_rect) then
                        return "telegraph"
                    end
                end
            end,
            after_collision = function(state, col, other)
                if col.normal.y == 0 then
                    self.walk_dir_x = col.normal.x
                end
            end,
        },
        telegraph = {
            enter = function(state)
                self.vx = 0
                self.state_timer:start(self.telegraph_duration)
            end,
            update = function(state, dt)
                if self.state_timer:update(dt) then
                    return "charge"
                end
            end,
        },
        charge = {
            enter = function(state)
                self.attack_speed = self.def_attack_speed + random_neighbor(self.attack_speed_randomness)
                self.vx = self.attack_speed * self.walk_dir_x
            end,
            after_collision = function(state, col, other)
                if col.normal.y == 0 then
                    self.state_machine:set_state("linger")
                end
            end,
        },
        linger = {
            enter = function(state)
                self.vx = 0
                self.state_timer:start(self.linger_duration + random_neighbor(self.linger_duration_randomness))
            end,
            update = function(state, dt)
                if self.state_timer:update(dt)   then
                    return "wander"
                end
            end,
        },
    }, "wander")

	self.score = 10
end

function Bull:update(dt)
    Bull.super.update(self, dt)
    
    self.debug_values[1] = self.state_machine.current_state_name
    self.state_machine:update(dt)
    
    -- self.audio_delay = self.audio_delay - dt
    -- if self.audio_delay <= 0 then
    -- 	self.audio_delay = love.math.random(0.3, 1.5)
    -- 	audio:play({
        -- 		"larva_damage1",
        -- 		"larva_damage2",
        -- 		"larva_damage3",
        -- 		"larva_death"
        -- 	})
        -- end
end
    
function Bull:draw()
    Bull.super.draw(self)

    local r = Rect:new(self.x, self.y, self.x + self.w, self.y + self.h)
    if self.walk_dir_x < 0 then
        r:set_ax(r.x - self.detect_range)
    else
        r:set_bx(r.bx + self.detect_range)
    end
    rect_color(COL_RED, "line", r.x, r.y, r.w, r.h)
end
    
function Bull:start_attack()

end

function Bull:after_collision(col, other)
    if col.type ~= "cross" then
        self.state_machine:_call("after_collision", col, other)
    end
end

return Bull
