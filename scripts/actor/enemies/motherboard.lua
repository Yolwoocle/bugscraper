require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"
local ElectricRays = require "scripts.actor.enemies.electric_rays"
local StateMachine = require "scripts.state_machine"
local Timer = require "scripts.timer"
local Segment = require "scripts.math.segment"
local guns = require "data.guns"
local ElectricArc = require "scripts.actor.enemies.electric_arc"
local Chipper = require "scripts.actor.enemies.chipper"
local BigChipper360 = require "scripts.actor.enemies.big_chipper_360"
local MotherboardButton = require "scripts.actor.enemies.motherboard_button"
local FlyingDung = require "scripts.actor.enemies.flying_dung"
local Fly = require "scripts.actor.enemies.fly"
local AnimatedSprite = require "scripts.graphics.animated_sprite"
local UI = require "scripts.ui.ui"
local Explosion = require "scripts.actor.enemies.explosion"
local Sprite    = require "scripts.graphics.sprite"

local Motherboard = Enemy:inherit()

function Motherboard:init(x, y)
    self:init_enemy(x,y, images.motherboard, 24*16, 4)
    self.name = "motherboard" 

    self.damage = 0

    -- Parameters 
    self.follow_player = false
    self.max_life = 500
    self.life = self.max_life
    self.self_knockback_mult = 0
    self.is_pushable = false
    self.is_stompable = false
    self.gravity = 0
    self.kill_when_negative_life = false
    self.bullet_bounce_mode = BULLET_BOUNCE_MODE_NORMAL

    self.is_front = true

    self.is_affected_by_bounds = false

    -- rays and arcs
    self.rays = ElectricRays:new(self.mid_x, self.y + self.h + 24, {
        angle_speed = 0.2,
        n_rays = 7,
        spawn_state = "disabled",
    })
    game:new_actor(self.rays)

    -- timers
    self.state_timer = Timer:new(0)
    self.ray_timer = Timer:new(1.0)
    self.spawn_timer = Timer:new({0.5, 1.5})
    self.new_button_timer = Timer:new(1.5)

    -- state management
    self.next_state = nil

    -- guns
    self.plug_gun_offset = 26
    self.burst_gun = guns.unlootable.W2BossBurst:new(self)
    self.turret_gun = guns.unlootable.W2BossTurretGun:new(self)

    -- plugs
    self.plug_y = self.h - 9
    self.plug_offset = 0
    self.plug_sprite = AnimatedSprite:new({
        images.motherboard_plug_rays_1,
        images.motherboard_plug_rays_2,
    }, SPRITE_ANCHOR_CENTER_TOP, {frame_duration = 0.05})

    -- shield
    self.shield_sprite = Sprite:new(images.motherboard_shield, SPRITE_ANCHOR_CENTER_TOP)

    -- enemies
    self.max_chippers = 6
    self.dung_damage = 20
    self.enemy_mix = {
        {Chipper, 1},
        {Fly, 1},
        {FlyingDung, 2},
    }
    self.wave_enemies = {}

    local removeme_timer_mult = 1--0.1
    self.state_machine = StateMachine:new({
        rays = {
            enter = function(state)
                self.wave_enemies = {}
                self:set_bouncy(true)

                self.ray_timer:start()
                self.spawn_timer:start()

                self.ray_cycles_left = 7 * removeme_timer_mult
            end,
            exit = function(state)
                self.rays:set_state("disabled")

                for i = 1, #self.wave_enemies do
                    self.wave_enemies[i]:kill()
                end
            end,
            update = function(state, dt)
                local cabin_rect = game.level.cabin_inner_rect
                self.plug_sprite:update(dt)

                -- Update rays
                if self.ray_timer:update(dt) then
                    self.rays:set_state(({
                        disabled = "telegraph",
                        telegraph = "active",
                        active = "disabled",
                    })[self.rays.state])
                    self.ray_timer:start(1.0)

                    if self.rays.state == "disabled" then
                        self.ray_cycles_left = self.ray_cycles_left - 1
                        if self.ray_cycles_left <= 0 then
                            self:transition_to_next_state("charging")
                        end
                    end
                end

                -- Spawn enemies
                if self.spawn_timer:update(dt) then
                    if #self.wave_enemies < self.max_chippers then
                        local x0 = random_range(cabin_rect.ax + 16, cabin_rect.bx - 16)
                        local y0 = self.y + self.h + 16
                        local enemy_class = random_weighted(self.enemy_mix) 

                        local enemy 
                        if enemy_class == FlyingDung then
                            enemy = enemy_class:new(x0, y0, self)
                        else
                            enemy = enemy_class:new(x0, y0)
                        end
                        game:new_actor(enemy)

                        table.insert(self.wave_enemies, enemy)
                    end

                    self.spawn_timer:start()
                end

                -- Remove dead enemies
                for i = #self.wave_enemies, 1, -1 do
                    if self.wave_enemies[i].is_dead then
                        table.remove(self.wave_enemies, i)
                    end
                end
            end,
        },
        charging = {
            enter = function(state)
                self.wave_enemies = {}
                for i=1, 1 do
                    local chipper = BigChipper360:new(self.mid_x, self.y + self.h + 16)
                    game:new_actor(chipper)
                    table.insert(self.wave_enemies, chipper)
                end

                self.state_timer:start(20.0 * removeme_timer_mult)
                self:randomize_button_position()
                
                self:set_bouncy(true)
                self:spawn_button()
            end,
            update = function(state, dt)
                if self.state_timer:update(dt) then
                    self:transition_to_next_state("bullets")
                end

                if self.new_button_timer:update(dt) then
                    self:spawn_button()
                end
            end,
            exit = function(state)
                for _, e in pairs(self.wave_enemies) do
                    if not e.is_dead then
                        e:kill()
                    end
                end
            end
        },
        bullets = {
            enter = function(state)
                self.state_timer:start(15.0 * removeme_timer_mult)
                self.gun_target = self:get_random_player()

                self:set_bouncy(false)
                self.show_gun_barrels = true
                self.gun_directions = {
                    turret = {
                        a = 0,
                    },
                    burst = {
                        a = 0,
                    },
                }
            end,
            exit = function(state)
                self.show_gun_barrels = false
                self.gun_directions = nil
            end,
            update = function(state, dt)
                if self.state_timer:update(dt) then
                    self:transition_to_next_state("rays")
                end

                self.turret_gun:update(dt)
                self.burst_gun:update(dt)
                
                if not self.gun_directions then
                    return
                end
                
                if self.gun_target then
                    self.gun_directions.turret.a = get_angle_between_actors(self, self.gun_target, true)
                    local dx, dy = math.cos(self.gun_directions.turret.a), math.sin(self.gun_directions.turret.a)
                    self.turret_gun:shoot(dt, self, self.mid_x, self.mid_y + self.plug_gun_offset, dx, dy)
                end

                if not self.burst_gun.is_reloading and self.burst_gun.ammo == self.burst_gun.max_ammo then
                    local a = random_range(0, pi)
                    self.gun_directions.burst.a = a
                    self.burst_dirx, self.burst_diry = math.cos(a), math.sin(a)
                end
                if self.burst_dirx then
                    self.burst_gun:shoot(dt, self, self.mid_x, self.mid_y + self.plug_gun_offset, self.burst_dirx, self.burst_diry)
                end
            end,
        },
        transition = {
            enter = function(state)
                self.plug_offset = 16
                self.plug_offset_speed = 0
            end,
            update = function(state, dt)
                self.plug_offset_speed = self.plug_offset_speed - 400*dt
                self.plug_offset = self.plug_offset + self.plug_offset_speed*dt
                if self.plug_offset < -6 then
                    self.plug_offset = 0
                    if self.next_state then
                        self.state_machine:set_state(self.next_state)
                    end
                end
            end,
        },
        dying = {
            enter = function(state)
                self.plug_sprite.is_visible = false

                self.dying_timer = Timer:new(4.0)
                self.explosion_timer = Timer:new(0.3)
                self.dying_timer:start()
                self.explosion_timer:start()

                self.kill_on_next_frame= false
                self.is_immune_to_bullets = true
            end,
            update = function(state, dt)
                if self.explosion_timer:update(dt) then
                    local explosion = Explosion:new(random_range(self.x, self.x + self.w), random_range(self.y - 42, self.y+self.h), {use_gun = false})
                    explosion.is_front = true
                    game:new_actor(explosion)
                    self.explosion_timer:start()
                end
                
                if random_range(0, 1) < 0.05 then
                    Particles:spark(self.x + self.w*random_range(0, 1), random_range(self.y - 42, self.y+self.h))
                end

                if self.dying_timer:update(dt) then
                    self.kill_on_next_frame = true
                    game:frameskip(10)
                end

                if self.kill_on_next_frame then
                    self.kill_on_next_frame = false    
                    self:kill()

                    for r = 0, 1, 0.1 do
                        local explosion = Explosion:new(self.x + self.w*r, random_range(self.y - 42, self.y+self.h), {use_gun = false})
                        explosion.is_front = true
                        game:new_actor(explosion)
                    end
                end

                self.spr:update_offset(random_neighbor(5), random_neighbor(5))
            end
        }
    })

    self:transition_to_next_state("charging")
