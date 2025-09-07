require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"
local Timer = require "scripts.timer"
local StateMachine = require "scripts.state_machine"
local Rect = require "scripts.math.rect"
local AnimatedSprite = require "scripts.graphics.animated_sprite"

local Rollopod = Enemy:inherit()
	
function Rollopod:init(x, y, spr, w, h)
    Rollopod.super.init(self, x,y, spr or images.larva1, w or 18, h or 12)
    self.name = "rollopod"
    self.follow_player = false
    self.is_pushable = true
    
    self.life = 30
    self.friction_x = 1

    self.destroy_bullet_on_impact = false
    self.is_bouncy_to_bullets = true
    self.is_immune_to_bullets = true
    self.is_stompable = true
    self.stomp_animation_image = images.rollopod_dead

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
    self.audio_delay = love.math.random(0.3, 1)

    self.detect_range = 200
    self.jump_force = 200
    
    self.rotation_speed = 40
    self.spr = AnimatedSprite:new({
        normal = {images.rollopod, 0.07, 2},
        rolled = {images.rollopod_rolled, 0.05, 1},
    }, "normal", SPRITE_ANCHOR_CENTER_CENTER) 

    self.skid_spr = AnimatedSprite:new({
        normal = {images.skid_effect, 0.01, 28}
    }, "normal", SPRITE_ANCHOR_CENTER_BOTTOM)

    self.state_timer = Timer:new(1.0)
    self.state_machine = StateMachine:new({
        wander = {
            enter = function(state)
                self.speed = self.def_speed + random_neighbor(self.speed_randomness)
                self.state_timer:start(1.0)

                self.spr:set_animation("normal")
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
                
                self.spr:set_animation("rolled")

                self.vy = -self.jump_force 
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
            update = function(state, dt)
                self.spr.rot = self.spr.rot + self.walk_dir_x*dt*self.rotation_speed

                self.skid_spr:update(dt)
                self.skid_spr:set_flip_x(not self.spr.flip_x)

                if random_range(0, 1) < 0.3 then
                    Particles:image(self.mid_x - self.walk_dir_x*16, self.y+self.h, 1, 
                        images.bullet_casing, 4, nil, nil, nil, {
                        vx1 = -self.vx*0.1,
                        vx2 = -self.vx*0.2,
            
                        vy1 = -40,
                        vy2 = -80,
                    })
                end
            end,
            exit = function(state)
                self.spr.rot = 0
            end,
            draw = function(state)
                self.skid_spr:draw(self.mid_x - self.walk_dir_x*16, self.y+self.h)
            end
        },
        linger = {
            enter = function(state)
                self.vx = 0
                self.state_timer:start(self.linger_duration + random_neighbor(self.linger_duration_randomness))
                
                self.vy = -self.jump_force 
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

function Rollopod:update(dt)
    Rollopod.super.update(self, dt)
    
    -- self.debug_values[1] = self.state_machine.current_state_name
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
    
function Rollopod:draw()
    Rollopod.super.draw(self)
    self.state_machine:draw()

    local r = Rect:new(self.x, self.y, self.x + self.w, self.y + self.h)
    if self.walk_dir_x < 0 then
        r:set_ax(r.x - self.detect_range)
    else
        r:set_bx(r.bx + self.detect_range)
    end
    -- rect_color(COL_RED, "line", r.x, r.y, r.w, r.h)
end
    
function Rollopod:start_attack()

end

function Rollopod:after_collision(col, other)
    if col.type ~= "cross" then
        self.state_machine:_call("after_collision", col, other)
    end
end

return Rollopod
