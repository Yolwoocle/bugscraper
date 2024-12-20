require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local Timer = require "scripts.timer"
local FlyingDung = require "scripts.actor.enemies.flying_dung"
local AnimatedSprite = require "scripts.graphics.animated_sprite"

local sounds = require "data.sounds"
local images = require "data.images"

local DungBeetle = Enemy:inherit()

function DungBeetle:init(x, y)
    self:init_enemy(x,y, images.dung_beetle_1, 24, 16)
    self.name = "dung_beetle"
    self.follow_player = false

    self.damage = 1
    self.life = math.huge

    self.knockback = 0
    
    self.is_pushable = false
    self.is_knockbackable = false
    self.is_stompable = false
    self.destroy_bullet_on_impact = false
	self.is_immune_to_bullets = true
    self.is_bouncy_to_bullets = true

    self.spawn_dung_timer = Timer:new(2.0)
    self.spawn_dung_timer:start()
    self.dung_limit = 6
    self.dungs = {}

    self.spr = AnimatedSprite:new({
        idle = {
            {images.dung_beetle_walk_1},
            0.1
        },
        walk = {
            {images.dung_beetle_walk_1, images.dung_beetle_walk_2},
            0.1
        },
        run = {
            {images.dung_beetle_1, images.dung_beetle_2, images.dung_beetle_3, images.dung_beetle_4, images.dung_beetle_5, images.dung_beetle_6}, 
            0.08
        },
    }, "idle") 

    self.hits = self.dung_limit
    self.life = math.huge
    self.unridden_life = 10

    self.has_unridden = false
end

function DungBeetle:update(dt)
    self:update_enemy(dt)

    if self.spawn_dung_timer:update(dt) and self.vehicle then
        local flying_dung = FlyingDung:new(self.mid_x, self.mid_y, self)
        flying_dung:center_actor()
        game:new_actor(flying_dung)
        table.insert(self.dungs, flying_dung)

        if #self.dungs < self.dung_limit then
            self.spawn_dung_timer:start()
        end
    end
    
    for i = #self.dungs, 1, -1 do
        local dung = self.dungs[i]
        if dung.is_removed then
            table.remove(self.dungs, i)
            self.spawn_dung_timer:start()
        end
    end

    if self.vehicle == nil and not self.has_unridden then
        self.has_unridden = true
        self:unride()
    end

    -- animation
    self.debug_values[1] = ""
    self.debug_values[2] = ""
    if self.vehicle and math.abs(self.vehicle.vx) > 80 then
        self.spr:set_animation("run")
        self.spr:set_flip_x(self.vehicle.vx < 0)
        self.debug_values[3] = "80"
        
    elseif self.vehicle and math.abs(self.vehicle.vx) > 40 then
        self.spr:set_animation("walk")
        self.spr:set_flip_x(self.vehicle.vx < 0)
        self.debug_values[3] = "40"
        
    elseif not self.vehicle then
        self.spr:set_animation("walk")
        self.debug_values[3] = "not vehicle"
        
    else
        self.spr:set_animation("idle")
        self.debug_values[3] = "huge"
    end
    self.anim_frame_len = 0.08

end

function DungBeetle:on_death()
    for i = 1, #self.dungs do
        local dung = self.dungs[i]
        dung:kill()
    end
end

function DungBeetle:draw()
    self:draw_enemy()

    if self.vehicle then
        draw_centered(images.dung_beetle_shield, self.mid_x, self.mid_y, -self.vehicle.spr.rot)
        draw_centered(images.dung_beetle_shield_shine, self.mid_x, self.mid_y)
        -- print_outline(nil, nil, tostring(self.anim_frame_len), self.mid_x + 20, self.mid_y)
    end
end

function DungBeetle:on_hit_flying_dung(flying_dung)
    self.hits = math.max(0, self.hits - 1)
    
    self:do_damage(5, flying_dung)
    if self.vehicle and self.vehicle.state_machine.current_state_name ~= "bunny_hopping" then
        if sign(self.vehicle.vx) == -sign(flying_dung.vx) then
            self.vehicle:do_knockback(self.vehicle.self_knockback_mult, sign(flying_dung.vx) * 20, 0)
        end
        self.vehicle:do_damage(5, flying_dung)
    end
end

function DungBeetle:unride()
    self.follow_player = true 
    self.is_pushable = true
    self.is_knockbackable = true

    self.destroy_bullet_on_impact = true
	self.is_immune_to_bullets = false
    self.is_bouncy_to_bullets = false

    self.life = self.unridden_life
end

return DungBeetle