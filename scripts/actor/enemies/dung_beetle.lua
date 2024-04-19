require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local Timer = require "scripts.timer"
local FlyingDung = require "scripts.actor.enemies.flying_dung"

local sounds = require "data.sounds"
local images = require "data.images"

local DungBeetle = Enemy:inherit()

function DungBeetle:init(x, y)
    self:init_enemy(x,y, images.daniel_small, 24, 20)
    self.name = "dung_beetle"
    self.follow_player = false

    self.damage = 1
    -- self.self_knockback_mult = 0.1

    self.knockback = 0
    
    self.is_pushable = false
    self.is_knockbackable = false
    self.is_stompable = false
    self.destroy_bullet_on_impact = false
	self.is_immune_to_bullets = true

    self.sound_damage = {"cloth1", "cloth2", "cloth3"}
    self.sound_death = "cloth_drop"
    self.sound_stomp = "cloth_drop"

    self.spawn_dung_timer = Timer:new(2.0)
    self.spawn_dung_timer:start()
    self.dung_limit = 6
    self.dungs = {}

    self.hits = self.dung_limit
    self.life = math.huge
    self.unridden_life = 15
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
end

function DungBeetle:on_death()
    Particles:image(self.mid_x, self.mid_y, 20, {images.dummy_target_ptc1, images.dummy_target_ptc2}, self.w, nil, nil, 0.5)

    for i = 1, #self.dungs do
        local dung = self.dungs[i]
        dung:kill()
    end
end

function DungBeetle:draw()
    self:draw_enemy()

    print_outline(nil, nil, tostring(self.hits), self.mid_x + 20, self.mid_y)
end

function DungBeetle:on_hit_flying_dung(flying_dung)
    self.hits = math.max(0, self.hits - 1)
    self:do_damage(10, flying_dung)

    if self.vehicle then
        self.vehicle:do_damage(1, flying_dung)

        if self.hits <= 0 then
            self.vehicle:kill()
            self:unride()
        end
    end
end

function DungBeetle:unride()
    self.follow_player = true 
    self.is_pushable = true
    self.is_knockbackable = true

    self.destroy_bullet_on_impact = true
	self.is_immune_to_bullets = false

    self.life = self.unridden_life
end

return DungBeetle