end

function Motherboard:set_bouncy(val)
    self.super.set_bouncy(self, val)

    self.shield_sprite:set_visible(val)
end

function Motherboard:transition_to_next_state(state)
    self.next_state = state
    self.state_machine:set_state("transition")

    if state == "rays" then
        self.plug_sprite:set_animation({
            images.motherboard_plug_rays_1,
            images.motherboard_plug_rays_2,
        })
    elseif state == "charging" then
        self.plug_sprite:set_animation({
            images.motherboard_plug_bullets,
        })
    elseif state == "bullets" then
        self.plug_sprite:set_animation({
            images.motherboard_plug_bullets,
        })
    end
end

function Motherboard:on_hit_flying_dung(dung)
    self:do_damage(self.dung_damage)
end

function Motherboard:update(dt)
    self:update_enemy(dt)

    self.state_machine:update(dt)
    if self.gun_directions then
        for gun_type, _ in pairs(self.gun_directions) do 
            if not self.gun_directions[gun_type].a_lerp then
                self.gun_directions[gun_type].a_lerp = self.gun_directions[gun_type].a
            else 
                self.gun_directions[gun_type].a_lerp = lerp_angle(self.gun_directions[gun_type].a_lerp, self.gun_directions[gun_type].a, 0.2)
            end
        end
    end

    self.shield_sprite:set_scale(nil, lerp(self.shield_sprite.sy, 1, 0.05))
