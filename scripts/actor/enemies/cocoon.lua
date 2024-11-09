require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"
local Guns = require "data.guns"

local Cocoon = Enemy:inherit()

function Cocoon:init(x, y, player_n)
    self:init_enemy(x,y, images.cocoon, 15, 26)
    self.player_n = player_n or 1
    
    self.name = "cocoon"
    self.follow_player = false
    self.counts_as_enemy = true
    
    self.life = 12
    self.damage = 0
    self.self_knockback_mult = 0.1
    
	-- self.destroy_bullet_on_impact = false
	-- self.is_immune_to_bullets = true

    self.knockback = 0
    
    self.is_pushable = false
    self.is_knockbackable = false
    self.loot = {}

    self.sound_damage = {"cloth1", "cloth2", "cloth3"}
    self.sound_death = "cloth_drop"
    self.sound_stomp = "cloth_drop"
end

function Cocoon:update(dt)
    self:update_enemy(dt)
end

function Cocoon:on_death(damager, reason)
    Particles:image(self.mid_x, self.mid_y, 20, {images.cocoon_fragment_1, images.cocoon_fragment_2}, self.w, nil, nil, 0.5)
    local player = game:new_player(self.player_n, self.x, self.y)
    
    player:set_invincibility(player.max_invincible_time)

    -- local l = math.floor(damager.life/2)
    -- player:set_life(l)
    -- damager:set_life(damager.life - l)
end

return Cocoon