require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"
local skins  = require "data.skins"

local Guns = require "data.guns"
local Timer = require "scripts.timer"

local Cocoon = Enemy:inherit()

function Cocoon:init(x, y, player)
    Cocoon.super.init(self, x,y, images.cocoon, 15, 15)
    self.name = "cocoon"

    self.player_n = player and (player.n or 1) or 1

    self.follow_player = false
    self.counts_as_enemy = false

    self.life = 12
    self.damage = 0
    self.self_knockback_mult = 0.1
    
	-- self.destroy_bullet_on_impact = false
	-- self.is_immune_to_bullets = true
    
    self.knockback = 0
    
    self.is_immune_to_explosions = true
    self.is_immune_to_electricity = true
    self.is_stompable = false
    self.do_stomp_animation = false
    self.stompable_cooldown_timer = Timer:new(0.5)
    self.stompable_cooldown_timer:start()
    -- self.stomps = 3 
    
    self.is_pushable = false
    self.is_knockbackable = false
    self.loot = {}

    self.has_revived = false

    self.gun = player and (player.gun) or nil
    
    local skin = player and (player.skin) or (skins[1])
    self.spr:set_outline(skin.color_palette[1], "round")

    self.sweat_timer = Timer:new(0.7):start()

    self.sound_damage = "sfx_actor_cocoon_damage_{01-07}"
    self.sound_death = "sfx_actor_cocoon_break"
    self.sound_stomp = "sfx_actor_cocoon_break"
end

function Cocoon:update(dt)
    self:update_enemy(dt)

    if self.stompable_cooldown_timer:update(dt) then
        self.is_stompable = true
    end

    if self.sweat_timer:update(dt) then
        Particles:sweat(self.x + self.w + 4, self.y - 4)
        self.sweat_timer:start()
    end
end

function Cocoon:on_death(damager, reason)
    if self.has_revived then
        return
    end
    
    self:revive(damager)
end

function Cocoon:revive(damager)    
    if game.players[self.player_n] then
        self:kill()
        return
    end

    local reviver
    if damager and damager.is_player then
        reviver = damager
    elseif damager and damager.is_bullet then
        reviver = damager.player
    elseif damager == nil then
        reviver = damager
    else
        return
    end

    self.has_revived = true

    Particles:floating_image({
        images.star_small_1,
        images.star_small_2,
    }, self.mid_x, self.mid_y, random_range_int(10, 12), 0, 0.25, 1, 120, 0.95)
    -- img, x, y,              amount,                  rot, life, s, vel, friction, params
    
    Particles:image(self.mid_x, self.mid_y, 20, {images.cocoon_fragment_1, images.cocoon_fragment_2}, self.w, nil, nil, 0.5)
    game:frameskip(10)

    game:revive_player(self.player_n, self.x, self.y)
    Audio:play("sfx_actor_cocoon_revive_{01-02}")
    
    if not self.is_dead then
        self:kill()
    end  
end

function Cocoon:draw()
    self:draw_enemy()
    
end

return Cocoon