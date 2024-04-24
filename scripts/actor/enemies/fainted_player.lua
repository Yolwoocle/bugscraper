require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"
local Guns = require "data.guns"

local FaintedPlayer = Enemy:inherit()

function FaintedPlayer:init(x, y, player)
    self:init_enemy(x,y, player.skin.spr_dead, 13, 13)
    self.name = "fainted_player"

    self.player_n = player.n or 1

    self.follow_player = false
    self.counts_as_enemy = true

    self.life = 12
    self.damage = 0
    self.self_knockback_mult = 0.1
    
	self.destroy_bullet_on_impact = false
	self.is_immune_to_bullets = true

    self.knockback = 0
    
    self.is_pushable = false
    self.is_knockbackable = false
    self.loot = {}

    self.sound_damage = {"cloth1", "cloth2", "cloth3"}
    self.sound_death = "cloth_drop"
    self.sound_stomp = "cloth_drop"
end

function FaintedPlayer:update(dt)
    self:update_enemy(dt)
end

function FaintedPlayer:on_death(damager, reason)
    Particles:image(self.mid_x, self.mid_y, 20, {images.cocoon_fragment_1, images.cocoon_fragment_2}, self.w, nil, nil, 0.5)
    local player = game:new_player(self.player_n, self.x, self.y)
    
    player:set_invincibility(player.max_iframes)

    local l = math.floor(damager.life/2)
    if damager.life > 1 then
        player:set_life(l)
        damager:set_life(damager.life - l)
    else 
        player:set_life(1)
        damager:set_life(0)
    end
end

return FaintedPlayer