end

function Motherboard:randomize_button_position()
    self.button_position = random_sample {
        {-5*BW, 0},
        {2*BW, 0},
        {-11*BW, -6},
        {8*BW, -6},
    }
end

function Motherboard:on_motherboard_button_pressed(button)
    self:randomize_button_position()
    self.new_button_timer:start()
end

function Motherboard:spawn_button()
    local button = MotherboardButton:new(self.mid_x + self.button_position[1], self.y + self.button_position[2], self)
    game:new_actor(button)
    table.insert(self.wave_enemies, button)
end

function Motherboard:draw()
    self:draw_enemy()
    local x, y = self.x + 193 + self.spr.ox, self.y - 19 + self.spr.oy
    UI:draw_icon_bar(x, y, 7 * (self.life/self.max_life), 7, 0, images.motherboard_led_on, images.motherboard_led_off, nil, 1)

    if self.gun_directions then
        for gun_name, gun_params in pairs(self.gun_directions) do
            draw_centered(images.motherboard_bullet_cannon, self.mid_x, self.y + self.plug_y + self.plug_gun_offset, gun_params.a_lerp)
        end
    end

    self.state_machine:draw()
    self.plug_sprite:draw(self.mid_x, self.y + self.plug_y + self.plug_offset, 0, 0)

    self.shield_sprite:draw(self.mid_x, self.y - 6, 0, 0)
end

function Motherboard:on_death()
    if self.wave_enemies then
        for _, e in pairs(self.wave_enemies) do
            e:kill()
        end
    end

    self.rays:kill()
end

function Motherboard:on_negative_life()
    if self.state_machine.current_state_name ~= "dying" then
        self.state_machine:set_state("dying")
    end
end

function Motherboard:on_bullet_bounced(bullet, col)
    self.shield_sprite:set_scale(nil, 1.5)
end

return Motherboard