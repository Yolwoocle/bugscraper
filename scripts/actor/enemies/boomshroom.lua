require "scripts.util"
local Fly = require "scripts.actor.enemies.fly"
local Timer = require "scripts.timer"
local Explosion = require "scripts.actor.enemies.explosion"
local StateMachine = require "scripts.state_machine"
local sounds = require "data.sounds"
local images = require "data.images"

local Boomshroom = Fly:inherit()
	
function Boomshroom:init(x, y)
    self:init_fly(x,y, images.boomshroom_1, 14, 16, false)
    self.name = "boomshroom"
    self.max_life = 15
    self.life = self.max_life
    
    self.is_killed_on_negative_life = false
    self.is_killed_on_stomp = false
    self.do_stomp_animation = false
    self.counts_as_enemy = true

    self.explosion_radius = 16 * 3
    self.weight = 0 -- ranges from 0 to 1, dictates how much y velocity is weighed down
    self.weight_vy_multiplier = 15

    self.state = "normal" -- "normal", "exploding"
    self.exploding_timer = Timer:new(2.0)
    self.flash_timer = Timer:new(0.5)
    self.sound_death = nil
    self.loot = {}
    
    self.follow_player = false
    self.direction = random_range(0, pi2)

    self.anim_frames = nil

    self.sizes = {
        [1] = {w = 14, h = 16, sprite = images.boomshroom_1},
        [2] = {w = 14, h = 16, sprite = images.boomshroom_2},
        [3] = {w = 14, h = 16, sprite = images.boomshroom_3},
        [4] = {w = 14, h = 17, sprite = images.boomshroom_4},
        [5] = {w = 16, h = 16, sprite = images.boomshroom_5},
        [6] = {w = 16, h = 16, sprite = images.boomshroom_6},
        [7] = {w = 20, h = 20, sprite = images.boomshroom_8},
    }

    self.dead_scale = 1.5
    self.spr:set_anchor(SPRITE_ANCHOR_CENTER_CENTER)

    self.score = 10

    self.state_machine = StateMachine:new({
        normal = {
            update = function(state, dt)
                self.weight = 1 - self.life/self.max_life

                self.direction = self.direction + random_sample({-1, 1}) * dt * 3
                self.vx = self.vx + math.cos(self.direction) * self.speed
                self.vy = self.vy + math.sin(self.direction) * self.speed + self.weight * self.weight_vy_multiplier

                -- You don't need to understand this.
                self:set_size(clamp(math.ceil((#self.sizes-1) * (1 - self.life / self.max_life)), 1, #self.sizes - 1)) 
            end
        }, 
            
        exploding = {
            enter = function(state)
                self.is_immune_to_bullets = true
                self.is_stompable = false
                self.destroy_bullet_on_impact = false
                self.counts_as_enemy = false -- FIXME: check if this affects the "kills" stat
                self.speed = 0
                self.speed_x = 0
                self.speed_y = 0
                self.damage = 0
                self.weight = 1                

                self.exploding_timer:start()
                self.flash_timer:start(0.5)

                self:set_size(#self.sizes)
                Audio:play("stomp2")
            end,
            update = function(state, dt)
                if self.flash_timer:update(dt) then
                    self.flash_white = not self.flash_white
                    if self.flash_white then
                        local d = math.max(0.05, self.flash_timer:get_duration() * 0.3)
                        self.flash_timer:set_duration(d)
                    end
                    self.flash_timer:start()
                end

                if self.exploding_timer:update(dt) then                    
                    local explosion = Explosion:new(self.mid_x, self.mid_y, {radius = self.explosion_radius})
                    game:new_actor(explosion)
                    self:kill()
                end

                self.vy = self.vy + self.weight * self.weight_vy_multiplier

                local time = self.exploding_timer:get_time()
                local duration = self.exploding_timer:get_duration()
                if time <= duration * 0.5 then
                    local s = 1 + (1 - time/(duration*0.5)) * 0.5
                    self:set_sprite_scale(s)
                else
                    self:set_sprite_scale(1)
                end
            end
        }
    }, "normal")

    self.t = 0
end

function Boomshroom:after_collision(col, other)
    if col.type ~= "cross" then
        local new_vx, new_vy = bounce_vector_cardinal(math.cos(self.direction), math.sin(self.direction), col.normal.x, col.normal.y)
        self.direction = math.atan2(new_vy, new_vx)
    end
end

function Boomshroom:update(dt)
    self:update_fly(dt)
    self.t = self.t + dt

    self.state_machine:update(dt)
end

function Boomshroom:set_size(size)
    size = clamp(size, 1, #self.sizes) 
    self.spr:set_image(self.sizes[size].sprite)
    self:set_dimensions(self.sizes[size].w, self.sizes[size].h)
end

function Boomshroom:on_negative_life()
    self:start_exploding()
end

function Boomshroom:on_stomp_killed()
    self:start_exploding()
end

function Boomshroom:start_exploding()
    self.state_machine:set_state("exploding")
end

return Boomshroom