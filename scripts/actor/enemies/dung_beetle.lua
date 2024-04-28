require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local Timer = require "scripts.timer"
local FlyingDung = require "scripts.actor.enemies.flying_dung"

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

    self.anim_frame_len = 0.2
    self.anim_frames = {images.dung_beetle_1, images.dung_beetle_2}

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
    if self.vehicle then
        self.anim_frame_len = math.abs(10/self.vehicle.vx)
        self.flip_x = self.vehicle.vx < 0
    else
        self.anim_frame_len = 0.2
    end
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
        draw_centered(images.dung_beetle_shield, self.mid_x, self.mid_y)
        -- print_outline(nil, nil, tostring(self.anim_frame_len), self.mid_x + 20, self.mid_y)
    end
end

function DungBeetle:on_hit_flying_dung(flying_dung)
    self.hits = math.max(0, self.hits - 1)
    
    self:do_damage(5, flying_dung)
    if self.vehicle then
		self.vehicle:do_knockback(self.vehicle.self_knockback_mult, flying_dung)
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